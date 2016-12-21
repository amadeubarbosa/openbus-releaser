#!/bin/sh

source releaser/tester/utils.sh

assert_arg "$1" "collab.sh <collab version> <core version> [openssl version]"
assert_arg "$2" "collab.sh <collab version> <core version> [openssl version]"

installbase $2 $3

collab_ver=$1
installpack collab $collab_ver
installsrc collab $collab_ver collaboration-service 

collab_src=$OPENBUS_SANDBOX/build/collaboration-service-$collab_ver
export OPENBUS_COLLAB_HOME=$OPENBUS_SANDBOX/install/collab-$collab_ver
export OPENBUS_COLLAB_TEST=$collab_src/test

print_header "TEST" "Testing Collab Service"

cd $collab_src/test

source runall.sh RELEASE

rm -fr $OPENBUS_SANDBOX

