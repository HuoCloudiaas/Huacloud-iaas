#!/bin/bash 

##############################################################################
#Copyright HuaCloud Inc.
# This program isn't  free software: but you can redistribute it and/or modify
# it when you deploy Huacloud iaas product for 1230 version.
###########################################################################
#
:<<!EOF!
function illustration{

#解决方式及目的描述 
脚本上的检查所有IAAS环境中主机分区使用率是否超过预设值，
使用说明：
1 运行脚本查看环境中所有主机的CPU及SWAP信息，
2 运行脚本需要添加$1为脚本所在主机IP地址
3. 需要在脚本同目录下添加所有主机的IP地址信息，文件名nodeiplist
}
!EOF!

set -e
set	-o xtrace
temp_dir=`mktemp`; rm -rf $temp_dir; mkdir -p $temp_dir
TOPDIR=$(cd $(dirname "$0") && pwd)
cchost=$1

for i in `cat $TOPDIR/nodeiplist` ; do
	ssh root@$i  "ip addr | grep inet | grep brd 
	hostname
	scp root@$cchost:$TOPDIR/cpuinfo /root/
	bash -l -c  /root/cpuinfo  
	hostname "
done
