#!/usr/bin/env zsh

set -e

cd "$(dirname "$0")"
cd ..
carton bundle --custom-index-page Build/index.html
rm -r ../public || true
mv Bundle ../public

# Build favicon
py Build/genFavicon.py
