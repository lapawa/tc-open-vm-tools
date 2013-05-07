#!/bin/sh

#
# configure file locations
#
SRC="open-vm-tools-9.2.3-1031360"
TCZ="open-vm-tools.tcz"
EXT_MODULES="open-vm-tools-modules-$(uname -r)"  # extension name for the vmware tools kernel modules
TCZ_MODULES="$EXT_MODULES.tcz"
INSTDIR="/tmp/open-vm-tools-inst"
INSTDIR_MODULES="/tmp/$EXT_MODULES"
ADDITIONAL="additional-files"  
REMASTER=`which remaster.sh`
   
##
## process command line parameters
##
args=`getopt f $*`
if [ $? != 0 ]; then
  echo 'Usage:  build.sh [-f]'
  echo '        -f  force overwrite of existing files.'
  exit 2
fi
set -- $args
for i
do
  case "$i"
  in
    -f)
      echo "Option $i set. Overwrite of existing files enforced."
      FORCE=1
      shift;;
    esac
done

   
##
##  Test for directories and old files from last run
##

# test existance of open-vm-tools tarball
for F in $SRC.tar.gz $ADDITIONAL
do
  if [ ! -f "$SRC.tar.gz" ]; then
    echo "Source package $F is not in current directory. exit(1)"
    exit 1
  fi
done

# check for already existing files and ask for -f option.
for T in "$TCZ" "$TCZ_MODULES" "$INSTDIR" "$INSTDIR_MODULES" ; do
  if [ -e $T ]; then
    echo -n "Found '$T' from previous run. => "
    if [ $FORCE ]; then
      echo "rm -r '$T'"
      rm -r "$T"
    else
      echo "Use option -f to overwrite or move file away. exit(3)"
      exit 3
    fi
  fi
done


##
##  Start compiling the source package
##
set -e

# extract source archive
tar xfz $SRC.tar.gz
cd $SRC


# configure, make, make install
export RPCGENFLAGS="-Y /usr/local/bin"
export CFLAGS="-march=i486 -mtune=i686 -Os -pipe -Wno-error=deprecated-declarations"
export CXXFLAGS="-march=i486 -mtune=i686 -Os -pipe"
export LDFLAGS="-Wl,-O1"

./configure --with-x --without-pam --without-gtkmm --without-procps --without-dnet --without-icu 
make
mkdir $INSTDIR
make DESTDIR=$INSTDIR install-strip
cd ..


##
##  Cleanup and remove unneccessary files 
##

#  these directories are relevant for -dev extension
find "$INSTDIR" -type d -name pkgconfig -print | xargs rm -r
find "$INSTDIR" -type d -name include   -print | xargs rm -r
# language packs
find "$INSTDIR" -type d -name messages  -print | xargs rm -r

# This script relies on several OS scripts and is not working with TinyCore
rm "$INSTDIR/etc/vmware-tools/scripts/vmware/network"


##
##  Create tcz extensions
##

# build extension for kernel modules
mkdir -p "$INSTDIR_MODULES/usr/local/"
mv "$INSTDIR/lib" "$INSTDIR_MODULES/usr/local"
mksquashfs "$INSTDIR_MODULES" "$TCZ_MODULES" -noappend 
md5sum "$TCZ_MODULES" > "$TCZ_MODULES.md5.txt"


# move some directories into usr/local
mkdir -p $INSTDIR/usr/local/etc/init.d
mv $INSTDIR/etc/* $INSTDIR/usr/local/etc/
rm -r $INSTDIR/etc

rm -r $INSTDIR/sbin

# add additional tinycore specific file to installation directory
#rsync -rlpv --executability "$ADDITIONAL/" $INSTDIR/usr/local
#tar -xf $ADDITIONAL -C $INSTDIR/usr/local
cp -ra $ADDITIONAL/* $INSTDIR/usr/local/

#cp $INIT $INSTDIR/usr/local/etc/init.d/open-vm-tools
chmod +x $INSTDIR/usr/local/etc/init.d/open-vm-tools
# set suid flag on vmware-user-suid-wrapper
chmod +s $INSTDIR/usr/local/bin/vmware-user-suid-wrapper


##
## create tinycore extension 'open-vm-tools' with md5sum file
##
mksquashfs $INSTDIR $TCZ -noappend 
md5sum $TCZ > $TCZ.md5.txt


##
## create list files
##
WD=`pwd`
cd "$INSTDIR"
find usr -not -type d > "$WD/$TCZ.list"
cd "$INSDIR_MODULES"
find usr -not -type d > "$WD/$TCZ_MODULES.list"
cd "$WD"


##
## copy extension to persistance datastore if exists
##
if [ -d /etc/sysconfig/tcedir/optional/ ]; then
    cp "$TCZ" "$APPBROWSER/"
    cp "$TCZ_MODULES" "$APPBROWSER/"
fi

# clean up
echo 'Cleaning up temporary files...'
rm -r $SRC
rm -r $INSTDIR
rm -r $INSTDIR_MODULES


# build iso image 
if [ -r ezremaster.cfg -a -x "$REMASTER" ]; then
	echo 'Creating iso image...'
	$REMASTER `pwd`/ezremaster.cfg rebuild
	mv /tmp/ezremaster/ezremaster.iso `pwd`/tcl4-vmw-9-2-3.iso
fi


