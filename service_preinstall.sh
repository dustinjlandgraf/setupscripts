#!/bin/bash

#Check to see if there is a Services directory at the system level

if [ ! -d "/Library/Services" ]; then
  mkdir /Library/Services
fi