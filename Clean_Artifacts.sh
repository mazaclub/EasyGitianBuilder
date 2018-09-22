#!/bin/bash

test -f EasyGitian.env && source EasyGitian.env
if [ "$EASYGITIAN_DEBUG}" = "true" ] ; then
   DEBUG=true
   set -xeo pipefail
fi


echo "Cleaning EasyGitian directory..."
echo "Cleaning results..."
rm -rf results/*
echo "Cleaning repos..."
rm -rf repos/*
echo "Cleaning binaries..." 
rm -rf binaries/*
echo "Cleaning cache..."
rm -rf cache/*
echo "Cleaning inputs..."
sdk_tarballs=$(find inputs/ -name 'MacOSX*.sdk.tar.gz') 
if [ ! -z ${sdk_tarballs} ] ; then
  echo "MacOS SDK tarball found, saving to EasyGitian main directory" \
  && echo "Put it in the inputs/ directory to use it again" \
  && for i in  ${sdk_tarballs} ; do 
       echo $i
       test -f inputs/${i} && mv $i ./ 
     done
fi
rm -rf inputs/*


