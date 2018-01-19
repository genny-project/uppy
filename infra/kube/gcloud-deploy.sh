#!/usr/bin/env bash
set -o pipefail
set -o errexit
set -o nounset
# set -o xtrace

# Set magic variables for current FILE & DIR
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__kube="${__dir}"

# Store the new image in docker hub
docker build --quiet -t transloadit/uppy-server:latest -t transloadit/uppy-server:$TRAVIS_COMMIT .;
docker login -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD";
docker push transloadit/uppy-server:$TRAVIS_COMMIT;
docker push transloadit/uppy-server:latest;

echo $CA_CRT | base64 --decode -i > ${HOME}/ca.crt

gcloud config set container/use_client_certificate True
export CLOUDSDK_CONTAINER_USE_CLIENT_CERTIFICATE=True

kubectl config set-cluster transloadit-cluster --embed-certs=true --server=${CLUSTER_ENDPOINT} --certificate-authority=${HOME}/ca.crt
kubectl config set-credentials travis --token=$SA_TOKEN
kubectl config set-context travis --cluster=$CLUSTER_NAME --user=travis --namespace=uppy
kubectl config use-context travis

echo $UPPY_ENV | base64 --decode -i > "${__kube}/uppy-server/uppy-env.yaml"

kubectl config current-context

kubectl apply -f "${__kube}/uppy-server/uppy-env.yaml"
kubectl apply -f "${__kube}/uppy-server/pvc.yaml"
kubectl apply -f "${__kube}/uppy-server/deployment.yaml"
kubectl apply -f "${__kube}/uppy-server/service.yaml"
kubectl apply -f "${__kube}/uppy-server/ingress-tls.yaml"
kubectl apply -f "${__kube}/uppy-server/hpa.yaml"
kubectl set image deployment/uppy-server --namespace=uppy uppy-server=docker.io/transloadit/uppy-server:$TRAVIS_COMMIT
sleep 10s

kubectl get pods --namespace=uppy
kubectl get service --namespace=uppy
kubectl get deployment --namespace=uppy

function cleanup {
    printf "Cleaning up...\n"
    rm -vf "${HOME}/gcloud-service-key.json"
    rm -vf "${__kube}/uppy-server/uppy-env.yaml"
    printf "Cleaning done."
}

trap cleanup EXIT