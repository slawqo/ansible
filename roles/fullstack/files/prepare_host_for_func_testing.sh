#!/bin/bash

export INSTALL_OVN=True
export Q_BUILD_OVS_FROM_GIT=True
export OVN_BRANCH='v21.06.0'
export OVS_BRANCH='v2.16.0'
export DATABASE_USER=openstack_citest

sudo setenforce 0

venv=$1

if [ -n $venv ]; then
    export VENV=$venv
fi

cd /opt/stack/neutron
tools/configure_for_func_testing.sh /opt/stack/devstack -i
cd -
