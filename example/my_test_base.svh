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


class my_test_base extends uvm_test;

  my_env env;
  my_vseq_base vseq;

  `uvm_component_utils(my_test_base)

  function new(string name="my_test_base", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = my_env::type_id::create("env", this);
  endfunction

  virtual function void init_vseq(my_vseq_base vseq);
    vseq.sqr_x = env.agt_x.sqr;
    vseq.sqr_y = env.agt_y.sqr;
  endfunction

endclass

