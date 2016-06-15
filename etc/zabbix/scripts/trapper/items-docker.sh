#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/../main"

CTS=$(echo "GET /containers/json?all=1 HTTP/1.0\r\n" | sudo netcat -U "$DOCKER_SOCKET" | tail -n +5)
LEN=$(echo "$CTS" | jq "length")
RES=''
for I in $(seq 0 $((LEN-1)))
do
    ID=$(echo "$CTS" | jq ".[$I].Id" | sed -e 's/^"//' -e 's/"$//')
    NAME=$(echo "$CTS" | jq ".[$I].Names[0]" | sed -e 's/^"\//"/' | sed -e 's/^"//' -e 's/"$//')
    CT=$(echo "GET /containers/$ID/json HTTP/1.0\r\n" | sudo netcat -U "$DOCKER_SOCKET" | tail -n +5)
    RUNNING=$(echo "$CT" | jq ".State.Running" | sed -e 's/^"//' -e 's/"$//')
    PID=$(echo "$CT" | jq ".State.Pid" | sed -e 's/^"//' -e 's/"$//')
    EXITCODE=$(echo "$CT" | jq ".State.ExitCode" | sed -e 's/^"//' -e 's/"$//')
    RES="$RES\n- docker.containers.running[$NAME] $RUNNING"
    RES="$RES\n- docker.containers.pid[$NAME] $PID"
    RES="$RES\n- docker.containers.exitcode[$NAME] $EXITCODE"
    if [ "$RUNNING" = "true" ]; then
        TOP=$(echo "GET /containers/$ID/top?ps_args=-aux HTTP/1.0\r\n" | sudo netcat -U "$DOCKER_SOCKET"|tail -n +5)
        PS=$(echo "$TOP" | jq ".Processes")
        PS_LEN=$(echo "$PS" | jq "length")
        for J in $(seq 0 $((PS_LEN-1)))
        do
            P=$(echo "$PS" | jq ".[$J]")
            PID=$(echo "$P" | jq ".[1]" | sed -e 's/^"//' -e 's/"$//')
            CPU=$(echo "$P" | jq ".[2]" | sed -e 's/^"//' -e 's/"$//')
            MEM=$(echo "$P" | jq ".[3]" | sed -e 's/^"//' -e 's/"$//')
            VSZ=$(echo "$P" | jq ".[4]" | sed -e 's/^"//' -e 's/"$//')
            RSS=$(echo "$P" | jq ".[5]" | sed -e 's/^"//' -e 's/"$//')
            COMMAND=$(echo "$P" | jq ".[10]" | sed -e 's/^"//' -e 's/"$//')
            RES="$RES\n- docker.top.cpu[$NAME,$PID] $CPU"
            RES="$RES\n- docker.top.mem[$NAME,$PID] $MEM"
            RES="$RES\n- docker.top.vsz[$NAME,$PID] $VSZ"
            RES="$RES\n- docker.top.rss[$NAME,$PID] $RSS"
            RES="$RES\n- docker.top.command[$NAME,$PID] \"$COMMAND\""
        done
    fi
done
zbx_send_all "$RES"
