FROM bestwu/wine:i386
LABEL maintainer='BoringCat <boringcat@outlook.com>'

RUN echo 'deb https://mirrors.aliyun.com/deepin stable main non-free contrib' > /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends deepin.com.weixin.work && \
    apt-get -y autoremove && apt-get clean -y && apt-get autoclean -y && \
    find /var/lib/apt/lists -type f -delete && \
    find /var/cache -type f -delete && \
    find /var/log -type f -delete && \
    find /usr/share/doc -type f -delete && \
    find /usr/share/man -type f -delete

ENV APP=WXWork \
    AUDIO_GID=995 \
    VIDEO_GID=986 \
    GID=1000 \
    UID=1000

RUN groupadd -o -g $GID wechat && \
    groupmod -o -g $AUDIO_GID audio && \
    groupmod -o -g $VIDEO_GID video && \
    useradd -d "/home/wechat" -m -o -u $UID -g wechat -G audio,video wechat && \
    mkdir /WXWork && \
    chown -R wechat:wechat /WXWork && \
    ln -s "/WXWork" "/home/wechat/WXWork"

VOLUME ["/WXWork", "/HostHome"]

ADD entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]