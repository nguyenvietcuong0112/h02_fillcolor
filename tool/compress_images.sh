#!/bin/bash
# Compress PNG images using pngquant (lossy compression)

IMAGES_DIR="assets/images"

echo "🎨 Compressing PNG images with pngquant..."
echo "Directory: $IMAGES_DIR"
echo ""

# Check if pngquant is installed
if ! command -v pngquant &> /dev/null; then
    echo "❌ pngquant not found!"
    echo "Install with: brew install pngquant"
    exit 1
fi

# Count files
total_files=$(find "$IMAGES_DIR" -maxdepth 1 -name "*.png" | wc -l | tr -d ' ')
echo "Found $total_files PNG files"
echo ""

if [ "$total_files" -eq 0 ]; then
    echo "No PNG files found!"
    exit 0
fi

total_original=0
total_compressed=0

# Process each PNG file
for img in "$IMAGES_DIR"/*.png; do
    if [ -f "$img" ]; then
        filename=$(basename "$img")
        echo "Processing: $filename"
        
        # Get original size
        original_size=$(stat -f%z "$img")
        total_original=$((total_original + original_size))
        original_kb=$(echo "scale=1; $original_size / 1024" | bc)
        
        # Compress with pngquant (quality 65-80)
        pngquant --quality=65-80 --force --ext .png "$img" 2>/dev/null
        
        # Get new size
        new_size=$(stat -f%z "$img")
        total_compressed=$((total_compressed + new_size))
        new_kb=$(echo "scale=1; $new_size / 1024" | bc)
        
        # Calculate reduction
        if [ "$original_size" -gt 0 ]; then
            reduction=$(echo "scale=1; (($original_size - $new_size) * 100) / $original_size" | bc)
            echo "  ${original_kb}KB → ${new_kb}KB (${reduction}% reduction)"
        fi
        
        echo ""
    fi
done

# Summary
echo "=================================================="
echo "✅ Compression complete!"

if [ "$total_original" -gt 0 ]; then
    total_original_mb=$(echo "scale=2; $total_original / 1024 / 1024" | bc)
    total_compressed_mb=$(echo "scale=2; $total_compressed / 1024 / 1024" | bc)
    total_reduction=$(echo "scale=1; (($total_original - $total_compressed) * 100) / $total_original" | bc)
    echo "Total size: ${total_original_mb}MB → ${total_compressed_mb}MB"
    echo "Total reduction: ${total_reduction}%"
fi
