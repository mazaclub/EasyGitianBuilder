#!/bin/bash
# Copyright (c) 2017 MAZA Network Developers, Robert Nelson (guruvan)

## This script runs inside the virtualbox vm 


# gitian-builder directory has shared folders mounted
# prior to cloning 
mkdir ~/tmp-git
pushd ~/tmp-git || exit 4
git clone https://github.com/devrandom/gitian-builder
cp -av gitian-builder ~
popd
# Just use examples for now
git clone https://github.com/bitcoin-abc/bitcoin-abc
git clone https://github.com/bitcoin-core/gitian.sigs
# make sure these appear in ~/ and ~/gitian-builder
ln -s ~/bitcoin-abc ~/gitian-builder/
ln -s ~/gitian.sigs ~/gitian-builder/
pushd ~/gitian-builder || exit 4
./bin/make-base-vm --lxc --arch amd64 --suite trusty
popd
