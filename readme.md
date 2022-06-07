# Dotfiles

Use preseed file with Debian 11.3.0 ISO by pressing `<ESC>` when installer starts

```
auto url=https://raw.githubusercontent.com/possibilities/dotfiles-next/main/preseed.cfg
```

Install everything

```
wget -O - https://raw.githubusercontent.com/possibilities/dotfiles-next/main/bootstrap-system.sh | sh
```

Restore secrets

1. Log into AWS console and create new credentials
2. Run restore script with new credentials
3. Delete new credentials in favor of credentials restored from backup

```
BACKUP_NAME=whitebird \
  AWS_ACCESS_KEY_ID='new-aws-id' \
  AWS_SECRET_ACCESS_KEY='new-aws-key' \
  ./backup-restore.sh
```
