#!/bin/bash

#This script will change security settings on a Mac to allow all users to edit some system settings
#DJL2018

#Allow access to System Preferences. This command is required, the others can be commented out.
security authorizationdb write system.preferences allow

#Allow access to Printer preferences
security authorizationdb write system.preferences.printing allow

#Allow access to Energy Saver preferences
security authorizationdb write system.preferences.energysaver allow

#Allow access to Network preferences
security authorizationdb write system.preferences.network allow
