#!/bin/bash

# This is the remote script that runs on the nodes.
# For testing, this will be modified, see run.sh for the specifics.
# For prod, this is run as-is.

echo "Running remote.sh"
sudo yum -y update
sudo yum -y upgrade
sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
sudo yum -y install singularity

mkdir ~/compat/
LOGFILE=~/compat/$(uname -m).build.log

touch $LOGFILE

(
    echo "Initalizing compat layer build for $( uname -m ) on a $( curl http://169.254.169.254/latest/meta-data/instance-type )"
    echo "Starting build: $(date)"
    time singularity run docker://eessi/bootstrap-prefix:centos8-$(uname -m) ~/compat/$(uname -m) noninteractive 
    echo "Finished build: $( date )"
) |tee -a $LOGFILE

