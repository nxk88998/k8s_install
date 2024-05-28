集群部署方式：

集群环境要求 centos7.9 部署机已经安装了ansible组件(未安装则自动离线安装),内核版本高于4.8以上（未达到脚本会自动安装，但需要重启）

1,配置安装信息,修改automation_install.sh脚本内部masterIP地址
#修改需要部署的IP地址
k8s_master01=192.168.233.11
k8s_master02=192.168.233.12
k8s_master03=192.168.233.13

#高可用虚拟地址
k8s_vip=192.168.233.10

#服务器网卡名称
network_name=ens33

如需单master安装清注释automation_install.sh文件中
该行#ansible-playbook $pwd/ansible_master_node.yaml

2,安装noden节点
bash 执行automation_install.sh  即可选择2

3,如果服务器无法上网，可将镜像文件放置
k8s_images目录中，会统一分发安装

安装信息
k8s版本 1.28.2
cilium 1.15.4
kernel-ml 5.16.8-1
cri-dockerd 0.3.14
docker-ce 20.10.12
containerd.io 1.6.31-3
ansible 2.9.27


自带cilium网络组件镜像导入如需要安装请执行命令
cilium install --version 1.15.4
如果你是纯内网环境安装cilium执行完上述命令后修改daemonset和deployment image镜像地址,去除 SHA256 摘要即可。
kubectl edit deployment cilium-operator -n kube-system
kubectl edit daemonset  cilium -n kube-system

本代码未添加离线包，完整测试包下载地址
http://47.97.202.142/k8s-install-1.28.2-centos7.tar.gz

