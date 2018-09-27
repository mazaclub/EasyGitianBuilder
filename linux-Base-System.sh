#!/bin/bash
# Copyright (c) 2017 MAZA Network Developers, Robert Nelson (guruvan)

## This script runs on the host machine 

# Currently this script only supports debian-based distributions.
# At best we can support debian & CentOS with Vagrant

# TODO
# fix sums to verify
# determine OS & Release in order to download the correct Vbox .deb file
# support non-debian Linux distros

case "$1" in 
  reinstall)  reinstall=true
              echo "reinstalling vagrant and virtualbox"
              rm .vagrant_installed
              rm .Vbox_installed
          ;;
          *) reinstall=false
          ;;
esac

# host needs 64bit cpu and VT-x 
test -f EasyGitian.env && source EasyGitian.env
if [ "${EASYGITIAN_DEBUG}" = "true" ] ; then
   DEBUG=true
   set -xeo pipefail
fi
echo "Checking for 64 bit CPU..."
grep lm /proc/cpuinfo > /dev/null 2>&1 || { echo "64 bit CPU required. Exiting..." ; exit 1; }
echo "Checking for VT-x Virtualization Capabilities in your CPU..."
grep vmx /proc/cpuinfo > /dev/null 2>&1|| { echo "VirtualBox requires VT-x Virtualization capabilities. Exiting..." ; exit 1; }
# First install Virtualbox and Vagrant
# Vagrant 
test -f ./EasyGitian.env && source ./EasyGitian.env
if [ "${EASYGITIAN_WSL}" = "true" ] ; then
   VBOXMANAGE="/mnt/c/Program Files/Oracle/VirtualBox/VBoxManage.exe"
else
   VBOXMANAGE="$(which VBoxManage)"
fi

get_vagrant () {
vagrant_version=2.1.4

# Get files 
#wget -N https://releases.hashicorp.com/vagrant/2.0.0/vagrant_2.0.0_x86_64.deb
wget -N https://releases.hashicorp.com/vagrant/2.1.4/vagrant_2.1.4_x86_64.deb
#wget -N https://releases.hashicorp.com/vagrant/2.0.0/vagrant_2.0.0_SHA256SUMS
wget -N https://releases.hashicorp.com/vagrant/2.1.4/vagrant_2.1.4_SHA256SUMS
wget -N https://releases.hashicorp.com/vagrant/2.1.4/vagrant_2.1.4_SHA256SUMS.sig
#wget -N https://releases.hashicorp.com/vagrant/2.0.0/vagrant_2.0.0_SHA256SUMS.sig


# Verify shasums signature via gpg
gpg --import hashicorp.asc \
  || gpg --recv-keys --keyserver pool.sks-keyservers.net  51852D87348FFC4C \
  || exit 9
gpg --verify vagrant_${vagrant_version}_SHA256SUMS.sig vagrant_${vagrant_version}_SHA256SUMS || exit 8
#gpg --verify vagrant_2.0.0_SHA256SUMS.sig vagrant_2.0.0_SHA256SUMS || exit 8
gpg --verify vagrant_2.1.4_SHA256SUMS.sig vagrant_2.1.4_SHA256SUMS || exit 8

# Verify shasum for download
# fix to verify all downloaded versions
#grep vagrant_2.0.0_x86_64.deb vagrant_2.0.0_SHA256SUMS | shasum -c || exit 7
grep vagrant_2.1.4_x86_64.deb vagrant_2.1.4_SHA256SUMS | shasum -c || exit 7

# install debian package
## TODO this is probably not good
########sudo dpkg -i vagrant_2.0.0_x86_64.deb
which vagrant || { echo "==>> sudo dpkg -i vagrant_2.1.4_x86_64.deb"; sudo dpkg -i vagrant_2.1.4_x86_64.deb; }
if [ "${reinstall}" = "true" ] ; then
   echo "==>> sudo dpkg -i vagrant_2.1.4_x86_64.deb" 
   sudo dpkg -i vagrant_2.1.4_x86_64.deb && reinst_vagrant=true
fi
test -z ${DEBUG} || read -n 1 -s -r -p "Press any key to continue"
#if [ "$(uname -a |awk '{print $3}' | awk -F\- '{print $NF}')" = "Microsoft" ] ; then
#    wget -N https://releases.hashicorp.com/vagrant/2.0.0/vagrant_2.0.0_x86_64.msi
#    grep vagrant_2.0.0_x86_64.msi vagrant_2.0.0_SHA256SUMS | shasum -c || exit 7
#    /mnt/c/Windows/System32/msiexec.exe /i vagrant_2.0.0_x86_64.msi
#    read -n 1 -s -r -p "Press any key to continue"
#fi
if [ "${EASYGITIAN_WSL}" = "true" ] ; then
    wget -N https://releases.hashicorp.com/vagrant/2.1.4/vagrant_2.1.4_x86_64.msi
    grep vagrant_2.1.4_x86_64.msi vagrant_2.1.4_SHA256SUMS | shasum -c || exit 7
    /mnt/c/Windows/System32/msiexec.exe /i vagrant_2.1.4_x86_64.msi /norestart
    test -f /mnt/c/HashiCorp/Vagrant/bin/vagrant.exe || get_vagrant
fi

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

if [ "${EASYGITIAN_WSL}" = "true" ] ; then
   VBOXMANAGE="/mnt/c/Program Files/Oracle/VirtualBox/VBoxManage.exe"
   printf "\\nWSL in use\\nInstalling VirtualBox for Windows\\n"
   vbox_shortver="5.2.18"
   vbox_version="5.2.18-124319"
   vbox_installer=VirtualBox-5.2.18-124319-Win.exe
   vboxwin_sha=2607f510bcb5dca11a189ca769bbd28e0ff3ff1d082762c03f062b406c8763f3 
   wget -N https://download.virtualbox.org/virtualbox/${vbox_shortver}/VirtualBox-5.2.18-124319-Win.exe \
    && wget -N http://download.virtualbox.org/virtualbox/${vbox_shortver}/Oracle_VM_VirtualBox_Extension_Pack-${vbox_version}.vbox-extpack \
    && wget -N -O vbox_${vbox_shortver}.SHA256SUMS https://www.virtualbox.org/download/hashes/${vbox_shortver}/SHA256SUMS \
    && if [ "${vboxwin_sha}" = $(sha256sum VirtualBox-5.2.18-124319-Win.exe |awk '{print $1}') ] ; then
          printf "\\nVirtualBox downloaded successfully...Installing..."
	  ./${vbox_installer} || { echo "Error installing ${vbox_installer}" ; exit 1; } 
       else
          printf "\\nVirtualBox not downloaded successfully"
          test -z ${DEBUG} || read -n 1 -s -r -p "Press any key to continue"
	  printf "\\nRetrying..."
          get_vbox 
       fi
     grep "${vbox_version}.vbox-extpack" vbox_${vbox_shortver}.SHA256SUMS | shasum -c || exit 5
     echo y | "${VBOXMANAGE}"  extpack install --replace Oracle_VM_VirtualBox_Extension_Pack-${vbox_version}.vbox-extpack
     test -z ${DEBUG} || read -n 1 -s -r -p "Press any key to continue"
elif [ "${OS}" = "Debian" ] ; then
 echo "Installing Virtualbox from apt"
 case "${osrelease}" in
   jessie) echo "Installing virtualbox via jessie-backports to get latest version"
           # add apt source for backports
	   echo "deb http://ftp.debian.org/debian jessie-backports main contrib" >> ./jessie-backports.list
           echo "Installing virtualbox with sudo privileges"
           set -x
	   sudo  mv ./jessie-backports.list /etc/apt/sources.list.d
	   sudo chown root.root /etc/apt/sources.list.d/jessie-backports.list
           sudo apt-get update
           # install kernel headers 
	   sudo apt-get install -y linux-headers-"$(uname -r|sed 's,[^-]*-[^-]*-,,')"
           sudo apt-get install -y -t jessie-backports install virtualbox virtualbox-guest-additions-iso virtualbox-guest-x11
           set +x
	   VBOXMANAGE=$(which VBoxManage)
          ;;
  stretch) echo "Installing virtualbox via contrib repository" 
           vbox_version=5.2.18-124319
           vbox_shortver=5.2.18
#sudo add-apt-repository "deb http://download.virtualbox.org/virtualbox/debian stretch contrib"
           echo "deb http://download.virtualbox.org/virtualbox/debian stretch contrib" >> ./stretch-virtualbox.list
           echo "Installing virtualbox with sudo privileges"
           set -x
           sudo mv ./stretch-virtualbox.list /etc/apt/sources.list.d/
           sudo chown root.root /etc/apt/sources.list.d/stretch-virtualbox.list
           wget -N -O oracle_vbox_2016.asc https://www.virtualbox.org/download/oracle_vbox_2016.asc \
             && wget -N -O oracle_vbox.asc https://www.virtualbox.org/download/oracle_vbox.asc \
             && sudo apt-key add oracle_vbox_2016.asc \
             && sudo apt-key add oracle_vbox.asc \
             && sudo apt-get update \
             && sudo apt-get install -y virtualbox-5.2 \
             && wget -N http://download.virtualbox.org/virtualbox/${vbox_shortver}/Oracle_VM_VirtualBox_Extension_Pack-${vbox_version}.vbox-extpack \
             && wget -N -O vbox_${vbox_shortver}.SHA256SUMS https://www.virtualbox.org/download/hashes/${vbox_shortver}/SHA256SUMS 
             grep "${vbox_version}.vbox-extpack" vbox_${vbox_shortver}.SHA256SUMS | shasum -c || exit 5
           set +x
           VBOXMANAGE=$(which VBoxManage)
           echo y | "${VBOXMANAGE}"  extpack install --replace Oracle_VM_VirtualBox_Extension_Pack-${vbox_version}.vbox-extpack
           test -z ${DEBUG} || read -n 1 -s -r -p "Press any key to continue"
	  ;;
	 *) echo "Installation of Virtualbox not yet implemented on your system"
	  ;;
 esac
else 
  echo "Attempting to download Virtualbox from official web source and install via dpkg"
  echo "I detected your OS is ${OS} and version is ${osrelease} - you should have used apt"
    test -z ${DEBUG} || read -n 1 -s -r -p "Press any key to continue"
  vbox_version=5.1.28-117968
  vbox_shortver=5.1.28
  wget -N http://download.virtualbox.org/virtualbox/5.1.28/virtualbox-5.1_5.1.28-117968~"${OS}~${osrelease}"_amd64.deb
  wget -N http://download.virtualbox.org/virtualbox/5.1.28/Oracle_VM_VirtualBox_Extension_Pack-5.1.28-117968.vbox-extpack
  wget -N -O vbox_5.1.28.SHA256SUMS  https://www.virtualbox.org/download/hashes/5.1.28/SHA256SUMS
  # Verify shasum for download
  grep virtualbox-5.1_5.1.28-117968~"${OS}~${osrelease}"_amd64.deb  vbox_5.1.28.SHA256SUMS | shasum -c || exit 6
  grep "117968.vbox-extpack" vbox_5.1.28.SHA256SUMS | shasum -c || exit 5
  sudo dpkg -i virtualbox-5.1_5.1.28-117968~"${OS}~${osrelease}"_amd64.deb
  export VBOXMANAGE=$(which VBoxManage)
fi
which "$VBOXMANAGE"|| not_installed VBoxManage
#if [ "${reinstall}" = "true" ] ; then
#   not_installed vagrant
#   not_installed vbox
#fi
# install extension pack
echo "Checking for  VirtuaBox Extension Pack"
sleep 5

echo "Checking for  VirtuaBox Extension Pack"
extpack_installed=$("${VBOXMANAGE}" list extpacks |grep "Usable" | awk '{print $2}')||extpack_installed=false
if [ "$extpack_installed" != "true" ] ; then
   echo "No Extension Pack installed, getting one now...."
   get_vbox
elif [ -z "${extpack_installed}" ] ;then 
   echo "No Extension Pack installed, getting one now...."
   get_vbox
fi
if [ "$extpack_installed" != "true" ] ; then
   echo "No Extension Pack installed, getting one now...."
  echo y | "${VBOXMANAGE}"  extpack install --replace Oracle_VM_VirtualBox_Extension_Pack-${vbox_version}.vbox-extpack
fi
touch .Vbox_installed

}

not_installed () {
(( attempts++ ))
if [ ${attempts} -le 3 ]; then
   echo "Attempting to install ${1} -  ${attempts} tries"
   command -v "$1" || get_"${1}"
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
if [ "${EASYGITIAN_WSL}" = "true" ] ; then
  test -f "/mnt/c/HashiCorp/Vagrant/bin/vagrant.exe" || get_vagrant
fi
which  vagrant || get_vagrant
if [ "${reinstall}" = "true" ] ; then
   get_vagrant
fi
which ${VBOXMANAGE} || get_vbox
if [ "${reinstall}" = "true" ] ; then
   get_vbox
fi
extpack_installed=$("${VBOXMANAGE}" list extpacks |grep "Usable" | awk '{print $2}') || extpack_installed=false
if [ "$extpack_installed" != "true" ] ; then
   echo "No Extension Pack installed, getting one now...."
   get_vbox
elif [ -z "${extpack_installed}" ] ;then 
   echo "No Extension Pack installed, getting one now...."
   get_vbox
fi
which  vagrant && which ${VBOXMANAGE} && touch .prereq_install_complete
echo "Prerequisites should now be installed" 
if [ "${EASYGITIAN_WSL}" = "true" ]; then 
  echo "Your system needs to reboot for Vagrant and VirtualBox to be fully installed"
  #read -n 1 -s -r -p "Press any key to reboot now....
  echo "automatically rebooting in 60 seconds"
  echo "Press CTRL-C to abort"
  sleep 60
  shutdown.exe /r /t 30
fi


