#!/bin/bash

## This script runs inside the virtualbox vm 


# gitian-builder directory has shared folders mounted
# prior to cloning 
mkdir ~/tmp-git
cd ~/tmp-git
git clone https://github.com/devrandom/gitian-builder
cp -av gitian-builder ~
cd ~
# Just use examples for now
git clone https://github.com/bitcoin-abc/bitcoin-abc
git clone https://github.com/bitcoin-core/gitian.sigs
# make sure these appear in ~/ and ~/gitian-builder
ln -s ~/bitcoin-abc ~/gitian-builder/
ln -s ~/gitian.sigs ~/gitian-builder/
cd ~/gitian-builder
./bin/make-base-vm --lxc --arch amd64 --suite trusty

