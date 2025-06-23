#!/bin/bash
# Add demo-fixes.js to index.html

cd /app/build
if ! grep -q "demo-fixes.js" index.html; then
    cp index.html index.html.bak
    awk '/<\/body>/ {print "<script src=\"/demo-fixes.js\"></script>"} 1' index.html.bak > index.html
    echo "Added demo-fixes.js to index.html"
else
    echo "demo-fixes.js already in index.html"
fi