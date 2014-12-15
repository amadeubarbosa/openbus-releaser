#!/bin/sh

function assert_ok {
	if [ $1 -ne 0 ]; then
		exit $1
	fi
}

function assert_dir {
	if [[ ! -d $1 ]]; then
		mkdir -p $1
	fi
}

function assert_arg {
	if [[ "$1" == "" ]]; then
		echo "Usage: $2"
		exit 1
	fi
}

function print_header {
	echo "========================================================================"
	echo "[ $1 ] $2"
	echo ""
}

if [[ "$WORKSPACE" == "" ]]; then
	WORKSPACE=`pwd`
fi

LUA51_BIN=$LUA51/bin/$TEC_UNAME/lua5.1
RELEASE_REPO=$WORKSPACE/releases
OPENBUS_BUILD=$WORKSPACE/build
OPENBUS_SANDBOX=$WORKSPACE/sandbox
PUTS_HOME=$WORKSPACE/puts
PUTS_BIN="$LUA51_BIN -epackage.path=[[$PUTS_HOME/lua/?.lua]] $PUTS_HOME/lua/tools/console.lua"
