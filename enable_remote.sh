#!/bin/bash

#Enable Remote Login
systemsetup -setremotelogin on

#Restrict remote login to the Admin group
dseditgroup -o edit -a admin -t group com.apple.access_ssh

#Enable Remote Management and restrict to Admin Group
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -allowAccessFor -specifiedUsers
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -on -users ardadmin -privs -all -restart -agent -menu
