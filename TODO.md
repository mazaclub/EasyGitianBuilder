# Improvements Needed

## base box used doesn't have enough disk space to run the full build
 - use another base box
 - add another virtual disk
 
## signing and verification are not implemented

## lxc-execute fails on first attempt to run builds
 - TODO: check this fix
  1. Added lxc-vm-test.sh to run in Vagrant provisioning
     creates a clean vm and tests it 
  2. /etc/rc.local checks a test vm before building

  - appears libexec/make-clean-vm fails w lxc errors

  tail  /var/lib/lxc/gitian/gitian.log 
      lxc-execute 1505863798.808 ERROR    lxc_conf - failed to mount rootfs
      lxc-execute 1505863798.808 ERROR    lxc_conf - failed to setup rootfs for 'gitian'
      lxc-execute 1505863798.808 ERROR    lxc_conf - Error setting up rootfs mount after spawn
      lxc-execute 1505863798.809 ERROR    lxc_start - failed to setup the container
      lxc-execute 1505863798.809 ERROR    lxc_sync - invalid sequence number 1. expected 2
      lxc-execute 1505863798.865 ERROR    lxc_start - failed to spawn 'gitian'

  - second attempt to run build will succeed

## Complete Linux-base-system.sh
  - needs testing on debian and ubuntu base systems

## configure to use apt-cacher-ng if desired
  - 

## De-bitcoin-ify builds
  - factor variables to replace hardcoded "bitcoin" references
  - allow to build multiple coins on the same VM

## Windows powershell programming
  - make Vagrant/Virtualbox/SDK installation automated on Windows 
  - convert shellscripts to  powershell/bat files

## Fix windows errors
  - Manual edit of USER_CONFIG.env produces Dos files, convert to unix 

## add other vagrant providers
  - aws
  - digitalocean
  - allow user to set machine size for faster builds
  - allow user to create ramdisk for faster builds
  - allow user to choose spot pricing 



