 Usage:                                                                                                                         
       ./EasyGitian [optional_command] 

    Commands: 
       install_prereqs - Install Vagrant & Virtualbox
       first_run - run builder VM for the first time 
       make_env - make USER_CONFIG.env for gitian-builder options
       make_tarball - make OSX SDK tarball needed to build OSX version
       clean_vm - Revert to snapshot made in first_run
       rebuild_vm - destroy and recreate the virtualbox VM  
       reboot_vm - Restart VirtualMachine, Reload Vagrantfile
       destroy_vm - destroy VM - destroys build disk
       halt_vm - stop Virtualbox VM, do not rebuild or destroy it
       watch_build - view build progress from another terminal
       toggle_gui - toggle Virtualbox GUI / Headless modes for VM

       run_build - Run Gitian build 

 Rebuilding the VM will destroy it in vagrant and virtualbox, and provision a fresh debian box
 ready to build.  

 Cleaning the VM will restore from snapshot - this is all that should be needed to run builds with 
 a fresh system. 

 To keep an eye on build progress, run the build in one terminal session, and in another run
   ./EasyGitian watch_build 

 Running ./EasyGitian with no options will run the build, which will run 
 all steps necessary to prep the system for building 

