#!/usr/bin/env zsh

set -e

cd "$(dirname "$0")"
carton bundle
rm -r ../public || true
mv Bundle ../public
