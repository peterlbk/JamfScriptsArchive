#!/bin/sh -x
logfile="/Library/Logs/jss.log"
user=`ls -l /dev/console | cut -d " " -f 4`

sudo -u $user /usr/local/bin/SophosUpdate