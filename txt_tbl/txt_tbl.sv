// -------------------------------------------------------------
//    Copyright 2017 XtremeEDA
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
  endfunction : new

  virtual function void prepend_blank_title_lines(int num_rows);
    while (title_lines.size() < num_rows) title_lines.push_front("");
  endfunction : prepend_blank_title_lines

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
  endfunction : line_to_q_helper

  static function int max(int a, int b);
    return (a > b) ? a : b;
  endfunction : max

  protected virtual function void set_width_to_largest_line();
    width = 0;
    foreach (title_lines[i]) width = max(width, title_lines[i].len());
  endfunction : set_width_to_largest_line
endclass : column_info



class txt_tbl;
  string left_border_char         = "|";
  string right_border_char        = "|";
  string vertical_border_char     = "|";
  string horizontal_border_char   = "-";
  string left_intersection_char   = "+";
  string right_intersection_char  = "+";
  string intersection_char        = "+";
  string boundry_pad_char         = " ";
  string pad_char                 = " ";


  // The column titles are store in a two dimensional queue to allow for
  // multi-line column titles.
  protected column_info   columns[$];
  protected int           num_header_rows = 0;

  virtual function void add_column(string column_title, int width=0,
                                   bit left_justify_title=1, bit left_justify_field=0,
                                   bit sticky_width_growth=1);
    column_info   ci = new(column_title, width, left_justify_title, left_justify_field, sticky_width_growth);
    columns.push_back(ci);
    num_header_rows = max(num_header_rows, ci.title_lines.size());
    adjust_all_column_header_rows();
  endfunction : add_column

  virtual function string get_header();
    get_header = "";
    for (int j = 0; j < num_header_rows; j++) begin
      if (j > 0) get_header = {get_header, "\n"};
      get_header = {get_header, left_border_char};
      foreach (columns[i]) begin
        get_header = {get_header, get_wrapped_column_title(i, j)};
      end
    end
  endfunction : get_header

  virtual function string get_border();
    get_border = left_intersection_char;
    foreach (columns[i]) get_border = {get_border, get_wrapped_column_border(i)};
  endfunction : get_border

  virtual function string get_row(string column_fields[$]);
    int   num_cols = max(column_fields.size(), columns.size());
    get_row = left_border_char;

    for (int i = 0; i < num_cols; i++) begin
      string f = (i < column_fields.size()) ? column_fields[i] : "";
      if (i >= columns.size()) add_column("?");
      get_row = {get_row, get_wrapped_column_field(i, f)};
    end
  endfunction : get_row

  static function int max(int a, int b);
    return (a > b) ? a : b;
  endfunction : max

  protected virtual function bit is_last_column(int col_idx);
    return col_idx >= (columns.size() - 1);
  endfunction : is_last_column

  protected virtual function string get_wrapped_column_txt(int col_idx, string txt);
    string end_char = is_last_column(col_idx) ? right_border_char : vertical_border_char;
    return {boundry_pad_char, txt, boundry_pad_char, end_char};
  endfunction : get_wrapped_column_txt

  protected virtual function string get_wrapped_column_title(int col_idx, int title_row_idx);
    string hdr_line = columns[col_idx].title_lines[title_row_idx];
    hdr_line = get_resized_justified_txt(col_idx, hdr_line, columns[col_idx].left_justify_title);
    return get_wrapped_column_txt(col_idx, hdr_line);
  endfunction : get_wrapped_column_title

  protected virtual function string get_wrapped_column_border(int col_idx);
    string end_char = is_last_column(col_idx) ? right_intersection_char : intersection_char;
    return {horizontal_border_char, get_horizontal_col_border(get_column_width(col_idx, 0)),
            horizontal_border_char, end_char};
  endfunction : get_wrapped_column_border

  protected virtual function string get_wrapped_column_field(int col_idx, string field);
    string f = get_resized_justified_txt(col_idx, field, columns[col_idx].left_justify_field);
    return get_wrapped_column_txt(col_idx, f);
  endfunction : get_wrapped_column_field

  protected virtual function string get_horizontal_col_border(int size);
    return {size{horizontal_border_char}}; // repeat 'horizontal_border_char' 'size' times
  endfunction : get_horizontal_col_border

  protected virtual function string get_resized_justified_txt(int col_idx, string txt, bit left_justify=0);
    int     width     = get_column_width(col_idx, txt.len());
    int     pad_width = width - txt.len();
    string  pad       = pad_width > 0 ? {pad_width{pad_char}} : "";

    get_resized_justified_txt = {left_justify ? "" : pad,
                                 txt,
                                 left_justify ? pad : ""};
  endfunction : get_resized_justified_txt

  protected virtual function int get_column_width(int col_idx, int txt_len_to_fit);
    return columns[col_idx].get_width(txt_len_to_fit);
  endfunction : get_column_width

  protected virtual function void adjust_all_column_header_rows();
    foreach (columns[i]) columns[i].prepend_blank_title_lines(num_header_rows);
  endfunction : adjust_all_column_header_rows
endclass : txt_tbl
