#!/bin/sh

source releaser/builder/utils.sh

assert_arg "$1" "collab.sh <version>"

version=$1
modules="\
collaboration-service-$version \
licenses-2013 \
"

makepack collab $version "$modules"
