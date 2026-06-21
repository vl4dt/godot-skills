#!/usr/bin/env node
/**
 * Godot MCP Server — Main entry point
 *
 * Implements the Model Context Protocol (MCP) stdio transport,
 * connecting AI coding agents to a running Godot 4.x editor
 * via WebSocket on localhost:6789.
 *
 * Tool categories: scene, script, project, runtime, file, visualization
 */

import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { GodotConnector } from "./godot-connector.js";
import { registerSceneTools } from "./tools/scene-tools.js";
import { registerScriptTools } from "./tools/script-tools.js";
import { registerProjectTools } from "./tools/project-tools.js";
import { registerRuntimeTools } from "./tools/runtime-tools.js";
import { registerFileTools } from "./tools/file-tools.js";
import { registerVizTools } from "./tools/viz-tools.js";

const VERSION = "0.2.0-alpha";
const GODOT_WS_DEFAULT = "ws://127.0.0.1:6789";

async function main(): Promise<void> {
  // Parse command-line options
  const args = parseArgs(process.argv);
  const wsUrl = args.ws || GODOT_WS_DEFAULT;
  const projectRoot = args.project || process.cwd();

  // Create the MCP server
  const server = new McpServer({
    name: "godot-mcp-server",
    version: VERSION,
  });

  // Create the Godot editor connector (lazy-connects on first tool call)
  const connector = new GodotConnector(wsUrl, projectRoot);

  // Register all tool categories — each returns cleanup hooks
  registerSceneTools(server, connector);
  registerScriptTools(server, connector);
  registerProjectTools(server, connector);
  registerRuntimeTools(server, connector);
  registerFileTools(server, connector);
  registerVizTools(server, connector);

  // Connect to stdio transport (MCP client ↔ server communication)
  const transport = new StdioServerTransport();
  await server.connect(transport);

  console.error(
    `[godot-mcp-server v${VERSION}] Listening on stdio. ` +
    `Target Godot editor: ${wsUrl} | Project: ${projectRoot}`
  );

  // Graceful shutdown
  process.on("SIGINT", () => shutdown(server, connector));
  process.on("SIGTERM", () => shutdown(server, connector));
}

// ── Argument parsing ────────────────────────────────────────────────

interface CliArgs {
  ws?: string;
  project?: string;
}

function parseArgs(argv: string[]): CliArgs {
  const args: CliArgs = {};
  for (let i = 2; i < argv.length; i++) {
    switch (argv[i]) {
      case "--ws":
      case "-w":
        args.ws = argv[++i];
        break;
      case "--project":
      case "-p":
        args.project = argv[++i];
        break;
      case "--help":
      case "-h":
        printUsage();
        process.exit(0);
    }
  }
  return args;
}

function printUsage(): void {
  console.error(`
Godot MCP Server v${VERSION}

Usage: godot-mcp-server [options]

Options:
  -w, --ws <url>          WebSocket URL for Godot editor (default: ws://127.0.0.1:6789)
  -p, --project <path>    Project root directory (default: cwd)
  -h, --help              Show this help message

Tool Categories:
  scene      — Scene tree inspection and modification
  script     — Script creation, editing, validation
  project    — Project settings, class database queries
  runtime    — Run/stop/pause scenes, debugger output
  file       — Browse, read, write, search project files
  visualization — Generate project structure graphs

Example:
  godot-mcp-server -p /path/to/godot-project
`);
}

// ── Shutdown ────────────────────────────────────────────────────────

async function shutdown(server: McpServer, connector: GodotConnector): Promise<void> {
  console.error("[godot-mcp-server] Shutting down...");
  await connector.disconnect();
  await server.close();
  process.exit(0);
}

main().catch((err) => {
  console.error(`[godot-mcp-server] Fatal error: ${err.message}`);
  console.error(err.stack);
  process.exit(1);
});
