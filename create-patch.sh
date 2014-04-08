#!/bin/ash
SRC=open-vm-tools-9.4.0-1280544

rm -rf $SRC
tar xfz $SRC.tar.gz

diff -rupN  $SRC/  $SRC-patched/ > $SRC.patch
