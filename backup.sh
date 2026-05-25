#!/bin/bash

# 1. Ensure we are executing from the exact directory where the script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

DATE=$(date +%Y%m%d_%H%M%S)
# 2. SAVE OUTSIDE: Generate the backup file in the PARENT directory (e.g., ~)
BACKUP_NAME="../hexo_backup_$DATE.tar.gz"

echo "⏳ Starting backup of core Hexo data..."

# 3. Core logic: Archive flat files, explicitly omitting trash and cache
tar -czvf "$BACKUP_NAME" \
    --exclude="blog/node_modules" \
    --exclude="blog/public" \
    --exclude="blog/.db.json" \
    --exclude="unusedpics" \
    --exclude="*.tar.gz" \
    docker-compose.yml *.sh blog/

echo "✅ Backup completed!"
echo "📦 Backup file generated at: $(readlink -m "$BACKUP_NAME")"
