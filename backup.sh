#!/bin/sh

# Paths
LOCAL_HOST="davidchu@david-home-ubuntu"
LOCAL_URL="david-home-ubuntu"
UPLOAD_LOCATION="/media/davidchu/Data"
BACKUP_PATH="/media/davidchu/Backup"
REMOTE_HOST="davidchu@david-remote"
REMOTE_BACKUP_PATH="/media/davidchu/Backup"
LOCAL_DISK="/dev/sdb"
BACKUP_DISK="/dev/sda"
REMOTE_BACKUP_DISK="/dev/sda"

### Local

# Backup Immich database
docker exec -t immich_postgres pg_dumpall --clean --if-exists --username=postgres > "$UPLOAD_LOCATION"/database-backup/immich-database.sql
# For deduplicating backup programs such as Borg or Restic, compressing the content can increase backup size by making it harder to deduplicate. If you are using a different program or still prefer to compress, you can use the following command instead:
# docker exec -t immich_postgres pg_dumpall --clean --if-exists --username=<DB_USERNAME> | /usr/bin/gzip --rsyncable > "$UPLOAD_LOCATION"/database-backup/immich-database.sql.gz

### Append to local Borg repository
borg create "$BACKUP_PATH/immich-borg::{now}" "$UPLOAD_LOCATION" --exclude "$UPLOAD_LOCATION"/thumbs/ --exclude "$UPLOAD_LOCATION"/encoded-video/
borg prune --keep-weekly=4 --keep-monthly=3 "$BACKUP_PATH"/immich-borg
borg compact "$BACKUP_PATH"/immich-borg

### Append to remote Borg repository
borg create "$REMOTE_HOST:$REMOTE_BACKUP_PATH/immich-borg::{now}" "$UPLOAD_LOCATION" --exclude "$UPLOAD_LOCATION"/thumbs/ --exclude "$UPLOAD_LOCATION"/encoded-video/
borg prune --keep-weekly=4 --keep-monthly=3 "$REMOTE_HOST:$REMOTE_BACKUP_PATH"/immich-borg
borg compact "$REMOTE_HOST:$REMOTE_BACKUP_PATH"/immich-borg

### Push borg stats to Grafana Alloy, counting down from port 9999. See alloy/config.alloy
borg info $BACKUP_PATH/immich-borg --last 1 --json | curl http://localhost:9999/loki/api/v1/raw -XPOST -H "Content-Type: application/json" -d @-
ssh $REMOTE_HOST -t "borg info $REMOTE_BACKUP_PATH/immich-borg --last 1 --json | curl http://$LOCAL_URL:9998/loki/api/v1/raw -XPOST -H 'Content-Type: application/json' -d @-"

### Push disk stats to Grafana Alloy, counting down from port 9999. See alloy/config.alloy
smartctl -a -j $LOCAL_DISK | curl http://localhost:9997/loki/api/v1/raw -XPOST -H "Content-Type: application/json" -d @-
smartctl -a -j $BACKUP_DISK | curl http://localhost:9996/loki/api/v1/raw -XPOST -H "Content-Type: application/json" -d @-
ssh $REMOTE_HOST -t "sudo smartctl -a -j $BACKUP_DISK | curl http://$LOCAL_URL:9995/loki/api/v1/raw -XPOST -H 'Content-Type: application/json' -d @-"

### Push immich server size to Grafana.
curl http://localhost:2283/api/server/storage?apiKey=lAtOVA7y6VrlyKrmgqdCoLxRtfsVv8YXOJqbmqrs | curl http://localhost:9994/loki/api/v1/raw -XPOST -H "Content-Type: application/json" -d @-
