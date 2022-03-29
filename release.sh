#!/bin/bash
#

set -ex
# SET THE FOLLOWING VARIABLES
# docker hub username
USERNAME=robinhoodis
# image name
IMAGE=ubuntu
# ensure we're up to date
#git pull


# bump version
cat VERSION | awk -F. -v OFS=. 'NF==1{print ++$NF}; NF>1{if(length($NF+1)>length($NF))$(NF-1)++; $NF=sprintf("%0*d", length($NF), ($NF+1)%(10^length($NF))); print}' > VERSION.tmp && mv VERSION.tmp VERSION
version=`cat VERSION`
echo "version: $version"

sed -e "s/[0-9]\.[0-9]\.[0-9]/${version}/" deployment.yaml > deployment.yaml.tmp && mv deployment.yaml.tmp deployment.yaml

# run build
./build.sh
# tag it
#git add -A
#git commit -m "version $version"
#git tag -a "$version" -m "version $version"
#git push
#git push --tags
docker tag $USERNAME/$IMAGE:latest $USERNAME/$IMAGE:$version
# push it
docker push $USERNAME/$IMAGE:latest
docker push $USERNAME/$IMAGE:$version
git add . && git commit -m "creating skel" &&  git push
