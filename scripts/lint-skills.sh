#!/bin/bash
# lint-skills.sh — Lint SKILL.md files for frontmatter, formatting, and links
# Usage: ./scripts/lint-skills.sh
set -e
cd "$(dirname "$0")/.."

errors=0
warnings=0
passed=0

pass() { echo "  ✓ $1"; passed=$((passed+1)); }
warn() { echo "  ⚠ $1"; warnings=$((warnings+1)); }
fail() { echo "  ✗ $1"; errors=$((errors+1)); }

echo "=========================================="
echo "SKILL.md Lint"
echo "=========================================="
echo ""

# [1] Frontmatter completeness
echo "[1] Frontmatter completeness"
for skill_dir in skills/*/; do
    skill_name=$(basename "$skill_dir")
    skill_md="$skill_dir/SKILL.md"
    [ -f "$skill_md" ] || continue

    missing=()
    for field in name description license compatibility metadata; do
        if ! grep -q "^$field:" "$skill_md"; then
            missing+=("$field")
        fi
    done

    if [ ${#missing[@]} -eq 0 ]; then
        pass "$skill_name — all required frontmatter fields present"
    else
        fail "$skill_name — missing: ${missing[*]}"
    fi
done

# [2] Frontmatter author and version in metadata
echo ""
echo "[2] Metadata completeness (author, version, tags)"
for skill_dir in skills/*/; do
    skill_name=$(basename "$skill_dir")
    skill_md="$skill_dir/SKILL.md"
    [ -f "$skill_md" ] || continue

    missing=()
    if ! grep -q "author:" "$skill_md"; then
        missing+=("author")
    fi
    if ! grep -q "version:" "$skill_md"; then
        missing+=("version")
    fi
    if ! grep -q "tags:" "$skill_md"; then
        missing+=("tags")
    fi

    if [ ${#missing[@]} -eq 0 ]; then
        pass "$skill_name — metadata complete"
    else
        warn "$skill_name — metadata missing: ${missing[*]}"
    fi
done

# [3] Code examples present (at least one fenced code block)
echo ""
echo "[3] Code examples present"
for skill_dir in skills/*/; do
    skill_name=$(basename "$skill_dir")
    skill_md="$skill_dir/SKILL.md"
    [ -f "$skill_md" ] || continue

    code_blocks=$(grep -c '```' "$skill_md" 2>/dev/null || echo 0)
    if [ "$code_blocks" -ge 2 ]; then
        pass "$skill_name — has code examples ($((code_blocks / 2)) blocks)"
    else
        warn "$skill_name — no fenced code blocks found"
    fi
done

# [4] Internal reference links resolve
echo ""
echo "[4] Internal reference links resolve"
for skill_dir in skills/*/; do
    skill_name=$(basename "$skill_dir")
    skill_md="$skill_dir/SKILL.md"
    [ -f "$skill_md" ] || continue

    broken=()
    # Find relative links like (references/...) or (../skills/...)
    while IFS= read -r link; do
        # Resolve relative to skill directory
        resolved="$skill_dir/$link"
        if [ ! -f "$resolved" ]; then
            broken+=("$link")
        fi
    done < <(grep -oP '\(\s*references/[^)]+\)' "$skill_md" 2>/dev/null | tr -d '()')

    if [ ${#broken[@]} -eq 0 ]; then
        pass "$skill_name — reference links OK"
    else
        fail "$skill_name — broken refs: ${broken[*]}"
    fi
done

# [5] No trailing whitespace on content lines (outside code blocks)
echo ""
echo "[5] Trailing whitespace check"
for skill_dir in skills/*/; do
    skill_name=$(basename "$skill_dir")
    skill_md="$skill_dir/SKILL.md"
    [ -f "$skill_md" ] || continue

    # Check for trailing whitespace (excluding code blocks)
    trailing=$(grep -cE ' +$' "$skill_md" 2>/dev/null || true)
    trailing=$(echo "$trailing" | tr -d '\r\n ')
    [ -z "$trailing" ] && trailing=0
    if [ "$trailing" -eq 0 ] 2>/dev/null; then
        pass "$skill_name — no trailing whitespace"
    else
        warn "$skill_name — $trailing lines with trailing whitespace"
    fi
done

# [6] Godot version compatibility includes 4.7
echo ""
echo "[6] Godot 4.7 compatibility declared"
for skill_dir in skills/*/; do
    skill_name=$(basename "$skill_dir")
    skill_md="$skill_dir/SKILL.md"
    [ -f "$skill_md" ] || continue

    if grep -q "godot-4.7" "$skill_md"; then
        pass "$skill_name — declares Godot 4.7 compatibility"
    else
        warn "$skill_name — missing godot-4.7 in compatibility list"
    fi
done

echo ""
echo "=========================================="
if [ "$errors" -eq 0 ]; then
    echo "LINT PASSED: $passed passed, $warnings warnings, $errors errors"
else
    echo "LINT FAILED: $passed passed, $warnings warnings, $errors errors"
    exit 1
fi
echo "=========================================="
