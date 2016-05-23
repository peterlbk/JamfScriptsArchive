#!/bin/sh -x
logfile="/Library/Logs/mac2.log"
user=`ls -l /dev/console | cut -d " " -f 4`

# Sequel Pro installation
installtv ()
{
	/bin/echo "`date`: Installing Teamviewer for $user..."  >> ${logfile}
	dmgfile="sequelpro.dmg"
	spver=`curl http://www.sequelpro.com/download | grep dmg |  awk -F "-" '{print $2}' | awk -F "/" '{print $1}'`
	volname="Sequel Pro ${spver}"
	url=`curl http://www.sequelpro.com/download | grep dmg |  awk -F "\"" '{print $2}'`
	/bin/echo "`date`: Downloading Sequel Pro." >> ${logfile}
	/usr/bin/curl -o /tmp/${dmgfile} -L $url
	/bin/echo "`date`: Mounting installer disk image." >> ${logfile}
	/usr/bin/hdiutil attach /tmp/${dmgfile} #-nobrowse -quiet
	/bin/echo "`date`: Installing..." >> ${logfile}
	mv "/Applications/Sequel Pro.app" /tmp/
	cp -R "/Volumes/${volname}/Sequel Pro.app" "/Applications/"
	/bin/sleep 10
	/bin/echo "`date`: Unmounting installer disk image." >> ${logfile}
	/usr/bin/hdiutil detach $(/bin/df | /usr/bin/grep ${volname} | awk '{print $1}') -quiet
	/bin/sleep 10
	/bin/echo "`date`: Deleting disk image." >> ${logfile}
	/bin/rm `/tmp/`${dmgfile}
}




# Check for installed version
localver=`defaults read /Applications/Sequel\ Pro.app/Contents/Info.plist CFBundleShortVersionString`

# If nothing has been installed then install & launch
if [ -z "$localver" ]
then 
	installtv
	exit 0
fi

onlinever=`curl http://www.sequelpro.com/download | grep dmg |  awk -F "-" '{print $2}' | awk -F "/" '{print $1}'`

# If latest version is installed then exit
if [ "$localver" != "$onlinever" ]
then 
	installtv
	exit 0
fi


