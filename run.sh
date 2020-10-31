#!/bin/bash

set -e

if [[ $# -eq 0 ]] || [[ "$1" == "test" ]] || [[ "$1" == "plan" ]]; then
    echo "Starting test run, to run prod run '$0 prod'";
    echo "Stripping singularity building from remote script..."
    cp remote.sh terraform/remote.sh
    perl -pi -e 's|sudo yum |# sudo yum|' terraform/remote.sh
    perl -pi -e 's|.*singularity.*docker.*|    echo "Testing only..."|' terraform/remote.sh
    MODE=test
    export TF_VAR_mode=test
elif [[ $1 == "prod" ]]; then
    echo "Starting production, run this will take a while...'";
    cp remote.sh terraform/remote.sh
    export TF_VAR_mode=prod
    MODE=prod
else
    echo "Pass either nothing, 'test', 'prod' or 'plan' to this script."
    echo "Nothing passed implies 'test'."
    exit 1
fi    

BUILDTIME_UTC=$( date -u +'%Y-%m-%d_%H_%M_%S_UTC' )
TF_SHOW="terraform show -no-color"

cd terraform;

# If terraform isn't initalized for this module, do that first.
[ -d .terraform ] || terraform init

if [[ "$1" == "plan" ]]; then
    terraform plan
    cd ..
    rm terraform/remote.sh
    exit 0
fi

terraform apply -auto-approve

echo "Build complete for all arch. Starting fetch..."
for HOST in $( $TF_SHOW | grep ^public_dns | awk '{print $1}' ); do
    ARCH=$( echo $HOST | cut -f3,4 -d_ )
    DNS=$( $TF_SHOW | grep ^${HOST} -A1|grep -v public_dns | cut -f2 -d'"' )
    UNAME=$( grep 'user = "' variables.tf | cut -f2 -d\" )
    REMOTE="$UNAME@$DNS"
    SSH="ssh -o LogLevel=ERROR -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
    echo "Fetching ${ARCH}..."
    time $SSH $REMOTE 'tar -cf - compat | gzip -9' > ../compat-${MODE}-${ARCH}-${BUILDTIME_UTC}.tar.gz
done

terraform destroy -auto-approve

cd ..
rm terraform/remote.sh
