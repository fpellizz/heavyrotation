#!/bin/bash
##########################################################################################
# HeavyRotation
#
# Script che utilizza logrotate di linux per effettuare un rotazione dei log di una webapp
# deployata su un apache tomcat. I file vengono compressi e spostati su un filesystem 
# remoto montato via nfs, quindi trasparente all'utente, ma non a logrotate, che si 
# risente.
# Il nome della cartella di backup viene generata dinamicamente, tramite la lettura
# di alcune proprieta' da un file. 
# 
#
#########################################################################################

function check_system () {
    # verify system requirements 
    if [ -f /usr/sbin/logrotate ]
    then
        echo "logrotate binary ok"
    else
        echo "logrotate is not present on your system. Please install it"
        exit 1
    fi
}


function check_permission (){
    # checkin file permissions
    # is the config file readable?
    if [ -r ./config/config.logrotate ]
    then
        echo "config file OK"
    else
        echo "Cannot read config file. Please verify if the config.logrotate exists inside the config dir, or check permissions"
        exit 1
    fi
    # is the status file writable?
    if [ -w ./config/status.logrotate ]
    then
        echo "status file OK"
    else
        echo "Cannot write status file. Please check persmission"
        exit 1
    fi
}

function get_properties () {
    # read a string key=value and return the value 
    local property_value=$(cat $property_file | grep $1 | cut -d'=' -f 2)
    echo "$property_value"    
}

check_system
check_permission

#################################################################
# What time is it? It's friday? Isn't it?
timestamp=$(date +%Y%m%d-%H-%M-%S)

#################################################################
# Path e Nome del file di properties che verranno usate nella
# generazione del nome della cartella di backup dei logs

property_file_path=./config
property_file_file=build.info
property_file=$property_file_path/$property_file_file


# get properties from the properties file
codename=$(get_properties decisyon.codename)
version=$( get_properties decisyon.version )
metadata_version=$( get_properties decisyon.metadata.version )
short_version=$( get_properties decisyon.short.version )
build_number=$( get_properties build.number )
phase=$( get_properties build.phase )
svnrev=$( get_properties build.svnrev )
timestamp=$( get_properties build.timestamp )

# setting up some path and filename
path_tmp=/tmp
tmp_log_dir="$path_tmp/$build_codename"
logrotate_status_path=/opt/update_aquarius/config
logrotate_status_file=logrotate.status
logrotate_config_path=/opt/update_aquarius/config
logrotate_config_file=fusyon.logrotate
backup_log_home=/mnt/mcbain/logrotate/$build_codename
backup_log_dir=$build_version-$build_number-$timestamp
backup_log_path=$backup_log_home/$backup_log_dir

# doing the real job, maybe...
# creating temp log directory
mkdir -p $tmp_log_dir
# creating a fake file
touch $tmp_log_dir/dummy.log
# creating the remote backup log dir
mkdir -p $backup_log_path
# using logrotate, wow!
logrotate -s $logrotate_status_path/$logrotate_status_file $logrotate_config_path/$logrotate_config_file
# moving rotated file to a "remote" directory
mv $tmp_log_dir/*.* $backup_log_path/
# removing temp stuff
rm -rf $tmp_log_dir
rm -f $backup_log_path/dummy.log
