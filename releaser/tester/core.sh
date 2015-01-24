#!/bin/sh

source releaser/tester/utils.sh

assert_arg "$1" "core.sh <core version> [sdklua version] [openssl version]"

core_ver=$1
sdklua_ver=$2
ssl_ver=$3
if [[ "$ssl_ver" == "" ]]; then
	ssl_ver=1.0.0m
fi

installsrc core $core_ver openbus-busservice

if [[ "$sdklua_ver" == "" ]]; then
	installsrc core $core_ver openbus-lua
	for d in $OPENBUS_SANDBOX/build/openbus-lua-*; do
		[ -d "$d" ] && sdklua_ver="${d/$OPENBUS_SANDBOX\/build\/openbus\-lua\-/}" && break
	done
else
	installsrc lua52 $sdklua_ver openbus-lua
fi

core_src=$OPENBUS_SANDBOX/build/openbus-busservice-$core_ver
sdklua_src=$OPENBUS_SANDBOX/build/openbus-lua-$sdklua_ver

installpack openssl $ssl_ver
installpack lua52 $sdklua_ver
installpack core $core_ver

OPENBUS_OPENSSL_HOME=$OPENBUS_SANDBOX/install/openssl-$ssl_ver
OPENBUS_SDKLUA_HOME=$OPENBUS_SANDBOX/install/lua52-$sdklua_ver
export OPENBUS_CORE_HOME=$OPENBUS_SANDBOX/install/core-$core_ver # must be exported due to 'busadmin' test
export LUA_PATH="$core_src/test/?.lua;$sdklua_src/test/?.lua"
export LD_LIBRARY_PATH="$OPENBUS_OPENSSL_HOME/lib"

case $sdklua_ver in
	"2.0"*) OPENBUS_SDKLUA_TEST="$OPENBUS_SANDBOX/build/openbus-lua-$sdklua_ver/test";;
esac

print_header "TEST" "Testing OpenBus Core $1"

cd $core_src/test

source runall.sh RELEASE

rm -fr $OPENBUS_SANDBOX
