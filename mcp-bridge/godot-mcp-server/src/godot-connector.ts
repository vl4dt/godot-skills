/**
 * GodotEditorConnector — Manages WebSocket connection to a running Godot 4.x editor.
 *
 * Implements JSON-RPC 2.0 over WebSocket with:
 * - Automatic reconnection with exponential backoff
 * - Request/response correlation via unique IDs
 * - Notification push handling (scene_changed, debug_message, etc.)
 * - Graceful disconnect and lifecycle management
 */

import { WebSocket } from "ws";

// ── Types ───────────────────────────────────────────────────────────

export interface GodotConnectionInfo {
  status: "connected" | "disconnected" | "connecting" | "reconnecting";
  godotVersion?: string;
  projectPath?: string;
  sessionId?: string;
  protocolVersion?: string;
}

interface RpcRequest {
  jsonrpc: "2.0";
  id: number;
  method: string;
  params?: Record<string, unknown>;
}

interface RpcResponse {
  jsonrpc: "2.0";
  id?: number;
  result?: unknown;
  error?: { code: number; message: string; data?: unknown };
}

type NotificationCallback = (method: string, params: Record<string, unknown>) => void;

// ── Error codes ─────────────────────────────────────────────────────

export const ERROR_CODES = {
  PARSE_ERROR: -32700,
  INVALID_REQUEST: -32600,
  METHOD_NOT_FOUND: -32601,
  INVALID_PARAMS: -32602,
  INTERNAL_ERROR: -32603,
  GODOT_NOT_RESPONDING: -32000,
  SCENE_NOT_FOUND: -32001,
  SCRIPT_VALIDATION_FAILED: -32002,
  PERMISSION_DENIED: -32003,
  NODE_NOT_FOUND: -32004,
  PROPERTY_NOT_FOUND: -32005,
  SCENE_RUNNING: -32006,
  FEATURE_NOT_AVAILABLE: -32007,
} as const;

// ── Connector class ─────────────────────────────────────────────────

export class GodotConnector {
  private ws: WebSocket | null = null;
  private nextId = 1;
  private pendingRequests: Map<
    number,
    { resolve: (v: unknown) => void; reject: (e: Error) => void; timer: ReturnType<typeof setTimeout> }
  > = new Map();
  private notificationListeners: Set<NotificationCallback> = new Set();
  private reconnectTimer: ReturnType<typeof setTimeout> | null = null;
  private reconnectAttempts = 0;
  private maxReconnectAttempts = 10;
  private baseReconnectDelay = 1000; // ms
  private maxReconnectDelay = 30000; // ms
  private _connectionInfo: GodotConnectionInfo = { status: "disconnected" };

  constructor(
    private wsUrl: string,
    private projectRoot: string
  ) {}

  get connectionInfo(): GodotConnectionInfo {
    return this._connectionInfo;
  }

  get isConnected(): boolean {
    return this.ws?.readyState === WebSocket.OPEN;
  }

  /** Connect to the Godot editor via WebSocket */
  async connect(): Promise<GodotConnectionInfo> {
    if (this.isConnected) return this._connectionInfo;

    this._connectionInfo = { ...this._connectionInfo, status: "connecting" };

    return new Promise((resolve, reject) => {
      try {
        this.ws = new WebSocket(this.wsUrl);

        this.ws.on("open", () => {
          console.error(`[godot-mcp] Connected to ${this.wsUrl}`);
          this.reconnectAttempts = 0;

          // Perform handshake
          const handshake: RpcRequest = {
            jsonrpc: "2.0",
            id: this.nextId++,
            method: "connect",
            params: {
              clientName: "godot-mcp-server",
              clientVersion: "0.2.0-alpha",
              features: ["scene", "script", "runtime", "project", "files", "viz"],
            },
          };

          this.trackRequest(handshake.id, (result) => {
            const info = result as GodotConnectionInfo & { status: string };
            if (info.status === "connected") {
              this._connectionInfo = {
                status: "connected",
                godotVersion: info.godotVersion,
                projectPath: info.projectPath,
                sessionId: info.sessionId,
                protocolVersion: info.protocolVersion,
              };
              resolve(this._connectionInfo);
            } else {
              reject(new Error(`Handshake failed: ${JSON.stringify(info)}`));
            }
          }, reject);

          // Timeout for handshake response
          setTimeout(() => {
            if (this.pendingRequests.has(handshake.id)) {
              this.pendingRequests.get(handshake.id)!.reject(
                new Error("Handshake timed out — is Godot 4.x running with the MCP plugin?")
              );
            }
          }, 10000);
        });

        this.ws.on("message", (data: Buffer) => this.handleMessage(data.toString()));

        this.ws.on("error", (err: Error) => {
          console.error(`[godot-mcp] WebSocket error: ${err.message}`);
          reject(err);
        });

        this.ws.on("close", (code: number, reason: Buffer) => {
          console.error(`[godot-mcp] Connection closed (code: ${code})`);
          this._connectionInfo = { ...this._connectionInfo, status: "disconnected" };
          this.notifyListeners("connection_lost", {});
          this.scheduleReconnect();
        });
      } catch (err) {
        reject(err);
      }
    });
  }

  /** Send a JSON-RPC request and return the result */
  async request(method: string, params?: Record<string, unknown>): Promise<unknown> {
    if (!this.isConnected) {
      await this.connect();
    }

    const id = this.nextId++;
    const message: RpcRequest = { jsonrpc: "2.0", id, method, params };

    return new Promise((resolve, reject) => {
      const timer = setTimeout(() => {
        this.pendingRequests.delete(id);
        reject(new Error(`RPC timeout for '${method}' after 30s`));
      }, 30000);

      this.trackRequest(id, resolve, reject, timer);

      try {
        this.ws!.send(JSON.stringify(message));
      } catch (err) {
        this.pendingRequests.delete(id);
        clearTimeout(timer);
        reject(new Error(`Failed to send request: ${(err as Error).message}`));
      }
    });
  }

  /** Subscribe to server notifications */
  onNotification(callback: NotificationCallback): void {
    this.notificationListeners.add(callback);
  }

  /** Unsubscribe from notifications */
  offNotification(callback: NotificationCallback): void {
    this.notificationListeners.delete(callback);
  }

  /** Gracefully disconnect */
  async disconnect(): Promise<void> {
    if (this.reconnectTimer) {
      clearTimeout(this.reconnectTimer);
      this.reconnectTimer = null;
    }

    // Cancel all pending requests
    for (const [id, track] of this.pendingRequests) {
      clearTimeout(track.timer);
      track.reject(new Error("Connector disconnected"));
    }
    this.pendingRequests.clear();

    if (this.ws) {
      this.ws.close(1000, "MCP server shutting down");
      this.ws = null;
    }

    this._connectionInfo = { ...this._connectionInfo, status: "disconnected" };
  }

  // ── Private helpers ───────────────────────────────────────────────

  private handleMessage(raw: string): void {
    let msg: RpcResponse;
    try {
      msg = JSON.parse(raw) as RpcResponse;
    } catch {
      return; // Invalid JSON — silently drop
    }

    if (msg.id !== undefined) {
      // Response to a pending request
      const track = this.pendingRequests.get(msg.id);
      if (track) {
        this.pendingRequests.delete(msg.id);
        clearTimeout(track.timer);
        if (msg.error) {
          track.reject(new GodotRpcError(msg.error.code, msg.error.message, msg.error.data));
        } else {
          track.resolve(msg.result ?? null);
        }
      }
    } else if ("method" in msg && "params" in msg) {
      // Notification (no id, has method)
      this.notifyListeners(msg.method as string, msg.params as Record<string, unknown>);
    }
  }

  private notifyListeners(method: string, params: Record<string, unknown>): void {
    for (const cb of this.notificationListeners) {
      try {
        cb(method, params);
      } catch (err) {
        console.error(`[godot-mcp] Notification handler error: ${(err as Error).message}`);
      }
    }
  }

  private trackRequest(
    id: number,
    resolve: (v: unknown) => void,
    reject: (e: Error) => void,
    timer?: ReturnType<typeof setTimeout>
  ): void {
    this.pendingRequests.set(id, {
      resolve,
      reject,
      timer: timer ?? setTimeout(() => {}, 0),
    });
  }

  private scheduleReconnect(): void {
    if (this.reconnectAttempts >= this.maxReconnectAttempts) {
      console.error("[godot-mcp] Max reconnection attempts reached. Giving up.");
      return;
    }

    this._connectionInfo = { ...this._connectionInfo, status: "reconnecting" };
    const delay = Math.min(
      this.baseReconnectDelay * Math.pow(2, this.reconnectAttempts),
      this.maxReconnectDelay
    );
    this.reconnectAttempts++;

    console.error(`[godot-mcp] Reconnecting in ${delay}ms (attempt ${this.reconnectAttempts}/${this.maxReconnectAttempts})`);

    this.reconnectTimer = setTimeout(async () => {
      try {
        await this.connect();
      } catch {
        // connect() will schedule another reconnect on close
      }
    }, delay);
  }
}

/** Custom error class for Godot RPC errors */
export class GodotRpcError extends Error {
  constructor(
    public readonly code: number,
    message: string,
    public readonly data?: unknown
  ) {
    super(`Godot RPC error [${code}]: ${message}`);
    this.name = "GodotRpcError";
  }
}
