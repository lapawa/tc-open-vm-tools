#!/bin/ash
read -r <open-vm-tools.version TOOLS_VERSION
SRC="open-vm-tools-${TOOLS_VERSION}"

rm -rf $SRC
tar xfz $SRC.tar.gz

diff -rupN  $SRC/  $SRC-patched/ > $SRC.patch
