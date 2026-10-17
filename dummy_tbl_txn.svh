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

// A dummy object needed because the default type for T_CAST type requires log_fields[] and get_log_table().
class dummy_tbl_txn;
  static string log_fields[] = {"column1", "column2"};
  virtual function rows_of_log_fields_t get_log_table();
    string s[string] = '{"column1": "value a", "column2": "value b"};
    return {s}; // Return only a single row.
  endfunction
endclass
