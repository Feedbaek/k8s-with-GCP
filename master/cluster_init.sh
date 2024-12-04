########### 이거는 마스터 노드만 설정 ###########

# Calico 설정 적용해서 init
sudo kubeadm init --pod-network-cidr=192.168.0.0/16


# root 계정이 아닌 다른 계정에서도 kubectl 명령어를 사용하기 위해 config 설정
sudo mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


# Calico CNI 설치
sudo kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.0/manifests/tigera-operator.yaml
sudo kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.0/manifests/custom-resources.yaml


################################################
