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

class my_driver extends uvm_driver #(my_item);

  virtual my_interface vif;

  `uvm_component_utils(my_driver)

  function new(string name="my_driver", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (!uvm_config_db#(virtual my_interface)::get(this, "", "vif", vif)) begin
      `uvm_fatal("MY_DRIVER_VIF", "Could not get my_interface 'vif' from uvm_config_db")
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    fork drive_task(); join_none
  endtask

  protected virtual task drive_task();
    forever drive_loop();
  endtask

  protected virtual task drive_loop();
    @(vif.cb);
    if (vif.cb.reset_n !== 1'b1) begin
      drive_nothing();
    end else begin
      seq_item_port.try_next_item(req);
      if (req == null) begin
        drive_nothing();
      end else begin
        drive_item();
      end
    end
  endtask

  protected virtual task drive_item();
    vif.cb.valid <= '1;
    vif.cb.a <= req.a;
    vif.cb.b <= req.b;
    seq_item_port.item_done();
  endtask

  protected virtual task drive_nothing();
    vif.cb.valid <= '0;
    vif.cb.a <= 'X;
    vif.cb.b <= 'X;
  endtask

endclass
