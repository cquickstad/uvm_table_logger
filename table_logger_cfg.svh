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

class table_logger_cfg extends uvm_object;

  // The file to which this logger will write the log.
  string log_file_name = "file_name.log";

  // The value to place in a table location when that field is otherwise empty.
  string empty_field_value = "-";

  bit col_en[string];
  int col_width[string];
  string col_title[string];
  bit col_title_left_justify[string];
  bit col_field_left_justify[string];
  bit col_sticky_width_growth[string];

  `uvm_object_utils(table_logger_cfg)

  function new(string name="table_logger_cfg");
    super.new(name);
  endfunction

  function void do_copy(uvm_object rhs);
    table_logger_cfg rhs_;
    if (!$cast(rhs_, rhs)) `uvm_fatal("TABLE_LOGGER_CFG_CAST:", "Failed to cast to table_logger_cfg")
    super.do_copy(rhs);
    this.log_file_name = rhs_.log_file_name;
    this.empty_field_value = rhs_.empty_field_value;
    this.col_en = rhs_.col_en;
    this.col_width = rhs_.col_width;
    this.col_title = rhs_.col_title;
  endfunction

  function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    table_logger_cfg rhs_;
    do_compare = super.do_compare(rhs, comparer);
    if (!$cast(rhs_, rhs)) `uvm_fatal("TABLE_LOGGER_CFG_CAST:", "Failed to cast to table_logger_cfg")
    do_compare &= (this.log_file_name == rhs_.log_file_name);
    do_compare &= (this.empty_field_value == rhs_.empty_field_value);
    do_compare &= (this.col_en.size() == rhs_.col_en.size());
    do_compare &= (this.col_width.size() == rhs_.col_width.size());
    do_compare &= (this.col_title.size() == rhs_.col_title.size());
    do_compare &= (this.col_title_left_justify.size() == rhs_.col_title_left_justify.size());
    do_compare &= (this.col_field_left_justify.size() == rhs_.col_field_left_justify.size());
    do_compare &= (this.col_sticky_width_growth.size() == rhs_.col_sticky_width_growth.size());
    foreach (this.col_en[s]) do_compare &= (rhs_.col_en.exists(s) && (this.col_en[s] == rhs_.col_en[s]));
    foreach (this.col_width[s]) do_compare &= (rhs_.col_width.exists(s) && (this.col_width[s] == rhs_.col_width[s]));
    foreach (this.col_title[s]) do_compare &= (rhs_.col_title.exists(s) && (this.col_title[s] == rhs_.col_title[s]));
    foreach (this.col_title_left_justify[s]) do_compare &= (rhs_.col_title_left_justify.exists(s) && (this.col_title_left_justify[s] == rhs_.col_title_left_justify[s]));
    foreach (this.col_field_left_justify[s]) do_compare &= (rhs_.col_field_left_justify.exists(s) && (this.col_field_left_justify[s] == rhs_.col_field_left_justify[s]));
    foreach (this.col_sticky_width_growth[s]) do_compare &= (rhs_.col_sticky_width_growth.exists(s) && (this.col_sticky_width_growth[s] == rhs_.col_sticky_width_growth[s]));
  endfunction

endclass
