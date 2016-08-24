#!/bin/sh -x
logfile="/Library/Logs/jss.log"
user=`ls -l /dev/console | cut -d " " -f 4`
PRODUCT="Citrix HDX"
#  installation
installcr ()
{
	/bin/echo "`date`: Installing Citrix HDX Plugin for $user..."  >> ${logfile}
	dmgfile="image.dmg"
	volname="HDXRealTimeMediaEngine"
	url1=`curl https://www.citrix.nl/downloads/search.html?qs=hdx%20realtime%20engine | grep "for Mac" | head -1 | awk -F "\"" '{print $2}'`
	url2="https://www.citrix.nl$url1"
	url3=`curl https://www.citrix.nl/downloads/citrix-receiver/additional-client-software/hdx-realtime-media-engine-21.html | grep .dmg | awk -F ".dmg" '{print $0}' | sed -n '2p' | awk -F "rel=\"" '{print $2}' | awk -F "\"" '{print $1}'`
	url="https:$url3"
	/bin/echo "`date`: Downloading $PRODUCT." >> ${logfile}
	/usr/bin/curl -k -o /tmp/image.dmg $url
	/bin/echo "`date`: Mounting installer disk image." >> ${logfile}
	/usr/bin/hdiutil attach /tmp/image.dmg -nobrowse -quiet
	/bin/echo "`date`: Installing..." >> ${logfile}
	/usr/sbin/installer -pkg /Volumes/HDXRealTimeMediaEngine/Install\ HDXRealTimeMediaEngine.pkg -target / > /dev/null
	#/bin/sleep 10
	/bin/echo "`date`: Unmounting installer disk image." >> ${logfile}
	/usr/bin/hdiutil detach $(/bin/df | /usr/bin/grep ${volname} | awk '{print $1}') -quiet
	#/bin/sleep 10
	/bin/echo "`date`: Deleting disk image." >> ${logfile}
	/bin/rm `/tmp/image.dmg`/${dmgfile}
}


# Check for installed version
localver=`defaults read /Library/PreferencePanes/Citrix\ HDX\ RealTime\ Media\ Engine.prefPane/Contents/Info.plist RTMEVersion | awk -F "." '{ print $1,$2}'`



# If nothing has been installed then install & launch
if [ -z "$localver" ]
then
# no citrix hdx installed, install
	installcr
	echo "installing "
	exit 0
fi

onlinever=`curl https://www.citrix.nl/downloads/search.html?qs=hdx%20realtime%20engine | grep "for Mac" | head -1 | awk -F "HDX RealTime Media Engine " {'print$2'} | awk -F " " {'print$1'} | awk -F "." '{print $1,$2}'`



if [ "$localver" != "$onlinever" ]
then
# main local version is less than online version
	installcr
	exit 0
fi
