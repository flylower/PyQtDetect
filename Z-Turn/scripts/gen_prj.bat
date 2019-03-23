@echo off

call common.bat

Pushd %VIVADO_HOME%\VIVADO\%VIVADO_VERSION%
call %VIVADO_HOME%\VIVADO\%VIVADO_VERSION%\settings64.bat
popd

rem del /f /s /q ..\PyQtDetect
rmdir /S /Q ..\PyQtDetect
mkdir ..\PyQtDetect
cd ..\PyQtDetect
call vivado -mode batch -source ../scripts/pyqtdetect.tcl
pause