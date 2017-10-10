#!/bin/bash 

. /host_vagrantdir/USER_CONFIG.env



test -f /home/vagrant/gitian-builder/.build_list || { echo "Build not started, try again later" ; exit 2; }

builds=$(wc -l /home/vagrant/gitian-builder/.build_list|awk '{print $1}')
while [ "$builds" -ge 1 ]; do
 line=$(head -n 1 /home/vagrant/gitian-builder/.build_list)
 printf "\nCurrent build: %s\n\n" "$line"
 printf "Number of Builds to run: %s\n\n"  "$builds"
 printf "\nWaiting for %s build to begin install to LXC vm\n\n" "$line"
 x=0
 while [ $x -eq 0 ] ; do
  #echo "waiting for install.log"
  if [ -f /home/vagrant/gitian-builder/var/install.log ] ;then 
    tail -f /home/vagrant/gitian-builder/var/install.log & IL_PID=$! 
    echo "Build Install has started"
    x=1
  else
    echo "Install process is not started yet"
    sleep 5
  fi
 done
 x=0
 while [ $x -eq 0 ] ; do
  echo "Waiting for build to to start"
  if [ -f /home/vagrant/gitian-builder/var/build.log ] ;then 
    kill "${IL_PID}" > /dev/null 2>&1
    tail -f /home/vagrant/gitian-builder/var/build.log & BL_PID=$! 
    echo "tail"
    x=1
  else 
    echo "still waiting for build.log"
    sleep 5
  fi
 done

 while true; do
   sleep 5
   NEW=$(md5sum /home/vagrant/gitian-builder/var/build.log)
   if [ "$NEW" = "$LAST" ]; then
     kill "${BL_PID}" > /dev/null 2>&1
     printf "\nBuild Log for %s Complete\n\n"  "$line"
     break
   fi
     LAST="$NEW"
 done
 #test -f /home/vagrant/gitian-builder/var/done.log && { echo "Build complete" ; exit 0; }
 sed -i '1d' /home/vagrant/gitian-builder/.build_list
 builds=$(wc -l /home/vagrant/gitian-builder/.build_list|awk '{print $1}')
done
rm /home/vagrant/gitian-builder/.build_list
printf "\nBuild List Complete - your build should be done.\n\n"


 


