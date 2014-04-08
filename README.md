tc5-open-vm-tools
=================

Tools to build open-vm-tools for TinyCoreLinux 5.2

The fast track building instructions
------------------------------------
1. Boot a system with tcl5.2 and least 512MB of RAM.
1. Install tce package for git
```
    tce-load -iw git
```
1. Clone git repository with building instructions and tools
```
    git clone https://github.com/lapawa/tc5-open-vm-tools.git &&
    cd tc5-open-vm-tools
```
1. Prepare the tiny core machine for building the tools
```
   ./prepare-tcl-to-build.sh
```
This script will install additional tce packages and get the open-vm-tools tarball from sourceforge.net.
1. Change user to root.
```
    sudo -s
```
1. Start build script
    ./build-and-install.sh
1. Good luck
1. The build script will spit out two tinycore extensions:
   open-vm-tools.tcz
   and
   open-vm-tools-modules-KERNEL.tcz
  

Putting it al in one line
---------------------------
```
    tce-load -iw git && git clone https://github.com/lapawa/tc5-open-vm-tools.git && cd tc5-open-vm-tools && ./prepare-tcl-to-build.sh && sudo ./build-and-install.sh
```

Tested with these versions
-------------------------

- TinyCore      : v5.2 i686
  http://www.tinycorelinux.com
- open-vm-tools : 9.4.0-1208544
  http://open-vm-tools.sf.net
- linux kernel  : 3.8.13-tinycore
  The build script is kernel version independent and uses `uname -r` 
  to find kernel header files 


Build dependencies
------------------

 - git                # To clone repository from github.com/lapawa/tc5-open-vm-tools
 - compiletc          # this meta package pulls in a lot of necessary development tools
 - linux-kernel-sources-env # Installs the shell script /usr/local/bin/linux-kernel-sources-env.sh which will prepare kernel sources/headers
 - glibc_apps         # /usr/bin/rpcgen is in this packet
 - squashfs-tools-4.x # Tools to build the .tcz file
 - glib2-dev          # 
 - libtirpc-dev       # libary for remote procedure calls. The xdr_ datatype are define in there.
 - Xorg-7.7-dev
 - gtk2-dev           # because of a missing parameter in lib/appUtil/Makefile.am file it is not possible to compile with X and without gtk2 
 - libGL-dev          # gtk2 and cairo expect these header files.
 - gtkmm-dev  
 - fuse


Instructions used to configure
------------------------------

Set these environment variables before starting configure script:
```
    export RPCGENFLAGS="-Y /usr/local/bin"
    export CFLAGS="-march=i486 -mtune=i686 -Os -pipe -Wno-error=deprecated-declarations -I/usr/local/include/tirpci -DHAVE_TIRPC"
    export CXXFLAGS="-march=i486 -mtune=i686 -Os -pipe"
    export LDFLAGS="-Wl,-O1 -ltirpc"
```
  
Additional configure options:
 * --with-x 
 * --without-pam
 * --without-gtkmm
 * --without-procps
 * --without-dnet
 * --without-icu

   
Look into build-and-install.sh for details.

