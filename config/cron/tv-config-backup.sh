#!/bin/sh

SOMA_BASE=/var/lib/soma
SOMA_BACKUP=$SOMA_BASE/backup

# Check for sane installation paths
if [ ! -d "$SOMA_BACKUP" ]; then
  echo "Backup directory is missing. Did you install soma correctly?"
  exit
fi

# Backup TV config
/bin/tar cvzf $SOMA_BACKUP/tvheadend-backup-hts-config.tgz /home/hts/.hts

for dir in /home/*     # list directories in the form "/tmp/dirname/"
do
  # Backup Kodi config
  if [ -d "$dir/.kodi" ]; then
    count=$((count + 1))
    /bin/tar cvzf $SOMA_BACKUP/kodi-backup-$count.tgz $dir/.kodi
  fi
done

# Backup soma config
/bin/tar cvzf $SOMA_BACKUP/soma-backup.tgz $SOMA_BASE/config


