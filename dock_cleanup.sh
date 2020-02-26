#!/bin/zsh

#This script is intended to get rid of some of the default nonsense in the Dock when a new user logs in for the first time
#DJL Feb 19, 2020

/usr/local/bin/dockutil --remove 'Mail'
/usr/local/bin/dockutil --remove 'Calendar'
/usr/local/bin/dockutil --remove 'Contacts'
/usr/local/bin/dockutil --remove 'Reminders'
/usr/local/bin/dockutil --remove 'Messages'
/usr/local/bin/dockutil --remove 'FaceTime'
/usr/local/bin/dockutil --remove 'Music'
/usr/local/bin/dockutil --remove 'TV'
/usr/local/bin/dockutil --remove 'Podcasts'

exit 0
