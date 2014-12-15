#!/bin/sh

source releaser/setupenv.sh

function installpack {
	# $1: profile name
	# $2: release name
	# $3: destination path

	id=$1-$2
	pack=$RELEASE_REPO/$TEC_UNAME/$id/openbus-$id-$TEC_UNAME.tar.gz
	dest=$3

	if [[ $dest == "" ]]; then
		dest=$OPENBUS_SANDBOX/install/$id
	fi

	assert_dir $dest

	print_header "TEST" "Unpacking $1"

	#$PUTS_BIN --installer --package=$pack --path=$dest
	tar -xzf $pack -C $dest
	assert_ok $?
}

function installsrc {
	# $1: profile name
	# $2: release name
	# $3: product name
	# $4: destination path

	id=$1-$2
	pack=$RELEASE_REPO/$TEC_UNAME/$id/build.tar.gz
	dest=$4

	if [[ $dest == "" ]]; then
		dest=$OPENBUS_SANDBOX
	fi

	assert_dir $dest

	print_header "TEST" "Recovering source of $3 @ $id"

	tar -xzf $pack -C $dest ./build/$3*
	assert_ok $?
}

OPENBUS_TEMP=$OPENBUS_SANDBOX/temp
assert_dir $OPENBUS_TEMP

