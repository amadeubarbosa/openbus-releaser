#!/bin/sh

source releaser/setupenv.sh

function makepack {
	local name=$1
	local version=$2
	local modules=$3
	local platform=$4

	id=$name-$version
	print_header "BUILD" "Compiling $id"

	assert_dir $LFS_HOME

	PUTS_CONF=$LFS_HOME/puts.conf
	echo "BASEDIR = '$LFS_HOME' " > $PUTS_CONF

	$PUTS_BIN --config=$PUTS_CONF --compile --update --force \
		  --select="luafilesystem-1.4.2lua51snapshot" \
		  > $LFS_HOME/puts_compile.out 2>&1
	assert_ok $?

	assert_dir $OPENBUS_BUILD

	PUTS_CONF=$OPENBUS_BUILD/puts.conf
	echo "BASEDIR = '$OPENBUS_BUILD' " > $PUTS_CONF

	$PUTS_BIN --config=$PUTS_CONF --compile --update --force --select="$modules" \
		> $OPENBUS_BUILD/puts_compile.out 2>&1
	assert_ok $?

	print_header "BUILD" "Packing $id"

	profile=$OPENBUS_BUILD/$name
	if [ ! -f $profile ]; then
		for package in $modules; do
			echo "$package" >> $profile
			assert_ok $?
		done
	fi

	local release=
	if [[ "$version" != "" ]]; then
		release="--release=$version"
	fi

	local arch=$TEC_UNAME
	if [[ "$platform" != "" ]]; then
		arch="$platform"
	fi

	$PUTS_BIN --config=$PUTS_CONF --makepack --profile=$profile $release --arch=$arch \
		> $OPENBUS_BUILD/puts_makepack.out 2>&1
	assert_ok $?

	local packbase=
	if [[ -n "$RELEASE_REPO" ]]; then
		print_header "BUILD" "Storing package $id on $RELEASE_REPO/$arch/$id"

		assert_dir $RELEASE_REPO/$arch/$id
		packbase=$RELEASE_REPO/$arch/$id/openbus-$id-$arch
		mv $OPENBUS_BUILD/packs/openbus-$id-$arch.tar.gz $packbase.tar.gz
		assert_ok $?
		tar -czf $packbase-BUILD.tar.gz -C $OPENBUS_BUILD .
		assert_ok $?
	fi
	if [[ -n "$RELEASE_SCP" ]]; then
		print_header "BUILD" "Storing package $id on $RELEASE_SCP"

		if [[ -z "$packbase" ]]; then
			packbase=$WORKSPACE/openbus-$id-$arch
			mv $OPENBUS_BUILD/packs/openbus-$id-$arch.tar.gz $packbase.tar.gz
			assert_ok $?
			tar -czf $packbase-BUILD.tar.gz -C $OPENBUS_BUILD .
			assert_ok $?
		fi
		scp $packbase{,-BUILD}.tar.gz $RELEASE_SCP
		assert_ok $?
	fi
	if [[ -n "$RELEASE_CURL" ]]; then
		print_header "BUILD" "Storing package $id on $RELEASE_CURL"

		if [[ -z "$packbase" ]]; then
			packbase=$WORKSPACE/openbus-$id-$arch
			mv $OPENBUS_BUILD/packs/openbus-$id-$arch.tar.gz $packbase.tar.gz
			assert_ok $?
			tar -czf $packbase-BUILD.tar.gz -C $OPENBUS_BUILD .
			assert_ok $?
		fi
		curl $RELEASE_CURL_PARAMS -T "$packbase{,-BUILD}.tar.gz" $RELEASE_CURL/
		assert_ok $?
	fi

	rm -fr $LFS_HOME
	rm -fr $OPENBUS_BUILD
	assert_ok $?
}
