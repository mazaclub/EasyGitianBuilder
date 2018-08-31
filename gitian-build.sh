#!/bin/bash
# Copyright (c) 2017 MAZA Network Developers, Robert Nelson (guruvan)

## This script runs inside the virtualbox vm

#set -x
# Portions Copyright (c) 2017 MAZA Network Developers, Robert Nelson (guruvan) 
# Copyright (c) 2016 The Bitcoin Core developers

# Distributed under the MIT software license, see the accompanying
# file COPYING or http://www.opensource.org/licenses/mit-license.php.

cleanup () {
  test -f /home/vagrant/gitian-builder/.build_list \
    && rm /home/vagrant/gitian-builder/.build_list
  test -f /host_vagrantdir/build_list \
    && rm /host_vagrantdir/build_list
  echo "Exiting gitian build"
  exit 99
}
trap cleanup INT EXIT
# What to do
if [ -f /host_vagrantdir/USER_CONFIG.env ]; then
  . /host_vagrantdir/USER_CONFIG.env
else
  /host_vagrantdir/USER_CONFIG.sh
  . /host_vagrantdir/USER_CONFIG.env
fi
echo "Checking env"
echo "VGITIAN_BUILD = ${VGITIAN_BUILD}"
env

# set date for build output directories
DATE="$(date +%Y%m%d%H%M)"


# Check for sufficient diskspace to complete build
printf "\nChecking disk space for your build...\n\n"
diskspace=$(df -k "$HOME/gitian-builder" |grep dev|awk '{print $4}')
if [ "$diskspace" -le 20000000 ]; then
   availspace=$(( diskspace / 1048576))
   printf "\nInsufficient space - 20GB required %s available \n" "$availspace"
   printf "\nThis shouldn't happen, you should have a second disk in your VM\n"
   printf "\nYou can run\n./EasyGitian rebuild_vm\nto get a fresh VM with sufficient space\n"
   printf "\nAborting Build\n"
   exit 1
fi

sign=${VGITIAN_SIGN:-false}
assert=${VGITIAN_ASSERT:-false}
verify=${VGITIAN_VERIFY:-false}
build=${VGITIAN_BUILD:-true}
#setupenv=${VGITIAN_SETUPENV:-false}

echo "Make the list of OS versions to build"
test -f gitian-builder/.build_list && rm gitian-builder/.build_list > /dev/null 2>&1
# Systems to build
linux=${VGITIAN_LINUX:-true}
if [[ $linux = true ]]
then
  echo "linux" >> gitian-builder/.build_list
fi
windows=${VGITIAN_WIN:-false}
if [[ $windows = true ]]
then
  echo "windows" >> gitian-builder/.build_list
fi
osx=${VGITIAN_OSX:-false}
if [[ $osx = true ]]
then
  echo "osx" >> gitian-builder/.build_list
fi
cp gitian-builder/.build_list /host_vagrantdir/build_list
test -f gitian-builder/var/install.log && rm gitian-builder/var/install.log
test -f gitian-builder/var/build.log && rm gitian-builder/var/build.log

# Other Basic variables
COIN=${VGITIAN_COIN:-bitcoin-abc}
SIGNER=${VGITIAN_SIGNER:-"notconfiguredgitian@mazacoin.org"}
VERSION=${VGITIAN_VERSION:-0.14.6}
commit=${VGITIAN_COMMIT:-false}
url=${VGITIAN_URL:-"https://github.com/bitcoin-abc/bitcoin-abc"}
sigrepo=${VGITIAN_SIGREPO:-"https://github.com/bitcoin-core/gitian.sigs"}
detachedsigrepo=${VGITIAN_DETACHEDSIGREPO:-"https://github.com/bitcoin-core/detached-sigs"}
proc=${VGITIAN_PROC:-3}
mem=${VGITIAN_MEM:-3500}
lxc=true
osslTarUrl=http://downloads.sourceforge.net/project/osslsigncode/osslsigncode/osslsigncode-1.7.1.tar.gz
osslPatchUrl=https://bitcoincore.org/cfields/osslsigncode-Backports-to-1.7.1.patch
scriptName=$(basename -- "$0")
signProg="gpg --detach-sign"
commitFiles=${VGITIAN_COMMITFILES:-false}

printf "\nSign: %s" "$sign"
printf "\nVerify: %s" "$verify"
printf "\nBuild: %s" "$build"
printf "\nBuild Linux: %s" "$linux"
printf "\nBuild Windows: %s" "$windows"
printf "\nBuild OSX: %s" "$osx"
printf "\nSigner: %s" "$SIGNER"
printf "\nVersion: %s" "$VERSION"
printf "\nCommit: %s" "$commit"
printf "\nURL: %s" "$url"
printf "\nProcessors: %s" "$proc"
printf "\nMemory: %s" "$mem"

# Help Message
read -r -d '' usage <<- EOF
Usage: $scriptName [-c|u|v|b|s|B|o|h|j|m|] signer version

Run this script from the directory containing the bitcoin, gitian-builder, gitian.sigs, and bitcoin-detached-sigs.

Arguments:
signer          GPG signer to sign each build assert file
version		Version number, commit, or branch to build. If building a commit or branch, the -c option must be specified

Options:
-c|--commit	Indicate that the version argument is for a commit or branch
-u|--url	Specify the URL of the repository. Default is https://github.com/bitcoin/bitcoin
-v|--verify 	Verify the gitian build
-b|--build	Do a gitian build
-s|--sign	Make signed binaries for Windows and Mac OSX
-B|--buildsign	Build both signed and unsigned binaries
-o|--os		Specify which Operating Systems the build is for. Default is lwx. l for linux, w for windows, x for osx
-j		Number of processes to use. Default 2
-m		Memory to allocate in MiB. Default 2000
--kvm           Use KVM instead of LXC
--setup         Setup the gitian building environment. Uses KVM. If you want to use lxc, use the --lxc option. Only works on Debian-based systems (Ubuntu, Debian)
--detach-sign   Create the assert file for detached signing. Will not commit anything.
--no-commit     Do not commit anything to git
-h|--help	Print this help message
EOF

# Get options and arguments
while :; do
    case $1 in
        # Verify
        -v|--verify)
	    verify=true
            ;;
        # Build
        -b|--build)
	    build=true
            ;;
        # Sign binaries
        -s|--sign)
	    sign=true
            ;;
        # Build then Sign
        -B|--buildsign)
	    sign=true
	    build=true
            ;;
        # PGP Signer
        -S|--signer)
	    if [ -n "$2" ]
	    then
		SIGNER=$2
		shift
	    else
		echo 'Error: "--signer" requires a non-empty argument.'
		exit 1
	    fi
           ;;
        # Operating Systems
        -o|--os)
	    if [ -n "$2" ]
	    then
		linux=false
		windows=false
		osx=false
		if [[ "$2" = *"l"* ]]
		then
		    linux=true
		fi
		if [[ "$2" = *"w"* ]]
		then
		    windows=true
		fi
		if [[ "$2" = *"x"* ]]
		then
		    osx=true
		fi
		shift
	    else
		#echo 'Error: "--os" requires an argument containing an l (for linux), w (for windows), or x (for Mac OSX)\n'
		printf "Error: \"--os\" requires an argument containing an l (for linux), w (for windows), or x (for Mac OSX)\n"
		exit 1
	    fi
	    ;;
	# Help message
	-h|--help)
	    echo "$usage"
	    exit 0
	    ;;
	# Commit or branch
	-c|--commit)
	    commit=true
	    ;;
	# Number of Processes
	-j)
	    if [ -n "$2" ]
	    then
		proc=$2
		shift
	    else
		echo 'Error: "-j" requires an argument'
		exit 1
	    fi
	    ;;
	# Memory to allocate
	-m)
	    if [ -n "$2" ]
	    then
		mem=$2
		shift
	    else
		echo 'Error: "-m" requires an argument'
		exit 1
	    fi
	    ;;
	# URL
	-u)
	    if [ -n "$2" ]
	    then
		url=$2
		shift
	    else
		echo 'Error: "-u" requires an argument'
		exit 1
	    fi
	    ;;
        # kvm
        --kvm)
            lxc=false
            ;;
        # Detach sign
        --detach-sign)
            signProg="true"
            commitFiles=false
            ;;
        # Commit files
        --no-commit)
            commitFiles=false
            ;;
        # Setup
        --setup)
            setup=true
            ;;
	*)               # Default case: If no more options then break out of the loop.
             break
    esac
    shift
done

# Set up LXC
if [[ $lxc = true ]]
then
    export USE_LXC=1
    export LXC_BRIDGE=br0
    sudo ifconfig br0 up 10.0.3.2
fi

# Check for OSX SDK
if [[ ! -e "gitian-builder/inputs/MacOSX10.11.sdk.tar.gz" && $osx == true ]]
then
    echo "Cannot build for OSX, SDK does not exist. Will build for other OSes"
    osx=false
fi

# Get signer
if [[ -n "$1" ]]
then
    SIGNER=$1
    shift
fi

# Get version
if [[ -n "$1" ]]
then
    VERSION=$1
    COMMIT="${VERSION}"
    shift
fi

# Check that a signer is specified
if [[ "$SIGNER" == "" ]]
then
    echo "$scriptName: Missing signer."
    echo "Try $scriptName --help for more information"
    exit 1
fi

# Check that a version is specified
if [[ $VERSION == "" ]]
then
    echo "$scriptName: Missing version."
    echo "Try $scriptName --help for more information"
    exit 1
fi

# Add a "v" if no -c
if [[ $commit = false ]]
then
	COMMIT="v${VERSION}"
fi
echo "${COMMIT}"



### not used
# Setup build environment
if [[ $setup = true ]]
then
    sudo apt-get install ruby apache2 git apt-cacher-ng python-vm-builder qemu-kvm qemu-utils
    #git clone https://github.com/bitcoin-core/gitian.sigs.git
    git clone "$sigrepo" repos/"${COIN}"-gitian.sigs
    git clone "$detachedsigrepo" repos/"${COIN}"-detached-sigs
    git clone https://github.com/devrandom/gitian-builder.git
    pushd ./gitian-builder
    if [[ -n "$USE_LXC" ]]
    then
        sudo apt-get install lxc
        bin/make-base-vm --suite trusty --arch amd64 --lxc
    else
        bin/make-base-vm --suite trusty --arch amd64
    fi
    popd
fi

# Set up build
echo "Checking for initial ${COIN} git directories - codebase, gitian.sigs, detached-sigs"
pushd repos
test -d ./"${COIN}" || { echo "${COIN} git directory not found, cloning..."; git clone "$url"; }
test -d ./"${COIN}-gitian.sigs" || { echo "${COIN} gitian.sigs directory not found, cloning..."; git clone "$sigrepo" "${COIN}"-gitian.sigs; }
test -d ./"${COIN}-detached-sigs" || { echo "${COIN} detached-sigs directory not found, cloning..."; git clone "$detachedsigrepo" "${COIN}"-detached-sigs; }
pushd ./"${COIN}"
# check current descriptors 
#git checkout "${VERSION}"
git fetch
git checkout "${COMMIT}"
popd
# make sure we have a base-vm made
suites="$(shyaml get-value suites <  "${COIN}"/contrib/gitian-descriptors/gitian-linux.yml|awk '{print $2}')"
arches="$(shyaml get-value architectures  <  "${COIN}"/contrib/gitian-descriptors/gitian-linux.yml|awk '{print $2}')"

popd # back to /home/vagrant
for suite in $suites ; do
  for arch in ${arches} ; do
    pushd ~/gitian-builder || exit 4
    echo "check for base vm disk" 
     test -f base-"${suite}"-"${arch}" \
       || ./bin/make-base-vm --lxc --arch "${arch}" --suite "${suite}"
    popd
  done
done

echo "moving to build steps" 


# Build
if [[ $build = true ]]
then
        # Clean result dir
	rm -rf ./gitian-builder/result/*
	# Clean build dir
	rm -rf ./gitian-builder/build/*
	# Make output folder
	mkdir -p ./bitcoin-binaries/"${COIN}"/"${VERSION}"/"${DATE}"/{linux,windows,osx}
	mkdir -p ./gitian-results/"${COIN}"/"${VERSION}"/"${DATE}"/{linux,windows,osx}
	# Build Dependencies
	echo ""
	echo "Building Dependencies"
	echo ""
	pushd ./gitian-builder	
	mkdir -p inputs
	wget -N -P inputs $osslPatchUrl
	wget -N -P inputs $osslTarUrl
	make -C ../repos/"${COIN}"/depends download SOURCES_PATH="$(pwd)"/cache/common

	# Linux
	if [[ $linux = true ]]
	then
            echo ""
	    echo "Compiling ${COIN} ${VERSION} for Linux"
	    echo ""
	    ./bin/gbuild -j "${proc}" -m "${mem}" \
	      --commit "${COIN}"="${COMMIT}" --url "${COIN}"="${url}" \
	      ../repos/"${COIN}"/contrib/gitian-descriptors/gitian-linux.yml
	    if [[ $assert = true ]]
	    then
	      ./bin/gsign -p $signProg --signer "$SIGNER" \
	        --release "${VERSION}"-linux --destination ../repos/"${COIN}"-gitian.sigs/ \
		../repos/"${COIN}"/contrib/gitian-descriptors/gitian-linux.yml
	    fi
	    cp build/out/"${COIN}"*.tar.gz build/out/src/"${COIN}"*.tar.gz \
	      ../bitcoin-binaries/"${COIN}"/"${VERSION}"/"${DATE}"/linux/
            sed -i '/linux/d' .build_list
	    cp -av result/"${COIN}"-linux*.yml ../gitian-results/"${COIN}"/"${VERSION}"/"${DATE}"/linux/
	    # take a break here to give user time to view errors
            sleep 30
	fi
	# Windows
	if [[ $windows = true ]]
	then
	    echo ""
	    echo "Compiling ${COIN} ${VERSION} for Windows"
	    echo ""
	    ./bin/gbuild -j "${proc}" -m "${mem}" \
	      --commit "${COIN}"="${COMMIT}" --url "${COIN}"="${url}" \
	      ../repos/"${COIN}"/contrib/gitian-descriptors/gitian-win.yml
	    if [[ $assert = true ]]
	    then
	       ./bin/gsign -p $signProg --signer "$SIGNER" \
	         --release "${VERSION}"-win-unsigned --destination ../repos/"${COIN}"-gitian.sigs/ \
		 ../repos/"${COIN}"/contrib/gitian-descriptors/gitian-win.yml
	    fi
	    cp build/out/"${COIN}"*-win-unsigned.tar.gz inputs/"${COIN}"*-win-unsigned.tar.gz
	    cp build/out/"${COIN}"*.zip build/out/"${COIN}"*.exe \
	      ../bitcoin-binaries/"${COIN}"/"${VERSION}"/"${DATE}"/windows/
            sed -i '/windows/d' .build_list
	    cp -av result/"${COIN}"-win*.yml ../gitian-results/"${COIN}"/"${VERSION}"/"${DATE}"/windows/
	    # take a break here to give user time to view errors
            sleep 30
	fi
	# Mac OSX
	if [[ $osx = true ]]
	then
	    echo ""
	    echo "Compiling ${COIN} ${VERSION} for Mac OSX"
	    echo ""
	    ./bin/gbuild -j "${proc}" -m "${mem}" \
	      --commit "${COIN}"="${COMMIT}" --url "${COIN}"="${url}" \
	      ../repos/"${COIN}"/contrib/gitian-descriptors/gitian-osx.yml
	    if [[ $assert = true ]]
	    then
	    ./bin/gsign -p $signProg --signer "$SIGNER" \
	      --release "${VERSION}"-osx-unsigned --destination ../repos/"${COIN}"-gitian.sigs/ \
	      ../repos/"${COIN}"/contrib/gitian-descriptors/gitian-osx.yml
	    fi
	    cp build/out/"${COIN}"*-osx-unsigned.tar.gz inputs/"${COIN}"-osx-unsigned.tar.gz
	    cp build/out/"${COIN}"*.tar.gz build/out/"${COIN}"*.dmg \
	      ../bitcoin-binaries/"${COIN}"/"${VERSION}"/"${DATE}"/osx/
            sed -i '/osx/d' .build_list
	    cp -av result/"${COIN}"-osx*.yml ../gitian-results/"${COIN}"/"${VERSION}"/"${DATE}"/osx/
	    # take a break here to give user time to view errors
	    sleep 30
	fi
	popd

        if [[ $commitFiles = true ]]
        then
	    # Commit to gitian.sigs repo
            echo ""
            echo "Committing ${VERSION} Unsigned Sigs"
            echo ""
            pushd repos/"${COIN}"-gitian.sigs
            git add "${VERSION}-linux/${SIGNER}"
            git add "${VERSION}-win-unsigned/${SIGNER}"
            git add "${VERSION}-osx-unsigned/${SIGNER}"
            git commit -a -m "Add ${VERSION} unsigned sigs for ${SIGNER}"
            popd
        fi
fi

# Verify the build
if [[ $verify = true ]]
then
        # import keys for existing signers
        pushd ./repos/"${COIN}"/contrib/gitian-keys
        for sig in *.gpg ; do
	  gpg --import "$sig"
          #ln -s "$sig" "$sig.pgp" 
        done 
	popd
	# Linux
	pushd ./gitian-builder
	echo ""
	printf "\nVerifying v%s Linux\n" "${VERSION}"
	echo ""
	./bin/gverify -v -d ../repos/"${COIN}"-gitian.sigs/ -r "${VERSION}"-linux \
	  ../repos/"${COIN}"/contrib/gitian-descriptors/gitian-linux.yml
	# Windows
	echo ""
	printf "\nVerifying v%s Windows\n" "${VERSION}"
	echo ""
	./bin/gverify -v -d ../repos/"${COIN}"-gitian.sigs/ -r "${VERSION}"-win-unsigned \
	  ../repos/"${COIN}"/contrib/gitian-descriptors/gitian-win.yml
	# Mac OSX	
	echo ""
	printf "\nVerifying v%s Mac OSX\n" "${VERSION}"
	echo ""	
	./bin/gverify -v -d ../repos/"${COIN}"-gitian.sigs/ -r "${VERSION}"-osx-unsigned \
	  ../repos/"${COIN}"/contrib/gitian-descriptors/gitian-osx.yml
	# Signed Windows
	echo ""
	echo "Verifying v${VERSION} Signed Windows"
	echo ""
	./bin/gverify -v -d ../repos/"${COIN}"-gitian.sigs/ -r "${VERSION}"-win-signed \
	  ../repos/"${COIN}"/contrib/gitian-descriptors/gitian-win-signer.yml
	# Signed Mac OSX
	echo ""
	echo "Verifying v${VERSION} Signed Mac OSX"
	echo ""
	./bin/gverify -v -d ../repos/"${COIN}"-gitian.sigs/ -r "${VERSION}"-osx-signed \
	  ../repos/"${COIN}"/contrib/gitian-descriptors/gitian-osx-signer.yml
	popd
fi


# Sign binaries
if [[ $sign = true ]]
then
	
        pushd ./gitian-builder
	# Sign Windows
	if [[ $windows = true ]]
	then
	    echo ""
	    echo "Signing ${VERSION} Windows"
	    echo ""
	    ./bin/gbuild -i --commit signature="${COMMIT}" ../repos/"${COIN}"/contrib/gitian-descriptors/gitian-win-signer.yml
	    ./bin/gsign -p $signProg --signer "$SIGNER" --release "${VERSION}"-win-signed --destination ../repos/"${COIN}"-gitian.sigs/ ../repos/"${COIN}"/contrib/gitian-descriptors/gitian-win-signer.yml
	    mv build/out/"${COIN}"-*win64-setup.exe ../bitcoin-binaries/"${COIN}/${VERSION}/${DATE}"
	    mv build/out/"${COIN}"-*win32-setup.exe ../bitcoin-binaries/"${COIN}/${VERSION}/${DATE}"
	fi
	# Sign Mac OSX
	if [[ $osx = true ]]
	then
	    echo ""
	    echo "Signing ${VERSION} Mac OSX"
	    echo ""
	    ./bin/gbuild -i --commit signature="${COMMIT}" ../repos/"${COIN}"/contrib/gitian-descriptors/gitian-osx-signer.yml
	    ./bin/gsign -p $signProg --signer "$SIGNER" --release "${VERSION}"-osx-signed --destination ../repos/"${COIN}"-gitian.sigs/ ../repos/"${COIN}"/contrib/gitian-descriptors/gitian-osx-signer.yml
	    mv build/out/"${COIN}"-osx-signed.dmg ../bitcoin-binaries/"${COIN}/${VERSION}/${DATE}/${COIN}-${VERSION}"-osx.dmg
	fi
	popd

        if [[ $commitFiles = true ]]
        then
            # Commit Sigs
            pushd repos/"${COIN}"-gitian.sigs
            echo ""
            echo "Committing ${VERSION} Signed Sigs"
            echo ""
            git add "${VERSION}-win-signed/${SIGNER}"
            git add "${VERSION}-osx-signed/${SIGNER}"
            git commit -a -m "Add ${VERSION} signed binary sigs for ${SIGNER}"
            popd
        fi
fi
