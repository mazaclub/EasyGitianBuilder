# Easy Gitian Building for Coin projects

EasyGitian provides a means of building a Virtual Machine in Virtualbox 
(more coming) capable of building coin projects with LXC containers 
as described in bitcoincore's gitian-building and release-process documents.

EasyGitian provides scripts for OSX & Linux to operate Vagrant & Virtualbox, 
(VPS providers coming soon) and a Vagrantfile to get your build system up 
and running quickly

EasyGitian is usuable on Windows, but requires the builder to use vagrant 
to operate the Virtual Machine directly, rather than having most operations scripted
(batch/powershell scripts welcome!) 

## Why Easy Gitian builder
Gitian building is generally too difficult for most people to 
get done easily, and reliably. Instructions are less than 
clear if you don't have a background in most of the tech 
being used, and the tech though widely used isn't necessarily 
well understood by most users.

gitian-builder provides a Vagrantfile to pull cloud boxes from ubuntu for several 
different versions, and the stock bin/make-base-vm and libexec/make-clean-vm support virtualbox,
but it's unclear the intended use or operation of these VMs. 

LXC based building is an interim step - gitian-builder's gbuild script doesn't fully support bulding in virtualbox
or other cloud-based VMs. 

A similar project [gitian-docker](https://github.com/maza/gitian-docker) provides nearly the same functionality
but is less portable due to docker's changing handling of host filesytem access on Windows and OSX. Vagrant 
orchestrated virtual machines seem more reliable on local systems than docker. Vagrant provides the ability to expand 
to several VPS providers (notably AWS, DigitalOcean, Vultr), and will allow for EasyGitian to spawn high-powered ephemeral 
build machines 


## Work in progress 
 - Windows is not fully automated. Use is possible via
   Vagrant commands 

 - Uses debian provided Vagrant base box, all modifications done at runtime
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

 Debian, Ubuntu and CentOS are supprted directly by Vagrant
 Currently, only Debian based systems are supported in EasyGitian

 Linux operation is similar but mostly untested
 
 On debian stretch & jessie virtualbox is installed via apt
 On other debian based systems (including ubuntu for now) 
 an attempt is made to download the .deb file for your host system and install via dpkg 


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
      
  start the machine the first time and provision all gitian's requirements

  ```
  vagrant up
  ```

  Once provisioning for the machine is complete, halt and make a snapshot

  ```
  vagrant halt
  vagrant snapshot save default Gitian-Clean
  vagrant up
  vagrant ssh
  ```

  Once you've logged in via `vagrant ssh` you can run: 

  ```
  ./run-gitian-build
  ```
       
  to completely rebuild your VM and lose all snapshots

  ```
  vagrant destroy
  vagrant up
  ```
    
    - Scripts intended to be used inside the vm are in all lowercase - other scripts are intended for use on the host
      (darwin-base-system.sh and linux-base-system.sh are exceptions at this time)
 
    - This directory is mounted in the VM as /host_vagrantdir
