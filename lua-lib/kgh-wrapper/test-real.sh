#!/bin/bash

echo "🧪 Testing KGH wrapper with real GitHub operations..."

# Crear un branch de test
TEST_BRANCH="test-kgh-$(date +%s)"
echo "Creating test branch: $TEST_BRANCH"
git checkout -b $TEST_BRANCH

# Hacer un cambio simple
echo "# Test Change" >> README.md
git add README.md
git commit -m "test: add test line to README"

# Test 1: Crear PR real
echo "Test 1: Creating real PR"
kgh pr create \
  --title "Test PR from KGH" \
  --body "This is a test PR created by KGH wrapper" \
  --base main

# Test 2: Listar PRs reales
echo "Test 2: Listing real PRs"
kgh pr list --state open --limit 5

# Test 3: Crear Issue real
echo "Test 3: Creating real Issue"
kgh issue create \
  --title "Test Issue from KGH" \
  --body "This is a test issue created by KGH wrapper" \
  --label "enhancement"

# Test 4: Listar Issues reales
echo "Test 4: Listing real Issues"
kgh issue list --state open --limit 5

# Test 5: Ver información del repo
echo "Test 5: Viewing repo info"
kgh repo view --json name,description

# Limpiar
echo "Cleaning up..."
git checkout main
git branch -D $TEST_BRANCH

echo "✅ Real tests completed!" 