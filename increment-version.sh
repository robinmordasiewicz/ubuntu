#!/bin/bash
#

set -e

CONTAINERVERSION=`cat VERSION | awk -F. -v OFS=. 'NF==1{print ++$NF}; NF>1{if(length($NF+1)>length($NF))$(NF-1)++; $NF=sprintf("%0*d", length($NF), ($NF+1)%(10^length($NF))); print}'`
echo $CONTAINERVERSION > VERSION

cat deployment.yaml | sed -re "s/image:[[:space:]]robinhoodis\/ubuntu:.*/image: robinhoodis\/ubuntu:${CONTAINERVERSION}/" > deployment.yaml.tmp && mv deployment.yaml.tmp deployment.yaml

exit 0
