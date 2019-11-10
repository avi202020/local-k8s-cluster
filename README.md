# Introduction
- Local 3-node k8s cluster provisioned by Vagrant and Ansible.

# Setup kubernetes cluster from scratch
- Start 3 vms: `cd` to `vagrant-3-dns-ubuntu1804` and run `./start.sh` to create 3 vms. The 3 vms have their DNS set up and can access the Internet and can be accessed from host machine

Suppose the IP address are given below,we will use these IPs as examples:

|Node|Ip|Host|
| --- | --- | --- |
|master|172.28.128.228|vagrant-3-dns-ubuntu1804-1.vagrant.local|
|worker1|172.28.128.229|vagrant-3-dns-ubuntu1804-2.vagrant.local|
|worker2|172.28.128.230|vagrant-3-dns-ubuntu1804-3.vagrant.local|

- Provision: `cd` to project root folder and run `./provision.sh all[or master/worker1/worker2]` to provision vm(s), the provision mainly installs docker
- Install k8s master: `./install-k8s-master.sh`
- Install k8s workers: `./install-k8s-worker.sh workers[or worker1/worker2]`
- Reconfigure kubelet:

Login each nodes and modify kubelet config to use the above IPs for each node:

```
sudo vi /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
```
add:

```
Environment="KUBELET_EXTRA_ARGS=--node-ip=[ip from above, e.g. 172.28.128.228]"
```
like:

```
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"
Environment="KUBELET_EXTRA_ARGS=--node-ip=[ip from above, e.g. 172.28.128.228]"
```
then restart kubelet: 

```bash
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

- Create cluster: login to master node and run:

```bash
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=[172.28.128.228 - ip address for master, ip address should from landrush and starts with `172.xxx.xxx.xxx`, like `172.28.128.225`]
```
Attention: We will be using Flannel network plugin which by default requires setting `--pod-network-cidr` to `10.244.0.0/16`, so do not change that

- Save the last several lines of the output for the previous step for later use, like:

```
Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 172.28.128.228:6443 --token 6ml26q.l6qo06dvnzgixf8l \
    --discovery-token-ca-cert-hash sha256:82a59083c348b89879c3f3c17e23eb7815c43cacb300bd28d6795a8f37f9ca60 
```

- Init kubectl on master: login into master node and run:

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

now you should be able to run:

```bash
kubectl get nodes
```

- Download Flannel yaml on master:
```bash
curl -o kube-flannel.yml https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

- Modify kube-flannel.yml: 

add `iface=enp0s8` to kube-flannel.yml, like:

```
  containers:
  - name: kube-flannel
    image: quay.io/coreos/flannel:v0.10.0-amd64
    command:
    - /opt/bin/flanneld
    args:
    - --ip-masq
    - --kube-subnet-mgr
    - --iface=enp0s8
```

where enp0s8 should be the network interface name for your Vagrant node's corresponding IP address , use `ifconfig -a` to find it.

without this step, Flannel will use the default network interface for Vagrant node which is `10.0.2.15` for every node which will not be working.

- Install pod network: login into master node and run:

```bash
sudo kubectl apply -f kube-flannel.yml
```

- Join the cluster: login to each worker node and run your saved `kubeadm join...`:

```bash
sudo kubeadm join 172.28.128.225:6443 --token qjt39y.g0umwcos5enynw \
    --discovery-token-ca-cert-hash sha256:384ee76110b0b6783b0ebe87c8b177809d6ef84c2b499c934008fc0d3397f2 
```

- Check cluster status: login to master node and run `kubectl get nodes`,if all nodes are Ready then you are set



# K8s command cheat sheet
- disable swap: sudo swapoff -a
- create cluster: sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=172.28.128.225
- install network: kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
- get all nodes: kubectl get nodes -o wide
- get all pods: kubectl get pods -o wide
- get all context: kubectl config get-contexts
- get all cluster: kubectl config get-clusters
- login pod: kubectl exec -it [pod name] -- /bin/bash
- exec command in pod: kubectl exec pod1 -it [pod name] -- [command]
- delete context: kubectl config delete-context [context]
- join cluster: 
