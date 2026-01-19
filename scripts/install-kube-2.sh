#!/bin/bash

sudo kubeadm init --config llamanet/kube/files/cluster-config.yaml

mkdir ~/.kube
sudo cat /etc/kubernetes/admin.conf | tee >/dev/null ~/.kube/config

kubectl create ns kube-flannel
kubectl label --overwrite ns kube-flannel pod-security.kubernetes.io/enforce=privileged

helm repo add flannel https://flannel-io.github.io/flannel/

helm install flannel --set podCidr="172.18.0.0/16" --namespace kube-flannel flannel/flannel

head_init.sh:

sudo apt update
sudo apt -y upgrade 
sudo apt -y install git tmux ansible

sudo kubeadm init --config files/cluster-config.yaml --pod-network-cidr 172.18.0.0/24

kubeadm token create --print-join-command
kubeadm join 172.17.0.2:6443 --token xxxx --discovery-token-ca-cert-hash sha256:xxxxx


kubectl get namespace "kube-flannel" -o json \
  | tr -d "\n" | sed "s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/" \
  | kubectl replace --raw /api/v1/namespaces/kube-flannel/finalize -f -
