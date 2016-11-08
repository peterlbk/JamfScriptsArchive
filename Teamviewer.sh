#!/bin/sh -x
logfile="/Library/Logs/jamf.log"
user=`ls -l /dev/console | cut -d " " -f 4`

# Teamviewer installation
installtv ()
{
	/bin/echo "`date`: Installing Teamviewer for $user..."  >> ${logfile}
	dmgfile="teamviewer.dmg"
	volname="TeamViewerQS"
	url="http://downloadeu2.teamviewer.com/download/TeamViewerQS.dmg"
	/bin/echo "`date`: Downloading Teamviewer." >> ${logfile}
	/usr/bin/curl -o /tmp/teamviewer.dmg $url
	/bin/echo "`date`: Mounting installer disk image." >> ${logfile}
	/usr/bin/hdiutil attach /tmp/teamviewer.dmg -nobrowse -quiet
	/bin/echo "`date`: Installing..." >> ${logfile}
	cp -R /Volumes/TeamViewerQS/TeamViewerQS.app /Applications/TeamViewerQS.app
	/bin/sleep 10
	/bin/echo "`date`: Unmounting installer disk image." >> ${logfile}
	/usr/bin/hdiutil detach $(/bin/df | /usr/bin/grep ${volname} | awk '{print $1}') -quiet
	/bin/sleep 10
	/bin/echo "`date`: Deleting disk image." >> ${logfile}
	/bin/rm `/tmp/teamviewer.dmg`/${dmgfile}
}


launchtv ()
{
/bin/echo "`date`: Launching Teamviewer..." >> ${logfile}
sudo -u "$user" open -a /Applications/TeamViewerQS.app
}



# Check for installed version
localver=`defaults read /Applications/TeamViewerQS.app/Contents/Info.plist CFBundleShortVersionString`

# If nothing has been installed then install & launch
if [ -z ${localver} ]
then
	installtv
	launchtv
	exit 0
fi

onlinever=`curl http://www.teamviewer.com/en/download/changelog/  | grep "Version" | sed -n 4p | awk -F "</h4>" '{print $1}' | cut -d" " -f2`

# If latest version is installed then exit
if [ "$localver" = "$onlinever" ]
then
	launchtv
	exit 0
fi

# If main version differs, install
mainlocal=`defaults read /Applications/TeamViewerQS.app/Contents/Info.plist CFBundleShortVersionString | awk -F "." '{ print $1 }'`
sublocal=`defaults read /Applications/TeamViewerQS.app/Contents/Info.plist CFBundleShortVersionString | awk -F "." '{ print $2 }'`
minlocal=`defaults read /Applications/TeamViewerQS.app/Contents/Info.plist CFBundleShortVersionString | awk -F "." '{ print $3 }'`

mainonline=`curl http://www.teamviewer.com/en/download/changelog/  | grep "Version" | sed -n 4p | awk -F "</h4>" '{print $1}' | cut -d" " -f2 | awk -F "." '{ print $1 }'`
subonline=`curl http://www.teamviewer.com/en/download/changelog/  | grep "Version" | sed -n 4p | awk -F "</h4>" '{print $1}' | cut -d" " -f2 | awk -F "." '{ print $2 }'`
minonline=`curl http://www.teamviewer.com/en/download/changelog/  | grep "Version" | sed -n 4p | awk -F "</h4>" '{print $1}' | cut -d" " -f2 | awk -F "." '{ print $3 }'`

if [ -z ${mainlocal} ]
then
	installtv
	launchtv
	exit 0
elif [ ${mainlocal} -lt ${mainonline} ]
then
	installtv
	launchtv
	exit 0
elif [ $sublocal -lt $subonline ]
then
	installtv
	launchtv
	exit 0
elif [ $minlocal -lt $minonline ]
then
	installtv
	launchtv
	exit 0
fi
