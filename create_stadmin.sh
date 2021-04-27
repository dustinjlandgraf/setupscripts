#!/bin/bash

#This script is intended to be pushed from FileWave
# This script will do a few things, but most importantly;
### It will check if a specified Admin account exists - if it doesn't it will create it
### It will check if a specified Admin account has a secure token - If it doesn't, it will attempt to promote the current user to an admin to grant the secure token to the specified Admin

# It does a few other checks for secure tokens as well - you would be wise to read the whole thing

# Script is butchered by DJL from original found here
# https://travellingtechguy.eu/script-secure-tokens-mojave

# DJL updated for FileWave usage Feb 17, 2021
# DJL added user creation fallback Apr 21, 2021
# DJL added osascript timeout after suggestion from @ggete from FileWave channel in MacAdmins Slack

#The Following Variables need to be set in FileWave as environment variables on the script
#addAdminUser - Shortname of your Admin Account
#addAdminFullname - Long name of Admin user (only used if creating the account)
#addAdminUserPassword - Password for Admin account

#Look for the two osascript sections below if you want to change the prompt titles or wording

# Check if a User is logged in
if pgrep -x "Finder" \
&& pgrep -x "Dock" \
&& [ "$CURRENTUSER" != "_mbsetupuser" ]; then


# Check if the admin provided exists on the system
	if [[ $("/usr/sbin/dseditgroup" -o checkmember -m $addAdminUser admin / 2>&1) =~ "Unable" ]]; then
  		addAdminUserType="UserDoesNotExist"
  		else
  		addAdminUserType="UserExists"
	fi
	if [ "$addAdminUserType" = UserDoesNotExist ]; then
		echo "Specified Admin account does not exist. Creating now."
         			SECONDARY_GROUPS="admin _lpadmin _sshd"

         			#Use the next available UID
         			MAXID=$(dscl . -list /Users UniqueID | awk '{print $2}' | sort -ug | tail -1)
         			USERID=$((MAXID+1))

         			# Create the user account
         			dscl . -create /Users/$addAdminUser
         			dscl . -create /Users/$addAdminUser UserShell /bin/zsh
         			dscl . -create /Users/$addAdminUser RealName "$addAdminFullname"
         			dscl . -create /Users/$addAdminUser UniqueID "$USERID"
         			dscl . -create /Users/$addAdminUser PrimaryGroupID 20
         			dscl . -create /Users/$addAdminUser NFSHomeDirectory /Users/$addAdminUser
         			dscl . -passwd /Users/$addAdminUser $addAdminUserPassword

         			# Add user to any specified groups
         			for GROUP in $SECONDARY_GROUPS ; do
          				dseditgroup -o edit -t user -a $addAdminUser $GROUP
        			done

      			#Create the home directory
      			createhomedir -c -u $addAdminUser
      	else
        		echo "Admin user status: Account exists!"
	fi

# Check if our admin has a Secure Token
	if [[ $("/usr/sbin/sysadminctl" -secureTokenStatus "$addAdminUser" 2>&1) =~ "ENABLED" ]]; then
		adminToken="true"
	else
		adminToken="false"
	fi
  	echo "Admin Token: $adminToken"

# Check if $addAdminUser is actually an administrator
	if [[ $("/usr/sbin/dseditgroup" -o checkmember -m $addAdminUser admin / 2>&1) =~ "yes" ]]; then
		AdminUserType="IsAdmin"
	else
		AdminUserType="IsNotAdmin"
	fi
	echo "Admin Account Status: $AdminUserType"

#Fixing the admin to make it admin
	if [ "$AdminUserType" = IsNotAdmin ]; then
		dscl . -append /groups/admin GroupMembership $addAdminUser
		echo "Admin Promo status: It was not admin but now it is"
	else
		echo "Admin Promo status: No Action Needed "
	fi

# Check if FileVault is Enabled
# I'm not using this variable in the rest of the script. Only added it in case you want to customise the script and enable FileVault at the end if 'fvStatus' is false
	if [[ $("/usr/bin/fdesetup" status 2>&1) =~ "FileVault is On." ]]; then
		fvStatus="true"
		else
		fvStatus="false"
	fi
  	echo "FV Status: $fvStatus"

# Check Secure Tokens Status - Do we have any Token Holder?
	if [[ $("/usr/sbin/diskutil" apfs listcryptousers / 2>&1) =~ "No cryptographic users" ]]; then
		tokenStatus="false"
	else
		tokenStatus="true"
	fi
	echo "Token Status $tokenStatus"


# Get the current logged in user
	userName=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

# Check if end user is admin
	if [[ $("/usr/sbin/dseditgroup" -o checkmember -m $userName admin / 2>&1) =~ "yes" ]]; then
  		userType="Admin"
  	else
  		userType="Not admin"
	fi
	echo "User type: $userType"

# Check Token status for end user

	if [[ $("/usr/sbin/sysadminctl" -secureTokenStatus "$userName" 2>&1) =~ "ENABLED" ]]; then
 		userToken="true"
  	else
		userToken="false"
	fi
		echo "User Token: $userToken"

# If both end user and additional admin have a secure token

	if [[ $userToken = "true" && $adminToken = "true" ]]; then
		echo "Admin has a token"
		exit 0
	fi

# Prompt for password

	echo "Prompting ${userName} for their login password."
userPass="$(/usr/bin/osascript -e 'tell application "System Events"
	with timeout of 3600 seconds
		display dialog "Please enter your current computer password" default answer "" with title "Admin Account Setup" with text buttons {"Ok"} default button 1 with hidden answer
	end timeout
end tell' -e 'text returned of result')"

# Check if the password is ok

	passDSCLCheck=`dscl /Local/Default authonly $userName $userPass; echo $?`

# If password is not valid, loop and ask again

	while [[ "$passDSCLCheck" != "0" ]]; do
		echo "asking again"
userPassAgain="$(/usr/bin/osascript -e 'tell application "System Events"
	with timeout of 3600 seconds
		display dialog "Please enter your current computer password" default answer "" with title "Admin Account Setup" with text buttons {"Ok"} default button 1 with hidden answer
	end timeout
end tell' -e 'text returned of result')"
		userPass=$userPassAgain
		passDSCLCheck=`dscl /Local/Default authonly $userName $userPassAgain; echo $?`
	done

	if [ "$passDSCLCheck" -eq 0 ]; then
		echo "Password OK for $userName"
	fi

# If additional admin has a token but end user does not

	if [[ $adminToken = "true" && $userToken = "false" ]]; then
		sysadminctl -adminUser $addAdminUser -adminPassword $addAdminUserPassword -secureTokenOn $userName -password $userPass
		echo "Token granted to end user!"
		diskutil apfs listcryptousers /
	fi

# If no Token Holder exists, just grant both admin and end user a token

	if [[ $tokenStatus = "false" && $userToken="false" ]]; then
		sysadminctl -adminUser $addAdminUser -adminPassword $addAdminUserPassword -secureTokenOn $userName -password $userPass
		echo "Token granted to both additional admin and end user!"
		diskutil apfs listcryptousers /
	fi

# If end user is an admin Token holder while our additional admin does not have one

	if [[ $userType = "Admin" && $userToken = "true" && $adminToken = "false" ]]; then
		sysadminctl -adminUser $userName -adminPassword $userPass -secureTokenOn $addAdminUser -password $addAdminUserPassword
		echo "End user admin token holder granted token to additional admin!"
		diskutil apfs listcryptousers /
	fi

# If end user is a non-admin token holder and our additional admin does not have a Token yet

	if [[ $userType = "Not admin" && $userToken = "true" && $adminToken = "false" ]]; then
		echo "We have a problem."
		dscl . -append /groups/admin GroupMembership $userName
		echo "End user promoted to admin!"
		sysadminctl -adminUser $userName -adminPassword $userPass -secureTokenOn $addAdminUser -password $addAdminUserPassword
		echo "End user admin token holder granted token to additional admin!"
		diskutil apfs listcryptousers /
		dscl . -delete /groups/admin GroupMembership $userName
		echo "End user demoted back to standard user"
	fi


else
	echo "No user logged in"
	exit 1
fi

exit 0
