#!/bin/bash
# new-godot-project.sh — Scaffold a new Godot 4.x project
# Usage: ./scripts/new-godot-project.sh <ProjectName> <OutputDirectory>

set -e

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <ProjectName> <OutputDirectory>"
    echo "Example: $0 MyGame /path/to/output"
    exit 1
fi

PROJECT_NAME="$1"
OUTPUT_DIR="$2"
PROJECT_PATH="${OUTPUT_DIR}/${PROJECT_NAME}"

echo "Creating Godot 4.x project: ${PROJECT_NAME}"
echo "Output directory: ${PROJECT_PATH}"

# Create directory structure
mkdir -p "${PROJECT_PATH}/scenes/ui"
mkdir -p "${PROJECT_PATH}/scenes/levels"
mkdir -p "${PROJECT_PATH}/scenes/entities"
mkdir -p "${PROJECT_PATH}/scripts/core"
mkdir -p "${PROJECT_PATH}/scripts/entities"
mkdir -p "${PROJECT_PATH}/scripts/ui"
mkdir -p "${PROJECT_PATH}/scripts/levels"
mkdir -p "${PROJECT_PATH}/resources/data"
mkdir -p "${PROJECT_PATH}/resources/config"
mkdir -p "${PROJECT_PATH}/assets/textures"
mkdir -p "${PROJECT_PATH}/assets/audio"
mkdir -p "${PROJECT_PATH}/assets/fonts"
mkdir -p "${PROJECT_PATH}/assets/models"
mkdir -p "${PROJECT_PATH}/levels"

# Create .gdignore in assets
touch "${PROJECT_PATH}/assets/.gdignore"

# Create .gitignore
cat > "${PROJECT_PATH}/.gitignore" << 'GITIGNORE'
# Godot editor cache
.godot/
*.import/

# Export outputs
export-*/

# OS-specific
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/
*.sln
*.csproj
*.slnx
*.godot
GITIGNORE

# Create project.godot template
cat > "${PROJECT_PATH}/project.godot" << 'PROJEOF'
; Engine configuration file.
; It's best edited using the editor UI and not directly,
; but it can also be edited safely in a text editor.

config_version=5

[application]

config/name="${PROJECT_NAME}"
config/description="A Godot 4.x project"
config/features=PackedStringArray("Forward Plus")

[display]

window/size/width=1280
window/size/height=720
window/stretch/mode="canvas_items"

[rendering]

renderer/rendering_method="forward_plus"
PROJEOF

echo ""
echo "Project created successfully!"
echo "Open ${PROJECT_PATH} in the Godot 4.x editor to configure further."
