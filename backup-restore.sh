#!/bin/sh

set -e

if [ -z "${BACKUP_NAME}" ]; then
  echo BACKUP_NAME environment variable is required
  exit 1
fi

# * Zsh history
# * Slack creds
# * Browser meta
# * Lab creds

duplicity \
  --force \
  --file-to-restore \
  .private_environment \
  "s3:///mike-backups-4c256a80-e412-11ec-94cf-5f96b9da8566/${BACKUP_NAME}" \
  /home/mike/.private_environment

duplicity \
  --force \
  --file-to-restore \
  .ssh/id_ed25519 \
  "s3:///mike-backups-4c256a80-e412-11ec-94cf-5f96b9da8566/${BACKUP_NAME}" \
  /home/mike/.ssh/id_ed25519

duplicity \
  --force \
  --file-to-restore \
  .ssh/id_ed25519.pub \
  "s3:///mike-backups-4c256a80-e412-11ec-94cf-5f96b9da8566/${BACKUP_NAME}" \
  /home/mike/.ssh/id_ed25519.pub

duplicity \
  --force \
  --file-to-restore \
  .gist \
  "s3:///mike-backups-4c256a80-e412-11ec-94cf-5f96b9da8566/${BACKUP_NAME}" \
  /home/mike/.gist

duplicity \
  --force \
  --file-to-restore \
  .gist-vim \
  "s3:///mike-backups-4c256a80-e412-11ec-94cf-5f96b9da8566/${BACKUP_NAME}" \
  /home/mike/.gist-vim
