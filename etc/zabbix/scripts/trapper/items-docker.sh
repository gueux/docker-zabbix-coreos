#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/../main"

CTS=$(echo -e "GET /containers/json?all=1 HTTP/1.0\r\n" | sudo netcat -U "$DOCKER_SOCKET" | tail -n +5)
LEN=$(echo -e "$CTS" | jq "length")
RES=''
for I in $(seq 0 $((LEN-1)))
do
    ID=$(echo -e "$CTS" | jq ".[$I].Id" | sed -e 's/^"//' -e 's/"$//')
    NAME=$(echo -e "$CTS" | jq ".[$I].Names[0]" | sed -e 's/^"\//"/' | sed -e 's/^"//' -e 's/"$//')
    CT=$(echo -e "GET /containers/$ID/json HTTP/1.0\r\n" | sudo netcat -U "$DOCKER_SOCKET" | tail -n +5)
    RUNNING=$(echo -e "$CT" | jq ".State.Running" | sed -e 's/^"//' -e 's/"$//')
    PID=$(echo -e "$CT" | jq ".State.Pid" | sed -e 's/^"//' -e 's/"$//')
    EXITCODE=$(echo -e "$CT" | jq ".State.ExitCode" | sed -e 's/^"//' -e 's/"$//')
    RES="$RES\n- docker.containers.running[$NAME] $RUNNING"
    RES="$RES\n- docker.containers.pid[$NAME] $PID"
    RES="$RES\n- docker.containers.exitcode[$NAME] $EXITCODE"
    if [ "$RUNNING" = "true" ]; then
        TOP=$(echo -e "GET /containers/$ID/top?ps_args=-aux HTTP/1.0\r\n" | sudo netcat -U "$DOCKER_SOCKET"|tail -n +5)
        PS=$(echo -e "$TOP" | jq ".Processes")
        PS_LEN=$(echo -e "$PS" | jq "length")
        for J in $(seq 0 $((PS_LEN-1)))
        do
            P=$(echo -e "$PS" | jq ".[$J]")
            PID=$(echo -e "$P" | jq ".[1]" | sed -e 's/^"//' -e 's/"$//')
            CPU=$(echo -e "$P" | jq ".[2]" | sed -e 's/^"//' -e 's/"$//')
            MEM=$(echo -e "$P" | jq ".[3]" | sed -e 's/^"//' -e 's/"$//')
            VSZ=$(echo -e "$P" | jq ".[4]" | sed -e 's/^"//' -e 's/"$//')
            RSS=$(echo -e "$P" | jq ".[5]" | sed -e 's/^"//' -e 's/"$//')
            COMMAND=$(echo -e "$P" | jq ".[10]" | sed -e 's/^"//' -e 's/"$//')
            RES="$RES\n- docker.top.cpu[$NAME,$PID] $CPU"
            RES="$RES\n- docker.top.mem[$NAME,$PID] $MEM"
            RES="$RES\n- docker.top.vsz[$NAME,$PID] $VSZ"
            RES="$RES\n- docker.top.rss[$NAME,$PID] $RSS"
            RES="$RES\n- docker.top.command[$NAME,$PID] \"$COMMAND\""
        done
    fi
done
zbx_send_all "$RES"
