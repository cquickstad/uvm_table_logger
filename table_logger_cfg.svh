// -------------------------------------------------------------
//    Copyright 2020 Chad Quickstad
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

// Look for the latest version of this code at:
//  https://github.com/cquickstad/uvm_table_logger.git

class table_logger_cfg extends uvm_object;

  // The file to which this logger will write the log.
  string log_file_name = "file_name.log";

  // The value to place in a table location when that field is otherwise empty.
  string empty_field_value = "-";

  // The value to place in an empty table location on the rows after the first row of a transaction
  // that get_log_table() reports on multiple rows.  (The first row uses empty_field_value.)
  // For example, "" leaves those locations blank so that only the multi-line fields stand out.
  string multi_line_empty_field_value = "-";

  // When 1, the "line" and "time" columns are written only on the first row of a transaction that
  // get_log_table() reports on multiple rows.  The other rows get multi_line_empty_field_value.  The
  // line number then counts transactions instead of rows.
  bit line_and_time_on_first_row_only = 0;

  // The characters used to draw the table borders.  When null (the default), ASCII is used.
  // For example:
  //   txt_tbl_pkg::txt_tbl_unicode_border_style style = new(); // or txt_tbl_unicode_heavy_border_style,
  //   cfg.border_style = style;                                //    txt_tbl_unicode_double_border_style,
  //                                                            //    txt_tbl_unicode_double_header_border_style
  // The Unicode styles write UTF-8 box-drawing characters, so view the log with a UTF-8 capable viewer.
  // A custom style can be made by extending txt_tbl_border_style.
  txt_tbl_border_style border_style;

  bit col_en[string];
  int col_width[string];
  string col_title[string];
  bit col_title_left_justify[string];
  bit col_field_left_justify[string];
  bit col_sticky_width_growth[string];

  // The UVM field macros expand to code that Verilator width-warns about.
  // verilator lint_off WIDTH
  `uvm_object_utils_begin(table_logger_cfg)
    `uvm_field_aa_int_string(col_en, UVM_ALL_ON)
    `uvm_field_aa_int_string(col_width, UVM_ALL_ON)
    `uvm_field_aa_string_string(col_title, UVM_ALL_ON)
    `uvm_field_aa_int_string(col_title_left_justify, UVM_ALL_ON)
    `uvm_field_aa_int_string(col_field_left_justify, UVM_ALL_ON)
    `uvm_field_aa_int_string(col_sticky_width_growth, UVM_ALL_ON)
  `uvm_object_utils_end
  // verilator lint_on WIDTH

  function new(string name="table_logger_cfg");
    super.new(name);
  endfunction

  // Helper to set the column title vertically.
  // For example: set_col_title_vertical("bus_error", "Bus Error") would produce the following
  //              column title for a column with tag "bus_error":
  //              +---+
  //              | B |
  //              | u |
  //              | s |
  //              |   |
  //              | E |
  //              | r |
  //              | r |
  //              | o |
  //              | r |
  //              +---+
  virtual function void set_col_title_vertical(string column_tag, string title);
    col_title[column_tag] = string2vertical(title);
  endfunction

  // Helper to set the column width for a field to be printed in decimal
  // given the number of bits of the field.
  // Reminder: the number of bits of a type can be obtained with $bits().
  // For example: set_col_width_for_dec_bits(.column_tag("my_column"),.bit_width($bits(my_type_t)))
  virtual function void set_col_width_for_dec_bits(string column_tag, int bit_width);
    bit [1023:0] max_value = (1024'b1 << bit_width) - 1;
    col_width[column_tag] = get_dec_str_width(max_value);
  endfunction

  // Helper to set the column width for a field to be printed in decimal
  // given the maximum value expected to be represented.
  // For example: set_col_width_for_dec_max(.column_tag("things"),.max_value(`NUMBER_OF_THINGS))
  virtual function void set_col_width_for_dec_max(string column_tag, int max_value);
    col_width[column_tag] = get_dec_str_width(1024'(max_value));
  endfunction

  // Helper to set the column width for a field to be printed in hexadecimal
  // given the number of bits.
  // Reminder: the number of bits of a type can be obtained with $bits().
  // For example: get_hex_str_width(.bit_width($bits(my_type_t)))
  virtual function void set_col_width_for_hex(string column_tag, int bit_width);
    col_width[column_tag] = get_hex_str_width(bit_width);
  endfunction

  // Helper to determine the column width for a field to be printed as an integer
  // decimal given the maximum value expected to be represented.
  // Counts digits directly: $log10() fails for values that do not fit in an
  // int, and real-number rounding is inexact near powers of 10.
  static function int get_dec_str_width(bit [1023:0] max_value);
    string s = $sformatf("%0d", max_value);
    return s.len();
  endfunction

  localparam NUM_BITS_PER_HEX_CHARACTER = 4;

  // Helper to determine the column width for a field to be printed in hexadecimal
  // given the number of bits.
  // Reminder: the number of bits of a type can be obtained with $bits().
  // For example: get_hex_str_width(.bit_width($bits(my_type_t)))
  static function int get_hex_str_width(int bit_width);
    return div_round_up(bit_width, NUM_BITS_PER_HEX_CHARACTER);
  endfunction

  // Helper function that implements the standard integer round-up division algorithm.
  static function int div_round_up(int dividend, int divisor);
    return (dividend + (divisor - 1)) / divisor;
  endfunction

  // Helper to transform a string from horizontal to vertical.
  // For example: string2vertical("My String") returns "M\ny\n \nS\nt\nr\ni\nn\ng"
  //              which will display as:
  //              M
  //              y
  //
  //              S
  //              t
  //              r
  //              i
  //              n
  //              g
  static function string string2vertical(string s);
    string2vertical = "";
    foreach (s[i]) string2vertical = {string2vertical, s[i], "\n"};
    string2vertical = string2vertical.substr(0, string2vertical.len()-2);
  endfunction

endclass
