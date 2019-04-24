@echo off
set xv_path=C:\\Xilinx\\Vivado\\2017.2\\bin
call %xv_path%/xelab  -wto bfc6d33675f34e59a51d26a1983c03b4 -m64 --debug typical --relax --mt 2 -L xil_defaultlib -L secureip --snapshot mips_testbench_behav xil_defaultlib.mips_testbench -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
