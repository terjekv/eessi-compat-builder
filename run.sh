#!/bin/bash

set -e

REMOTE_LOG_DIR=/tmp/eessi-logs

[ -e output ] || mkdir output

if [[ $# -eq 0 ]] || [[ "$1" == "test" ]] || [[ "$1" == "plan" ]]; then
    echo ">>> Starting test run, to run prod run '$0 prod'";
    echo " >> Stripping building from remote script..."
    cp remote.sh terraform/remote.sh
    perl -pi -e 's|sudo yum |# sudo yum |' terraform/remote.sh
    perl -pi -e 's|.*singularity.*docker.*|    echo ">>> Installing [testing]"; touch "\${COMPATROOT}/testing"; touch "\${SOFTWAREROOT}/testing"|' terraform/remote.sh
    MODE=test
    export TF_VAR_mode=test
elif [[ $1 == "prod" ]]; then
    echo ">>> Starting production, run this will take a while...'";
    cp remote.sh terraform/remote.sh
    export TF_VAR_mode=prod
    MODE=prod
else
    echo "!!! Pass either nothing, 'test', 'prod' or 'plan' to this script."
    echo " !! Nothing passed implies 'test'."
    exit 1
fi    

BUILDTIME_UTC=$( date -u +'%Y-%m-%d_%H_%M_%S_UTC' )
TF_SHOW="terraform show -no-color"

cd terraform;

# If terraform isn't initalized for this module, do that first.
[ -d .terraform ] || terraform init

echo ">>> Starting to terraform..."

if [[ "$1" == "plan" ]]; then
    terraform plan
    cd ..
    rm terraform/remote.sh
    exit 0
fi

terraform apply -auto-approve

echo ">>> Build complete for all architectures. Starting data retrieval..."
for HOST in $( $TF_SHOW | grep ^public_dns | awk '{print $1}' ); do
    ARCH=$( echo $HOST | cut -f3,4 -d_ )
    DNS=$( $TF_SHOW | grep ^${HOST} -A1|grep -v public_dns | cut -f2 -d'"' )
    UNAME=$( grep 'user = "' variables.tf | cut -f2 -d\" )
    REMOTE="$UNAME@$DNS"
    SSH="ssh -o LogLevel=ERROR -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

    echo " >> ${ARCH}..."

    echo "  + logs..."
    BASENAME="eessi-logs-${MODE}-${ARCH}-${BUILDTIME_UTC}"
    for LOGFILE in $( $SSH $REMOTE ls $REMOTE_LOG_DIR/* ); do
        $SSH $REMOTE "gzip --stdout '${LOGFILE}'" > ../output/${BASENAME}.$( basename $LOGFILE ).gz
    done

    echo "  + compatibility layer..."
    BASENAME="eessi-compat-${MODE}-${ARCH}-${BUILDTIME_UTC}"
    for REPO in $( $SSH $REMOTE ls -d /cvmfs/* ); do
        for RELEASE in $( $SSH $REMOTE ls -d $REPO/* ); do 
	    echo "    - ${RELEASE}/compat..."
            $SSH $REMOTE "tar -C '${RELEASE}' -cf - compat | gzip -9" > ../output/${BASENAME}.tar.gz
	done
    done
done

echo ">>> Destroying infrastructure"
terraform destroy -auto-approve

cd ..
rm terraform/remote.sh
