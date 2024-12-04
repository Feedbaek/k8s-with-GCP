#!/bin/bash

# swap 임시 비활성화
sudo swapoff -a

# swap 영구 비활성화
sudo sed -i '/swap/s/^/#/' /etc/fstab

# 방화벽 비활성화
sudo apt-get install -y firewalld
sudo systemctl stop firewalld
sudo systemctl disable firewalld

#/etc/modules-load.d/k8s.conf 파일 생성
sudo cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

#/etc/sysctl.d/k8s.conf 파일 생성
sudo cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables=1
net.bridge.bridge-nf-call-iptables=1
EOF

#시스템 재시작 없이 stysctl 파라미터 반영
sudo sysctl --system



#apt 업데이트
sudo apt-get update

#필수 패키지 설치
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg

#공개키 다운로드
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# 저장소 등록
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 저장소 적용을 위한 apt 업데이트
sudo apt-get update

# containerd 패키지 설치
sudo apt-get install -y containerd

# containerd 구성 파일 생성
sudo mkdir -p /etc/containerd

# containerd 기본 설정값으로 config.toml 생성
sudo containerd config default | sudo tee /etc/containerd/config.toml

# config.toml 파일 수정
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

# 수정사항 적용 및 재실행
sudo systemctl restart containerd



# apt 패키지 색인을 업데이트하고, 쿠버네티스 apt 리포지터리를 사용하는 데 필요한 패키지를 설치한다.
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

# 구글 클라우드의 공개 사이닝 키를 다운로드 한다.
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# 쿠버네티스 apt 리포지터리를 추가한다.
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# apt 패키지 색인을 업데이트하고, kubelet, kubeadm, kubectl을 설치하고 해당 버전을 고정한다.
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl


# init 전에 네트워크 모듈 로드
sudo modprobe br_netfilter
sudo tee -a /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.ipv4.ip_forward=1
EOF
sudo sysctl --system
