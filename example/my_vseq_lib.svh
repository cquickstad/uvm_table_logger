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

class rand_vseq extends my_vseq_base;

  rand int unsigned delay;
  constraint delay_c { delay < 100; }

  `uvm_object_utils(rand_vseq)

  function new(string name="rand_vseq");
    super.new(name);
  endfunction

  virtual task body();
    random_seq s = random_seq::type_id::create("s");
    #(delay * 1ns);
    if (!s.randomize()) `uvm_fatal("SEQ_RAND", "Failed to randomize random_seq.")
    start_on_sqr(s);
  endtask

endclass
