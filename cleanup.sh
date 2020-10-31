#!/bin/sh

rm -f terraform/remote.sh
rm -f *.tar.gz
cd terraform; terraform destroy -auto-approve; cd ..
