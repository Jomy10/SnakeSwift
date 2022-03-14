#!/usr/bin/env zsh

cd WebApp
carton bundle

cd ..
cp WebApp/Bundle public
