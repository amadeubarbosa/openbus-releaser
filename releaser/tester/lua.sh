#!/bin/sh

source releaser/tester/utils.sh

assert_arg "$1" "lua.sh <sdk-lua version> <core version> [openssl version]"
assert_arg "$2" "lua.sh <sdk-lua version> <core version> [openssl version]"

installbase $2 $3

sdklua_ver=$1
installpack lua52 $sdklua_ver
installsrc lua52 $sdklua_ver openbus-lua

sdklua_src=$OPENBUS_SANDBOX/build/openbus-lua-$sdklua_ver
export OPENBUS_SDKLUA_HOME=$OPENBUS_SANDBOX/install/lua52-$sdklua_ver  # must be exported due to interop. test
export LUA_PATH="$sdklua_src/test/?.lua;$LUA_PATH"

print_header "TEST" "Testing SDK-Lua"

cd $sdklua_src/test

source runall.sh RELEASE

rm -fr $OPENBUS_SANDBOX

