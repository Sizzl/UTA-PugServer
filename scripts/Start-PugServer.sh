#!/bin/bash

MYPUGHOME=~/UTA-PugServer
MYUTHOME=~/ut-server

if [ "$1" != "" ] && [ -f $1/ucc.init ]
then
 pushd $1 >/dev/null
else
 if [ -f $MYUTHOME/ucc.init ]
 then
  pushd $MYUTHOME >/dev/null
 else
  echo "UT server root directory not specified in command line parameter or variable, or ucc.init not found."
  exit 1
 fi
fi

if [ -f $MYPUGHOME/scripts/Update-PugServer.sh ]
then
 /bin/bash $MYPUGHOME/scripts/Update-PugServer.sh
fi

./ucc.init restart &
popd >/dev/null