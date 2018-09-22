#!/bin/bash 
# Copyright (c) 2017 MAZA Network Developers, Robert Nelson (guruvan)
test -f EasyGitian.env && source EasyGitian.env
if [ "$EASYGITIAN_DEBUG}" = "true" ] ; then
   DEBUG=true
   set -xeo pipefail
fi

if [ -f .vbox-vm-initialized ] ; then
  echo "Your VM had been initialized previously"
  echo "If you've destroyed and recreated it please remove"
  echo "./.vbox-vm-initialized"
  echo "and try again"
  exit 1
fi

echo "Now starting your gitian build VM for the first time"
echo "This will take some time as the proper build environment is created within the VM"
echo "gitiian-builder and needed repositories will be downloaded and installed"

test -d ./binaries || mkdir ./binaries
test -d ./build || mkdir ./build
test -d ./cache || mkdir ./cache
test -d ./inputs || mkdir ./inputs 
test -d ./results || mkdir ./results
vagrant up \
 && touch .vbox-vm-initialized \
 && echo "Halting VM to take snapshot for future use" \
 && vagrant halt \
 && ./Add_VM_Disk.sh \
 && vagrant up \
 && vagrant ssh -c '/host_vagrantdir/mount_build_disk.sh' \
 && vagrant halt \
 && vagrant snapshot save Gitian-builder_jessie Gitian-Clean \
 && touch .vbox-vm-snapshot-clean \
 && echo "Now we'll reboot the VM and you'll be ready to build" \
 && vagrant up \
 && exit 0

echo "Trouble initializing VM - please report errors in an issue"
echo "at https://github.com/mazacub/easygitianbuilder"
sleep 7
exit 1



