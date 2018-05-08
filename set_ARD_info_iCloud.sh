#!/bin/bash

#Script will find what iCloud account is in use and insert it into Computer Info field 4, then forces a Watchman update.
#Script is intended to be run as system.

#Get current console user
USER=`stat -f "%Su" /dev/console`

#Find iCloud Account
ACCOUNT=$(sudo -u $USER defaults read MobileMeAccounts | grep AccountID | cut -d "\"" -f 2)

#Set iCloud account as Computer Info 4 field in ARD
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -computerinfo -set4 -4 $ACCOUNT

#Force Watchman to update
/Library/MonitoringClient/RunClient -F
