#!/bin/bash

# Define paths
SOURCE_DIR="./blog/source"
IMAGES_DIR="./blog/source/images" 
TRASH_DIR="./unusedpics"

echo "🔍 Scanning for unused images specifically in $IMAGES_DIR ..."

unused_images=()

if [ ! -d "$IMAGES_DIR" ]; then
    echo "❌ Error: The directory $IMAGES_DIR does not exist."
    exit 1
fi

# Safely find all images ONLY in the IMAGES_DIR
while IFS= read -r -d '' img_path; do
    img_name=$(basename "$img_path")
    
    # Search for this filename in all .md files within the broader SOURCE_DIR
    if ! grep -rq "$img_name" --include="*.md" "$SOURCE_DIR"; then
        echo "🗑️ Unused image: $img_path"
        unused_images+=("$img_path")
    fi
done < <(find "$IMAGES_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" -o -iname "*.svg" \) -print0)

unused_count=${#unused_images[@]}
echo "------------------------------------------------------"

if [ "$unused_count" -eq 0 ]; then
    echo "✅ Scan complete! No unused images found in $IMAGES_DIR."
    exit 0
fi

echo "⚠️  Found $unused_count unused image(s)."
read -p "👉 Type 'all' to move them to the '$TRASH_DIR' directory, or press any other key to cancel: " user_choice

if [ "$user_choice" = "all" ]; then
    echo "📁 Creating directory: $TRASH_DIR..."
    mkdir -p "$TRASH_DIR"
    
    for img in "${unused_images[@]}"; do
        mv "$img" "$TRASH_DIR/"
    done
    echo "✅ Successfully moved $unused_count image(s) to ./$TRASH_DIR/."
else
    echo "🚫 Action cancelled. No files were moved."
fi
