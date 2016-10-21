#!/bin/sh
logfile="/Library/Logs/jss.log"
user=`ls -l /dev/console | cut -d " " -f 4`
PRODUCT="MS RD"
#  installation
LOCALVER=`defaults read /Applications/Microsoft\ Remote\ Desktop.app/Contents/Info.plist CFBundleShortVersionString`
ONLINEVER=`curl -L http://go.microsoft.com/fwlink/?LinkID=619698 2>/dev/null | grep "Version" | awk -F " " '{print$2}' | head -1`

installmsrd ()
{
	/bin/echo "`date`: Installing $product for $user..."  >> ${logfile}
	dlurl=`curl -L http://go.microsoft.com/fwlink/?LinkID=619698 2>/dev/null | grep "btn-ha-primary" | awk -F "'" '{print$4}'`
	cd /tmp/
	curl -L -O https://rink.hockeyapp.net/api/2/apps/5e0c144289a51fca2d3bfa39ce7f2b06/app_versions/48?format=zip
	/bin/echo "`date`: Downloading $PRODUCT." >> ${logfile}
	unzip 48\?format\=zip -d /Applications/
	/bin/echo "`date`: Installing..." >> ${logfile}
	mv "/Applications/Microsoft Remote Desktop Beta.app" "/Applications/Microsoft Remote Desktop.app"
	open -a "/Applications/Microsoft Remote Desktop.app"
	
}



if [ -z $LOCALVER ]
	then
		echo "No $product found. Installing $product..."
		installmsrd
elif [ $ONLINEVER != $LOCALVER ]
then
	echo "Updating $product..."
	installmsrd
else
	echo "Latest Version installed"
fi
 