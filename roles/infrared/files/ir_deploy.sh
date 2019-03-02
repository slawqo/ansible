#!/bin/bash

IR_DIR="."

# TODO: maybe it's possible to discover somehow current venv?
VENV_NAME=".venv"
VENV_DIR="${IR_DIR}/$VENV_NAME"

# Progress
PROGRESS_FILE="./.ir_progress"
START=0
ENV_PROVISIONED=1
UC_INSTALLED=2
OC_INSTALLED=3

HOST="127.0.0.1"
HOST_KEY="~/.ssh/id_rsa_infrared"
HOST_USER="root"

# Default values (can be configured, see help)
UNDERCLOUD_NODES=1
CONTROLLERS=1
COMPUTES=1
OSP_VERSION=13
DVR="no"
IMAGE="http://download-node-02.eng.bos.redhat.com/brewroot/packages/rhel-guest-image/7.6/220/images/rhel-guest-image-7.6-220.x86_64.qcow2"


function print_help() {
    echo ""
    echo "Script to spawn OSP with infrared"
    echo " Usage: ir_deploy.sh [-h] [-undercloud] [-controllers] [-computes] [-image] [-osp] [-dvr]"
    echo ""
    echo " -h - print this help"
    echo " -undercloud  - number of UC nodes"
    echo "      Default value: 1"
    echo " -controllers - number of controller nodes in OC"
    echo "      Default value: 1"
    echo " -computes    - number of compute nodes in OC"
    echo "      Default value: 1"
    echo " -osp         - used version of OSP"
    echo "      Default value: 13"
    echo " -image       - image used do deploy servers"
    echo "      Default value: RHEL 7.6 image"
    echo " -dvr         - deploy overcloud with dvr or legacy routers,"
    echo "      Possible values: yes, no"
    echo "      Default value: no"
}

function install_ir() {
    if [ ! -d ${VENV_DIR} ]; then
        virtualenv ${VENV_NAME} && source ${VENV_DIR}/bin/activate
        pip install --upgrade pip
        pip install --upgrade setuptools
        pip install .
    else
        echo "Venv $VENV_NAME already created"
        source ${VENV_DIR}/bin/activate
    fi
}

function provision() {
    infrared virsh --host-address $HOST --host-key $HOST_KEY --topology-nodes "undercloud:$UNDERCLOUD_NODES,controller:$CONTROLLERS,compute:$COMPUTES" --host-memory-overcommit True --image-url $IMAGE
    if [ $? -ne 0 ]; then
        exit 1
    else
        echo $ENV_PROVISIONED > $PROGRESS_FILE
    fi
}

function install_undercloud() {
    IMAGES_TASK="rpm"
    if [ $OSP_VERSION -lt 10 ]; then
        IMAGES_TASK="build"
    fi

    IMAGES_URL=""
    if [ "$IMAGES_TASK" == "build" ]; then
        IMAGES_URL="--images-url http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2"
    fi

    UNDERCLOUD_CDN=""
    if [ -f "./undercloud_cdn.yml" ]; then
        UNDERCLOUD_CDN="--cdn undercloud_cdn.yml"
    fi

    infrared tripleo-undercloud --version $OSP_VERSION --images-task $IMAGES_TASK $UNDERCLOUD_CDN $IMAGES_URL
    if [ $? -ne 0 ]; then
        exit 1
    else
        echo $UC_INSTALLED > $PROGRESS_FILE
    fi
}

function install_overcloud(){
    CONTAINERS=no
    if [ $OSP_VERSION -ge 13 ]; then
        CONTAINERS=yes
    fi

    OVERCLOUD_CDN=""
    if [ -f "./overcloud_cdn.yml" ]; then
        OVERCLOUD_CDN="--overcloud-templates overcloud_cdn.yml"
    fi

    infrared tripleo-overcloud --deployment-files virt --version $OSP_VERSION --introspect yes --tagging yes --deploy yes --containers $CONTAINERS $OVERCLOUD_CDN --network-dvr $DVR
    if [ $? -ne 0 ]; then
        exit 1
    else
        echo $OC_INSTALLED > $PROGRESS_FILE
    fi
}


##### Main script starts here #####
for i in "$@"; do
	case $i in
		-h=*|--help)
		print_help
		exit 1
		;;
		--undercloud=*)
		UNDERCLOUD_NODES="${i#*=}"
		shift # past argument=value
		;;
		--controllers=*)
		CONTROLLERS="${i#*=}"
		shift # past argument=value
		;;
		--computes=*)
		COMPUTES="${i#*=}"
		shift # past argument=value
		;;
		--osp=*)
		OSP_VERSION="${i#*=}"
		shift # past argument=value
		;;
		--image=*)
		IMAGE="${i#*=}"
		shift # past argument=value
		;;
        --dvr=*)
        DVR="${i#*=}"
		shift # past argument=value
        ;;
		*)
			  print_help
			  exit 1
		;;
	esac
done

install_ir

OLD_PROGRESS=$START
if [ -f $PROGRESS_FILE ]; then
	OLD_PROGRESS=$(cat $PROGRESS_FILE)
fi

if [ $OLD_PROGRESS -ne $START ]; then
	echo "Found old deploy state: $OLD_PROGRESS. Resuming from next step..."
fi

if [ $OLD_PROGRESS -lt $ENV_PROVISIONED ]; then
	provision
	echo "Provisioning completed"
else
	echo "Provisioning already done"
fi

if [ $OLD_PROGRESS -lt $UC_INSTALLED ]; then
	install_undercloud
	echo "Undercloud installed"
else
	echo "Undercloud installation already done"
fi

if [ $OLD_PROGRESS -lt $OC_INSTALLED ]; then
	install_overcloud
	echo "Overcloud installed"
else
	echo "Overcloud installation already done"
fi
