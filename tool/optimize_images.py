#!/usr/bin/env python3
"""
Script to optimize PNG images by resizing and compressing them.
This will reduce file sizes and improve app performance.
"""

import os
import sys
from PIL import Image
from pathlib import Path

def optimize_image(input_path, output_path, max_size=1024, quality=85):
    """
    Optimize a PNG image by resizing and compressing.
    
    Args:
        input_path: Path to input image
        output_path: Path to save optimized image
        max_size: Maximum width/height (will maintain aspect ratio)
        quality: Compression quality (0-100)
    """
    try:
        with Image.open(input_path) as img:
            # Get original size
            original_size = os.path.getsize(input_path)
            width, height = img.size
            
            # Calculate new size maintaining aspect ratio
            if width > max_size or height > max_size:
                if width > height:
                    new_width = max_size
                    new_height = int(height * (max_size / width))
                else:
                    new_height = max_size
                    new_width = int(width * (max_size / height))
                
                img = img.resize((new_width, new_height), Image.Resampling.LANCZOS)
                print(f"  Resized: {width}x{height} → {new_width}x{new_height}")
            
            # Convert to RGB if necessary (for better compression)
            if img.mode in ('RGBA', 'LA'):
                # Create white background
                background = Image.new('RGB', img.size, (255, 255, 255))
                if img.mode == 'RGBA':
                    background.paste(img, mask=img.split()[3])
                else:
                    background.paste(img, mask=img.split()[1])
                img = background
            elif img.mode != 'RGB':
                img = img.convert('RGB')
            
            # Save with optimization
            img.save(output_path, 'PNG', optimize=True, quality=quality)
            
            new_size = os.path.getsize(output_path)
            reduction = ((original_size - new_size) / original_size) * 100
            
            print(f"  Size: {original_size/1024:.1f}KB → {new_size/1024:.1f}KB ({reduction:.1f}% reduction)")
            return True
            
    except Exception as e:
        print(f"  Error: {e}")
        return False

def main():
    # Get the assets/images directory
    script_dir = Path(__file__).parent
    project_dir = script_dir.parent
    images_dir = project_dir / 'assets' / 'images'
    
    if not images_dir.exists():
        print(f"Error: Images directory not found: {images_dir}")
        sys.exit(1)
    
    print("🎨 Optimizing PNG images...")
    print(f"Directory: {images_dir}\n")
    
    # Find all PNG files
    png_files = list(images_dir.glob('*.png'))
    
    if not png_files:
        print("No PNG files found!")
        sys.exit(0)
    
    print(f"Found {len(png_files)} PNG files\n")
    
    # Create backup directory
    backup_dir = images_dir / 'backup_original'
    backup_dir.mkdir(exist_ok=True)
    
    optimized_count = 0
    total_original = 0
    total_optimized = 0
    
    for png_file in png_files:
        print(f"Processing: {png_file.name}")
        
        # Backup original
        backup_path = backup_dir / png_file.name
        if not backup_path.exists():
            import shutil
            shutil.copy2(png_file, backup_path)
            print(f"  Backed up to: backup_original/")
        
        original_size = os.path.getsize(png_file)
        total_original += original_size
        
        # Optimize
        if optimize_image(png_file, png_file, max_size=1024, quality=85):
            optimized_count += 1
            total_optimized += os.path.getsize(png_file)
        
        print()
    
    # Summary
    print("=" * 50)
    print(f"✅ Optimization complete!")
    print(f"Files processed: {optimized_count}/{len(png_files)}")
    print(f"Total size: {total_original/1024:.1f}KB → {total_optimized/1024:.1f}KB")
    total_reduction = ((total_original - total_optimized) / total_original) * 100
    print(f"Total reduction: {total_reduction:.1f}%")
    print(f"\nOriginal files backed up to: {backup_dir}")

if __name__ == '__main__':
    main()
