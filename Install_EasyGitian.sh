#!/bin/bash 

# any argument tuens on debug 
test -z $1 || export DEBUG=true
# Copyright (c) 2017 MAZA Network Developers, Robert Nelson (guruvan)

## EasyGitian Installer
## 
## installs git, clones repo



printf "EasyGitian Installer\\n\\n"

if [ $UID -eq 0 ]; then
   printf "\\nDo not run shell scripts found on the internet as root!\\n"
   printf "\\nWhat if the script has 'rm -rf /' in it? I could do anything!\\n"
   exit 99
fi

test -f ~/EasyGitian.env && rm ~/EasyGitian.env
test -z "$DEBUG" || read -n 1 -s -r -p "Press any key to continue"



git_clone () {
  # test to see if we just started with a shell script, or a cloned directory
  # testing for one of our tag files should be sufficient
  if [[  -f ./binaries/.easygitian-dir ]] ; then 
     echo "It appears you already have EasyGitianBuilder from git or a release package" 
     echo "LOCAL_DIR=$(pwd)" > local_dir.env
     test -z "$DEBUG" || read -n 1 -s -r -p "Press any key to continue"
  else 
     echo "cloning EasyGitianBuilder" 
     git clone https://github.com/mazaclub/easygitianbuilder
     cd easygitianbuilder || exit 1
     echo "LOCAL_DIR=$(pwd)" > local_dir.env
     test -z "$DEBUG" ||  read -n 1 -s -r -p "Press any key to continue"
  fi
}
  


deb_check_host () {
     printf "\\nYoull be asked for your password if we need to install any software through apt\\n\\n"
     which wget > /dev/null 2>&1 || { sudo apt-get update ; sudo apt-get install -y wget; }
     which gpg  > /dev/null 2>&1 || { sudo apt-get update; sudo  apt-get install -y gnupg2; }
     which git  > /dev/null 2>&1 || { sudo apt-get update; sudo apt-get install -y git; }
     # TODO test gpg properly
     echo "if you see an error about dirmngr when running EasyGitian,"
     echo "run the following commands" 
     echo "sudo apt-get update && sudo apt-get purge -y gnupg && sudo apt-get install -y gnupg2"
     read -n 1 -s -r -p "Press any key to continue"
     git_clone \
      && echo "cd ~/easygitianbuilder" >> ~/EasyGitian.env \
      && cp ~/EasyGitian.env ~/easygitianbuilder \
      && echo "EasyGitian is installed." \
      && echo "To start a build run:" \
      && echo "source ~/EasyGitian.env ; ./EasyGitian" 
} \

get_brew () {
  brewdir=$(which brew)
  if [[ -z ${brewdir} ]] ; then
     printf "\\nInstalling Homebrew\\n\\nYoull be prompted for your password to allow Homebrew to be installed\\n"
     # install homebrew
     printf "Begin Homebrews install script from https://raw.githubusercontent.com/Homebrew/install/master/install\\n"
     read -n 1 -s -r -p "Press any key to continue the installation";echo
     test -f /usr/local/bin/brew || /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi
  brewdir=$(which brew)
  test -z "${brewdir}" && { echo "Somehow brew is not found still. Please install it manually" ; exit 1; }
  printf "Brew appears to be installed in %s" "${brewdir}"
  test -z "$DEBUG" || read -n 1 -s -r -p "Press any key to continue"
}

install_gpg_osx () {
  printf "\\nGPG not found\\nThere are two means to install it\\n\
You may install via [H]omebrew or GPGTools.org [W]ebsite\\n\\n\
Homebrew is required if you later want to build wallets without gitian\\n\\nChoose [H]omebrew or [W]eb or [Q]uit install [H/W/Q]\\n"
  read -r -n1 gpginst 
  case $gpginst in
    [Hh]) which brew || get_brew
          brew update
          brew install gnupg2
          test -z "$DEBUG" || read -n 1 -s -r -p "Press any key to continue"
          ;;
    [Ww]) printf "\\nInstalling GPGTools Suite\\n"
          printf "\\nActually, no we arent - temporarily disabled\\n If you want GPGTools,download it from\\n"
          printf "https://releases.gpgtools.org/ \\n and restart ./Install_EasyGitian.sh\\n"
          install_gpg_osx
          echo "curl tools"
          #curl -O https://releases.gpgtools.org/GPG_Suite-2017.1.dmg 
          gpgshasum=01705da33b9dadaf5282d28f9ef58f2eb7cd8ff6f19b4ade78861bf87668a061
          dlfilesum=$(shasum -a 256 GPG_Suite-2017.1.dmg|awk '{print $1}')
          if [ "$gpgshasum" = "$dlfilesum" ] ; then 
             printf "\\nWhen the Finder window opens, install GPGSuite Tools\\n\\n"
             hdiutil attach GPG_Suite-2017.1.dmg -autoopen > /dev/null 2>&1
             read -n 1 -s -r -p "Press any key to continue the installation";echo
          else
             printf "\\nDownload failed, retrying..."
             test -z "$DEBUG" || read -n 1 -s -r -p "Press any key to continue"
             install_gpg_osx
          fi
          curl -O https://releases.gpgtools.org/GPG_Suite-2017.1.dmg.sig
          gpg --receive-keys E8A664480D9E43F5
          gpg --verify GPG_Suite-2017.1.dmg.sig || { echo "Something went wrong with the installation"; exit 4; }
          test -z "$DEBUG" || read -n 1 -s -r -p "Press any key to continue"
          ;;
    [Qq]) printf "\\nTo try again just type:\\n\\n./Install_EasyGitian.sh\\n"
          exit 3
        ;;
       *) printf "\\nPlease choose [H]omebrew or GPGTools [W]ebsite [H/W]:\\n"
          install_gpg_osx
        ;;
  esac
}
get_winaltdir () {
 export EASYGITIAN_WINUSERDIR="/mnt/c/Users/${EASYGITIAN_WINUSER}"
 printf "\\nBuilding in %s/easygitianbuilder" ${EASYGITIAN_WINUSERDIR}
 printf "\\nYou should have 50GB of free space before building"
 printf "\\nBuild path must be a local drvfs mount like /mnt/c/some/directory\\n"
 printf "\\n\\nPress Enter to accept this directory or provide another build path\\n\\n"
 read -r winbuilddir
 test -z ${winbuilddir} && winbuilddir="${EASYGITIAN_WINUSERDIR}" 
 touch "${winbuilddir}/.easygitian_wsl" || { echo "$winbuilddir does not appear writable" ; get_winaltdir; }
 export EASYGITIAN_WINUSERDIR=${winbuilddir}
}
   
get_winbuild_dir () { 

 winuser=$(cmd.exe /c "echo %USERNAME%")
 export EASYGITIAN_WSL=true
 export EASYGITIAN_WINUSER=${winuser%$'\r'}
 export EASYGITIAN_WSLUSER=${USER}
 #export EASYGITIAN_WINUSERDIR="/mnt/c/Users/${EASYGITIAN_WINUSER}"
 get_winaltdir
 touch "${EASYGITIAN_WINUSERDIR}/.easygitian_wsl" || get_winaltdir
 export EASYGITIAN_WINDIR="/mnt/c/Users/${EASYGITIAN_WINUSER}/easygitianbuilder"
 export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS=1
 export PATH="${PATH}:/mnt/c/HashiCorp/Vagrant:/mnt/c/Program Files/Oracle/VirtualBox"
 echo "export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS=1" > "${EASYGITIAN_WINUSERDIR}/EasyGitian.env"
 echo "export EASYGITIAN_WSL=true" >> "${EASYGITIAN_WINUSERDIR}/EasyGitian.env"
 echo "export EASYGITIAN_WINUSER=$(echo "${EASYGITIAN_WINUSER}")" >> "${EASYGITIAN_WINUSERDIR}/EasyGitian.env"
 echo "export EASYGITIAN_WSLUSER=$(echo "${EASYGITIAN_WSLUSER}")" >> "${EASYGITIAN_WINUSERDIR}/EasyGitian.env"
 echo "export EASYGITIAN_WINDIR=$(echo "${EASYGITIAN_WINDIR}")" >> "${EASYGITIAN_WINUSERDIR}/EasyGitian.env"
 echo "export EASYGITIAN_WINUSERDIR=$(echo "${EASYGITIAN_WINUSERDIR}")" >> "${EASYGITIAN_WINUSERDIR}/EasyGitian.env"
 echo "export PATH=\"$(echo "${PATH}")"\" >> "${EASYGITIAN_WINUSERDIR}/EasyGitian.env"
 chmod +x $EASYGITIAN_WINUSERDIR/EasyGitian.env
 cp "$EASYGITIAN_WINUSERDIR/EasyGitian.env" $HOME/EasyGitian.env
 echo "cd $(echo ${EASYGITIAN_WINDIR})" >> $HOME/EasyGitian.env

   # set path
   # set EASYGITIAN_WSL=true
   # set EASYGITIAN_WSLUSER=ubuntu
   # set EASYGITIAN_WINUSER=IEUser
   # set EASYGITIAN_WINDIR=/mnt/c/Users/IEUser
   # write exports to EASYGITIAN_WINDIR/EasyGitian.env
   # chmod +x $EASYGITIAN_WINDIR/EasyGitian.env
   # cp EASYGITIAN_WINDIR/EasyGitian.env $HOME/EasyGitian.env
   # echo "cd $(echo ${EASYGITIAN_WINDIR})" >> $HOME/EasyGitian.env

#  test -z "${winbuilddir}" && winbuilddir="/mnt/c/Users/${winuser}"
#  test -d "${winbuilddir}" || { echo "${winbuilddir} not found, please try again" ; get_winbuild_dir; }
#  printf "%s\\n" "${winbuilddir}" > WSL.env
#  test -z "$DEBUG" || read -n 1 -s -r -p "Press any key to continue"
}
  printf "Lets find out how you will use EasyGitian\\n"
  test -z "$DEBUG" || read -n 1 -s -r -p "Press any key to continue"


if [ "$(uname -s)" = "Darwin" ]; then
   echo "export EASYGITIAN_OSX=true" >> ~/EasyGitian.env
   echo "export EASYGITIAN_OS=Darwin" >> ~/EasyGitian.env
   printf "\\nInstalling EasyGitian on MacOS\\nIf you have not yet installed Xcode or\\n\
the developer tools you'll be prompted to do so\\n\\n"
   read -n 1 -s -r -p "Press any key to continue the installation" ;echo
   printf "\\nXcode 7.3.1 is required to build the correct SDK tarball\\nYou may install either \
just the Command Line Tools, or all of Xcode if you intend to build for OSX(MacOS)\\n\\n"
   printf "If you already have the command line tools installed, you'll have another chance \
to download Xcode once EasyGitian is installed\\n\\n"
   test -z "$DEBUG" || read -n 1 -s -r -p "Press any key to continue"
   pkgutil --pkg-info=com.apple.pkg.CLTools_Executables || xcode-select --install
   printf "\\n"
   read -n 1 -s -r -p "Press any key to continue the installation";echo
   printf "\\nChecking for GPG...\\n"
   gpg --version || install_gpg_osx  
   # TODO should be EASYGITIAN_DIR
   cd ~
   git_clone \
    && printf "\\nYou're ready to start EasyGitian\\nAt your terminal type:\\n\
cd %s/easygitianbuilder\\n./EasyGitian\\n\\nEasyGitian will make sure you \
have Vagrant and Virtualbox installed\\nand start your build\\n\\n" "$(pwd)"
   test -z "$DEBUG" ||  read -n 1 -s -r -p "Press any key to continue"
   test -d ./easygitianbuilder \
    && cp ~/EasyGitian.env ./easygitianbuilder \
    && printf "\\nEasyGitian appears to exist\\nStarting it now\\n" \
    && cd ./easygitianbuilder \
    && echo "EasyGitian is installed." \
    && echo "To start a build run:" \
    && echo "source ~/EasyGitian.env ; ./EasyGitian" 
elif [ "$(uname -a | awk '{print $3}' |awk -F"-" '{print $NF}')" = "Microsoft" ]; then
  printf "\\nIt appears you're running in Windows System for Linux\\n\\nVirtualBox is only aware of C: and other Windows  mounted filesystems\\n\\nBuilds will happen in a folder in your Windows User directory, and VirtualBox VMs will reside there\\n\\n"
  #printf "\\nYour C: drive mounted on /mnt/c"
  test -z "$DEBUG" || read -n 1 -s -r -p "Press any key to continue"
  get_winbuild_dir
  cd "${EASYGITIAN_WINUSERDIR}" || { echo "${EASYGITIAN_WINUSERDIR} not found" ; exit 1; }
  git_clone \
    && cp "${EASYGITIAN_WINUSERDIR}/EasyGitian.env" "${EASYGITIAN_WINDIR}/EasyGitian.env" \
    && echo "Success getting EasyGitian from GitHub"
else  
  printf "\\nInstallation supported on MacOS and Debian based systems\\n\\n"
  test -z "$DEBUG" || read -n 1 -s -r -p "Press any key to continue"
  host=$(lsb_release -is)
  if [ "$host" = "Ubuntu" ]; then
     echo "export EASYGITIAN_UBU=true" >> ~/EasyGitian.env
     echo "export EASYGITIAN_OS=ubu" >> ~/EasyGitian.env
     printf "\\nInstalling on Ubuntu\\n"
     deb_check_host
  elif [ "$host" = "Debian" ]; then
     echo "export EASYGITIAN_DEB=true" >> ~/EasyGitian.env
     echo "export EASYGITIAN_OS=deb" >> ~/EasyGitian.env
     printf "\\nInstalling on Debian\\n"
     test -z "$DEBUG" || read -n 1 -s -r -p "Press any key to continue"
     deb_check_host
  else 
    printf "\\nYou need to run EasyGitian on Windows10 WSL with Ubuntu, MacOS, Ubuntu, or Debian"
     exit 9
  fi 
fi


