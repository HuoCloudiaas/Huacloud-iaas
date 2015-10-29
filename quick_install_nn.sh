#!/bin/bash

# 部署操作、模块、角色的定义
opt[0]='deploy';    product[0]='cml-a';       role[0]='cml-a';
opt[1]='deploy';    product[1]='neutron';     role[1]='nn';
opt[2]='deploy';    product[2]='nova';        role[2]='nn';
opt[3]='deploy';    product[3]='ceilometer';  role[3]='nn';

#### main ####
if [ $# -ne 1 ];then
    echo "请输入唯一参数：部署目标的IP地址（管理网段）。"
    exit 100
fi
# 部署IP地址
deployIP=$1

# 日志输出
mkdir -p /opt/autodeploy/product_deploy/log
logFile=/opt/autodeploy/product_deploy/log/deploy_products_${deployIP}.log

# 阶段标志输出
mkdir -p /opt/stage_flag
flagFile=/opt/stage_flag/quick_deploy_products_nn_${deployIP}.flag

# 检查标识
startIndex=0
if [ -e $flagFile ];then
    tmpFlag=`cat $flagFile`
    [ -n $tmpFlag ] && startIndex=$tmpFlag
fi

# 判断是否为测试
isTest=0
cat ./global_config | grep "IS_TEST.*rue"
[ $? -eq 0 ] && isTest=1

# 更新各个节点的主机名(/etc/hosts)
[ $isTest -eq 0  ] && ./updateHostnames.py

warningFlag=0
length=${#opt[@]}
for (( i=startIndex; i<length; i++ )) ; do
    opt=${opt[$i]}
    product=${product[$i]}
    role=${role[$i]}

    # 在产品的部署和安装前，先检查服务是否正常。正常情况下，将跳过该产品的部署和安装。
    if [ $isTest -eq 0 ];then
        if [ $opt == "deploy" -o $opt == "install" ];then
            ./Run.py health_quick_check $product $deployIP $role > /dev/null 2>&1
            rtv=$?
            if [ $rtv -eq 200 ];then
                # 返回值为200时，为用户强制中断，因此退出。
                exit 200
            elif [ $rtv -eq 0 ];then
                (( count=i+1  ))
                echo "$count" > $flagFile
                continue
            fi
        fi
    fi

    ./Run.py $opt $product $deployIP $role
    rtv=$?
    if [ $rtv -eq 200 ];then
        # 返回值为200时，为用户强制中断，因此退出。
        exit 200
    elif [ $rtv -ge 100 ];then
        echo ""
        echo "${product} 部署失败，快速部署中断，请手动修复后，重新运行快速安装脚本。"
        exit 100
    elif [ $rtv -gt 0 ];then
        warningFlag=1
    fi

 
    # 写入标识
    (( count=i+1  ))
    [ $isTest -eq 0  ] && echo "$count" > $flagFile
done

echo ""
echo ""
echo "###############################################"
echo "#                     END                     #"
echo "###############################################"
if [ $warningFlag -eq 0 ];then
    echo "计算节点部署成功!!!"
else
    echo "计算节点部署完毕，但有异常输出，请检查日志："
    echo "  $logFile"
fi

