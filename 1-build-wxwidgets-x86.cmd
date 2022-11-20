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

goto nmake_build

:nmake_build
%_PSC% Copy-Item -Path "%TK_Src_Dir%\*" -Destination "%TK_Build_Dir%" -Recurse -Force
7z x -o"%TK_Build_Dir%\3rdparty\webview2" Microsoft.Web.WebView2.nupkg.zip

@REM Enable webview edge backend
%_PSC% "(Get-Content -path '%TK_Build_Dir%\include\wx\msw\setup.h') -Replace '\s*#\s*define\s+wxUSE_WEBVIEW_EDGE\s+.*','#define wxUSE_WEBVIEW_EDGE 1' | Out-File '%TK_Build_Dir%\include\wx\msw\setup.h'"

pushd "%TK_Build_Dir%\build\msw"
    nmake /f makefile.vc BUILD=release SHARED=1 UNICODE=1 TARGET_CPU=X86
popd
@REM Copy webview edge dll file
%_PSC% Copy-Item -Path "%TK_Build_Dir%\3rdparty\webview2\build\native\x86\*.dll" -Destination "%TK_Build_Dir%\lib\vc_dll" -Recurse -Force
goto __END

:cmake_build
set CMAKE_GENERATOR_PARAM=
for /F "tokens=1 delims=." %%a in ('MSBuild -nologo -version') do (
    set MSVC_TOOLSET=%%a
)
if "%MSVC_TOOLSET%x"=="x" (
    echo MSVC_TOOLSET not found
) else (
    echo MSVC_TOOLSET %MSVC_TOOLSET%
    if "%MSVC_TOOLSET%"=="15" (
        set CMAKE_GENERATOR_PARAM=-G "Visual Studio 15 2017"
    )
    if "%MSVC_TOOLSET%"=="16" (
        set CMAKE_GENERATOR_PARAM=-G "Visual Studio 16 2019"
    )
    if "%MSVC_TOOLSET%"=="17" (
        set CMAKE_GENERATOR_PARAM=-G "Visual Studio 17 2022"
    )
)

@REM set CMAKE_GENERATOR_PARAM=-G Ninja
@REM set CMAKE_GENERATOR_PARAM=-G "NMake Makefiles

set CMAKE_GENERATOR_PARAM=%CMAKE_GENERATOR_PARAM% -A Win32

echo=
echo CMAKE_GENERATOR_PARAM %CMAKE_GENERATOR_PARAM%

set TK_CMake_Install_Prefix=%~dp0wxWidgets-dist-winx86

@REM loop 3 times as wxlua project recommended.
SETLOCAL ENABLEDELAYEDEXPANSION
for %%i in (
    1
    2
    3
) do (
    set TK_CUSTOM_CONFIGURE_OPTS=
    set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DCMAKE_BUILD_TYPE=MinSizeRel
    set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DCMAKE_INSTALL_PREFIX="%TK_CMake_Install_Prefix%"
    set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DwxBUILD_SHARED=TRUE
    set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DwxBUILD_SAMPLES=OFF
    set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DwxBUILD_INSTALL=TRUE
    set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DwxUSE_WEBVIEW=TRUE
    set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DwxUSE_WEBVIEW_EDGE=TRUE
    set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DwxBUILD_TOOLKIT=msw
    set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DwxUSE_UNICODE=TRUE
    set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DwxUSE_DPI_AWARE_MANIFEST=per-monitor
    set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -S "%TK_Src_Dir%"
    set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -B "%TK_Build_Dir%"
    
    echo TK_CUSTOM_CONFIGURE_OPTS !TK_CUSTOM_CONFIGURE_OPTS!

    cmake %CMAKE_GENERATOR_PARAM% !TK_CUSTOM_CONFIGURE_OPTS!
)
SETLOCAL DISABLEDELAYEDEXPANSION

devenv "%TK_Build_Dir%\wxWidgets.sln" /Build "Release|Win32"
devenv "%TK_Build_Dir%\wxWidgets.sln" /Build "Release|Win32" /Project INSTALL

goto __END

:__END