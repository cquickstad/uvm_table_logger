# uvm_table_logger
An abstract generic logger that logs UVM transactions from a monitor in an attractive, well-formatted, and highly configurable text table.

## To use:
  1. Add a static array of strings named `log_fields` to your transaction object to indicate the table fields/columns and the order of those columns in the table.  (These strings define unique tags for the columns. The actual descriptive names that appear in the log file will be determined by `table_logger_cfg.col_title`.)
```
class my_txn extends uvm_object;
  ...
  static string log_fields[] = {"column_a_tag", "column_b_tag", "column_c_tag"};
  ...
endclass
```
  2. Add a `get_log_table()` function (method) to your transaction object that returns the type `rows_of_log_fields_t`.  Populate the return data (rows of fields) to represet the transaction in table format.
```
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
  3. Instantiate a `table_logger_cfg` instance (or a child of it), specify the log configuration, and add it to the `vm_config_db`.
```
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
    uvm_config_db#(table_logger_cfg)::set(this, "logger", "cfg", log_cfg);
    ...
  endfunction
  ...
endclass
```
  4. Instantiate a `table_logger` instance (or a child of it).
```
class my_env extends uvm_env;
  ...
  table_logger#(my_txn, my_txn) logger;
  ...
  virtual function void build_phase(uvm_phase phase);
    ...
    logger = table_logger#(my_txn, my_txn)::type_id::create("logger", this);
    ...
  endfunction
  ...
endclass
```
  5. Connect your monitor's analysis port to `table_logger.analysis_export` in the `connect_phase`.
```
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
