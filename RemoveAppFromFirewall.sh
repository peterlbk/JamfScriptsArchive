#!/bin/sh -x

APP="/usr/sbin/httpd"


#### NO CHANGES BELOW THIS LINE ####

CHECKEXISTS=`/usr/libexec/ApplicationFirewall/socketfilterfw --listapps | grep $APP`

if [[ -z $CHECKEXISTS ]]; then
	echo "app doesn't exist, exiting now"
else
	echo "app does exist, removing from firewall exception"
	/usr/libexec/ApplicationFirewall/socketfilterfw --remove $APP
fi