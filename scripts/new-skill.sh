#!/usr/bin/env bash
# new-skill.sh — Scaffold a new Godot skill directory from the template.
# Usage: scripts/new-skill.sh <skill-name> "<description>"
# Example: scripts/new-skill.sh godot-tweening "Tween and animation timing patterns for Godot 4.x"
#
# Cross-platform: works on POSIX shells and Git Bash/WSL on Windows.
# All paths use forward slashes for Godot compatibility.

set -euo pipefail

# --- Argument validation ---
if [ $# -lt 2 ]; then
    echo "Usage: $0 <skill-name> \"<description>\""
    echo ""
    echo "Creates a new skill directory from docs/skill-template/ with:"
    echo "  skills/<name>/SKILL.md"
    echo "  skills/<name>/agents/claude-code.yaml"
    echo "  skills/<name>/agents/openai.yaml"
    echo "  skills/<name>/references/DETAIL.md"
    exit 1
fi

SKILL_NAME="$1"
SKILL_DESCRIPTION="$2"

# Validate skill name: lowercase kebab-case, max 64 chars
if [[ ! "$SKILL_NAME" =~ ^[a-z][a-z0-9]*(-[a-z0-9]+)*$ ]]; then
    echo "Error: Skill name must be lowercase kebab-case (e.g., godot-tweening)"
    echo "  - Start with a letter"
    echo "  - Use hyphens to separate words"
    echo "  - No underscores, spaces, or uppercase"
    exit 1
fi

if [ ${#SKILL_NAME} -gt 64 ]; then
    echo "Error: Skill name must be <= 64 characters (got ${#SKILL_NAME})"
    exit 1
fi

# --- Resolve paths ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATE_DIR="$ROOT_DIR/docs/skill-template"
TARGET_DIR="$ROOT_DIR/skills/$SKILL_NAME"

if [ ! -d "$TEMPLATE_DIR" ]; then
    echo "Error: Template directory not found at $TEMPLATE_DIR"
    exit 1
fi

if [ -d "$TARGET_DIR" ]; then
    echo "Error: Skill directory already exists at $TARGET_DIR"
    exit 1
fi

# --- Generate title from name (capitalize words) ---
SKILL_TITLE=$(echo "$SKILL_NAME" | sed 's/-/ /g; s/\b\(.\)/\u\1/g')

# --- Create directory structure ---
mkdir -p "$TARGET_DIR/agents"
mkdir -p "$TARGET_DIR/references"

# --- Copy and substitute files ---
for template in SKILL.md agents/claude-code.yaml agents/openai.yaml references/DETAIL.md; do
    if [ -f "$TEMPLATE_DIR/$template" ]; then
        sed \
            -e "s/{{SKILL_NAME}}/$SKILL_NAME/g" \
            -e "s/{{SKILL_DESCRIPTION}}/$SKILL_DESCRIPTION/g" \
            -e "s/{{SKILL_TITLE}}/$SKILL_TITLE/g" \
            "$TEMPLATE_DIR/$template" > "$TARGET_DIR/$template"
    fi
done

# --- Validate the new skill ---
echo ""
echo "Created skill: $SKILL_NAME"
echo "Directory: $TARGET_DIR"
echo ""
echo "Files:"
find "$TARGET_DIR" -type f | sort | while read -r f; do
    echo "  $f"
done
echo ""

# Run validation if available
if [ -x "$SCRIPT_DIR/validate-skills.sh" ]; then
    echo "Validating..."
    if bash "$SCRIPT_DIR/validate-skills.sh" 2>&1 | grep -q "PASSED\|pass"; then
        echo "✓ Validation passed"
    else
        echo "⚠ Validation reported issues — review manually"
    fi
else
    echo "Note: validate-skills.sh not found. Validate manually."
fi

echo ""
echo "Next steps:"
echo "  1. Edit $TARGET_DIR/SKILL.md with actual content"
echo "  2. Fill in references/DETAIL.md with expanded documentation"
echo "  3. Update agents/*.yaml with skill-specific triggers"
echo "  4. Run: bash scripts/verify.sh"
