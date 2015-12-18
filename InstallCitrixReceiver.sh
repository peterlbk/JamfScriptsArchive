#!/bin/sh -x
logfile="/Library/Logs/jss.log"
user=`ls -l /dev/console | cut -d " " -f 4`
PRODUCT="Receiver"
#  installation
installcr ()
{
	/bin/echo "`date`: Installing Citrix Receiver for $user..."  >> ${logfile}
	dmgfile="image.dmg"
	volname="Citrix Receiver"
	url="https://downloadplugins.citrix.com.edgesuite.net/Mac/CitrixReceiverWeb.dmg"
	/bin/echo "`date`: Downloading $PRODUCT." >> ${logfile}
	/usr/bin/curl -k -o /tmp/image.dmg $url
	/bin/echo "`date`: Mounting installer disk image." >> ${logfile}
	/usr/bin/hdiutil attach /tmp/image.dmg -nobrowse -quiet
	/bin/echo "`date`: Installing..." >> ${logfile}
	/usr/sbin/installer -pkg /Volumes/Citrix\ Receiver/Install\ Citrix\ Receiver.pkg -target / > /dev/null
	/bin/sleep 10
	/bin/echo "`date`: Unmounting installer disk image." >> ${logfile}
	/usr/bin/hdiutil detach $(/bin/df | /usr/bin/grep ${volname} | awk '{print $1}') -quiet
	/bin/sleep 10
	/bin/echo "`date`: Deleting disk image." >> ${logfile}
	/bin/rm `/tmp/image.dmg`/${dmgfile}
}


# Check for installed version
localmain=`defaults read /Applications/Citrix\ Receiver.app/Contents/Info.plist CFBundleShortVersionString | awk -F "." {'print$1'}`
#emainonline=`defaults read /Applications/Citrix\ Receiver.app/Contents/Info.plist CFBundleShortVersionString | awk -F "." {'print$2'}`



# If nothing has been installed then install & launch
if [ -z "$localmain" ]
then 
# no citrix installed, install
	installcr
	exit 0
fi

onlinever=`curl https://www.citrix.nl/downloads/citrix-receiver.html | grep "receiver-for-mac-latest.html" | awk -F "Receiver" {'print$2'} | rev | cut -c 81- | rev`
mainonline=`echo $onlinever | awk -F "." {'print$1'}`
subonline=`echo $onlinever | awk -F "." {'print$2'}`

# If main version differs, install
mainlocal=`defaults read /Applications/Citrix\ Receiver.app/Contents/Info.plist CFBundleShortVersionString | awk -F "." '{ print $1 }'`
sublocal=`defaults read /Applications/Citrix\ Receiver.app/Contents/Info.plist CFBundleShortVersionString | awk -F "." '{ print $2 }'`
minlocal=`defaults read /Applications/Citrix\ Receiver.app/Contents/Info.plist CFBundleShortVersionString | awk -F "." '{ print $3 }'`

if [ $mainlocal -lt $mainonline ]
then 
# main local version is less than online version
	installcr
	exit 0
elif [ $sublocal -lt $subonline ]
then 
# main local and online are equal, but if minor version differs
	installcr
	exit 0
fi
