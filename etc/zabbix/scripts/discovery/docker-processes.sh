#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/../main"
CTS=$(echo -e "GET /containers/json?all=1 HTTP/1.0\r\n" | sudo netcat -U "$DOCKER_SOCKET" | tail -n +5)
LEN=$(echo -e "$CTS" | jq 'length')
for I in $(seq 0 $((LEN-1)))
do
    ID=$(echo -e "$CTS" | jq ".[$I].Id" | sed -e 's/^"//' -e 's/"$//')
    NAME=$(echo -e "$CTS" | jq ".[$I].Names[0]" | sed -e 's/^"\//"/')
    CT=$(echo -e "GET /containers/$ID/json HTTP/1.0\r\n"|sudo netcat -U "$DOCKER_SOCKET" | tail -n +5)
    RUNNING=$(echo -e "$CT" | jq ".State.Running" | sed -e 's/^"//' -e 's/"$//')
    if [ "$RUNNING" = "true" ]; then
        TOP=$(echo -e "GET /containers/$ID/top?ps_args=-aux HTTP/1.0\r\n"| sudo netcat -U "$DOCKER_SOCKET" | tail -n +5)
        PS=$(echo -e "$TOP" | jq ".Processes")
        PS_LEN=$(echo "$PS" | jq "length")

        for J in $(seq 0 $((PS_LEN-1)))
        do
            P=$(echo -e "$PS" | jq ".[$J]")
            PID=$(echo -e "$P" | jq ".[1]" | sed -e 's/^"//' -e 's/"$//')
            CMD=$(basename $(echo "$P" | jq ".[10]" | sed -e 's/^"//' -e 's/"$//' | cut -d' ' -f1))
            DATA="$DATA,"'{"{#NAME}":'${NAME}',"{#PID}":'${PID}',"{#CMD}":"'${CMD}'"}'
        done
    fi
done
echo -e '{"data":['${DATA#,}']}'
