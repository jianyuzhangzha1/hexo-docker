#!/bin/bash

# Define the shell configuration file path (default is .bashrc for Raspberry Pi/Linux)
RC_FILE="$HOME/.bashrc"

# Get the absolute path of the current working directory
CURRENT_DIR=$(pwd)
COMPOSE_FILE="$CURRENT_DIR/docker-compose.yml"

# Define the complete alias command we want to set
ALIAS_CMD="alias hexo='docker compose -f \"$COMPOSE_FILE\" exec hexo-dev npx hexo'"

echo "🔍 Checking the current directory environment..."

# Prerequisite check: Ensure docker-compose.yml exists in the current directory
if [ ! -f "$COMPOSE_FILE" ]; then
    echo "❌ Error: docker-compose.yml not found in the current directory!"
    echo "💡 Please 'cd' into your hexo-docker directory first, then run this script."
    exit 1
fi

echo "✅ Found docker-compose.yml: $COMPOSE_FILE"

# Check if a line starting with 'alias hexo=' already exists in .bashrc
if grep -q "^alias hexo=" "$RC_FILE"; then
    echo "🔄 Existing 'hexo' alias detected. Updating it to point to the current directory..."
    # Use sed to safely delete the old alias line
    sed -i '/^alias hexo=/d' "$RC_FILE"
    # Append the new alias line
    echo "$ALIAS_CMD" >> "$RC_FILE"
else
    echo "➕ No existing 'hexo' alias found. Adding new record..."
    echo "$ALIAS_CMD" >> "$RC_FILE"
fi

echo "🎉 Configuration successful!"
echo "📜 Written configuration: $ALIAS_CMD"
echo "⚠️  Note: The alias will not take effect immediately in the current terminal."
echo "👉 Please run the following command to apply it instantly, or open a new terminal session:"
echo "    source ~/.bashrc"
