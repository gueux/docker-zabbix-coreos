#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/../main"
CTS=$(echo "GET /containers/json?all=1 HTTP/1.0\r\n"|sudo netcat -U "$DOCKER_SOCKET"|tail -n +5)
LEN=$(echo "$CTS"|jq 'length')
for I in $(seq 0 $((LEN-1)))
do
    NAME=$(echo "$CTS"|jq ".[$I].Names[0]"|sed -e 's/^"\//"/')
    DATA="$DATA,"'{"{#NAME}":'$NAME'}'
done
echo '{"data":['${DATA#,}']}'
