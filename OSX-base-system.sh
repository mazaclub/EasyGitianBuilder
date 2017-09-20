#!/bin/bash


# First install Virtualbox and Vagrant
# Vagrant 

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

# login to developer.apple.com and download the SDK
echo "Now Open a browser and obtain https://developer.apple.com/devcenter/download.action?path=/Developer_Tools/Xcode_7.3.1/Xcode_7.3.1.dmg"
echo "If you do not have an Apple Developer ID, you will need to register for one to download Xcode" 
echo "Xcode is about 5GB"
echo "When the download is complete, make sure that Xcode_7.3.1.dmg is in either this directory or your Downloads directory"
echo "You are setting up an OSX system. If you don't want to build OSX binaries you may skip downloading Xcode"
echo "You may also skip this download if you've previously created the SDK tarball for 10.11 (from Xcode 7.3.1)"
echo "If you've already created the SDK tarball, this is a great time to move it to the inputs directory in this directory" 


echo "Will you Download or Skip this step [D/S]?"
get_answer () {
 read tarball
mktarball=$(echo ${tarball} | tr '[:upper:]' '[:lower:]')


# If we didn't skip download, let's make a tarball
case $mktarball in 
   d) echo "Downloaded Xcode, making tarball"
      test -f ~/Downloads/Xcode_7.3.1.dmg && mv  ~/Downloads/Xcode_7.3.1.dmg .
      test -f ./Xcode_7.3.1.dmg || exit 4
      hdiutil attach Xcode_7.3.1.dmg
      test -d ./inputs || mkdir -v ./inputs
      cd ./inputs
      tar -C /Volumes/Xcode/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/ -czf MacOSX10.11.sdk.tar.gz MacOSX10.11.sdk
      test -f MacOSX10.11.sdk.tar.gz || exit 3
      cd ..
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
get_answer
echo "You have the SDK tarball in ./inputs"
echo "Creating build environment variables now..."
./USER_CONFIG.sh

echo "Now starting your gitian build VM for the first time"
echo "This will take some time as the proper build environment is created within the VM"
echo "gitiian-builder and needed repositories will be downloaded and installed"

vagrant up
echo "Now we'll reboot the VM and you'll be ready to build"
vagrant halt
sleep 10
vagrant up

echo "You're now ready to perform gitian builds"
echo "The first build will build all the dependencies as well as the application"
echo "for the systems you've chosen. This will take a good deal of time"
echo "If you've chosen to build for Linux, aarch, arm and x86_64 binaries are built"
echo "Running build in 30 seconds, press CTRL-C to abort"
sleep 30

vagrant ssh -c ./run-gitian-build
