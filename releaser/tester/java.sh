#!/bin/sh

source releaser/tester/utils.sh

assert_arg "$1" "java.sh <sdk-java version> <core version> [platform] [openssl version]"
assert_arg "$2" "java.sh <sdk-java version> <core version> [platform] [openssl version]"

sdkjava_ver=$1
core_ver=$2
platform=$3
if [[ "$platform" == "" ]]; then
	platform=jre6
fi
ssl_ver=$4
if [[ "$ssl_ver" == "" ]]; then
	ssl_ver=1.0.0m
fi


installsrc java $sdkjava_ver openbus-java $platform
installsrc core $core_ver openbus-busservice

installsrc core $core_ver openbus-lua
for d in $OPENBUS_SANDBOX/build/openbus-lua-*; do
	[ -d "$d" ] && sdklua_ver="${d/$OPENBUS_SANDBOX\/build\/openbus\-lua\-/}" && break
done

# TODO assert $sdklua_ver

core_src=$OPENBUS_SANDBOX/build/openbus-busservice-$core_ver
sdklua_src=$OPENBUS_SANDBOX/build/openbus-lua-$sdklua_ver
sdkjava_src=$OPENBUS_SANDBOX/build/openbus-java-$sdkjava_ver

installpack openssl $ssl_ver
installpack java $sdkjava_ver $platform
# TODO only needed if version != 2.1
case $sdklua_ver in
	"2.0"*)
	 	installpack lua52 $sdklua_ver
	 	OPENBUS_SDKLUA_HOME=$OPENBUS_SANDBOX/install/lua52-$sdklua_ver # runbus.sh runadmin.sh --> busconsole
	 	;;
esac
installpack core $core_ver

OPENBUS_OPENSSL_HOME=$OPENBUS_SANDBOX/install/openssl-$ssl_ver
export LD_LIBRARY_PATH="$OPENBUS_OPENSSL_HOME/lib"
#export OPENBUS_SDKJAVA_HOME=$OPENBUS_SANDBOX/install/java-$sdkjava_ver  # must be exported due to interop. test
OPENBUS_CORE_HOME=$OPENBUS_SANDBOX/install/core-$core_ver # runbus.sh runadmin.sh --> busservies busamin
OPENBUS_CORE_TEST="$core_src/test" # runall.sh --> runbus.sh runadmin.sh
export LUA_PATH="$core_src/test/?.lua;$sdklua_src/test/?.lua"


print_header "TEST" "Testing SDK-Java"

cd $sdkjava_src/core/src/test

source runall.sh RELEASE

rm -fr $OPENBUS_SANDBOX
