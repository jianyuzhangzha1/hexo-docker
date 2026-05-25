#!/bin/bash

# ==========================================
# Setup 'updateblog' Alias Script (Archive Edition)
# ==========================================

echo "⚙️ Initializing 'updateblog' alias configuration..."

# 1. Get the absolute path of the blog/public directory
CURRENT_DIR=$(pwd)
# IMPORTANT: The trailing slash '/' is required for rsync to sync contents
PUBLIC_DIR="$CURRENT_DIR/blog/public/"

if [ ! -d "$CURRENT_DIR/blog" ]; then
    echo "❌ Error: 'blog' directory not found."
    echo "💡 Please ensure you are running this script from inside the 'hexo-docker' directory."
    exit 1
fi

# 2. Prompt the user for the remote destination address
echo ""
echo "🌐 Please enter the remote destination address."
echo "   Format : [username]@[server_ip]:[absolute_path_to_remote_public_folder]"
echo "   Example: root@192.168.1.100:/opt/hexo-web/public/"
echo "------------------------------------------------------"
read -p "👉 Remote Address: " REMOTE_DEST

if [ -z "$REMOTE_DEST" ]; then
    echo "❌ Error: Remote address cannot be empty. Setup aborted."
    exit 1
fi

# 3. Construct the alias command
ALIAS_CMD="alias updateblog='rsync -avzu --progress \"$PUBLIC_DIR\" \"$REMOTE_DEST\"'"

# 4. Write to .bashrc safely with Archiving

# 4. Write to .bashrc safely with Archiving
RC_FILE="$HOME/.bashrc"
CURRENT_TIME=$(date +"%Y-%m-%d %H:%M:%S")

echo ""
echo "🔗 Configuring 'updateblog' alias in $RC_FILE..."

if grep -q "^[[:space:]]*alias updateblog=" "$RC_FILE"; then
    echo "🔄 Existing active 'updateblog' alias detected."
    echo "📦 Archiving the old alias with timestamp..."

    sed -i "s/^[[:space:]]*alias updateblog=.*/# [Archived on $CURRENT_TIME] &/g" "$RC_FILE"
fi

# Append the new active alias
echo "$ALIAS_CMD" >> "$RC_FILE"
