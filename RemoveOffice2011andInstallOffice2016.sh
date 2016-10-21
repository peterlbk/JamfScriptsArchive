#!/bin/sh -x

####################################################################################################
#
# HISTORY
#
#	Version: 1.1 February 2016
#
#	- Original Script by Daniel Slijper to remove office 2011 https://jamfnation.jamfsoftware.com/viewProfile.html?userID=22820
#	- Dockutil and its functions added by Peter Loobuyck https://jamfnation.jamfsoftware.com/viewProfile.html?userID=10731
#	- customEvent added to install Office 2016 by JSS
#	
####################################################################################################

# HARDCODED VALUES SET HERE

customEvent="" 			# The custom event name used to install Office 2016

if [ "$4" != "" ] && [ "${customEvent}" == "" ]
then
    customEvent=${4}
fi

if [ "${customEvent}" == "" ]
then
	>&2 echo "Error: The 'customEvent' parameter is blank. Please specify a custom event name to install Office 2016."
	exit
fi

####################################################################################################
#
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

# Determine current user

USER=`ls -l /dev/console | cut -d " " -f 4`

# Step 0: Setup Dockutil and Remove Dock Icons
cd /tmp
curl -O https://raw.githubusercontent.com/kcrawford/dockutil/master/scripts/dockutil
chmod a+x /tmp/dockutil

DOCKUTIL=/tmp/dockutil

REMAPP () {
   if [ -e "$DOCKUTIL" ]
	then
	DOCKITEM="$1"
	# Check if item exists
	
	APP="/Applications/Microsoft\ Office\ 2011/${DOCKITEM}.app"
	CHECKDOCKITEM=`${DOCKUTIL} --find "$DOCKITEM" /Users/$USER  | grep "not found"`
	if [ -e "$CHECKDOCKITEM" ];
	then
		echo 'Dockitem found - no action taken'
	else 
		echo "$DOCKITEM found - removing $DOCKITEM now..."
		$DOCKUTIL  --remove "$DOCKITEM"
	fi
fi
}

# REMAPP twice to remove all versions of office from the Dock
REMAPP "Microsoft Word"
REMAPP "Microsoft PowerPoint"
REMAPP "Microsoft Outlook"
REMAPP "Microsoft Excel"

REMAPP "Microsoft Word"
REMAPP "Microsoft PowerPoint"
REMAPP "Microsoft Outlook"
REMAPP "Microsoft Excel"



# Step 1: Remove Microsoft Office 2011 Application folder

rm -rf "/Applications/Microsoft Office 2011"
rm -rf "/Applications/Microsoft Communicator.app"
rm -rf "/Applications/Microsoft Messenger.app"


# Step 2: Remove preference and license files and Office folder
# a. Remove various com.microsoft files and Office folder from Home > Library folders

mv /Users/${USER}/Library/Preferences/com.microsoft.autoupdate2.plist /Users/${USER}/Library/Preferences/com.microsnot.autoupdate2.plist
rm -rf /Users/${USER}/Library/Preferences/com.microsoft.*
mv /Users/${USER}/Library/Preferences/com.microsnot.autoupdate2.plist /Users/${USER}/Library/Preferences/com.microsoft.autoupdate2.plist
rm -rf /Users/${USER}/Library/Preferences/ByHost/com.microsoft.*
rm -rf /Users/${USER}/Library/Preferences/ByHost/Microsoft*

# b. Remove various com.microsoft.office.licensing files from Computer > Library folders

rm -rf /Library/LaunchDaemons/com.microsoft.office.licensing.helper.plist
rm -rf /Library/Preferences/com.microsoft.office.licensing.plist
rm -rf /Library/PrivilegedHelperTools/com.microsoft.office.licensing.helper

# Step 3: Remove Microsoft folders and Office 2011 files

rm -rf "/Users/${USER}/Library/Application Support/Microsoft/Office"
rm -rf "/Library/Application Support/Microsoft"
rm -rf /Library/Receipts/Office2011_*

# Step 4: Move old Microsoft User Data to Desktop for user to delete in case POP mailboxes exist

mv "/Users/${USER}/Documents/Microsoft User Data" /Users/${USER}/Desktop/OldMSUserData

# Step 5: Install MS Office 2016 by running custom event

/usr/local/jamf/bin/jamf policy -event "${customEvent}"

# Step 6: Add new office icons to the Dock

ADDAPP () {
   if [ -e "$DOCKUTIL" ]
	then
	DOCKITEM="$1"
	# Check if item exists
	
	APP="/Applications/${DOCKITEM}.app"
	CHECKDOCKITEM=`${DOCKUTIL} --find "$DOCKITEM" /Users/$USER  | grep "not found"`
	if [ -z "$CHECKDOCKITEM" ];
	then
		echo 'Dockitem found - no action taken'
	else 
		echo "$DOCKITEM  not found - adding $DOCKITEM now..."
		$DOCKUTIL  --add "$APP"
	fi
fi
}

ADDAPP "Microsoft Word"
ADDAPP "Microsoft PowerPoint"
ADDAPP "Microsoft Outlook"
ADDAPP "Microsoft Excel"

# Step 7 Cleaning up the mess...
rm /tmp/dockutil


