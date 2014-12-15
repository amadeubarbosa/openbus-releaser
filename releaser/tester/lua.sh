#!/bin/sh

source releaser/tester/utils.sh

assert_arg "$1" "lua.sh <sdk-lua version> <core version> [openssl version]"
assert_arg "$2" "lua.sh <sdk-lua version> <core version> [openssl version]"

sdklua_ver=$1
core_ver=$2
ssl_ver=$3
if [[ "$ssl_ver" == "" ]]; then
	ssl_ver=1.0.0m
fi

installsrc lua52 $sdklua_ver openbus-lua
installsrc core $core_ver openbus-busservice

core_src=$OPENBUS_SANDBOX/build/openbus-busservice-$core_ver
sdklua_src=$OPENBUS_SANDBOX/build/openbus-lua-$sdklua_ver

installpack openssl $ssl_ver
installpack lua52 $sdklua_ver
installpack core $core_ver

OPENBUS_OPENSSL_HOME=$OPENBUS_SANDBOX/install/openssl-$ssl_ver
export OPENBUS_SDKLUA_HOME=$OPENBUS_SANDBOX/install/lua52-$sdklua_ver  # must be exported due to interop. test
OPENBUS_CORE_HOME=$OPENBUS_SANDBOX/install/core-$core_ver
OPENBUS_CORE_TEST="$core_src/test"
export LUA_PATH="$core_src/test/?.lua;$sdklua_src/test/?.lua"
export LD_LIBRARY_PATH="$OPENBUS_OPENSSL_HOME/lib"

print_header "TEST" "Testing SDK-Lua"

cd $sdklua_src/test

source runall.sh RELEASE

rm -fr $OPENBUS_SANDBOX
