tc4-open-vm-tools
=================

Tools to build open-vm-tools for TinyCoreLinux 4.x

The fast track building instructions
------------------------------------
1. Boot a system with tcl4
2. Install build depencies mentions below from tcl repository
```sh
    tce-load -iw git <build-deps>
```
3. Clone the git repository into a tinycore bootet machine and change into the directory 
```sh
    git clone git://github.com/lapawa/tc4-open-vm-tools.git &&
    cd tc4-open-vm-tools
```
2. Download source tarball from http://sourceforge.net/projects/open-vm-tools/files/open-vm-tools/stable-9.2.x/
3. Change user to root.
```sh
    sudo -s
```
4. Start build script
```sh
    ./build-and-install.sh
```
5. Good luck
6. The build script will spit out two tinycore extensions:
   open-vm-tools.tcz
   and
   open-vm-tools-modules-KERNEL.tcz
  

Tested with these versions
-------------------------

- TinyCore      : v4.7.5 i686
  http://www.tinycorelinux.com
- open-vm-tools : 9.2.2-893683
  http://open-vm-tools.sf.net
- linux kernel  : 3.0.21-tinycore
  The build script is kernel version independent and uses `uname -r` 
  to find kernel header files 


Build dependencies
------------------

 - git                # To clone repository from github.com/lapawa/tc4-open-vm-tools
 - compiletc          # this meta package pulls in a lot of necessary development tools
 - linux-headers-3.0.21-tinycore # /usr/include/asm header files
 - eglibc_apps        # /usr/bin/rpcgen is in this packet
 - glib2-dev          # 
 - Xorg-7.6-dev
 - gtk2-dev           # because of a missing parameter in lib/appUtil/Makefile.am file it is not possible to compile with X and without gtk2 
 - gtkmm-dev  
 - fuse


Instructions used to configure
------------------------------

Set these environment variables before starting configure script:
 * export RPCGENFLAGS="-Y /usr/local/bin"
 * export CFLAGS="-march=i486 -mtune=i686 -Os -pipe -Wno-error=deprecated-declarations"
 * export CXXFLAGS="-march=i486 -mtune=i686 -Os -pipe"
 * export LDFLAGS="-Wl,-O1"
  
Additional configure options:
 * --with-x 
 * --without-pam
 * --without-gtkmm
 * --without-procps
 * --without-dnet
 * --without-icu

   
Look into build-and-install.sh for details.

