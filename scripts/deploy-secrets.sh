#!/bin/bash
# init emailia
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

log "dp::janus::ci::(busy):: Deploying secrets." 2
log "dp::janus::ci::(busy):: This is not the most secure method to deploy secrets and should be used with caution. Helm Secrets should be used in the future." 1 

if [ "$1" == "install" ]; then
	log "dp::janus::ci::(busy):: Sending to installation dir."
  scp .env.*.private $JANUS_REMOTE:$JANUS_REMOTE_HOME
else
	log "dp::janus::ci::(busy):: Sending to janus dir."
  scp .env.*.private $JANUS_REMOTE:$JANUS_REMOTE_ROOT
fi


log "dp::janus::ci::(idle)::all good." 0
