#!/bin/bash


# JVM_ARG_1="-Xmx512m"
# JVM_ARG_2="-Xms512m"
# JVM_ARG_3="-XX:+UseConcMarkSweepGC"
# JVM_ARG_4="-XX:+UseParNewGC"
# JVM_ARG_5="-XX:CMSInitiatingOccupancyFraction=75"
# JVM_ARG_6="-XX:+UseCMSCompactAtFullCollection"
# JVM_ARG_6="-XX:CMSMaxAbortablePrecleanTime=5000"
# JVM_ARG_6="-XX:CMSFullGCsBeforeCompaction=5"
#JVM参数组装
JVM_ARGS="";
for arg in $(env)
do
    env_var=$(echo $arg | cut -d= -f1);
    if [[ $env_var =~ ^JVM_ARG_([0-9])+ ]]; then

       JVM_ARGS="${JVM_ARGS} ${!env_var} "
    fi
done

#启动参数组装
COMMAND_ARGS="";
if [ $# -gt 0 ]; then
    for cmd_arg in $@
    do
        COMMAND_ARGS="$COMMAND_ARGS $cmd_arg"
    done
fi

#运行程序
java $JVM_ARGS  -jar ${APP} ${COMMAND_ARGS}
