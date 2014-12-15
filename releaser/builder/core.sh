#!/bin/sh

source releaser/builder/utils.sh

assert_arg "$1" "core.sh <version>"

version=$1
modules="\
openbus-busservice-$version \
openbus-busadmin-$version \
licenses-2013 \
"

makepack core $version "$modules"
