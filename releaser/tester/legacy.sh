#!/bin/sh

source releaser/tester/utils.sh

assert_arg "$1" "legacy.sh <core version> <legacy core> <legacy sdklua> [openssl version]"
assert_arg "$2" "legacy.sh <core version> <legacy core> <legacy sdklua> [openssl version]"
assert_arg "$3" "legacy.sh <core version> <legacy core> <legacy sdklua> [openssl version]"

installbase $1 $4

legacycore_ver=$2
installsrc core $legacycore_ver openbus-busservice

legacysdklua_ver=$3
installpack lua52 $legacysdklua_ver
installsrc lua52 $legacysdklua_ver openbus-lua

legacycore_src=$OPENBUS_SANDBOX/build/openbus-busservice-$legacycore_ver
legacysdklua_src=$OPENBUS_SANDBOX/build/openbus-lua-$legacysdklua_ver
OPENBUS_LEGACYSDKLUA_HOME=$OPENBUS_SANDBOX/install/lua52-$legacysdklua_ver
OPENBUS_LEGACYSDKLUA_TEST=$legacysdklua_src/test

print_header "TEST" "Testing Core Legacy Support"

cd $legacycore_src/test

source runlegacy.sh RELEASE

rm -fr $OPENBUS_SANDBOX

