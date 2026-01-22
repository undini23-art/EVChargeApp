from PIL import Image, ImageDraw, ImageFont
import os

# Create 1024x1024 icon (iOS requirement)
size = 1024
img = Image.new('RGB', (size, size), '#2DBE6C')
draw = ImageDraw.Draw(img)

# Draw a lightning bolt symbol
# Background circle
circle_margin = 150
draw.ellipse([circle_margin, circle_margin, size-circle_margin, size-circle_margin], 
             fill='#1B8F4E')

# Lightning bolt in white
bolt_points = [
    (size//2 + 50, size//4),
    (size//2 - 30, size//2),
    (size//2 + 20, size//2),
    (size//2 - 50, size*3//4),
    (size//2 + 30, size//2 + 50),
    (size//2 - 20, size//2 + 50)
]
draw.polygon(bolt_points, fill='white')

# Save main icon
img.save('app_icon.png')
print("Created app_icon.png")

# Create foreground for adaptive icon (transparent background)
img_fg = Image.new('RGBA', (size, size), (0, 0, 0, 0))
draw_fg = ImageDraw.Draw(img_fg)

# Draw white lightning bolt on transparent background
draw_fg.polygon(bolt_points, fill='white')

img_fg.save('app_icon_foreground.png')
print("Created app_icon_foreground.png")
