#!/bin/bash
# init install deps
echo -e "\033[0;62m\033[0;49;35m"
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
	log "dp::(idle)::let's wait $1 seconds for $2." 2
	while true; do echo -n .; sleep 1; done | pv -s $1  -S -F '%t %p' > /dev/null
}

log "dp::janus::ci::(busy):: Installing dependencies: K3S and Kompose." 2
if [[ "$(which kompose)" == "" || "$(which k3s)" == "" ]]; then
		curl -sfL https://get.k3s.io | sh -
		curl -L https://github.com/kubernetes/kompose/releases/download/v1.35.0/kompose-linux-amd64 -o kompose
    rm -rf /var/lib/rancher/k3s/server/manifests/traefik.yaml
    systemctl restart k3s
    helm repo add traefik https://traefik.github.io/charts
    helm repo update
    echo "$(minikube ip) ${JANUS_HOSTNAME}" | sudo tee -a /etc/hosts
fi
else
	log "dp::janus::ci::(skip)::skipped installing deps."
fi




log "dp::janus::ci::(idle)::all good." 0