#!/bin/sh

set -e

[ -z "$BACKUP_ROOT_PATH" ] && echo 'BACKUP_ROOT_PATH is required' && exit 1
[ ! -d ${BACKUP_ROOT_PATH} ] && echo "BACKUP_ROOT_PATH does not exist: ${BACKUP_ROOT_PATH}"

cp -r ${BACKUP_ROOT_PATH}/secrets.tar.gz /tmp
cd /tmp
tar xvzf ./secrets.tar.gz
