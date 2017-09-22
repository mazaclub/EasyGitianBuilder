# Easy Gitian Building for Coin projects

 - Provides a Script set to operate Vagrant & Virtualbox
 - Provisions all requirements for gitian-builder to use lxc containers for building


Work in progress 
 - will not complete a full buildset at this time
 - base box used has too small disk
 - Linux is untested, may or may not succeed at building 
 - Windows is not fully automated. Use is possible via
   Vagrant commands 

 - Uses modified gitian-build.sh from Bitcoin
 - Uses standard gitian-builder repo to build with an Ubuntu trusty-amd64 LXC vm

## OSX 
 EasyGitian will attempt to ensure that you have Vagrant and Virtualbox 
 installed, and download and help you to install them if needed. 
 
 Tested with:
 Vagrant 2.0 
 VirtualBox 5.1

 You'll then be given the opportunity to download Xcode_7.3.1 from 
 the Apple Developers site, and produce the SDK tarball required to 
 build OSX version of coins.

 Vagrant is used to create and launch a Virtualbox VM, and provision it 
 with all your needs to build with gitian. A clean snapshot is saved for refreshing 
 your build host, and a build is begun. 

 Environment variables needed to run the build are requested at the begining of the build,
 or may be made and saved prior to the second build. 
 
 Gitian building is done inside the VM in an lxc container VM.

 Results, binaries, cached compiled dependencies are all saved in this directory for you.
 
 EasyGitian Usage documented in USAGE.md
 Manual operation is possible, and outlined below

## Linux 
 Linux operation is similar but yet untested. 

## Windows, and manual usage
   Windows users will need to install Vagrant and VirtualBox (and the extension pack) 
   Once those are installed, clone this repository to a directory on your machine
    - ensure that git is not configured to change Line Endings to CRLF 
    - ensure that editors don't add CRLF to any files you edit
   
    - make directories in this directory for Vbox Shared Folders to save your builds
       binaries
       results
       inputs
       cache
    - optionally acquire the OSX SDK tarball required for 
      building OSX versions, and put in the inputs directory made above
    - run
      ```vagrant up
      ```
      to start the machine the first time and provision all gitian's requirements
    - Once provisioning for the machine is complete, halt and make a snapshot
      ```vagrant halt
      vagrant snapshot save default Gitian-Clean
      vagrant up
      vagrant ssh
      ```
    - on the VM commandline run
      ```./run-gitian-build
      ```
    - This directory is mounted in the VM as /host_vagrantdir 
    - to completely rebuild your VM and lose all snapshots
      ```vagrant destroy
      vagrant up
      ```
    
 
