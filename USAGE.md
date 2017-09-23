 Usage:                                                                                                                         
       ./EasyGitian [optional_command] 

    Commands: 
       install_prereqs - Install Vagrant & Virtualbox
       first_run - run builder VM for the first time 
       make_env - make USER_CONFIG.env for gitian-builder options
       make_tarball - make OSX SDK tarball needed to build OSX version
       clean_vm - Revert to snapshot made in first_run
       rebuild_vm - destroy and recreate the virtualbox VM  
       run_build - Run Gitian build
       reboot_vm - Restart VirtualMachine, Reload Vagrantfile
       destroy_vm - destroy VM - destroys build disk

 Running ./EasyGitian with no options will run the build, which will run 
 all steps necessary to prep the system for building 

 Rebuilding the VM will destroy it in vagrant and virtualbox, and provision a fresh debian box
 ready to build.  
