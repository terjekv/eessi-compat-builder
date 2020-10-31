#!/bin/sh

export TF_VAR_mode=test
rm -f output/*
rm -f terraform/remote.sh
rm -f *.tar.gz
cd terraform; terraform destroy -auto-approve; cd ..
