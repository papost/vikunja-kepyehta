#!/bin/bash

# Favicon Generation Script for Vikunja
# This script generates all necessary favicon and icon files from army.svg

set -e

echo "🎨 Favicon Generation Script"
echo "============================"

# Check if army.svg exists
if [ ! -f "army.svg" ]; then
    echo "❌ army.svg not found! Make sure you're in the correct directory."
    exit 1
fi

# Check if ImageMagick is installed
if ! command -v convert >/dev/null 2>&1; then
    echo "❌ ImageMagick is not installed. Please install it first:"
    echo "   macOS: brew install imagemagick"
    echo "   Ubuntu/Debian: sudo apt-get install imagemagick"
    echo "   CentOS/RHEL: sudo yum install ImageMagick"
    exit 1
fi

echo "✅ army.svg found"
echo "✅ ImageMagick is available"
echo ""

# Create output directory
mkdir -p temp_icons

echo "🔄 Generating favicon files from army.svg..."

# Generate different sizes
declare -A sizes=(
    ["16"]="favicon-16x16.png"
    ["32"]="favicon-32x32.png"
    ["60"]="apple-touch-icon-60x60.png"
    ["76"]="apple-touch-icon-76x76.png"
    ["120"]="apple-touch-icon-120x120.png"
    ["144"]="msapplication-icon-144x144.png"
    ["150"]="mstile-150x150.png"
    ["152"]="apple-touch-icon-152x152.png"
    ["180"]="apple-touch-icon-180x180.png apple-touch-icon.png"
    ["192"]="android-chrome-192x192.png"
    ["512"]="android-chrome-512x512.png icon-maskable.png"
)

# Generate PNG files
for size in "${!sizes[@]}"; do
    filenames=${sizes[$size]}
    echo "  📐 Generating ${size}x${size} icons..."
    
    # Convert SVG to PNG at specified size
    convert -background transparent army.svg -resize ${size}x${size} temp_icons/icon_${size}.png
    
    # Copy to all required filenames
    for filename in $filenames; do
        cp temp_icons/icon_${size}.png temp_icons/$filename
        echo "    ✅ Created $filename"
    done
done

# Generate favicon.ico (multi-size ICO file)
echo "  🔄 Generating favicon.ico..."
convert army.svg -background transparent \
    \( -clone 0 -resize 16x16 \) \
    \( -clone 0 -resize 32x32 \) \
    \( -clone 0 -resize 48x48 \) \
    -delete 0 temp_icons/favicon.ico
echo "    ✅ Created favicon.ico"

# Generate badge-monochrome.png (simplified version)
echo "  🔄 Generating badge-monochrome.png..."
convert army.svg -background transparent -resize 512x512 -colorspace Gray temp_icons/badge-monochrome.png
echo "    ✅ Created badge-monochrome.png"

echo ""
echo "📁 Moving files to frontend/public/..."

# Move favicon.ico to public root
cp temp_icons/favicon.ico frontend/public/

# Move other icons to images/icons directory
for file in temp_icons/*.png; do
    filename=$(basename "$file")
    if [ "$filename" != "badge-monochrome.png" ] && [[ "$filename" != icon_*.png ]]; then
        cp "$file" frontend/public/images/icons/
    fi
done

# Move badge-monochrome.png
cp temp_icons/badge-monochrome.png frontend/public/images/icons/

echo ""
echo "🧹 Cleaning up temporary files..."
rm -rf temp_icons

echo ""
echo "🎉 Favicon generation complete!"
echo ""
echo "📱 Generated files:"
echo "   • favicon.ico (16x16, 32x32, 48x48)"
echo "   • PNG icons for all sizes (16x16 to 512x512)"
echo "   • Apple touch icons"
echo "   • Android chrome icons"
echo "   • Windows tile icons"
echo "   • Maskable icon for PWA"
echo "   • Monochrome badge"
echo ""
echo "🌐 Your browser tab will now show the army.svg logo!"
echo "   Restart your application to see the changes:"
echo "   ./deploy.sh"
