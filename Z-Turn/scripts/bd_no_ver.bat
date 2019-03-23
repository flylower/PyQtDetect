@echo off

call common.bat

Pushd %VIVADO_HOME%\VIVADO\%VIVADO_VERSION%
call %VIVADO_HOME%\VIVADO\%VIVADO_VERSION%\settings64.bat
popd
call vivado -nolog -nojournal -mode batch -source ./bd_no_ver.tcl
pause