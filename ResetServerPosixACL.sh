#!/bin/bash
######################################################################
#                                                                    #
# Usage: sudo ./ResetServerFolders.sh /path/to/SHAREPOINTS           #
#                                                                    #
###################################################################### 



# Check if path is added
if [[ "$1" != "" ]]; then
    DIR="$1"
else
    echo "NO PATH SET, THE SCRIPT EXITS NOW..." 1>&2
    exit 1
fi
echo "\n"

# Start fixing
echo "Adjusting locked files..."
chflags -R nouchg $DIR 2>&1
if [[ $? -ne 0 ]]
then
    echo "ERROR ADJUSTING LOCKED FILES. SCRIPT EXITS NOW."
    exit 1
fi
echo "Fixing Extended Attributes..."
xattr -r -c $DIR 2>&1
if [[ $? -ne 0 ]]
then
    echo "ERROR FIXING EXTENDED ATTRIBUTES. SCRIPT EXITS NOW."
    exit 1
fi
echo "Removing ACLs..."
chmod -RN $DIR 2>&1
if [[ $? -ne 0 ]]
then
    echo "ERROR REMOVING ACLS. SCRIPT EXITS NOW"
    exit 1
fi

# Check os en fix POSIX
SYS=$(osascript -e "system attribute \"sys2\"")
if [[ "$SYS" == "9" ]]; then
	echo "Setting POSIX owners on Mavericks system..."
	chown -R admin:admin $DIR 2>&1
		if [[ $? -ne 0 ]]
			then
    		echo "ERROR SETTING POSIX OWNERS IN MAVERICKS. SCRIPT EXITS NOW."
    		exit 1
		fi
else 
	echo "Setting POSIX owners on pre-Mavericks system..."
	chown -R admin:staff $DIR 2>&1
		if [[ $? -ne 0 ]]
			then
    		echo "ERROR SETTING POSIX OWNERS IN PRE-MAVERICKS. SCRIPT EXITS NOW."
    		exit 1
		fi
fi
echo "Setting POSIX rights on all shares..."
chmod -R 770 $DIR 2>&1
if [[ $? -ne 0 ]]
then
    echo "ERROR SETTING POSIX ON ALL SHARES. SCRIPT EXITS NOW."
    exit 1
fi

echo "Setting POSIX rights on Shares root folder..."
chmod 777 $DIR 2>&1
if [[ $? -ne 0 ]]
then
    echo "ERROR SETTING POSIX ROOT FOLDER. SCRIPT EXITS NOW."
    exit 1
fi
echo "Ready! All files cleaned..."; exit
