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
@REM set CMAKE_GENERATOR_PARAM=
@REM for /F "tokens=1 delims=." %%a in ('MSBuild -nologo -version') do (
@REM     set MSVC_TOOLSET=%%a
@REM )
@REM if "%MSVC_TOOLSET%x"=="x" (
@REM     echo MSVC_TOOLSET not found
@REM ) else (
@REM     echo MSVC_TOOLSET %MSVC_TOOLSET%
@REM     if "%MSVC_TOOLSET%"=="15" (
@REM         set CMAKE_GENERATOR_PARAM=-G "Visual Studio 15 2017"
@REM     )
@REM     if "%MSVC_TOOLSET%"=="16" (
@REM         set CMAKE_GENERATOR_PARAM=-G "Visual Studio 16 2019"
@REM     )
@REM     if "%MSVC_TOOLSET%"=="17" (
@REM         set CMAKE_GENERATOR_PARAM=-G "Visual Studio 17 2022"
@REM     )
@REM )

@REM @REM set CMAKE_GENERATOR_PARAM=-G Ninja
@REM @REM set CMAKE_GENERATOR_PARAM=-G "NMake Makefiles

@REM set CMAKE_GENERATOR_PARAM=%CMAKE_GENERATOR_PARAM% -A Win32

@REM echo=
@REM echo CMAKE_GENERATOR_PARAM %CMAKE_GENERATOR_PARAM%

@REM set TK_CMake_Install_Prefix=%~dp0wxWidgets-dist-winx86

@REM @REM loop 3 times as wxlua project recommended.
@REM SETLOCAL ENABLEDELAYEDEXPANSION
@REM for %%i in (
@REM     1
@REM     2
@REM     3
@REM ) do (
@REM     set TK_CUSTOM_CONFIGURE_OPTS=
@REM     set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DCMAKE_BUILD_TYPE=MinSizeRel
@REM     set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DCMAKE_INSTALL_PREFIX="%TK_CMake_Install_Prefix%"
@REM     set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DwxBUILD_SHARED=TRUE
@REM     set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DwxBUILD_SAMPLES=OFF
@REM     set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DwxBUILD_INSTALL=TRUE
@REM     set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DwxUSE_WEBVIEW=TRUE
@REM     set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DwxUSE_WEBVIEW_EDGE=TRUE
@REM     set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DwxBUILD_TOOLKIT=msw
@REM     set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DwxUSE_UNICODE=TRUE
@REM     set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DwxUSE_DPI_AWARE_MANIFEST=per-monitor
@REM     set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -S "%TK_Src_Dir%"
@REM     set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -B "%TK_Build_Dir%"
    
@REM     echo TK_CUSTOM_CONFIGURE_OPTS !TK_CUSTOM_CONFIGURE_OPTS!

@REM     cmake %CMAKE_GENERATOR_PARAM% !TK_CUSTOM_CONFIGURE_OPTS!
@REM )
@REM SETLOCAL DISABLEDELAYEDEXPANSION

@REM devenv "%TK_Build_Dir%\wxWidgets.sln" /Build "Release|Win32"
@REM devenv "%TK_Build_Dir%\wxWidgets.sln" /Build "Release|Win32" /Project INSTALL

goto __END

:__END