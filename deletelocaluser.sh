#!/bin/sh
user=`ls -l /dev/console | cut -d " " -f 4`
adminname="admin"
checkadmin=`/usr/bin/dscl . -search /Users name "$adminname" `
if [ -n "$checkadmin" ] && [ "$checkadmin" != "$adminname" ]
then
	dscl . -delete /groups/_appserveradm GroupMembership "$adminname"
	dscl . -delete /groups/_appserverusr GroupMembership "$adminname"
	dscl . -delete /groups/_lpadmin GroupMembership "$adminname"
	dscl . -delete /groups/admin GroupMembership "$adminname"
	dscl . -delete /groups/com.apple.sharepoint.group.1 GroupMembership "$adminname"
	dscl . -delete /groups/staff GroupMembership "$adminname"
	dscl . -delete /users/"$adminname"
	dscl . create /Users/"$adminname" IsHidden 1
	dscl . -delete /Users/"$adminname"
	/bin/echo "`date`: Deleting local admin user..."
else
	/bin/echo "`date`: No "$adminname" user found..."
fi
