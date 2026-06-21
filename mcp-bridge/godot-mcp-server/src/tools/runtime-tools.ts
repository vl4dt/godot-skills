/**
 * Runtime tools — Scene run/stop/pause control and debugger output.
 *
 * Tools: scene_run, scene_stop, debugger_output, output_log, pause_resume
 */

import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { z } from "zod";
import { GodotConnector } from "../godot-connector.js";

export function registerRuntimeTools(server: McpServer, connector: GodotConnector): void {
  // ── scene_run ─────────────────────────────────────────────────────

  server.registerTool(
    "scene_run",
    {
      description: "Run the current or specified scene in the Godot editor.",
      inputSchema: z.object({
        scenePath: z.string().optional().describe("Optional path to a .tscn file to run (e.g. res://scenes/level.tscn). If omitted, runs the currently open scene."),
      }),
    },
    async ({ scenePath }) => ({
      content: [{ type: "text", text: JSON.stringify(await connector.request("scene_run", { scenePath }), null, 2) }],
    })
  );

  // ── scene_stop ────────────────────────────────────────────────────

  server.registerTool(
    "scene_stop",
    {
      description: "Stop the currently running scene.",
      inputSchema: z.object({}).strict(),
    },
    async () => ({
      content: [{ type: "text", text: JSON.stringify(await connector.request("scene_stop", {}), null, 2) }],
    })
  );

  // ── debugger_output ───────────────────────────────────────────────

  server.registerTool(
    "debugger_output",
    {
      description: "Read recent debugger output messages from the running scene.",
      inputSchema: z.object({
        lines: z.number().int().describe("Number of recent lines to retrieve").default(100),
        sinceTimestamp: z.number().nullable().optional().describe("Optional Unix timestamp to filter messages after"),
      }),
    },
    async ({ lines, sinceTimestamp }) => ({
      content: [{ type: "text", text: JSON.stringify(await connector.request("debugger_output", { lines, sinceTimestamp }), null, 2) }],
    })
  );

  // ── output_log ────────────────────────────────────────────────────

  server.registerTool(
    "output_log",
    {
      description: "Read the Godot output log with optional level filtering.",
      inputSchema: z.object({
        lines: z.number().int().describe("Number of recent lines to retrieve").default(50),
        level: z.enum(["all", "error", "warning", "info"]).describe("Filter by log level").default("all"),
      }),
    },
    async ({ lines, level }) => ({
      content: [{ type: "text", text: JSON.stringify(await connector.request("output_log", { lines, level }), null, 2) }],
    })
  );

  // ── pause_resume ──────────────────────────────────────────────────

  server.registerTool(
    "pause_resume",
    {
      description: "Pause or resume the currently running scene.",
      inputSchema: z.object({
        action: z.enum(["pause", "resume"]).describe("Action to perform"),
      }),
    },
    async ({ action }) => ({
      content: [{ type: "text", text: JSON.stringify(await connector.request("pause_resume", { action }), null, 2) }],
    })
  );
}
