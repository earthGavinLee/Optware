#!/bin/sh
BSDIR="/volume1/tmp/ipkg-bootstrap"

echo "Creating temporary ipkg repository..."
rm -rf $BSDIR
mkdir -p $BSDIR
ln -s $BSDIR /tmp/ipkg
cat >>$BSDIR/ipkg.conf <<EOF
dest root /
lists_dir ext /$BSDIR/ipkg
EOF

export IPKG_CONF_DIR=$BSDIR 
export IPKG_DIR_PREFIX=$BSDIR 

echo "Installing DS101(g)-bootstrap package..."
mkdir -p /usr/lib/ipkg/info/
sh ./ipkg.sh install bootstrap.ipk

echo "Installing IPKG package... (Ignore missing md5sum warning)"
sh ./ipkg.sh install ipkg.ipk

echo "Removing temporary ipkg repository..."
rm -rf $BSDIR
rm /tmp/ipkg
rm -rf /usr/lib/ipkg

echo "Instaling OpenSSL.."
/opt/bin/ipkg install openssl.ipk || exit 1

echo "Instaling wget-SSL..."
/opt/bin/ipkg install wget-ssl.ipk || exit 1

[ ! -d /opt/etc/ipkg ] && mkdir -p /opt/etc/ipkg
if [ ! -e /opt/etc/ipkg/cross-feed.conf ]
then
	echo "Creating /opt/etc/ipkg/cross-feed.conf..."
	ARCH=`uname -m`
	if [ "$ARCH" = "ppc" ]; then
		echo "src/gz cross http://ipkg.nslu2-linux.org/feeds/optware/ds101g/cross/stable" >/opt/etc/ipkg/cross-feed.conf
	else
		echo "src/gz cross http://ipkg.nslu2-linux.org/feeds/optware/ds101/cross/stable" >/opt/etc/ipkg/cross-feed.conf
	fi
fi

echo "Setup complete..."
