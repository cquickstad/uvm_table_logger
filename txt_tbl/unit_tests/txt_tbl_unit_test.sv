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

// Uses uvm_unit's sv_test unit-test framework:
// https://github.com/cquickstad/uvm_unit/

`include "sv_test.svh"
import sv_test_pkg::*;


`include "txt_tbl_pkg.sv"
import txt_tbl_pkg::*;


`SV_TEST(txt_tbl_line_to_q_helper_test)
  string q[$];

  q = column_info::line_to_q_helper("1");
  `ASSERT_EQ(q.size(), 1)
  if (q.size() == 1) `ASSERT_STR_EQ(q[0], "1")

  q = column_info::line_to_q_helper("aaa\nb\ncc");
  `ASSERT_EQ(q.size(), 3)
  if (q.size() >= 1) `ASSERT_STR_EQ(q[0], "aaa")
  if (q.size() >= 2) `ASSERT_STR_EQ(q[1],   "b")
  if (q.size() >= 3) `ASSERT_STR_EQ(q[2],  "cc")

  q = column_info::line_to_q_helper("z\n");
  `ASSERT_EQ(q.size(), 2)
  if (q.size() >= 1) `ASSERT_STR_EQ(q[0], "z")
  if (q.size() >= 2) `ASSERT_STR_EQ(q[1],  "")

  q = column_info::line_to_q_helper("\ny");
  `ASSERT_EQ(q.size(), 2)
  if (q.size() >= 1) `ASSERT_STR_EQ(q[0],  "")
  if (q.size() >= 2) `ASSERT_STR_EQ(q[1], "y")
`END_SV_TEST


class txt_tbl_fxtr extends sv_test_fixture;
    txt_tbl   cut;

    function new(unit_test_pkg::unit_test_runner tr);
        super.new(tr);
    endfunction

    virtual task setup();
        cut = new();
    endtask
endclass


`SV_TEST_F(txt_tbl_fxtr, empty_txt_tbl)
  `ASSERT_STR_EQ(cut.get_header(), "")
  `ASSERT_STR_EQ(cut.get_border(), "+")
  `ASSERT_STR_EQ(cut.get_row({}), "|")
`END_SV_TEST

`SV_TEST_F(txt_tbl_fxtr, txt_tbl_one_column)
  cut.add_column("My Column");
  `ASSERT_STR_EQ(cut.get_header(),        "| My Column |")
  `ASSERT_STR_EQ(cut.get_border(),        "+-----------+")
  `ASSERT_STR_EQ(cut.get_row({"data 1"}), "|    data 1 |")
`END_SV_TEST

`SV_TEST_F(txt_tbl_fxtr, txt_tbl_miltiple_columns)
  cut.add_column("My Column");
  cut.add_column("My 2nd Column");
  cut.add_column("The best column yet!");
  `ASSERT_STR_EQ(cut.get_header(),        "| My Column | My 2nd Column | The best column yet! |")
  `ASSERT_STR_EQ(cut.get_border(),        "+-----------+---------------+----------------------+")
  `ASSERT_STR_EQ(cut.get_row({"data 1",
                             "2", "d3"}), "|    data 1 |             2 |                   d3 |")
`END_SV_TEST

`SV_TEST_F(txt_tbl_fxtr, txt_tbl_multiple_line_header)
  cut.add_column("My\nFirst\nColumn");
  cut.add_column("My\nColumn");
  cut.add_column("col");
  `ASSERT_STR_EQ(cut.get_header(),        {  "| My     |        |     |",
                                           "\n| First  | My     |     |",
                                           "\n| Column | Column | col |"})
  `ASSERT_STR_EQ(cut.get_border(),           "+--------+--------+-----+")
  `ASSERT_STR_EQ(cut.get_row({"aa",
                              "bb",
                              "cc"}),        "|     aa |     bb |  cc |")
`END_SV_TEST

`SV_TEST_F(txt_tbl_fxtr, txt_tbl_width_and_justification)
  cut.add_column("My\nFirst\nColumn", 8, 0, 1);
  cut.add_column("My\nColumn", 7, 1, 1);
  cut.add_column("col");
  `ASSERT_STR_EQ(cut.get_header(),        {  "|       My |         |     |",
                                           "\n|    First | My      |     |",
                                           "\n|   Column | Column  | col |"})
  `ASSERT_STR_EQ(cut.get_border(),           "+----------+---------+-----+")
  `ASSERT_STR_EQ(cut.get_row({"aa",
                              "bb",
                              "cc"}),        "| aa       | bb      |  cc |")
`END_SV_TEST

`SV_TEST_F(txt_tbl_fxtr, txt_tbl_altered_border_characters)
  cut.left_border_char              = "[";
  cut.right_border_char             = "]";
  cut.vertical_border_char          = "*";
  cut.horizontal_border_char        = "=";
  cut.left_intersection_char        = "/";
  cut.right_intersection_char       = ",";
  cut.intersection_char             = "~";
  cut.boundary_pad_char             = "_";
  cut.pad_char                      = ".";
  cut.add_column("My\nFirst\nColumn", 8, 0, 1);
  cut.add_column("My\nColumn", 7, 1, 1);
  cut.add_column("col");
  `ASSERT_STR_EQ(cut.get_header(),        {  "[_......My_*_......._*_..._]",
                                           "\n[_...First_*_My....._*_..._]",
                                           "\n[_..Column_*_Column._*_col_]"})
  `ASSERT_STR_EQ(cut.get_border(),           "/==========~=========~=====,")
  `ASSERT_STR_EQ(cut.get_row({"aa",
                              "bb",
                              "cc"}),        "[_aa......_*_bb....._*_.cc_]")
`END_SV_TEST

`SV_TEST_F(txt_tbl_fxtr, txt_tbl_sticky_width_growth)
  cut.add_column(.column_title("a"), .sticky_width_growth(1));
  cut.add_column(.column_title("b"), .sticky_width_growth(0));
  cut.add_column(.column_title("c"), .sticky_width_growth(1));
  `ASSERT_STR_EQ(cut.get_header(), "| a | b | c |")
  `ASSERT_STR_EQ(cut.get_border(), "+---+---+---+")
  `ASSERT_STR_EQ(cut.get_row({"1", "2", "3"}), "| 1 | 2 | 3 |")
  `ASSERT_STR_EQ(cut.get_row({"111", "222", "333"}), "| 111 | 222 | 333 |")
  `ASSERT_STR_EQ(cut.get_header(), "| a   | b | c   |")
  `ASSERT_STR_EQ(cut.get_border(), "+-----+---+-----+")
  `ASSERT_STR_EQ(cut.get_row({"1", "2", "3"}), "|   1 | 2 |   3 |")
`END_SV_TEST

`SV_TEST_F(txt_tbl_fxtr, txt_tbl_not_enough_row_fields)
  cut.add_column(.column_title("a"), .sticky_width_growth(1));
  cut.add_column(.column_title("b"), .sticky_width_growth(0));
  cut.add_column(.column_title("c"), .sticky_width_growth(1));
  `ASSERT_STR_EQ(cut.get_row({"1"}), "| 1 |   |   |")
`END_SV_TEST

`SV_TEST_F(txt_tbl_fxtr, txt_tbl_too_many_row_fields)
  cut.add_column(.column_title("a"), .sticky_width_growth(1));
  `ASSERT_STR_EQ(cut.get_row({"1", "2", "3"}), "| 1 | 2 | 3 |")
  `ASSERT_STR_EQ(cut.get_header(), "| a | ? | ? |")
  `ASSERT_STR_EQ(cut.get_border(), "+---+---+---+")
`END_SV_TEST


// ---------------------------------------------------------------------------------------------
// Border style and border position tests
//
// The box-drawing characters are written as octal escapes of their UTF-8 encodings, for simulator
// compatibility.  txt_tbl_unicode_escapes_are_box_drawing_code_points decodes them to check the
// escapes independently of the escapes themselves.
// ---------------------------------------------------------------------------------------------

// Decodes a string holding exactly one 3-byte UTF-8 character into its code point.
// Returns -1 if the string is not exactly one 3-byte UTF-8 character.
function automatic int utf8_code_point(string s);
  if (s.len() != 3) return -1;
  if ((s[0] & 8'hF0) != 8'hE0) return -1;
  if ((s[1] & 8'hC0) != 8'h80) return -1;
  if ((s[2] & 8'hC0) != 8'h80) return -1;
  return ((int'(s[0]) & 'h0F) << 12) | ((int'(s[1]) & 'h3F) << 6) | (int'(s[2]) & 'h3F);
endfunction


// The expected border characters of a style, used to build expected table strings.
class box_glyphs;
  string h, v;          // horizontal, vertical
  string tl, t, tr;     // top-left, top, top-right
  string ml, m, mr;     // middle-left, middle, middle-right
  string bl, b, br;     // bottom-left, bottom, bottom-right

  function new(string h, string v,
               string tl, string t, string tr,
               string ml, string m, string mr,
               string bl, string b, string br);
    this.h  = h;  this.v = v;
    this.tl = tl; this.t = t; this.tr = tr;
    this.ml = ml; this.m = m; this.mr = mr;
    this.bl = bl; this.b = b; this.br = br;
  endfunction

endclass


class txt_tbl_border_fxtr extends txt_tbl_fxtr;
  txt_tbl_ascii_border_style          ascii;
  txt_tbl_unicode_border_style        unicode;
  txt_tbl_unicode_heavy_border_style  heavy;
  txt_tbl_unicode_double_border_style dbl;

  // The expected characters of each style
  box_glyphs ascii_g, unicode_g, heavy_g, double_g;

  // All of the styles above, with their expected characters at the same index.
  txt_tbl_border_style all_styles[$];
  box_glyphs           all_glyphs[$];

  function new(unit_test_pkg::unit_test_runner tr);
    super.new(tr);
  endfunction

  virtual task setup();
    super.setup();
    ascii   = new();
    unicode = new();
    heavy   = new();
    dbl     = new();
    ascii_g   = new("-", "|", "+", "+", "+", "+", "+", "+", "+", "+", "+");
    unicode_g = new("\342\224\200", "\342\224\202",
                    "\342\224\214", "\342\224\254", "\342\224\220",
                    "\342\224\234", "\342\224\274", "\342\224\244",
                    "\342\224\224", "\342\224\264", "\342\224\230");
    heavy_g   = new("\342\224\201", "\342\224\203",
                    "\342\224\217", "\342\224\263", "\342\224\223",
                    "\342\224\243", "\342\225\213", "\342\224\253",
                    "\342\224\227", "\342\224\273", "\342\224\233");
    double_g  = new("\342\225\220", "\342\225\221",
                    "\342\225\224", "\342\225\246", "\342\225\227",
                    "\342\225\240", "\342\225\254", "\342\225\243",
                    "\342\225\232", "\342\225\251", "\342\225\235");
    all_styles = '{ascii,   unicode,   heavy,   dbl};
    all_glyphs = '{ascii_g, unicode_g, heavy_g, double_g};
  endtask

  // Checks every border character member of 'tbl' against 'g'.
  virtual function void check_border_chars(txt_tbl tbl, box_glyphs g);
    `ASSERT_STR_EQ(tbl.horizontal_border_char,         g.h)
    `ASSERT_STR_EQ(tbl.left_border_char,               g.v)
    `ASSERT_STR_EQ(tbl.vertical_border_char,           g.v)
    `ASSERT_STR_EQ(tbl.right_border_char,              g.v)
    `ASSERT_STR_EQ(tbl.top_left_intersection_char,     g.tl)
    `ASSERT_STR_EQ(tbl.top_intersection_char,          g.t)
    `ASSERT_STR_EQ(tbl.top_right_intersection_char,    g.tr)
    `ASSERT_STR_EQ(tbl.left_intersection_char,         g.ml)
    `ASSERT_STR_EQ(tbl.intersection_char,              g.m)
    `ASSERT_STR_EQ(tbl.right_intersection_char,        g.mr)
    `ASSERT_STR_EQ(tbl.bottom_left_intersection_char,  g.bl)
    `ASSERT_STR_EQ(tbl.bottom_intersection_char,       g.b)
    `ASSERT_STR_EQ(tbl.bottom_right_intersection_char, g.br)
  endfunction

  // Checks the code point of every border character member of 'tbl'.
  virtual function void check_code_points(txt_tbl tbl, int h, int v,
                                          int tl, int t, int tr,
                                          int ml, int m, int mr,
                                          int bl, int b, int br);
    `ASSERT_EQ(utf8_code_point(tbl.horizontal_border_char),         h)
    `ASSERT_EQ(utf8_code_point(tbl.left_border_char),               v)
    `ASSERT_EQ(utf8_code_point(tbl.vertical_border_char),           v)
    `ASSERT_EQ(utf8_code_point(tbl.right_border_char),              v)
    `ASSERT_EQ(utf8_code_point(tbl.top_left_intersection_char),     tl)
    `ASSERT_EQ(utf8_code_point(tbl.top_intersection_char),          t)
    `ASSERT_EQ(utf8_code_point(tbl.top_right_intersection_char),    tr)
    `ASSERT_EQ(utf8_code_point(tbl.left_intersection_char),         ml)
    `ASSERT_EQ(utf8_code_point(tbl.intersection_char),              m)
    `ASSERT_EQ(utf8_code_point(tbl.right_intersection_char),        mr)
    `ASSERT_EQ(utf8_code_point(tbl.bottom_left_intersection_char),  bl)
    `ASSERT_EQ(utf8_code_point(tbl.bottom_intersection_char),       b)
    `ASSERT_EQ(utf8_code_point(tbl.bottom_right_intersection_char), br)
  endfunction

  // Checks a complete table with three columns (first, inner, and last) and a two-line header.
  virtual function void check_full_table(txt_tbl_border_style style, box_glyphs g);
    txt_tbl tbl = new();
    tbl.set_border_style(style);
    tbl.add_column("a");
    tbl.add_column("bb\nb");
    tbl.add_column("c");
    `ASSERT_STR_EQ(tbl.get_border_top(),
                   {g.tl, {3{g.h}}, g.t, {4{g.h}}, g.t, {3{g.h}}, g.tr})
    `ASSERT_STR_EQ(tbl.get_header(),
                   {  g.v, "   ", g.v, " bb ", g.v, "   ", g.v,
                    "\n", g.v, " a ", g.v, " b  ", g.v, " c ", g.v})
    `ASSERT_STR_EQ(tbl.get_border_middle(),
                   {g.ml, {3{g.h}}, g.m, {4{g.h}}, g.m, {3{g.h}}, g.mr})
    `ASSERT_STR_EQ(tbl.get_row({"1", "2", "3"}),
                   {g.v, " 1 ", g.v, "  2 ", g.v, " 3 ", g.v})
    `ASSERT_STR_EQ(tbl.get_border_bottom(),
                   {g.bl, {3{g.h}}, g.b, {4{g.h}}, g.b, {3{g.h}}, g.br})
  endfunction
endclass


`SV_TEST_F(txt_tbl_border_fxtr, txt_tbl_default_border_style_is_ascii)
  check_border_chars(cut, ascii_g);
  cut.add_column("a");
  cut.add_column("b");
  `ASSERT_STR_EQ(cut.get_border_top(),    "+---+---+")
  `ASSERT_STR_EQ(cut.get_border_middle(), "+---+---+")
  `ASSERT_STR_EQ(cut.get_border_bottom(), "+---+---+")
  `ASSERT_STR_EQ(cut.get_row({"1", "2"}),               "| 1 | 2 |")
`END_SV_TEST

`SV_TEST_F(txt_tbl_border_fxtr, txt_tbl_unicode_escapes_are_box_drawing_code_points)
  cut.set_border_style(unicode);
  check_code_points(cut, 'h2500, 'h2502,
                         'h250C, 'h252C, 'h2510,
                         'h251C, 'h253C, 'h2524,
                         'h2514, 'h2534, 'h2518);
  cut.set_border_style(heavy);
  check_code_points(cut, 'h2501, 'h2503,
                         'h250F, 'h2533, 'h2513,
                         'h2523, 'h254B, 'h252B,
                         'h2517, 'h253B, 'h251B);
  cut.set_border_style(dbl);
  check_code_points(cut, 'h2550, 'h2551,
                         'h2554, 'h2566, 'h2557,
                         'h2560, 'h256C, 'h2563,
                         'h255A, 'h2569, 'h255D);
`END_SV_TEST

`SV_TEST_F(txt_tbl_border_fxtr, txt_tbl_set_border_style_sets_all_border_chars)
  foreach (all_styles[i]) begin
    cut.set_border_style(all_styles[i]);
    check_border_chars(cut, all_glyphs[i]);
  end
`END_SV_TEST

`SV_TEST_F(txt_tbl_border_fxtr, txt_tbl_ascii_full_table)
  check_full_table(ascii, ascii_g);
`END_SV_TEST

`SV_TEST_F(txt_tbl_border_fxtr, txt_tbl_unicode_full_table)
  check_full_table(unicode, unicode_g);
`END_SV_TEST

`SV_TEST_F(txt_tbl_border_fxtr, txt_tbl_unicode_heavy_full_table)
  check_full_table(heavy, heavy_g);
`END_SV_TEST

`SV_TEST_F(txt_tbl_border_fxtr, txt_tbl_unicode_double_full_table)
  check_full_table(dbl, double_g);
`END_SV_TEST

`SV_TEST_F(txt_tbl_border_fxtr, txt_tbl_get_border_is_middle)
  foreach (all_styles[i]) begin
    txt_tbl tbl = new();
    tbl.set_border_style(all_styles[i]);
    tbl.add_column("a");
    tbl.add_column("b");
    `ASSERT_STR_EQ(tbl.get_border(), tbl.get_border_middle())
  end
`END_SV_TEST

`SV_TEST_F(txt_tbl_border_fxtr, txt_tbl_unicode_empty_table)
  box_glyphs g = unicode_g;
  string no_fields[$];
  cut.set_border_style(unicode);
  `ASSERT_STR_EQ(cut.get_border_top(),    g.tl)
  `ASSERT_STR_EQ(cut.get_border_middle(), g.ml)
  `ASSERT_STR_EQ(cut.get_border_bottom(), g.bl)
  `ASSERT_STR_EQ(cut.get_header(), "")
  `ASSERT_STR_EQ(cut.get_row(no_fields), g.v)
`END_SV_TEST

`SV_TEST_F(txt_tbl_border_fxtr, txt_tbl_unicode_single_column_uses_right_corners)
  box_glyphs g = unicode_g;
  cut.set_border_style(unicode);
  cut.add_column("a");
  `ASSERT_STR_EQ(cut.get_border_top(),    {g.tl, {3{g.h}}, g.tr})
  `ASSERT_STR_EQ(cut.get_border_middle(), {g.ml, {3{g.h}}, g.mr})
  `ASSERT_STR_EQ(cut.get_border_bottom(), {g.bl, {3{g.h}}, g.br})
  `ASSERT_STR_EQ(cut.get_header(), {g.v, " a ", g.v})
`END_SV_TEST

`SV_TEST_F(txt_tbl_border_fxtr, txt_tbl_set_border_style_after_columns_added)
  box_glyphs g = double_g;
  cut.add_column("a");
  cut.add_column("b");
  `ASSERT_STR_EQ(cut.get_border_top(), "+---+---+")
  cut.set_border_style(dbl);
  `ASSERT_STR_EQ(cut.get_border_top(), {g.tl, {3{g.h}}, g.t, {3{g.h}}, g.tr})
  `ASSERT_STR_EQ(cut.get_row({"1", "2"}),            {g.v, " 1 ", g.v, " 2 ", g.v})
`END_SV_TEST

`SV_TEST_F(txt_tbl_border_fxtr, txt_tbl_set_border_style_back_to_ascii)
  cut.add_column("a");
  cut.add_column("b");
  cut.set_border_style(heavy);
  cut.set_border_style(ascii);
  check_border_chars(cut, ascii_g);
  `ASSERT_STR_EQ(cut.get_border_top(),    "+---+---+")
  `ASSERT_STR_EQ(cut.get_border_middle(), "+---+---+")
  `ASSERT_STR_EQ(cut.get_border_bottom(), "+---+---+")
  `ASSERT_STR_EQ(cut.get_header(),                      "| a | b |")
`END_SV_TEST

`SV_TEST_F(txt_tbl_border_fxtr, txt_tbl_set_border_style_preserves_pad_chars)
  box_glyphs g = unicode_g;
  cut.boundary_pad_char = "_";
  cut.pad_char         = ".";
  cut.set_border_style(unicode);
  `ASSERT_STR_EQ(cut.boundary_pad_char, "_")
  `ASSERT_STR_EQ(cut.pad_char,         ".")
  cut.add_column("abc");
  `ASSERT_STR_EQ(cut.get_row({"1"}), {g.v, "_..1_", g.v})
`END_SV_TEST

`SV_TEST_F(txt_tbl_border_fxtr, txt_tbl_set_border_chars_maps_each_argument)
  box_glyphs g = new("h", "v", "1", "2", "3", "4", "5", "6", "7", "8", "9");
  cut.set_border_chars("h", "v", "1", "2", "3", "4", "5", "6", "7", "8", "9");
  check_border_chars(cut, g);
  cut.add_column("a");
  cut.add_column("b");
  `ASSERT_STR_EQ(cut.get_border_top(),    "1hhh2hhh3")
  `ASSERT_STR_EQ(cut.get_border_middle(), "4hhh5hhh6")
  `ASSERT_STR_EQ(cut.get_border_bottom(), "7hhh8hhh9")
  `ASSERT_STR_EQ(cut.get_row({"x", "y"}),               "v x v y v")
`END_SV_TEST

`SV_TEST_F(txt_tbl_border_fxtr, txt_tbl_position_specific_intersection_members)
  // Setting the members directly (instead of using set_border_chars()) only affects the matching rule.
  cut.top_left_intersection_char     = "/";
  cut.top_intersection_char          = "v";
  cut.top_right_intersection_char    = "\\";
  cut.bottom_left_intersection_char  = "\\";
  cut.bottom_intersection_char       = "^";
  cut.bottom_right_intersection_char = "/";
  cut.add_column("a");
  cut.add_column("b");
  `ASSERT_STR_EQ(cut.get_border_top(),    "/---v---\\")
  `ASSERT_STR_EQ(cut.get_border_middle(), "+---+---+")
  `ASSERT_STR_EQ(cut.get_border_bottom(), "\\---^---/")
  // The legacy (middle) members do not affect the top and bottom rules.
  cut.left_intersection_char  = "[";
  cut.intersection_char       = "|";
  cut.right_intersection_char = "]";
  `ASSERT_STR_EQ(cut.get_border_top(),    "/---v---\\")
  `ASSERT_STR_EQ(cut.get_border_middle(), "[---|---]")
  `ASSERT_STR_EQ(cut.get_border_bottom(), "\\---^---/")
`END_SV_TEST

`SV_TEST_F(txt_tbl_border_fxtr, txt_tbl_unicode_column_width_ignores_border_bytes)
  // Column widths count the field text only, so the multi-byte border characters must not affect
  // the padding, and a widened column must repeat the horizontal character once per text character.
  box_glyphs g = unicode_g;
  cut.set_border_style(unicode);
  cut.add_column("a");
  cut.add_column("b");
  `ASSERT_STR_EQ(cut.get_row({"123", "2"}),             {g.v, " 123 ", g.v, " 2 ", g.v})
  `ASSERT_STR_EQ(cut.get_header(),                      {g.v, " a   ", g.v, " b ", g.v})
  `ASSERT_STR_EQ(cut.get_border_top(),    {g.tl, {5{g.h}}, g.t, {3{g.h}}, g.tr})
  `ASSERT_STR_EQ(cut.get_border_bottom(), {g.bl, {5{g.h}}, g.b, {3{g.h}}, g.br})
  `ASSERT_EQ(cut.get_border_top().len(), 3 * (1 + 5 + 1 + 3 + 1))
`END_SV_TEST

`SV_TEST_F(txt_tbl_border_fxtr, txt_tbl_unicode_too_many_row_fields)
  // Columns that are automatically added for extra row fields use the selected style.
  box_glyphs g = heavy_g;
  cut.set_border_style(heavy);
  cut.add_column("a");
  `ASSERT_STR_EQ(cut.get_row({"1", "2"}),               {g.v, " 1 ", g.v, " 2 ", g.v})
  `ASSERT_STR_EQ(cut.get_header(),                      {g.v, " a ", g.v, " ? ", g.v})
  `ASSERT_STR_EQ(cut.get_border_top(),    {g.tl, {3{g.h}}, g.t, {3{g.h}}, g.tr})
  `ASSERT_STR_EQ(cut.get_border_middle(), {g.ml, {3{g.h}}, g.m, {3{g.h}}, g.mr})
  `ASSERT_STR_EQ(cut.get_border_bottom(), {g.bl, {3{g.h}}, g.b, {3{g.h}}, g.br})
`END_SV_TEST

`SV_TEST_F(txt_tbl_border_fxtr, txt_tbl_set_border_style_null_is_ignored)
  txt_tbl_border_style no_style;
  cut.set_border_style(unicode);
  cut.set_border_style(no_style);
  check_border_chars(cut, unicode_g);
`END_SV_TEST


// A custom style with a distinct character for every function, to check that set_border_style()
// copies each function's character to the matching border character.
class distinct_border_style extends txt_tbl_border_style;
  virtual function string horizontal();   return "h"; endfunction
  virtual function string vertical();     return "v"; endfunction
  virtual function string top_left();     return "1"; endfunction
  virtual function string top();          return "2"; endfunction
  virtual function string top_right();    return "3"; endfunction
  virtual function string middle_left();  return "4"; endfunction
  virtual function string middle();       return "5"; endfunction
  virtual function string middle_right(); return "6"; endfunction
  virtual function string bottom_left();  return "7"; endfunction
  virtual function string bottom();       return "8"; endfunction
  virtual function string bottom_right(); return "9"; endfunction
endclass

`SV_TEST_F(txt_tbl_border_fxtr, txt_tbl_custom_border_style)
  distinct_border_style style = new();
  box_glyphs g = new("h", "v", "1", "2", "3", "4", "5", "6", "7", "8", "9");
  check_full_table(style, g);
  cut.set_border_style(style);
  check_border_chars(cut, g);
`END_SV_TEST


// A custom style that extends a built-in style and overrides only some of its characters.
class rounded_border_style extends txt_tbl_unicode_border_style;
  virtual function string top_left();     return "\342\225\255"; endfunction  // U+256D
  virtual function string top_right();    return "\342\225\256"; endfunction  // U+256E
  virtual function string bottom_right(); return "\342\225\257"; endfunction  // U+256F
  virtual function string bottom_left();  return "\342\225\260"; endfunction  // U+2570
endclass

`SV_TEST_F(txt_tbl_border_fxtr, txt_tbl_extended_border_style)
  rounded_border_style style = new();
  box_glyphs g = new(unicode_g.h, unicode_g.v,
                     "\342\225\255", unicode_g.t, "\342\225\256",
                     unicode_g.ml,   unicode_g.m, unicode_g.mr,
                     "\342\225\260", unicode_g.b, "\342\225\257");
  check_full_table(style, g);
  cut.set_border_style(style);
  check_code_points(cut, 'h2500, 'h2502,
                         'h256D, 'h252C, 'h256E,
                         'h251C, 'h253C, 'h2524,
                         'h2570, 'h2534, 'h256F);
`END_SV_TEST

`SV_TEST_F(txt_tbl_border_fxtr, txt_tbl_utf8_code_point_helper)
  // Sanity check of the test helper itself.
  // (String literals cannot be passed directly to `ASSERT_EQ(), so they are stored in variables first.)
  string light_h   = "\342\224\200";
  string double_m  = "\342\225\254";
  string ascii_h   = "-";
  string three_chr = "abc";
  string two_glyph = "\342\224\200\342\224\200";
  `ASSERT_EQ(utf8_code_point(light_h),   'h2500)
  `ASSERT_EQ(utf8_code_point(double_m),  'h256C)
  `ASSERT_EQ(utf8_code_point(ascii_h),   -1)
  `ASSERT_EQ(utf8_code_point(three_chr), -1)
  `ASSERT_EQ(utf8_code_point(two_glyph), -1)
`END_SV_TEST
