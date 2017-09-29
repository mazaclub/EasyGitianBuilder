#!/bin/bash -x

## This script runs on the host machine 

# Currently this script only supports debian-based distributions.
# At best we can support debian & CentOS with Vagrant

# TODO
# fix sums to verify
# determine OS & Release in order to download the correct Vbox .deb file
# support non-debian Linux distros

# First install Virtualbox and Vagrant
# Vagrant 

get_vagrant () {
# Get files 
wget https://releases.hashicorp.com/vagrant/2.0.0/vagrant_2.0.0_x86_64.deb
wget https://releases.hashicorp.com/vagrant/2.0.0/vagrant_2.0.0_SHA256SUMS
wget https://releases.hashicorp.com/vagrant/2.0.0/vagrant_2.0.0_SHA256SUMS.sig

# Verify shasums signature via gpg
gpg --keyserver hkp://pgp.mit.edu  --recv-keys 51852D87348FFC4C || exit 9
gpg --verify vagrant_2.0.0_SHA256SUMS.sig vagrant_2.0.0_SHA256SUMS || exit 8

# Verify shasum for download
grep vagrant_2.0.0_x86_64.deb vagrant_2.0.0_SHA256SUMS | shasum -c || exit 7

# install debian package
sudo dpkg -i vagrant_2.0.0_x86_64.deb

which vagrant || not_installed vagrant
touch .vagrant_installed
}


# Virtualbox
# first determine if we have a proper distro
get_distro () {
 # here's one attempt 
 #OS=$(grep NAME /etc/os-release | grep -v PRETTY|awk -F= '{print $2}'|sed 's/\"//g')
 #OS=Ubuntu
 OS=$(lsb_release -is|tr '[:upper:]' '[:lower:]')
 if [ "${OS}" = "ubuntu" ]; then
   OS=Ubuntu
   osrelease=$(grep VERSION /etc/os-release |grep -v ID|awk -F\, '{print $2}'|sed 's/\"//g'|awk '{print $1}'|tr '[:upper:]' '[:lower:]')
 elif [ ${OS} = "debian" ] ; then
   OS=Debian
   osrelease=$( grep VERSION /etc/os-release |grep -v ID|awk  '{print $2}'|sed 's/\"//g'|awk -F\( '{print $2}'|awk -F\) '{print $1}')
 else
   echo "OS not recognized - currently only debian and ubuntu are supported"
   echo "If you're running debian or ubuntu, please report the version in an"
   echo "issue on https://github.com/mazaclub/EasyGitianBuilder"
   exit 19
 fi
}


get_vbox () {

if [ "${OS}" = "debian" ] ; then
 echo "Installing Virtualbox from apt"
 case "${osrelease}" in
   jessie) echo "Installing virtualbox via jessie-backports to get latest version"
           # add apt source for backports
	   echo "deb http://ftp.debian.org/debian jessie-backports main contrib" >> ./jessie-backports.list
	   sudo  mv ./jessie-backports.list /etc/apt/sources.list.d
	   sudo chown root.root /etc/apt/sources.list.d/jessie-backports.list
           sudo apt-get update
           # install kernel headers 
	   sudo apt-get install -y linux-headers-"$(uname -r|sed 's,[^-]*-[^-]*-,,')"
           sudo apt-get install -y -t jessie-backports install virtualbox virtualbox-guest-additions-iso virtualbox-guest-x11
          ;;
  stretch) echo "Installing virtualbox via contrib repository" 
           echo "deb http://download.virtualbox.org/virtualbox/debian stretch contrib" >> ./stretch-virtualbox.list
           sudo mv ./stretch-virtualbox.list /etc/apt/sources.list.d/
           chown root.root /etc/apt/sources.list.d/stretch-virtualbox.list
           curl -O https://www.virtualbox.org/download/oracle_vbox_2016.asc
           sudo apt-key add oracle_vbox_2016.asc
           sudo apt-get update
           sudo apt-get install vitrualbox-5.1
	  ;;
	 *) echo "Installation of Virtualbox not yet implemented on your system"
	  ;;
 esac
else 
  echo "Attempting to download Virtualbox from official web source and install via dpkg"
  wget http://download.virtualbox.org/virtualbox/5.1.28/virtualbox-5.1_5.1.28-117968~"${OS}"~"${osrelease}"_amd64.deb 
  wget http://download.virtualbox.org/virtualbox/5.1.28/Oracle_VM_VirtualBox_Extension_Pack-5.1.28-117968.vbox-extpack
  wget https://www.virtualbox.org/download/hashes/5.1.28/SHA256SUMS
  # Verify shasum for download
  grep virtualbox-5.1_5.1.28-117968~"${OS}"~"${osrelease}"_amd64.deb  SHA256SUMS | shasum -c || exit 6
  grep "117968.vbox-extpack" SHA256SUMS | shasum -c || exit 5
  sudo dpkg -i virtualbox-5.1_5.1.28-117968~"${OS}"~"${osrelease}"_amd64.deb
fi
which VBoxManage || not_installed VBoxManage
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

get_distro
attempts=1
which vagrant || get_vagrant
which VBoxManage || get_vbox
which vagrant && which VBoxManage && touch .prereq_install_complete
echo "Prerequisites should now be installed" 
