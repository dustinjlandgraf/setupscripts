#!/bin/bash

#This script will attempt to reset the enrollment status of a macOS device without having to do a full nuke and pave
#Intended for testing devices running Mojave and up
#DJL2020

#script must be run as root!

rm /var/db/.AppleSetupDone
echo "Removed .AppleSetupDone File"
rm /Library/Keychains/apsd.keychain
echo "Removed Apple Push Keychain"
rm -rf /var/db/ConfigurationProfiles/
echo "Removed all configuration profiles"

echo "Rebooting Now"
echo "Good luck and Godspeed!"
shutdown -r now