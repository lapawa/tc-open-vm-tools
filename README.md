tc4-open-vm-tools
=================

Tools to build open-vm-tools for TinyCoreLinux 4.x

The fast track building instructions
------------------------------------
1. Clone the git repository into a tinycore bootet machine
2. Download open-vm-tools tarball into the same directory
3. Change user to root. ```sudo -s```
4. Start build script ```./build-and-install.sh```
5. Good luck / take some time
6. The build script will spit out two tinycore extensions:
   open-vm-tools.tcz
   and
   open-vm-tools-modules-KERNEL.tcz
  

Tested with these verions
-------------------------

- TinyCore      : v4.7.5 i686
  http://www.tinycorelinux.com
- open-vm-tools : 9.2.2-893683
  http://open-vm-tools.sf.net
- linux kernel  : 3.0.21-tinycore
  The build script is kernel version independent and uses `uname -r` 
  to find kernel header files 


Required tinycore extensions to build:
-------------------------------------

 - compiletc          # this meta package pulls in a lot of necessary development tools
 - linux-headers-3.0.21-tinycore # /usr/include/asm header files
 - eglibc_apps        # /usr/bin/rpcgen is in this packet
 - glib2-dev          # 
 - Xorg-7.6-dev
 - gtk2-dev           # because of a missing parameter in lib/appUtil/Makefile.am file it is not possible to compile with X and wihtout gtk2 
 - gtkmm-dev  
 - fuse


Instructions used to build the extensions:
------------------------------------------

Set these environment variables before starting configure script:
 * export RPCGENFLAGS="-Y /usr/local/bin"
 * export CFLAGS="-march=i486 -mtune=i686 -Os -pipe -Wno-error=deprecated-declarations"
 * export CXXFLAGS="-march=i486 -mtune=i686 -Os -pipe"
 * export LDFLAGS="-Wl,-O1"
  
Additional configure options:
  * --without-x
  * --without-gtk2
  * --without-pam
  * --without-gtkmm
  * --without-procps
  * --without-dnet
  * --without-icu
  * --prefix=/usr/local
   
Look into build-and-install.sh for detailed instructions

