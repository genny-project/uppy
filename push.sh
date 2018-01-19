#!/bin/bash

if [ -z "${1}" ]; then
   version="latest"
else
   version="${1}"
fi


docker push gennyproject/uppy:${version}
docker tag  gennyproject/uppy:${version} gennyproject/uppy:latest
docker push gennyproject/uppy:latest
