#!/bin/bash 
# Copyright (c) 2017 MAZA Network Developers, Robert Nelson (guruvan)

## This script runs inside the virtualbox vm 
test -f /host_vagrantdir/EasyGitian.env && source /host_vagrantdir/EasyGitian.env
if [ "$EASYGITIAN_DEBUG}" = "true" ] ; then
   DEBUG=true
   set -xeo pipefail
fi
test -f /host_vagrantdir/USER_CONFIG.env && source /host_vagrantdir/USER_CONFIG.env

## install shyaml to easily parse gitian-descriptors

sudo apt-get install -y python-pip
sudo pip install shyaml


# gitian-builder directory has shared folders mounted
# prior to cloning 
mkdir ~/tmp-git
pushd ~/tmp-git || exit 4
git clone https://github.com/devrandom/gitian-builder
if [ "$DEBUG" = "true" ] ; then 
   cp -av gitian-builder ~
else
   cp -a gitian-builder ~
fi
popd
# Just use examples for now
# We need the user's chosen repo in order to make the 
# proper base-vm below

REPO=${VGITIAN_URL:-https://github.com/bitcoin-abc/bitcoin-abc}
REPODIR=$(echo "${REPO}" | awk -F/ '{print $NF}')
SIGREPO=${VGITIAN_SIGREPO:-https://github.com/bitcoin-core/gitian.sigs}
# TODO these are really slow in Virtualbox
# we already have these repos, we should use then
git clone "${REPO}"
git clone "${SIGREPO}"
# make sure these appear in ~/ and ~/gitian-builder

SUITES="$(shyaml get-value suites <  "${REPODIR}"/contrib/gitian-descriptors/gitian-linux.yml|awk '{print $2}')"
ARCHES="$(shyaml get-value architectures <  "${REPODIR}"/contrib/gitian-descriptors/gitian-linux.yml|awk '{print $2}')"
suites="${SUITES:-trusty}"
arches="${ARCHES:-amd64}"

for suite in $suites ; do
  for arch in ${arches} ; do
    pushd ~/gitian-builder || exit 4
    ./bin/make-base-vm --lxc --arch "${arch}" --suite "${suite}"
    popd
  done
done
