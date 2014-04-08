#!/bin/ash


echo 'Preparing this tiny core machine to build the open-vm-tools.'o

echo 'Pulling in the build dependencies from file build_dependencies'
while read line
do
  tce-load -iw $line
done < build-dependencies 

