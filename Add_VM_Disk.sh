#!/bin/bash 
# Copyright (c) 2017 MAZA Network Developers, Robert Nelson (guruvan)

# This script runs on the host
# Create a new disk and attach to the VM
test -f EasyGitian.env && source EasyGitian.env
if [ "$EASYGITIAN_DEBUG}" = "true" ] ; then
   DEBUG=true
   set -xeo pipefail
fi
DIR=$(pwd)

## We need a minimum of a 40GB disk here
## Build a 75GB disk so users can have 
## lxc vms for multiple suites and architectures 
## without running out of space

HOSTOS=$(uname)


if [ "${HOSTOS}" = "MINGW64_NT-10.0" ]; then
	VBOXMANAGE="/c/Program Files/Oracle/Virtualbox/VBoxManage.exe"
elif [ "${HOSTOS}" = "Linux" ] ; then
	realhost=$(uname -a |awk '{print $3}'|awk -F\- '{print $NF}')
	DIR1=$(echo $DIR | awk -F/ '{print $NF}')
	DIR2=$(echo $DIR | awk -F/ '{print $(NF-1)}')
	DIR="C:\\Users\\${DIR2}\\${DIR1}"
     if [ "${realhost}" = "Microsoft" ] ; then
	VBOXMANAGE="/mnt/c/Program Files/Oracle/VirtualBox/VBoxManage.exe"
     else
	VBOXMANAGE="$(which VBoxManage)"
     fi

else
	VBOXMANAGE="$(which VBoxManage)"
fi

echo "Running ${VBOXMANAGE} to install a second virtual disk"
"$VBOXMANAGE" createhd --filename "${DIR}/Gitian-builder_jessie.vdi" --size 75000 --format VDI --variant Standard
echo "Attaching the new virtual disk to Gitian-builder_jessie VM"
"$VBOXMANAGE" storageattach "Gitian-builder_jessie" --storagectl "SATA Controller" --port 1 --device 0 --type hdd --medium "${DIR}/Gitian-builder_jessie.vdi"

echo "Virtual Disk added"
# To add another disk, copy and modify this file, incrementing the "port 1" and choosing another file name 
# Then copy and modify mount_build_disk to mount the new disk 
# the mount point for fstab must exit
# be suure to edit the new mount_build_disk.sh 
# 
# vagrant ssh -c 'sudo mkdir /some/mountpoint'
# vagrant ssh -c '/host_vagrantdir/mount_build_disk_mine.sh'

