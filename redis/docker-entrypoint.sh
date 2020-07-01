#!/bin/bash


# args： command:redis-server 、redis-sentinel、...
#        configPath
# 检查传入的第一个参数是否为redis-server
if [[ $# < 1 ]]; then
    echo -e "\033[31mparameter nums error!\033[0m"
    exit   256
fi
exec_command=$1;

prefix="REDIS"
config_path="$REDIS_CONFIG_PATH/redis.conf"
if [[ $exec_command == "redis-sentinel" ]]; then
    prefix="SENTINEL"
    config_path="$REDIS_CONFIG_PATH/sentinel.conf"
fi

echo "command is :$exec_command"
echo "配置文件：$config_path"


#检查config_path是否存在文件，如果存在则直接使用，如果不存在则使用默认，并将环境变量中redis/sentinel开头的变量转换为对应的参数
if [[ -f $config_path ]]; then
    echo "配置文件${config_path}已存在，不再生成对应的配置文件"
else
    echo "不存在配置文件，根据环境变量生成对应的配置文件"
    # 生成一份空白的配置文件
    echo "" >> "$config_path"

    (
        function updateConfig(){
            key=$1
            value=$2
            file=$3
            echo "[Configuring] '$key' in '$file'"
            echo "$key $value" >> "$file"

        }

        EXCLUSIONS="|REDIS_DEFAULT_CONFIG_PATH|SENTINEL_DEFAULT_CONFIG_PATH|REDIS_CONFIG_PATH|"

        for VAR in $(export | cut -d' ' -f3-)
        do
            #获取环境变量的key
            env_var=$(echo "$VAR" | cut -d= -f1)

            #排除不需要写入配置文件的变量
            if [[ "$EXCLUSIONS" = *"|$env_var|"* ]]; then
                echo "Excluding $env_var from $prefix config"
                continue
            fi

            #如果是redis-service模式
            if [[ $env_var =~ ^REDIS_  ]]; then
                config_name=$(echo "$env_var" | cut -d_ -f2- | tr '[:upper:]' '[:lower:]' | tr _ .)
                updateConfig "$config_name" "${!env_var}" "$config_path"
            fi

            #如果是redis-sentinel模式
            if [[ $env_var =~ ^SENTINEL[1-9]?_  ]]; then
                config_name=$(echo "$env_var" | sed -s 's/__/-/g' | cut -d_ -f2- | tr '[:upper:]' '[:lower:]'  | tr _ " ")
                updateConfig "$config_name" "${!env_var}" "$config_path"
            fi
        done
    )
fi


#执行命令
exec $exec_command  $config_path