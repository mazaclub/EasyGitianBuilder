#!/bin/bash
# Copyright (c) 2017 MAZA Network Developers, Robert Nelson (guruvan)

## This script runs from EasyGitian(make_env) on the host
## This script runs inside the Virtualbox VM if /host_vagrantdir/USER_CONFIG.env is not found

# Create environment variables file for running gitian builds via vagrant

 
rm user_config.env
printf "#!/bin/bash \n" > user_config.env


echo "Run build t/f"
read -r -n1 VGITIAN_BUILD
echo
echo "export VGITIAN_BUILD=$(echo "${VGITIAN_BUILD}" | tr '[:upper:]' '[:lower:]'|sed 's/t/true/g;s/f/false/g')">> user_config.env
#build=$(echo "${VGITIAN_BUILD}" | tr '[:upper:]' '[:lower:]'|sed 's/t/true/g;s/f/false/g')

echo "export VGITIAN_SETUPENV=false" >> user_config.env
#if [[ $build = true ]] ; then
#echo "Setup build environment t/f"
#  read -r -n1 VGITIAN_
#VGITIAN_SETUPENV=$(echo "${VGITIAN_SETUPENV}" | tr '[:upper:]' '[:lower:]')

   echo "Build Linux t/f"
   read -r -n1 VGITIAN_LINUX
   echo
   echo "export VGITIAN_LINUX=$(echo "${VGITIAN_LINUX}" | tr '[:upper:]' '[:lower:]'|sed 's/t/true/g;s/f/false/g')">> user_config.env  
   echo "Build Windows t/f"
   read -r -n1 VGITIAN_WIN
   echo
   echo "export VGITIAN_WIN=$(echo "${VGITIAN_WIN}" | tr '[:upper:]' '[:lower:]'|sed 's/t/true/g;s/f/false/g')">> user_config.env
   echo "Build OSX t/f"
   read -r -n1 VGITIAN_OSX
   echo
   echo "export VGITIAN_OSX=$(echo "${VGITIAN_OSX}" | tr '[:upper:]' '[:lower:]'|sed 's/t/true/g;s/f/false/g')">> user_config.env  

   echo "Code Version to Build [0.14.6|master|git-commit]"
   echo "Use a (numeric only) tagged release version, branch name, or commit hash" 
   read -r VGITIAN_VERSION
   echo
   echo "export VGITIAN_VERSION=$(echo "${VGITIAN_VERSION}" | tr '[:upper:]' '[:lower:]')">> user_config.env

   echo "Version is a git commit hash? [t/f]"
   read -r VGITIAN_COMMIT
   echo
   echo "export VGITIAN_COMMIT=$(echo "${VGITIAN_COMMIT}" | tr '[:upper:]' '[:lower:]'|sed 's/t/true/g;s/f/false/g')">> user_config.env  
#fi
echo "Code git URL"
read -r VGITIAN_URL
echo
echo "export VGITIAN_URL=$(echo "${VGITIAN_URL}" | tr '[:upper:]' '[:lower:]')">> user_config.env
echo "export VGITIAN_COIN=$(echo "${VGITIAN_URL}" | tr '[:upper:]' '[:lower:]'|awk -F/ '{print $NF}')" >> user_config.env

echo "Verify build t/f"
read -r -n1 VGITIAN_VERIFY
echo
echo "export VGITIAN_VERIFY=$(echo "${VGITIAN_VERIFY}" | tr '[:upper:]' '[:lower:]'|sed 's/t/true/g;s/f/false/g')">> user_config.env

echo "Gitian Signature git Repo URL?"
read -r VGITIAN_SIGREPO
echo
echo "export VGITIAN_SIGREPO=$(echo "${VGITIAN_SIGREPO}" | tr '[:upper:]' '[:lower:]')" >> user_config.env
echo "Detached Signature git Repo URL?"
read -r VGITIAN_DETACHEDSIGREPO
echo
echo "export VGITIAN_DETACHEDSIGREPO=$(echo "${VGITIAN_DETACHEDSIGREPO}" | tr '[:upper:]' '[:lower:]')" >> user_config.env

echo "Sign Results? (Create and sign builder assertions files?) t/f"
read -r -n1 VGITIAN_ASSERT
echo
echo "export VGITIAN_ASSERT=$(echo "${VGITIAN_ASSERT}" | tr '[:upper:]' '[:lower:]'|sed 's/t/true/g;s/f/false/g')" >> user_config.env

#if [[ $VGITIAN_ASSERT = true ]]; then
   echo "Sign Binaries? t/f"
   read -r -n1 VGITIAN_SIGN
   echo
   echo "export VGITIAN_SIGN=$(echo "${VGITIAN_SIGN}" | tr '[:upper:]' '[:lower:]'|sed 's/t/true/g;s/f/false/g')" >> user_config.env
   echo "Build Signer"
   read -r VGITIAN_SIGNER
   echo
   echo "export VGITIAN_SIGNER=$(echo "${VGITIAN_SIGNER}" | tr '[:upper:]' '[:lower:]')">> user_config.env

   echo "Commit Signatures to gitian signatures repo? t/f"
   read -r -n1 VGITIAN_COMMITFILES
   echo
   echo "export VGITIAN_COMMITFILES=$(echo "${VGITIAN_COMMITFILES}" | tr '[:upper:]' '[:lower:]'|sed 's/t/true/g;s/f/false/g')" >> user_config.env
#fi

#echo "Number of Processors to tell make to use"
#read -r -n1 VGITIAN_PROC
#echo "export VGITIAN_PROC=$(echo "${VGITIAN_PROC}" | tr '[:upper:]' '[:lower:]')">> user_config.env
uname="$(uname| tr '[:upper:]' '[:lower:]')"
if [ "${uname}" = "darwin" ] ; then
  echo "export VGITIAN_PROC=$(sysctl -n hw.ncpu)" >> user_config.env
else
  echo "export VGITIAN_PROC=$(nproc)" >> user_config.env
fi

echo "export VGITIAN_MEM=4500" >> user_config.env


mv user_config.env USER_CONFIG.env
