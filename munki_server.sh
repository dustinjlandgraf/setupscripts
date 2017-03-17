#!/bin/bash

#DJL2017
#Set the parent directory for your repository here. Do not include a trailing slash!
REPO=/Users/Shared

cd "$REPO"

#Download the current version of software
curl -O https://munkibuilds.org/munkitools2-latest.pkg
installer -pkg munkitools2-latest.pkg -target / ; echo "Munki Tools installed. You will need to reboot after this script finishes."

USER=`ls -la /dev/console | awk '{print $3}'`
su $USER -c '/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
su $USER -c 'brew cask install autodmg'

#make necessary directories
mkdir -p munki_repo/{catalogs,manifests,pkgs,pkgsinfo}

#set permissions on these directories
chmod -R a+rX munki_repo

if [ -e /Applications/Server.app ]
then
        echo "Server.app is installed. Installing DeployStudio. Please configure Munki Repo in Websites section of Server.app"
        su $USER -c 'brew cask install deploystudio'
else
        echo "Server.app is not installed. Creating link to Munki Repo and starting Apache."
        ln -s $REPO/munki_repo /Library/WebServer/Documents/ && apachectl start
fi

echo "Repoository configured at"
echo $REPO"/munki_repo"

/usr/local/munki/munkiimport --configure
