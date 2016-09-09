#!/bin/sh -x
logfile="/Library/Logs/jss.log"
user=`ls -l /dev/console | cut -d " " -f 4`

# Step 0: Setup Dockutil and Remove Dock Icons

cd /tmp
curl -O https://raw.githubusercontent.com/kcrawford/dockutil/master/scripts/dockutil
chmod a+x /tmp/dockutil

DOCKUTIL=/tmp/dockutil

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

sudo -u $user $DOCKUTIL  --add "/Applications/Self Service.app"

#cleaning up the mess

rm /tmp/dockutil
killall Dock