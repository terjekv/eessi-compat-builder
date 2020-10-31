#!/bin/bash

set -e

# This is the remote script that runs on the nodes.
# For testing, this will be modified, see run.sh for the specifics.
# For prod, this is run as-is.

RELEASE="2020.10"
ENVIRONMENT="pilot"

ARCH=$( uname -m )

LOGDIR="/tmp/eessi-logs"
ROOTDIR="/cvmfs/${ENVIRONMENT}.eessi-hpc.org/${RELEASE}"
COMPATROOT="${ROOTDIR}/compat/${ARCH}"
SOFTWAREROOT="${ROOTDIR}/software" # x86_64/intel/cascadelake

echo "Running remote.sh"
sudo yum -y update
sudo yum -y upgrade
sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
sudo yum -y install singularity


sudo mkdir -p $LOGDIR $ROOTDIR $COMPATROOT $SOFTWAREROOT
sudo chown $( who | awk '{print $1}' ) $LOGDIR $ROOTDIR $COMPATROOT $SOFTWAREROOT

LOGFILE="${LOGDIR}/compat-build.log"
(
    echo "Initalizing compat layer build for $( uname -m ) on a $( curl http://169.254.169.254/latest/meta-data/instance-type )"
    echo "Starting build: $(date)"
    time singularity run docker://eessi/bootstrap-prefix:centos8-${ARCH} ${COMPATROOT} noninteractive 
    echo "Finished build: $( date )"
) | tee -a $LOGFILE | grep '^>>> Installing '

