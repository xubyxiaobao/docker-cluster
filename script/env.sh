#!/bin/bash
#环境变量设置

#项目运行docker子网
export NETWORK=ddc_network
export SUBNET=172.32.0.0/16
export GATEWAY=172.32.0.1
export CLUSTER_SUFFIX="_cluster"
export ALL_SERVICES="|zookeeper|kafka|redis|mongo|nifi|"
export ALL_COMMANDS="|start|stop|"
export BASE_DIR=$(cd $(dirname $0);pwd)