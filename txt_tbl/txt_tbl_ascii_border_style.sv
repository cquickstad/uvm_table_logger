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

// '+', '-', and '|' (txt_tbl's default)
class txt_tbl_ascii_border_style extends txt_tbl_border_style;
  virtual function string horizontal();   return "-"; endfunction
  virtual function string vertical();     return "|"; endfunction
  virtual function string top_left();     return "+"; endfunction
  virtual function string top();          return "+"; endfunction
  virtual function string top_right();    return "+"; endfunction
  virtual function string middle_left();  return "+"; endfunction
  virtual function string middle();       return "+"; endfunction
  virtual function string middle_right(); return "+"; endfunction
  virtual function string bottom_left();  return "+"; endfunction
  virtual function string bottom();       return "+"; endfunction
  virtual function string bottom_right(); return "+"; endfunction
endclass
