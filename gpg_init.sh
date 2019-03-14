#!/usr/bin/env bash
export GNUPGHOME=$(dirname $0)/data/volumes/home/.gnupg
test -d && rm -r $GNUPGHOME
mkdir -p $GNUPGHOME
GPG_BIN=$(which gpg2) || GPG_BIN=$(which gpg) || {
	echo "error gpg not found"
	exit 1
}

cat >$GNUPGHOME/batch <<EOF
	%echo Generating a basic OpenPGP key
	%no-ask-passphrase
	%no-protection
	Key-Type: DSA
	Key-Length: 1024
	Name-Real: Lorenz Werner
	Name-Comment: apt sign key
	Name-Email: apt@doublefun.net
	Expire-Date: 0
	# Do a commit here, so that we can later print "done" :-)
	%commit
	%echo done
EOF

$GPG_BIN --batch --gen-key $GNUPGHOME/batch
key=$($GPG_BIN --with-colons --keyid-format long --list-keys apt@doublefun.net | grep fpr | cut -d ':' -f 10)
$GPG_BIN --keyserver keyserver.ubuntu.com --send-keys $key
$GPG_BIN --output pubkey.gpg --armor --export $key
