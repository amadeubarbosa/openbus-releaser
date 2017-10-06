#!/bin/sh

source releaser/builder/utils.sh

assert_arg "$1" "extension.sh <version>"

version=$1
modules="\
openbus-busextension-$version \
licenses-2013 \
"

makepack busextension $version "$modules"
