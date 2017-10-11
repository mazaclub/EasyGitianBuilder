#!/bin/bash -x
# Copyright (c) 2017 MAZA Network Developers, Robert Nelson (guruvan)

# This script runs on the host
# Create a new disk and attach to the VM

DIR=$(pwd)

VBoxManage createhd --filename "${DIR}/Gitian-builder_jessie.vdi" --size 50000 --format VDI --variant Standard
VBoxManage storageattach "Gitian-builder_jessie" --storagectl "SATA Controller" --port 1 --device 0 --type hdd --medium "${DIR}/Gitian-builder_jessie.vdi"

# To add another disk, copy and modify this file, incrementing the "port 1" and choosing another file name 
# Then copy and modify mount_build_disk to mount the new disk 
# the mount point for fstab must exit
# be suure to edit the new mount_build_disk.sh 
# 
# vagrant ssh -c 'sudo mkdir /some/mountpoint'
# vagrant ssh -c '/host_vagrantdir/mount_build_disk_mine.sh'

