#!/usr/bin/env bash

if [ -z "$1" ]
  then
    echo "Error: No inventory host provided, the host should exists in inventory.ini file, example: './install-k8s-worker.sh worker1'"
    exit 1
fi

export ANSIBLE_HOST_KEY_CHECKING=false
ansible-playbook -i inventory.ini -v worker-playbook.yml --extra-vars "host=$1" -v