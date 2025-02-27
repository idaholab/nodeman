# Copyright 2025, Battelle Energy Alliance, LLC
#
# Author:
# Scott Serr
# scott.serr@inl.gov
#
# Description:
# This is the the file to source to add nodeman commands to your bash shell.
# Before modifying this file for your needs, consider if the modification
# can be part of the site / cluster config file.
#


# standard soultion to find if script has been sourced
(return 0 2>/dev/null) && sourced=1 || sourced=0

# if it's not sourced we need to bail
#echo "sourced = $sourced"
if [[ $sourced == 0 ]]; then
    echo "To use this tool you must source it to add the functions to your bash shell"
    exit
fi

# Up the maximum limit of open file descriptors
ulimit -n 16384

NM_SCRIPT=$(realpath "${BASH_SOURCE[0]}")

NM_HOME=$(dirname "$NM_SCRIPT")
echo "NM_HOME=$NM_HOME"

# Set some locations for files - these can be customized in the site_config / cluster files
export NM_DATA=$NM_HOME/data
export NM_LOG=$NM_DATA/logs/nm.log
export NM_NODES_DIR=$NM_DATA/logs/nodes

# Source core components - site config may depend on some of these functions
source $NM_HOME/nodeman_func.bash
source $NM_HOME/nodeman_list.bash
source $NM_HOME/nodeman_util.bash


NM_SITE_CONFIG_FILE=$(egrep -l ".*CLUSTER_HOSTNAMES.*=$HOSTNAME" $NM_HOME/site_config/* | head -n 1)

if [ -f $NM_SITE_CONFIG_FILE ]; then

    echo "NM_SITE_CONFIG_FILE=$NM_SITE_CONFIG_FILE"
    source $NM_SITE_CONFIG_FILE

    # A reminder that you need IPMI user and password configured for many features to work
    if [ -z $NM_IPMI_USER ]  || [ -z $NM_IPMI_PASS ]; then
	echo "WARNING:"
	echo "IPMI username and password must be configured for many fatures to work."
	echo "Check your site / cluster configuration"
    fi
    
    # Let's hide the password from spilling on the screen if we can by using the -E switch on ipmitool
    export IPMI_PASSWORD="$NM_IPMI_PASS"
    export NM_IPMI="ipmitool -I lanplus -U $NM_IPMI_USER -E"
    
else

    echo "ERROR:"
    echo "A cluster configuration file in $NM_HOME/site_config/"
    echo "containing #CLUSTER_HOSTNAME=$HOSTNAME was not found."

fi


