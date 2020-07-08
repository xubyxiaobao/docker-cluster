### 说明
registry是在局域网内部搭建私有的镜像注册中心，从而使无法联网的服务器可以从本机上下载镜像。
本文件夹脚本可以从连接外网的docker服务器上下载必要的基础镜像并压缩为一个压缩文件，将压缩文件传输至无法连接外网的服务器上在骑上运行私服，将必须的基础镜像上传至私服，使内网服务器可以快速、方便的下载镜像。
###Note：
必须修改每台docker服务器上的`/etc/docker/daemon.json`文件夹，使每台服务器可以通过http方式访问到私有注册中心

### 脚本说明
- `env.sh`：设置`save-images.sh`和`load-images.sh`脚本运行过程中的相关变量
 - `SAVE_IMAGES`：需要保存/恢复的基础服务列表
 - `IMAGES_TAR_NAME`：运行`save-iamges.sh`代表生成的压缩文件名称(自动拼接tar.gz)/运行`load-images.sh`时代需要导入镜像库的镜像文件解压包
 - `REGISTRY_HOST`：宿主机的ip
 - `REGISTRY_PORT`：registry服务暴露的端口
 - `REGISTRY_STORAGE`：运行registry容器时数据持久化的映射路径
- `save-images.sh`：在能连接外网的服务器上运行，生成一个包含必须基础镜像文件的压缩包。
- `load-images.sh`：解压缩一个镜像文件压缩包，并将其中的镜像推送至私服

### 执行顺序
1、首先根据环境修改`env.sh`文件中的变量
2、在能连接外网的docker服务器上运行`save-lmages.sh`脚本(注意运行该脚本需要env.sh)，可以得到一个压缩文件，例如image.tar.gz
3、将压缩传输至无法连接外网的、作为registry容器的宿主机上
4、将`load-images.sh`、`env.sh`与压缩文件放于同一目录下，并运行`load-images.sh`脚本
