/**
 * Scene tools — Scene tree inspection and modification.
 *
 * Tools: scene_tree, scene_create, scene_add_node, scene_remove_node,
 *        scene_move_node, scene_set_property, scene_set_property_batch
 */

import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { z } from "zod";
import { GodotConnector } from "../godot-connector.js";

// ── Schema helpers ──────────────────────────────────────────────────

const ScenePathSchema = z.string().optional();
const NodePathSchema = z.string();
const NodeTypeSchema = z.string();
const NodeNameSchema = z.string();
const PropertiesSchema = z.record(z.string(), z.unknown());

// ── Tool definitions ────────────────────────────────────────────────

export function registerSceneTools(server: McpServer, connector: GodotConnector): void {
  // ── scene_tree ────────────────────────────────────────────────────

  server.registerTool(
    "scene_tree",
    {
      description: "Get the complete scene tree structure of the current or specified scene file.",
      inputSchema: z.object({
        scenePath: ScenePathSchema.describe("Path to the .tscn file (relative to project root). If omitted, returns the currently open scene."),
        includeProperties: z.boolean().describe("Include node properties in the response").default(true),
        includeSignals: z.boolean().describe("Include node signals in the response").default(true),
        maxDepth: z.number().int().describe("Maximum depth to traverse (-1 for unlimited)").default(-1),
      }),
    },
    async ({ scenePath, includeProperties, includeSignals, maxDepth }) => ({
      content: [{ type: "text", text: JSON.stringify(await connector.request("scene_tree", { scenePath, includeProperties, includeSignals, maxDepth }), null, 2) }],
    })
  );

  // ── scene_create ──────────────────────────────────────────────────

  server.registerTool(
    "scene_create",
    {
      description: "Create a new scene file with a root node of the specified type.",
      inputSchema: z.object({
        path: z.string().describe("Destination path for the .tscn file (e.g. res://scenes/new_level.tscn)"),
        rootType: NodeTypeSchema.describe("Godot class name for the root node (e.g. Node2D, Control, CharacterBody3D)"),
        rootName: NodeNameSchema.describe("Name for the root node in the scene tree"),
      }),
    },
    async ({ path, rootType, rootName }) => ({
      content: [{ type: "text", text: JSON.stringify(await connector.request("scene_create", { path, rootType, rootName }), null, 2) }],
    })
  );

  // ── scene_add_node ────────────────────────────────────────────────

  server.registerTool(
    "scene_add_node",
    {
      description: 'Add a new node of the specified type to a scene at the given parent path. Supports Godot 4.7 nodes like AreaLight3D and VirtualJoystick.',
      inputSchema: z.object({
        scenePath: ScenePathSchema.describe("Path to the .tscn file"),
        parentPath: NodePathSchema.describe('Path of the parent node (e.g. ":Node2D" or ":Node2D/Sprite2D")'),
        nodeType: NodeTypeSchema.describe("Godot class name for the new node (e.g. Sprite2D, CollisionShape2D, AreaLight3D)"),
        nodeName: NodeNameSchema.describe("Name for the new node"),
        properties: PropertiesSchema.describe("Optional initial property values to set on the node"),
      }),
    },
    async ({ scenePath, parentPath, nodeType, nodeName, properties = {} }) => ({
      content: [{ type: "text", text: JSON.stringify(await connector.request("scene_add_node", { scenePath, parentPath, nodeType, nodeName, properties }), null, 2) }],
    })
  );

  // ── scene_remove_node ─────────────────────────────────────────────

  server.registerTool(
    "scene_remove_node",
    {
      description: "Remove a node from a scene by its path.",
      inputSchema: z.object({
        scenePath: ScenePathSchema.describe("Path to the .tscn file"),
        nodePath: NodePathSchema.describe('Path of the node to remove (e.g. ":Node2D/ChildNode")'),
      }),
    },
    async ({ scenePath, nodePath }) => ({
      content: [{ type: "text", text: JSON.stringify(await connector.request("scene_remove_node", { scenePath, nodePath }), null, 2) }],
    })
  );

  // ── scene_move_node ───────────────────────────────────────────────

  server.registerTool(
    "scene_move_node",
    {
      description: "Move a node to a new parent in the scene hierarchy.",
      inputSchema: z.object({
        scenePath: ScenePathSchema.describe("Path to the .tscn file"),
        nodePath: NodePathSchema.describe("Path of the node to move"),
        newParentPath: NodePathSchema.describe("Path of the new parent node"),
      }),
    },
    async ({ scenePath, nodePath, newParentPath }) => ({
      content: [{ type: "text", text: JSON.stringify(await connector.request("scene_move_node", { scenePath, nodePath, newParentPath }), null, 2) }],
    })
  );

  // ── scene_set_property ────────────────────────────────────────────

  server.registerTool(
    "scene_set_property",
    {
      description: "Set a single property on a node in the scene.",
      inputSchema: z.object({
        scenePath: ScenePathSchema.describe("Path to the .tscn file"),
        nodePath: NodePathSchema.describe("Path of the target node"),
        property: z.string().describe("Name of the property to set (e.g. position, texture, enabled)"),
        value: z.record(z.string(), z.unknown()).describe('The value to set. Use a JSON object for Vector2/Vector3, e.g. {"x": 100, "y": 200}'),
      }),
    },
    async ({ scenePath, nodePath, property, value }) => ({
      content: [{ type: "text", text: JSON.stringify(await connector.request("scene_set_property", { scenePath, nodePath, property, value }), null, 2) }],
    })
  );

  // ── scene_set_property_batch ──────────────────────────────────────

  server.registerTool(
    "scene_set_property_batch",
    {
      description: "Set multiple properties on a node atomically.",
      inputSchema: z.object({
        scenePath: ScenePathSchema.describe("Path to the .tscn file"),
        nodePath: NodePathSchema.describe("Path of the target node"),
        properties: z.array(z.object({ property: z.string(), value: z.unknown() })).describe("Array of {property, value} pairs to set atomically"),
      }),
    },
    async ({ scenePath, nodePath, properties }) => ({
      content: [{ type: "text", text: JSON.stringify(await connector.request("scene_set_property_batch", { scenePath, nodePath, properties }), null, 2) }],
    })
  );
}
