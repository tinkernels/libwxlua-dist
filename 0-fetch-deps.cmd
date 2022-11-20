@echo off
chcp 65001 >NUL 2>NUL

cd /d %~dp0

set _PWSH=powershell
where pwsh.exe 2>&1
IF %ERRORLEVEL% EQU 0 (
    echo=
    echo found pwsh
    echo=
    set _PWSH=pwsh
)
set _PSC=%_PWSH% -NoProfile -ExecutionPolicy Bypass -Command

%_PSC% Invoke-WebRequest -Uri "https://github.com/tinkernels/openresty-luajit2-dist/releases/latest/download/luajit-dist-win32.7z" -OutFile "luajit-dist-win32.7z"
%_PSC% Invoke-WebRequest -Uri "https://github.com/tinkernels/openresty-luajit2-dist/releases/latest/download/luajit-dist-winx64.7z" -OutFile "luajit-dist-winx64.7z"

%_PSC% Invoke-WebRequest -Uri "https://www.nuget.org/api/v2/package/Microsoft.Web.WebView2" -OutFile Microsoft.Web.WebView2.nupkg.zip

7z x luajit-dist-win32.7z
7z x luajit-dist-winx64.7z

git clone --depth 1 --recurse-submodules --branch v3.2.0.2 https://github.com/pkulchenko/wxlua.git wxlua-src
git clone --depth 1 --recurse-submodules --branch v3.2.1 https://github.com/wxWidgets/wxWidgets.git wxWidgets-src
