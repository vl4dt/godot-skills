---
name: godot-headless-workflow
description: "AI-agent development loop for Godot 4.x without opening the editor: headless validation (--check-only), project import, gdUnit4 testing, safe hand-editing of text scenes (.tscn), CLI export pipeline for Android/iOS, mobile checklist, and RevenueCat plugin integration. Use when building or modifying a Godot game as a coding agent, running Godot in CI, validating GDScript changes, exporting mobile builds, or integrating in-app purchases."
license: MIT
compatibility:
  - godot-4.2
  - godot-4.3
  - godot-4.4
  - godot-4.5
  - godot-4.6
  - godot-4.7
metadata:
  author: vl4dt
  version: 0.1.0
  tags:
    - godot
    - headless
    - ci
    - ai-agents
    - testing
    - export
    - revenuecat
  created: 2026-08-24
---

# Godot Headless Workflow (Agent Development Loop)

The complete edit→validate→test→run→export loop for Godot projects **without ever opening
the editor**. Every change must pass the headless gate before you claim it works.

## Golden Rules

1. **Never trust an edit you haven't validated headlessly.** A script that looks right but
   was never parsed is not done.
2. **GDScript only** unless the project already uses C# (see `godot-csharp-patterns`). Pin the
   engine version in the project's `AGENTS.md` (e.g., `Godot 4.7.2 stable, GDScript`).
3. **Scenes are text** (`.tscn`/`.tres`) — editable by hand *with care*, or better, generated
   by tool scripts. See §Text Asset Safety.
4. **Never touch `.godot/`** — it's a regenerable cache.
5. **The editor GUI is optional.** Use it (or the package's MCP bridge) only for visual
   layout iteration; logic, tests, and builds are all CLI work.

## Prerequisites

```bash
godot --version          # e.g. 4.7.stable.official — confirm once per machine/session
```

The Godot binary must be on PATH **in the shell you run commands from** (Git Bash on Windows,
native bash on Linux). Export templates are needed only for §CLI Export:

| Host | Template install path |
|---|---|
| Windows | `%APPDATA%\Godot\export_templates\<engine-version>\` |
| Linux | `~/.local/share/godot/export_templates/<engine-version>/` |
| macOS | `~/Library/Application Support/Godot/export_templates/<engine-version>/` |

## Cross-Platform (Windows ↔ Ubuntu hosts)

All Godot CLI flags, gdUnit4 runners (`runtest.cmd` / `runtest.sh`), `res://` paths, and
export behavior are **identical across hosts** — projects stay fully portable. Watch only:

1. **Line endings kill `.sh` scripts**: if `verify.sh` is checked out with CRLF on Linux it
   fails with `$'\r': command not found`. Add to every game repo's `.gitattributes`:
   `*.sh text eol=lf` (and commit it from day one).
2. **Runner extension differs by host** — `runtest.cmd` on Windows, `runtest.sh` elsewhere;
   detect or parameterize instead of hardcoding one.
3. **Don't mix toolchain worlds**: run Godot + Android SDK/adb **natively** per OS. Building
   inside WSL while your emulator/adb runs on Windows causes device-detection pain.
   On Ubuntu, USB debugging needs udev rules for your phone vendor before `adb devices` lists it.
4. **Signing env vars are the same** on both hosts — just use absolute paths appropriate
   per filesystem in `GODOT_ANDROID_KEYSTORE_PATH`.

## The Core Loop

```
edit (.gd / .tscn / project settings)
  → full import            (after adding/removing assets or scenes)
  → parse check            (every changed script)
  → unit tests             (gdUnit4, see references/testing.md)
  → smoke run              (boot the game headlessly for N frames)
  → commit                 (only when everything above exits 0)
  → export                 (when feature-complete; see references/exporting.md)
```

### Step 1 — Full import (required after asset/scene changes)

```bash
godot --headless --path . --import
```

Imports all resources, generates `.godot/` cache, resolves UIDs, and reports load errors.
Run this before anything else in a fresh clone, and whenever you added textures/scenes/fonts.
Exit code ≠ 0 means broken resources — fix before continuing.

### Step 2 — Parse-check changed scripts

```bash
godot --headless --check-only --script res://scripts/player.gd
```

Syntax + basic type checking without executing. Fast enough to run per-edit. Note: it does
NOT catch broken node paths, missing autoloads, or runtime type errors — those need steps 3–4.

### Step 3 — Unit tests (gdUnit4)

Standardize every project on [gdUnit4](https://github.com/MikeSchulze/gdUnit4). Tests live in
`res://tests/`; suites extend `GdUnitTestSuite`. Run from the project root:

```bash
# Windows
addons/gdUnit4/runtest.cmd -a res://tests --continue
# Linux/macOS
./addons/gdUnit4/runtest.sh -a res://tests --continue
```

Non-zero exit = failures (CI-safe). HTML/XML reports land in `res://reports/`.
Full patterns — assertions, async tests, parametrized cases — in `references/testing.md`.

### Step 4 — Smoke run

Boot the real game headlessly and let it tick a bounded number of frames:

```bash
godot --headless --path . --quit-after 300   # ~300 frames of main scene
```

Runtime errors (bad autoload order, missing nodes, signal typos) print here and fail loudly.
For deeper checks (instantiate specific scenes, assert state), use a SceneTree driver script:

```gdscript
# tools/smoke_test.gd — instantiate target scenes, tick frames, assert they survive
extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var targets := ["res://scenes/main.tscn"]
	var errors := 0
	for path in targets:
		var ps: PackedScene = load(path)
		if ps == null:
			push_error("FAILED TO LOAD: " + path)
			errors += 1
			continue
		var node := ps.instantiate()
		root.add_child(node)
		await process_frame
		await process_frame
		node.queue_free()
		await process_frame
	print("SMOKE RESULT: ", "FAIL" if errors > 0 else "PASS")
	quit(1 if errors > 0 else 0)
```

```bash
godot --headless --path . -s res://tools/smoke_test.gd
```

### Copy-paste verification gate (put this in every game repo)

```bash
#!/usr/bin/env bash
# verify.sh — the agent gate. Run after EVERY batch of edits. All steps must exit 0.
set -e
godot --headless --path . --import
for f in $(git diff --name-only HEAD | grep '\.gd$'); do
  godot --headless --check-only --script "res://${f#*/}" || exit 1
done
addons/gdUnit4/runtest.cmd -a res://tests --continue      # Linux/macOS: runtest.sh
godot --headless --path . --quit-after 300
echo "ALL CHECKS PASSED"
```

## Text Asset Safety (.tscn / .tres)

Scenes and resources are plain text — readable, diffable, mergeable. Rules:

| Do | Don't |
|---|---|
| Read `.tscn` to learn structure before editing scripts | Invent `uid://` values |
| Edit node properties, positions, exported values in place | Delete or rename `.uid` sidecar files |
| Add `[node]` blocks mirroring existing syntax exactly | Reference resources by UID you haven't seen |
| Prefer generating scenes via a tool script (below) | Hand-write complex nested scenes from scratch |
| Let Godot regenerate paths after moving files (`--import`) | Edit anything under `.godot/` |

Since Godot 4.4, scripts carry `.uid` sidecars and `ext_resource` entries may point at
`uid://…`. If both `uid` and `path` exist, either resolving is fine — **keep the `path`
attribute when hand-editing** and never fabricate UIDs.

When structural changes get risky (new node trees, wiring signals between nodes), generate
the scene programmatically instead:

```gdscript
# tools/build_scene.gd — run: godot --headless --path . -s res://tools/build_scene.gd
extends SceneTree

func _init() -> void:
	call_deferred("_build")

func _build() -> void:
	var root_node := Node2D.new()
	root_node.name = "Level1"
	var sprite := Sprite2D.new()
	sprite.name = "Player"
	sprite.position = Vector2(640, 360)
	root_node.add_child(sprite)

	var packed := PackedScene.new()
	packed.pack(root_node)
	ResourceSaver.save(packed, "res://scenes/levels/level_1.tscn")
	print("SCENE SAVED")
	quit(0)
```

This is deterministic, reviewable, and can't corrupt unrelated scene sections.

## CLI Export

One-time setup: create presets (editor UI or by writing `export_presets.cfg` — see
`references/exporting.md` for working Android/iOS preset skeletons).

```bash
# Windows/Linux desktop
godot --headless --path . --export-release "Windows Desktop" builds/win/game.exe

# Android (AAB for Play Store; APK for sideload/Galaxy Store)
godot --headless --path . --export-release "Android" builds/android/game.aab

# iOS — produces an Xcode project FOLDER, archived later on macOS
godot --headless --path . --export-release "iOS" builds/ios/
```

Release Android exports read signing config from env vars:

```bash
export GODOT_ANDROID_KEYSTORE_PATH=/path/to/release.keystore
export GODOT_ANDROID_KEYSTORE_USER=alias
export GODOT_ANDROID_KEYSTORE_PASSWORD=secret
```

Details, debugging exports (`--export-debug`), and the store-submission checklist live in
`references/exporting.md`.

## Mobile Quick Checklist

- Stretch mode `canvas_items` + portrait/landscape locked in `project.godot`
- Touch input: enable "Emulate Mouse From Touch"; consider Godot 4.7's `VirtualJoystick`
- Respect notches/safe areas (get visible rect from viewport, anchor UI inside it)
- Budget: mid-range phone should hold 60 fps — profile with `godot-performance` skill before shipping
- Min versions when using the RevenueCat plugin below: iOS 15+, Android SDK 24+

## In-App Purchases (RevenueCat)

Use the community **Godotx RevenueCat** plugin (MIT; wraps the official RC iOS/Android SDKs;
built against Godot 4.7-stable). Condensed flow — full playbook in `references/revenuecat.md`:

1. Install via AssetLib ("Godotx RevenueCat") → gives `addons/`, `ios/plugins/`, `android/plugins/`
2. Enable the plugin **per export preset**; Android additionally needs **Gradle Build ON**
3. Create the app + IAP products in Play Console / App Store Connect first, mirror them in
   the RevenueCat dashboard, note the platform-specific public API keys
4. Init at startup with the platform key → fetch offerings → paywall → purchase → entitlement check
5. Test a real sandbox purchase on device **before** building game systems on top of it

⚠️ Verify exact method names against the addon's own README/API reference at integration
time — don't guess API surface (see failure modes below).

## Agent Failure Modes (catch these in review)

| Failure mode | Symptom | Gate |
|---|---|---|
| **Godot 3 API bleed** | `onready var`, `yield(`, `.instance()`, `tool` alone, `export var`, string-form `connect("x", self, "y")` | `grep -rnE "onready \|yield\(|\.instance\(\)|^tool\b|^export \|connect\(\"" scripts/` → must be empty |
| **Unity API bleed (C# projects)** | `UnityEngine`, `MonoBehaviour`, `GetComponent` | Only relevant in .NET projects; prefer GDScript to avoid entirely |
| **Invented UIDs / broken refs** | Load errors at import | Run `--import` gate after every scene edit |
| **Autoload order bugs** | Singleton accessed before init in `_init()` | Move access to `_ready()`; smoke run catches it |
| **Wrong callback** | Game logic in `_process()` that needs physics ticks | Use `_physics_process()` for movement/forces (`godot-physics` skill) |
| **Signal leaks** | Connections to freed nodes; crashes on scene change | Connect in `_ready()`, disconnect or use `CONNECT_ONE_SHOT`; review with `godot-code-review` skill |
| **Guessed external APIs** | Hallucinated plugin/engine methods | Only cite APIs found in the project's addons/docs or verified via `--check-only` passing |

## Editor vs Headless — When To Use Which

| Task | Tool |
|---|---|
| Script edits, tests, exports, CI, refactors | **Headless CLI (this skill)** |
| Visual layout polish, animation curves, theme tweaking | Editor GUI (human) or the package's `mcp-bridge/` MCP server for agent-driven editor control |
| Import cache issues | Always `--import` headless, never hand-fix `.godot/` |

## Related Skills

| Need | Skill |
|---|---|
| Scaffold the project | `godot-project-setup` |
| GDScript style & architecture decisions | `godot-gdscript-patterns`, `godot-brainstorming` |
| Review before merging features | `godot-code-review` |
| Diagnose failing smoke runs | `godot-debugging` |
| Ship fast on phones | `godot-performance` |
| Input handling, save systems, audio, shaders | `godot-input`, `godot-save-systems`, `godot-audio`, `godot-shaders-vfx` |

## References

- `references/testing.md` — gdUnit4 deep dive: suites, assertions, async, CI integration
- `references/exporting.md` — export presets, Android/iOS pipelines, store submission checklist
- `references/revenuecat.md` — RevenueCat plugin integration playbook for mobile games
