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


class random_seq extends my_sequence_base;

  rand int unsigned delay_ns;
  constraint delay_ns_c { delay_ns < 500; }

  `uvm_object_utils(random_seq)

  function new(string name="random_seq");
    super.new(name);
  endfunction

  virtual task body();
    #(delay_ns * 1ns);
    req = my_item::type_id::create("req");
    start_item(req);
    if (!req.randomize()) `uvm_fatal("ITEM_RAND", "Failed to randomize my_item.")
    finish_item(req);
  endtask


endclass

