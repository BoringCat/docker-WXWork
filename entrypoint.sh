#!/bin/bash

groupmod -o -g $AUDIO_GID audio
groupmod -o -g $VIDEO_GID video
if [ $GID != $(echo `id -g wechat`) ]; then
    groupmod -o -g $GID wechat
fi
if [ $UID != $(echo `id -u wechat`) ]; then
    usermod -o -u $UID wechat
fi

chown wechat:wechat /WXWork /home/wechat
chown wechat:wechat /home/wechat/.deepinwine -R | true

if [ -f "/home/wechat/.deepinwine/Deepin-$APP/system.reg" ]; then
    REGDPI=$(printf '"LogPixels"=dword:%08x' $DPI)
    sed -i "s/\"LogPixels\"=.*$/$REGDPI/g" /home/wechat/.deepinwine/Deepin-$APP/system.reg
fi

su wechat -c '
echo "启动 $APP"
"/opt/deepinwine/apps/Deepin-$APP/run.sh"
export Timei=0
echo "Timei: "$Timei
while true
do
    export PID=$(pidof WXWork.exe)
    echo "PID: "$PID
    if [ -z $PID ]; then
        if [ $Timei -eq 300 ]; then
            break
        else
            let Timei++
        fi
        sleep 1
    else
        break
    fi
done'

tail --pid=`pidof WXWork.exe` -f /dev/null > /dev/null 2>&1

echo "退出"