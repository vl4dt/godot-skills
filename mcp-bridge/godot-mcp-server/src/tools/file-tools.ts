/**
 * File tools — Browse, read, write, search, and delete project files.
 *
 * Tools: file_browse, file_read, file_write, file_search, file_delete
 */

import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { z } from "zod";
import { GodotConnector } from "../godot-connector.js";

export function registerFileTools(server: McpServer, connector: GodotConnector): void {
  // ── file_browse ───────────────────────────────────────────────────

  server.registerTool(
    "file_browse",
    {
      description: "List files and directories in a project path.",
      inputSchema: z.object({
        path: z.string().describe("Directory path to browse (e.g. 'res://scenes' or 'res://scripts')"),
        recursive: z.boolean().describe("Recursively list all files").default(false),
        includeHidden: z.boolean().describe("Include hidden files and directories").default(false),
      }),
    },
    async ({ path, recursive, includeHidden }) => ({
      content: [{ type: "text", text: JSON.stringify(await connector.request("file_browse", { path, recursive, includeHidden }), null, 2) }],
    })
  );

  // ── file_read ─────────────────────────────────────────────────────

  server.registerTool(
    "file_read",
    {
      description: "Read a file from the project directory.",
      inputSchema: z.object({
        path: z.string().describe("Path to the file (e.g. 'res://scenes/player.tscn')"),
      }),
    },
    async ({ path }) => ({
      content: [{ type: "text", text: JSON.stringify(await connector.request("file_read", { path }), null, 2) }],
    })
  );

  // ── file_write ────────────────────────────────────────────────────

  server.registerTool(
    "file_write",
    {
      description: "Write or append to a file in the project directory. Requires explicit confirmation.",
      inputSchema: z.object({
        path: z.string().describe("Path to the file (e.g. 'res://scripts/player.gd')"),
        content: z.string().describe("Content to write"),
        append: z.boolean().describe("Append to file instead of overwriting").default(false),
      }),
    },
    async ({ path, content, append }) => ({
      content: [{ type: "text", text: JSON.stringify(await connector.request("file_write", { path, content, append }), null, 2) }],
    })
  );

  // ── file_search ───────────────────────────────────────────────────

  server.registerTool(
    "file_search",
    {
      description: "Search for a pattern across project files.",
      inputSchema: z.object({
        pattern: z.string().describe("Search pattern (supports basic regex)"),
        scope: z.string().describe("Directory to search within (default: res://)").default("res://"),
        caseSensitive: z.boolean().describe("Case-sensitive search").default(true),
        maxResults: z.number().int().describe("Maximum number of results to return").default(100),
      }),
    },
    async ({ pattern, scope, caseSensitive, maxResults }) => ({
      content: [{ type: "text", text: JSON.stringify(await connector.request("file_search", { pattern, scope, caseSensitive, maxResults }), null, 2) }],
    })
  );

  // ── file_delete ───────────────────────────────────────────────────

  server.registerTool(
    "file_delete",
    {
      description: "Delete a file from the project. This action cannot be undone.",
      inputSchema: z.object({
        path: z.string().describe("Path to the file to delete (e.g. 'res://scenes/unused.tscn')"),
      }),
    },
    async ({ path }) => ({
      content: [{ type: "text", text: JSON.stringify(await connector.request("file_delete", { path }), null, 2) }],
    })
  );
}
