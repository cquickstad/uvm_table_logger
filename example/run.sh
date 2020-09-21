#!/bin/bash

function xcelium {
    xrun -access rwc \
        -sv \
        -uvm \
        -uvmhome CDNS-1.2 \
        -timescale 1ns/1ns \
        -xceligen on \
        -disable_sem2009 \
        +libext+.v \
        +libext+.sv \
        -incdir ../ \
        -incdir ../txt_tbl/ \
        $*
}

xcelium \
  \
  +UVM_NO_RELNOTES \
  \
  $* \
  \
  my_interface.sv \
  my_pkg.sv \
  \
  top.sv

