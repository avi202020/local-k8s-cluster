#!/usr/bin/env bash

export ANSIBLE_HOST_KEY_CHECKING=false
ansible-playbook -i inventory.ini -v master-playbook.yml