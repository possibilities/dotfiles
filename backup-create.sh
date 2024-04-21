#!/bin/sh

rsync -a --progress --exclude='*/' /home/mike/ /media/veracrypt2/backups/$(date +%Y%m%d)/
rsync -a --progress /home/mike/code /media/veracrypt2/backups/$(date +%Y%m%d)/code
rsync -a --progress /home/mike/.config /media/veracrypt2/backups/$(date +%Y%m%d)/dot-config
rsync -a --progress /home/mike/.var /media/veracrypt2/backups/$(date +%Y%m%d)/dot-var
rsync -a --progress /home/mike/.ssh /media/veracrypt2/backups/$(date +%Y%m%d)/dot-ssh

echo "done creating backup."
