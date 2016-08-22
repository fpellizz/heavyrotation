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
    #verify system requirements 
    if [ -f /usr/sbin/logrotate ]
    then
        echo "logrotate binary ok"
    else
        echo "logrotate is not present on your system. Please install it"
        exit 1
    fi
}


function check_permission (){
    if [ -r ./config/config.logrotate ]
    then
        echo "config file OK"
    else
        echo "Cannot read config file. Please verify if the config.logrotate exists inside the config dir, or check permissions"
        exit 1
    fi
    
        if [ -w ./config/status.logrotate ]
    then
        echo "status file OK"
    else
        echo "Cannot write status file. Please check persmission"
        exit 1
    fi
}

check_system
check_permission

timestamp=$(date +%Y%m%d-%H-%M-%S)
#
#################################################################
# Path e Nome del file di properties che verranno usate nella
# generazione del nome della cartella di backup dei logs
#
#property_file_path=/opt/tomcat8/webapps/aquarius
property_file_path=.
property_file_file=build.info
property_file=$property_file_path/$property_file_file
#
#build_codename=$(cat $property_file | grep decisyon.codename | cut -d'=' -f 2)
#build_version=$(cat $property_file | grep decisyon.version | cut -d'=' -f 2)
#build_metadata_version=$(cat $property_file | grep decisyon.metadata.version | cut -d'=' -f 2)
#build_short_version=$(cat $property_file | grep decisyon.short.version | cut -d'=' -f 2)
#build_number=$(cat $property_file | grep build.number | cut -d'=' -f 2)
#build_phase=$(cat $property_file | grep build.phase | cut -d'=' -f 2)
#build_revision=$(cat $property_file | grep build.svnrev | cut -d'=' -f 2)
#build_timestamp=$(cat $property_file | grep build.timestamp | cut -d'=' -f 2)
#
function get_properties () {
    local property_value=$(cat $property_file | grep $1 | cut -d'=' -f 2)
    echo "$property_value"    
}
#
codename=$(get_properties decisyon.codename)
version=$( get_properties decisyon.version )
metadata_version=$( get_properties decisyon.metadata.version )
short_version=$( get_properties decisyon.short.version )
build_number=$( get_properties build.number )
phase=$( get_properties build.phase )
svnrev=$( get_properties build.svnrev )
timestamp=$( get_properties build.timestamp )
#
#echo $property_file
#echo $codename
#echo $version
#echo $metadata_version
#echo $short_version
#echo $build_number 
#echo $phase
#echo $svnrev
#echo $timestamp
#
path_tmp=/tmp
tmp_log_dir="$path_tmp/$build_codename"
logrotate_status_path=/opt/update_aquarius/config
logrotate_status_file=logrotate.status
logrotate_config_path=/opt/update_aquarius/config
logrotate_config_file=fusyon.logrotate

backup_log_home=/mnt/mcbain/logrotate/$build_codename
backup_log_dir=$build_version-$build_number-$timestamp
backup_log_path=$backup_log_home/$backup_log_dir

echo $tmp_log_dir
echo $backup_log_path

mkdir -p $tmp_log_dir
touch $tmp_log_dir/dummy.log
mkdir -p $backup_log_path
logrotate -s $logrotate_status_path/$logrotate_status_file $logrotate_config_path/$logrotate_config_file
mv $tmp_log_dir/*.* $backup_log_path/
rm -rf $tmp_log_dir
rm -f $backup_log_path/dummy.log
