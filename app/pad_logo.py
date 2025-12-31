from PIL import Image
import os

def pad_image(input_path, output_path):
    img = Image.open(input_path)
    width, height = img.size
    
    # Calculate new square size
    # Android 12 circle is roughly 2/3 of the icon size.
    # We want the text (width) to fit in the circle.
    # So the circle diameter must be >= width.
    # If circle diameter is D, icon size is D. (Actually icon viewport is larger, but safe zone is ~66%)
    # Let's be safe: Make the canvas 1.8x the width of the text logo.
    
    new_size = int(max(width, height) * 1.8)
    
    # Create new transparent image
    new_img = Image.new("RGBA", (new_size, new_size), (0, 0, 0, 0))
    
    # Paste original in center
    x = (new_size - width) // 2
    y = (new_size - height) // 2
    new_img.paste(img, (x, y))
    
    new_img.save(output_path)
    print(f"Created padded image at {output_path}")

if __name__ == "__main__":
    pad_image('/home/jamil/Desktop/travenor/app/assets/images/travenor_splash_logo.png', 
              '/home/jamil/Desktop/travenor/app/assets/images/travenor_splash_logo_padded.png')
