#!/bin/sh

source releaser/tester/utils.sh

assert_arg "$1" "interop.sh <core version> [...]"

installbase $1

export OPENBUS_TESTCFG=$OPENBUS_TEMP/test.properties

bus1port=21210
bus2port=21212
leasetime=5
passwordpenalty=10

echo "bus.host.port=$bus1port"                        >  $OPENBUS_TESTCFG
echo "bus2.host.port=$bus2port"                       >> $OPENBUS_TESTCFG
echo "bus.reference.path=$OPENBUS_TEMP/BUS01.ior"     >> $OPENBUS_TESTCFG
echo "bus2.reference.path=$OPENBUS_TEMP/BUS02.ior"    >> $OPENBUS_TESTCFG
echo "system.sharedauth=$OPENBUS_TEMP/sharedauth.dat" >> $OPENBUS_TESTCFG
echo "login.lease.time=$leasetime"                    >> $OPENBUS_TESTCFG
echo "password.penalty.time=$passwordpenalty"         >> $OPENBUS_TESTCFG
#echo "openbus.log.level=5"                           >> $OPENBUS_TESTCFG
#echo "openbus.test.verbose=yes"                      >> $OPENBUS_TESTCFG

OPENBUS_INTEROPCFG=$OPENBUS_TEMP/interop.cfg

adm_files=""
lua_packs="
  ['$1'] = {
    testprops = [[$OPENBUS_TESTCFG]],
    adminbin = [[$OPENBUS_CORE_HOME/bin/busadmin]],
    consolebin = [[$OPENBUS_CORESDKLUA_HOME/bin/busconsole]],
    interopdir = [[$coresdklua_src/interop]],
    sdktestdir = [[$coresdklua_src/test]],
  },"
java_packs=""
test_releases=""

for pack in $2 $3 $4 $5 $6 $7 $8 $9; do
	case $pack in
		"lua52-"*)
			lua_ver=52
			sdklua_ver=${pack/lua52\-/}
			installpack lua$lua_ver $sdklua_ver
			installsrc lua$lua_ver $sdklua_ver openbus-lua
			sdklua_src=$OPENBUS_SANDBOX/build/openbus-lua-$sdklua_ver
			sdklua_dir=$OPENBUS_SANDBOX/install/lua$lua_ver-$sdklua_ver  # must be exported due to interop. test
			lua_packs="$lua_packs
  ['$sdklua_ver'] = {
    testprops = [[$OPENBUS_TESTCFG]],
    adminbin = [[$OPENBUS_CORE_HOME/bin/busadmin]],
    consolebin = [[$sdklua_dir/bin/busconsole]],
    interopdir = [[$sdklua_src/interop]],
    sdktestdir = [[$sdklua_src/test]],
  },"
			adm_files="$adm_files $sdklua_src/interop/script.adm"
			test_releases="$test_releases 'lua-$sdklua_ver',"
			;;
		"java-"*)
			sdkjava_ver=${pack/java\-/}
			installsrc java $sdkjava_ver openbus-java jre6
			sdkjava_src=$OPENBUS_SANDBOX/build/openbus-java-$sdkjava_ver
			java_packs="$java_packs
  ['$sdkjava_ver'] = {
    testprops = [[$OPENBUS_TESTCFG]],
    jrebin = [[`which java`]],
    interopdir = [[$sdkjava_src/interop]],
  },"
			for file in $sdkjava_src/interop/*/admin/*.adm; do
				adm_files="$adm_files $file"
			done
			test_releases="$test_releases 'java-$sdkjava_ver',"
	esac 
done

echo "
setups = {buscleaner=[[lua-$1]]}
lua = { $lua_packs }
java = { $java_packs }
releases = { $test_releases }
" > $OPENBUS_INTEROPCFG

print_header "TEST" "Testing SDK Interoperability"

runbus="source ${OPENBUS_CORE_TEST}/runbus.sh RELEASE"
runadmin="source ${OPENBUS_CORE_TEST}/runadmin.sh RELEASE"

export OPENBUS_CONFIG=/local/openbus/maia/releaser/git/openbus.cfg

$runbus BUS01 $bus1port
$runbus BUS02 $bus2port
genkey $OPENBUS_TEMP/testsyst

for adm in $adm_files; do
	dirpath=${adm%/*}
	script=${adm##*/}
	pushd $dirpath
	$runadmin localhost $bus1port --script=$script
	$runadmin localhost $bus2port --script=$script
	popd
done

$INTEROP_RUN $OPENBUS_INTEROPCFG
assert_ok $?

#for adm in $adm_files; do
#	dirpath=${adm%/*}
#	script=${adm##*/}
#	pushd $dirpath
#	$runadmin localhost $bus1port --undo-script=$script
#	$runadmin localhost $bus2port --undo-script=$script
#	popd
#done

rm -fr $OPENBUS_SANDBOX

