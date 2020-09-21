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


class my_monitor extends uvm_monitor;

  virtual my_interface vif;

  uvm_analysis_port #(my_item) ap;

  string ifc;

  `uvm_component_utils_begin(my_monitor)
    `uvm_field_string(ifc, UVM_ALL_ON)
  `uvm_component_utils_end

  function new(string name="my_monitor", uvm_component parent=null);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (!uvm_config_db#(virtual my_interface)::get(this, "", "vif", vif)) begin
      `uvm_fatal("MY_MONITOR_VIF", "Could not get my_interface 'ifc' from uvm_config_db")
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    fork monitor_thread(); join_none
  endtask

  protected virtual task monitor_thread();
    forever begin
      my_item txn;
      @(vif.cb);
      if (vif.cb.reset_n !== 1'b1) continue;
      if (vif.cb.valid !== 1'b1) continue;
      txn = my_item::type_id::create("txn", this);
      txn.ifc = ifc;
      txn.a = vif.cb.a;
      txn.b = vif.cb.b;
      ap.write(txn);
    end
  endtask

endclass

