#!/bin/sh

source releaser/setupenv.sh

function getpack {
	pack=$1
	if [[ -n "$RELEASE_REPO" ]]; then
		pack=$RELEASE_REPO/$TEC_UNAME/$id/$pack
	fi
	if [[ -n "$RELEASE_SCP" ]]; then
		scp $RELEASE_SCP/$pack $OPENBUS_TEMP
		assert_ok $?
		pack=$OPENBUS_TEMP/$pack
	fi
	if [[ -n "$RELEASE_CURL" ]]; then
		# RELEASE_CURL_PARAMS=--ftp-ssl --insecure --user openbus:senha
		curl $RELEASE_CURL_PARAMS $RELEASE_CURL/$pack -o $OPENBUS_TEMP/$pack
		assert_ok $?
		pack=$OPENBUS_TEMP/$pack
	fi
}

function installpack {
	# $1: profile name
	# $2: release name
	# $3: destination path

	id=$1-$2
	pack=openbus-$id-$TEC_UNAME.tar.gz
	dest=$3

	getpack $pack

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
	pack=openbus-$id-$TEC_UNAME-BUILD.tar.gz
	dest=$4

	getpack $pack

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
