#!/bin/sh -x

#
# User-editable variables
#

# For the jss_server_address variable, put the complete 
# fully qualified domain name address of your Casper server

jss_server_address=$4
jss_host=`echo $jss_server_address | awk -F "/" '{print$1}'`
# For the jss_server_address variable, put the port number 
# of your Casper server. This is usually 8443; change as
# appropriate.

jss_server_port=$5

CheckSiteNetwork (){

  #  CheckSiteNetwork function adapted from Facebook's check_corp function script.
  #  check_corp script available on Facebook's IT-CPE Github repo:
  #
  # check_corp:
  #   This script verifies a system is on the corporate network.
  #   Input: CORP_URL= set this to a hostname on your corp network
  #   Optional ($1) contains a parameter that is used for testing.
  #   Output: Returns a check_corp variable that will return "True" if on 
  #   corp network, "False" otherwise.
  #   If a parameter is passed ($1), the check_corp variable will return it
  #   This is useful for testing scripts where you want to force check_corp
  #   to be either "True" or "False"
  # USAGE: 
  #   check_corp        # No parameter passed
  #   check_corp "True"  # Parameter of "True" is passed and returned
  

  site_network="False"
  ping=`host -W .5 $jss_host`

  # If the ping fails - site_network="False"
  [[ $? -eq 0 ]] && site_network="True"

  # Check if we are using a test
  [[ -n "$1" ]] && site_network="$1"
}

CheckTomcat (){
 
# Verifies that the JSS's Tomcat service is responding via its assigned port.


tomcat_chk=`nc -z -w 5 $jss_host $jss_server_port > /dev/null; echo $?`

if [ "$tomcat_chk" -eq 0 ]; then
       /usr/bin/logger "Machine can connect to $jss_server_address over port $jss_server_port. Proceeding."
else
       /usr/bin/logger "Machine cannot connect to $jss_server_address over port $jss_server_port. Exiting."
       exit 0
fi

}

CheckLogAge (){
 
# Verifies that the /var/log/jamf.log hasn't been written to for at least five minutes.
# This should help ensure that jamf manage can run and not have to wait for a policy to
# finish running.

jamf_log="/var/log/jamf.log"
current_time=`date +%s`
last_modified=`stat -f %m "$jamf_log"`

if [[ $(($current_time-$last_modified)) -gt 300 ]]; then 
     /usr/bin/logger "Log has not been modified in the past five minutes. Proceeding." 
else 
     /usr/bin/logger "Log has been modified in the past five minutes. Exiting."
     exit 0
fi

}

FixMDM (){
 
# Verifies that the Mac can communicate with the Casper server.
# Once communication is verified, it takes the following actions:
#
# 1. Removes the existing MDM certificate if one exists
# 2. Runs jamf manage to fix the certificate
# 3. Runs a recon to send an updated inventory to the JSS to report
#    that the MDM certificate is fixed.
#

jss_comm_chk=`jamf checkJSSConnection > /dev/null; echo $?`

if [[ "$jss_comm_chk" -gt 0 ]]; then
       /usr/bin/logger "Machine cannot connect to the JSS. Exiting."
       exit 0
elif [[ "$jss_comm_chk" -eq 0 ]]; then
       /usr/bin/logger "Machine can connect to the JSS. Fixing MDM"
       jamf removeMdmProfile -verbose
       jamf manage -verbose
       jamf recon
fi
}

SelfDestruct (){
 
# Removes script and associated LaunchDaemon

if [[ -f "/Library/LaunchDaemons/com.company.fixcaspermdm.plist" ]]; then
   /bin/rm "/Library/LaunchDaemons/com.company.fixcaspermdm.plist"
fi
srm $0
}

CheckSiteNetwork

if [[ "$site_network" == "False" ]]; then
    /usr/bin/logger "Unable to verify access to site network. Exiting."
fi 


if [[ "$site_network" == "True" ]]; then
    /usr/bin/logger "Access to site network verified"
    CheckTomcat
    CheckLogAge
    FixMDM
    SelfDestruct
fi
exit 0