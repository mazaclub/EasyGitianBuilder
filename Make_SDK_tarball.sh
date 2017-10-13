#!/bin/bash
# Copyright (c) 2017 MAZA Network Developers, Robert Nelson (guruvan)

## This script runs on the host 

## TODO
##  - this script currently only supports OSX
##  - linux can open the dmg, and make the tarball 



test -f USER_CONFIG.env || { echo "Please configure the Build environment variables. Run: ./EasyGitian make_env"; exit 1; }
. ./USER_CONFIG.env
test -d ./repos/"${VGITIAN_COIN}" || { echo "Your coin repo is not downloaded yet. Run: ./EasyGitian get_repos"; exit 2; }

get_sdkver () {
  SDKNAME=$(grep "sdk.tar.gz" repos/"${VGITIAN_COIN}"/contrib/gitian-descriptors/gitian-osx.yml|grep -v "BASEPREFIX")
  SDKVER=$(echo "$SDKNAME"| awk -F [X.] '{print $2"."$3}') 
}

get_xcodever () {
  printf "\n\nNote that various versions of XCode may include the %s SDK Version you want\n" "${SDKVER}"
  printf "and may have different compiler versions included\nThis will affect your build output hashes\n"
  printf "\nCheck the repository for the coin you're building\n"
  printf "EasyGitian has no way to know if other gitian builders of your coin\n"
  printf "have chosen a different XCode version to get the SDK than what we guess here\n\n"

  case "$SDKVER" in
    10.7) 
         XCODEVER=4.3.2
         printf "\nXCode Version for SDK Version %s is 4.3.3\n" "${SDKVER}"
	 ;;
    10.8)
         XCODEVER="4.4"
         printf "\nXCode Version for SDK Version %s is 4.4\n" "${SDKVER}"
	 ;;
    10.9)
         XCODEVER="5.1"
         printf "\nXCode Version for SDK Version %s is 5.1\n" "${SDKVER}"
	 ;;
    10.10)
         XCODEVER=6.3
         printf "\nXCode Version for SDK Version %s is 6.3\n" "${SDKVER}"
	 ;;
    10.11)
         XCODEVER="7.3.1"
         printf "\nXCode Version for SDK Version %s is 7.3.1\n" "${SDKVER}"
	 ;;
        *)
	 printf "\nUnknown Version of SDK - please check your coin's repo for more information\n"
	 ;;
   esac
}

mark_skipped () {
touch ./.skip_osx_builds
}

get_answer () {
 read -r -n1  tarball
mktarball=$(echo "${tarball}" | tr '[:upper:]' '[:lower:]')
}

check_linux () {
 case $1 in 
   d) echo "Downloaded from other sources - checking your tarball now" 
      test -f inputs/MacOSX"${SDKVER}".sdk.tar.gz || check_linux s
      exit
    ;;
   s) echo "SDK tarball not available in ./inputs, skipping OSX builds"
      touch ./.skip_osx_builds
   ;;
  esac
}
ball_it () {
# If we didn't skip download, let's make a tarball
case $1 in 
   d) 
      printf "\nExpecting your Xcode Download to be Xcode_%s.dmg" "${XCODEVER}"
      read -r -s -p -n1 "Is this correct? [y/n]" answer
      case ${answer} in 
         [Yy])  
	     printf "Please Download Xcode_%s.dmg from Apple Developer's site now\n" "${XCODEVER}"
	     ;;
            *)
             read -r -s -p "Enter a different Xcode version number now:" XCODEVER;echo
	     ;;
      esac
      read -n 1 -s -r -p "Press any key to continue once you have Xcode_${XCODEVER}.dmg Downloaded to your Downloads directory or this one";echo
      echo "Checking downloaded Xcode, making tarball"
      test -f ~/Downloads/Xcode_"${XCODEVER}".dmg && hdiutil attach ~/Downloads/Xcode_"${XCODEVER}".dmg 
      test -d /Volumes/Xcode || { test -f ./Xcode_"${XCODEVER}".dmg && hdiutil attach ./Xcode_"${XCODEVER}".dmg; }
      test -d /Volumes/Xcode || exit 99
      test -d ./inputs || mkdir -v ./inputs
      pushd ./inputs || exit 4
      tar -C /Volumes/Xcode/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/ -czf MacOSX"${SDKVER}".sdk.tar.gz MacOSX"${SDKVER}".sdk
      test -f MacOSX"${SDKVER}".sdk.tar.gz || exit 3
      popd
      printf "\nMacOSX %s SDK tarball created\n" "${SDKVER}"
   ;;
   s) echo "Skipped download, not making tarball - please maksure it is in the inputs directory in this directory"
      read -n 1 -s -r -p "Press any key to continue once you have a tarball in the inputs directory";echo
      test -f inputs/MacOSX"${SDKVER}".sdk.tar.gz || exit 2
   ;;
   *) echo "Download or Skip? Please answer d/s: "
      get_answer
   ;;
esac
}
download_skip () { 
printf "\nDo you intend to build OSX versions?\n"
printf "Since the SDK is not redistributable, you'll need an \n"
printf "Apple Developer ID to Download Xcode_%s \nand extract the SDK as a tarball\n\n" "${XCODEVER}"
echo "Or you can skip OSX builds"
echo " "
echo "Press d to download and make a tarball"
echo "Press s to skip OSX builds"
get_answer
case "${mktarball}" in 
  [Dd]) 
      echo "Proceeding to tarball install"
      download_tarball
      ;;
  [Ss]) 
      echo "Skipping OSX builds"
      touch ./.skip_osx_builds
      exit 1
      ;;
     *) get_answer
      ;;
esac
}
download_tarball () {
  # login to developer.apple.com and download the SDK
   HOSTOS="$(uname |tr '[:upper:]' '[:lower:]')"
  if [ "${HOSTOS}" = "darwin" ] ; then
     cat << END
      Now Open a browser and obtain:
       https://developer.apple.com/devcenter/download.action?path=/Developer_Tools/Xcode_${XCODEVER}/Xcode_${XCODEVER}.dmg
      If you do not have an Apple Developer ID, you will need to register for one to download Xcode
      Xcode is about 5GB
      When the download is complete, make sure that Xcode_${XCODEVER}.dmg is in either this directory or your Downloads directory
      You are setting up an OSX system. If you don't want to build OSX binaries you may skip downloading Xcode
      You may also skip this download if you've previously created the SDK tarball for ${SDKVER} (from Xcode ${XCODEVER})
      If you've already created the SDK tarball, this is a great time to move it to the inputs directory in this directory
END
     
     echo "Press D to continue after downloading or"
     echo "Press S to skip making the tarball"
     get_answer
     ball_it "${mktarball}"
  elif [ "${HOSTOS}" = "linux" ] ; then
     cat << END
      Making the tarball isn't supported (yet) on Linux
      You can place one in ./inputs and it will be used to build OSX versions
      Otherwise you can mark this step as Skipped
END
     get_answer
     check_linux "${mktarball}"
  else 
     echo "Host not recognized - report github issue"
     exit 2
  fi
 } 

test -f  ./.skip_osx_builds && rm ./.skip_osx_builds
get_sdkver
get_xcodever
download_skip
