#!/bin/bash

function checkUP(){
    stack_name=$1
    service_num=$2
    while true; do
        if [ $service_num == $(docker stack ps -f "desired-state=running" -q  $stack_name |wc -l) ]; then
            echo "${stack_name} 启动成功"
            break;
        else
            docker stack ps $stack_name
        fi
        sleep 5
    done
}
