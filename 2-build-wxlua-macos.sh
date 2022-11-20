#!/usr/bin/env bash

# shellcheck disable=SC2296
# ---------------- GET SELF PATH ----------------
ORIGINAL_PWD_GETSELFPATHVAR=$(pwd)
if test -n "$BASH"; then SH_FILE_RUN_PATH_GETSELFPATHVAR=${BASH_SOURCE[0]}
elif test -n "$ZSH_NAME"; then SH_FILE_RUN_PATH_GETSELFPATHVAR=${(%):-%x}
elif test -n "$KSH_VERSION"; then SH_FILE_RUN_PATH_GETSELFPATHVAR=${.sh.file}
else SH_FILE_RUN_PATH_GETSELFPATHVAR=$(lsof -p $$ -Fn0 | tr -d '\0' | grep "${0##*/}" | tail -1 | sed 's/^[^\/]*//g')
fi
cd "$(dirname "$SH_FILE_RUN_PATH_GETSELFPATHVAR")" || return 1
SH_FILE_RUN_BASENAME_GETSELFPATHVAR=$(basename "$SH_FILE_RUN_PATH_GETSELFPATHVAR")
while [ -L "$SH_FILE_RUN_BASENAME_GETSELFPATHVAR" ]; do
    SH_FILE_REAL_PATH_GETSELFPATHVAR=$(readlink "$SH_FILE_RUN_BASENAME_GETSELFPATHVAR")
    cd "$(dirname "$SH_FILE_REAL_PATH_GETSELFPATHVAR")" || return 1
    SH_FILE_RUN_BASENAME_GETSELFPATHVAR=$(basename "$SH_FILE_REAL_PATH_GETSELFPATHVAR")
done
SH_SELF_PATH_DIR_RESULT=$(pwd -P)
SH_FILE_REAL_PATH_GETSELFPATHVAR=$SH_SELF_PATH_DIR_RESULT/$SH_FILE_RUN_BASENAME_GETSELFPATHVAR
cd "$ORIGINAL_PWD_GETSELFPATHVAR" || return 1
unset ORIGINAL_PWD_GETSELFPATHVAR SH_FILE_RUN_PATH_GETSELFPATHVAR SH_FILE_RUN_BASENAME_GETSELFPATHVAR SH_FILE_REAL_PATH_GETSELFPATHVAR
# ---------------- GET SELF PATH ----------------
# USE $SH_SELF_PATH_DIR_RESULT BEBLOW

mkdir "$SH_SELF_PATH_DIR_RESULT/build-wxlua"
cd "$SH_SELF_PATH_DIR_RESULT/build-wxlua" || exit
TK_CMake_Build_DIR=$(pwd -P)
echo "TK_CMake_Build_DIR: $TK_CMake_Build_DIR"

cd ../build-wxWidgets || exit
TK_Custom_Wx_Config_EXEF="$(pwd -P)/wx-config"
echo "TK_Custom_Wx_Config_EXEF: $TK_Custom_Wx_Config_EXEF"

cd "$TK_CMake_Build_DIR" || exit

cd ../wxlua-src/wxLua || exit
TK_Custom_Wxlua_SRC_DIR=$(pwd -P)
echo "TK_Custom_Wxlua_SRC_DIR: $TK_Custom_Wxlua_SRC_DIR"

cd "$TK_CMake_Build_DIR" || exit

cd ../luajit-dist || exit
TK_Lua_LIB="$(pwd -P)/lib/libluajit-5.1.dylib"
echo "TK_Lua_LIB: $TK_Lua_LIB"

TK_Lua_INC_DIR="$(pwd -P)/include/luajit-2.1"
echo "TK_Lua_INC_DIR: $TK_Lua_INC_DIR"

cd "$TK_CMake_Build_DIR" || exit

TK_CMake_Install_Prefix="$SH_SELF_PATH_DIR_RESULT/wxlua-dist"

TK_CMake_Custom_Opts+=(-DMACOSX_RPATH=TRUE)
TK_CMake_Custom_Opts+=(-DCMAKE_BUILD_TYPE=MinSizeRel)
TK_CMake_Custom_Opts+=(-DCMAKE_INSTALL_PREFIX="$TK_CMake_Install_Prefix")
TK_CMake_Custom_Opts+=(-DBUILD_SHARED_LIBS=FALSE)
TK_CMake_Custom_Opts+=(-DBUILD_OUTPUT_DIRECTORY_ARCHIVE=lib)
TK_CMake_Custom_Opts+=(-DBUILD_OUTPUT_DIRECTORY_LIBRARY=lib)
TK_CMake_Custom_Opts+=(-DBUILD_OUTPUT_DIRECTORY_RUNTIME=bin)
TK_CMake_Custom_Opts+=(-DwxLuaBind_COMPONENTS="gl;stc;xrc;richtext;html;media;aui;adv;core;xml;net;base")
TK_CMake_Custom_Opts+=(-DwxLua_LUA_INCLUDE_DIR="$TK_Lua_INC_DIR")
TK_CMake_Custom_Opts+=(-DwxLua_LUA_LIBRARY="$TK_Lua_LIB")
TK_CMake_Custom_Opts+=(-DwxLua_LUA_LIBRARY_USE_BUILTIN=FALSE)
TK_CMake_Custom_Opts+=(-DwxWidgets_CONFIG_EXECUTABLE="$TK_Custom_Wx_Config_EXEF")
TK_CMake_Custom_Opts+=(-G "Unix Makefiles")
TK_CMake_Custom_Opts+=(-S "$TK_Custom_Wxlua_SRC_DIR")
TK_CMake_Custom_Opts+=(-B "$TK_CMake_Build_DIR")

echo "TK_CMake_Custom_Opts: ${TK_CMake_Custom_Opts[*]}"
# loop 5 times as wxlua project recommended.
for _ in {1..3}; do
cmake "${TK_CMake_Custom_Opts[@]}"     
done

# echo -n "press enter to continue: "; read -r

cmake --build .
cmake --install .

rm -rfv "${TK_CMake_Install_Prefix:?}/bin"
rm -rfv "${TK_CMake_Install_Prefix:?}/share"
cp -fv "$TK_CMake_Install_Prefix/lib/libwx.dylib" "$SH_SELF_PATH_DIR_RESULT/luajit-dist/lib/lua/5.1"

echo -en '\a'