#!/bin/bash

## This script runs on the host machine

# First install Virtualbox and Vagrant

# Vagrant 
get_vagrant () {
# Get files 
wget https://releases.hashicorp.com/vagrant/2.0.0/vagrant_2.0.0_x86_64.dmg
wget https://releases.hashicorp.com/vagrant/2.0.0/vagrant_2.0.0_SHA256SUMS
wget https://releases.hashicorp.com/vagrant/2.0.0/vagrant_2.0.0_SHA256SUMS.sig

# Verify shasums signature via gpg
gpg --recv-keys 51852D87348FFC4C || exit 9
gpg --verify vagrant_2.0.0_SHA256SUMS.sig vagrant_2.0.0_SHA256SUMS || exit 8

# Verify shasum for download
grep dmg vagrant_2.0.0_SHA256SUMS | shasum -c || exit 7

# Mount the dmg and open it
hdiutil attach vagrant_2.0.0_x86_64.dmg -autoopen
# User must install the app
echo "Now drag the Vagrant icon to the Applications folder" 
read -n 1 -s -r -p "Press any key to continue";echo
which vagrant || not_installed vagrant
touch .vagrant_installed
}


# Virtualbox
get_vbox () {
# Get files 
wget http://download.virtualbox.org/virtualbox/5.1.28/VirtualBox-5.1.28-117968-OSX.dmg
wget http://download.virtualbox.org/virtualbox/5.1.28/Oracle_VM_VirtualBox_Extension_Pack-5.1.28-117968.vbox-extpack
wget https://www.virtualbox.org/download/hashes/5.1.28/SHA256SUMS
# Verify shasum for download
grep dmg SHA256SUMS | shasum -c || exit 6
grep "117968.vbox-extpack" SHA256SUMS | shasum -c || exit 5
# Mount the dmg and open it
hdiutil attach VirtualBox-5.1.28-117968-OSX.dmg -autoopen
# User must install the app
echo "Now drag the VirtualBox icon to the Applications folder" 
read -n 1 -s -r -p "Press any key to continue";echo
which VBoxManage || not_installed VBoxManage
touch .Vbox_installed
}

not_installed () {
(( attempts++ ))
if [ ${attempts} -le 3 ] then
   echo "Attempting to install ${1} -  ${attempts} tries"
   which $1 || get_${1}
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
which vagrant || get_vagrant
which VBoxManage || get_vbox
which vagrant && which VBoxManage && touch .prereq_install_complete
echo "Prerequisites should now be installed" 
