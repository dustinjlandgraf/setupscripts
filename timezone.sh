#!/bin/bash
#DJL2017

#script to set time zone to Chicago

/usr/sbin/systemsetup -setnetworktimeserver time.apple.com
/usr/sbin/systemsetup -setusingnetworktime on
/usr/sbin/systemsetup -settimezone America/Chicago
