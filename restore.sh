#!/bin/bash

# ==========================================
# Hexo Docker Auto Restore (Anti-Nesting Edition)
# ==========================================

echo "⏳ Starting Hexo restoration process..."

# 1. Find the latest backup file in the current directory
BACKUP_FILE=$(ls -t hexo_backup_*.tar.gz 2>/dev/null | head -n 1)

if [ -z "$BACKUP_FILE" ]; then
    echo "❌ Error: No backup file starting with 'hexo_backup_' found."
    exit 1
fi

BACKUP_PATH="$(pwd)/$BACKUP_FILE"
TARGET_DIR="hexo-docker"
echo "✅ Found latest backup: $BACKUP_FILE"

# 2. ANTI-NESTING CHECK
CURRENT_DIR_NAME=$(basename "$PWD")

if [ "$CURRENT_DIR_NAME" == "$TARGET_DIR" ]; then
    echo "⚠️  You are already inside '$TARGET_DIR'."
    echo "📁 Extracting flat files here to prevent nested directories..."
    tar -xzvf "$BACKUP_PATH" -C .
else
    echo "📁 Creating directory '$TARGET_DIR'..."
    mkdir -p "$TARGET_DIR"
    echo "📦 Extracting flat files into $TARGET_DIR/..."
    tar -xzvf "$BACKUP_PATH" -C "$TARGET_DIR"
    cd "$TARGET_DIR" || exit 1
fi

# 3. Detect Current User ID and Group ID
CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)
echo "👤 Detected current user ID: $CURRENT_UID:$CURRENT_GID"

if [ -f "docker-compose.yml" ]; then
    echo "🔧 Updating user permissions in docker-compose.yml..."
    sed -i '/^[[:space:]]*#*[[:space:]]*user:/d' docker-compose.yml
    sed -i "/container_name:/a \    user: \"$CURRENT_UID:$CURRENT_GID\"" docker-compose.yml
fi

# 4. Detect Target Port from docker-compose.yml
TARGET_PORT="4000"
if [ -f "docker-compose.yml" ]; then
    DETECTED_PORT=$(grep -Eo '[0-9]+:4000' docker-compose.yml | cut -d: -f1 | head -n 1)
    if [ ! -z "$DETECTED_PORT" ]; then
        TARGET_PORT="$DETECTED_PORT"
    fi
fi
echo "🌐 Detected target port mapping: $TARGET_PORT"

# 5. Initialize Docker Environment
echo "⚙️  Installing Node.js dependencies via Docker (this may take a while)..."
docker compose run --rm hexo-dev npm install --registry=[https://registry.npmmirror.com](https://registry.npmmirror.com)

echo "🚀 Starting Hexo service..."
docker compose up -d

# 6. Setup Alias
RC_FILE="$HOME/.bashrc"
CURRENT_DIR=$(pwd)
COMPOSE_FILE="$CURRENT_DIR/docker-compose.yml"
ALIAS_CMD="alias hexo='docker compose -f \"$COMPOSE_FILE\" exec hexo-dev npx hexo'"

echo "🔗 Configuring 'hexo' alias..."
sed -i '/^alias hexo=/d' "$RC_FILE"
echo "$ALIAS_CMD" >> "$RC_FILE"

# ==========================================
echo "🎉 RESTORE COMPLETE! Access URL: http://localhost:$TARGET_PORT"
echo "👉 Action required: Run 'source ~/.bashrc'"
