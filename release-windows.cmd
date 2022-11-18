@echo off
chcp 65001 >NUL 2>NUL

cd /d %~dp0

cmd /c 0-fetch-deps.cmd
cmd /c 1-build-wxwidgets.cmd
cmd /c 2-build-wxlua.cmd
cmd /c 3-clean-4release.cmd

7z a luajit-dist-winx64.7z luajit-dist-winx64
7z a luajit-dist-win32.7z luajit-dist-win32
7z a wxlua-dist-winx64.7z wxlua-dist-winx64
7z a wxlua-dist-win32.7z wxlua-dist-win32
7z a wxWidgets-dist-winx64.7z wxWidgets-dist-winx64
7z a wxWidgets-dist-win32.7z wxWidgets-dist-win32