#!/bin/sh
# Sophos Cloud Installer for KBC
SOPHOSTOKEN=`defaults read /Library/Application\ Support/Sophos/mcs/config/configuration.plist RegistrationToken`
SPTOKEN="f56c0d6d9218fcbf1b2bb4523ffced9aae656e61df73d9494677b7452845e0c0"
TOKENCHECK=`defaults read /Library/Application\ Support/Sophos/mcs/config/configuration.plist RegistrationToken | grep -c $SPTOKEN`
URL="https://dzr-api-amzn-eu-west-1-9af7.api-upe.p.hmr.sophos.com/api/download/787e5463e985ad699559b81f0534e72b/SophosInstall.zip"


# Check if there is a KBC Sophos version installed....
if [ "$SOPHOSTOKEN" != "$SPTOKEN" ]
then
# If no KBC Sophos is installed but a version is available then uninstall it
	if [ -n "$SOPHOSTOKEN" ]
	then
		SPDIR=`ls /Library/Application\ Support/Sophos | grep -v mcs | grep -v tmp`
		/Library/Application\ Support/Sophos/$SPDIR/Installer.app/Contents/MacOS/tools/InstallationDeployer --remove
	fi
	logfile="/Library/Logs/kbc_scb.log"
	user=`ls -l /dev/console | cut -d " " -f 4`
	/bin/echo "`date`: Running Sophos Installer for $user..." >> ${logfile}
	PWD=pwd
	cd /tmp
	echo "`date`: Downloading Sophos installer..." >> ${logfile}
	curl -O "$URL"
	echo "`date`: Extracting Sophos installer..." >> ${logfile}
	unzip -o SophosInstall.zip
	echo "`date`: Adding a+x rights to Sophos installer & its helper..." >> ${logfile}
	chmod a+x /tmp/Sophos\ Installer.app/Contents/MacOS/Sophos\ Installer
	chmod a+x /tmp/Sophos\ Installer.app/Contents/MacOS/tools/com.sophos.bootstrap.helper
	echo "`date`: Installing Sophos ..." >> ${logfile}
	/tmp/Sophos\ Installer.app/Contents/MacOS/Sophos\ Installer --install --tamper_password appleseed
	echo "`date`: Removing Sophos installer..." >> ${logfile}
	rm -rf /tmp/Sophos*
	cd "$PWD"
	echo "`date`: Finished installing Sophos..." >> ${logfile}
fi
exit 0