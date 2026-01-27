#!/bin/bash

OPT_SPEC="dc:hv"

DEBUG_DEFAULT=""
VERBOSE_DEFAULT=""
HELP_DEFAULT=""

CONFIG_FILE_DEFAULT="./files/cluster-config.yaml"

function main() {
    echo "--- Start ---"

    parse_args $*

    # Check if it's already installed
    install_controller ${CONFIG_FILE}

    # Check if Calicois installed
#    install_calico "./files/
    
    echo "--- End ---"
}

function parse_args() {

    while getopts ${OPT_SPEC} opt $* ; do
	case $opt in
	    d)
		DEBUG="true"
		;;

	    c)
		CONFIG_FILE=${OPTARG}
		;;

	    h)
		HELP="true"
		;;

	    v)
		VERBOSE="true"
		;;
	esac
    done

    : DEBUG=${DEBUG:=${DEBUG_DEFAULT}}
    : CONFIG_FILE=${CONFIG_FILE:=${CONFIG_FILE_DEFAULT}}
}

# ===============================================================
# 
# ===============================================================
function install_controller() {
    local cluster_file=$1
    sudo kubeadm init --config ${cluster_file}

    mkdir -p ~/.kube
    #
    sudo cat /etc/kubernetes/admin.conf | tee >/dev/null ~/.kube/config
}

function install_calico() {
    local calico_spec_file=$1
    
    helm repo add projectcalico https://docs.tigera.io/calico/charts

    kubectl create namespace tigera-operator

    helm install calico projectcalico/tigera-operator --version v3.31.3 --namespace tigera-operator

    sudo curl -L https://github.com/projectcalico/calico/releases/download/v3.31.3/calicoctl-linux-amd64 -o /usr/local/bin/calicoctl

    sudo curl -L https://github.com/projectcalico/calico/releases/download/v3.31.3/calicoctl-linux-arm64 -o /usr/local/bin/calicoctl
    sudo chmod 0755 /usr/local/bin/calicoctl

    sudo curl -L https://github.com/projectcalico/calico/releases/download/v3.31.3/calicoctl-linux-arm64 -o /usr/local/bin/kubectl-calico
    sudo chmod 0755 /usr/local/bin/kubectl-calico
}

# ===================================================================
# Status check functions
# ===================================================================
#- Controller Files -
KUBE_CONTROL_FILES=(
    /etc/kubernetes/admin.conf
    /etc/kubernetes/super-admin.conf
    /etc/kubernetes/kubelet.conf
    /etc/kubernetes/bootstrap-kubelet.conf
    /etc/kubernetes/controller-manager.conf
    /etc/kubernetes/scheduler.conf
    )
#- 
function controller_installed() {
    # Are the /etc files for kubernetes, etcd installed?
    # Are the kubelet and etcd services running?
    echo "test if controller is installed"
}


# mkdir ~/.kube
# sudo cat /etc/kubernetes/admin.conf | tee >/dev/null ~/.kube/config

# kubectl create ns kube-flannel
# kubectl label --overwrite ns kube-flannel pod-security.kubernetes.io/enforce=privileged

# helm repo add flannel https://flannel-io.github.io/flannel/

# helm install flannel --set podCidr="172.18.0.0/16" --namespace kube-flannel flannel/flannel

# head_init.sh:

# sudo apt update
# sudo apt -y upgrade 
# sudo apt -y install git tmux ansible

# sudo kubeadm init --config files/cluster-config.yaml --pod-network-cidr 172.18.0.0/24

# kubeadm token create --print-join-command
# kubeadm join 172.17.0.2:6443 --token xxxx --discovery-token-ca-cert-hash sha256:xxxxx


# kubectl get namespace "kube-flannel" -o json \
#   | tr -d "\n" | sed "s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/" \
#   | kubectl replace --raw /api/v1/namespaces/kube-flannel/finalize -f -

main $*
