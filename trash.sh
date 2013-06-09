#! /bin/sh
#使用 trash 代替 rm 命令 
#在/usr/bin/目录创建一个trash文件，之后，只要把”alias rm=trash”放进bashrc就可以了

DATE=`date +%Y%m%d`
TRASH="$HOME/.trash"

# Make sure the dest directionry is exists.
if [ ! -d $TRASH ]; then
    mkdir $TRASH
    if [ ! -z $SUDO_USER ]; then
        chown $SUDO_USER $TRASH
        chgrp $SUDO_GID $TRASH
    fi
fi

if [ ! -d $TRASH/$DATE ]; then
    mkdir $TRASH/$DATE
    if [ ! -z $SUDO_USER ]; then
        chown $SUDO_USER $TRASH/$DATE
        chgrp $SUDO_GID $TRASH/$DATE
    fi
fi

while [ $# -gt 0 ]
do
    if [ `expr substr $1 1 1` = "-" ]; then
        if [ $1 = "--" ]; then
            shift
            break
        fi
        shift
    else
        break
    fi
done
if [ $# -gt 0 ]; then
    mv $* $TRASH/$DATE
fi
