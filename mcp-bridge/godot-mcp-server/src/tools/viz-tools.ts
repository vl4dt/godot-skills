/**
 * Visualization tools — Project structure graph generation.
 *
 * Tools: map_project
 */

import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { z } from "zod";
import { GodotConnector } from "../godot-connector.js";

export function registerVizTools(server: McpServer, connector: GodotConnector): void {
  // ── map_project ───────────────────────────────────────────────────

  server.registerTool(
    "map_project",
    {
      description: "Generate a graph representation of the project structure showing scenes, scripts, and their dependencies. Useful for understanding large project layouts.",
      inputSchema: z.object({
        format: z.enum(["json", "html"]).describe("Output format").default("json"),
        includeTypes: z.boolean().describe("Include node type annotations in the graph").default(true),
        includeDependencies: z.boolean().describe("Show script-to-scene dependency edges").default(true),
        maxDepth: z.number().int().describe("Maximum directory depth to traverse (-1 for unlimited)").default(-1),
      }),
    },
    async ({ format, includeTypes, includeDependencies, maxDepth }) => {
      const result = await connector.request("map_project", { format, includeTypes, includeDependencies, maxDepth });

      if (format === "html") {
        return {
          content: [
            { type: "text", text: `# Project Map\n\nGenerate the following HTML file and open it in a browser:\n\n\`\`\`html\n${result}\n\`\`\`` },
          ],
        };
      }

      return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
    }
  );
}
