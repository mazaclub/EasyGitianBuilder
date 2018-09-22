#!/bin/bash
# Copyright (c) 2017 MAZA Network Developers, Robert Nelson (guruvan)

test -f EasyGitian.env && source EasyGitian.env
if [ "$EASYGITIAN_DEBUG}" = "true" ] ; then
   DEBUG=true
   set -xeo pipefail
fi
## This script runs on the host machine

# First install Virtualbox and Vagrant

# Vagrant 
get_vagrant () {
# Get files 
vagrant_version=2.1.4
curl -O https://releases.hashicorp.com/vagrant/$vagrant_version/vagrant_${vagrant_version}_x86_64.dmg  -o vagrant_${vagrant_version}_x86_64.dmg
curl -O https://releases.hashicorp.com/vagrant/${vagrant_version}/vagrant_${vagrant_version}_SHA256SUMS -o vagrant_${vagrant_version}_SHA256SUMS
curl -O https://releases.hashicorp.com/vagrant/${vagrant_version}/vagrant_${vagrant_version}_SHA256SUMS.sig -o vagrant_${vagrant_version}_SHA256SUMS.sig

# Verify shasums signature via gpg
#gpg --recv-keys 51852D87348FFC4C || exit 9
gpg --import hashicorp.asc \
  || gpg --recv-keys --keyserver pool.sks-keyservers.net  51852D87348FFC4C \
  || exit 9
gpg --verify vagrant_${vagrant_version}_SHA256SUMS.sig vagrant_${vagrant_version}_SHA256SUMS || exit 8

# Verify shasum for download
grep dmg vagrant_${vagrant_version}_SHA256SUMS | shasum -c || exit 7

# Mount the dmg and open it
hdiutil attach vagrant_${vagrant_version}_x86_64.dmg -autoopen
# User must install the app
echo "Now double click the Vagrant pkg file" 
read -n 1 -s -r -p "Press any key to continue";echo
which vagrant || not_installed vagrant
touch .vagrant_installed
}


# Virtualbox
get_vbox () {
# Get files 
vbox_version=5.2.18-124319
vbox_shortver=5.2.18
curl -O http://download.virtualbox.org/virtualbox/${vbox_shortver}/VirtualBox-${vbox_version}-OSX.dmg
curl -O http://download.virtualbox.org/virtualbox/${vbox_shortver}/Oracle_VM_VirtualBox_Extension_Pack-${vbox_version}.vbox-extpack
curl -O https://www.virtualbox.org/download/hashes/${vbox_shortver}/SHA256SUMS 
mv SHA256SUMS vbox_${vbox_shortver}.SHA256SUMS
# Verify shasum for download
grep dmg vbox_${vbox_shortver}.SHA256SUMS | shasum -c || exit 6
grep "${vbox_version}.vbox-extpack" vbox_${vbox_shortver}.SHA256SUMS | shasum -c || exit 5
# Mount the dmg and open it
hdiutil attach VirtualBox-${vbox_version}-OSX.dmg -autoopen
# User must install the app
echo "Now drag the VirtualBox icon to the Applications folder" 
read -n 1 -s -r -p "Press any key to continue";echo
which VBoxManage || not_installed VBoxManage
echo "Installing VirtualBox Extension Pack (required)"
sleep 5
extpack_installed=$(VBoxManage list extpacks |grep "Usable" | awk '{print $2}')
if [ "$extpack_installed" != "true" ] ; then
   VBoxManage extpack install --replace Oracle_VM_VirtualBox_Extension_Pack-${vbox_version}.vbox-extpack
fi
# TODO - if mojave user doesn't allow the kernel module to load
# Vbox will fail later, requiring a reboot
# determine if we can reload the vbox driver if the user didn't click allow 
# Remind user to unlock before clicking allow 
touch .Vbox_installed
}

not_installed () {
(( attempts++ ))
if [ ${attempts} -le 3 ]; then
   echo "Attempting to install ${1} -  ${attempts} tries"
   which "$1" || get_"${1}"
else 
   echo "Installation of ${1} failed"
   test -f ./.Vbox_installed && echo "VirtualBox seems installed" 
   test -f ./.vagrant_installed && echo "Vagrant seems installed"
   echo " " 
   echo "If both Virtualbox and Vagrant seem installed, and you still see this message"
   echo "Please report an issue on https://github.com/mazaclub/EasyGitianBuilder"
   echo " " 
   echo "You may attempt to install ${1} on your own and run EasyGitian later" 
   exit 99
fi
}

attempts=1
if [ -z "$1" ]; then
which vagrant || get_vagrant
which VBoxManage || get_vbox
which vagrant && which VBoxManage && touch .prereq_install_complete
echo "Prerequisites should now be installed" 
else 
get_vagrant
get_vbox
fi
