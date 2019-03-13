#!/usr/bin/env bash
FIGLET=$(which figlet) || FIGLET=cat
echo "Welcome to Docker Debuilder" | $FIGLET

export PATH=/usr/lib/ccache:$PATH
export GNUPGHOME
export CCACHE_DIR
export CCACHE_CONFIGPATH
export DEBSIGN_KEYID
export DEBRELEASE_DEBS_DIR
export TARGET_RELEASE

export CPPFLAGS=$(dpkg-buildflags --get CPPFLAGS)
export CFLAGS=$(dpkg-buildflags --get CFLAGS)
export CXXFLAGS=$(dpkg-buildflags --get CXXFLAGS)
export LDFLAGS=$(dpkg-buildflags --get LDFLAGS)

if [ $# -gt 0 ]; then
	echo "starting user cmd"
	/bin/bash -c "$*"
	exit
fi

for dir in src/*; do
	mkdir -p /build/srv/_debs
	[ "_debs" = "$dir" ] && continue
	test -d "${dir}" || continue
	echo building $dir | $FIGLET
	pushd "${dir}"
	#debuild -b -uc -us -i -I --no-sign
	debuild -i -I --lintian-opts -i --default-display-level
	popd
done
