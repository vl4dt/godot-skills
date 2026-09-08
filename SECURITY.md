# Security Policy

## Reporting a Vulnerability

Report vulnerabilities privately through
[GitHub Security Advisories](https://github.com/Narmo/godot-skills/security/advisories/new).
Please do not open a public issue for a security problem.

Include what the issue is, how to reproduce it, and what an attacker gains. Expect
an initial response within a week.

## Scope

This repository ships two kinds of content, and both are in scope:

- **The MCP bridge** (`mcp-bridge/`) — the server and the wire protocol it defines.
- **The skills and examples** (`skills/`, `examples/`) — these are copied into real
  games, so an insecure pattern documented here propagates downstream. Insecure
  guidance is a vulnerability in this repository, not just a documentation bug.

## Threat Model for the MCP Bridge

The bridge lets an AI agent write files into a project and run scenes, which is
arbitrary code execution by design. Its security therefore rests on two properties,
both specified in [`mcp-bridge/protocol.md`](mcp-bridge/protocol.md):

1. **Only the intended client can connect.** Binding to `127.0.0.1` is not
   sufficient: any local process can reach that port, and any web page the user
   visits can open a WebSocket to it, because browsers do not apply the same-origin
   policy to WebSockets. A conforming plugin requires a per-session token and
   rejects any handshake carrying an `Origin` header.
2. **File access stays inside the project.** `res://` is not a sandbox — Godot
   resolves `res://../..` and absolute host paths. A conforming plugin validates
   every path before opening it.

A plugin that skips either property turns the bridge into a remote shell. If you
find a released plugin that does, report it here as well as to its author.

## Known-Dangerous Godot Patterns

These come up repeatedly in game code and are treated as security bugs in this
repository:

- `ResourceLoader.load()` on any file the player or network can write (save games,
  downloaded content, mods). Loading a `.tres`/`.res` executes attached scripts.
  Use `FileAccess.store_var`/`get_var` with `allow_objects = false`, or JSON.
- `bytes_to_var(buf, true)` / `var_to_bytes_with_objects()` on untrusted input, for
  the same reason.
- Building a `load()` path out of RPC arguments or other remote input. Look the
  value up in a fixed table instead.
