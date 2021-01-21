#!/usr/bin/env bash

cd "$(dirname "$0")"

CONFIG_VERSION=$(grep -E "CONFIGURATION_.*_VERSION" Current_Config/Configuration.h | xargs | tr -d ' ')

rm -rf Configurations

rm -rf Updated_Config

mkdir Updated_Config

git clone https://github.com/MarlinFirmware/Configurations.git
#cp -r Config_CP Configurations

cd Configurations

BASE_DIR=config/default

I=0
J=0

declare -a COMMITS=($(git log --oneline $BASE_DIR/Configuration.h | cut -d' ' -f1))

for commit in "${COMMITS[@]}"
do
I=$((I+1))
VERSION=$(git show $commit:$BASE_DIR/Configuration.h | grep -E "CONFIGURATION_.*_VERSION" | xargs | tr -d ' ')
if [ $CONFIG_VERSION = $VERSION ]; then
J=$I
elif [ $J -ne 0 ]; then
break
fi
done

BASE_COMMIT=${COMMITS[$J]}

git checkout $BASE_COMMIT

git checkout -b autoupdater

cp ../Current_Config/* $BASE_DIR/

git add .

git commit -m "user changes"

USER_COMMIT=$(git log --oneline | head -1 | cut -d' ' -f1)

git rebase origin/HEAD

cp $BASE_DIR/* ../Updated_Config/

cd ..

rm -rf Configurations

grep -E "CONFIGURATION_.*_VERSION" *_Config/Configuration*