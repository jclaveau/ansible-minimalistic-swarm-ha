#!/bin/bash
set -x
set -e

_pwd=$PWD
tempDir=$(mktemp -d)

vagrant up

# Set infrastructure on Vagrant
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i vagrant.py -i vagrant-groups.list ../install.yml

[ -n "$tempDir" ] && rm -rf "$tempDir"
