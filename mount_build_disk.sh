#!/bin/bash -x

## This script runs inside the VM

# Partition the disk
sudo sfdisk /dev/sdb << EOF
;
EOF

# Make Filesystem
sudo /sbin/mkfs.ext4 /dev/sdb1
# mount && touch file
sudo mount /dev/sdb1 /mnt
# move data 
#sudo cp -avx  /home/vagrant/* /mnt
sudo tar -C /home/vagrant --one-file-system --exclude gitian-builder/base-trusty-amd64 --exclude gitian-builder/target-trusty-amd64  -cpv .  | sudo tar -C /mnt -xpf - 
sudo cp -a --sparse=always /home/vagrant/gitian-builder/base-trusty-amd64 /mnt/gitian-builder/
sudo cp -a --sparse=always /home/vagrant/gitian-builder/target-trusty-amd64 /mnt/gitian-builder/
#sudo cp -avx  /home/vagrant/.??* /mnt

# no ssh causes error rebooting the vm via vagrant
sudo rm --one-file-system -rf  /home/vagrant
mkdir /home/vagrant 
cp -av /mnt/.ssh /home/vagrant/
sudo chown -R vagrant.vagrant /mnt

# add to fstab
sudo su -c 'echo "/dev/sdb1        /home/vagrant    ext4 defaults     0       0" >> /etc/fstab'
#echo "/dev/sdb1        /home/vagrant    ext4 defaults     0       0" >> /etc/fstab

# umount
sudo umount /mnt
