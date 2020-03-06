[![Docker Image](https://img.shields.io/badge/docker%20image-available-green.svg)](https://hub.docker.com/r/boringcat/wechat/)


**感谢[bestwu](https://github.com/bestwu)提供的[deepin-wine](https://github.com/bestwu/docker-wine)镜像**

在此基础上修改`Dockerfile`与`entrypoint.sh`得到企业微信的docker镜像

---

本镜像基于[深度操作系统](https://www.deepin.org/download/)

## 更新版本
### 2020/03/06  
  * 匹配了HIDPI, 只需要在 environment 中传入 DPI=%d  
  目前能做到持久化企业微信时每次修改DPI的值也能生效
  * 解决了容器关闭慢的问题
  * 挂载 `/home/wechat/.deepinwine/Deepin-WXWork` 时貌似不会覆盖已有文件，可以利用这点更新企业微信
  * 目前无法启动企业微信的更新程序，但是启动时的自动更新可以（？？？？？），如有需要请解压企业微信最新的安装包然后覆盖文件夹内容就行
  * 持久化目前看来不可能，因为企业微信有启动时的自动更新和我的DPI调整脚本


### 2020/02/23  
* 没有测试能否在docker内启动更新，可以选择将wine文件夹挂载出来，然后手动覆盖最新版企业微信  
* 尚未解明deepin-wine在什么条件下会重新解压应用到 `/home/wechat/.deepinwine` 中。如果要挂载 `/home/wechat/.deepinwine` 建议在确保有备份的情况下挂载，或者判断不需要写入权限时以`ro`挂载


## 准备工作

允许所有用户访问X11服务,运行命令:

```bash
    xhost +
```

### 查看系统audio gid

```bash
  getent group audio | cut -d ":" -f3
```

Archlinux 结果：

```bash
995
```

## 运行

### docker-compose

```yml
version: '2'
services:
  wechat:
    image: boringcat/wechat:work
    hostname: WXWork    # 可选，用于好看
    devices:
      - /dev/snd        # 声音设备
    volumes:
      - /tmp/.X11-unix:/tmp/.X11-unix
      - $HOME/WXWork:/WXWork
      - $HOME:/HostHome # 可选，用于发送文件
      - $HOME/wine-WXWork:/home/wechat/.deepinwine/Deepin-WXWork # 可选，用于持久化 例如：更新企业微信
    environment:
      DISPLAY: unix$DISPLAY
      QT_IM_MODULE: fcitx
      XMODIFIERS=@im: fcitx
      GTK_IM_MODULE: fcitx
      AUDIO_GID: 995 # 可选 默认995（Archlinux） 主机audio gid 解决声音设备访问权限问题
      GID: 1000 # 可选 默认1000 主机当前用户 gid 解决挂载目录访问权限问题
      UID: 1000 # 可选 默认1000 主机当前用户 uid 解决挂载目录访问权限问题
      DPI: 96 # 可选 默认96 
```

或

```bash
    docker run -d --name wechat --device /dev/snd \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v $HOME/WXWork:/WXWork \
    -v $HOME:/HostHome \
    -v $HOME/wine-WXWork:/home/wechat/.deepinwine/Deepin-WXWork \
    -e DISPLAY=unix$DISPLAY \
    -e XMODIFIERS=@im=fcitx \
    -e QT_IM_MODULE=fcitx \
    -e GTK_IM_MODULE=fcitx \
    -e AUDIO_GID=`getent group audio | cut -d: -f3` \
    -e GID=`id -g` \
    -e UID=`id -u` \
    -e DPI=96
    boringcat/wechat:work
```