// -------------------------------------------------------------
//    Copyright 2026 Chad Quickstad
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

// This code is available from https://github.com/cquickstad/txt_tbl

`ifndef __TXT_TBL_PKG_SV__
`define __TXT_TBL_PKG_SV__

package txt_tbl_pkg;

  `include "column_info.sv"
  `include "txt_tbl_border_style.sv"
  `include "txt_tbl_ascii_border_style.sv"
  `include "txt_tbl_unicode_border_style.sv"
  `include "txt_tbl_unicode_heavy_border_style.sv"
  `include "txt_tbl_unicode_double_border_style.sv"
  `include "txt_tbl_unicode_double_header_border_style.sv"
  `include "txt_tbl.sv"

endpackage

`endif
