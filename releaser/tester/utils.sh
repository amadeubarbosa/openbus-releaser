#!/bin/sh

source releaser/setupenv.sh

function getpack {
	pack=$1
	platform=$2

	if [[ -n "$RELEASE_REPO" ]]; then
		pack=$RELEASE_REPO/$platform/$id/$pack
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
	# $3: platform
	# $4: destination path
	
	id=$1-$2
	platform=$3
	if [[ "$platform" == "" ]]; then
		platform="$TEC_UNAME"
	fi
	pack=openbus-$id-$platform.tar.gz
	dest=$4
	
	getpack $pack $platform

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
	# $4: platform
	# $5: destination path
	
	id=$1-$2
	platform=$4
	if [[ "$platform" == "" ]]; then
		platform="$TEC_UNAME"
	fi
	pack=openbus-$id-$platform-BUILD.tar.gz
	dest=$5
	
	getpack $pack $platform

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
