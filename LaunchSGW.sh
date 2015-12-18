#!/bin/sh -x
logfile="/Library/Logs/kbc_scb.log"
user=`ls -l /dev/console | cut -d " " -f 4`


CHECKJA=`ls /Applications/ | grep Junos`

if [ -z "$CHECKJA" ]
then
	SUPPORTURL="https://dev-support2.kbc.be/"
	jamf policy -event installff
	open -a /Applications/Firefox.app "$SUPPORTURL"
else
	open -a /Applications/Junos\ Pulse.app
fi