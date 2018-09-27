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
   -  AMD-v capabilities (linux hosts)
## user configurability
   - ram/cpu allocation
   - easygitianbuilder dir location
   - VirtualBox location
   - vagrant/vbox binaries location


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
   - Vagrant should work with gentoo and Arch as well
   - Devuan support
   - make sdk tarball

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



Install_EasyGitian.sh:49:     #  test gpg properly
Install_EasyGitian.sh:188:   #  should be EASYGITIAN_DIR
Make_SDK_tarball.sh:6:## 
USER_CONFIG.sh:17: #  make function to ask for and regurgitate each variable needed
USER_CONFIG.sh:19: #  check t/f answers are correct 
USER_CONFIG.sh:20: #  check URLs are valid git repos
darwin-Base-System.sh:65:#  - if mojave user doesn't allow the kernel module to load
linux-Base-System.sh:9:# 
linux-Base-System.sh:69:##  this is probably not good
prep_gitian.sh:32:#  these are really slow in Virtualbox
