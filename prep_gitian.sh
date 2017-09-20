#!/bin/bash -x
mkdir ~/tmp-git
cd ~/tmp-git
git clone https://github.com/devrandom/gitian-builder
cp -av gitian-builder ~
cd ~
git clone https://github.com/bitcoin-abc/bitcoin-abc
git clone https://github.com/bitcoin-core/gitian.sigs
ln -s ~/bitcoin-abc ~/gitian-builder/
ln -s ~/gitian.sigs ~/gitian-builder/
cd ~/gitian-builder
./bin/make-base-vm --lxc --arch amd64 --suite trusty
