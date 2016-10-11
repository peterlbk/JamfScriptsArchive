#!/bin/sh -x
logfile="/Library/Logs/jss.log"
user=`ls -l /dev/console | cut -d " " -f 4`
OSvers_URL=$( sw_vers -productVersion | sed 's/[.]/_/g' )
userAgent="User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X ${OSvers_URL}) ; rv:32.0) Gecko/20100101 Firefox/32.0"

curl -A "${userAgent}" -L https://get.adobe.com/reader/?loc=nl > /tmp/dc.html
ONLINEVER=`cat /tmp/dc.html | grep Versie | awk -F "Versie " '{print$2}' | awk -F "</" '{print$1}'`
ONLINEDMG=`cat /tmp/dc.html | grep mainInstaller | head -1 | awk -F "\"" '{print$2}'`


IFS='.' read over1 over2 over3 <<< "$ONLINEVER"
over1=${over1:2}
echo $over1
echo $over2
echo $over3
OVERALL=$over1$over2$over3

LOCALVER=`defaults read /Applications/Adobe\ Acrobat\ Reader\ DC.app/Contents/Info.plist  CFBundleShortVersionString`

IFS='.' read lver1 lver2 lver3 <<< "$LOCALVER"
echo $lver1
echo $lver2
echo $lver3

rm /tmp/dc.html

installar ()
{
	
	cd /tmp
	volname="AcrobatReader"
	/bin/echo "`date`: Downloading ${volname}..." >> ${logfile}
	DLVER="https://ardownload2.adobe.com/pub/adobe/reader/mac/AcrobatDC/${OVERALL}/AcroRdrDC_${OVERALL}_MUI.dmg"
	curl -L -o /tmp/${volname}.dmg $DLVER
	/bin/echo "`date`: Mounting installer disk image." >> ${logfile}
	/usr/bin/hdiutil attach /tmp/${volname}.dmg -nobrowse -quiet
	/bin/echo "`date`: Installing - Updating ${volname}." >> ${logfile}
	INSTALLER=`ls /Volumes/AcroRdrDC_${OVERALL}_MUI  | grep Acro`
	/usr/sbin/installer -pkg /Volumes/AcroRdrDC_${OVERALL}_MUI/${INSTALLER} -target / > /dev/null
	/bin/echo "`date`: Unmounting installer disk image." >> ${logfile}
	/usr/bin/hdiutil detach $(/bin/df | /usr/bin/grep ${volname} | awk '{print $1}') -quiet
	/bin/echo "`date`: Deleting disk image." >> ${logfile}
	/bin/rm -rf /tmp/${volname}.dmg
}

# If nothing has been installed then install & launch
echo "Let us check for install"
ONLINEVER=${ONLINEVER:2}
if [ -z $LOCALVER ]
then
	echo "No Acrobat Reader found. Installing Acrobat Reader..."
	installar
elif [ $ONLINEVER = $LOCALVER ]
then
	echo "Adobe Reader Up to Date; exiting now"
	exit 0
elif [ $lver1 -lt $over1 ]
then
	echo "Main version higher - installing Acrobat Reader"
	installar
elif [ $lver2 -lt $over2 ]
then
	echo "Medium version higher - installing Acrobat Reader"
	installar
elif [ $lver3 -lt $over3 ]
then
	echo "Minor version higher - installing Acrobat Reader"
	installar
else
	echo "Newer version installed than online available"
	exit 0
fi
