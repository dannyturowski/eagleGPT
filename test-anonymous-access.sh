#!/bin/bash

echo "🔍 Testing Anonymous Access on eagleGPT"
echo "======================================"
echo ""

# Test 1: Check if root returns 200
echo "Test 1: HTTP Status Code"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" https://eaglegpt.us/)
echo "HTTPS Status: $HTTP_CODE"

# Test 2: Check page content
echo ""
echo "Test 2: Page Content Analysis"
CONTENT=$(curl -s https://eaglegpt.us/ | head -200)

# Check for auth redirect in HTML
if echo "$CONTENT" | grep -q "window.location.*auth"; then
    echo "❌ Found client-side auth redirect"
else
    echo "✅ No client-side auth redirect"
fi

# Check for meta refresh to auth
if echo "$CONTENT" | grep -q "meta.*refresh.*auth"; then
    echo "❌ Found meta refresh to auth"
else
    echo "✅ No meta refresh to auth"
fi

# Check page title
if echo "$CONTENT" | grep -q "<title>eagleGPT</title>"; then
    echo "✅ Page title is correct"
else
    echo "❌ Page title issue"
fi

# Test 3: Check JavaScript bundle
echo ""
echo "Test 3: JavaScript Bundle Check"
JS_FILES=$(echo "$CONTENT" | grep -o '/_app/immutable/nodes/[^"]*\.js' | head -5)
if [ -n "$JS_FILES" ]; then
    echo "Found JS files:"
    echo "$JS_FILES" | head -3
    
    # Download and check one JS file for publicRoutes
    FIRST_JS=$(echo "$JS_FILES" | head -1)
    if [ -n "$FIRST_JS" ]; then
        echo ""
        echo "Checking $FIRST_JS for publicRoutes..."
        curl -s "https://eaglegpt.us$FIRST_JS" | grep -q "publicRoutes" && echo "✅ Found publicRoutes in JS" || echo "❌ No publicRoutes in JS"
    fi
fi

# Test 4: API check
echo ""
echo "Test 4: API Configuration"
API_NAME=$(curl -s https://eaglegpt.us/api/config | jq -r '.name' 2>/dev/null || echo "Failed")
echo "API returns name: $API_NAME"

echo ""
echo "📋 Summary:"
echo "- The issue appears to be in the client-side JavaScript"
echo "- The (app) layout is redirecting before checking public routes"
echo "- Need to rebuild with the updated layout logic"