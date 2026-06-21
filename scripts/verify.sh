#!/bin/bash
# verify.sh — Unified verification for @robotcat/godot-skills
# Usage: ./scripts/verify.sh
set -e
cd "$(dirname "$0")/.."

PASS=0
FAIL=0

pass() { echo "  ✓ $1"; PASS=$((PASS+1)); }
fail() { echo "  ✗ $1"; FAIL=$((FAIL+1)); }

echo "=========================================="
echo "@robotcat/godot-skills — Verification"
echo "=========================================="
echo ""

# [1] Skills validation (delegates to existing script)
echo "[1] Skills validation"
if bash scripts/validate-skills.sh > /dev/null 2>&1; then
    pass "All skills pass Agent Skills Open Standard checks"
else
    fail "Skills validation failed — run scripts/validate-skills.sh for details"
fi

# [2] Package structure
echo ""
echo "[2] Package structure"
[ -f "package.json" ] && pass "package.json present" || fail "package.json missing"
[ -f "LICENSE" ] && pass "LICENSE present" || fail "LICENSE missing"
[ -f "README.md" ] && pass "README.md present" || fail "README.md missing"
[ -f "AGENTS.md" ] && pass "AGENTS.md present" || fail "AGENTS.md missing"
[ -f "CHANGELOG.md" ] && pass "CHANGELOG.md present" || fail "CHANGELOG.md missing"
[ -f "CODE_OF_CONDUCT.md" ] && pass "CODE_OF_CONDUCT.md present" || fail "CODE_OF_CONDUCT.md missing"
[ -f "CONTRIBUTING.md" ] && pass "CONTRIBUTING.md present" || fail "CONTRIBUTING.md missing"

# [3] Project flow scaffolding
echo ""
echo "[3] Project flow scaffolding"
[ -f "CONTEXT.md" ] && pass "CONTEXT.md present" || fail "CONTEXT.md missing"
[ -d "docs/adr" ] && pass "docs/adr/ directory exists" || fail "docs/adr/ missing"
[ -d "docs/specs" ] && pass "docs/specs/ directory exists" || fail "docs/specs/ missing"

# [4] MCP bridge
echo ""
echo "[4] MCP bridge"
[ -d "mcp-bridge/godot-mcp-server" ] && pass "MCP server directory exists" || fail "MCP server missing"
[ -f "mcp-bridge/godot-mcp-server/package.json" ] && pass "MCP server package.json" || fail "MCP server package.json missing"
[ -d "mcp-bridge/godot-mcp-server/dist" ] && pass "MCP server dist/ built" || fail "MCP server dist/ not built"

# [5] Examples
echo ""
echo "[5] Example projects"
for example in minimal-rpg platformer-2d multiplayer-lobby; do
    if [ -d "examples/$example" ] && [ -f "examples/$example/README.md" ]; then
        pass "Example: $example"
    else
        fail "Example: $example (missing or incomplete)"
    fi
done

# [6] Docs
echo ""
echo "[6] Documentation"
[ -f "docs/architecture.md" ] && pass "docs/architecture.md" || fail "docs/architecture.md missing"
[ -f "docs/contributing.md" ] && pass "docs/contributing.md" || fail "docs/contributing.md missing"
[ -f "docs/cross-agent-testing.md" ] && pass "docs/cross-agent-testing.md" || fail "docs/cross-agent-testing.md missing"

# [7] ADR count
echo ""
echo "[7] Architecture Decision Records"
ADR_COUNT=$(find docs/adr -name "*.md" 2>/dev/null | wc -l)
if [ "$ADR_COUNT" -gt 0 ]; then
    pass "docs/adr/ has $ADR_COUNT ADR files"
else
    fail "docs/adr/ is empty"
fi

# [8] Specs count
echo ""
echo "[8] Feature specs"
SPEC_COUNT=$(find docs/specs -name "spec.md" 2>/dev/null | wc -l)
if [ "$SPEC_COUNT" -gt 0 ]; then
    pass "docs/specs/ has $SPEC_COUNT spec files"
else
    fail "docs/specs/ is empty"
fi

# [9] Scripts
echo ""
echo "[9] Scripts"
[ -f "scripts/validate-skills.sh" ] && pass "scripts/validate-skills.sh" || fail "scripts/validate-skills.sh missing"
[ -f "scripts/verify.sh" ] && pass "scripts/verify.sh" || fail "scripts/verify.sh missing"

echo ""
echo "=========================================="
TOTAL=$((PASS+FAIL))
if [ "$FAIL" -eq 0 ]; then
    echo "ALL CHECKS PASSED: $PASS/$TOTAL"
else
    echo "RESULTS: $PASS passed, $FAIL failed ($TOTAL total)"
    exit 1
fi
echo "=========================================="
