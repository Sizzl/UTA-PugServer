#!/bin/bash

MYPUGHOME=~/UTA-PugServer
MYUTHOME=~/ut-server

if [ "$1" != "" ] && [ -f $1/ucc64.init ]; then
    pushd $1 >/dev/null
elif [ "$1" != "" ] && [ -f $1/ucc.init ]; then
    pushd $1 >/dev/null
else
    if [ -f $MYUTHOME/ucc64.init ]; then
        pushd $MYUTHOME >/dev/null
    elif [ -f $MYUTHOME/ucc.init ]; then
        pushd $MYUTHOME >/dev/null
    else
        echo "UT server root directory not specified in command line parameter or variable, or ucc.init / ucc64.init not found."
        exit 1
    fi
fi

if [ -f $MYPUGHOME/scripts/Update-PugServer.sh ]; then
    if [ "$1" != "" ]; then
        /bin/bash $MYPUGHOME/scripts/Update-PugServer.sh $1/../
    else
        /bin/bash $MYPUGHOME/scripts/Update-PugServer.sh
    fi
fi

if [ -f ./ucc64.init ]; then
    ./ucc64.init restart &
else
    ./ucc.init restart &
fi
popd >/dev/null
