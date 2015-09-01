#!/bin/sh

#
# set some environment variables
#

# version number of vmware tools and source package
read -r <open-vm-tools.version TOOLS_VERSION
SRC="open-vm-tools-${TOOLS_VERSION}"
TCL_VERSION=`/usr/bin/version`

# output
TCZ="open-vm-tools.tcz"
EXT_MODULES="open-vm-tools-modules-$(uname -r)"  # extension name for the vmware tools kernel modules
TCZ_MODULES="${EXT_MODULES}.tcz"

# List of packages created by this script
BUILD_PKGS="${TCZ} ${TCZ_MODULES}"
# List of filename extensions belonging to a tinycorelinux package
PKG_EXTS=".dep .list .md5.txt"

# ISO image created by this script
ISOIMAGE="${PWD}/tcl${TCL_VERSION}-vmw-${TOOLS_VERSION}.iso"

# temporary files
INSTDIR="/tmp/open-vm-tools-inst"
INSTDIR_MODULES="/tmp/$EXT_MODULES"

# directory with overlay files added to the package
ADDITIONAL="additional-files"  
# location of remastering script
REMASTER=`which remaster.sh`
APPBROWSER='/etc/sysconfig/tcedir/optional'
CONFIGFLAGS="--with-x --without-xerces --disable-deploypkg --without-pam --without-gtkmm --without-procps --without-icu"
NUMCPUS=`cat /proc/cpuinfo|grep processor|wc | cut -b 9`
MAKEFLAGS="-j$(( ${NUMCPUS} +1 ))"

KEEP=0
   
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
    -k)
      echo "Option $i set. Keeping temporary files."
      KEEP=1
      shift;;
  esac
done

   
##
##  Test for directories and files from previous runs
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
if [ -r "${SRC}.patch" ]; then
  echo "### apply patch $SRC.patch"
  patch -p0 < $SRC.patch
fi

cd $SRC


# configure, make, make install
export RPCGENFLAGS="-Y /usr/local/bin"
export CFLAGS="-march=i486 -mtune=i686 -Os -pipe -Wno-error=deprecated-declarations -DHAVE_TIRPC -I/usr/local/include/tirpc"
export CXXFLAGS="-march=i486 -mtune=i686 -Os -pipe"
export LDFLAGS="-Wl,-O1 -L/usr/local/lib -ltirpc"

echo "## configure $CONFIGFLAGS"
/bin/sh configure $CONFIGFLAGS
echo "## make $MAKEFLAGS"
make $MAKEFLAGS

mkdir "${INSTDIR}"
make DESTDIR=${INSTDIR} install-strip
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

# create dummy dependencies file for kernel modules
touch "${TCZ_MODULES}.dep"

##
## copy extension to persistance datastore if exists
##
if [ -d "$APPBROWSER" ]; then
    for PKG in $BUILD_PKGS; do
      cp "$PKG" "${APPBROWSER}/"
      for EXT in $PKG_EXTS; do
          cp "${PKG}${EXT}" "${APPBROWSER}/"
      done
    done
fi

# clean up
if [ -n "$KEEP" ]
then
  echo -n 'Cleaning up temporary files...'
  rm -r $SRC
  rm -r $INSTDIR
  rm -r $INSTDIR_MODULES
  echo 'done'
  
else
  echo 'Skipping deletion of temporary files.'
fi


# build iso image 
if [ -r ezremaster.cfg -a -x "$REMASTER" ]; then
        grep sr0 /etc/mtab > /dev/null
        if [ $? -ne 0 ];
        then
		mount /mnt/sr0
        fi

	echo 'Creating iso image...'
	$REMASTER `pwd`/ezremaster.cfg rebuild
	mv /tmp/ezremaster/ezremaster.iso "${ISOIMAGE}"
else
	echo "Skipping iso image creation due to missing config file 'ezremaster.cfg'"

fi

