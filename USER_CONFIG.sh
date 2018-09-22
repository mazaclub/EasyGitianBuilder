#!/bin/bash
# Copyright (c) 2017 MAZA Network Developers, Robert Nelson (guruvan)

## This script runs from EasyGitian(make_env) on the host
## This script runs inside the Virtualbox VM if /host_vagrantdir/USER_CONFIG.env is not found

# Create environment variables file for running gitian builds via vagrant
test -f EasyGitian.env && source EasyGitian.env
if [ "$EASYGITIAN_DEBUG}" = "true" ] ; then
   DEBUG=true
   set -xeo pipefail
fi               
make_config () { 
 test -f user_config.env && rm user_config.env
 printf "#!/bin/bash \n" > user_config.env
 
 # TODO make function to ask for and regurgitate each variable needed
 # and repeat if user isnt happy with their input
 # TODO check t/f answers are correct 
 # TODO check URLs are valid git repos
 
 echo "Run build t/f"
 get_tf
 VGITIAN_BUILD=${tf}
 echo
 echo "export VGITIAN_BUILD=$(echo "${VGITIAN_BUILD}")" >> user_config.env 
 #| tr '[:upper:]' '[:lower:]'|sed 's/t/true/g;s/f/false/g')">> user_config.env
 #build=$(echo "${VGITIAN_BUILD}" | tr '[:upper:]' '[:lower:]'|sed 's/t/true/g;s/f/false/g')
 
 echo "export VGITIAN_SETUPENV=false" >> user_config.env
 #if [[ $build = true ]] ; then
 #echo "Setup build environment t/f"
 #  read -r -n1 VGITIAN_
 #VGITIAN_SETUPENV=$(echo "${VGITIAN_SETUPENV}" | tr '[:upper:]' '[:lower:]')
 
    echo "Build Linux t/f"
    get_tf
    VGITIAN_LINUX=${tf}
    echo
    echo "export VGITIAN_LINUX=$(echo "${VGITIAN_LINUX}" )">> user_config.env  
    #| tr '[:upper:]' '[:lower:]'|sed 's/t/true/g;s/f/false/g'
    echo "Build Windows t/f"
    get_tf
    VGITIAN_WIN=${tf}

    echo
    echo "export VGITIAN_WIN=$(echo "${VGITIAN_WIN}")" >> user_config.env
    echo "Build OSX t/f"
    get_tf
    VGITIAN_OSX=${tf}
    echo
    echo "export VGITIAN_OSX=$(echo "${VGITIAN_OSX}")">> user_config.env  
 
    echo "Code Version to Build [0.14.6|master|git-commit]"
    echo "Use a (numeric only) tagged release version, branch name, or commit hash" 
    read -r VGITIAN_VERSION
    echo
    echo "export VGITIAN_VERSION=$(echo "${VGITIAN_VERSION}" | tr '[:upper:]' '[:lower:]')">> user_config.env
 
    echo "Version is a git commit hash? [t/f]"
    get_tf
    VGITIAN_COMMIT=${tf}
    echo
    echo "export VGITIAN_COMMIT=$(echo "${VGITIAN_COMMIT}")">> user_config.env  
 #fi
 echo "Code git URL i.e. https://github.com/mazanetwork/maza"
 read -r VGITIAN_URL
 echo
 echo "export VGITIAN_URL=$(echo "${VGITIAN_URL}" | tr '[:upper:]' '[:lower:]')">> user_config.env
 echo "export VGITIAN_COIN=$(echo "${VGITIAN_URL}" | tr '[:upper:]' '[:lower:]'|awk -F/ '{print $NF}')" >> user_config.env
 
 echo "Download other builders' hashes and Verify build? t/f "
 get_tf
 VGITIAN_VERIFY=${tf}
 echo
 echo "export VGITIAN_VERIFY=$(echo "${VGITIAN_VERIFY}")">> user_config.env
 
 echo "Gitian Signature git Repo URL? i.e. https://github.com/mazacoin/gitian.sigs"
 read -r VGITIAN_SIGREPO
 echo
 echo "export VGITIAN_SIGREPO=$(echo "${VGITIAN_SIGREPO}" | tr '[:upper:]' '[:lower:]')" >> user_config.env
 echo "Detached Signature git Repo URL? i.e. https://github.com/mazacoin/maza-detached-sigs"
 read -r VGITIAN_DETACHEDSIGREPO
 echo
 echo "export VGITIAN_DETACHEDSIGREPO=$(echo "${VGITIAN_DETACHEDSIGREPO}" | tr '[:upper:]' '[:lower:]')" >> user_config.env
 
 echo "Sign Results? Create and sign builder assertions files? t/f"
 get_tf
 VGITIAN_ASSERT=${tf}
 echo
 echo "export VGITIAN_ASSERT=$(echo "${VGITIAN_ASSERT}" )" >> user_config.env
 
 #if [[ $VGITIAN_ASSERT = true ]]; then
    echo "GPG Sign Built Binaries? t/f"
    get_tf
    VGITIAN_SIGN=${tf}
    echo
    echo "export VGITIAN_SIGN=$(echo "${VGITIAN_SIGN}" )" >> user_config.env
    echo "Build Signer - GPG Key email - required"
    read -r VGITIAN_SIGNER
    echo
    echo "export VGITIAN_SIGNER=$(echo "${VGITIAN_SIGNER}" | tr '[:upper:]' '[:lower:]')">> user_config.env
 
    echo "Commit Signatures to gitian signatures repo? t/f"
    get_tf
    VGITIAN_COMMITFILES=${tf}
    echo
    echo "export VGITIAN_COMMITFILES=$(echo "${VGITIAN_COMMITFILES}" )" >> user_config.env
 #fi
 
 #echo "Number of Processors to tell make to use"
 #read -r -n1 VGITIAN_PROC
 #echo "export VGITIAN_PROC=$(echo "${VGITIAN_PROC}" | tr '[:upper:]' '[:lower:]')">> user_config.env
 uname="$(uname| tr '[:upper:]' '[:lower:]')"
 if [ "${uname}" = "darwin" ] ; then
   echo "export VGITIAN_PROC=$(sysctl -n hw.ncpu)" >> user_config.env
   HOST_MEM=$(sysctl -n hw.memsize); HOST_MEM=$((HOST_MEM/1048576))
 else
   echo "export VGITIAN_PROC=$(nproc)" >> user_config.env
   HOST_MEM=$(cat /proc/meminfo  |grep MemTotal |awk '{print $2 / 1024 }'|awk -F\. '{print $1}')
 fi
 
 echo "export VGITIAN_MEM=$(expr ${HOST_MEM} \- 2048)" >> user_config.env
mv user_config.env USER_CONFIG.env
 #end make_config
 check_config
}
get_tf () {
    read -r -s -n1 choice
    tf=$(echo ${choice} |tr '[:upper:]' '[:lower:]'|sed 's/t/true/g;s/f/false/g')
    if [ "$tf" != "true" ] ; then
       if [ "$tf" != "false" ]; then
          echo "Please enter t or f "
          get_tf
       fi
    fi
}
check_config () {
   cat USER_CONFIG.env
   echo "Replace Build Configuration? [t/f]"
   get_tf
   if [ "${tf}" = "true" ] ;then
      new_config=true
      make_config
   else
      if [ "${new_config}" = "true" ] ; then
         echo "Build Config changed" 
      else
         echo "Not changing build config." 
      fi
   fi
}



if [ -f USER_CONFIG.env ]; then
   echo "Build config found..."
   check_config
else 
   echo "No Build configuration found, making one now..."
   new_config=true
   make_config
   check_config
fi
