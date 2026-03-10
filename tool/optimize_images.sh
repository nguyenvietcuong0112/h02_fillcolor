#!/bin/bash
# Script to optimize PNG images using sips (built-in macOS tool)

IMAGES_DIR="assets/images"
BACKUP_DIR="$IMAGES_DIR/backup_original"
MAX_SIZE=1024

echo "🎨 Optimizing PNG images..."
echo "Directory: $IMAGES_DIR"
echo ""

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Count files
total_files=$(find "$IMAGES_DIR" -maxdepth 1 -name "*.png" | wc -l | tr -d ' ')
echo "Found $total_files PNG files"
echo ""

if [ "$total_files" -eq 0 ]; then
    echo "No PNG files found!"
    exit 0
fi

processed=0
total_original=0
total_optimized=0

# Process each PNG file
for img in "$IMAGES_DIR"/*.png; do
    if [ -f "$img" ]; then
        filename=$(basename "$img")
        echo "Processing: $filename"
        
        # Backup original if not already backed up
        if [ ! -f "$BACKUP_DIR/$filename" ]; then
            cp "$img" "$BACKUP_DIR/$filename"
            echo "  ✓ Backed up to backup_original/"
        fi
        
        # Get original size
        original_size=$(stat -f%z "$img")
        total_original=$((total_original + original_size))
        
        # Get image dimensions
        width=$(sips -g pixelWidth "$img" | grep pixelWidth | awk '{print $2}')
        height=$(sips -g pixelHeight "$img" | grep pixelHeight | awk '{print $2}')
        
        # Resize if needed
        if [ "$width" -gt "$MAX_SIZE" ] || [ "$height" -gt "$MAX_SIZE" ]; then
            echo "  Resizing: ${width}x${height} → max ${MAX_SIZE}px"
            sips -Z "$MAX_SIZE" "$img" > /dev/null 2>&1
        fi
        
        # Get new size
        new_size=$(stat -f%z "$img")
        total_optimized=$((total_optimized + new_size))
        
        # Calculate reduction
        if [ "$original_size" -gt 0 ]; then
            reduction=$(echo "scale=1; (($original_size - $new_size) * 100) / $original_size" | bc)
            original_kb=$(echo "scale=1; $original_size / 1024" | bc)
            new_kb=$(echo "scale=1; $new_size / 1024" | bc)
            echo "  Size: ${original_kb}KB → ${new_kb}KB (${reduction}% reduction)"
        fi
        
        processed=$((processed + 1))
        echo ""
    fi
done

# Summary
echo "=================================================="
echo "✅ Optimization complete!"
echo "Files processed: $processed/$total_files"

if [ "$total_original" -gt 0 ]; then
    total_original_kb=$(echo "scale=1; $total_original / 1024" | bc)
    total_optimized_kb=$(echo "scale=1; $total_optimized / 1024" | bc)
    total_reduction=$(echo "scale=1; (($total_original - $total_optimized) * 100) / $total_original" | bc)
    echo "Total size: ${total_original_kb}KB → ${total_optimized_kb}KB"
    echo "Total reduction: ${total_reduction}%"
fi

echo ""
echo "Original files backed up to: $BACKUP_DIR"
