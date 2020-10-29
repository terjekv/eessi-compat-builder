#!/bin/bash

set -e

cd terraform;
terraform apply -auto-approve

IP=$( terraform show -no-color | grep ^public_ip -A1 | grep -v public_ip | cut -f2 -d'"' )
UNAME="ec2-user"
REMOTE="$UNAME@$IP"

ssh $REMOTE -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no 'tar -cf - compat | gzip -9' > ../compat.tar.gz

terraform destroy -auto-approve
