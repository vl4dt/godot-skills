# verify.ps1 — Unified verification for @robotcat/godot-skills (PowerShell)
# Usage: .\scripts\verify.ps1
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot\..

$Results = @{ pass = 0; fail = 0 }

function Test-Check {
    param([string]$Name, [bool]$Condition)
    if ($Condition) {
        Write-Host "  ✓ $Name"
        $Results.pass++
    } else {
        Write-Host "  ✗ $Name"
        $Results.fail++
    }
}

Write-Host "=========================================="
Write-Host "@robotcat/godot-skills — Verification"
Write-Host "=========================================="
Write-Host ""

# [1] Package structure
Write-Host "[1] Package structure"
Test-Check "package.json present" (Test-Path "package.json")
Test-Check "LICENSE present" (Test-Path "LICENSE")
Test-Check "README.md present" (Test-Path "README.md")
Test-Check "AGENTS.md present" (Test-Path "AGENTS.md")
Test-Check "CHANGELOG.md present" (Test-Path "CHANGELOG.md")

# [2] Project flow scaffolding
Write-Host ""
Write-Host "[2] Project flow scaffolding"
Test-Check "CONTEXT.md present" (Test-Path "CONTEXT.md")
Test-Check "docs/adr/ directory exists" (Test-Path "docs/adr")
Test-Check "docs/specs/ directory exists" (Test-Path "docs/specs")

# [3] Skills directories
Write-Host ""
Write-Host "[3] Skills"
$skillDirs = Get-ChildItem -Path "skills" -Directory -ErrorAction SilentlyContinue
if ($skillDirs) {
    foreach ($dir in $skillDirs) {
        Test-Check "$($dir.Name)/SKILL.md" (Test-Path (Join-Path $dir.FullName "SKILL.md"))
    }
} else {
    Write-Host "  ✗ No skills directories found"
    $Results.fail++
}

# [4] MCP bridge
Write-Host ""
Write-Host "[4] MCP bridge"
Test-Check "MCP server directory" (Test-Path "mcp-bridge/godot-mcp-server")
Test-Check "MCP server package.json" (Test-Path "mcp-bridge/godot-mcp-server/package.json")
Test-Check "MCP server dist/ built" (Test-Path "mcp-bridge/godot-mcp-server/dist")

# [5] Examples
Write-Host ""
Write-Host "[5] Example projects"
foreach ($example in @("minimal-rpg", "platformer-2d", "multiplayer-lobby")) {
    Test-Check "Example: $example" ((Test-Path "examples/$example") -and (Test-Path "examples/$example/README.md"))
}

# [6] Documentation
Write-Host ""
Write-Host "[6] Documentation"
Test-Check "docs/architecture.md" (Test-Path "docs/architecture.md")
Test-Check "docs/contributing.md" (Test-Path "docs/contributing.md")

# [7] ADR count
Write-Host ""
Write-Host "[7] Architecture Decision Records"
$adrCount = (Get-ChildItem -Path "docs/adr" -Filter "*.md" -ErrorAction SilentlyContinue).Count
Test-Check "docs/adr/ has $adrCount ADR files" ($adrCount -gt 0)

# [8] Specs count
Write-Host ""
Write-Host "[8] Feature specs"
$specCount = (Get-ChildItem -Path "docs/specs" -Recurse -Filter "spec.md" -ErrorAction SilentlyContinue).Count
Test-Check "docs/specs/ has $specCount spec files" ($specCount -gt 0)

# [9] Scripts
Write-Host ""
Write-Host "[9] Scripts"
Test-Check "scripts/validate-skills.sh" (Test-Path "scripts/validate-skills.sh")
Test-Check "scripts/verify.ps1" (Test-Path "scripts/verify.ps1")

Write-Host ""
Write-Host "=========================================="
$total = $Results.pass + $Results.fail
if ($Results.fail -eq 0) {
    Write-Host "ALL CHECKS PASSED: $($Results.pass)/$total"
} else {
    Write-Host "RESULTS: $($Results.pass) passed, $($Results.fail) failed ($total total)"
    exit 1
}
Write-Host "=========================================="
