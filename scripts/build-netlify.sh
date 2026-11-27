#!/bin/sh
# Builds the static copy of the website that Netlify publishes (newvis.gensolve.in).
# Only the public pages and assets go into dist/; the Python app, tools and docs stay out.
set -e
cd "$(dirname "$0")/.."
rm -rf dist
mkdir -p dist
cp landing.html dist/index.html
cp privacy.html 404.html dist/
cp -R static dist/static
cp static/robots.txt static/sitemap.xml dist/
echo "Built dist/ ($(find dist -type f | wc -l | tr -d ' ') files)"
