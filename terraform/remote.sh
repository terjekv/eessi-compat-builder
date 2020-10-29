#!/bin/bash

echo "Running remote.sh"
sudo yum -y update
sudo yum -y upgrade
sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
sudo yum -y install singularity
sudo yum -y install tee

(
    echo "Initalizing compat layer build for $( uname -a ) on a $( curl http://169.254.169.254/latest/meta-data/instance-type )"
    echo "Starting build: $(date)"
    time singularity run docker://eessi/bootstrap-prefix:centos8-$(uname -m) ~/compat/$(uname -m) noninteractive 
    echo "Finished build: $( date )"
) | tee ~/compat/$(uname -m).build.log

