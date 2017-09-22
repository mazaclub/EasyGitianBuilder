#!/bin/bash

## This script runs from EasyGitian(make_env) on the host
## This script runs inside the Virtualbox VM if /host_vagrantdir/USER_CONFIG.env is not found

# Create environment variables file for running gitian builds via vagrant

 
rm user_config.env
echo "Sign build? t/f"
read VGITIAN_SIGN  
echo "VGITIAN_SIGN=$(echo $VGITIAN_SIGN | tr '[:upper:]' '[:lower:]'|sed 's/t/true/g;s/f/false/g')" >> user_config.env

echo "Verify build t/f"
read VGITIAN_VERIFY
echo "VGITIAN_VERIFY=$(echo $VGITIAN_VERIFY | tr '[:upper:]' '[:lower:]'|sed 's/t/true/g;s/f/false/g')">> user_config.env  

echo "Run build t/f"
read VGITIAN_BUILD
echo "VGITIAN_BUILD=$(echo $VGITIAN_BUILD | tr '[:upper:]' '[:lower:]'|sed 's/t/true/g;s/f/false/g')">> user_config.env  

#echo "Setup build environment t/f"
#  read VGITIAN_
#VGITIAN_SETUPENV=$(echo $VGITIAN_SETUPENV | tr '[:upper:]' '[:lower:]')
echo "VGITIAN_SETUPENV=false" >> user_config.env

echo "Build Linux t/f"
read VGITIAN_LINUX
echo "VGITIAN_LINUX=$(echo $VGITIAN_LINUX | tr '[:upper:]' '[:lower:]'|sed 's/t/true/g;s/f/false/g')">> user_config.env  

echo "Build Windows t/f"
read VGITIAN_WIN
echo "VGITIAN_WIN=$(echo $VGITIAN_WIN | tr '[:upper:]' '[:lower:]'|sed 's/t/true/g;s/f/false/g')">> user_config.env  

echo "Build OSX t/f"
read VGITIAN_OSX
echo "VGITIAN_OSX=$(echo $VGITIAN_OSX | tr '[:upper:]' '[:lower:]'|sed 's/t/true/g;s/f/false/g')">> user_config.env  

echo "Build Signer [what goes here?]"
read VGITIAN_SIGNER
echo "VGITIAN_SIGNER=$(echo $VGITIAN_SIGNER | tr '[:upper:]' '[:lower:]')">> user_config.env  

echo "Code Version to Build [0.14.6|master|git-commit]"
read VGITIAN_VERSION
echo "VGITIAN_VERSION=$(echo $VGITIAN_VERSION | tr '[:upper:]' '[:lower:]')">> user_config.env  

echo "Build specific commit?"
read VGITIAN_COMMIT
echo "VGITIAN_COMMIT=$(echo $VGITIAN_COMMIT | tr '[:upper:]' '[:lower:]')">> user_config.env  

echo "Code git URL"
read VGITIAN_URL
echo "VGITIAN_URL=$(echo $VGITIAN_URL | tr '[:upper:]' '[:lower:]')">> user_config.env  

#echo "Number of Processors to tell make to use"
#read VGITIAN_PROC
#echo "VGITIAN_PROC=$(echo $VGITIAN_PROC | tr '[:upper:]' '[:lower:]')">> user_config.env  
uname="$(uname| tr '[:upper:]' '[:lower:]')"
if [ "${uname}" = "darwin" ] ; then
  echo "VGITIAN_PROC=$(sysctl -n hw.ncpu)" >> user_config.env
else
  echo "VGITIAN_PROC=$(nproc)" >> user_config.env
fi

echo "VGITIAN_MEM=3500" >> user_config.env

mv user_config.env USER_CONFIG.env
