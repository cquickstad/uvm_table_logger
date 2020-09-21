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

module top;

  import uvm_pkg::*;
  import my_pkg::*;

  reg reset_n, clk;

  my_interface ifc_x(.*);
  my_interface ifc_y(.*);

  initial begin : ifc_uvm_cfg_db
    uvm_config_db#(virtual my_interface)::set(null, "*agt_x*", "vif", ifc_x);
    uvm_config_db#(virtual my_interface)::set(null, "*agt_y*", "vif", ifc_y);
  end

  initial run_test(); // The UVM test is selected from the command line with +UVM_TESTNAME=my_test

  initial begin : drive_reset
    automatic int t_rst_x_ns, t_rst_on_clks;
    t_rst_x_ns = $urandom_range(100, 300);
    t_rst_on_clks = $urandom_range(3, 20);

    reset_n = 'X;
    #(t_rst_x_ns * 1ns);
    reset_n = '0;
    repeat (t_rst_on_clks) @(posedge clk);
    reset_n = '1;
  end

  initial begin : drive_clock
    automatic int t_clk_x_ns;
    t_clk_x_ns = $urandom_range(100, 300);

    clk = 'X;
    #(t_clk_x_ns * 1ns);
    clk = '0;
    forever #100ns clk = ~clk;
  end

endmodule
