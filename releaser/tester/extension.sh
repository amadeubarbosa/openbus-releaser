#!/bin/sh

source releaser/tester/utils.sh

assert_arg "$1" "extension.sh <extension version> <core version> [openssl version]"
assert_arg "$2" "extension.sh <extension version> <core version> [openssl version]"

installbase $2 $3

version=$1
installpack busextension $version
installsrc busextension $version openbus-busextension
installsrc busextension $version openbus-lua

for d in $OPENBUS_SANDBOX/build/openbus-lua-*; do
	[ -d "$d" ] && sdklua_ver="${d/$OPENBUS_SANDBOX\/build\/openbus\-lua\-/}" && break
done
if [ -z $sdklua_ver ]; then exit 1; fi

installpack lua52 $sdklua_ver

sdklua_src=$(ls -d $OPENBUS_SANDBOX/build/openbus-lua-*)
export OPENBUS_SDKLUA_HOME=$OPENBUS_SANDBOX/install/lua52-$sdklua_ver  # must be exported due to test
export OPENBUS_SDKLUA_TEST=$sdklua_src/test  # must be exported due to test

extension_src=$OPENBUS_SANDBOX/build/openbus-busextension-$version
export OPENBUS_GOVERNANCE_HOME=$OPENBUS_SANDBOX/install/busextension-$version
export OPENBUS_GOVERNANCE_TEST=$extension_src/test

print_header "TEST" "Testing Governance Extension Service"

cd $extension_src/test

source runall.sh RELEASE

rm -fr $OPENBUS_SANDBOX

