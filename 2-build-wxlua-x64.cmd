@echo off
chcp 65001 >NUL 2>NUL

cd /d %~dp0

call vsenv.cmd 64

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

set CMAKE_GENERATOR_PARAM=%CMAKE_GENERATOR_PARAM% -A x64

echo=
echo CMAKE_GENERATOR_PARAM %CMAKE_GENERATOR_PARAM%

set TK_CMake_SRCDIR=%~dp0wxlua-src\wxLua
set TK_CMake_Install_Prefix=%~dp0wxlua-dist-winx64
set TK_CMake_Build_Dir=%~dp0build-wxlua\x64
set TK_Build_Ver_MMU=32u
set TK_Build_Ver_MSW_MMU=msw32u
set TK_WxWidgets_ROOT=%~dp0build-wxWidgets\x64
set TK_WxWidgets_LIBDIR=%TK_WxWidgets_ROOT%\lib\vc_x64_dll
set TK_wxWidgets_VERSION=3.2.1
set TK_Wxlua_Components="gl;stc;xrc;richtext;html;media;aui;adv;core;xml;net;base"
set TK_Lua_INCDIR=%~dp0luajit-dist-winx64\include
set TK_Lua_LIB=%~dp0luajit-dist-winx64\lib\lua51.lib

rmdir /q /s "%TK_CMake_Install_Prefix%"
rmdir /q /s "%TK_CMake_Build_Dir%"

mkdir "%TK_CMake_Build_Dir%"

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
    set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DCMAKE_SKIP_INSTALL_ALL_DEPENDENCY=FALSE
    set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DBUILD_SHARED_LIBS=TRUE -DBUILD_OUTPUT_DIRECTORY_ARCHIVE=lib -DBUILD_OUTPUT_DIRECTORY_LIBRARY=lib -DBUILD_OUTPUT_DIRECTORY_RUNTIME=bin
    set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DwxLuaBind_COMPONENTS=%TK_Wxlua_Components%
    set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DwxLua_LUA_INCLUDE_DIR="%TK_Lua_INCDIR%"
    set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DwxLua_LUA_LIBRARY="%TK_Lua_LIB%"
    set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DwxLua_LUA_LIBRARY_USE_BUILTIN=FALSE
    set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DwxWidgets_ROOT_DIR="%TK_WxWidgets_ROOT%"
    set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DwxWidgets_LIB_DIR="%TK_WxWidgets_LIBDIR%"
    set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DwxWidgets_VERSION=%TK_wxWidgets_VERSION%
    set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DwxWidgets_CONFIGURATION=mswu
    set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DWX_adv="%TK_WxWidgets_LIBDIR%\wx%TK_Build_Ver_MSW_MMU%_adv.lib"
    set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DWX_aui="%TK_WxWidgets_LIBDIR%\wx%TK_Build_Ver_MSW_MMU%_aui.lib"
    set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DWX_base="%TK_WxWidgets_LIBDIR%\wxbase%TK_Build_Ver_MMU%.lib"
    set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DWX_core="%TK_WxWidgets_LIBDIR%\wx%TK_Build_Ver_MSW_MMU%_core.lib"
    set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DWX_gl="%TK_WxWidgets_LIBDIR%\wx%TK_Build_Ver_MSW_MMU%_gl.lib"
    set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DWX_html="%TK_WxWidgets_LIBDIR%\wx%TK_Build_Ver_MSW_MMU%_html.lib"
    set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DWX_media="%TK_WxWidgets_LIBDIR%\wx%TK_Build_Ver_MSW_MMU%_media.lib"
    set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DWX_net="%TK_WxWidgets_LIBDIR%\wxbase%TK_Build_Ver_MMU%_net.lib"
    set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DWX_propgrid="%TK_WxWidgets_LIBDIR%\wx%TK_Build_Ver_MSW_MMU%_propgrid.lib"
    set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DWX_qa="%TK_WxWidgets_LIBDIR%\wx%TK_Build_Ver_MSW_MMU%_qa.lib"
    set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DWX_ribbon="%TK_WxWidgets_LIBDIR%\wx%TK_Build_Ver_MSW_MMU%_ribbon.lib"
    set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DWX_richtext="%TK_WxWidgets_LIBDIR%\wx%TK_Build_Ver_MSW_MMU%_richtext.lib"
    set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DWX_stc="%TK_WxWidgets_LIBDIR%\wx%TK_Build_Ver_MSW_MMU%_stc.lib"
    set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DWX_webview="%TK_WxWidgets_LIBDIR%\wx%TK_Build_Ver_MSW_MMU%_webview.lib"
    set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DWX_xml="%TK_WxWidgets_LIBDIR%\wxbase%TK_Build_Ver_MMU%_xml.lib"
    set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DWX_xrc="%TK_WxWidgets_LIBDIR%\wx%TK_Build_Ver_MSW_MMU%_xrc.lib"
    set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -S "%TK_CMake_SRCDIR%"
    set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -B "%TK_CMake_Build_Dir%"
    @REM set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DWX_dbgrid=
    @REM set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DWX_scintilla=
    @REM set TK_CUSTOM_CONFIGURE_OPTS=!TK_CUSTOM_CONFIGURE_OPTS! -DWX_odbc=
    
    echo TK_CUSTOM_CONFIGURE_OPTS !TK_CUSTOM_CONFIGURE_OPTS!

    cmake %CMAKE_GENERATOR_PARAM% !TK_CUSTOM_CONFIGURE_OPTS!
)
SETLOCAL DISABLEDELAYEDEXPANSION

@REM cmake --build "%TK_CMake_Build_Dir%" --config "MinSizeRel"
@REM devenv "%TK_CMake_Build_Dir%\wxLua.sln" /Build "MinSizeRel|x64"
@REM devenv "%TK_CMake_Build_Dir%\wxLua.sln" /Build "MinSizeRel|x64" /project INSTALL
devenv "%TK_CMake_Build_Dir%\modules\wxLuaModules.sln" /Build "MinSizeRel|x64"
devenv "%TK_CMake_Build_Dir%\modules\wxLuaModules.sln" /Build "MinSizeRel|x64" /project INSTALL
