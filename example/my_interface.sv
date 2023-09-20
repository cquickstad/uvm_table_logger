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

`ifndef __INTERFACE_SV__
`define __INTERFACE_SV__


interface my_interface(input reset_n, input clk);

  wire valid;
  wire [31:0] a, b;
  wire [1:0] c;

  clocking cb @(posedge clk);
    default input #1step output #0;
    input reset_n;
    inout valid;
    inout a;
    inout b;
    inout c;
  endclocking

endinterface


`endif
