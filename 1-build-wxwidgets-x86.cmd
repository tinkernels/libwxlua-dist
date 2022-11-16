@echo off
chcp 65001 >NUL 2>NUL

cd /d %~dp0

call vsenv.cmd 32

set _PWSH=powershell
where pwsh.exe 2>&1
IF %ERRORLEVEL% EQU 0 (
    echo=
    echo found pwsh
    echo=
    set _PWSH=pwsh
)
set _PSC=%_PWSH% -NoProfile -ExecutionPolicy Bypass -Command

set TKVAR_BUILD_DIR=build-wxWidgets\x86

rmdir /q /s "%TKVAR_BUILD_DIR%
mkdir "%TKVAR_BUILD_DIR%"

%_PSC% -NoProfile -ExecutionPolicy Bypass -Command Copy-Item -Path "wxWidgets-src\*" -Destination "%TKVAR_BUILD_DIR%" -recurse -Force

cd "%TKVAR_BUILD_DIR%\build\msw"
nmake /f makefile.vc BUILD=release SHARED=1 UNICODE=1 TARGET_CPU=X86