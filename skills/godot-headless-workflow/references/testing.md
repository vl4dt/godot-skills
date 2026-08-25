# gdUnit4 Testing Deep Dive

Standardize every Godot project on [gdUnit4](https://github.com/MikeSchulze/gdUnit4) — the
actively maintained test framework with a headless CLI runner built for CI and agents.

## Install

1. AssetLib → "gdUnit4" → Install (or add as git submodule under `addons/gdUnit4`)
2. Enable the addon in Project Settings → Plugins
3. Commit `addons/gdUnit4/` with the project so agents on fresh clones can run tests

## Layout

```
tests/
├── unit/          # pure logic: score, economy, state machines
│   └── test_score_manager.gd
├── integration/   # scenes wired together
└── fixtures/      # test data (.tres)
reports/           # generated HTML/XML — .gitignore this
```

## Suite Conventions

```gdscript
# tests/unit/test_score_manager.gd
class_name TestScoreManager
extends GdUnitTestSuite

const ScoreManager := preload("res://scripts/core/score_manager.gd")

var _sm

func before_test() -> void:
	_sm = ScoreManager.new()          # auto-freed after each test

func test_add_score_increments() -> void:
	_sm.add(10)
	assert_int(_sm.score).is_equal(10)

func test_score_never_negative() -> void:
	_sm.add(-5)
	assert_int(_sm.score).is_equal(0)

func test_addition_is_parameterized(a: int, b: int, expected: int) -> void:
	_sm.add(a + b)
	assert_int(_sm.score).is_equal(expected)   # supply via test-suite args or use fuzzers
```

Assertion helpers to know: `assert_int`, `assert_float`, `assert_str`, `assert_bool`,
`assert_that(expr)`, `assert_array`, `assert_dict`, `assert_object(obj).is_instanceof(...)`,
`assert_signal(spy).is_emitted("name")`. Full list in gdUnit4 docs.

## Async & Scene Tests

Await signals/frames inside tests — essential for scene-dependent logic:

```gdscript
func test_enemy_dies_after_hit() -> void:
	var enemy := auto_free(load("res://scenes/entities/enemy.tscn").instantiate())
	scene_runner().add_child(enemy)     # scene_runner() gives a managed tree context
	await get_tree().process_frame

	enemy.take_damage(enemy.hp)
	await assert_signal(enemy).is_emitted("died")
```

Keep rendering-dependent asserts out of headless runs: no pixel/screenshot checks in CI.

## Running From CLI

```bash
# everything under res://tests
addons/gdUnit4/runtest.cmd -a res://tests --continue       # Windows
./addons/gdUnit4/runtest.sh -a res://tests --continue      # Linux/macOS

# one suite only
addons/gdUnit4/runtest.cmd -a tests/unit/test_score_manager.gd

# filter by name pattern; stop-on-first-failure for fast loops
addons/gdUnit4/runtest.cmd -a res://tests --include test_score --no-failure
```

- Exit code 0 = all passed; non-zero = failures → CI/agent gate safe
- Reports: `res://reports/` (HTML + XML/JUnit)
- Runner is headless by default when no display is available

## Agent Workflow Integration

1. Write the failing test FIRST when fixing a bug (reproduce via test, then fix)
2. Run only the touched suite while iterating (`--include`), full suite before commit
3. If a test is flaky (async timing), fix the race condition — never delete the assertion
4. New feature ⇒ new suite; refactoring ⇒ tests unchanged, code changes

## Common Pitfalls

| Pitfall | Fix |
|---|---|
| Test class missing `class_name` / wrong base class | Must be `extends GdUnitTestSuite` + `class_name Test*` |
| Asserting inside awaited coroutines after timeout | Use `await assert_signal(...)` helpers, not manual timers |
| Scene loads but `_ready` errors | Run smoke test (`SKILL.md §Smoke run`) — it surfaces these |
| Tests pass alone, fail together | Suites sharing autoload state → reset in `before_test()` |
| Adding tests without enabling addon | `--import` + check plugin enabled in project.godot |
