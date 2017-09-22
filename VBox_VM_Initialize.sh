#!/bin/bash -x

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
vagrant up
touch .vbox-vm-initialized
echo "Halting VM to take snapshot for future use"
vagrant halt
vagrant snapshot save default Gitian-Clean
touch .vbox-vm-snapshot-clean
echo "Now we'll reboot the VM and you'll be ready to build"
vagrant up


echo "You're now ready to perform gitian builds"
echo "The first build will build all the dependencies as well as the application"
echo "for the systems you've chosen. This will take a good deal of time"
echo "If you've chosen to build for Linux, aarch, arm and x86_64 binaries are built"
echo "Running build in 30 seconds, press CTRL-C to abort"
sleep 30

./EasyGitian run_build
