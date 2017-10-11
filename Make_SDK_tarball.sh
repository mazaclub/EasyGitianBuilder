#!/bin/bash
# Copyright (c) 2017 MAZA Network Developers, Robert Nelson (guruvan)

## This script runs on the host 

## TODO
##  - this script currently only supports OSX
##  - linux can open the dmg, and make the tarball 



mark_skipped () {
touch ./.skip_osx_builds
}

get_answer () {
 read -r tarball
mktarball=$(echo "${tarball}" | tr '[:upper:]' '[:lower:]')
}

check_linux () {
 case $1 in 
   d) echo "Downloaded from other sources - checking your tarball now" 
      test -f inputs/MacOSX10.11.sdk.tar.gz || check_linux s
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
   d) read -n 1 -s -r -p "Press any key to continue once you have Xcode Downloaded to your Downloads directory or this one";echo
      echo "Downloaded Xcode, making tarball"
      test -f ~/Downloads/Xcode_7.3.1.dmg && hdiutil attach ~/Downloads/Xcode_7.3.1.dmg 
      test -d /Volumes/Xcode || test -f ./Xcode_7.3.1.dmg && hdiutil attach ./Xcode_7.3.1.dmg
      test -d /Volumes/Xcode || exit 99
      test -d ./inputs || mkdir -v ./inputs
      pushd ./inputs || exit 4
      tar -C /Volumes/Xcode/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/ -czf MacOSX10.11.sdk.tar.gz MacOSX10.11.sdk
      test -f MacOSX10.11.sdk.tar.gz || exit 3
      popd
      echo "MacOSX 10.11 SDK tarball created"
   ;;
   s) echo "Skipped download, not making tarball - please maksure it is in the inputs directory in this directory"
      read -n 1 -s -r -p "Press any key to continue once you have a tarball in the inputs directory";echo
      test -f inputs/MacOSX10.11.sdk.tar.gz || exit 2
   ;;
   *) echo "Download or Skip? Please answer d/s: "
      get_answer
   ;;
esac
}
download_skip () { 
echo "Do you intend to build OSX versions?"
echo "If so, you'll need an Apple Developer ID to Download Xcode_7.3.1 and extract the SDK as a tarball"
echo "Or ou can skip OSX builds"
echo " "
echo "Press d to download"
echo "Press s to skip OSX builds"
get_answer
case "${mktarball}" in 
  d) echo "Proceeding to tarball install"
     download_tarball
   ;;
  s) echo "Skipping OSX builds"
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
      Now Open a browser and obtain https://developer.apple.com/devcenter/download.action?path=/Developer_Tools/Xcode_7.3.1/Xcode_7.3.1.dmg
      If you do not have an Apple Developer ID, you will need to register for one to download Xcode
      Xcode is about 5GB
      When the download is complete, make sure that Xcode_7.3.1.dmg is in either this directory or your Downloads directory
      You are setting up an OSX system. If you don't want to build OSX binaries you may skip downloading Xcode
      You may also skip this download if you've previously created the SDK tarball for 10.11 (from Xcode 7.3.1)
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
download_skip
