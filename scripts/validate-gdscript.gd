#!/usr/bin/env godot
# validate-gdscript.gd — Basic GDScript syntax validation
# Usage: godot --headless scripts/validate-gdscript.gd <path-to-script.gd>

@tool
extends SceneTree

func _init():
	var args = OS.get_cmdline_args()
	if args.is_empty():
		push_error("Usage: godot --headless validate-gdscript.gd <path>")
		quit(1)

	var script_path = args[0]
	var error = load(script_path)
	if error == null:
		print("VALID: ", script_path)
		quit(0)
	else:
		push_error("INVALID: ", script_path, " — ", error)
		quit(1)
