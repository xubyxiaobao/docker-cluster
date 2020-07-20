### 说明
> 本文档以3台centos7服务器为示例，三台服务器的基本信息为
           
  | 主机名 |  IP | swarm节点属性|
  | :-----: | :---: | :-----:|
  | ddc1  |  192.168.35.101 | manager   |
  | ddc2  |  192.168.35.102 | manager   |
  | ddc3  |  192.168.35.103 | manager   |
> 操作系统要求：Centos7.2


## 准备工作选择
> 首先需要任意一台服务器作为私服的运行服务器，记录ip。例如ddc3 ：192.168.35.103(很重要，后面会使用) 
### 端口开放
为了保证docker-swarm之间的通信，需开放如下端口
- 2377 TCP 
- 7946 TCP/UDP 
- 4789 TCP/UDP
- 5000 TCP
```bash
firewall-cmd --zone=public --add-port=2377/tcp --permanent
firewall-cmd --zone=public --add-port=7946/tcp --permanent
firewall-cmd --zone=public --add-port=7946/udp --permanent
firewall-cmd --zone=public --add-port=4789/tcp --permanent
firewall-cmd --zone=public --add-port=4789/udp --permanent
firewall-cmd --zone=public --add-port=5000/tcp --permanent
firewall-cmd --reload
```


### docker安装(所有服务器都需要安装)
####1、删除旧docker
```bash
$ sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
```
####2、安装
下载网盘中的文件：[docker-ce-19.03.12-3.el7.x86_64.rpm](http://pan.gridsum.com/index.php/s/16yxZYdBRZro86M)，
将文件上传至服务器，执行如下命令
```bash
   sudo yum -y  install /opt/docker-ce-19.03.12-3.el7.x86_64.rpm
   ```

#### 3、更改配置
消除docker安装后的网络警告
```bash
echo -e "net.bridge.bridge-nf-call-ip6tables = 1 \nnet.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.conf
sysctl -p
```

设置私服ip(docker默认使用https方式访问私服，添加如下配置是为了能用http访问私服)
> 注意：下面的`insecure-registries`为私服IP，根据各自情况填写
```bash
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "insecure-registries": ["192.168.33.100:5000"] 
}
EOF
```

#### 4、设置docker为服务
```bash
sudo systemctl enable docker
```
#### 5、启动docker
```bash
sudo systemctl start docker
```
#### 6、验证
```bash
sudo docker info
```
会显示类似如下信息，则安装成功
```bash
[root@dockerRegistry opt]# docker info
Client:
 Debug Mode: false

Server:
 Containers: 1
  Running: 1
  Paused: 0
  Stopped: 0
 Images: 1
 Server Version: 19.03.12
 Storage Driver: overlay2
  Backing Filesystem: xfs
  Supports d_type: true
  Native Overlay Diff: true
 Logging Driver: json-file
 Cgroup Driver: cgroupfs
 Plugins:
  Volume: local
  Network: bridge host ipvlan macvlan null overlay
  Log: awslogs fluentd gcplogs gelf journald json-file local logentries splunk syslog
 Swarm: inactive
 Runtimes: runc
 Default Runtime: runc
 Init Binary: docker-init
 containerd version: 7ad184331fa3e55e52b890ea95e65ba581ae3429
 runc version: dc9208a3303feef5b3839f4323d9beb36df0a9dd
 init version: fec3683
 Security Options:
  seccomp
   Profile: default
 Kernel Version: 3.10.0-957.12.2.el7.x86_64
 Operating System: CentOS Linux 7 (Core)
 OSType: linux
 Architecture: x86_64
 CPUs: 2
 Total Memory: 1.795GiB
 Name: dockerRegistry
 ID: SY6H:5I3E:S5XS:K4TL:6LT5:ZDDU:N2CY:ZUWS:VROA:LPLS:4IIT:EROP
 Docker Root Dir: /var/lib/docker
 Debug Mode: false
 Registry: https://index.docker.io/v1/
 Labels:
 Experimental: false
 Insecure Registries:
  127.0.0.0/8
 Registry Mirrors:
  https://7z5eap9m.mirror.aliyuncs.com/
 Live Restore Enabled: false
```
#### docker服务数据路径
docker安装之后默认的服务数据存放根路径为/var/lib/docker目录下，var目录默认使用的是根分区的磁盘空间；所以这是非常危险的事情；随着我们镜像、启动的容器实例开始增多的时候，磁盘所消耗的空间也会越来越大，所以我们必须要做数据迁移和修改docker服务的默认存储位置路径
##### 1、创建docker容器存放的路径
```bash
mkdir -p /home/data/docker/lib
```
##### 2、编辑Docker配置文件
```bash
mkdir -p /etc/systemd/system/docker.service.d/ 
vim /etc/systemd/system/docker.service.d/devicemapper.conf

[Service]
ExecStart=
ExecStart=/usr/bin/dockerd  --graph=/home/data/docker/lib/
```
##### 3、重启Docker服务
```bash
#docker配置文件重新加载
systemctl daemon-reload
#docker服务重启 
systemctl restart docker
```
##### 5、查看现在容器存放的目录
```bash
docker info | grep "Dir"
```


### 运行docker-registry私服
> 类似maven私服
#### 1、文件下载
下载网盘文件[images.tar.gz、script.tar](http://pan.gridsum.com/index.php/apps/files/?dir=/docker%E5%AE%89%E8%A3%85&fileid=1835584)
#### 2、启动私服
- 将下载的文件`images.tar.gz`、`script.tar`上传至将要运行私服的服务器路径下，解压`script.tar`
```bash
# 解压脚本
tar -xf script.tar
```
打开`env.sh`文件，进行必要配置
- `REGISTRY_HOST`修改为当前服务器的ip(其他服务器可访问到的)
- `REGISTRY_STORAGE`表示私服数据存储的路径，可按照需要修改(note：请注意修改该路径)
授予脚本可执行权限后执行脚本，运行私服
```bash
chmod a+x load-images.sh && ./load-images.sh
```

>如果有其他镜像也需要上传至私服，可参考文档[私服相关](docker-registry/README.md)


### docker-swarm 初始化
#### 1、swarm初始化
在任意一台服务器上执行如下命令，ip为执行该命令服务器，注意ip需要根据情况修改
```bash
sudo docker swarm init --advertise-addr 192.168.35.101
```

#### 2、执行效果类似下面所示
```bash
[vagrant@ddc1 ~]$ sudo docker swarm init --advertise-addr=192.168.35.101
Swarm initialized: current node  (ilgubzc1uklqalpzoq0t7mhcm) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-28jew2i7wjib6obtmpsubaz8krvxd0zqj7g3bbaidwh7ni1s11-bud9m3xf5j73g8yibwyynm8d3 192.168.35.101:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.

```
#### 3、加入swarm
在其余docker实例上执行一下命令加入swarm集群(直接复制manager节点初始化时生成的加入swarm命令)
```bash
  sudo  docker swarm join --token SWMTKN-1-28jew2i7wjib6obtmpsubaz8krvxd0zqj7g3bbaidwh7ni1s11-bud9m3xf5j73g8yibwyynm8d3 192.168.35.101:2377
```
> 由于swarm初始化时生成的加入集群的token与ip不同，注意worker节点加入swarm集群时的命令

#### 4、成功加入swarm集群后会提示如下信息
```bash
[vagrant@ddc3 ~]$ sudo  docker swarm join --token SWMTKN-1-28jew2i7wjib6obtmpsubaz8krvxd0zqj7g3bbaidwh7ni1s11-bud9m3xf5j73g8yibwyynm8d3 192.168.35.101:2377
This node joined a swarm as a worker.
```
#### 5、在步骤1的服务器上进行验证
```bash
sudo docker node ls
```
```bash
[root@ddc2 data]# docker node ls
ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
0ud5um1ppr727eyoik7b05u1w     ddc1                Ready               Active                                  19.03.12
pqp1b5d4f6dcj6coykld44svs *   ddc2                Ready               Active              Leader              19.03.12
x78f2e8w0w7ce9340i5l1ogu3     ddc3                Ready               Active                                  19.03.12

```

#### 6、将其余两台服务器提升为manager节点
```bash
#在步骤1的服务器上执行如下命令，hostname为5步骤中 HOSTNAME 列
docker node promote hostname
```
执行结果如下所示
```bash
[vagrant@ddc1 ~]$ sudo docker node promote ddc2
Node ddc2 promoted to a manager in the swarm.
[vagrant@ddc1 ~]$ sudo docker node promote ddc3
Node ddc3 promoted to a manager in the swarm.
```

### Note
#### 非root用户加入docker用户组省去sudo
```bash
usermod -aG docker xxxx
#需退出当前用户登录状态以让权限生效
```


## 启动基础服务
### 1、上传文件
将本项目中`deploy-cluster`文件夹下的所有文件都上传至任意一台服务器上

### 2、授予可执行权限
```bash
chmod -R a+x ./*.sh
```
### 3、根据需求修改env.sh
对env.sh进行一些必要参数的修改，具体参数见env.sh文件注释


### 4、服务启动
命令格式：
```bash
./base-server.sh command [serverName]
```
- 启动集群命令说明：
    - command：为start/stop，必填参数
        - start：启动/更新服务
        - stop：停止服务
    - serverName：服务名，选填，为空时启动所有服务
    - example：
        - 启动zookeeper：`./base-server.sh start zookeeper`
        - 启动kafka：`./base-server.sh start kafka`
        - 启动所有服务：`./base-server.sh start all`(all可填可不填)
    - note：
        - `serverName` 的范围为env.sh的参数ALL_SERVICES
        - 服务启动过程中，可以使用`docker service logs -f  <serviceName>` 查看启动日志;serviceName可以运行命令`docker service ls`获取
        
        
>如果需要添加新的服务，需要创建一个名称为新服务的文件夹，将放入docker-stack.yml配置文件，并且在`env.sh`的变量ALL_SERVERS后追加新服务，并且添加对应的xx_image(镜像名称)、xx_nums(docker-stack.yml中包含的服务数量)<br/>

#### 服务说明
##### zookeeper 
可在docker-stack.yml文件中的对应服务中添加envrioment修改服务的配置
`ZOO_TICK_TIME`
`ZOO_INIT_LIMIT`
`ZOO_SYNC_LIMIT`
`ZOO_MAX_CLIENT_CNXNS`
zookeeper配置修改详细地址：https://github.com/docker-library/docs/tree/master/zookeeper
##### kafka
可在docker-stack.xml文件中的对应服务中添加环境变量修改server.properties的配置，环境变量名称为server.properties中对应配置的key，所有字母大写，'.'转换为'_',并且添加前缀`KAFKA_'
> 例如：需要修改 num.io.threads=8 ->  KAFKA_NUM_IO_THREADS=8。

详细文档地址：https://github.com/wurstmeister/kafka-docker

##### redis
- 当reids启动模式为redis服务器时，使用配置文件路径为 /data/redis.conf
- 当redis启动模式为sentinel服务器时，使用配置文件路径为 /data/sentinel.conf
- 可在env.sh修改redis的密码
- 可在环境变量中修改的配置项为

| 环境变量中的名称| 属性名称 |  默认值 | 所属文件|
| :-----: | :---: | :-----:|:---:|
| BIND_ID  |  bind | 0.0.0.0 | redis.conf |
| SLAVEOF  |  slaveof| null | redis.conf|
| PASSWORD | requirepass/masterauth | null | redis.conf|
| PORT     | port | 6379/26379 | redis.conf/sentinel.conf |
| SENTINEL_MASTER| sentinel monitor mymaster | null | sentinel.conf |
| SENTINEL_DOWN_AFTER|sentinel down-after-milliseconds mymaster|30000|sentinel.conf|
| SENTINEL_PARALLEL_SYNCS|sentinel parallel-syncs mymaster|1|sentinel.conf|
| SENTINEL_FAILOVER_TIMEOUT| sentinel failover-timeout mymaster| 180000|sentinel.conf|
>修改redis相关配置时，如果环境边变量中包含则在环境变量中修改，否则修改redis文件夹下对应的redis.conf、sentinel配置文件，并重新构建镜像
>enviroment修改的参数将优先于修改配置文件

#### mongodb
如果需要修改mongodb的服务参数，可在docker-stack.yml中的属性`entrypoint`后添加参数，详细请看mongod --help参数列表
>env.sh中可修改集群初始的管理员账号/密码


#### nifi
- 启动nifi之前必须先启动zookeeper，nifi才能成功启动
- 启动nifi之后必须启动nginx，否则将无法访问nifi提供的服务
- env.sh文件中提供了nifi的管理员密码(账号默认为admin)

####nginx
nginx为外部访问nifi必备组件，必须在构建nifi之后才能构建nginx镜像。



## 启动微服务
> 微服务可部署在worker节点中，只需要将新的docker实例加入swarm就可以，将deploy-cluster/apps/docker-stack.xml中的注释解开，
> ddc中的服务即可只部署到worker节点上

### 4、服务启动
命令格式：
```bash
cd /opt/docker-cluster
./micro-server.sh command [projectName]
```
- 启动微服务命令说明：
    - command：为start/stop，必填参数
        - start：启动/更新服务
        - stop：停止服务
    - projectName：项目名，选填，为空时启动`docker-cluster/apps/`目录下所有的`.jar`包
    - example：
        - 启动register-center：`./micro-server.sh start register-center`
        - 启动所有服务：`./micro-server.sh start all`(all可填可不填)
   
     
#### Note：
1、将需要运行的jar包放到`docker-cluster/apps/`文件夹下
2、运行命令，如 './micro-server.sh start spring-web' 启动/更新spring-web.jar服务 
3、运行命令，如 './micro-server.sh stop spring-web'  停止spring-web.jar服务
>Note：<br/>
>1、启动微服务的名称与jar包的文件名去除`.jar`后一致(如启动spring-web.jar 命令为 ./micro-server.sh start spring-web.jar)<br/>
>2、jar包必须放到`docker-cluster/apps/`文件夹下<br/>
>3、环境变量MICRO_SERVER_COMMANDS(env.sh中)会追加到对应的命令行中，例如设置
>`MICRO_SERVER_COMMANDS='spring-web1="--server.port=8080" spring-web2="--server.port=9090"'`，
>启动 spring-web1、spring-web2服务时，最终执行的java命令为: <br/>
>`java -jar spring-web1 --server.port=8080` <br/>
>`java -jar spring-web2 --server.port=9090` <br/>
>4、设置env.sh中的变量`MICRO_SERVER_COMMANDS`请特别注意格式：<br/>
>`MICRO_SERVER_COMMANDS='serverName1="xxx"  serverName2="xxx" serverName3="xxx"'`<br/>
>注意单引号与双引号！！！ <br/>
>6、可以添加micro-server/docker-stack.yml中的environment变量来修改jvm的启动参数，格式为JVM_ARG_([0-9])+。
>在运行java命令时，会遍历环境变量，从中获取 JVM_ARG_([0-9])+ 格式的参数，并拼接到java启动命令中。
>例如有参数： JVM_ARG_1="-Xmx512m"、JVM_ARG_2="-Xms512m"、JVM_ARG_3="-XX:+UseConcMarkSweepGC"，
>容器启动时会运行命令 `java -Xmx512m -Xms512m -jar xx.jar`



## 前端
镜像运行时，会将`frontend.tar`解压到路径`/opt/`文件夹下，读取`conf.d`文件夹中的配置文件。
因此只需要响应的修改这2个文件的内容即可；<br/>
在配置文件中配置了对应的端口后，还需要在`frontend/docker-stack.yml`配置文件项`ports`中映射对应的端口。<br/>
例如，配置文件为
```bash
#frontend/conf.d/frontend.conf
server {
        listen     10005;
        server_name  8002test;


        location ^~ /center/ {
                alias /opt/frontend/center_test/dist/;
                index  index.html index.htm;
        }

        location ^~ /energy/ {
                alias /opt/frontend/energy_test/dist/;
                index  index.html index.htm;
        }

        location ^~ /ddc/ {
                alias /opt/frontend/ddc_test/dist/;
                index  index.html index.htm;
        }
        location ^~ /equip/ {
                alias /opt/frontend/equip_test/dist/;
                index  index.html index.htm;
        }

        location ^~ /wisdom/ {
                alias /opt/frontend/wisdom_test/dist/;
                index  index.html index.htm;
        }

    }
```
frontend.tar解压后为
```bash
/opt/frontend/center_test/
/opt/frontend/energy_test/
/opt/frontend/ddc_test/
/opt/frontend/equip_test/
/opt/frontend/wisdom_test/
```
在`docker-stack.yml`配置文件中的`ports`项必须对端口10005做映射，以供外网访问


## 配置相关
- **zookeeper**:zoo1:2181，zoo2:2181，zoo3:2181
- **kafka**:kafka1:9092，kafka2:9092，kafka3:9092
- **mongodb**:mongodb1:27017，mongodb2:27017，mongodb3:27017
- **redis**:redis1:6379，redis2:6379，redis3:6379，sentinel1:26379，sentinel2:26379，sentinel3:26379
- **mysql**：mysql:3306
- **nifi**:nifi1，nifi2，nifi3
需要密码的都在env.sh配置文件中，按照说明做相应修改即可


