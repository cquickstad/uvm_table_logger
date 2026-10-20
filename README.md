# uvm_table_logger
An abstract generic logger that logs UVM transactions from a monitor in an attractive, well-formatted, and highly configurable text table.

For example:
```text
╒══════╤═════════╤═════╤═══════════════╤══════════════════╕
│ Line │    Time │ Ifc │ Value A (hex) │          Value C │
╞══════╪═════════╪═════╪═══════════════╪══════════════════╡
│    1 │ 1649000 │   X │      9f3070b3 │  LAST_ENUM_VALUE │
│    2 │ 2049000 │   Y │      6f1d78ed │ THIRD_ENUM_VALUE │
│    3 │ 2249000 │   X │      2ec7cf25 │ FIRST_ENUM_VALUE │
```

## Setup
### Requirements
* A SystemVerilog simulator with UVM.  The example runs on Xcelium (UVM 1.2) and Verilator (UVM IEEE 1800.2-2020).

### Get the code
```sh
git clone https://github.com/cquickstad/uvm_table_logger.git
```
The `txt_tbl` directory (from [txt_tbl](https://github.com/cquickstad/txt_tbl)) is a
[git-subrepo](https://github.com/ingydotnet/git-subrepo), so its files are already in this repository.  No submodule
commands are needed.

### Compile
1. Add the repository directory and its `txt_tbl` directory to the include path.
2. Compile `table_logger_pkg.sv` after `uvm_pkg` and before your package that uses it.  It includes `txt_tbl_pkg.sv`,
   so you don't need to compile that separately.

For example, with Xcelium:
```sh
xrun -sv -uvm \
  -incdir <path>/uvm_table_logger \
  -incdir <path>/uvm_table_logger/txt_tbl \
  <path>/uvm_table_logger/table_logger_pkg.sv \
  my_pkg.sv \
  top.sv
```
With Verilator, the equivalent options are `+incdir+<path>/uvm_table_logger` and
`+incdir+<path>/uvm_table_logger/txt_tbl`.  See `example/run.sh` (Xcelium) and `example/verilator_run.sh` (Verilator)
for complete command lines.

## To use:
`table_logger`, `table_logger_cfg`, and `rows_of_log_fields_t` are in `table_logger_pkg`.  The code below assumes
that the package where it lives imports it:
```systemverilog
package my_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import table_logger_pkg::*;
  ...
endpackage
```
(Otherwise, use the `table_logger_pkg::` prefix, as the `example` directory does.)

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
4. Instantiate a `table_logger` instance (or a child of it).  It takes two type parameters,
   `table_logger#(T_CAST, T_SUBSCRIBER)`:
   * `T_SUBSCRIBER` is the type that the monitor's analysis port writes.
   * `T_CAST` is the type that has `log_fields` and `get_log_table()`.  Each item received is `$cast` to it (a failed
     cast is a `uvm_fatal`), so it must be `T_SUBSCRIBER` or a child of it.

   When your transaction has `log_fields` and `get_log_table()` itself, use it for both, as below.  To log an existing
   transaction without modifying its source (for example, from third-party VIP), extend it with `log_fields` and
   `get_log_table()`, use a factory override so the monitor creates the child, and use
   `table_logger#(my_table_txn, my_txn)`.  The `example` directory does this.
5. Connect your monitor's analysis port to `table_logger.analysis_export` in the `connect_phase`.

Steps 3–5 together in an environment:
```systemverilog
class my_env extends uvm_env;
  `uvm_component_utils(my_env)

  my_agent                      agent;
  table_logger_cfg              log_cfg;
  table_logger#(my_txn, my_txn) logger;

  function new(string name="my_env", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = my_agent::type_id::create("agent", this);

    // Step 3: Configure the logger
    log_cfg = table_logger_cfg::type_id::create("log_cfg", this);
    log_cfg.log_file_name = "bus.log";
    log_cfg.col_title["column_a_tag"] = "Column\nA";
    log_cfg.col_title["column_b_tag"] = "Column\nB";
    log_cfg.col_title["column_c_tag"] = "Column\nC";
    log_cfg.col_width["column_b_tag"] = 20;
    // "logger" must match the logger's instance name (step 4).  The field name must be "cfg".
    uvm_config_db#(table_logger_cfg)::set(this, "logger", "cfg", log_cfg);

    // Step 4: Create the logger
    // The name must match the uvm_config_db path used for the cfg (step 3).
    logger = table_logger#(my_txn, my_txn)::type_id::create("logger", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // Step 5: Connect the monitor to the logger
    agent.monitor.ap.connect(logger.analysis_export);
  endfunction
endclass
```

## Configuration
All configuration is in `table_logger_cfg`.  The `col_*` settings are associative arrays indexed by column tag (the
strings in `log_fields`).  A column that has no entry uses the default.

The order of the columns in the table is set by the order of the tags in the transaction's
`static string log_fields[]`, not by `table_logger_cfg`.  To reorder the columns, reorder the tags in `log_fields`.

The logger adds two columns, with tags `"line"` and `"time"`, before the columns in `log_fields`.  `line` counts the rows
logged, starting at 1, and `time` is `$time` when the row was logged.  They can be configured like any other column.

| Setting                            | Default             | Description                                                    |
|------------------------------------|---------------------|----------------------------------------------------------------|
| `log_file_name`                    | `"file_name.log"`   | The file the table is written to.                              |
| `empty_field_value`                | `"-"`               | Written for a field that `get_log_table()` didn't set.         |
| `border_style`                     | `null` (ASCII)      | The characters used to draw the borders.  See [Border styles](#border-styles). |
| `col_en[tag]`                      | `1`                 | `0` leaves the column out of the table.                        |
| `col_title[tag]`                   | the tag             | The column title.  `"\n"` starts a new title line.             |
| `col_width[tag]`                   | `0`                 | The minimum column width.  The column is never narrower than its title. |
| `col_title_left_justify[tag]`      | `0` (right-justify) | `1` left-justifies the title.                                  |
| `col_field_left_justify[tag]`      | `0` (right-justify) | `1` left-justifies the fields.                                 |
| `col_sticky_width_growth[tag]`     | `1`                 | When a field is wider than its column, the field is written in full and the row is misaligned.  With `1`, the column stays at the new width for later rows; with `0`, it goes back to its width for later rows. |

Fields are never truncated, so set `col_width` wide enough for the widest value to keep the rows aligned.  Because the
header is written before any rows, it can't be widened to match.  These helpers set `col_width` (or `col_title`) for
common cases:

| Helper                                                 | Description                                                        |
|--------------------------------------------------------|--------------------------------------------------------------------|
| `set_col_width_for_hex(tag, bit_width)`                | Width of a `bit_width`-bit value in hexadecimal.                   |
| `set_col_width_for_dec_bits(tag, bit_width)`           | Width of the largest `bit_width`-bit unsigned value in decimal.    |
| `set_col_width_for_dec_max(tag, max_value)`            | Width of `max_value` in decimal.                                   |
| `set_col_title_vertical(tag, title)`                   | Writes the title vertically, one character per line.               |
| `enum_width_finder#(my_enum_t)::get_max_width()`       | The length of the longest name in an enum, to set `col_width` with. |

For example:
```systemverilog
log_cfg.col_en["time"] = 0; // Don't log the time
log_cfg.set_col_width_for_hex("addr", $bits(addr_t));
log_cfg.col_width["kind"] = enum_width_finder#(kind_t)::get_max_width();
log_cfg.col_field_left_justify["kind"] = 1;
log_cfg.set_col_title_vertical("err", "Error");
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

## License
Licensed under the [Apache License, Version 2.0](LICENSE).  The `txt_tbl` directory is also licensed under the Apache
License, Version 2.0 (see [txt_tbl/LICENSE](txt_tbl/LICENSE)).
