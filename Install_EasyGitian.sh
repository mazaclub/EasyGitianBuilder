#!/bin/bash
# Copyright (c) 2017 MAZA Network Developers, Robert Nelson (guruvan)

## EasyGitian Installer
## 
## installs git, clones repo

printf "EasyGitian Installer\n\n"

if [ $UID -eq 0 ]; then
   printf "\nDo not run shell scripts found on the internet as root!\n"
   printf "\nWhat if the script has 'rm -rf /' in it? I could do anything!\n"
   exit 99
fi
deb_check_host () {
     printf "\nYou'll be asked for your password if we need to install \
any software through apt\n\n"
     which wget > /dev/null 2>&1 || { sudo apt-get update ; sudo apt-get install -y wget; }
     which gpg > /dev/null 2>&1 || { sudo apt-get update; sudo  apt-get install -y gpg; }
     which git > /dev/null 2>&1 || { sudo apt-get update; sudo apt-get install -y git; }
     git clone https://github.com/mazaclub/easygitianbuilder
     cd ./easygitianbuilder || { echo "git clone seems to have failed"; exit 3; }
     exec ./EasyGitian
}

install_gpg_osx () {
  printf "\nGPG not found\nThere are two means to install it\n\
You may install via [H]omebrew or GPGTools.org [W]ebsite\n\n\
Homebrew is required if you later want to build wallets without gitian\n\nChoose [H]omebrew or [W]eb or [Q]uit install [H/W/Q]\n"
  read -r -n1 gpginst 
  case $gpginst in
    [Hh]) printf "\nInstalling Homebrew\n\nYou'll be prompted for your password to allow Homebrew to be installed\n"
          # install homebrew
          printf "Begin Homebrew's install script from https://raw.githubusercontent.com/Homebrew/install/master/install\n"
          read -n 1 -s -r -p "Press any key to continue the installation";echo
          /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
          brew update
          brew install gnupg2
          ;;
    [Ww]) printf "\nInstalling GPGTools Suite\n"
          echo "curl tools"
          #curl -O https://releases.gpgtools.org/GPG_Suite-2017.1.dmg 
          gpgshasum=01705da33b9dadaf5282d28f9ef58f2eb7cd8ff6f19b4ade78861bf87668a061
          dlfilesum=$(shasum -a 256 GPG_Suite-2017.1.dmg|awk '{print $1}')
          if [ "$gpgshasum" = "$dlfilesum" ] ; then 
             printf "\nWhen the Finder window opens, install GPGSuite Tools\n\n"
             hdiutil attach GPG_Suite-2017.1.dmg -autoopen > /dev/null 2>&1
             read -n 1 -s -r -p "Press any key to continue the installation";echo
          else
             printf "\nDownload failed, retrying..."
             install_gpg_osx
          fi
          curl -O https://releases.gpgtools.org/GPG_Suite-2017.1.dmg.sig
          gpg --receive-keys E8A664480D9E43F5
          gpg --verify GPG_Suite-2017.1.dmg.sig || { echo "Something went wrong with the installation"; exit 4; }
          ;;
    [Qq]) printf "\nTo try again just type:\n\n./install-easygitian.sh\n"
          exit 3
        ;;
       *) printf "\nPlease choose [H]omebrew or GPGTools [W]ebsite [H/W]:\n"
          install_gpg_osx
        ;;
  esac
}

if [ "$(uname -s)" = "Darwin" ]; then
   printf "\nInstalling EasyGitian on MacOS\nIf you have not yet installed Xcode or\n\
the developer tools (required) you'll be prompted to do so\n\n"
   read -n 1 -s -r -p "Press any key to continue the installation";echo
   printf "\nXcode 7.3.1 is required to build the correct SDK tarball\nYou may install either \
just the Command Line Tools, or all of Xcode if you intend to build for OSX(MacOS)\n\n"
   printf "If you already have the command line tools installed, you'll have another chance \
to download Xcode once EasyGitian is installed\n\n"
   pkgutil --pkg-info=com.apple.pkg.CLTools_Executables || xcode-select --install
   printf "\n"
   read -n 1 -s -r -p "Press any key to continue the installation";echo
   printf "\nChecking for GPG...\n"
   gpg --version || install_gpg_osx  
   git clone https://github.com/mazaclub/easygitianbuilder \
    && printf "\nYou're ready to start EasyGitian\nAt your terminal type:\n\
cd %s/easygitianbuilder\n./EasyGitian\n\nEasyGitian will make sure you \
have Vagrant and Virtualbox installed\nand start your build\n\n" "$(pwd)"
   test -d ./easygitianbuilder \
    && printf "\nEasyGitian appears to exist\nStarting it now\n" \
    && cd ./easygitianbuilder \
    && exec ./EasyGitian
else 
  printf "\nInstallation supported on MacOS and Debian based systems\n\n"
  host=$(lsb_release -is)
  if [ "$host" = "Ubuntu" ]; then
     printf "\nInstalling on Ubuntu\n"
     deb_check_host
  elif [ "$host" = "Debian" ]; then
     printf "\nInstalling on Debian\n"
     deb_check_host
  else 
     echo "You need to run EasyGitian on MacOS, Ubuntu, or Debian"
     exit 9
  fi 
fi


