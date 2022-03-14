#!/usr/bin/env zsh

set -e

carton bundle
rm -r ../public || true
mv Bundle ../public
