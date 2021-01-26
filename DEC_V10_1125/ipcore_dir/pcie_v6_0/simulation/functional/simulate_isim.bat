
REM compile all of the files
vlogcomp -work work -d SIMULATION -i ..\ -i ..\tests -i ..\dsport --incremental -f board.f
vlogcomp -work work %XILINX%\verilog\src\glbl.v
vhpcomp -work work --incremental -f board.f

REM compile and link source files
fuse.exe work.board work.glbl -d SIMULATION -L unisims_ver -L secureip -o demo_tb.exe
fuse.exe work.board -L unisim -L secureip -o demo_tb.exe

REM set BATCH_MODE=0 to run simulation in GUI mode
set /a BATCH_MODE=1

if [ %BATCH_MODE% == 1 ]; (goto :batchmode)

REM run the simulation in GUI mode
demo_tb.exe -gui -view wave.wcfg -wdb wave_isim -tclbatch isim_cmd.tcl
goto :eof

:batchmode

REM run the simulation in batch mode
demo_tb.exe -wdb wave_isim -tclbatch isim_cmd.tcl

