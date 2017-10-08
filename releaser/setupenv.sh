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
LUA52_BIN=$LUA52/bin/${TEC_UNAME}/lua52
RELEASE_REPO=${RELEASE_REPO:=$WORKSPACE/releases}
#RELEASE_SCP=openbus@macumba:/local/openbus/releases
#RELEASE_CURL=ftp://ftp-pub.tecgraf.puc-rio.br/openbus/releases
#RELEASE_CURL_PARAMS=--ftp-ssl --insecure --user openbus:<senha>
OPENBUS_BUILD=$WORKSPACE/build
OPENBUS_SANDBOX=$WORKSPACE/sandbox
LFS_HOME=$WORKSPACE/luafilesystem
LFS_LDIR=$LFS_HOME/install/lib
PUTS_HOME=$WORKSPACE/puts
PUTS_BIN="$LUA51_BIN -epackage.cpath=[[$LFS_LDIR/lib?.so]] -epackage.path=[[$PUTS_HOME/lua/?.lua]] $PUTS_HOME/lua/tools/console.lua"
LOSKI_HOME=$WORKSPACE/loski
RUNNER_HOME=$WORKSPACE/interop-runner
INTEROP_RUN="$LUA52_BIN -epackage.path=[[$RUNNER_HOME/lua/?.lua]] -epackage.cpath=[[$LFS_HOME/lib/${TEC_UNAME}/lib?.so;$LOSKI_HOME/src/?.so]] $RUNNER_HOME/lua/runall.lua"
