#!/bin/sh

source releaser/builder/utils.sh

assert_arg "$1" "openssl.sh <version>"

name=openssl
version=$1

makepack $name $version "$name-$version"
