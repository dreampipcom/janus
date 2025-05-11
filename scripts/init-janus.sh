#!/bin/bash
# init weagle
echo -e "\033[0;62m\033[0;49;35m"
set -a && source ../.env.common.private && set +a
set -a && source ../.env.ingress.private && set +a
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
  log "dp::(idle)::let's wait $1 seconds for $2." 2
  while true; do echo -n .; sleep 1; done | pv -s $1  -S -F '%t %p' > /dev/null
}


log "dp::janus::${JANUS_ENV}::ingress::(busy)::preparing Janus (Ingress: Traefik, Grafana, Prometheus) configuration files." 2

cd ../ingress
mkdir data
cd data
mkdir charts
mkdir manifests
cd $root_dir

cd ../ingress

origin="./_ingress.yaml"
destination="./data/charts/ingress.yaml"
tmpfile=$(mktemp --tmpdir=.)
cp -p $origin $tmpfile
cat $origin | envsubst > $tmpfile && mv $tmpfile $destination

origin="./_traefik-role.yaml"
destination="./data/charts/traefik-role.yaml"
tmpfile=$(mktemp --tmpdir=.)
cp -p $origin $tmpfile
cat $origin | envsubst > $tmpfile && mv $tmpfile $destination

origin="./_traefik-account.yaml"
destination="./data/charts/traefik-account.yaml"
tmpfile=$(mktemp --tmpdir=.)
cp -p $origin $tmpfile
cat $origin | envsubst > $tmpfile && mv $tmpfile $destination

origin="./_traefik-binding.yaml"
destination="./data/charts/traefik-binding.yaml"
tmpfile=$(mktemp --tmpdir=.)
cp -p $origin $tmpfile
cat $origin | envsubst > $tmpfile && mv $tmpfile $destination

origin="./_traefik-services.yaml"
destination="./data/charts/traefik-services.yaml"
tmpfile=$(mktemp --tmpdir=.)
cp -p $origin $tmpfile
cat $origin | envsubst > $tmpfile && mv $tmpfile $destination

if [ "$JANUS_ENV" == "prod" ]; then
  log "dp::janus::ci::(busy):: Initiating Production Traefik settings."
  origin="./_traefik-prod.yaml"
  destination="./data/charts/traefik.yaml"
  tmpfile=$(mktemp --tmpdir=.)
  cp -p $origin $tmpfile
  cat $origin | envsubst > $tmpfile && mv $tmpfile $destination
else
  log "dp::janus::ci::(busy):: Initiating local Traefik settings."
  origin="./_traefik-local.yaml"
  destination="./data/charts/traefik.yaml"
  tmpfile=$(mktemp --tmpdir=.)
  cp -p $origin $tmpfile
  cat $origin | envsubst > $tmpfile && mv $tmpfile $destination

  origin="./_whoami.yaml"
  destination="./data/charts/whoami.yaml"
  tmpfile=$(mktemp --tmpdir=.)
  cp -p $origin $tmpfile
  cat $origin | envsubst > $tmpfile && mv $tmpfile $destination
fi


origin="./_prometheus-config.yaml"
destination="./data/charts/prometheus-config.yaml"
tmpfile=$(mktemp --tmpdir=.)
cp -p $origin $tmpfile
cat $origin | envsubst > $tmpfile && mv $tmpfile $destination

origin="./_prometheus-role.yaml"
destination="./data/charts/prometheus-role.yaml"
tmpfile=$(mktemp --tmpdir=.)
cp -p $origin $tmpfile
cat $origin | envsubst > $tmpfile && mv $tmpfile $destination

origin="./_prometheus-service.yaml"
destination="./data/charts/prometheus-service.yaml"
tmpfile=$(mktemp --tmpdir=.)
cp -p $origin $tmpfile
cat $origin | envsubst > $tmpfile && mv $tmpfile $destination

origin="./_prometheus.yaml"
destination="./data/charts/prometheus.yaml"
tmpfile=$(mktemp --tmpdir=.)
cp -p $origin $tmpfile
cat $origin | envsubst > $tmpfile && mv $tmpfile $destination

origin="./_grafana.yaml"
destination="./data/charts/grafana.yaml"
tmpfile=$(mktemp --tmpdir=.)
cp -p $origin $tmpfile
cat $origin | envsubst > $tmpfile && mv $tmpfile $destination

origin="./_nexus-proxy.yaml"
destination="./data/charts/nexus-proxy.yaml"
tmpfile=$(mktemp --tmpdir=.)
cp -p $origin $tmpfile
cat $origin | envsubst > $tmpfile && mv $tmpfile $destination

origin="./_ingress-euterpe.yaml"
destination="./data/charts/ingress-euterpe.yaml"
tmpfile=$(mktemp --tmpdir=.)
cp -p $origin $tmpfile
cat $origin | envsubst > $tmpfile && mv $tmpfile $destination


log "dp::janus::${JANUS_ENV}::ingress::(idle)::all good." 0
