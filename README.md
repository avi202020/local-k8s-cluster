# Introduction
- Local 3-node k8s cluster provisioned by Vagrant and Ansible.

# Setup kubernetes cluster from scratch
- Start 3 vms: `cd` to `vagrant-3-dns-ubuntu1804` and run `./start.sh` to create 3 vms. The 3 vms have their DNS set up and can access the Internet and can be accessed from host machine
- Provision: `cd` to project root folder and run `./provision.sh all[or master/worker1/worker2]` to provision vm(s), the provision mainly installs docker
- Install k8s master: `./install-k8s-master.sh`
- Create cluster: login to master node and run:

```bash
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=[ip address for master, ip address should from landrush and starts with `172.xxx.xxx.xxx`, like `172.28.128.225`]
```
- Save the last several lines of the output for the previous step, like:

```
Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 172.28.128.225:6443 --token 6ml26q.l6qo06dvnzgixf8l \
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

- Install pod network: login into master node and run:

```bash
sudo kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

- Install k8s workers: `./install-k8s-worker.sh workers`
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
- get all nodes: kubectl get nodes
- get all context: kubectl config get-contexts
- get all cluster: kubectl config get-clusters
- delete context: kubectl config delete-context [context]
- join cluster: 

```bash
kubeadm join 172.28.128.223:6443 --token qjt39y.g0umwcooms5enynw \
    --discovery-token-ca-cert-hash sha256:384ee76110b0a0b6783b0ebe87c8b177809d6ef84c2b499c934008fc0d3397f2 
```
