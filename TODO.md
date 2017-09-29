# Improvements Needed

 
## signing and verification are not implemented
## more basic sanity checking is required throughout
   - disk space on host should be checked
   - check available host ram 
   - check for VT-x / AMD-v capabilities (linux hosts)

## test linux install 
## organize scripts
   - vm data should be in their own dir

## Complete Linux-base-system.sh
  - needs testing on debian and ubuntu base systems

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



