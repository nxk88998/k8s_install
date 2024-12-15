#!/bin/bash

PWD=`pwd`
chart_version="v1.2.6"
mkdir -p ${PWD}/tidb-operator 

kubectl create ns tidb-admin
#部署tidb-Operator环境
#kubectl create -f https://raw.githubusercontent.com/pingcap/tidb-operator/master/manifests/crd.yaml

helm repo add pingcap https://charts.pingcap.org/
kubectl create -f ./tidb-operator/crd.yaml
#helm inspect values pingcap/tidb-operator --version=${chart_version} > ${PWD}/tidb-operator/values-tidb-operator.yaml

helm install tidb-operator pingcap/tidb-operator --namespace=tidb-admin --version=${chart_version} -f ${PWD}/tidb-operator/values-tidb-operator.yaml 

kubectl get po -n tidb-admin -l app.kubernetes.io/name=tidb-operator

#部署集群

namespace="tidb-cluster"
cluster_name="tidb-cluster.yaml"

cat $cluster_name | grep -v \# | grep -v ^$
kubectl create namespace ${namespace}
kubectl apply -f ${cluster_name} -n ${namespace}
kubectl apply -f tidb-svc.yaml -n ${namespace}
kubectl apply -f tidb-monitors.yaml -n ${namespace}

#默认root没有密码
echo '
CREATE USER 'sylink'@'%' IDENTIFIED BY 'sylink';
GRANT ALL PRIVILEGES ON *.* TO 'sylink'@'%';
'
