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

class my_env extends uvm_env;

  `uvm_component_utils(my_env)

  my_agent agt_x;
  my_agent agt_y;

  table_logger_cfg log_cfg;
  table_logger#(my_table_item, my_item) logger;

  function new(string name="my_env", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    factory_overrides();
    configure_agents();
    configure_logger();
    agt_x = my_agent::type_id::create("agt_x", this);
    agt_y = my_agent::type_id::create("agt_y", this);
    logger = table_logger#(my_table_item, my_item)::type_id::create("logger", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agt_x.ap.connect(logger.analysis_export);
    agt_y.ap.connect(logger.analysis_export);
  endfunction

  protected virtual function void factory_overrides();
    // Use the factory to override the default type created by the monitor
    // with the type that the table_logger can use.
    set_type_override_by_type(my_item::get_type(), my_table_item::get_type());
  endfunction

  protected virtual function void configure_agents();
    uvm_config_db#(string)::set(this, "agt_x*", "ifc", "X");
    uvm_config_db#(string)::set(this, "agt_y*", "ifc", "Y");
  endfunction

  protected virtual function void configure_logger();
    log_cfg = table_logger_cfg::type_id::create("cfg", this);
    log_cfg.log_file_name = "my_log.log";
    log_cfg.col_width["ifc"] = 1;
    log_cfg.col_width["a"] = 8;
    log_cfg.col_width["b"] = 10;
    log_cfg.col_title["ifc"] = "I\nn\nt\ne\nr\nf\nn\nc\ne";
    log_cfg.col_title["a"] = "Value A\n(hex)";
    log_cfg.col_title["b"] = "Value B\n(decimal)";
    uvm_config_db#(table_logger_cfg)::set(this, "logger", "cfg", log_cfg);
  endfunction

endclass

