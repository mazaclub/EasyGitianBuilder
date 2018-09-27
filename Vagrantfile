# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
# From Hashicorp (Vagrant) website:
# Checksums for versioned boxes or boxes from HashiCorp's Vagrant Cloud: 
# For boxes from HashiCorp's Vagrant Cloud, 
# the checksums are embedded in the metadata of the box. 
# The metadata itself is served over TLS and its format is validated.
  config.vm.box = "debian/contrib-jessie64"
  config.vm.box_version = "8.5.0"
  config.vm.hostname = "gitian-jessie"
  config.vm.post_up_message = "Run ./EasyGitian to start building or 'vagrant ssh' to login directly"
  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
   config.vm.network "forwarded_port", guest: 22, host: 22222

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"
   # share some more dirs to the host for builds 
  config.vm.synced_folder ".", "/host_vagrantdir"
  #config.vm.synced_folder "./build", "/home/vagrant/gitian-builder/build"
  config.vm.synced_folder "./binaries", "/home/vagrant/bitcoin-binaries"
  config.vm.synced_folder "./cache", "/home/vagrant/gitian-builder/cache"
  config.vm.synced_folder "./inputs", "/home/vagrant/gitian-builder/inputs"
  config.vm.synced_folder "./results", "/home/vagrant/gitian-results"
  config.vm.synced_folder "./repos", "/home/vagrant/repos"
  
  config.vm.define "Gitian-builder_jessie"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
   config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
     vb.gui = true
     vb.name = "Gitian-builder_jessie"

  #
  #   # Customize the amount of memory on the VM:
     vb.memory = "8192"
     #vb.customize ["modifyvm", :id, "--cpus", `#{RbConfig::CONFIG['host_os'] =~ /darwin/ ? 'sysctl -n hw.ncpu' : 'nproc'}`.chomp]

 host = RbConfig::CONFIG['host_os']
## Give VM 1/4 system memory & access to all cpu cores on the host
     if host =~ /darwin/
          cpus = `sysctl -n hw.ncpu`.to_i
          guestmem = `sysctl -n hw.memsize`.to_i / 1024 / 1024
##          # sysctl returns Bytes and we need to convert to MB
##     #     mem = `sysctl -n hw.memsize`.to_i / 1024 / 1024 / 4
     elsif host =~ /linux/
          cpus = `nproc`.to_i
	  guestmem = `sed -n -e '/^MemTotal/s/^[^0-9]*//p' /proc/meminfo`.to_i / 1024
##      #    mem = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024 / 4
     else
          cpus = `wmic cpu get NumberOfCores`.split("\n")[2].to_i
	  guestmem = `wmic OS get TotalVisibleMemorySize`.split("\n")[2].to_i / 1024
##       #   mem = `wmic OS get TotalVisibleMemorySize`.split("\n")[2].to_i / 1024 /4
   end
   cpus = cpus - 1
   guestmem = guestmem - 2048
   vb.customize ["modifyvm", :id, "--cpus", cpus , "--memory", guestmem]
   end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
   config.vm.provision "shell", inline: <<-SHELL
   apt-get update
   apt-get install -y git ruby sudo apt-cacher-ng qemu-utils debootstrap lxc python-cheetah parted kpartx bridge-utils make ubuntu-archive-keyring curl lxc
   #
   # the version of lxc-start in Debian needs to run as root, so make sure
   # that the build script can execute it without providing a password
   echo "%sudo ALL=NOPASSWD: /usr/bin/lxc-start" > /etc/sudoers.d/gitian-lxc
   echo "%sudo ALL=NOPASSWD: /usr/bin/lxc-execute" >> /etc/sudoers.d/gitian-lxc
   # make /etc/rc.local script that sets up bridge between guest and host
   echo '#!/bin/sh -e' > /etc/rc.local
   echo 'brctl addbr br0' >> /etc/rc.local
   echo 'ifconfig br0 10.0.3.2/24 up' >> /etc/rc.local
   echo 'iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE' >> /etc/rc.local
   echo 'echo 1 > /proc/sys/net/ipv4/ip_forward' >> /etc/rc.local
   # lxc-execute is failing on first start after reboot, this fixes that
   echo 'test -f /home/vagrant/gitian-builder/var/lxc.config && /usr/bin/lxc-execute -n gitian -f /home/vagrant/gitian-builder/var/lxc.config -- sudo -u root -i -- ps' >> /etc/rc.local
   echo 'exit 0' >> /etc/rc.local
   # make sure that USE_LXC is always set when logging in as debian,
   # and configure LXC IP addresses
   echo 'export USE_LXC=1' >> /home/vagrant/.profile
   echo 'export GITIAN_HOST_IP=10.0.3.2' >> /home/vagrant/.profile
   echo 'export LXC_GUEST_IP=10.0.3.5' >> /home/vagrant/.profile
   cd /home/vagrant
   wget http://archive.ubuntu.com/ubuntu/pool/universe/v/vm-builder/vm-builder_0.12.4+bzr494.orig.tar.gz
   echo "76cbf8c52c391160b2641e7120dbade5afded713afaa6032f733a261f13e6a8e  vm-builder_0.12.4+bzr494.orig.tar.gz" | sha256sum -c
   tar -zxvf vm-builder_0.12.4+bzr494.orig.tar.gz
   cd vm-builder-0.12.4+bzr494
   python setup.py install
   # xenial scripts are missing on the installed version of debootstrap
   wget http://ftp.us.debian.org/debian/pool/main/d/debootstrap/debootstrap_1.0.91_all.deb
   dpkg -i debootstrap_1.0.91_all.deb

   chown -R vagrant.vagrant /home/vagrant
   su - vagrant -c /host_vagrantdir/prep_gitian.sh
   /etc/rc.local
   su - vagrant -c '/host_vagrantdir/lxc-vm-test.sh'
   ln -s /host_vagrantdir/gitian-build.sh /home/vagrant/run-gitian-build
   SHELL


end
