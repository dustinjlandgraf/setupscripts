#!/bin/bash

#This is a stupid script to reset the clock on a Mac.
#It can be useful for LDAP troubleshooting or using it during an imaging workflow.
#DJL2017
#Don't blame me...

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

tput bold
echo "It is currently $(date)"
tput sgr0
/usr/sbin/systemsetup -setnetworktimeserver time.apple.com
/usr/sbin/systemsetup -setusingnetworktime on
echo "Attempting to check in with time server"
ntpd -g -q
tput bold
echo "It is currently $(date)"
tput sgr0

exit 0
