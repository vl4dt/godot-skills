#!/bin/bash
# check-agent-extensions.sh — Validate agent-specific extension files
# Usage: ./scripts/check-agent-extensions.sh [skill_dir]
# If skill_dir is given, check only that skill; otherwise check all.
set -e
cd "$(dirname "$0")/.."

errors=0
passed=0

pass() { echo "  ✓ $1"; passed=$((passed+1)); }
fail() { echo "  ✗ $1"; errors=$((errors+1)); }

echo "=========================================="
echo "Agent Extension Validation"
echo "=========================================="
echo ""

TARGET_DIR="${1:-skills}"

# [1] Required agent files present
echo "[1] Required agent files (claude-code.yaml, openai.yaml)"
for skill_dir in "$TARGET_DIR"/*/; do
    [ -d "$skill_dir" ] || continue
    skill_name=$(basename "$skill_dir")
    agents_dir="$skill_dir/agents"

    if [ ! -d "$agents_dir" ]; then
        fail "$skill_name — agents/ directory missing"
        continue
    fi

    for agent_file in claude-code.yaml openai.yaml; do
        if [ -f "$agents_dir/$agent_file" ]; then
            pass "$skill_name — $agent_file present"
        else
            fail "$skill_name — $agent_file missing"
        fi
    done
done

# [2] Safety notice in each agent file
echo ""
echo "[2] Safety notices (Safely ignored by other agents)"
for skill_dir in "$TARGET_DIR"/*/; do
    [ -d "$skill_dir" ] || continue
    skill_name=$(basename "$skill_dir")
    agents_dir="$skill_dir/agents"
    [ -d "$agents_dir" ] || continue

    for agent_file in claude-code.yaml openai.yaml; do
        filepath="$agents_dir/$agent_file"
        [ -f "$filepath" ] || continue
        if grep -q 'Safely ignored by other agents' "$filepath"; then
            pass "$skill_name — $agent_file has safety notice"
        else
            fail "$skill_name — $agent_file missing safety notice"
        fi
    done
done

# [3] No agent-specific content leaked into SKILL.md
echo ""
echo "[3] No agent leakage in SKILL.md"
for skill_dir in "$TARGET_DIR"/*/; do
    [ -d "$skill_dir" ] || continue
    skill_name=$(basename "$skill_dir")
    skill_md="$skill_dir/SKILL.md"
    [ -f "$skill_md" ] || continue

    if grep -qi 'claude-code\|openai\|codex' "$skill_md" 2>/dev/null; then
        fail "$skill_name — contains agent-specific references"
    else
        pass "$skill_name — no agent leakage"
    fi
done

# [4] Agent files are valid YAML (basic check)
echo ""
echo "[4] Agent files are valid YAML"
for skill_dir in "$TARGET_DIR"/*/; do
    [ -d "$skill_dir" ] || continue
    skill_name=$(basename "$skill_dir")
    agents_dir="$skill_dir/agents"
    [ -d "$agents_dir" ] || continue

    for agent_file in claude-code.yaml openai.yaml; do
        filepath="$agents_dir/$agent_file"
        [ -f "$filepath" ] || continue
        # Basic YAML check: file is not empty and has at least one non-comment, non-blank line
        if [ -s "$filepath" ] && grep -q '^[a-zA-Z]' "$filepath"; then
            pass "$skill_name — $agent_file valid YAML structure"
        else
            fail "$skill_name — $agent_file appears empty or malformed"
        fi
    done
done

echo ""
echo "=========================================="
if [ "$errors" -eq 0 ]; then
    echo "AGENT EXTENSIONS OK: $passed checks passed, $errors errors"
else
    echo "AGENT EXTENSIONS FAILED: $passed passed, $errors errors"
    exit 1
fi
echo "=========================================="
