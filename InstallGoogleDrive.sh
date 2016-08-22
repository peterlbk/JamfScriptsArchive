#!/bin/sh -x
logfile="/Library/Logs/jss.log"
user=`ls -l /dev/console | cut -d " " -f 4`
PRODUCT="Google Drive"
#  installation

	/bin/echo "`date`: Installing Google Drive for $user..."  >> ${logfile}
	dmgfile="image.dmg"
	volname="Install Google Drive"
	url="https://dl.google.com/drive/installgoogledrive.dmg"
	/bin/echo "`date`: Downloading $PRODUCT." >> ${logfile}
	/usr/bin/curl -k -o /tmp/image.dmg $url
	/bin/echo "`date`: Mounting installer disk image." >> ${logfile}
	/usr/bin/hdiutil attach /tmp/image.dmg -nobrowse -quiet
	/bin/echo "`date`: Installing..." >> ${logfile}
	cp -R /Volumes/Install\ Google\ Drive/Google\ Drive.app /Applications/
	/bin/sleep 3
	/bin/echo "`date`: Unmounting installer disk image." >> ${logfile}
	/usr/bin/hdiutil detach $(/bin/df | /usr/bin/grep ${volname} | awk '{print $1}') -quiet
	/bin/sleep 3
	open -a /Applications/Google\ Drive.app/
 