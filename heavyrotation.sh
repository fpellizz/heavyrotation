#!/bin/bash
#config section

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
        echo "statuttapposto"
    else
        echo "Cannot read config file. Please verify if the config.logrotate exists inside the config dir, or check permissions"
        exit 1
    fi
    
        if [ -w ./config/status.logrotate ]
    then
        echo "statuttapposto"
    else
        echo "Cannot write status file. Please check persmission"
        exit 1
    fi
}

check_system
check_permission

timestamp=$(date +%Y%m%d-%H-%M-%S)
build_info_path=/opt/tomcat8/webapps/aquarius
build_info_file=build.info
build_info=$build_info_path/$build_info_file

build_codename=$(cat $build_info | grep decisyon.codename | cut -d'=' -f 2)
build_version=$(cat $build_info | grep decisyon.version | cut -d'=' -f 2)
build_metadata_version=$(cat $build_info | grep decisyon.metadata.version | cut -d'=' -f 2)
build_short_version=$(cat $build_info | grep decisyon.short.version | cut -d'=' -f 2)
build_number=$(cat $build_info | grep build.number | cut -d'=' -f 2)
build_phase=$(cat $build_info | grep build.phase | cut -d'=' -f 2)
build_revision=$(cat $build_info | grep build.svnrev | cut -d'=' -f 2)
build_timestamp=$(cat $build_info | grep build.timestamp | cut -d'=' -f 2)


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
#logrotate -f -s /tmp/logdummy.state $logrotate_config_path/$logrotate_config_file
mv $tmp_log_dir/*.* $backup_log_path/
rm -rf $tmp_log_dir
rm -f $backup_log_path/dummy.log
