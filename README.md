### 说明
> 本文档以3台centos7服务器为示例，三台服务器的基本信息为
           
  | 主机名 |  IP | swarm节点属性|
  | :-----: | :---: | :-----:|
  | ddc1  |  192.168.35.101 | manager |
  | ddc2  |  192.168.35.102 | manager   |
  | ddc3  |  192.168.35.103 | manager   |

## 准备工作
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
firewall-cmd --reload
```

### openssl
```bash
yum -y install openssl
yum -y install openssl-devel
```

### docker
#### 1、卸载存留的docker
```bash
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
```
#### 2、安装必要依赖
```bash
sudo yum install -y yum-utils \
    device-mapper-persistent-data \
    lvm2
```

#### 3、设置yum源
```bash
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

#### 4、安装docker
```bash
sudo yum install -y docker-ce docker-ce-cli containerd.io
```
#### 5、配置docker国内镜像，加快镜像下载速度
```bash
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["http://hub-mirror.c.163.com"]
}
EOF
```
>国内加速地址列表：<br/>
> Docker中国区官方镜像:
> https://registry.docker-cn.com <br/>
> 网易:
> http://hub-mirror.c.163.com<br/>
> ustc:
> https://docker.mirrors.ustc.edu.cn<br/>
> 中国科技大学:
> https://docker.mirrors.ustc.edu.cn<br/>
 
  
#### 6、设置docker为服务
```bash
sudo systemctl enable docker
```

#### 7、启动docker
```bash
sudo systemctl start docker
```
#### 8、验证
```bash
sudo docker run hello-world
```
会显示类似如下信息
```bash
[vagrant@ddc2 ~]$ sudo docker run hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
0e03bdcc26d7: Pull complete
Digest: sha256:d58e752213a51785838f9eed2b7a498ffa1cb3aa7f946dda11af39286c3db9a9
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/

```

### 安装docker-registry 私服
选取一台服务器作为registry容器运行的宿主机，并修改**每台**docker服务器的配置 /etc/docker/daemon.json
例如：服务器ddc3(192.168.35.103)作为私服，端口5000为registry容器暴露服务的端口
```json 
vi /etc/docker/daemon.json

{
  "insecure-registries": ["192.168.35.103:5000"]  
}
```
在该服务器上运行下面的命令启动私服
```bash
docker run -d --name registry -p 5000:5000 \
-v /usr/local/docker/registry-image/:/tmp/registry \
--restart=always registry
```

给镜像打标签
```bash
docker tag redis:5.0.9 192.168.35.103:5000/redis:5.0.9
```
将镜像推送至私服
```bash
docker push 192.168.35.103:5000/redis:5.0.9
```
查看私服镜像列表
```bash
#浏览器访问
http://192.168.35.103:5000/v2/_catalog
```
查看某个镜像具体版本
```bash
http://192.168.35.103:5000/v2/image/tags/list
```
[本地私服搭建步骤](./docker-registry/README.md)


### docker-swarm 初始化
#### 1、在ddc1服务器上执行如下命令
```bash
sudo docker swarm init --advertise-addr ddc1-ip
```

#### 2、执行效果类似下面所示
```bash
[vagrant@ddc1 ~]$ sudo docker swarm init --advertise-addr=192.168.35.101
Swarm initialized: current node (ilgubzc1uklqalpzoq0t7mhcm) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-28jew2i7wjib6obtmpsubaz8krvxd0zqj7g3bbaidwh7ni1s11-bud9m3xf5j73g8yibwyynm8d3 192.168.35.101:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.

```
#### 3、在ddc2、ddc3上执行类似命令加入swarm集群，直接复制manager节点初始化时生成的加入swarm语句
```bash
  sudo  docker swarm join --token SWMTKN-1-28jew2i7wjib6obtmpsubaz8krvxd0zqj7g3bbaidwh7ni1s11-bud9m3xf5j73g8yibwyynm8d3 192.168.35.101:2377
```
> 由于swarm初始化时生成的加入集群的token与ip不同，注意worker节点加入swarm集群时的命令

#### 4、成功加入swarm集群后会提示如下信息
```bash
[vagrant@ddc3 ~]$ sudo  docker swarm join --token SWMTKN-1-28jew2i7wjib6obtmpsubaz8krvxd0zqj7g3bbaidwh7ni1s11-bud9m3xf5j73g8yibwyynm8d3 192.168.35.101:2377
This node joined a swarm as a worker.
```
#### 5、在ddc1服务器上进行验证
```bash
sudo docker node ls
```

#### 6、将ddc2、ddc3服务器提升为manager节点
```bash
#在192.168.35.101服务器上执行如下命令
docker node promote <node>
```
执行结果如下所示
```bash
[vagrant@ddc1 ~]$ sudo docker node promote ddc2
Node ddc2 promoted to a manager in the swarm.
[vagrant@ddc1 ~]$ sudo docker node promote ddc3
Node ddc3 promoted to a manager in the swarm.
```

#### 7、为3台服务器打标签
```bash
sudo docker node update --label-add nodename=swarm1 ddc1

sudo docker node update --label-add nodename=swarm2 ddc2

sudo docker node update --label-add nodename=swarm3 ddc3
```


### Note
#### 非root用户加入docker用户组省去sudo
```bash
usermod -aG docker xxxx
#需退出当前用户登录状态以让权限生效
```


## 项目中脚本的使用
### 新建文件夹，将本项目所有文件都放入其中
```bash
# 例如
mkdir /opt/docker-clsuter
```
### 授予可执行全选
```bash
chmod -R a+x /opt/docker-cluster/
```
### 根据需求修改env.sh
对env.sh进行一些必要参数的修改

### 启动集群
```bash
cd /opt/docker-cluster
./base-server.sh start [serverName]
```
> 启动集群命令说明：
>第一个参数：start/stop 部署集群/停止集群
>
>第二个参数[可选]：服务的名称，可以为 zookeeper、kafka、mongodb、redis、nifi、nginx，如果没有则启动所有服务

>文件说明：env.sh启动过程中的参数配置，详情请看env.sh文件
>
>服务启动过程中，可以使用docker service logs -f  <服务名> 查看启动日志

- 如果需要添加新的服务，需要创建一个名称为新服务的文件夹，将放入docker-stack.yml配置文件，并且在`env.sh`的变量ALL_SERVERS后追加新服务，并且添加对应的xx_image(镜像名称)、xx_nums(docker-stack.yml中包含的服务数量)
- 如果构建该服务需要执行一些操作时，在其中放入名称为`post-handler.sh`的可执行脚本即可

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
nginx为外部访问nifi必备组件，必须在构建nifi之后才能构建nginx镜像