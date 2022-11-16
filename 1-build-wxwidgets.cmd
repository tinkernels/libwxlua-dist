@echo off
chcp 65001 >NUL 2>NUL

cd /d %~dp0

cmd /c 1-build-wxwidgets-x86.cmd
cmd /c 1-build-wxwidgets-x64.cmd