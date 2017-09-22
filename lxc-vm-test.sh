#!/bin/bash -x
cd /home/vagrant/gitian-builder
PATH=$PATH:$(pwd)/libexec
make-clean-vm --suite trusty --arch amd64

        # on-target needs $DISTRO to be set to debian if using a Debian guest
	    # (when running gbuild, $DISTRO is set based on the descriptor, so this line isn't needed)
	     #   DiSTRO=debian

# For LXC:
LXC_ARCH=amd64 LXC_SUITE=trusty on-target ls -la



