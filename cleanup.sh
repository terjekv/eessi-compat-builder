#!/bin/sh

rm -f *.tar.gz
cd terraform; terraform destroy -auto-approve; cd ..
