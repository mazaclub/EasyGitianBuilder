#!/bin/bash
cd /home/vagrant/gitian-builder
PATH=$PATH:$(pwd)/libexec
make-clean-vm --suite trusty --arch amd64

        # on-target needs $DISTRO to be set to debian if using a Debian guest
	    # (when running gbuild, $DISTRO is set based on the descriptor, so this line isn't needed)
	     #   DiSTRO=debian

# For LXC:
LXC_ARCH=amd64 LXC_SUITE=trusty on-target ls -la

cat << END
 
 
 You should see a directory listing above from inside the LXC container that gitian uses 
 to build. If you do, you are ready to build.

 A snapshot will be taken, and the Virtualbox VM will be restarted, and you can begin builds.
 

END


