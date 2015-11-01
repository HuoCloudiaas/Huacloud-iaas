 #!/bin/bash 

##############################################################################
#Copyright HuaCloud Inc.
# This program isn't  free software: but you can redistribute it and/or modify
# it when you deploy Huacloud iaas product for 1230 version.
###########################################################################
#
:<<!EOF!
function illustration{

#问题原因，解决方式及目的描述 
此脚本为简单的备份脚本， 为方便日常运维及相关需求 。
脚本以备份 "/etc /home /root /var/spool/mail " 为目的，将任务放置在crontab 中按照设置的
循环时间周期执行。
!EOF!
#######################脚本环境声明#####################################################

set –x    #任何参数都会显示
set -e    # 执行结果不是true则应该退出。
#set -o verbose #打印读入shell的输入行。
set -o xtrace  #执行命令之前打印命令
temp_dir=`mktemp`; rm -rf $temp_dir; mkdir -p $temp_dir    # 创建随机名称的临时文件路径
TOPDIR=$(cd $(dirname "$0") && pwd)                        # 设定相对目录为当前文件夹上级目录 

####################################正式脚本 ###############################################
 backdir="/etc /home /root /var/spool/mail"
 basedir=/backup
 [ ! -d "$basedir" ] && mkdir $basedir
 backfile=$basedir/backup.tar.gz
 tar -zcvf $backfile $backdir

 [root@localhost ~]# vim /etc/crontab
 45 2 * * * root sh /root/bin/backup.sh