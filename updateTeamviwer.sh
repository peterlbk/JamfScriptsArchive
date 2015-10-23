#!/bin/sh -x
logfile="/Library/Logs/mac2.log"
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


# Check for installed version
localver=`defaults read /Applications/TeamViewer.app/Contents/Info.plist CFBundleShortVersionString`

# If nothign has been installed then install
if [ -z "$localver" ]
then 
	installtv
	exit 0
fi

onlinever=`curl https://www.teamviewer.com/en/download/changelog/mac/  | grep "Version " | sed -n 2p | awk '{print $3}' | sed 's/.\{5\}$//'`

# If latest version is installed then exit
if [ "$localver" = "$onlinever" ]
then 
	exit 0
fi

# If main version differs, install
mainlocal=`defaults read /Applications/TeamViewer.app/Contents/Info.plist CFBundleShortVersionString | awk -F "." '{ print $1 }'`
sublocal=`defaults read /Applications/TeamViewer.app/Contents/Info.plist CFBundleShortVersionString | awk -F "." '{ print $2 }'`
minlocal=`defaults read /Applications/TeamViewer.app/Contents/Info.plist CFBundleShortVersionString | awk -F "." '{ print $3 }'`

mainonline=`curl https://www.teamviewer.com/en/download/changelog/mac/  | grep "Version " | sed -n 2p | awk '{print $3}' | sed 's/.\{5\}$//' | awk -F "." '{ print $1 }'`
subonline=`curl https://www.teamviewer.com/en/download/changelog/mac/  | grep "Version " | sed -n 2p | awk '{print $3}' | sed 's/.\{5\}$//' | awk -F "." '{ print $2 }'`
minonline=`curl https://www.teamviewer.com/en/download/changelog/mac/  | grep "Version " | sed -n 2p | awk '{print $3}' | sed 's/.\{5\}$//' | awk -F "." '{ print $3 }'`

if [ $mainlocal -lt $mainonline ]
then 
	installtv
	exit 0
elif [ $sublocal -lt $subonline ]
then 
	installtv
	exit 0
elif [ $minlocal -lt $minonline ]
then 
	installtv
	exit 0
fi

/bin/echo "`date`: Launching Teamviewer..." >> ${logfile}
open -a /Applications/TeamViewerQS.app