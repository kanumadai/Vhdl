#!/bin/sh

# compile all of the files
vlogcomp -work work -d SIMULATION -i ../ -i ../tests -i ../dsport --incremental -f board.f
vlogcomp -work work $XILINX/verilog/src/glbl.v
vhpcomp -work work --incremental -f board.f

# compile and link source files
fuse work.board work.glbl -d SIMULATION -L unisims_ver -L secureip -o demo_tb
fuse work.board -L unisim -L secureip -o demo_tb

# set BATCH_MODE=0 to run simulation in GUI mode
BATCH_MODE=1

if [ $BATCH_MODE == 1 ]; then

  # run the simulation in batch mode
  ./demo_tb -wdb wave_isim -tclbatch isim_cmd.tcl

else

  # run the simulation in gui mode
  ./demo_tb -gui -view wave.wcfg -wdb wave_isim -tclbatch isim_cmd.tcl

fi
