from PIL import Image, ImageDraw
import math

# Create 1024x1024 icon
size = 1024
img = Image.new('RGB', (size, size), '#2DBE6C')
draw = ImageDraw.Draw(img)

# Draw darker green circle background
center = size // 2
radius = 400
draw.ellipse([center-radius, center-radius, center+radius, center+radius], 
             fill='#1B8F4E')

# Draw simplified car shape (white)
car_width = 300
car_height = 120
car_x = center - car_width // 2
car_y = center - 80

# Car body (rounded rectangle)
draw.rounded_rectangle([car_x, car_y, car_x + car_width, car_y + car_height], 
                       radius=30, fill='white')

# Car windows
window_margin = 40
draw.rounded_rectangle([car_x + window_margin, car_y + 20, 
                       car_x + car_width // 2 - 10, car_y + 70], 
                       radius=15, fill='#E8F5E9')
draw.rounded_rectangle([car_x + car_width // 2 + 10, car_y + 20, 
                       car_x + car_width - window_margin, car_y + 70], 
                       radius=15, fill='#E8F5E9')

# Wheels
wheel_radius = 35
wheel_y = car_y + car_height - 10
draw.ellipse([car_x + 40 - wheel_radius, wheel_y - wheel_radius, 
              car_x + 40 + wheel_radius, wheel_y + wheel_radius], 
             fill='#424242')
draw.ellipse([car_x + car_width - 40 - wheel_radius, wheel_y - wheel_radius, 
              car_x + car_width - 40 + wheel_radius, wheel_y + wheel_radius], 
             fill='#424242')

# Draw leaf (eco symbol) on the left
leaf_x = center - 200
leaf_y = center + 100
# Simple leaf shape
leaf_points = [
    (leaf_x, leaf_y),
    (leaf_x - 30, leaf_y + 30),
    (leaf_x - 20, leaf_y + 60),
    (leaf_x, leaf_y + 80),
    (leaf_x + 20, leaf_y + 60),
    (leaf_x + 30, leaf_y + 30),
]
draw.polygon(leaf_points, fill='#4CAF50')
# Leaf vein
draw.line([(leaf_x, leaf_y), (leaf_x, leaf_y + 80)], fill='#388E3C', width=4)

# Draw lightning bolt (charging symbol) on the right
bolt_x = center + 180
bolt_y = center + 100
bolt_points = [
    (bolt_x + 20, bolt_y),
    (bolt_x - 10, bolt_y + 35),
    (bolt_x + 10, bolt_y + 35),
    (bolt_x - 20, bolt_y + 70),
    (bolt_x + 10, bolt_y + 40),
    (bolt_x - 10, bolt_y + 40)
]
draw.polygon(bolt_points, fill='#FDD835')

# Draw connector plug symbol at top
plug_x = center
plug_y = center - 200
# Plug outline
draw.rounded_rectangle([plug_x - 30, plug_y, plug_x + 30, plug_y + 60], 
                       radius=10, fill='white', outline='#1B8F4E', width=4)
# Plug pins
draw.rectangle([plug_x - 15, plug_y + 10, plug_x - 5, plug_y + 35], fill='#1B8F4E')
draw.rectangle([plug_x + 5, plug_y + 10, plug_x + 15, plug_y + 35], fill='#1B8F4E')

# Save main icon
img.save('app_icon.png')
print("Created detailed app_icon.png")

# Create foreground for adaptive icon
img_fg = Image.new('RGBA', (size, size), (0, 0, 0, 0))
draw_fg = ImageDraw.Draw(img_fg)

# Draw same elements on transparent background
# Car
draw_fg.rounded_rectangle([car_x, car_y, car_x + car_width, car_y + car_height], 
                          radius=30, fill='white')
draw_fg.rounded_rectangle([car_x + window_margin, car_y + 20, 
                          car_x + car_width // 2 - 10, car_y + 70], 
                          radius=15, fill='#E8F5E9')
draw_fg.rounded_rectangle([car_x + car_width // 2 + 10, car_y + 20, 
                          car_x + car_width - window_margin, car_y + 70], 
                          radius=15, fill='#E8F5E9')
draw_fg.ellipse([car_x + 40 - wheel_radius, wheel_y - wheel_radius, 
                car_x + 40 + wheel_radius, wheel_y + wheel_radius], 
                fill='#424242')
draw_fg.ellipse([car_x + car_width - 40 - wheel_radius, wheel_y - wheel_radius, 
                car_x + car_width - 40 + wheel_radius, wheel_y + wheel_radius], 
                fill='#424242')

# Leaf
draw_fg.polygon(leaf_points, fill='#4CAF50')
draw_fg.line([(leaf_x, leaf_y), (leaf_x, leaf_y + 80)], fill='#388E3C', width=4)

# Lightning
draw_fg.polygon(bolt_points, fill='#FDD835')

# Connector
draw_fg.rounded_rectangle([plug_x - 30, plug_y, plug_x + 30, plug_y + 60], 
                          radius=10, fill='white', outline='#1B8F4E', width=4)
draw_fg.rectangle([plug_x - 15, plug_y + 10, plug_x - 5, plug_y + 35], fill='#1B8F4E')
draw_fg.rectangle([plug_x + 5, plug_y + 10, plug_x + 15, plug_y + 35], fill='#1B8F4E')

img_fg.save('app_icon_foreground.png')
print("Created detailed app_icon_foreground.png")
