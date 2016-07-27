#!/bin/sh
# Determine OS version
osvers=$(sw_vers -productVersion | awk -F. '{print $2}')

# check if newer version exists
plugin="/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Info.plist"
if [ -f "$plugin" ]
then
	currentver=`/usr/bin/defaults read "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Info.plist" CFBundleShortVersionString`
	echo " Current version is $currentver"
	currentvermain=${currentver:5:1}
	echo "Installed main version is $currentvermain"
	currentvermin=${currentver:14:2}
	echo "Installed minor version is $currentvermin"
	onlineversionmain=`curl http://www.java.com/en/download/manual.jsp | grep "Recommended Version" | awk '{ print $4}'`
	echo "Online main: $onlineversionmain"
	onlineversionmin1=`curl http://www.java.com/en/download/manual.jsp | grep "Recommended Version" | awk '{ print $6}' | awk -F "<" '{ print $1}'`
	onlineversionmin=${onlineversionmin1:0:3}
	echo "Online minor: $onlineversionmin"
	if [ -z "$currentvermain" ] || [ "$onlineversionmain" -gt "$currentvermain" ]
	then
		echo "Let's install Java! Main online version is higher than installed version."
		installjava=1
	fi
	if [ "$onlineversionmain" = "$currentvermain" ] && [ "$onlineversionmin" -gt "$currentvermin" ]
	then
		echo "Let's install Java! Main online version is equal than installed version, but minor version is higher."
		installjava=1
	fi
	if [ "$onlineversionmain" = "$currentvermain" ] && [ "$onlineversionmin" = "$currentvermin" ]
	then
		echo "Java is up-to-date!"
	fi
else
	echo "No java installed, let's install"
	installjava=1
fi


# Find Download URL
fileURL=`curl http://www.java.com/en/download/manual.jsp | grep "Download Java for Mac OS X" | awk -F "\"" '{ print $4;exit}'`


# Specify name of downloaded disk image

java_eight_dmg="/tmp/java_eight.dmg"

if [[ ${osvers} -lt 7 ]]; then
  echo "Oracle Java 8 is not available for Mac OS X 10.6.8 or earlier."
  exit 0
fi