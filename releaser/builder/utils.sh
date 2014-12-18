#!/bin/sh

source releaser/setupenv.sh

function makepack {
	name=$1
	version=$2
	modules=$3

	id=$name-$version
	print_header "BUILD" "Compiling $id"

	assert_dir $OPENBUS_BUILD

	PUTS_CONF=$OPENBUS_BUILD/puts.conf
	echo "BASEDIR = '$OPENBUS_BUILD'" > $PUTS_CONF

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

	release=
	if [[ "$version" != "" ]]; then
		release="--release=$version"
	fi

	$PUTS_BIN --config=$PUTS_CONF --makepack --profile=$profile $release \
		> $OPENBUS_BUILD/puts_makepack.out 2>&1
	assert_ok $?

	packbase=
	if [[ -n "$RELEASE_REPO" ]]; then
		print_header "BUILD" "Storing package $id on $RELEASE_REPO/$TEC_UNAME/$id"

		assert_dir $RELEASE_REPO/$TEC_UNAME/$id
		packbase=$RELEASE_REPO/$TEC_UNAME/$id/openbus-$id-$TEC_UNAME
		mv $OPENBUS_BUILD/packs/openbus-$id-$TEC_UNAME.tar.gz $packbase.tar.gz
		assert_ok $?
		tar -czf $packbase-BUILD.tar.gz -C $OPENBUS_BUILD .
		assert_ok $?
	fi
	if [[ -n "$RELEASE_SCP" ]]; then
		print_header "BUILD" "Storing package $id on $RELEASE_SCP"

		if [[ -z "$packbase" ]]; then
			packbase=$WORKSPACE/openbus-$id-$TEC_UNAME
			mv $OPENBUS_BUILD/packs/openbus-$id-$TEC_UNAME.tar.gz $packbase.tar.gz
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
			packbase=$WORKSPACE/openbus-$id-$TEC_UNAME
			mv $OPENBUS_BUILD/packs/openbus-$id-$TEC_UNAME.tar.gz $packbase.tar.gz
			assert_ok $?
			tar -czf $packbase-BUILD.tar.gz -C $OPENBUS_BUILD .
			assert_ok $?
		fi
		curl $RELEASE_CURL_PARAMS -T "$packbase{,-BUILD}.tar.gz" $RELEASE_CURL/
		assert_ok $?
	fi

	rm -fr $OPENBUS_BUILD
	assert_ok $?
}
