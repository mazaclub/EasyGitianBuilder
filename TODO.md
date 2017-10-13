# Improvements Needed

## multi coin operation 
   - Get correct OSX SDK tarball for each coin
   - get suite from gitian-descriptors for each coin
      - tested on single suite builds - working

## signing and verification are not tested
   - steps more separated, untested
   - Verification & key import tested and working
   - Assertion and commit to gitian.sigs repos not yet fully implemented
   - gpg and git credentials need to be available inside the VBox VM 

## more basic sanity checking is required throughout
   - check available host ram 
   - check for VT-x / AMD-v capabilities (linux hosts)
   - get correct user directory for VirtualBox_VMs dir
     (currently presumes a default installation) 
   - Vbox warns about using more than the number of *physhical* processors 
     give use option of reducing number of procs used in VM

## add option to clear cache & inputs directories
   - clean built deps per coin
   - clean downloaded cache/common

## add option to install built wallet
   - find existing versions, ask before replacing 
   - install to /usr/local/bin on linux
   - install to (option) /Applications or ~/Applications on OSX

## linux install 
   - working on Debian Jessie host
   - need to add install for CentOS & Ubuntu
   - make sdk tarball

## Windows batch/powershell programming
  - make Vagrant/Virtualbox/SDK installation automated on Windows 
  - convert shellscripts to  powershell/bat files

## Fix windows errors
  - Manual edit of USER_CONFIG.env produces Dos files, convert to unix 

## organize scripts
   - vm data should be in their own dir

## allow user to select specific builds for each OS
   - build script / typical gitian-descriptors for most coins 
     will have multiple versions built for each OS in the HOSTS variable
   - users may wish to produce a verifiable build for only the 
     specific version they want to use
   - allow user to build for only 1 specific architecture rather
     than building 32 & 64 bit versions or architectures
   - possibly change gitian-builder/var/build-script on the fly
     but unclear if this affects results

## gitian-build.sh (run-gitian-build) (and gitian-builder/bin/gbuild) should copy data as completed
   - current build waits till entire descriptor for OS is complete.
   - this prevents completed deps from being saved if the build 
     for that OS fails even if dep build was successful
   - test mounting target-{ARCH}-{SUITE} to get files early
  


## add other vagrant providers
  - aws
  - digitalocean
  - allow user to set machine size for faster builds
  - allow user to create ramdisk for faster builds
  - allow user to choose spot pricing 



