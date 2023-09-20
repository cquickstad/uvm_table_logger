// SystemVerilog demands a default type. Supply a dummy to allow it to compile.
typedef enum {DUMMY_ENUM_WIDTH_FINDER_VALUE} dummy_default_enum_width_finder_t;

// This is a helper tool to assist in setting column widths for table columns
// that show enum values.
// Usage is as follows:
// log_cfg.column_width["some_enum_column"] = enum_width_finder#(some_enum_t)::get_max_width();
class enum_width_finder#(type ENUM_TYPE=dummy_default_enum_width_finder_t);

	static function int unsigned get_max_width();
		ENUM_TYPE e = e.first();
		get_max_width = 0;
		forever begin
			string s = e.name();
			int len = s.len();
			get_max_width = (len > get_max_width) ? len : get_max_width;
			if (e == e.last()) break;
			e = e.next();
		end
	endfunction

	static function int unsigned get_min_width();
		ENUM_TYPE e = e.first();
		get_min_width = -1;
		forever begin
			string s = e.name();
			int len = s.len();
			get_min_width = (len < get_min_width) ? len : get_min_width;
			if (e == e.last()) break;
			e = e.next();
		end
	endfunction

endclass
