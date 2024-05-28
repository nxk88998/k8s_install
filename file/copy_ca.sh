#!/bin/bash
mkdir /root/.kube/
cp /etc/kubernetes/admin.conf /root/.kube/config

token=`kubeadm token list | tail -n 1 | awk '{print $1}'`
ssl=`openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'`
vip=`cat /etc/keepalived/keepalived.conf | grep -Po "\d+\.\d+\.\d+\.\d+"`
echo "kubeadm join --token $token --discovery-token-ca-cert-hash sha256:$ssl  $vip:6443 --control-plane --cri-socket unix:///var/run/cri-dockerd.sock " > /tmp/token
echo "kubeadm join --token $token --discovery-token-ca-cert-hash sha256:$ssl  $vip:6443 --cri-socket unix:///var/run/cri-dockerd.sock  " > /tmp/token_node
