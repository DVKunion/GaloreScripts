#!/bin/bash
# k8s环境初始化脚本

source common/system/local_ip.sh
id=$RANDOM
hostnamectl set-hostname "node-${id}"
# 关闭防火墙
systemctl disable firewalld
systemctl stop firewalld
# 关闭selinux
# 临时禁用selinux
setenforce 0
# 永久关闭 修改/etc/sysconfig/selinux文件设置
sed -i 's/SELINUX=permissive/SELINUX=disabled/' /etc/sysconfig/selinux
sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
# 禁用交换分区
swapoff -a
# 永久禁用，打开/etc/fstab注释掉swap那一行。
sed -i 's/.*swap.*/#&/' /etc/fstab
# 启用必要模块
modprobe overlay
modprobe br_netfilter
echo 1 >/proc/sys/net/bridge/bridge-nf-call-iptables
echo 1 >/proc/sys/net/ipv4/ip_forward
# 修改内核参数
cat <<EOF >/etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

cat <<EOF | tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

cat <<EOF | tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sysctl --system
# 添加k8s仓库
cat <<EOF >/etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

# 安装
dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
dnf update -y
dnf install -y containerd kubelet kubeadm kubectl

mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml

sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
sed -i 's/registry.k8s.io\/pause:3.6/registry.aliyuncs.com\/google_containers\/pause:3.9/g' /etc/containerd/config.toml

systemctl restart containerd
systemctl enable containerd kubelet
