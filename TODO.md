# Improvements Needed


## proper handling of build output
   - binaries copied to correct output dirs
   - results saved by date/OS/coin

## signing and verification are not implemented

## more basic sanity checking is required throughout
   - check available host ram 
   - check for VT-x / AMD-v capabilities (linux hosts)
   - get correct user directory for VirtualBox_VMs dir
     (currently presumes a default installation) 

## linux install 
   - working on Debian Jessie host
   - need to add install for CentOS & Ubuntu

## Windows batch/powershell programming
  - make Vagrant/Virtualbox/SDK installation automated on Windows 
  - convert shellscripts to  powershell/bat files

## Fix windows errors
  - Manual edit of USER_CONFIG.env produces Dos files, convert to unix 

## organize scripts
   - vm data should be in their own dir

## allow user to select specific builds for each OS
   - build script / typical gitian-descriptors for most coins 
     will have multiple versions built for each OS 
   - users may wish to produce a verifiable build for only the 
     specific version they want to use
   - allow user to build for only 1 specific architecture rather
     than building 32 & 64 bit versions or architectures

## gitian-build.sh (run-gitian-build) should copy data as completed
   - current build waits till entire descriptor for OS is complete.
   - this prevents completed deps from being saved if the build 
     for that OS fails. 


## De-bitcoin-ify builds
  - factor variables to replace hardcoded "bitcoin" references
  - allow to build multiple coins on the same VM


## add other vagrant providers
  - aws
  - digitalocean
  - allow user to set machine size for faster builds
  - allow user to create ramdisk for faster builds
  - allow user to choose spot pricing 



