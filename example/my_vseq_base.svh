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

class my_vseq_base extends uvm_sequence;

  my_sequencer sqr_x, sqr_y;

  `uvm_object_utils(my_vseq_base)

  function new(string name="my_vseq_base");
    super.new(name);
  endfunction

  virtual task start_on_sqr(my_sequence_base s);
    if (s.ifc == IFC_X) s.start(sqr_x);
    if (s.ifc == IFC_Y) s.start(sqr_y);
  endtask

endclass

