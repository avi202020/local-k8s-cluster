# local-k8s-cluster
- Local k8s cluster provisioned by  vagrant and ansible.

# Setup kubernetes cluster from scratch
- `cd` to `vagrant-3-dns-ubuntu1804` and run `./start.sh` to create 3 vms
- The 3 vms have their DNS set up and can access the Internet and can be accessed from host machine
- `cd` to project root folder and run `./provision.sh all[or master/worker1/worker2]` to provision vm(s),mainly installing docker

