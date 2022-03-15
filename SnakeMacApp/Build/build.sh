#!/usr/bin/env zsh

cd "$(dirname "$0")"

cd ..
rm -r Snake.app

mkdir Snake.app
mkdir Snake.app/Contents
mkdir Snake.app/Contents/MacOS
mkdir Snake.app/Contents/Resources

cp Build/Info.plist Snake.app/Contents/Info.plist

# Build app icon
app_icon_png="Build/AppIcon.png"
output_icon_path="Build/AppIcon.iconset/"
mkdir $output_icon_path
sips -z 16 16     $app_icon_png --out "${output_icon_path}/icon_16x16.png"
sips -z 32 32     $app_icon_png --out "${output_icon_path}/icon_16x16@2x.png"
sips -z 32 32     $app_icon_png --out "${output_icon_path}/icon_32x32.png"
sips -z 64 64     $app_icon_png --out "${output_icon_path}/icon_32x32@2x.png"
sips -z 128 128   $app_icon_png --out "${output_icon_path}/icon_128x128.png"
sips -z 256 256   $app_icon_png --out "${output_icon_path}/icon_128x128@2x.png"
sips -z 256 256   $app_icon_png --out "${output_icon_path}/icon_256x256.png"
sips -z 512 512   $app_icon_png --out "${output_icon_path}/icon_256x256@2x.png"
sips -z 512 512   $app_icon_png --out "${output_icon_path}/icon_512x512.png"

iconutil -c icns $output_icon_path -o "Snake.app/Contents/Resources/AppIcon.icns"

rm -r $output_icon_path

# Build binary
swift build -c release

# Copy binary
cp "$(swift build -c release --show-bin-path)/SnakeMacApp" Snake.app/Contents/MacOS/Snake
