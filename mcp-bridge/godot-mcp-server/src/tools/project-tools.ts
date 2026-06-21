/**
 * Project tools — Project settings management and class database queries.
 *
 * Tools: project_settings_read, project_settings_set, class_db_info
 */

import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { z } from "zod";
import { GodotConnector } from "../godot-connector.js";

export function registerProjectTools(server: McpServer, connector: GodotConnector): void {
  // ── project_settings_read ─────────────────────────────────────────

  server.registerTool(
    "project_settings_read",
    {
      description: "Read one or more project settings from the current Godot project.",
      inputSchema: z.object({
        filter: z.string().nullable().optional().describe("Optional glob pattern to filter setting names (e.g. 'rendering/*')"),
        keys: z.array(z.string()).optional().describe("Optional explicit list of setting keys to read"),
      }),
    },
    async ({ filter, keys }) => ({
      content: [{ type: "text", text: JSON.stringify(await connector.request("project_settings_read", { filter, keys }), null, 2) }],
    })
  );

  // ── project_settings_set ──────────────────────────────────────────

  server.registerTool(
    "project_settings_set",
    {
      description: "Set a project setting value. Use with caution — some settings require a project restart.",
      inputSchema: z.object({
        key: z.string().describe("Full setting path (e.g. 'rendering/hdr', 'steam/frame/enabled')"),
        value: z.unknown().describe("The value to set"),
      }),
    },
    async ({ key, value }) => ({
      content: [{ type: "text", text: JSON.stringify(await connector.request("project_settings_set", { key, value }), null, 2) }],
    })
  );

  // ── class_db_info ─────────────────────────────────────────────────

  server.registerTool(
    "class_db_info",
    {
      description: "Query the Godot class database for information about a specific class, including properties, signals, and methods.",
      inputSchema: z.object({
        className: z.string().describe("Godot class name (e.g. 'Node2D', 'CharacterBody3D', 'AreaLight3D')"),
        includeProperties: z.boolean().describe("Include property list").default(true),
        includeSignals: z.boolean().describe("Include signal list").default(true),
        includeMethods: z.boolean().describe("Include method list").default(false),
      }),
    },
    async ({ className, includeProperties, includeSignals, includeMethods }) => ({
      content: [{ type: "text", text: JSON.stringify(await connector.request("class_db_info", { className, includeProperties, includeSignals, includeMethods }), null, 2) }],
    })
  );
}
