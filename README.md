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

## Quick Start

#### macOS, Debian, Ubuntu
  ```
  wget https//raw.githubusercontent.com/mazaclub/easygitianbuilder/v0.1.0/Install_EasyGitian.sh
  chmod +x Install_EasyGitian.sh
  ./Install_EasyGitian.sh
  source ~/EasyGitian.env
  ./EasyGitian
  ```
#### Windows with WSL & Ubuntu
_See README-Windows.md_


## Using EasyGitian

EasyGitian will attempt to install what is needed to build a VM and install gitian 
The build environment is configured, and you'll be asked
  - which steps to run (build, sign, verify) 
  - which OSes to build for (Linux, Windows, OSX) 
  - what release version and/or git commit tag to build from
  - signer ID
  - git url to fetch coin code from
  - git url for gitian signatures
  - whether or not to assert your signature on the build
  - whether or not to sign the final binaries

You should be able to build most coins that provide a contrib/gitian-descriptors directory
in the same fashion as Bitcoin, BitcoinCash, Maza. 

EasyGitian will attempt to read the gitian-descriptors files to determine 
what build system and architecture you need in your build environment 
to build your chosen coin. (please post errors in the github issues in this repo) 

Look in the repo library for your chosen coin for {coin}-detached-sigs and gitian.sigs repositories
(i.e. https://github.com/mazacoin/gitian.sigs https://github.com/pivx-project/pivx-detached-sigs)
These are needed to assert and/or verify your build. When EasyGitian configures your build,
it will ask for these URLs and ask if you'd like to Verify the builds.

When EasyGitian verifies the build, it will ensure you have the keys found in 
(i.e. https://github.com/mazacoin/maza/contrib/gitian-keys) and compare the hashes from your build 
to those found in the gitian.sigs repo, and show you any mismatches. 

Future versions will fully support developer's assertions and commit assertions to the gitian.sigs repo


### OSX
  - Ensure sufficient disk space is available
    EasyGitian will require there be 50GB available for Virtualbox VMs 
    and 20GB available for its own directory. Typically these will be in
    `/Users/{YOUR_ACCT_NAME}/Virtualbox VMs/`
    `/Users/{YOUR_ACCT_NAME}/easygitianbuilder`
    If these are on the same volume, 50GB is sufficient
  - Install GPG
  - Install Xcode OR "Developer Command Line Tools"
  - Clone this repo
  - Run EasyGitian to install Vagrant & Virtualbox, build a VM and build software

If you need assistance installing GPG and Xcode tools and getting this repo cloned via git,
an installer is provided:

(Open a Terminal)

  ```
  curl -O https://raw.githubusercontent.com/mazaclub/easygitianbuilder/v0.1.0/Install_EasyGitian.sh
  cat Install_EasyGitian.sh
  chmod +x Install_EasyGitian.sh
  ./Install_EasyGitian.sh
  ```
You'll be given a choice to install GPG from GPGTools.org or via Homebrew, and
install either Xcode or the required Developer Command Line tools. This repo 
will be cloned, and EasyGitian will be started for you.

If your system already has this, you can simply clone the repo, and get started:

  ```
  git clone https://github.com/mazaclub/EasyGitianBuilder easygitianbuilder
  cd ./easygitianbuilder
  ./EasyGitian
  ```

Vagrant & Virtualbox will be downloaded, verified, and installed
A Vagrant "base box" (debian-contribjessie) will be downloaded
EasyGitian will build a Vagrant/Virtualbox VM and setup a build environment
A build will begin.
  
To run another build, simply open a terminal and
  ```
  cd $HOME/easygitianbuilder
  ./EasyGitian
  ```

Additional help is available in easygitianbuilder/USAGE.md or
  ```
  cd $HOME/easygitianbuilder
  ./EasyGitian -h
  ```



### Linux (Debian)
  
Open a Terminal window

  ```
  git clone https://github.com/mazaclub/easygitianbuilder
  cd ./easygitianbuilder
  ./EasyGitian
  ```

Vagrant downloaded, verified, and installed, your apt-sources will be updated,
and Virtualbox (and extension pack) will be installed via apt.

A Vagrant "base box" (debian-contribjessie) will be downloaded
EasyGitian will build a Vagrant/Virtualbox VM and setup a build environment
A build will begin.
  
To run another build, simply open a terminal and
  ```
  cd $HOME/easygitianbuilder
  ./EasyGitian
  ```

Additional help is available in easygitianbuilder/USAGE.md or
  ```
  cd $HOME/easygitianbuilder
  ./EasyGitian -h
  ```


### Windows

Operation in Windows10 works with Ubuntu in Windows Subsystem for Linux
An Installer for WSL and Ubuntu is provided at 
https://raw.githubusercontent.com/mazaclub/easygitianbuilder/v0.1.0/Install_WSL_EasyGitian.ps1
Download that script, right click and run it a few times and Ubuntu will appear. 

If you have WSL and ubuntu already, EasyGitian should work for you. 
Download this to your home directory
  ```wget https://raw.githubusercontent.com/mazaclub/easygitianbuilder/v0.1.0/Install_EasyGitian.sh
  chmod +x Install_EasyGitian.sh
  ```

Now, however you've done the above run
  ```./Install_EasyGitian.sh
  source EasyGitian.env
  ./EasyGitian
  ```

See README-Windows.md   

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

A similar project [gitian-docker](https://github.com/mazacoin/gitian-docker) provides nearly the same functionality
but is less portable due to docker's changing handling of host filesytem access on Windows and OSX. Vagrant 
orchestrated virtual machines seem more reliable on local systems than docker. Vagrant provides the ability to expand 
to several VPS providers (notably AWS, DigitalOcean, Vultr), and will allow for EasyGitian to spawn high-powered ephemeral 
build machines 


## Work in progress 

 - Uses debian provided Vagrant base box, all modifications done at runtime
 - Uses modified gitian-build.sh from Bitcoin
 - Uses standard gitian-builder repo to build with an Ubuntu trusty-amd64 LXC vm


## OSX 

 EasyGitian will attempt to ensure that you have Vagrant and Virtualbox 
 installed, and download and help you to install them if needed. 
 
 Tested with:
 Vagrant 2.1.4
 VirtualBox 5.2.18

 You'll then be given the opportunity to download Xcode from 
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

 EasyGitian will attempt to install Vagrant 2.1.4 and Virtualbox 5.2.18 on Debian9
 Vagrant 2.0 and VirtualBox 5.1.28 will be installed on other debian based systems


    
