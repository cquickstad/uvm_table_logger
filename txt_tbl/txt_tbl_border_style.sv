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

// A set of characters used to draw the table borders.  Pass one to txt_tbl.set_border_style().
// To make a custom style, extend this class (or one of the built-in styles, such as
// txt_tbl_unicode_border_style) and override the functions.
virtual class txt_tbl_border_style;
  pure virtual function string horizontal();
  pure virtual function string vertical();
  pure virtual function string top_left();      // Top rule
  pure virtual function string top();
  pure virtual function string top_right();
  pure virtual function string middle_left();   // Middle rules (e.g. between the header and the rows)
  pure virtual function string middle();
  pure virtual function string middle_right();
  pure virtual function string bottom_left();   // Bottom rule
  pure virtual function string bottom();
  pure virtual function string bottom_right();

  // Header characters.  The top rule and the header lines use header_horizontal() and header_vertical(),
  // and the rule between the header and the rows uses header_horizontal() and header_left(),
  // header_middle() and header_right().  By default the header looks like the rest of the table; override
  // these to give the header its own look.
  virtual function string header_horizontal(); return horizontal();   endfunction
  virtual function string header_vertical();   return vertical();     endfunction
  virtual function string header_left();       return middle_left();  endfunction
  virtual function string header_middle();     return middle();       endfunction
  virtual function string header_right();      return middle_right(); endfunction
endclass
