#!/bin/bash

echo "🧪 Testing KGH wrapper..."

# Test 1: Basic PR creation with special characters
echo "Test 1: PR creation with special characters"
kgh pr create --title "Test PR with 'quotes' and spaces" --body "This is a test PR with special chars: \$ & | ;" --dry

# Test 2: PR listing with filters
echo "Test 2: PR listing with filters"
kgh pr list --state open --limit 5 --dry

# Test 3: Issue creation with special characters
echo "Test 3: Issue creation with special characters"
kgh issue create --title "Test Issue with 'quotes'" --body "This is a test issue with special chars: \$ & | ;" --dry

# Test 4: Issue listing with filters
echo "Test 4: Issue listing with filters"
kgh issue list --state open --limit 5 --dry

# Test 5: Generic command with special characters
echo "Test 5: Generic command with special characters"
kgh repo view --json name,description --dry

echo "✅ Tests completed!" 