#!/bin/bash
# Create a simple icon using ImageMagick if available, otherwise instructions

if command -v convert &> /dev/null; then
    # Create main icon with green background and white text
    convert -size 1024x1024 xc:"#2DBE6C" \
            -gravity center \
            -pointsize 400 \
            -font "Helvetica-Bold" \
            -fill white \
            -annotate +0+0 "⚡" \
            app_icon.png
    
    # Create foreground for adaptive icon
    convert -size 1024x1024 xc:none \
            -gravity center \
            -pointsize 400 \
            -font "Helvetica-Bold" \
            -fill white \
            -annotate +0+0 "⚡" \
            app_icon_foreground.png
    
    echo "Icons created successfully with ImageMagick"
else
    echo "ImageMagick not found. Creating placeholder text file."
    echo "Please replace app_icon.png with a 1024x1024 image" > README.txt
fi
