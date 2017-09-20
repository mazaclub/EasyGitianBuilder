#!/bin/bash -x

if [ ${UID} != 0 ] ; then 
 echo "Must be root - use sudo to run this script"
 exit 1
fi
echo "deb http://ftp.debian.org/debian jessie main contrib" >> /etc/apt/sources.list
apt-get update
apt-get install virtualbox-guest-dkms virtualbox-guest-x11 linux-headers-$(uname -r)
