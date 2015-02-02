#!/bin/sh

source releaser/tester/utils.sh

assert_arg "$1" "core.sh <core version> [openssl version]"

installbase $1 $2

export OPENBUS_CORE_HOME=$OPENBUS_CORE_HOME # must be exported due to 'busadmin' test
export OPENBUS_CORE_TEST=$OPENBUS_CORE_TEST # must be exported due to 'busadmin' test

print_header "TEST" "Testing OpenBus Core $1"

cd $core_src/test

source runall.sh RELEASE

rm -fr $OPENBUS_SANDBOX

