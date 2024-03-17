#!/bin/bash

MYPUGHOME=~/UTA-PugServer

if [ "$1" != "" ] && [ -d $1 ]
then
 pushd $1 >/dev/null
else
 if [ -d $MYPUGHOME ]
 then
  pushd $MYPUGHOME >/dev/null
 else
  echo "UTA PUG server root directory not specified in command line parameter or variable"
  exit 1
 fi
fi

git fetch -v >~/git-update.log
for file in `git diff HEAD..origin/master --name-status | awk '/^A/ {print $2}'`
do
    rm -f -v -- "$file" >>~/git-update.log
done
for file in `git diff --name-status | awk '/^[CDMRTUX]/ {print $2}'`
do
    git checkout -- "$file" >>~/git-update.log
done
git merge origin/master -v >>~/git-update.log

if [ -f ut-server/System/InstaGibPlus.example.ini ]
then
  cp ut-server/System/InstaGibPlus.example.ini ut-server/System/InstaGibPlus.ini
fi

if [ -f ut-server/System/MapVoteLA.example.ini ]
then
  cp ut-server/System/MapVoteLA.example.ini ut-server/System/MapVoteLA.ini
fi
popd >/dev/null