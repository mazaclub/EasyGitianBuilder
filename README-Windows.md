# EasyGitian on Windows 10 with Windows Subsystem for Linux

## Setup WSL if needed
  1. Download Install_Wsl_easyGitian.ps1 from github
  2. Right click that script to Run With Powershell  to turn WSL on, reboot required
  3. Right click to run that same script again when machine comes back up to install Ubuntu
  4. When ubuntu is installed, make a new user as instructed
     - username doesn't matter, need not be Windows username
  5. Exit Ubuntu with CTRL-d or ```exit```
  6. Right click on the script on more time to Run with Powershell, and your new Ubuntu WSL will appear


## Run EasyGitian the first time 
   0. If you setup WSL Ubuntu with ```Install_WSL_EasyGitian.ps1``` script, 
      in your home directory in ubuntu should be a copy of ```Install_EasyGitian.sh```
      
      If you already have WSL, you should be able to run 
        ```wget -O "${HOME}/Install_EasyGitian.sh" https://raw.githubusercontent/mazaclub/easygitianbuilder/Install_EasyGitian.sh```

   1. Run that to get EasyGitian setup and ready to install everything you need
   2. In your home directory now should be ```EasyGitian.env``` get started by running 
      ```source ./EasyGitian.env```
   3. Now in the easygitianbuilder directory you can run 
      ```./EasyGitian```
        EasyGitian needs to install
          - vagrant for ubuntu
          - vagrant.exe for Windows
          - VirtualBox for Windows
        EasyGitian will download, check gpg signatures and shasums, and install them for you
        The Windows installations expect you to click through the installs. 
   4. Once those are installed, EasyGitian needs to reboot your machine one more time
   5. Open Ubuntu again when your machine comes back online
         - click the above powershell script OR
         - click the start menu and enter C:\WSLDistros\Ubuntu\ubuntu.exe

 

 
