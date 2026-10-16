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

// Double box-drawing lines
// This style writes UTF-8 box-drawing characters, so the output must be viewed with a UTF-8 capable
// viewer/terminal.  The characters are written as octal escapes of their UTF-8 encodings (rather than as
// literal UTF-8 characters or \x hex escapes) for maximum simulator compatibility.  The trailing comments
// show the characters that the escapes produce.
class txt_tbl_unicode_double_border_style extends txt_tbl_border_style;
  virtual function string horizontal();   return "\342\225\220"; endfunction  // ═
  virtual function string vertical();     return "\342\225\221"; endfunction  // ║
  virtual function string top_left();     return "\342\225\224"; endfunction  // ╔
  virtual function string top();          return "\342\225\246"; endfunction  // ╦
  virtual function string top_right();    return "\342\225\227"; endfunction  // ╗
  virtual function string middle_left();  return "\342\225\240"; endfunction  // ╠
  virtual function string middle();       return "\342\225\254"; endfunction  // ╬
  virtual function string middle_right(); return "\342\225\243"; endfunction  // ╣
  virtual function string bottom_left();  return "\342\225\232"; endfunction  // ╚
  virtual function string bottom();       return "\342\225\251"; endfunction  // ╩
  virtual function string bottom_right(); return "\342\225\235"; endfunction  // ╝
endclass
