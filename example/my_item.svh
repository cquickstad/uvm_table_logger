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

  `uvm_object_utils(my_item)

  function new(string name="my_item");
    super.new(name);
  endfunction

endclass
