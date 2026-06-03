#!/bin/bash

# PostgreSQL Backup Script

BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/thingsboard_backup_$TIMESTAMP.sql"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

echo "Creating backup: $BACKUP_FILE"

# Execute backup
docker exec water-meter-postgres pg_dump -U thingsboard -d thingsboard > "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo "✓ Backup created successfully"
    echo "File: $BACKUP_FILE"
    echo "Size: $(du -h $BACKUP_FILE | cut -f1)"
else
    echo "✗ Backup failed"
    exit 1
fi
