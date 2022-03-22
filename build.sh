#!/bin/bash
#

set -ex
# SET THE FOLLOWING VARIABLES
# docker hub username
USERNAME=robinhoodis
# image name
IMAGE=ubuntu
#docker build -t $USERNAME/$IMAGE:latest .
docker build -t $USERNAME/$IMAGE:latest .
