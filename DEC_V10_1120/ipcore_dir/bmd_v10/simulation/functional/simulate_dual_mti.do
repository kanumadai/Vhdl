vlib work
vmap work

vlog -work work +incdir+../.+../../source \
      -f ../source_rtl.f \
      $env(XILINX)/verilog/src/glbl.v 

vlog -work work \
      -f rport_dual_rtl_x01.f 

vcom -93 -work work \
      -f board_dual_rtl_x01.f 

vsim +notimingchecks -t 1ps \
          -L unisim -L work -L secureip work.board glbl

run -all
