#!/bin/bash

# Limit CPU and memory usage so the system isn't swamped and unresponsive.
# Assumes Hyperthreading (divide-by-two).
# Leaves one CPU free (minus one) to keep the system responsive.
# 8 threads -> 3 jobs; never below 1
jobs=$(( $(nproc) / 2 - 1 ))
(( jobs < 1 )) && jobs=1

nice -n 15 ionice -c 3 verilator \
    -Wno-fatal \
    --binary \
    -j $jobs \
    -MAKEFLAGS 'OBJCACHE=ccache' \
    -CFLAGS -O0 \
    --trace-fst \
    --trace-structs \
    --trace-params \
    --trace-underscore \
    --trace-max-array 1024 \
    --top-module top \
    --vpi \
    +incdir+$UVM_HOME \
    +incdir+../txt_tbl \
    +incdir+../ \
    +define+UVM_NO_RELNOTES \
    +define+WITH_COV \
    \
    $UVM_HOME/uvm_pkg.sv \
    $UVM_HOME/dpi/uvm_dpi.cc \
    \
    my_interface.sv \
    \
    ../table_logger_pkg.sv \
    my_pkg.sv \
    \
    top.sv \
&& \
./obj_dir/Vtop +UVM_TESTNAME=rand_test
