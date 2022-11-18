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

set TK_Build_Dir=build-wxWidgets\x86
set TK_Src_Dir=wxWidgets-src

rmdir /q /s "%TK_Build_Dir%"
mkdir "%TK_Build_Dir%"

%_PSC% Copy-Item -Path "%TK_Src_Dir%\*" -Destination "%TK_Build_Dir%" -Recurse -Force

cd "%TK_Build_Dir%\build\msw"
nmake /f makefile.vc BUILD=release SHARED=1 UNICODE=1 TARGET_CPU=X86