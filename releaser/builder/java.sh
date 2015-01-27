#!/bin/sh

source releaser/builder/utils.sh

assert_arg "$1" "java.sh <version>"

version=$1
name=java
modules="\
openbus-java-$version \
licenses-2013 \
"
jre="jre6"

# define a custom profile for 'makepack' to consume
assert_dir $OPENBUS_BUILD
echo "openbus-java-$version +dependencies +dev
licenses-2013" > $OPENBUS_BUILD/$name

makepack $name $version "$modules" $jre
