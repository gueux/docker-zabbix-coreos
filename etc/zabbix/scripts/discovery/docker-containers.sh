#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/../main"
CTS=$(echo -e "GET /containers/json?all=1 HTTP/1.0\r\n" | sudo netcat -U "$DOCKER_SOCKET" | tail -n 1)
LEN=$(echo -e "$CTS" | jq 'length')
for I in $(seq 0 $((LEN-1)))
do
    NAME=$(echo -e "$CTS" | jq ".[$I].Names[0]" | sed -e 's/^"\//"/')
    DATA="$DATA,"'{"{#NAME}":'$NAME'}'
done
echo -e '{"data":['${DATA#,}']}'
