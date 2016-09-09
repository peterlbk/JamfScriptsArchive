#!/bin/sh

# This script displays a message that lets the user know that 
# a browser installation policy has finished. It is set 
# to the lowest priority to ensure that it runs last after all 
# other scripts and policy actions.

# Determine OS version
osvers=$(sw_vers -productVersion | awk -F. '{print $2}')

dialog="Your Crasplan Backup Application is going to launch next.

Please log in the application with your credentials and start your backup manually for this one time.

From that moment on, your backup will run automatically. Once your backup is running you can close the CrashPlan application."
description=`echo "$dialog"`
button1="OK"
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
icon="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/Actions.icns"

if [[ ${osvers} -lt 7 ]]; then

  "$jamfHelper" -windowType utility -description "$description" -button1 "$button1" -icon "$icon"

fi

if [[ ${osvers} -ge 7 ]]; then

  jamf displayMessage -message "$dialog" -windowType hud

fi
sleep 3
open -a /Applications/CrashPlan.app
exit 0