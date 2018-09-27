# EasyGitian on macOS

v0.1.0 has been primarily tesed with Mojave but should work with 
any version of macOS supported by Vagrant and Virtualbox

## Usage

Get a copy of Install_EasyGitian.sh and mark it executable

 ```
 curl -O https://raw.githubusercontent.com/mazaclub/master/Install_EasyGitian.sh
 chmod +x Install_EasyGitian.sh
 source ~/EasyGitian.env ## should put you n the easygitianbuilder directory)
 ./EasyGitian
 ```

 Install_EasyGitian.sh will help you get git and gpg which are required to install
 Vagrant and VirtualBox, and create ~/EasyGitian.env

## Errata

#### Install_EasyGitian.sh 
 
 This script checks for gpg - at the time of this release the GPGTools Suite 
 was undergoing change, and has been recently added to Homebrew. Script is not
 updated to permit install of gpgtools from homebrew. Website installation will 
 be removed from EasyGitian in a later version

 Install_EasyGitian.sh will install homebrew if needed, and install gnupg2 from homebrew
 if gpg isn't found on your system

#### Installation of VirtualBox may appear to fail
 Security policy on macOS may prevent the VirtualBox installation 
 from completing properly. VirtualBox attempts to load a driver without
 the proper Apple blessing. 
 
 User must Allow the driver load in the Security Prefeences pane.
 Option to allow does not appear in Securiy Preferences Pane

 A reboot at this stage should fix the issue. the Virtualbox driver 
 will attempt to load, and be blocked, providing the option to Allow 
 in the Security Preferences pane. 

#### Terminal would like to control this computer
 Noticed on Mojave, new security restrictions cause
 this notice dialog to appear when the VirtualBox VM is 
 first launched. Does not appear to have any effect to 
 allow or deny Terminal controlling the computer

