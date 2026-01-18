#!/bin/bash

#
# Run kubeadm init phase [phase] one step at a  time to observe
#
# Set PodCIDR in config file
sudo kubeadm init --config files/cluster-config.yaml --pod-network-cidr 172.18.0.0/24
