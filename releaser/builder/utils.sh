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

	assert_dir $RELEASE_REPO/$TEC_UNAME/$id

	print_header "BUILD" "Storing package $id"

	mv $OPENBUS_BUILD/packs/openbus-$id-$TEC_UNAME.tar.gz $RELEASE_REPO/$TEC_UNAME/$id
	assert_ok $?

	tar -czf $RELEASE_REPO/$TEC_UNAME/$id/build.tar.gz -C $OPENBUS_BUILD .
	assert_ok $?

	rm -fr $OPENBUS_BUILD
	assert_ok $?
}

