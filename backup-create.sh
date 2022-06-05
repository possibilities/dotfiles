#!/bin/sh

set -e

duplicity \
  --exclude='/home/mike/.cache' \
  --exclude='/home/mike/.local' \
  --exclude='/home/mike/.vim' \
  --exclude='/home/mike/src' \
  --exclude='/home/mike/code/**/node_modules' \
  --copy-links \
  /home/mike \
  "s3:///mike-backups-4c256a80-e412-11ec-94cf-5f96b9da8566/$(hostname)"
