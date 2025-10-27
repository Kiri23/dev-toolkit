#!/bin/bash

echo "🚀 Running GitHub Actions locally..."

# Check if .env file exists
if [ ! -f .env ]; then
    echo "❌ .env file not found. Please create it with your GitHub token:"
    echo "GITHUB_TOKEN=your_github_token_here"
    exit 1
fi

# Run act in dry-run mode first
echo "📝 Checking workflow syntax..."
if ! act -n -W .github/workflows/kgh-test.yml; then
    echo "❌ GitHub Actions workflow has syntax errors."
    exit 1
fi

# Run the actual workflow
echo "🔍 Running actual workflow..."
if ! act -W .github/workflows/kgh-test.yml; then
    echo "❌ GitHub Actions workflow failed."
    exit 1
fi

echo "✅ GitHub Actions passed locally!"
exit 0 