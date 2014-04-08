#!/bin/ash

set -e

source open-vm-tools_version.sh

echo "### Preparing this tiny core machine to build the open-vm-tools version $TOOLS_VERIONS"

echo '### Pulling in the build dependencies from file build_dependencies'
while read line
do
  tce-load -iw $line
done < build-dependencies 


echo '### loading open-vm-tools tar file from sourceforge.net'
wget "http://sourceforge.net/projects/open-vm-tools/files/open-vm-tools/stable-9.4.x/open-vm-tools-${TOOLS_VERSION}.tar.gz/download" -O "open-vm-tools-${TOOLS_VERSION}.tar.gz"

echo '### Done. The operating system is ready to build the tools.'
echo '### Continue with sudo ./build-and-install.sh'
