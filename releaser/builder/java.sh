#!/bin/sh

source releaser/builder/utils.sh

assert_arg "$1" "java.sh <version> <jdk label>"

version=$1
platform=$2
name=java
modules="\
openbus-java-$version \
licenses-2013 \
"
if [ "$platform" == "" ]; then
  platform="jre6"
fi

# define a custom profile for 'makepack' to consume
assert_dir $OPENBUS_BUILD
echo "openbus-java-$version +dependencies +dev
licenses-2013" > $OPENBUS_BUILD/$name

makepack $name $version "$modules" $platform
