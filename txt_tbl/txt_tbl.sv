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

class txt_tbl;
  string left_border_char               = "|";
  string right_border_char              = "|";
  string vertical_border_char           = "|";
  string horizontal_border_char         = "-";
  string left_intersection_char         = "+"; // Middle rules
  string right_intersection_char        = "+";
  string intersection_char              = "+";
  string top_left_intersection_char     = "+";
  string top_right_intersection_char    = "+";
  string top_intersection_char          = "+";
  string bottom_left_intersection_char  = "+";
  string bottom_right_intersection_char = "+";
  string bottom_intersection_char       = "+";
  // Header characters.  An empty header character uses the matching character above.
  string header_left_border_char        = ""; // Header lines
  string header_right_border_char       = "";
  string header_vertical_border_char    = "";
  string header_horizontal_border_char  = ""; // Top rule and header rule
  string header_left_intersection_char  = ""; // Header rule (between the header and the rows)
  string header_right_intersection_char = "";
  string header_intersection_char       = "";
  string boundary_pad_char              = " ";
  string pad_char                       = " ";


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
  endfunction

  virtual function string get_header();
    get_header = "";
    for (int j = 0; j < num_header_rows; j++) begin
      if (j > 0) get_header = {get_header, "\n"};
      get_header = {get_header, or_default(header_left_border_char, left_border_char)};
      foreach (columns[i]) begin
        get_header = {get_header, get_wrapped_column_title(i, j)};
      end
    end
  endfunction

  // Returns a middle horizontal rule.
  // Same as get_border_middle(); kept for backward compatibility.
  virtual function string get_border();
    return get_border_middle();
  endfunction

  // Returns the horizontal rule for the top of the table.
  virtual function string get_border_top();
    return get_border_with(or_default(header_horizontal_border_char, horizontal_border_char),
                           top_left_intersection_char, top_intersection_char, top_right_intersection_char);
  endfunction

  // Returns the horizontal rule between the header and the rows.
  virtual function string get_border_header();
    return get_border_with(or_default(header_horizontal_border_char,  horizontal_border_char),
                           or_default(header_left_intersection_char,  left_intersection_char),
                           or_default(header_intersection_char,       intersection_char),
                           or_default(header_right_intersection_char, right_intersection_char));
  endfunction

  // Returns a horizontal rule for within the rows of the table.
  virtual function string get_border_middle();
    return get_border_with(horizontal_border_char,
                           left_intersection_char, intersection_char, right_intersection_char);
  endfunction

  // Returns the horizontal rule for the bottom of the table.
  virtual function string get_border_bottom();
    return get_border_with(horizontal_border_char,
                           bottom_left_intersection_char, bottom_intersection_char,
                           bottom_right_intersection_char);
  endfunction

  // Sets all of the border characters from the given style, for example:
  //   txt_tbl_unicode_border_style style = new();
  //   tbl.set_border_style(style);
  // The characters are copied, so individual characters can still be changed afterwards.
  // A null style leaves the border characters unchanged.
  virtual function void set_border_style(txt_tbl_border_style style);
    if (style == null) return;
    set_border_chars(style.horizontal(), style.vertical(),
                     style.top_left(), style.top(), style.top_right(),
                     style.middle_left(), style.middle(), style.middle_right(),
                     style.bottom_left(), style.bottom(), style.bottom_right());
    set_header_border_chars(style.header_horizontal(), style.header_vertical(),
                            style.header_left(), style.header_middle(), style.header_right());
  endfunction

  // Sets all of the border characters, except for the padding characters.
  // The header uses the same characters as the rest of the table (see set_header_border_chars()).
  virtual function void set_border_chars(string horizontal, string vertical,
                                         string top_left, string top, string top_right,
                                         string mid_left, string mid, string mid_right,
                                         string bottom_left, string bottom, string bottom_right);
    horizontal_border_char         = horizontal;
    left_border_char               = vertical;
    right_border_char              = vertical;
    vertical_border_char           = vertical;
    top_left_intersection_char     = top_left;
    top_intersection_char          = top;
    top_right_intersection_char    = top_right;
    left_intersection_char         = mid_left;
    intersection_char              = mid;
    right_intersection_char        = mid_right;
    bottom_left_intersection_char  = bottom_left;
    bottom_intersection_char       = bottom;
    bottom_right_intersection_char = bottom_right;
    set_header_border_chars("", "", "", "", "");
  endfunction

  // Sets the border characters of the header lines, the top rule and the header rule.  An empty string
  // uses the matching character of the rest of the table.  The corners of the top rule are set by
  // set_border_chars().
  virtual function void set_header_border_chars(string horizontal, string vertical,
                                                string left, string mid, string right);
    header_horizontal_border_char  = horizontal;
    header_left_border_char        = vertical;
    header_right_border_char       = vertical;
    header_vertical_border_char    = vertical;
    header_left_intersection_char  = left;
    header_intersection_char       = mid;
    header_right_intersection_char = right;
  endfunction

  virtual function string get_row(string column_fields[$]);
    int   num_cols = max(column_fields.size(), columns.size());
    get_row = left_border_char;

    for (int i = 0; i < num_cols; i++) begin
      string f = (i < column_fields.size()) ? column_fields[i] : "";
      if (i >= columns.size()) add_column("?");
      get_row = {get_row, get_wrapped_column_field(i, f)};
    end
  endfunction

  static function int max(int a, int b);
    return (a > b) ? a : b;
  endfunction

  // Returns 'c', or 'default_c' if 'c' is empty.
  static function string or_default(string c, string default_c);
    return (c == "") ? default_c : c;
  endfunction

  protected virtual function bit is_last_column(int col_idx);
    return col_idx >= (columns.size() - 1);
  endfunction

  protected virtual function string get_wrapped_column_txt(int col_idx, string txt,
                                                         string vertical_char, string right_char);
    string end_char = is_last_column(col_idx) ? right_char : vertical_char;
    return {boundary_pad_char, txt, boundary_pad_char, end_char};
  endfunction

  protected virtual function string get_wrapped_column_title(int col_idx, int title_row_idx);
    string hdr_line = columns[col_idx].title_lines[title_row_idx];
    hdr_line = get_resized_justified_txt(col_idx, hdr_line, columns[col_idx].left_justify_title);
    return get_wrapped_column_txt(col_idx, hdr_line,
                                  or_default(header_vertical_border_char, vertical_border_char),
                                  or_default(header_right_border_char,    right_border_char));
  endfunction

  // Returns a horizontal rule of 'horizontal_char' that starts with 'left_char', has 'inner_char' between
  // columns, and ends with 'right_char'.
  protected virtual function string get_border_with(string horizontal_char,
                                                    string left_char, string inner_char, string right_char);
    get_border_with = left_char;
    foreach (columns[i]) begin
      get_border_with = {get_border_with,
                         get_wrapped_column_border(i, horizontal_char, inner_char, right_char)};
    end
  endfunction

  protected virtual function string get_wrapped_column_border(int col_idx, string horizontal_char,
                                                              string inner_char, string right_char);
    string end_char = is_last_column(col_idx) ? right_char : inner_char;
    return {horizontal_char, get_horizontal_col_border(get_column_width(col_idx, 0), horizontal_char),
            horizontal_char, end_char};
  endfunction

  protected virtual function string get_wrapped_column_field(int col_idx, string field);
    string f = get_resized_justified_txt(col_idx, field, columns[col_idx].left_justify_field);
    return get_wrapped_column_txt(col_idx, f, vertical_border_char, right_border_char);
  endfunction

  protected virtual function string get_horizontal_col_border(int size, string horizontal_char);
    return {size{horizontal_char}}; // repeat 'horizontal_char' 'size' times
  endfunction

  protected virtual function string get_resized_justified_txt(int col_idx, string txt, bit left_justify=0);
    int     width     = get_column_width(col_idx, txt.len());
    int     pad_width = width - txt.len();
    string  pad       = pad_width > 0 ? {pad_width{pad_char}} : "";

    get_resized_justified_txt = {left_justify ? "" : pad,
                                 txt,
                                 left_justify ? pad : ""};
  endfunction

  protected virtual function int get_column_width(int col_idx, int txt_len_to_fit);
    return columns[col_idx].get_width(txt_len_to_fit);
  endfunction

  protected virtual function void adjust_all_column_header_rows();
    foreach (columns[i]) columns[i].prepend_blank_title_lines(num_header_rows);
  endfunction

endclass
