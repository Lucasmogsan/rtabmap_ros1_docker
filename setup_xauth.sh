#!/bin/bash
XAUTH=/tmp/.docker.xauth

if [ ! -f $XAUTH ]; then
    touch $XAUTH
    xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
    chmod 777 $XAUTH
    printf "xauth file created at $XAUTH\n"
else
    printf "xauth file already exists at $XAUTH\n"
    printf "Content of the file (readable format):\n"
    xauth list $DISPLAY
fi