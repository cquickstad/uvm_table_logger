# uvm_table_logger
An abstract generic logger that logs UVM transactions from a monitor in an attractive, well-formatted, and highly configurable text table.

## To use:
1. Add a static array of strings named `log_fields` to your transaction object to indicate the table fields/columns and the order of those columns in the table.  (These strings define unique tags for the columns. The actual descriptive names that appear in the log file will be determined by `table_logger_cfg.col_title`.)
   ```systemverilog
   class my_txn extends uvm_object;
     ...
     static string log_fields[] = {"column_a_tag", "column_b_tag", "column_c_tag"};
     ...
   endclass
   ```
2. Add a `get_log_table()` function (method) to your transaction object that returns the type `rows_of_log_fields_t`.  Populate the return data (rows of fields) to represent the transaction in table format.
   ```systemverilog
   class my_txn extends uvm_object;
     ...
     virtual function rows_of_log_fields_t get_log_table();
       get_log_table = new[2]; // Two rows in the log
       get_log_table[0]["column_a_tag"] = "line 1 column A";
       get_log_table[0]["column_b_tag"] = "line 1 column B";
       get_log_table[0]["column_c_tag"] = "line 1 column C";
       get_log_table[1]["column_a_tag"] = "line 2 column A";
       // table_logger_cfg.empty_field_value is printed for entries that don't exist
       // get_log_table[1]["column_b_tag"] = "line 2 column B";
       get_log_table[1]["column_c_tag"] = "line 2 column C";
     endfunction
     ...
   endclass
   ```
3. Instantiate a `table_logger_cfg` instance (or a child of it), specify the log configuration, and add it to the `uvm_config_db`.  The logger gets it in its `connect_phase` with the field name `"cfg"`, so set it with field name `"cfg"` and an instance path that matches the logger's instance name from step 4 (`"logger"` here).
   ```systemverilog
   class my_env extends uvm_env;
     ...
     table_logger_cfg log_cfg;
     ...
     virtual function void build_phase(uvm_phase phase);
       ...
       log_cfg = table_logger_cfg::type_id::create("log_cfg", this);
       log_cfg.log_file_name = "bus.log";
       log_cfg.col_title["column_a_tag"] = "Column\nA";
       log_cfg.col_title["column_b_tag"] = "Column\nB";
       log_cfg.col_title["column_c_tag"] = "Column\nC";
       log_cfg.col_width["column_b_tag"] = 20;
       // "logger" must match the logger's instance name (step 4).  The field name must be "cfg".
       uvm_config_db#(table_logger_cfg)::set(this, "logger", "cfg", log_cfg);
       ...
     endfunction
     ...
   endclass
   ```
4. Instantiate a `table_logger` instance (or a child of it).
   ```systemverilog
   class my_env extends uvm_env;
     ...
     table_logger#(my_txn, my_txn) logger;
     ...
     virtual function void build_phase(uvm_phase phase);
       ...
       // The name must match the uvm_config_db path used for the cfg (step 3). 
       logger = table_logger#(my_txn, my_txn)::type_id::create("logger", this);
       ...
     endfunction
     ...
   endclass
   ```
5. Connect your monitor's analysis port to `table_logger.analysis_export` in the `connect_phase`.
   ```systemverilog
   class my_env extends uvm_env;
     ...
     virtual function void connect_phase(uvm_phase phase);
       ...
       agent.monitor.ap.connect(logger.analysis_export);
       ...
     endfunction
     ...
   endclass
   ```

## Border styles
The table borders are drawn in ASCII by default.  Set `table_logger_cfg.border_style` to a border style object to use
Unicode box-drawing characters instead.  The border style classes are in `txt_tbl_pkg`, which `table_logger_pkg.sv`
includes, so either `import txt_tbl_pkg::*;` or use the `txt_tbl_pkg::` prefix:
```systemverilog
txt_tbl_pkg::txt_tbl_unicode_border_style style = new();
log_cfg.border_style = style;
```

| Border style class                           | Result      |
|----------------------------------------------|-------------|
| (none) or `txt_tbl_ascii_border_style`       | `+---+---+` |
| `txt_tbl_unicode_border_style`               | `┌───┬───┐` |
| `txt_tbl_unicode_heavy_border_style`         | `┏━━━┳━━━┓` |
| `txt_tbl_unicode_double_border_style`        | `╔═══╦═══╗` |
| `txt_tbl_unicode_double_header_border_style` | `╒═══╤═══╕` |

`txt_tbl_unicode_double_header_border_style` sets the header apart from the rows with double horizontal lines, and
uses light lines everywhere else:
```systemverilog
txt_tbl_pkg::txt_tbl_unicode_double_header_border_style style = new();
log_cfg.border_style = style;
```
```text
╒══════╤══════╤══════╤══════╕
│ line │ time │ addr │ data │
╞══════╪══════╪══════╪══════╡
│    1 │   10 │  1a2 │   5f │
│    2 │   20 │  1a3 │   60 │
```

The logger writes the top rule and the header at the start of simulation, then writes each row as its transaction
arrives.  It does not write a bottom rule, so the table is left open after the last row.  (The `bottom*()` characters
of a style are used only when calling `txt_tbl.get_border_bottom()` directly.)

The Unicode styles write UTF-8, so view the log with a UTF-8 capable viewer/terminal.  (In the source, the box-drawing
characters are written as octal escapes rather than literal UTF-8 characters for simulator compatibility.)

To make a custom style, extend `txt_tbl_border_style` (or one of the styles above) and override its functions.  For
example, light lines with rounded corners:
```systemverilog
class rounded_border_style extends txt_tbl_pkg::txt_tbl_unicode_border_style;
  virtual function string top_left();     return "\342\225\255"; endfunction
  virtual function string top_right();    return "\342\225\256"; endfunction
  virtual function string bottom_right(); return "\342\225\257"; endfunction
  virtual function string bottom_left();  return "\342\225\260"; endfunction
endclass
```

`txt_tbl` provides `get_border_top()`, `get_border_header()`, `get_border_middle()`, and `get_border_bottom()` so that
each horizontal rule uses the matching corner/intersection characters.  (`get_border()` is the same as
`get_border_middle()`.)  To give the header its own look in a custom style, override the `header_*()` functions of
`txt_tbl_border_style`.

## Example
See the `example` directory for a complete simple UVM testbench that uses the table logger.
