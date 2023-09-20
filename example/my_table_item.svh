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

class my_table_item extends my_item;

  `uvm_object_utils(my_table_item)

  function new(string name="my_table_item");
    super.new(name);
  endfunction

  // The columns in the log file's table and the order of the columns are specified by the
  // following static array of strings.  Each element is a tag that represents the column.
  // The actual title of the column is set with table_logger_cfg.
  static string log_fields[] = {"ifc", "a", "b", "c"};

  typedef string rows_of_log_fields_t[][string];
  virtual function rows_of_log_fields_t get_log_table();
    get_log_table = new[1]; // This transaction is reported on a single row in the table
    get_log_table[0]["ifc"] = ifc;
    get_log_table[0]["a"] = $sformatf("%0x", a);
    get_log_table[0]["b"] = $sformatf("%0d", b);
    get_log_table[0]["c"] = c.name();
  endfunction

endclass
