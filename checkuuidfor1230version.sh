#!/bin/bash

##############################################################################
#Copyright HuaCloud Inc.
# This program isn't  free software: but you can redistribute it and/or modify
# it when you deploy Huacloud iaas product for 1230 version.
###########################################################################
#
: <<COMMENTBLOCK
脚本解决方式及目的描述 

问题现象及原因： 
    在虚拟机迁移时发现nova computer.log 日志下报错，迁移失败的原因为不能迁移到UUID 相同的主机。
问题解决方案：
     思路1 ， 更改主板的硬件UUID 
     思路2 ，更改libvirt手工设置主机uuid值以区另两台主机。
     思路1涉及硬件厂商 ，虽然复杂，但可从底层完全匹配，并为日后的机房或数据中心硬件运维打好基础，保障监控及资产信息的唯一性。
     思路2 可做为openstack 环境迁移的排除故障的手段使用 ，但建议做好纪录维护工作。
     具体步骤：
     1）检查硬件主板UUID 
       [root@nn1 ~]# dmidecode -s system-uuid 
		03000200-0400-0500-0006-000700080009

		[root@nn1 ~]# virsh sysinfo | grep uuid
    	<entry name='uuid'>03000200-0400-0500-0006-000700080009</entry>

     2) 检查虚拟化libvirt 设置的UUID
		[root@nn1 ~]#  virsh capabilities | grep uuid
    	<uuid>00020003-0004-0005-0006-000700080009</uuid>
     以上在各个节点信息一致，表明各节点使用了相同的UUID ， 需要在每台物理节点变更UUID值（上面不能有正在运行的虚拟机），并重新启动libvirtd 进程以生效 。

		步骤：
	1）  ps 命令确认1230版本libvirtd 配置文件地址（ 因为1230版本libvirt 没有采用centos 默认配置文件路径，首次我未确认，直接更改centos 默认路径的/etc/libvirt/libvirtd.conf 配置文件，发现没有生效。)

		[root@cc ~]# ps -ef | grep libvirtd
		root     11982     1  0 21:59 ?        00:00:00 libvirtd --daemon --config /usr/local/libvirt/etc/libvirt/libvirtd.conf --listen
		root     26979 14427  0 22:07 pts/1    00:00:00 grep libvirtd

	2） 确认配置文件路径libvirtd 使用/usr/local/libvirt/etc/libvirt/libvirtd.conf ，使用如下命令更改配置文件

		sed -i '/^host_uuid/d'  /usr/local/libvirt/etc/libvirt/libvirtd.conf  &&  sed  '/^#host/a\host_uuid = "'`uuidgen`'” '  /usr/local/libvirt/etc/libvirt/libvirtd.conf 

	3） 重启libvirtd 进程以后生效

	    /etc/init.d/libvirtd restart
     
        过程中提示报错，建议可先删除以下提示文件后重新启动进程 

		Starting libvirtd daemon:                                  [  OK  ]
		ln: creating symbolic link `/var/run/libvirt/libvirt-sock-ro': File exists
		ln: creating symbolic link `/var/run/libvirt/libvirt-sock': File exists
		You have new mail in /var/spool/mail/root
	 
	
COMMENTBLOCK

#  下面开始正式脚本文件

set -e    # 开始分析执行情况
set -o xtrace
temp_dir=`mktemp`; rm -rf $temp_dir; mkdir -p $temp_dir    # 创建随机名称的临时文件路径
TOPDIR=$(cd $(dirname "$0") && pwd)                        # 设定相对目录为当前文件夹上级目录 

# 预设三个主机为本次更改uuid 的目标主机 ， 如环境较大，可使用单独的文件来创建host list; 
host1_ip=$1
host2_ip=$2
host3_ip+$3

# 第一步骤检查所有主机节点的uuid 值是否相同, 此脚本默认在1230 版本头节点执行，所以SSH 无密码登陆已经建立，不需要再次设置，此脚本不再说明


for i in $1 $2 $3; do ssh root@$i  
	virsh sysinfo | grep uuid
	virsh capabilities | grep uuid
done 







