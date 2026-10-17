`ifndef __TABLE_LOGGER_PKG_SV__
`define __TABLE_LOGGER_PKG_SV__

`include "txt_tbl_pkg.sv"

package table_logger_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import txt_tbl_pkg::*;

  `include "enum_width_finder.svh"
  `include "table_logger_cfg.svh"
  `include "table_logger_types.svh"
  `include "dummy_tbl_txn.svh"
  `include "table_logger.svh"

endpackage

`endif
