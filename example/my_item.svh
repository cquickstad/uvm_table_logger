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


// In this example, transaction reported from the monitor is inherited code
// without the fields required by table_logger.  We will add those fields
// in my_table_item.
class my_item extends uvm_sequence_item;

  string ifc;
  rand reg [31:0] a;
  rand reg [31:0] b;
  rand my_enum_t c;

  `uvm_object_utils_begin(my_item)
    `uvm_field_string(ifc, UVM_ALL_ON)
    `uvm_field_int(a, UVM_ALL_ON)
    `uvm_field_int(b, UVM_ALL_ON)
    `uvm_field_enum(my_enum_t, c, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name="my_item");
    super.new(name);
  endfunction

endclass
