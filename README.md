tc4-open-vm-tools
=================

Tools to build open-vm-tools for TinyCoreLinux 4.x

TinyCore      : 4.7.5
open-vm-tools : 9.2.2-893683
linux kernel  : 3.0.21-tinycore


Required extensions to build:
  compiletc          # this meta package pulls in a lot of necessary development tools
  linux-headers-3.0.21-tinycore # /usr/include/asm header files
  eglibc_apps        # /usr/bin/rpcgen is in this packet
  glib2-dev          # 
  Xorg-7.6-dev
  gtk2-dev           # because of a missing parameter in lib/appUtil/Makefile.am file it is not possible to compile with X and wihtout gtk2 
  gtkmm-dev  
  fuse

Set these environment variables before starting configure script:
  export RPCGENFLAGS="-Y /usr/local/bin"
  export CFLAGS="-march=i486 -mtune=i686 -Os -pipe -Wno-error=deprecated-declarations"
  export CXXFLAGS="-march=i486 -mtune=i686 -Os -pipe"
  export LDFLAGS="-Wl,-O1"
  
Additional configure options:
  * --without-x
  * --without-gtk2
  * --without-pam
  * --without-gtkmm
  * --without-procps
  * --without-dnet
  * --without-icu
  * --prefix=/usr/local
   
Have a look in to build-and-install.sh for detailed instructions

   
sudo make DESTDIR=/tmp/open-vm-tools install-strip

