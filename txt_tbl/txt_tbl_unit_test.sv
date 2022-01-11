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


`include "txt_tbl.sv"


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
    endfunction : new

    virtual task setup();
        cut = new();
    endtask : setup
endclass : txt_tbl_fxtr


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
  cut.boundry_pad_char              = "_";
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

