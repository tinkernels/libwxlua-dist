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
TK_CUSTOM_BUILD_DIR=$(pwd -P)
echo "TK_CUSTOM_BUILD_DIR: $TK_CUSTOM_BUILD_DIR"

cd ../build-wxWidgets || exit
TK_CUSTOM_WX_CONFIG_EXEC_FILE="$(pwd -P)/wx-config"
echo "TK_CUSTOM_WX_CONFIG_EXEC_FILE: $TK_CUSTOM_WX_CONFIG_EXEC_FILE"

cd "$TK_CUSTOM_BUILD_DIR" || exit

cd ../wxlua-src/wxLua || exit
TK_CUSTOM_WXLUA_SRC_DIR=$(pwd -P)
echo "TK_CUSTOM_WXLUA_SRC_DIR: $TK_CUSTOM_WXLUA_SRC_DIR"

cd "$TK_CUSTOM_BUILD_DIR" || exit

cd ../luajit-dist || exit
TK_CUSTOM_LUA_LIB_DIR="$(pwd -P)/lib/libluajit-5.1.dylib"
echo "TK_CUSTOM_LUA_LIB_DIR: $TK_CUSTOM_LUA_LIB_DIR"

TK_CUSTOM_LUA_INC_DIR="$(pwd -P)/include/luajit-2.1"
echo "TK_CUSTOM_LUA_INC_DIR: $TK_CUSTOM_LUA_INC_DIR"

cd "$TK_CUSTOM_BUILD_DIR" || exit

TK_CUSTOM_CONFIGURE_OPTS+=(-DMACOSX_RPATH=TRUE)
TK_CUSTOM_CONFIGURE_OPTS+=(-DBUILD_SHARED_LIBS=FALSE)
TK_CUSTOM_CONFIGURE_OPTS+=(-DBUILD_OUTPUT_DIRECTORY_ARCHIVE=lib)
TK_CUSTOM_CONFIGURE_OPTS+=(-DBUILD_OUTPUT_DIRECTORY_LIBRARY=lib)
TK_CUSTOM_CONFIGURE_OPTS+=(-DBUILD_OUTPUT_DIRECTORY_RUNTIME=runapp)
TK_CUSTOM_CONFIGURE_OPTS+=(-DwxLuaBind_COMPONENTS="gl;stc;xrc;richtext;html;media;aui;adv;core;xml;net;base")
TK_CUSTOM_CONFIGURE_OPTS+=(-DCMAKE_BUILD_TYPE=MinSizeRel)
# TK_CUSTOM_CONFIGURE_OPTS+=(-DCMAKE_BUILD_TYPE=RelWithDebInfo)
# TK_CUSTOM_CONFIGURE_OPTS+=(-DwxLuaBind_COMPONENTS="gl;scintilla;mono")
# TK_CUSTOM_CONFIGURE_OPTS+=(-DwxLuaBind_COMPONENTS="gl;mono")

echo "TK_CUSTOM_CONFIGURE_OPTS: ${TK_CUSTOM_CONFIGURE_OPTS[*]}"

# loop 5 times as wxlua project recommended.
for _ in {1..3}; do
cmake "${TK_CUSTOM_CONFIGURE_OPTS[@]}" \
    -DwxLua_LUA_INCLUDE_DIR="$TK_CUSTOM_LUA_INC_DIR" \
    -DwxLua_LUA_LIBRARY="$TK_CUSTOM_LUA_LIB_DIR" \
    -DwxLua_LUA_LIBRARY_USE_BUILTIN=FALSE \
    -DwxWidgets_CONFIG_EXECUTABLE="$TK_CUSTOM_WX_CONFIG_EXEC_FILE" \
    -G "Unix Makefiles" \
    -S"$TK_CUSTOM_WXLUA_SRC_DIR" \
    -B.
done

echo -n "press enter to continue: "; read -r

make -j9

cp -fv "$TK_CUSTOM_BUILD_DIR/modules/luamodule/lib/MinSizeRel/libwx.dylib" "$SH_SELF_PATH_DIR_RESULT/luajit-dist/lib/lua/5.1"

echo -en '\a'
