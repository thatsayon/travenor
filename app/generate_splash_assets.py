#!/usr/bin/env python3
"""
Generate high-quality splash screen assets for Flutter.

This script creates properly sized splash images for all screen densities,
properly handling the wide text logo for Android 12+ adaptive splash screens.
"""

from PIL import Image
import os

def create_splash_assets(source_path, assets_dir):
    """Create all required splash screen assets from source logo."""
    
    img = Image.open(source_path).convert("RGBA")
    orig_width, orig_height = img.size
    print(f"Source image: {orig_width}x{orig_height}")
    
    # For the standard (pre-Android 12) splash, we'll use the logo as-is
    # but upscale if needed for clarity on high-DPI screens
    # The flutter_native_splash package will handle density scaling
    
    # For Android 12+, we need a square image where the logo fits
    # in the center "safe zone" which is about 2/3 of the total size.
    # Google recommends 288dp for the icon, which is 288*4 = 1152px at xxxhdpi
    
    # Create the main splash logo (upscaled for quality)
    # Target: at least 1200px width for good quality on xxxhdpi screens
    target_width = 1200
    if orig_width < target_width:
        scale_factor = target_width / orig_width
        new_width = int(orig_width * scale_factor)
        new_height = int(orig_height * scale_factor)
        upscaled = img.resize((new_width, new_height), Image.LANCZOS)
        print(f"Upscaled to: {new_width}x{new_height}")
    else:
        upscaled = img
        new_width, new_height = orig_width, orig_height
    
    # Save the main splash logo
    main_splash_path = os.path.join(assets_dir, "travenor_splash_logo.png")
    upscaled.save(main_splash_path, "PNG")
    print(f"Saved main splash logo: {main_splash_path}")
    
    # Create Android 12+ padded version (square)
    # The logo should be in the "safe zone" which is the inner 2/3 of the icon
    # For a 1152x1152 icon, the safe zone is ~768px diameter circle
    # Our text logo is wide, so we need to make sure it fits horizontally
    
    # Calculate canvas size: logo width should be ~60% of canvas for safety
    canvas_size = int(new_width / 0.6)
    # Round up to nice number
    canvas_size = max(1200, ((canvas_size + 99) // 100) * 100)
    print(f"Android 12+ canvas size: {canvas_size}x{canvas_size}")
    
    # Create transparent square canvas
    android12_img = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    
    # Center the logo
    x = (canvas_size - new_width) // 2
    y = (canvas_size - new_height) // 2
    android12_img.paste(upscaled, (x, y), upscaled)
    
    # Save Android 12+ version
    android12_path = os.path.join(assets_dir, "travenor_splash_logo_padded.png")
    android12_img.save(android12_path, "PNG")
    print(f"Saved Android 12+ splash logo: {android12_path}")
    
    print("\n✓ Splash assets generated successfully!")
    print("\nNext steps:")
    print("1. Run: flutter pub run flutter_native_splash:create")
    print("   This will regenerate all density-specific assets.")

if __name__ == "__main__":
    source = "/home/jamil/.gemini/antigravity/brain/19c9c2cc-46c2-4e2b-9666-c5aefb9cb478/uploaded_image_1767287890996.png"
    assets_dir = "/home/jamil/Desktop/travenor/app/assets/images"
    
    create_splash_assets(source, assets_dir)
