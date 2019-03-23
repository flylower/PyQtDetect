@echo on
call common.bat

Pushd %VIVADO_HOME%\VIVADO\%VIVADO_VERSION%
call %VIVADO_HOME%\VIVADO\%VIVADO_VERSION%\settings64.bat
popd

if exist work (
	rem del /f /s /q work
	rmdir /S /Q work
)

mkdir work
cd work

call vivado -mode tcl -source ..\axi_tlc1543_ip.tcl

pause