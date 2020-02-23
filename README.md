[![Docker Image](https://img.shields.io/badge/docker%20image-available-green.svg)](https://hub.docker.com/r/boringcat/wechat/)


**感谢[bestwu](https://github.com/bestwu)提供的[deepin-wine](https://github.com/bestwu/docker-wine)镜像**

在此基础上修改`Dockerfile`与`entrypoint.sh`得到企业微信的docker镜像

---

本镜像基于[深度操作系统](https://www.deepin.org/download/)

### 准备工作

允许所有用户访问X11服务,运行命令:

```bash
    xhost +
```

## 查看系统audio gid

```bash
  getent group audio | cut -d ":" -f3
```

Archlinux 结果：

```bash
995
```

### 运行

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
      - $HOME/wine-WXWork:/home/wechat/.deepinwine/Deepin-WXWork # 可选，用于持久化 例如：更新企业微信 (Beta功能)
    environment:
      - DISPLAY=unix$DISPLAY
      - QT_IM_MODULE=fcitx
      - XMODIFIERS=@im=fcitx
      - GTK_IM_MODULE=fcitx
      - AUDIO_GID=995 # 可选 默认995（archlinux） 主机audio gid 解决声音设备访问权限问题
      - GID=1000 # 可选 默认1000 主机当前用户 gid 解决挂载目录访问权限问题
      - UID=1000 # 可选 默认1000 主机当前用户 uid 解决挂载目录访问权限问题
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
    boringcat/wechat:work
```

### 更新版本
没有测试能否在docker内启动更新，可以选择将wine文件夹挂载出来，然后手动覆盖最新版企业微信  
**注意：** `entrypoint.sh` 内会更新 `/home/wechat/.deepinwine` 的所有权 `chown wechat:wechat /home/wechat/.deepinwine -R`  
**注意2：** 尚未解明deepin-wine在什么条件下会重新解压应用到 `/home/wechat/.deepinwine` 中。如果要挂载 `/home/wechat/.deepinwine` 建议在确保有备份的情况下挂载，或者判断不需要写入权限时以`ro`挂载