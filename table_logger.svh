// -------------------------------------------------------------
//    Copyright 2020 Chad Quickstad
//    All Rights Reserved Worldwide
//
//    Licensed under the Apache License, Version 2.0 (the
//    "License"); you may not use this file except in
//    compliance with the License.  You may obtain a copy of
//    the License at
//
//        http://www.apache.org/licenses/LICENSE-2.0
//
//    Unless required by applicable law or agreed to in
//    writing, software distributed under the License is
//    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//    CONDITIONS OF ANY KIND, either express or implied.  See
//    the License for the specific language governing
//    permissions and limitations under the License.
// -------------------------------------------------------------

// Look for the latest version of this code at:
//  https://github.com/cquickstad/uvm_table_logger.git

// See the 'example' directory for a usage example.

// In order to use the table_logger, you must:
// 1. Add a static array of strings to your transaction object to indicate the table fields/columns and
//    the order of those columns in the table.
// 2. Add add a get_log_table() function to your transaction object that returns type rows_of_log_fields_t.
//    Remember to populate the return data (rows of fields) to represent the transaction in table format.
// 3. Instantiate a table_logger_cfg instance (or a child of it) and add add it to the uvm_config_db.
// 4. Instantiate a table_logger instance.
// 5. Connect your monitor's analysis port to the table_logger's analysis_export in the connect_phase.


typedef string rows_of_log_fields_t[][string]; // Return type for T_CAST.get_log_table()

// A dummy object needed because the default type for T_CAST type requires log_fields[] and get_log_table().
class dummy_tbl_txn;
  static string log_fields[] = {"column1", "column2"};
  virtual function rows_of_log_fields_t get_log_table();
    string s[string] = '{"column1": "value a", "column2": "value b"};
    return {s}; // Return only a single row.
  endfunction
endclass


// The dual types in the template arguments allow you to use a transaction object that may not be natively
// compatible with the table_logger (i.e. it may not have log_fields[] or get_log_table()).
// T_CAST must be a child of T_SUBSCRIBER or the same type as T_SUBSCRIBER.
class table_logger #(type T_CAST=dummy_tbl_txn, type T_SUBSCRIBER=dummy_tbl_txn) extends uvm_subscriber #(T_SUBSCRIBER);

  // Reminder: uvm_subscriber provides analysis_export

  table_logger_cfg cfg;

  protected txt_tbl tt; // See https://github.com/cquickstad/txt_tbl.git
  protected int fd; // File Descriptor
  protected T_CAST t;
  protected string rows_of_fields[][string];
  protected string row_fields[string];
  protected string row_q[$];
  protected int line_count = 0;
  protected string fields[$];

  `uvm_component_param_utils(table_logger#(T_CAST, T_SUBSCRIBER))

  function new(string name="table_logger", uvm_component parent=null);
    super.new(name, parent);
    tt = new(); // It's not UVM, so new() instead of create()
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(!uvm_config_db#(table_logger_cfg)::get(this, "", "cfg", cfg)) `uvm_fatal("TABLE_LOGGER_CFG", "cfg not found in uvm_config_db")
  endfunction

  virtual function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    get_field_names();
    configure_table();
    open_file();
    print_header();
  endfunction

  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    close_file();
  endfunction

  // This method must exist for a uvm_subscriber.
  // It is automatically called when an item comes though the analysis port.
  virtual function void write(T_SUBSCRIBER t);
    if (t == null) return;
    if (!$cast(this.t, t)) `uvm_fatal("TABLE_LOGGER_CAST", "Failed to cast analysis port item.")
    log_txn();
  endfunction

  protected virtual function void get_field_names();
    // The transaction object being logged is the holder of the fields
    // to log and should determine what those fields are.
    fields = T_CAST::log_fields;
    fields = {"line", "time", fields};
  endfunction

  protected virtual function bit field_en(int i);
    return (i < fields.size()) && (!cfg.col_en.exists(fields[i]) || cfg.col_en[fields[i]]);
  endfunction

  protected virtual function void configure_table();
    foreach (fields[i]) configure_column(i);
  endfunction

  protected virtual function void configure_column(int i);
    if (field_en(i)) add_column(i);
  endfunction

  protected virtual function void add_column(int i);
    string f = fields[i];
    string column_title = (cfg.col_title.exists(f)) ? cfg.col_title[f] : f;
    int width = (cfg.col_width.exists(f)) ? cfg.col_width[f] : 0;
    int left_justify_title = (cfg.col_title_left_justify.exists(f)) ? cfg.col_title_left_justify[f] : 0;
    int left_justify_field = (cfg.col_field_left_justify.exists(f)) ? cfg.col_field_left_justify[f] : 0;
    int sticky_width_growth = (cfg.col_sticky_width_growth.exists(f)) ? cfg.col_sticky_width_growth[f] : 1;
    tt.add_column(column_title, width, left_justify_title, left_justify_field, sticky_width_growth);
  endfunction

  protected virtual function void open_file();
    fd = $fopen(cfg.log_file_name);
    if (fd == 0) `uvm_fatal("TABLE_LOGGER_FILE_OPEN", $sformatf("Failed to open file '%s' for writing", cfg.log_file_name))
  endfunction

  protected virtual function void close_file();
    $fclose(fd);
  endfunction

  protected virtual function void log(string s);
    $fdisplay(fd, s);
  endfunction

  protected virtual function void print_header();
    log(tt.get_border());
    log(tt.get_header());
    log(tt.get_border());
  endfunction

  protected virtual function void log_txn();
    rows_of_fields = t.get_log_table();
    foreach (rows_of_fields[r]) begin
      row_fields = rows_of_fields[r];
      log_row();
    end
  endfunction

  protected virtual function void log_row();
    row_q = {};
    build_row_q();
    log(tt.get_row(row_q));
  endfunction

  protected virtual function void build_row_q();
    foreach (fields[i]) if (field_en(i)) add_field_to_row_q(i);
  endfunction

  protected virtual function void add_field_to_row_q(int i);
    row_q.push_back(get_field_str(fields[i]));
  endfunction

  protected virtual function string get_field_str(string field);
    if (field == "line") return get_line_str();
    if (field == "time") return get_time_str();
    if (row_fields.exists(field)) return row_fields[field];
    return cfg.empty_field_value;
  endfunction

  protected virtual function string get_line_str();
    return $sformatf("%0d", ++line_count);
  endfunction

  protected virtual function string get_time_str();
    return $sformatf("%0t", $time());
  endfunction

endclass

