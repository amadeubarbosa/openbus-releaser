#!/bin/sh

source releaser/setupenv.sh

function getpack {
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
	
	local id=$1-$2
	local platform=$3
	if [[ "$platform" == "" ]]; then
		platform="$TEC_UNAME"
	fi
	local pack=openbus-$id-$platform.tar.gz
	local dest=$4
	
	getpack

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
	
	local id=$1-$2
	local platform=$4
	if [[ "$platform" == "" ]]; then
		platform="$TEC_UNAME"
	fi
	local pack=openbus-$id-$platform-BUILD.tar.gz
	local dest=$5
	local pack
	
	getpack

	if [[ $dest == "" ]]; then
		dest=$OPENBUS_SANDBOX
	fi
	assert_dir $dest

	print_header "TEST" "Recovering source of $3 @ $id"

	if [[ "$TEC_SYSNAME" == "Darwin" ]] || [[ "$TEC_SYSNAME" == "MacOS" ]]; then
		tar -xzf $pack -C $dest ./build/$3*
	else
		tar -xzf $pack -C $dest --wildcards ./build/$3*
	fi
	assert_ok $?
}

function installbase {
	core_ver=$1
	ssl_ver=$2
	if [[ "$ssl_ver" == "" ]]; then
		ssl_ver=1.0.0m
	fi
	
	installsrc core $core_ver openbus-busservice
	installsrc core $core_ver openbus-lua
	
	protocol_ver=${core_ver:0:3}
	for d in $OPENBUS_SANDBOX/build/openbus-lua-$protocol_ver*; do
		[ -d "$d" ] && coresdklua_ver="${d/$OPENBUS_SANDBOX\/build\/openbus\-lua\-/}" && break
	done
	# TODO assert $coresdklua_ver
	
	core_src=$OPENBUS_SANDBOX/build/openbus-busservice-$core_ver
	coresdklua_src=$OPENBUS_SANDBOX/build/openbus-lua-$coresdklua_ver
	
	installpack openssl $ssl_ver
	installpack core $core_ver
	case $core_ver in
		"2.0"* | "2.1.0.0rc1")
			installpack lua52 $coresdklua_ver
			export OPENBUS_CORESDKLUA_HOME=$OPENBUS_SANDBOX/install/lua52-$coresdklua_ver # runconsole.sh --> busconsole
			;;
	esac
	
	OPENBUS_OPENSSL_HOME=$OPENBUS_SANDBOX/install/openssl-$ssl_ver
	export OPENBUS_CORE_HOME=$OPENBUS_SANDBOX/install/core-$core_ver # runbus.sh runadmin.sh --> busservies busamin
	export OPENBUS_CORE_TEST=$core_src/test # runbus.sh -> validators
	export OPENBUS_CORESDKLUA_TEST=$coresdklua_src/test # run*.sh --> runconsole.sh | runadmin.sh -> openbus.test.*
}

export OPENBUS_TEMP=$OPENBUS_SANDBOX/temp
assert_dir $OPENBUS_TEMP
