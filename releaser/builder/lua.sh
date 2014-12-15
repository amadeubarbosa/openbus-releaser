#!/bin/sh

source releaser/builder/utils.sh

assert_arg "$1" "lua.sh <version>"

version=$1
name=lua52
modules="\
openbus-lua-$version \
openbus-busconsole-$version \
licenses-2013 \
"

if [[ $version == *"lua51"* ]]; then
	name=lua51
fi

# define a custom profile for 'makepack' to consume
assert_dir $OPENBUS_BUILD
echo "openbus-lua-$version +dependencies +dev
openbus-busconsole-$version
licenses-2013" > $OPENBUS_BUILD/$name

makepack $name $version "$modules"
