#!/bin/bash

PROGRESS_FILE="./.ir_progress"
POOL_NAME="images"

IR_NETWORKS="management data external"
IR_VM_TYPES="undercloud controller compute"

# First cleaning
# Clean old vms and volumes
for vm_type in $IR_VM_TYPES; do
    vms=$(sudo virsh list --all | grep $vm_type | grep -v devstack | grep -v multinode | awk '{print $2}')
    for vm in $vms; do
        sudo virsh undefine $vm
        sudo virsh destroy $vm
    done
    volumes=$(sudo virsh vol-list $POOL_NAME | grep $vm_type | awk '{print $1}')
    for vol in $volumes; do
        sudo virsh vol-delete $vol --pool $POOL_NAME
    done
done

# clean old networks
for net in $IR_NETWORKS; do
    sudo virsh net-destroy $net
    sudo virsh net-undefine $net
done

# Remove vbmc config
sudo rm -rf /root/.vbmc/
if [ -f ${PROGRESS_FILE} ]; then
    rm ${PROGRESS_FILE}
fi
