#!/bin/bash
# validate-skills.sh — Validate all skills against Agent Skills Open Standard
# Usage: ./scripts/validate-skills.sh
set -e
cd "$(dirname "$0")/.."

errors=0
passed=0

echo "=========================================="
echo "Agent Skills Open Standard Validation"
echo "=========================================="
echo ""

# Check all SKILL.md files have required frontmatter
echo "[1] SKILL.md frontmatter validation"
for skill_dir in skills/*/; do
    skill_name=$(basename "$skill_dir")
    skill_md="$skill_dir/SKILL.md"
    [ -f "$skill_md" ] || { echo "  ✗ MISSING: $skill_md"; errors=$((errors+1)); continue; }

    for field in name description license; do
        if ! grep -q "^$field:" "$skill_md"; then
            echo "  ✗ $skill_name — missing frontmatter: $field"
            errors=$((errors+1))
        fi
    done

    # Check compatibility and metadata are present (added in s3)
    if ! grep -q "^compatibility:" "$skill_md"; then
        echo "  ⚠ $skill_name — missing 'compatibility' frontmatter"
    fi
    if ! grep -q "^metadata:" "$skill_md"; then
        echo "  ⚠ $skill_name — missing 'metadata' frontmatter"
    fi

    lines=$(wc -l < "$skill_md")
    if [ "$lines" -ge 500 ]; then
        echo "  ✗ $skill_name — TOO LONG: $lines lines (max 500)"
        errors=$((errors+1))
    else
        echo "  ✓ $skill_name — $lines lines"
        passed=$((passed+1))
    fi
done

# Check agent-specific extensions
echo ""
echo "[2] Agent-specific extensions"
for skill_dir in skills/*/; do
    skill_name=$(basename "$skill_dir")
    for agent_file in claude-code.yaml openai.yaml; do
        if [ ! -f "$skill_dir/agents/$agent_file" ]; then
            echo "  ✗ $skill_name — missing agents/$agent_file"
            errors=$((errors+1))
        else
            if grep -q 'Safely ignored by other agents' "$skill_dir/agents/$agent_file"; then
                echo "  ✓ $skill_name — $agent_file (safety notice present)"
                passed=$((passed+1))
            else
                echo "  ✗ $skill_name — $agent_file (missing safety notice)"
                errors=$((errors+1))
            fi
        fi
    done
done

# Check no agent-specific leakage
echo ""
echo "[3] No agent-specific leakage in SKILL.md"
for skill_dir in skills/*/; do
    skill_name=$(basename "$skill_dir")
    skill_md="$skill_dir/SKILL.md"
    if grep -qi 'claude-code\|openai\|codex' "$skill_md" 2>/dev/null; then
        echo "  ✗ $skill_name — contains agent-specific references in SKILL.md"
        errors=$((errors+1))
    else
        echo "  ✓ $skill_name — no agent-specific leakage"
        passed=$((passed+1))
    fi
done

# Check package.json
echo ""
echo "[4] package.json validation"
if node -e "const d=require('./package.json'); if(!d.pi?.skills) throw new Error('missing pi manifest');" 2>/dev/null; then
    name=$(node -e "console.log(require('./package.json').name)")
    echo "  ✓ Valid: name=$name, pi.skills configured"
    passed=$((passed+1))
else
    echo "  ✗ package.json is invalid or missing pi manifest"
    errors=$((errors+1))
fi

# Check LICENSE
echo ""
echo "[5] LICENSE"
if [ -f "LICENSE" ] && grep -qi 'mit' LICENSE; then
    echo "  ✓ MIT License present"
    passed=$((passed+1))
else
    echo "  ✗ LICENSE missing or not MIT"
    errors=$((errors+1))
fi

# Check AGENTS.md
echo ""
echo "[6] Cross-agent documentation"
if [ -f "AGENTS.md" ]; then
    agents=$(grep -c '###' AGENTS.md 2>/dev/null || echo 0)
    echo "  ✓ AGENTS.md present ($agents agent sections)"
    passed=$((passed+1))
else
    echo "  ✗ AGENTS.md missing"
    errors=$((errors+1))
fi

echo ""
echo "=========================================="
if [ "$errors" -eq 0 ]; then
    echo "ALL CHECKS PASSED: $passed checks"
else
    echo "FAILED: $passed passed, $errors failed"
    exit 1
fi
echo "=========================================="
