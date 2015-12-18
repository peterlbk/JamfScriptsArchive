#!/bin/sh -x
logfile="/Library/Logs/kbc_scb.log"
user=`ls -l /dev/console | cut -d " " -f 4`



ONLINEVER=`curl -L https://www.mozilla.org/en/firefox/notes/ | grep Version | awk '{ print $2 }' | sed 's/.\{1\}$//'`
ONLINEMAIN=`echo $ONLINEVER | awk -F "." '{ print $1 }'`
ONLINESUB=`echo $ONLINEVER | awk -F "." '{ print $2 }'`
ONLINEMIN=`echo $ONLINEVER | awk -F "." '{ print $3 }'`

LOCALVER=`defaults read /Applications/Firefox.app/Contents/Info.plist CFBundleGetInfoString | awk '{print $2}'`
LOCALMAIN=`echo $LOCALVER | awk -F "." '{ print $1 }'`
LOCALSUB=`echo $LOCALVER | awk -F "." '{ print $2 }'`
LOCALMIN=`echo $LOCALVER | awk -F "." '{ print $3 }'`

installff ()
{
	cd /tmp
	volname="Firefox"
	/bin/echo "`date`: Downloading Firefox..." >> ${logfile}
	DLVER=`curl https://www.mozilla.org/en-US/install | grep download.mozilla.org | awk '{print $4}' | grep osx  | awk -F "'" '{print $2}' | sed 's/\&amp;/\&/g' | sed 's/firefox-/firefox-'$ONLINEVER'-SSL/g'`
	curl -L -o /tmp/firefox.dmg $DLVER
	/bin/echo "`date`: Mounting installer disk image." >> ${logfile}
	/usr/bin/hdiutil attach /tmp/firefox.dmg -nobrowse -quiet
	/bin/echo "`date`: Installing - Updating Firefox." >> ${logfile}
	ditto -Vv /Volumes/Firefox/Firefox.app/ /Applications/Firefox.app
	chown -R "$user" /Applications/Firefox.app/
	/bin/echo "`date`: Unmounting installer disk image." >> ${logfile}
	/usr/bin/hdiutil detach $(/bin/df | /usr/bin/grep ${volname} | awk '{print $1}') -quiet
	/bin/echo "`date`: Deleting disk image." >> ${logfile}
	/bin/rm -rf /tmp/firefox.dmg
}

# If nothing has been installed then install & launch
if [ -z "$LOCALVER" ]
then 
	installff
	exit 0
elif [ $LOCALMAIN -lt $ONLINEMAIN ]
then 
	installff
elif [ $LOCALSUB -lt $ONLINESUB ]
then 
	installff
elif [ $LOCALMIN -lt $ONLINEMIN ]
then 
	installff
fi