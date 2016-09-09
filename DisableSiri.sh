#!/bin/sh -x
logfile="/Library/Logs/jss.log"
user=`ls -l /dev/console | cut -d " " -f 4`

sudo -u $user defaults write com.apple.assistant.support "Assistant Enabled" 0
sudo -u $user defaults write com.apple.Siri StatusMenuVisible false
sudo -u $user defaults write com.apple.Siri UserHasDeclinedEnable true

cd /tmp
curl -O https://raw.githubusercontent.com/kcrawford/dockutil/master/scripts/dockutil
chmod a+x /tmp/dockutil

DOCKUTIL=/tmp/dockutil

sudo -u $user DOCKUTIL --add "/Applications/Siri.app"
sudo -u $user DOCKUTIL --remove "Siri"
killall -KILL SystemUIServer
killall Dock