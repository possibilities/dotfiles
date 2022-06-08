#!/bin/sh

set -e

if [ -z "${BACKUP_NAME}" ]; then
  echo BACKUP_NAME environment variable is required
  exit 1
fi

read -p "AWS_ACCESS_KEY_ID: " AWS_ACCESS_KEY_ID
read -p "AWS_SECRET_ACCESS_KEY: " AWS_SECRET_ACCESS_KEY

export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}

if [ -z "${AWS_ACCESS_KEY_ID}" ]; then
  echo AWS_ACCESS_KEY_ID is required
  exit 1
fi

if [ -z "${AWS_SECRET_ACCESS_KEY}" ]; then
  echo AWS_SECRET_ACCESS_KEY is required
  exit 1
fi

duplicity \
  --force \
  "s3:///mike-backups-4c256a80-e412-11ec-94cf-5f96b9da8566/${BACKUP_NAME}" \
  /home/mike
