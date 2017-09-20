# Improvements Needed

## lxc-execute fails on first attempt to run builds
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

## De-bitcoin-ify builds
  - factor variables to replace hardcoded "bitcoin" references
  - allow to build multiple coins on the same VM

## Windows powershell programming
  - make Vagrant/Virtualbox/SDK installation automated on Windows 
  - convert OSX-base-system.sh to powershell/bat file
  - convert USER_CONFIG.sh to powershell/bat file



