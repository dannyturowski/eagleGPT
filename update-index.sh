#!/bin/bash
# Update index.html to include our custom scripts

# Create a backup
cp /app/build/index.html /app/build/index.html.bak

# Add scripts before closing body tag
sed -i 's|</body>|<script src="/remove-anonymous-page.js"></script>\n<script src="/demo-auto-login.js"></script>\n</body>|' /app/build/index.html

echo "Scripts added to index.html"