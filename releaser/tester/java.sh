#!/bin/sh

source releaser/tester/utils.sh

assert_arg "$1" "java.sh <sdk-java version> <core version> [platform] [openssl version]"
assert_arg "$2" "java.sh <sdk-java version> <core version> [platform] [openssl version]"

installbase $2 $4

sdkjava_ver=$1
platform=$3
if [[ "$platform" == "" ]]; then
	platform=jre6
fi

installpack java $sdkjava_ver $platform
installsrc java $sdkjava_ver openbus-java $platform

print_header "TEST" "Testing SDK-Java"

cd $OPENBUS_SANDBOX/build/openbus-java-$sdkjava_ver/core/src/test

source runall.sh RELEASE

rm -fr $OPENBUS_SANDBOX
