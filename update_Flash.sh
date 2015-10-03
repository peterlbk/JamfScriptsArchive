#!/bin/sh

dmgfile="flash.dmg"
volname="Flash"
logfile="/Library/Logs/FlashUpdateScript.log"


    latestver=`/usr/bin/curl -s http://www.adobe.com/software/flash/about/ | sed -n '/Safari/,/<\/tr/s/[^>]*>\([0-9].*\)<.*/\1/p'`
    # Get the version number of the currently-installed Flash Player, if any.
    shortver=${latestver:0:2}
    url=http://fpdownload.macromedia.com/get/flashplayer/current/licensing/mac/install_flash_player_"${shortver}"_osx.dmg
    currentinstalledver=`/usr/bin/defaults read "/Library/Internet Plug-Ins/Flash Player.plugin/Contents/version" CFBundleShortVersionString`
    #else
    #   currentinstalledver="none"
    #fi
    # Compare the two versions, if they are different of Flash is not present then download and install the new version.
    if [ "${currentinstalledver}" != "${latestver}" ]; then
        /bin/echo "`date`: Current Flash version: ${currentinstalledver}" >> ${logfile}
        /bin/echo "`date`: Available Flash version: ${latestver}" >> ${logfile}
        /bin/echo "`date`: Downloading newer version." >> ${logfile}
        /usr/bin/curl -s -o `/usr/bin/dirname $0`/flash.dmg $url
        /bin/echo "`date`: Mounting installer disk image." >> ${logfile}
        /usr/bin/hdiutil attach `dirname $0`/flash.dmg -nobrowse -quiet
        /bin/echo "`date`: Installing..." >> ${logfile}
        /usr/sbin/installer -pkg /Volumes/Flash\ Player/Install\ Adobe\ Flash\ Player.app/Contents/Resources/Adobe\ Flash\ Player.pkg -target / > /dev/null
        /bin/sleep 10
        /bin/echo "`date`: Unmounting installer disk image." >> ${logfile}
        /usr/bin/hdiutil detach $(/bin/df | /usr/bin/grep ${volname} | awk '{print $1}') -quiet
        /bin/sleep 10
        /bin/echo "`date`: Deleting disk image." >> ${logfile}
        /bin/rm `/usr/bin/dirname $0`/${dmgfile}
        newlyinstalledver=`/usr/bin/defaults read "/Library/Internet Plug-Ins/Flash Player.plugin/Contents/version" CFBundleShortVersionString`
        if [ "${latestver}" = "${newlyinstalledver}" ]; then
            /bin/echo "`date`: SUCCESS: Flash has been updated to version ${newlyinstalledver}" >> ${logfile}
        else
            /bin/echo "`date`: ERROR: Flash update unsuccessful, version remains at ${currentinstalledver}." >> ${logfile}
            /bin/echo "--" >> ${logfile}
        fi
    # If Flash is up to date already, just log it and exit.       
    else
        /bin/echo "`date`: Flash is already up to date, running ${currentinstalledver}." >> ${logfile}
        /bin/echo "--" >> ${logfile}
    fi  

