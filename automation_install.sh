#!/bin/bash
pwd=`pwd`
images_version="1.28.2-docker"



#修改需要部署的IP地址
k8s_master01=192.168.233.134
k8s_master02=192.168.233.134
k8s_master03=192.168.233.134
k8s_vip=192.168.233.100  #高可用虚拟地址

#服务器网卡名称
network_name=ens33

#frpc信息
#名字最好不要特殊字符，比如_下划线等·，否则可能会出现报错 (关联tidb数据库名称，frpc名称,pulsar租户名称)
frp_name=testnull
frp_port=30015

rpm -q ansible
if [[ $? = 1 ]];then
echo "ansible未安装，开始默认安装"
yum -y install file/rpm/ansible/*
else
echo "ansible已安装"
fi



#安装k8s
automation_type=y
echo "欢迎使用唱片机安装模式= =!"
if [ $automation_type == y ];then

  read -p "注意：离线模式只支持centos7.9!!!
1,全新安装k8s 3master节点
2,添加node计算节点(必须先执行第一步安装3master!):
" option

#3,安装中间件:
#4,数据初始化:
  if [ $option = 1 ];then

    /bin/cp $pwd/file/hosts_bak  $pwd/file/hosts
    sed -i s\#pwd_list\#"$pwd"\#g $pwd/file/hosts

    sed -i s/k8s_vip/$k8s_vip/g  $pwd/file/hosts
    sed -i s/network_name/$network_name/g $pwd/file/hosts
    sed -i s/k8s_master01/$k8s_master01/g  $pwd/file/hosts
    sed -i s/k8s_master02/$k8s_master02/g  $pwd/file/hosts
    sed -i s/k8s_master03/$k8s_master03/g  $pwd/file/hosts
    sed -i s/frp_sumber_name/$frp_name/g  $pwd/file/hosts
    sed -i s/frp_sumber_port/$frp_port/g  $pwd/file/hosts
    sed -i s/k8s_vip/$k8s_vip/g  $pwd/file/hosts

    /bin/cp $pwd/file/keepalived.conf_bak  $pwd/file/keepalived.conf
    sed -i s/network_name/$network_name/g  $pwd/file/keepalived.conf
    /bin/cp $pwd/file/keepalived.conf_node_bak  $pwd/file/keepalived.conf_node
    sed -i s/network_name/$network_name/g  $pwd/file/keepalived.conf_node

    /bin/cp $pwd/file/kubeadm-init.yaml_bak  $pwd/file/kubeadm-init.yaml
    sed -i s/k8s_master01/$k8s_master01/g  $pwd/file/kubeadm-init.yaml
    sed -i s/k8s_vip/$k8s_vip/g  $pwd/file/kubeadm-init.yaml
    sed -i s/hostname/master$k8s_master01/g  $pwd/file/kubeadm-init.yaml
    /bin/cp $pwd/file/hosts /etc/ansible/hosts
    cat /etc/ssh/sshd_config | grep "UseDNS no" || echo "UseDNS no" >>  /etc/ssh/sshd_config
    systemctl restart sshd

    for i in `cat $pwd/file/hosts |  grep -Po "\d+\.\d+\.\d+\.\d+" | grep -v $k8s_vip | sort | uniq`
    do
    echo "输入$i 服务器密码"
    ssh-copy-id root@$i
    done

    echo "开始安装k8s"
    echo "ssh $k8s_master01 hostnamectl set-hostname master$k8s_master01"
    ssh $k8s_master01 "hostnamectl set-hostname master$k8s_master01"
    ssh $k8s_master01 "echo master$k8s_master01 > /etc/hostname"
    cat /etc/hosts | grep k8s_master01 || echo "$k8s_master01 k8s_master01" >> /etc/hosts
    ansible-playbook $pwd/ansible_master.yaml

      scp -r $k8s_master01:/etc/hosts /tmp/hosts
      scp -r $k8s_master01:/tmp/token /tmp/token 
      scp -r $k8s_master01:/tmp/token_node /tmp/token_node
      scp -r $k8s_master01:/etc/kubernetes/pki/ /tmp
      scp -r $k8s_master01:/etc/kubernetes/admin.conf /tmp
    #比较坑，必须指定证书复制而不能整个目录
    for i in $k8s_master02 $k8s_master03
    do
      scp -r /tmp/hosts $i:/etc/hosts 
      ssh $i "hostnamectl set-hostname master$i"
      ssh $i "echo master$i > /etc/hostname "
      ssh $i "mkdir -p /etc/kubernetes/pki/etcd; mkdir -p ~/.kube/"
      scp /tmp/pki/ca.crt $i:/etc/kubernetes/pki/ca.crt
      scp /tmp/pki/ca.key $i:/etc/kubernetes/pki/ca.key
      scp /tmp/pki/sa.key $i:/etc/kubernetes/pki/sa.key
      scp /tmp/pki/sa.pub $i:/etc/kubernetes/pki/sa.pub
      scp /tmp/pki/front-proxy-ca.crt $i:/etc/kubernetes/pki/front-proxy-ca.crt
      scp /tmp/pki/front-proxy-ca.key $i:/etc/kubernetes/pki/front-proxy-ca.key
      scp /tmp/pki/etcd/ca.crt $i:/etc/kubernetes/pki/etcd/ca.crt
      scp /tmp/pki/etcd/ca.key $i:/etc/kubernetes/pki/etcd/ca.key
      scp /tmp/admin.conf $i:/etc/kubernetes/admin.conf
      scp /tmp/admin.conf $i:~/.kube/config
    done

    ansible-playbook $pwd/ansible_master_node.yaml

    echo "确认内核版本，cilium组件网络组件需要4.8以上内核，如已更新请手动重启系统
          检查当前版本命令 awk -F \' '\$1==\"menuentry \" {print i++ \"  \" \$2}' /etc/grub2.cfg
          配置默认版本 grub2-set-default 序号"
    echo "#删除master污点标签，使其作为计算节点
          #示例命令 kubectl taint node master-192.168.1.171 node-role.kubernetes.io/master-"
    echo "硬盘IO测试，正常大约6秒左右创建完成文件
          time dd if=/dev/zero of=test.dbf bs=3M count=1000 oflag=direct"

    read -p  "是否重启master:
    内核大于4.8以上不需要重启
    请输入:(y/n)"  reboot
    
    if [[ $reboot == y  ]];then
      for i in $k8s_master03 $k8s_master02 $k8s_master01
      do
      ssh $i reboot
      done
    else
      echo "取消重启"
    fi
    
  ####添加NODE节点
  elif [ $option == 2 ];then
    read -p "输入集群VIP IP地址:" k8s_vip
    read -p "输入添加节点数量:" number
    echo "[k8s_node] " > /etc/ansible/hosts
    COUNTER=0
    while [ $COUNTER -lt $number ]
    do
        let COUNTER+=1
        read -p "请输入第$COUNTER个nodeIP:" node_number
        echo "$node_number vip=$k8s_vip  pwd=$pwd" >> /etc/ansible/hosts
        ssh-copy-id root@$node_number
        ssh $node_number  "hostnamectl set-hostname node$node_number"
        ssh $node_number  "echo node$node_number > /etc/hostname "
    done
    ansible-playbook $pwd/ansible_node.yaml

    echo "[k8s_tools]
    $k8s_vip " >> /etc/ansible/hosts
    

    echo "#删除master污点标签，使其作为计算节点
          #示例命令 kubectl taint node master-192.168.1.171 node-role.kubernetes.io/master-
          token过期添加节点，重新生成命令
          kubeadm token create --print-join-command
          加入master节点添加参数
          --control-plane "
  #elif [ $option == 3 ];then
  #/bin/cp $pwd/file/hosts /etc/ansible/hosts
  #ansible-playbook $pwd/tools.yaml

  elif [ $option == test ];then
    echo "初始化重置tidb账号密码"
    mysql -h $k8s_vip -P 4000 -u root -p -e "create database nacos_config; create database $frp_name;create database xxl_job; CREATE USER 'sylink'@'%' IDENTIFIED BY 'sylink'; GRANT ALL PRIVILEGES ON *.* TO 'sylink'@'%';USE mysql;set password for 'root'@'%' = 'sylink';FLUSH PRIVILEGES;"
    #mysql -h $k8s_vip -P 4000 -u sylink -psylink $frp_name  < $pwd/sql/tidb_init.sql #比对预留

    echo "#nacos初始化数据"
    mysql -h $k8s_vip -P 4000 -u sylink -psylink nacos_config < $pwd/sql/nacos-mysql.sql
    
    echo "初始化starrocks"
    starrocks_be=`kubectl get pod -n starrocks -o wide | grep starrocks-be | awk '{print $6}' | tail -n 1`
    for i in `kubectl get pod -n starrocks -o wide | grep starrocks-be | awk '{print $6}'`
    do
      mysql -h $starrocks_be -P 9030 -u root -e "alter system add backend $i:9050 ;"
    done

    starrocks_fe=`kubectl get pod -n starrocks -o wide | grep starrocks-fe | awk '{print $6}' | tail -n 1`
    for i in `kubectl get pod -n starrocks -o wide | grep starrocks-fe | awk '{print $6}'`
    do
      mysql -h $starrocks_be -P 9030 -u root -e "alter system add follower $i:9010 ;"
    done

    mysql -h $starrocks_be -P 9030 -u root < $pwd/sql/starrocks.sql
    
    echo "pulsar租户添加"
    kubectl cp -n pulsar $pwd/file/_init_tenant_namespace.sh pulsar-toolset-0:/tmp/
    kubectl exec -it pulsar-toolset-0 -n pulsar   bash /tmp/_init_tenant_namespace.sh $frp_name

    echo "xxl_job数据初始化"
    mysql -h $k8s_vip -P 4000 -u sylink -psylink xxl_job  < $pwd/sql/xxl_job_init.sql
  else
    echo "未选择安装退出"

  fi
##########################################################################################################
#elif [ $automation_type == 5 ];then
#echo "待开发预留"
#rancher 安装docker run -d --restart=unless-stopped   -p 80:80 -p 443:8443   --privileged   rancher/rancher:v2.5.8
#开放k8s端口范围- --service-node-port-range=1-65535

fi
