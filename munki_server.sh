#!/bin/bash

#DJL2017
#Set the parent directory for your repository here. Do not include a trailing slash!
REPO=/Users/Shared

cd "$REPO"

#Download the current version of software
curl -O https://munkibuilds.org/munkitools2-latest.pkg
installer -pkg munkitools2-latest.pkg -target / ; echo "Munki Tools installed. You will need to reboot after this script finishes."

#make necessary directories
mkdir munki_repo
mkdir munki_repo/catalogs
mkdir munki_repo/manifests
mkdir munki_repo/pkgs
mkdir munki_repo/pkgsinfo

#set permissions on these directories
chmod -R a+rX munki_repo

#If setting this up on a computer running Server.app, feel free to configure the web site there, otherwise uncomment the following line
#ln -s $REPO/munki_repo /Library/WebServer/Documents/ && apachectl start

echo "Repoository configured at"
echo $REPO"/munki_repo"

/usr/local/munki/munkiimport --configure
