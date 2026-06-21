# Phase 6: Testing Infrastructure, CI/CD, Quality Gates

## Problem / Opportunity

The package has grown to 12+ skills with agent-specific extensions. There's no automated testing pipeline, CI configuration, or quality gates beyond the manual `validate-skills.sh`. As the project matures, we need reproducible verification and automated publishing.

## Users / Actors

- Package maintainers ensuring skill quality before release
- Contributors validating PRs locally
- Downstream agents verifying installed skills are well-formed

## Goals

- Automated validation pipeline for all skills
- CI/CD configuration for GitHub Actions (or equivalent)
- Quality gates: frontmatter, line limits, agent extension presence, no leakage
- Local verify scripts for both POSIX and Windows

## Non-goals

- Not Godot game testing (that's `godot-debugging` territory)
- Not MCP server unit tests (separate concern, could be added later)
- Not performance benchmarking of skills themselves

## Requirements

### Deliverables

| Artifact | Purpose |
|----------|---------|
| `scripts/verify.sh` | POSIX verify script (unifies existing validate-skills.sh + new checks) |
| `scripts/verify.ps1` | PowerShell verify script (Windows parity) |
| `.github/workflows/ci.yml` | GitHub Actions CI pipeline |
| `scripts/lint-skills.sh` | SKILL.md linting (frontmatter, formatting, links) |
| `scripts/check-agent-extensions.sh` | Agent extension validation |
| MCP server tests | Basic smoke tests for godot-mcp-server |

### Verify script checks

1. All SKILL.md files exist with valid YAML frontmatter
2. Line count ≤ 500 per SKILL.md
3. Agent-specific extensions present (claude-code.yaml, openai.yaml)
4. Safety notices in agent YAML files
5. No agent-specific leakage in SKILL.md
6. package.json valid (name, version, pi.skills manifest)
7. LICENSE present and MIT
8. AGENTS.md present with ≥7 agent sections
9. CHANGELOG.md present
10. references/ directories exist for each skill
11. MCP server builds successfully (`npm run build`)

## Acceptance Criteria

- `scripts/verify.sh` runs on Linux/macOS, exits 0 on success
- `scripts/verify.ps1` runs on Windows PowerShell, exits 0 on success
- GitHub Actions workflow passes on push to main
- All 12 existing skills pass verification
- Verify scripts ≤ 200 lines each (maintainable)

## Risks

- **CI cost**: Free tier GitHub Actions should suffice for a documentation-heavy repo
- **Platform parity**: PowerShell vs bash behavior differences
- **MCP server build**: Requires Node.js in CI environment

## Open Questions / Assumptions

- Use GitHub Actions or another CI provider? (GitHub chosen for open-source convention)
- Include npm publish automation or keep manual? (Manual preferred for scoped packages)
- Add markdown linting (markdownlint) or keep checks custom? (Custom avoids extra deps)
