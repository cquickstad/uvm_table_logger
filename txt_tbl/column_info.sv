// -------------------------------------------------------------
//    Copyright 2017 Chad Quickstad
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

class column_info;

  string  title_lines[$];
  bit     left_justify_title;
  bit     left_justify_field;
  bit     sticky_width_growth;
  protected int width;

  function new(string title, int width, bit left_justify_title=1, bit left_justify_field, bit sticky_width_growth);
    title_lines = line_to_q_helper(title);
    set_width_to_largest_line();
    this.width = max(width, this.width);
    this.left_justify_title = left_justify_title;
    this.left_justify_field = left_justify_field;
    this.sticky_width_growth = sticky_width_growth;
  endfunction

  virtual function void prepend_blank_title_lines(int num_rows);
    while (title_lines.size() < num_rows) title_lines.push_front("");
  endfunction

  virtual function int get_width(int txt_len_to_fit);
    if (sticky_width_growth && txt_len_to_fit > width) width = txt_len_to_fit;
    return width;
  endfunction

  typedef string str_q[$]; // SystemVerilog doesn't allow returning a queue without this trick
  static function str_q line_to_q_helper(string line);
    int substr_start = 0;
    foreach (line[i]) begin
      if (line[i] == "\n") begin
        line_to_q_helper.push_back(line.substr(substr_start, i - 1));
        substr_start = i + 1;
      end
    end
    line_to_q_helper.push_back(line.substr(substr_start, line.len() - 1));
  endfunction

  static function int max(int a, int b);
    return (a > b) ? a : b;
  endfunction

  protected virtual function void set_width_to_largest_line();
    width = 0;
    foreach (title_lines[i]) width = max(width, title_lines[i].len());
  endfunction

endclass
