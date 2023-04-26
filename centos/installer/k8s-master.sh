#!/bin/bash

# 基于node继续安装
source centos/installer/k8s-init.sh
hostnamectl set-hostname master

kubeadm init \
  --apiserver-advertise-address="${local_ip}" \
  --image-repository registry.aliyuncs.com/google_containers \
  --pod-network-cidr=10.244.0.0/16

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://dvkunion.oss-cn-shanghai.aliyuncs.com/flannel-cni.yaml
crictl config runtime-endpoint unix:///var/run/containerd/containerd.sock
