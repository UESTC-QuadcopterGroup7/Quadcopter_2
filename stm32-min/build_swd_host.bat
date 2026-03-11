@echo off
setlocal

set BUILD_DIR=build_swd_host
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"

gcc -O2 -Wall -Wextra -std=c11 -Ihost_swd ^
  host_swd\swd_status.c ^
  host_swd\swd_transport_stub.c ^
  host_swd\adiv5.c ^
  host_swd\cortexm.c ^
  host_swd\stm32f4_flash.c ^
  host_swd\swd_tool_main.c ^
  -o "%BUILD_DIR%\swd_host_tool.exe"

exit /b %errorlevel%
