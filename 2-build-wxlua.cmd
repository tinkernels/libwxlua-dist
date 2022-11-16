@echo off
chcp 65001 >NUL 2>NUL

cd /d %~dp0

mkdir build-wxlua\x64
mkdir build-wxlua\x86

cmd /c 2-build-wxlua-x64.cmd
cmd /c 2-build-wxlua-x86.cmd
