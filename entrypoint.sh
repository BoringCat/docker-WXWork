#!/bin/bash

if [ "$DEBUG" -eq "1" ]; then
    set -xe
fi

[ -z "$WAIT_FOR_SLEEP" ] && WAIT_FOR_SLEEP=1

checkPid() {
    tail --pid=$1 -f /dev/null > /dev/null 2>&1
    sleep $WAIT_FOR_SLEEP
    [ ! -z "`pidof WXWork.exe`" ] && checkPid `pidof WXWork.exe`
}

groupmod -o -g $AUDIO_GID audio
groupmod -o -g $VIDEO_GID video
[ $GID != $(echo `id -g wechat`) ] && groupmod -o -g $GID wechat
[ $UID != $(echo `id -u wechat`) ] && usermod -o -u $UID wechat

chown wechat:wechat /WXWork /home/wechat
chown wechat:wechat /home/wechat/.deepinwine -R | true

if [ -f "/home/wechat/.deepinwine/Deepin-$APP/system.reg" ]; then
    REGDPI=$(printf '"LogPixels"=dword:%08x' $DPI)
    sed -i "s/\"LogPixels\"=.*$/$REGDPI/g" /home/wechat/.deepinwine/Deepin-$APP/system.reg
fi

CMD=""
if [[ "$@" != "" ]]
then
    CMD="-u "$@
fi

su wechat -c "
echo '启动 $APP'
/opt/deepinwine/apps/Deepin-$APP/run.sh $CMD
export Timei=0
while true
do
    export PID=\$(pidof WXWork.exe)
    if [ -z \$PID ]; then
        if [ \$Timei -eq 300 ]; then
            break
        else
            let Timei++
        fi
        sleep $WAIT_FOR_SLEEP
    else
        break
    fi
done"

checkPid `pidof WXWork.exe`

echo "退出"