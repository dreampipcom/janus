#!/bin/bash
# init k8s
echo -e "\033[0;62m\033[0;49;35m"
set -a && source .env.k8s.private && set +a
set -a && source .env.common.private && set +a
root_dir="$(pwd)"

log () {
  echo -e "\033[0;49;35m"
  # warning
  if [[ "$2" == "2" ]]; then
    echo -e "\033[35;43m$1\033[0m"
  fi
  # error
  if [[ "$2" == "1" ]]; then
    echo -e "\033[35;41m\033[33m$1\033[0m"
  fi
  # success
  if [[ "$2" == "0" ]]; then
    echo -e "\033[35;42m$1\033[0m"
  fi
  # normal
  if [[ "$2" == "" ]]; then
    echo -e "\033[35;46m$1\033[0m"
  fi
}

prompt () {
  log "$1" 2
  read answer
  echo "$answer"
}

gosu () {
  if [ $( id -u ) -ne 0 ]; then
    log "dp::(auth)::this command needs sudo, please add password for %p: " 2
      sudo -v
      # exit $?
  fi
}

take () {
  log "dp::(idle)::let's wait ($1 * $JANUS_COOLDOWN_POINTER) seconds for $2." 2
  while true; do echo -n .; sleep 1; done | pv -s $1 * $JANUS_COOLDOWN_POINTER  -S -F '%t %p' > /dev/null
}

_deploy () {
  cd ../ingress/data/charts
  kubectl apply -f . -n janus
}

_kompose () {
  kompose convert --out data/charts/
}


log "dp::janus::${JANUS_ENV}::k8s::(busy)::Initiating Kubernetes: ${JANUS_ENV} env."


# k8s setup
log "dp::janus::${JANUS_ENV}::k8s::(busy):: Cleaning up previous deployment." 2
kubectl delete --all deployments --namespace janus
helm uninstall traefik -n janus
rm -rf ../ingress/data

# network setup
# log "dp::janus::${JANUS_ENV}::k8s::(busy):: Configuring networks." 2
# ./init-networks.sh

config setup
log "dp::janus::${JANUS_ENV}::k8s::(busy):: Transposing files." 2
./init-janus.sh

# prepare
log "dp::janus::${JANUS_ENV}::k8s::(busy):: Initiating Kubernetes: creating namespaces."
kubectl create namespace janus

# deploy
log "dp::janus::${JANUS_ENV}::k8s::(busy):: Deploying: Applying Charts for Janus (Ingress)." 2
cd ../ingress
helm install traefik traefik/traefik --namespace=janus --values=./data/manifests/traefik.yaml
_deploy
cd $root_dir


log "dp::janus::${JANUS_ENV}::k8s::(idle)::all good." 0