#!/bin/bash

# jss.authusr.sh
# ©2016 brock walters jamf

# this script works under the following assumptions:
#   1) the user account assigned to UID 501 is created programmtically during provisioning or by IT staff
#   2) user accounts created by an end user in the GUI or by Server.app other than UID 501 are unauthorized
#   3) end users do not know how or do not have privileges to change the UID for their user account

# this script can be used in 1 of the following 3 ways:
#   - adding a comma-separated or space-separarted list to the parameter 4 field when using the script as the
#     payload in a JSS policy
#   - passing a comma-separated or space-separarted list as argument 4 of the command to run the script
#   - hard-coding a comma-separated or space-separarted list into the "AuthorizedUserAccounts" variable below
#     eg, AuthorizedUsers="_secretITaccount,mattdaemon,unclenobody" etc...

AuthorizedUserAccounts="ladmin"

#########################################
########## DO NOT MODIFY BELOW ##########
#########################################

AuthorizedUserAccounts="${AuthorizedUserAccounts:-$4}"
addauth=($(echo "$AuthorizedUserAccounts" | /usr/bin/sed 's/,/ /g'))
sysauth=(daemon Guest nobody root _amavisd _appleevents _appowner _appserver _ard _assetcache _astris _atsserver _avbdeviced _calendar _ces _clamav _coreaudiod _coremediaiod _cvmsroot _cvs _cyrus _devdocs _devicemgr _displaypolicyd _distnote _dovecot _dovenull _dpaudio _eppc _ftp _geod _iconservices _installassistant _installer _jabber _kadmin_admin _kadmin_changepw _krb_anonymous _krb_changepw _krb_kadmin _krb_kerberos _krb_krbtgt _krbfast _krbtgt _launchservicesd _lda _locationd _lp _mailman _mcxalr _mdnsresponder _mysql _netbios _netstatistics _networkd _nsurlsessiond _nsurlstoraged _postfix _postgres _qtss _sandbox _screensaver _scsd _securityagent _serialnumberd _softwareupdate _spotlight _sshd _svn _taskgated _teamsserver _timezone _tokend _trustevaluationagent _unknown _update_sharing _usbmuxd _uucp _warmd _webauthserver _windowserver _www _applepay _mbsetupuser _captiveagent _ctkd _datadetectors _findmydevice _gamecontrollerd _hidd _mobileasset _ondemand _wwwproxy _xcsbuildagent _xcscredserver _xserverdocs )
usercat=("${addauth[@]}" "${sysauth[@]}")
echo "${usercat[@]}" | /usr/bin/base64 > /private/tmp/authusr.b64

authusr=($(/usr/bin/base64 -D -i /private/tmp/authusr.b64))
usrxmpt=$(for i in "${authusr[@]}";do /bin/echo -n "/^$i$/d;";done)
userlst=($(/usr/bin/dscl . -list /Users | /usr/bin/sed "$usrxmpt")) 
useruid=($(for j in "${userlst[@]}";do /usr/bin/id -u "$j";done))

# conditional check for unauthorized users

UnauthorizedUserAccounts=($(echo "${useruid[@]//501/}"))
if [[ -z ${UnauthorizedUserAccounts[@]} ]]
then
    echo "<result>No Unauthorized User Accounts</result>"
else
    echo "<result>${UnauthorizedUserAccounts[@]}</result>"
fi
/bin/rm -f /private/tmp/authusr.b64