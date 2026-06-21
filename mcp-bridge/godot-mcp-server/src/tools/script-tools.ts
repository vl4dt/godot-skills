/**
 * Script tools — Script creation, editing, and validation.
 *
 * Tools: script_create, script_edit, script_read, script_validate
 */

import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { z } from "zod";
import { GodotConnector } from "../godot-connector.js";

export function registerScriptTools(server: McpServer, connector: GodotConnector): void {
  // ── script_create ─────────────────────────────────────────────────

  server.registerTool(
    "script_create",
    {
      description: "Create a new script file and optionally attach it to a node in a scene.",
      inputSchema: z.object({
        path: z.string().describe("Destination path for the script (e.g. res://scripts/player.gd)"),
        attachedTo: z.string().optional().describe("Optional node path to attach this script to (e.g. \":Node2D/Player\")"),
        scenePath: z.string().optional().describe("Optional scene path if attaching to a node in a specific scene"),
      }),
    },
    async ({ path, attachedTo, scenePath }) => ({
      content: [{ type: "text", text: JSON.stringify(await connector.request("script_create", { path, attachedTo, scenePath }), null, 2) }],
    })
  );

  // ── script_edit ───────────────────────────────────────────────────

  server.registerTool(
    "script_edit",
    {
      description: "Overwrite the contents of a script file. Supports GDScript and C#.",
      inputSchema: z.object({
        path: z.string().describe("Path to the script file (e.g. res://scripts/player.gd)"),
        content: z.string().describe("Full file contents to write"),
      }),
    },
    async ({ path, content }) => ({
      content: [{ type: "text", text: JSON.stringify(await connector.request("script_edit", { path, content }), null, 2) }],
    })
  );

  // ── script_read ───────────────────────────────────────────────────

  server.registerTool(
    "script_read",
    {
      description: "Read the full contents of a script file.",
      inputSchema: z.object({
        path: z.string().describe("Path to the script file (e.g. res://scripts/player.gd)"),
      }),
    },
    async ({ path }) => ({
      content: [{ type: "text", text: JSON.stringify(await connector.request("script_read", { path }), null, 2) }],
    })
  );

  // ── script_validate ───────────────────────────────────────────────

  server.registerTool(
    "script_validate",
    {
      description: "Validate a GDScript or C# script for syntax errors and best practices. Supports Godot 4.7 tween_await() migration detection.",
      inputSchema: z.object({
        path: z.string().describe("Path to the script file to validate"),
        checkDeprecated: z.boolean().describe("Flag deprecated API usage").default(false),
        suggestTweenAwait: z.boolean().describe("Detect nested tween callback patterns and suggest await migration (Godot 4.7+)").default(false),
      }),
    },
    async ({ path, checkDeprecated, suggestTweenAwait }) => ({
      content: [{ type: "text", text: JSON.stringify(await connector.request("script_validate", { path, checkDeprecated, suggestTweenAwait }), null, 2) }],
    })
  );
}
