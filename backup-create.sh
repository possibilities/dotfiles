#!/bin/sh

set -e

[ -z "$BACKUP_ROOT_PATH" ] && echo 'BACKUP_ROOT_PATH is required' && exit 1
[ ! -d ${BACKUP_ROOT_PATH} ] && echo "BACKUP_ROOT_PATH does not exist: ${BACKUP_ROOT_PATH}"

rm -rf ${BACKUP_ROOT_PATH}/secrets.tar.gz
tar -cvzf ${BACKUP_ROOT_PATH}/secrets.tar.gz ${HOME}/.zsh_history
