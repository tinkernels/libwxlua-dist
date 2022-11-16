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

cd "$SH_SELF_PATH_DIR_RESULT" || exit

brew update; brew upgrade

bash ./0-fetch-deps-macos-arm64.sh || exit
bash ./1-build-wxWidgets-macos-automake.sh || exit
bash ./2-build-wxlua-macos.sh || exit

# clean for packing.
find build-wxWidgets -mindepth 1 -maxdepth 1 ! -name lib ! -name include ! -name wx-config -exec rm -rfv {} \;
find build-wxlua -mindepth 1 -type f ! -name "*.h" ! -name "*.so" ! -name "*.dylib" ! -name "*.a" -exec rm -rfv {} \;
find build-wxlua -mindepth 1 -empty -type d -delete

TK_LUAJIT_RELEASE_TARBALL="luajit-dist-macos-arm64.tar.gz"
tar -cvf "$TK_LUAJIT_RELEASE_TARBALL" luajit-dist

TK_wxWidgets_RELEASE_TARBALL="wxWidgets-dist-macos-arm64.tar.gz"
tar -cvf "$TK_wxWidgets_RELEASE_TARBALL" build-wxWidgets

TK_wxLua_RELEASE_TARBALL="wxlua-dist-macos-arm64.tar.gz"
tar -cvf "$TK_wxLua_RELEASE_TARBALL" build-wxlua

if [[ "$CIRRUS_RELEASE" == "" ]]; then
  echo "Not a release. No need to deploy!"
  exit 0
fi

if [[ "$GITHUB_TOKEN" == "" ]]; then
  echo "Please provide GitHub access token via GITHUB_TOKEN environment variable!"
  exit 1
fi

FILE_CONTENT_TYPE="application/octet-stream"
FILES_TO_UPLOAD=(
  "$TK_LUAJIT_RELEASE_TARBALL"
  "$TK_wxWidgets_RELEASE_TARBALL"
  "$TK_wxLua_RELEASE_TARBALL"
)

for FPATH in "${FILES_TO_UPLOAD[@]}"
do
  echo "Uploading $FPATH..."
  NAME=$(basename "$FPATH")
  URL_TO_UPLOAD="https://uploads.github.com/repos/$CIRRUS_REPO_FULL_NAME/releases/$CIRRUS_RELEASE/assets?name=$NAME"
  curl -X POST \
    --data-binary @"$FPATH" \
    --header "Authorization: token $GITHUB_TOKEN" \
    --header "Content-Type: $FILE_CONTENT_TYPE" \
    "$URL_TO_UPLOAD"
done