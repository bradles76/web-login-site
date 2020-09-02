#!/bin/bash
# This script excepts 3 command-line arguments in this particular order: Tenable.io Access Key, Tenable.io Secret Key, Tenable.io JFrog pubread password
#This script expects the following environment variables to be set:
# BUILD_BUILDID - This is set by Azure if you have called this script from a Docker Build and Push step
# IMAGEREPOSITORY - This is set by Azure if you have called this script from a Docker Build and Push step
TIOACCKEY=$1
TIOSECKEY=$2
TIOJFROGPASSS=$3

echo "Checking $IMAGEREPOSITORY:$BUILD_BUILDID and analyzing results on-premise then reporting into cloud.tenable.com repo $IMAGEREPOSITORY"
echo "Tenable.io Access Key: $TIOACCKEY"
echo ""

#For debugging
echo "Variables list:"
set

echo "Download Tenable.io on-prem scanner"

docker login --username pubread --password $TIOJFROGPASSS tenableio-docker-consec-local.jfrog.io
docker pull tenableio-docker-consec-local.jfrog.io/cs-scanner:latest

#For debugging
docker images

echo "Start of on-prem analysis"
docker save $CONTAINERREGISTRY/$IMAGEREPOSITORY:$BUILD_BUILDID | docker run -e CHECK_POLICY=true -e DEBUG_MODE=true -e TENABLE_ACCESS_KEY=$TIOACCKEY -e TENABLE_SECRET_KEY=$TIOSECKEY -e IMPORT_REPO_NAME=$IMAGEREPOSITORY -i tenableio-docker-consec-local.jfrog.io/cs-scanner:latest inspect-image $IMAGEREPOSITORY:$BUILD_BUILDID

import requests

url = "https://cloud.tenable.com/container-security/api/v2/reports/repository/$IMAGEREPOSITORY:$BUILD_BUILDID"

headers = {
    "accept": "application/json",
    "x-apikeys": "accessKey=$TIOACCKEY;secretKey=$TIOSECKEY"
}

response = requests.request("GET", url, headers=headers)

print(response.text)
