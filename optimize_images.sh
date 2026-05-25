#!/bin/bash

IMAGES_DIR="./blog/source/images"
MAX_WIDTH="1200" 
QUALITY="82"     

echo "⏳ Starting image optimization in $IMAGES_DIR ..."

# Prerequisite check: Ensure ImageMagick is installed
if ! command -v mogrify &> /dev/null; then
    echo "❌ Error: ImageMagick (mogrify) is not installed."
    echo "💡 Please run: sudo apt install imagemagick"
    exit 1
fi

if [ ! -d "$IMAGES_DIR" ]; then
    echo "❌ Error: The directory $IMAGES_DIR does not exist."
    exit 1
fi

count=0

# Safely find all JPG and PNG files and process them IN-PLACE
while IFS= read -r -d '' img; do
    mogrify -resize "${MAX_WIDTH}>" -quality "$QUALITY" -strip "$img"
    echo "✅ Optimized: $(basename "$img")"
    ((count++))
done < <(find "$IMAGES_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -print0)

echo "------------------------------------------------------"
echo "🎉 Optimization complete! Processed $count image(s)."
