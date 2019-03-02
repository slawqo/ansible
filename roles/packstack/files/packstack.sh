#!/bin/bash

yum localinstall -y http://download.lab.bos.redhat.com/rcm-guest/puddles/OpenStack/rhos-release/rhos-release-latest.noarch.rpm
rhos-release "${1}"
yum install openstack-packstack -y
packstack --allinone --default-password=pass123456 \
    --provision-tempest=y \
    --os-swift-install=n \
    --os-heat-install=n
