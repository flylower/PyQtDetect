@echo off
call common.bat
rmdir /s/q ..\sdk
mkdir ..\sdk
cd ..\sdk
rem set PATH=%PATH%;%VIVADO_HOME%\Vivado\%VIVADO_VERSION%\tps\win64\git-1.9.5\bin\
call %VIVADO_HOME%\SDK\%VIVADO_VERSION%\bin\xsct.bat ../scripts/pyqtdetect_sdk.tcl
pause