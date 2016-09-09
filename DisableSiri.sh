#!/bin/sh -x
defaults write com.apple.assistant.support "Assistant Enabled" 0
defaults write com.apple.Siri StatusMenuVisible false
defaults write com.apple.Siri UserHasDeclinedEnable true

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

REMAPP "Siri"
killall Dock

rm $DOCKUTIL