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


class rand_test extends my_test_base;

  rand int num_seq;
  constraint num_seq_c { num_seq inside {[5:30]}; }

  `uvm_component_utils(rand_test)

  function new(string name="rand_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    `uvm_info(get_name(), "Starting test", UVM_LOW)

    if (!this.randomize()) `uvm_fatal("TEST_RAND", "Failed to randomize rand_test")

    repeat (num_seq) begin
      vseq = rand_vseq::type_id::create("seq");
      init_vseq(vseq);
      if (!vseq.randomize()) `uvm_fatal("SEQ_RAND", "Failed to randomize rand_vseq")
      vseq.start(null);
    end

    `uvm_info(get_name(), "End of test", UVM_LOW)
    phase.drop_objection(this);
  endtask

endclass

