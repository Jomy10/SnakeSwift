#!/usr/bin/env zsh

set -e

cd "$(dirname "$0")"
<<<<<<< HEAD:WebApp/Build/buildApp.sh
cd ..
=======
>>>>>>> master:WebApp/buildApp.sh
carton bundle
rm -r ../public || true
mv Bundle ../public

# Build favicon
py Build/genFavicon.py
