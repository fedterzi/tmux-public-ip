#!/usr/bin/env bash
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

tmpfile="/tmp/.tmux.public-ip.txt"
update_period=60

update() {
	dig=$(which dig 2>/dev/null)
	if [[ -z $dig ]]; then
		echo "install 'dig'"
		exit
	fi
	curl=$(which curl 2>/dev/null)
	if [[ -z $curl ]]; then
		echo "install 'curl'"
		exit
	fi
    pub_ip=$(dig +short myip.opendns.com @resolver1.opendns.com)
	if [[ -z $pub_ip ]]; then
		pub_ip=$(curl whatismyip.akamai.com)
	fi
	cat << _EOF_ > $tmpfile
LAST_TS=$(date +%s)
IP_ADDR=$pub_ip
_EOF_
}

if [ -f "$tmpfile" ]; then
	source $tmpfile
	if [[ $(( $LAST_TS + $update_period )) -lt $(date +%s) ]]; then
		update
	fi
else
	update
fi

source $tmpfile
echo $IP_ADDR
