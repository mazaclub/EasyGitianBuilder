# Easy Gitian Buidling

## Version 0.0.1

## Requirements
 - Vagrant
 - VirtualBox
 - MacOS SDK 10.11

## Setup
 1. have cloned this repo to your local machine 
 2. prepare the build environment
     - automated
       Run the Base script for your machine
         - OSX_base-system.sh
         - Linux_base-system.sh
         - Windows_base-system.bat
       Scripts will 
         - download, verify, (assist) install Vagrant & Virtualbox
         - clone needed git repositories
	 - assist download of Xcode, make needed tarball
	 - prepare the environment variables needed for building 
     - manual
       Download and install VirtualBox
       Download and install Vagrant
       Download Xcode 7.3.1 from Apple Developers site to this directory
       Extract SDK & make tarball in inputs directory
       Prepare a build environment file (USER_CONFIG.sh)
## Usage 
 in this directory run 
    ```
    vagrant up
    ```
    - the first run will download the base debian virtualbox image for you
    - the first run will setup the gitian build environment for you
    Once this is complete you can reboot the VM 
    
    ```
    vagrant halt
    vagrant up
    ```
    And the you can run the build!
    ```
    vagrant ssh -c ./run-gitian-build
    ```
 The results of your build will be in the following directories on the base host system
   - Binaries in ./binaries
   - Gitian hashs in ./results
   - cache of downloaded dependencies in ./cache/common
   - cache of compiled dependencies in ./cache/bitcoin-{OS}-{VERSION}


## Notes for Advanced users

 - ./ is shared to the VM at /host_vagrantdir 
 - shared folder mounts inside the VM do not remount on reboot, instead use
   ```
   vagrant reload
   ```
   or
   ```
   vagrant halt ; vagrant up
   ```
 - list or recover build artifacts
   ```
   mount -o loop -t ext4 /home/vagrant/gitian-builder/target-trusty-amd64 /mnt
   ls -la /mnt/home/ubuntu
   ```
 - Vagrant selects the number of CPUs to use dynamically
   uncomment code in Vagrantfile to set CPUs to use manually
 - 
