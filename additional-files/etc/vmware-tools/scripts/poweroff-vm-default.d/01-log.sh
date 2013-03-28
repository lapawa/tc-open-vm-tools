#!/bin/sh
echo "execution of $0 at `date`" >> /tmp/vmware-user-script.log
filetool.sh -b
poweroff


