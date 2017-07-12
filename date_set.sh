#!/bin/bash

#This is a stupid script to  reset the clock.
#It can be useful for LDAP troubleshooting or using it during an imaging workflow
#DJL2017
#Don't blame me...

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

echo "It is currently $(date)"
/usr/sbin/systemsetup -setnetworktimeserver time.apple.com
/usr/sbin/systemsetup -setusingnetworktime on
echo "Attempting to check in with time server"
ntpd -g -q
echo "It is currently $(date)"

exit 0
