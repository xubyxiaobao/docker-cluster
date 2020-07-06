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
### 授予项目中 *.sh可执行权限
```bash

```
