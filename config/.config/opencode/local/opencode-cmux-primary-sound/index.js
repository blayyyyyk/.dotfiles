// @bun
// src/config.ts
var TRUE_VALUES = new Set(["1", "true", "yes", "on"]);
var FALSE_VALUES = new Set(["0", "false", "no", "off"]);
function parseBoolean(value, fallback) {
  if (!value)
    return fallback;
  const normalized = value.trim().toLowerCase();
  if (TRUE_VALUES.has(normalized))
    return true;
  if (FALSE_VALUES.has(normalized))
    return false;
  return fallback;
}
function parseNumber(value, fallback) {
  if (!value)
    return fallback;
  const parsed = Number(value.trim());
  return Number.isFinite(parsed) ? parsed : fallback;
}
function parseTransport(value, fallback) {
  if (!value)
    return fallback;
  const normalized = value.trim().toLowerCase();
  if (normalized === "cli" || normalized === "socket" || normalized === "auto")
    return normalized;
  return fallback;
}
function loadConfig(env = process.env) {
  return {
    cmuxBin: env.OPENCODE_CMUX_BIN?.trim() || "cmux",
    statusKey: env.OPENCODE_CMUX_STATUS_KEY?.trim() || "opencode",
    transport: parseTransport(env.OPENCODE_CMUX_TRANSPORT, "auto"),
    notifySubagents: parseBoolean(env.OPENCODE_CMUX_NOTIFY_SUBAGENTS, false),
    logSubagents: parseBoolean(env.OPENCODE_CMUX_LOG_SUBAGENTS, true),
    progressEnabled: parseBoolean(env.OPENCODE_CMUX_PROGRESS, true),
    keepDoneStatus: parseBoolean(env.OPENCODE_CMUX_KEEP_DONE_STATUS, true),
    notifyQuestions: parseBoolean(env.OPENCODE_CMUX_NOTIFY_QUESTIONS, true),
    notifyPermissions: parseBoolean(env.OPENCODE_CMUX_NOTIFY_PERMISSIONS, true),
    logToolCalls: parseBoolean(env.OPENCODE_CMUX_LOG_TOOLS, true),
    logToolCallsVerbose: parseBoolean(env.OPENCODE_CMUX_LOG_TOOLS_VERBOSE, false),
    logFileEdits: parseBoolean(env.OPENCODE_CMUX_LOG_FILE_EDITS, true),
    logSessionLifecycle: parseBoolean(env.OPENCODE_CMUX_LOG_SESSION_LIFECYCLE, true),
    logTodos: parseBoolean(env.OPENCODE_CMUX_LOG_TODOS, true),
    gitIntegration: parseBoolean(env.OPENCODE_CMUX_GIT, true),
    staleSessionTimeoutMs: parseNumber(env.OPENCODE_CMUX_STALE_TIMEOUT, 0),
    doneTimeoutMs: parseNumber(env.OPENCODE_CMUX_DONE_TIMEOUT, 1e4)
  };
}

// src/cmux/detect.ts
import { statSync } from "fs";
import { homedir, tmpdir } from "os";
import { join } from "path";
function normalize(value) {
  const trimmed = value?.trim();
  return trimmed ? trimmed : undefined;
}
function checkSocketExists(socketPath) {
  if (socketPath.startsWith("\\\\.\\pipe\\"))
    return true;
  try {
    const stat = statSync(socketPath);
    return stat.isSocket();
  } catch {
    return false;
  }
}
function socketCandidates(env) {
  const candidates = [
    env.XDG_RUNTIME_DIR ? join(env.XDG_RUNTIME_DIR, "cmux.sock") : undefined,
    join(homedir(), "Library", "Application Support", "cmux", "cmux.sock"),
    join(homedir(), ".local", "share", "cmux", "cmux.sock"),
    join(tmpdir(), "cmux.sock"),
    "/tmp/cmux.sock"
  ];
  return [...new Set(candidates.filter((candidate) => !!candidate))];
}
function resolveSocketPath(env) {
  const explicit = normalize(env.CMUX_SOCKET_PATH) ?? normalize(env.CMUX_SOCKET);
  if (explicit)
    return explicit;
  const candidates = socketCandidates(env);
  return candidates.find(checkSocketExists) ?? candidates[0] ?? "/tmp/cmux.sock";
}
function detectCmuxEnvironment(env = process.env) {
  const socketPath = resolveSocketPath(env);
  const workspaceID = normalize(env.CMUX_WORKSPACE_ID);
  const tabID = normalize(env.CMUX_TAB_ID);
  const surfaceID = normalize(env.CMUX_SURFACE_ID);
  return {
    workspaceID,
    tabID,
    surfaceID,
    socketPath,
    isManagedWorkspace: workspaceID !== undefined,
    hasSocket: checkSocketExists(socketPath),
    termProgram: normalize(env.TERM_PROGRAM)
  };
}

// src/cmux/client.ts
import { spawn } from "child_process";

// src/cmux/commands.ts
function withWorkspace(args, workspaceID) {
  return workspaceID ? [...args, "--workspace", workspaceID] : args;
}
function buildNotifyCommand(payload, workspaceID, surfaceID) {
  const args = ["notify", "--title", payload.title];
  if (payload.subtitle)
    args.push("--subtitle", payload.subtitle);
  if (payload.body)
    args.push("--body", payload.body);
  const withContext = withWorkspace(args, workspaceID);
  return surfaceID ? [...withContext, "--surface", surfaceID] : withContext;
}
function buildClearNotificationsCommand(workspaceID) {
  return withWorkspace(["clear-notifications"], workspaceID);
}
function buildReportGitBranchCommand(branch, dirty, workspaceID) {
  const args = ["report-git-branch", branch];
  if (dirty)
    args.push("--status", "dirty");
  return withWorkspace(args, workspaceID);
}
function buildSetStatusCommand(key, payload, workspaceID) {
  const args = [
    "set-status",
    key,
    payload.text,
    "--icon",
    payload.icon,
    "--color",
    payload.color
  ];
  return withWorkspace(args, workspaceID);
}
function buildClearStatusCommand(key, workspaceID) {
  return withWorkspace(["clear-status", key], workspaceID);
}
function buildSetProgressCommand(payload, workspaceID) {
  return withWorkspace(["set-progress", payload.value.toFixed(2), "--label", payload.label], workspaceID);
}
function buildClearProgressCommand(workspaceID) {
  return withWorkspace(["clear-progress"], workspaceID);
}
function buildLogCommand(payload, workspaceID) {
  const args = [
    "log",
    "--level",
    payload.level,
    "--source",
    payload.source
  ];
  return withWorkspace([...args, "--", payload.message], workspaceID);
}
function buildClearLogCommand(workspaceID) {
  return withWorkspace(["clear-log"], workspaceID);
}
function quote(value) {
  if (!/[\s"|]/.test(value))
    return value;
  return `"${value.replace(/\\/g, "\\\\").replace(/"/g, "\\\"")}"`;
}
function withTab(command, workspaceID) {
  const base = workspaceID ? `${command} --tab=${workspaceID}` : command;
  return `${base}
`;
}
function buildSocketSetStatus(key, payload, workspaceID) {
  const command = `set_status ${key} ${quote(payload.text)} --icon=${payload.icon} --color=${payload.color}`;
  return withTab(command, workspaceID);
}
function buildSocketClearStatus(key, workspaceID) {
  return withTab(`clear_status ${key}`, workspaceID);
}
function buildSocketReportGitBranch(branch, dirty, workspaceID) {
  const command = `report_git_branch ${quote(branch)}${dirty ? " --status=dirty" : ""}`;
  return withTab(command, workspaceID);
}
function buildSocketSetProgress(payload, workspaceID) {
  const command = `set_progress ${payload.value.toFixed(2)} --label=${quote(payload.label)}`;
  return withTab(command, workspaceID);
}
function buildSocketClearProgress(workspaceID) {
  return withTab("clear_progress", workspaceID);
}
function buildSocketLog(payload, workspaceID) {
  let command = `log --level=${payload.level} --source=${payload.source}`;
  if (workspaceID)
    command += ` --tab=${workspaceID}`;
  command += ` -- ${quote(payload.message)}`;
  return `${command}
`;
}
function buildSocketClearLog(workspaceID) {
  return withTab("clear_log", workspaceID);
}
function buildJsonRpc(method, params, requestID) {
  const cleanParams = {};
  for (const [key, value] of Object.entries(params)) {
    if (value !== undefined) {
      cleanParams[key] = value;
    }
  }
  return JSON.stringify({ id: requestID, method, params: cleanParams }) + `
`;
}
function buildSocketNotify(payload, requestID, workspaceID, surfaceID) {
  return buildJsonRpc("notification.create", {
    title: payload.title,
    subtitle: payload.subtitle,
    body: payload.body,
    workspace_id: workspaceID,
    surface_id: surfaceID
  }, requestID);
}
function buildSocketClearNotifications(requestID) {
  return buildJsonRpc("notification.clear", {}, requestID);
}

// src/cmux/socket-client.ts
import { connect } from "net";
function socketWrite(options) {
  return new Promise((resolve) => {
    let settled = false;
    const settle = (outcome) => {
      if (settled)
        return;
      settled = true;
      resolve(outcome);
    };
    let socket;
    try {
      socket = connect({ path: options.socketPath });
    } catch (err) {
      const error = err instanceof Error ? err : new Error(String(err));
      const code = typeof err === "object" && err !== null && "code" in err ? String(err.code) : "UNKNOWN";
      settle({ error: { code, message: error.message } });
      return;
    }
    socket.setTimeout(options.timeoutMs);
    socket.on("connect", () => {
      socket.write(options.payload, (err) => {
        if (err) {
          socket.destroy();
          settle({ error: { code: "EWRITE", message: err.message } });
          return;
        }
        socket.destroy();
        settle({ response: "" });
      });
    });
    socket.on("timeout", () => {
      socket.destroy();
      settle({
        error: {
          code: "ETIMEDOUT",
          message: `Socket write timed out after ${options.timeoutMs}ms`
        }
      });
    });
    socket.on("error", (err) => {
      const code = typeof err === "object" && err !== null && "code" in err ? String(err.code) : "UNKNOWN";
      socket.destroy();
      settle({ error: { code, message: err.message } });
    });
  });
}
var DEFAULT_TIMEOUT_MS = 750;

class SocketCmuxClient {
  available;
  transport = "socket";
  preciseTabTargeting;
  workspaceID;
  tabID;
  surfaceID;
  requestCounter = 0;
  reportedConnectionFailure = false;
  connectionDisabled = false;
  socketPath;
  logger;
  timeoutMs;
  constructor(options) {
    this.socketPath = options.socketPath;
    this.workspaceID = options.workspaceID;
    this.tabID = options.tabID ?? options.workspaceID;
    this.surfaceID = options.surfaceID;
    this.preciseTabTargeting = options.preciseTabTargeting ?? options.tabID !== undefined;
    this.logger = options.logger;
    this.timeoutMs = options.timeoutMs ?? DEFAULT_TIMEOUT_MS;
    this.available = true;
  }
  async notify(payload) {
    const requestID = this.nextRequestID();
    const message = buildSocketNotify(payload, requestID, this.workspaceID, this.surfaceID);
    await this.sendJsonWrite(message, "notify");
  }
  async clearNotifications() {
    const message = buildSocketClearNotifications(this.nextRequestID());
    await this.sendJsonWrite(message, "notification.clear");
  }
  async setStatus(key, payload) {
    const message = buildSocketSetStatus(key, payload, this.tabID);
    await this.sendText(message, "set_status");
  }
  async clearStatus(key) {
    const message = buildSocketClearStatus(key, this.tabID);
    await this.sendText(message, "clear_status");
  }
  async setProgress(payload) {
    const message = buildSocketSetProgress(payload, this.tabID);
    await this.sendText(message, "set_progress");
  }
  async clearProgress() {
    const message = buildSocketClearProgress(this.tabID);
    await this.sendText(message, "clear_progress");
  }
  async log(payload) {
    const message = buildSocketLog(payload, this.tabID);
    await this.sendText(message, "log");
  }
  async clearLog() {
    const message = buildSocketClearLog(this.tabID);
    await this.sendText(message, "clear_log");
  }
  async reportGitBranch(branch, dirty) {
    const message = buildSocketReportGitBranch(branch, dirty, this.tabID);
    await this.sendText(message, "report_git_branch");
  }
  nextRequestID() {
    return `req-${++this.requestCounter}`;
  }
  async sendJsonWrite(payload, label) {
    if (this.connectionDisabled)
      return;
    const outcome = await socketWrite({
      socketPath: this.socketPath,
      payload,
      timeoutMs: this.timeoutMs
    });
    if (outcome.error) {
      this.handleError(outcome.error, label);
      return;
    }
  }
  async sendText(payload, label) {
    if (this.connectionDisabled)
      return;
    const outcome = await socketWrite({
      socketPath: this.socketPath,
      payload,
      timeoutMs: this.timeoutMs
    });
    if (outcome.error) {
      this.handleError(outcome.error, label);
    }
  }
  handleError(error, label) {
    const isConnectionFailure = error.code === "ECONNREFUSED" || error.code === "ENOENT";
    if (isConnectionFailure) {
      this.connectionDisabled = true;
      if (this.reportedConnectionFailure)
        return;
      this.reportedConnectionFailure = true;
    }
    this.logger.log("error", `cmux socket ${label} failed`, {
      code: error.code,
      error: error.message
    });
  }
}

// src/cmux/client.ts
function runCommand(binary, args) {
  return new Promise((resolve, reject) => {
    const child = spawn(binary, args, {
      env: process.env,
      stdio: ["ignore", "pipe", "pipe"]
    });
    let stdout = "";
    let stderr = "";
    child.stdout?.setEncoding("utf8");
    child.stderr?.setEncoding("utf8");
    child.stdout?.on("data", (chunk) => {
      stdout += chunk;
    });
    child.stderr?.on("data", (chunk) => {
      stderr += chunk;
    });
    child.once("error", reject);
    child.once("close", (exitCode, signal) => {
      resolve({
        exitCode: exitCode ?? 1,
        signal,
        stdout,
        stderr
      });
    });
  });
}

class CliCmuxClient {
  options;
  available;
  transport = "cli";
  preciseTabTargeting = false;
  workspaceID;
  tabID;
  surfaceID;
  reportedMissingBinary = false;
  constructor(options) {
    this.options = options;
    this.available = options.environment.isManagedWorkspace;
    this.workspaceID = options.environment.workspaceID;
    this.tabID = options.environment.tabID;
    this.surfaceID = options.environment.surfaceID;
  }
  async notify(payload) {
    await this.execute("notify", buildNotifyCommand(payload, this.workspaceID, this.surfaceID));
  }
  async clearNotifications() {
    await this.execute("clear-notifications", buildClearNotificationsCommand(this.workspaceID));
  }
  async setStatus(key, payload) {
    await this.execute("set-status", buildSetStatusCommand(key, payload, this.workspaceID));
  }
  async clearStatus(key) {
    await this.execute("clear-status", buildClearStatusCommand(key, this.workspaceID));
  }
  async setProgress(payload) {
    await this.execute("set-progress", buildSetProgressCommand(payload, this.workspaceID));
  }
  async clearProgress() {
    await this.execute("clear-progress", buildClearProgressCommand(this.workspaceID));
  }
  async log(payload) {
    await this.execute("log", buildLogCommand(payload, this.workspaceID));
  }
  async clearLog() {
    await this.execute("clear-log", buildClearLogCommand(this.workspaceID));
  }
  async reportGitBranch(branch, dirty) {
    await this.execute("report-git-branch", buildReportGitBranchCommand(branch, dirty, this.workspaceID));
  }
  async execute(label, args) {
    if (!this.available)
      return;
    try {
      const result = await runCommand(this.options.binary, args);
      if (result.exitCode === 0)
        return;
      await this.options.logger.log("warn", "cmux command exited unsuccessfully", {
        label,
        args,
        exitCode: result.exitCode,
        signal: result.signal,
        stderr: result.stderr.trim() || undefined,
        stdout: result.stdout.trim() || undefined
      });
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      const code = typeof error === "object" && error !== null && "code" in error ? String(error.code) : undefined;
      if (code === "ENOENT") {
        if (this.reportedMissingBinary)
          return;
        this.reportedMissingBinary = true;
      }
      await this.options.logger.log("error", "Failed to execute cmux command", {
        label,
        args,
        code,
        error: message
      });
    }
  }
}
function shouldUseSocket(transport, env, logger) {
  if (transport === "cli")
    return false;
  if (transport === "socket") {
    if (!env.hasSocket) {
      logger.log("warn", "Socket transport requested but socket not found, falling back to CLI", { socketPath: env.socketPath });
      return false;
    }
    return true;
  }
  return env.hasSocket;
}
function createCmuxClient(options) {
  const useSocket = shouldUseSocket(options.transport, options.environment, options.logger);
  if (useSocket) {
    if (!options.environment.tabID) {
      options.logger.log("warn", "CMUX_TAB_ID missing; sidebar updates may affect other tabs in this workspace", { workspaceID: options.environment.workspaceID });
    }
    return new SocketCmuxClient({
      socketPath: options.environment.socketPath,
      workspaceID: options.environment.workspaceID,
      tabID: options.environment.tabID ?? options.environment.workspaceID,
      surfaceID: options.environment.surfaceID,
      preciseTabTargeting: options.environment.tabID !== undefined,
      logger: options.logger
    });
  }
  return new CliCmuxClient(options);
}

// src/events.ts
function asRecord(value) {
  return typeof value === "object" && value !== null ? value : undefined;
}
function getString(record, keys) {
  for (const key of keys) {
    const value = record[key];
    if (typeof value === "string" && value.trim()) {
      return value.trim();
    }
  }
  return;
}
function readSessionID(properties) {
  const direct = getString(properties, ["sessionID", "sessionId", "id"]);
  if (direct)
    return direct;
  for (const key of ["session", "info", "data"]) {
    const record = asRecord(properties[key]);
    if (!record)
      continue;
    const nested = getString(record, ["sessionID", "sessionId", "id"]);
    if (nested)
      return nested;
  }
  return;
}
function describeToolCall(tool, args) {
  if (!args)
    return tool;
  switch (tool) {
    case "bash": {
      const cmd = getString(args, ["command", "cmd"]);
      if (cmd) {
        const short = cmd.length > 60 ? `${cmd.slice(0, 57)}...` : cmd;
        return `bash: ${short}`;
      }
      return "bash";
    }
    case "edit":
    case "write":
    case "read": {
      const path = getString(args, ["filePath", "path", "file"]);
      if (path) {
        const segments = path.split("/");
        const short = segments.length > 2 ? segments.slice(-2).join("/") : segments.join("/");
        return `${tool}: ${short}`;
      }
      return tool;
    }
    case "glob": {
      const pattern = getString(args, ["pattern", "glob"]);
      return pattern ? `glob: ${pattern}` : "glob";
    }
    case "grep": {
      const pattern = getString(args, ["pattern", "query"]);
      return pattern ? `grep: ${pattern}` : "grep";
    }
    default:
      return tool;
  }
}
function toRelativePath(filePath, projectRoot) {
  if (!projectRoot)
    return filePath;
  const root = projectRoot.endsWith("/") ? projectRoot : `${projectRoot}/`;
  if (filePath.startsWith(root)) {
    return filePath.slice(root.length);
  }
  return filePath;
}
function normalizeEvent(event) {
  const properties = event.properties ?? {};
  switch (event.type) {
    case "session.status": {
      const sessionID = readSessionID(properties);
      const statusValue = properties.status;
      const statusRecord = asRecord(statusValue);
      const status = typeof statusValue === "string" && statusValue.trim() || statusRecord && getString(statusRecord, ["type"]);
      if (!sessionID || !status)
        return null;
      return { type: "session.status", sessionID, status };
    }
    case "session.idle": {
      const sessionID = readSessionID(properties);
      if (!sessionID)
        return null;
      return { type: "session.idle", sessionID };
    }
    case "session.error": {
      return { type: "session.error", sessionID: readSessionID(properties) };
    }
    case "question.asked": {
      const header = getString(properties, ["header", "title", "message"]) ?? (() => {
        const questions = properties.questions;
        if (!Array.isArray(questions))
          return;
        for (const question of questions) {
          const record = asRecord(question);
          if (!record)
            continue;
          const value = getString(record, ["header", "title", "message"]);
          if (value)
            return value;
        }
        return;
      })();
      if (!header)
        return null;
      return {
        type: "question.asked",
        header,
        sessionID: readSessionID(properties)
      };
    }
    case "question.replied":
    case "question.rejected":
      return { type: "question.resolved" };
    case "permission.replied":
      return { type: "permission.replied" };
    case "file.edited": {
      const filePath = getString(properties, ["filePath", "path", "file"]);
      if (!filePath)
        return null;
      return {
        type: "file.edited",
        filePath,
        sessionID: readSessionID(properties)
      };
    }
    case "session.created": {
      const sessionID = readSessionID(properties);
      if (!sessionID)
        return null;
      return { type: "session.created", sessionID };
    }
    case "session.updated": {
      const sessionID = readSessionID(properties);
      if (!sessionID)
        return null;
      return { type: "session.updated", sessionID };
    }
    case "session.deleted": {
      const sessionID = readSessionID(properties);
      if (!sessionID)
        return null;
      return { type: "session.deleted", sessionID };
    }
    case "session.compacted": {
      const sessionID = readSessionID(properties);
      if (!sessionID)
        return null;
      return { type: "session.compacted", sessionID };
    }
    case "todo.updated": {
      const rawItems = properties.items ?? properties.todos ?? properties.list;
      const items = [];
      if (Array.isArray(rawItems)) {
        for (const raw of rawItems) {
          const record = asRecord(raw);
          if (!record)
            continue;
          const text = getString(record, ["text", "content", "title"]);
          if (!text)
            continue;
          items.push({
            text,
            completed: record.completed === true || record.status === "completed" || record.done === true
          });
        }
      }
      return { type: "todo.updated", items };
    }
    default:
      return null;
  }
}

// src/logger.ts
var SERVICE = "opencode-cmux";
function createPluginLogger(client) {
  return {
    async log(level, message, extra) {
      if (!client.app?.log)
        return;
      try {
        await client.app.log({
          body: {
            service: SERVICE,
            level,
            message,
            extra
          }
        });
      } catch (error) {
        console.warn("[opencode-cmux] failed to write plugin log", error);
      }
    }
  };
}

// src/opencode/session-resolver.ts
var NEGATIVE_CACHE_TTL_MS = 5000;
var PRIMARY_ATTENTION_MARKER = "[[opencode-main-attention]] ";

class OpencodeSessionResolver {
  client;
  logger;
  cache = new Map;
  failedAt = new Map;
  constructor(client, logger) {
    this.client = client;
    this.logger = logger;
  }
  async getSessionMetadata(sessionID, options = {}) {
    const cached = this.cache.get(sessionID);
    if (cached && !options.fresh)
      return cached;
    const lastFail = this.failedAt.get(sessionID);
    if (lastFail && Date.now() - lastFail < NEGATIVE_CACHE_TTL_MS) {
      return { id: sessionID, title: sessionID, kind: "primary", ancestryVerified: false };
    }
    if (!this.client.session?.get) {
      this.failedAt.set(sessionID, Date.now());
      await this.logger.log("warn", "Session client unavailable; using fallback metadata", {
        sessionID
      });
      return { id: sessionID, title: sessionID, kind: "primary", ancestryVerified: false };
    }
    try {
      const result = await this.client.session.get({ path: { id: sessionID } });
      const summary = result.data;
      const metadata = {
        id: sessionID,
        title: summary?.title?.trim() || sessionID,
        parentID: summary?.parentID,
        kind: summary?.parentID ? "subagent" : "primary",
        ancestryVerified: true
      };
      this.cache.set(sessionID, metadata);
      this.failedAt.delete(sessionID);
      return metadata;
    } catch (error) {
      this.failedAt.set(sessionID, Date.now());
      await this.logger.log("warn", "Failed to resolve session metadata; using fallback", {
        sessionID,
        error: error instanceof Error ? error.message : String(error)
      });
      return { id: sessionID, title: sessionID, kind: "primary", ancestryVerified: false };
    }
  }
}

// src/state/project-context.ts
import { basename } from "path";
function resolveProjectContext(ctx) {
  const root = ctx.worktree ?? ctx.project?.worktree ?? ctx.directory;
  const label = root ? basename(root) : ctx.project?.id ?? "project";
  return {
    id: ctx.project?.id ?? label,
    label,
    root
  };
}

// src/features/git.ts
import { spawnSync } from "child_process";
function runGit(cwd, args) {
  const result = spawnSync("git", args, {
    cwd,
    encoding: "utf8",
    stdio: ["ignore", "pipe", "ignore"],
    timeout: 500
  });
  if (result.error || result.status !== 0) {
    return { ok: false, stdout: "" };
  }
  return { ok: true, stdout: typeof result.stdout === "string" ? result.stdout : "" };
}
function detectGitInfo(cwd) {
  const branchResult = runGit(cwd, ["branch", "--show-current"]);
  if (!branchResult.ok)
    return { branch: null, dirty: false };
  const branch = branchResult.stdout.trim();
  if (!branch)
    return { branch: null, dirty: false };
  const dirtyResult = runGit(cwd, ["status", "--porcelain"]);
  const dirty = dirtyResult.ok && dirtyResult.stdout.trim().length > 0;
  return { branch, dirty };
}
function isGitCommand(command) {
  return /\bgit(\s|$)/.test(command.trim());
}

// src/state/progress-tracker.ts
var BASE_PROGRESS = 0.1;
var TOOL_WEIGHT = 0.6;
var TOOL_STEEPNESS = 0.15;
var TIME_WEIGHT = 0.1;
var TIME_HALF_LIFE_MS = 120000;
var TODO_WEIGHT = 0.4;
var WAITING_FLOOR = 0.5;

class ProgressTracker {
  toolCalls = 0;
  startedAt;
  todoTotal = 0;
  todoCompleted = 0;
  highWaterMark = 0;
  start() {
    this.startedAt = Date.now();
  }
  recordToolCall() {
    this.toolCalls++;
  }
  updateTodos(total, completed) {
    this.todoTotal = total;
    this.todoCompleted = completed;
  }
  estimate(phase = "working", now = Date.now()) {
    if (phase === "idle")
      return 1;
    const toolSignal = BASE_PROGRESS + TOOL_WEIGHT * (1 - 1 / (1 + this.toolCalls * TOOL_STEEPNESS));
    let timeSignal = 0;
    if (this.startedAt !== undefined) {
      const elapsed = Math.max(0, now - this.startedAt);
      timeSignal = TIME_WEIGHT * (1 - Math.exp(-elapsed * Math.LN2 / TIME_HALF_LIFE_MS));
    }
    let todoSignal = 0;
    if (this.todoTotal > 0) {
      todoSignal = TODO_WEIGHT * (this.todoCompleted / this.todoTotal);
    }
    let raw;
    if (this.todoTotal > 0) {
      raw = toolSignal * 0.5 + todoSignal + BASE_PROGRESS * 0.5;
    } else {
      raw = toolSignal + timeSignal;
    }
    raw = Math.min(0.95, Math.max(0, raw));
    if (phase === "waiting") {
      raw = Math.max(WAITING_FLOOR, raw);
    }
    if (raw > this.highWaterMark) {
      this.highWaterMark = raw;
    }
    return this.highWaterMark;
  }
  reset() {
    this.toolCalls = 0;
    this.startedAt = undefined;
    this.todoTotal = 0;
    this.todoCompleted = 0;
    this.highWaterMark = 0;
  }
}

// src/state/session-state.ts
function formatSessionLabel(session) {
  const title = session.title.trim();
  return title || session.id;
}
function getBusySubagentCount(sessions) {
  let count = 0;
  for (const session of sessions) {
    if (session.metadata.kind === "subagent" && session.activity === "busy") {
      count += 1;
    }
  }
  return count;
}

// src/state/presenter.ts
var FILE_EDIT_DEBOUNCE_MS = 500;
var MAX_RECENT_FILES = 10;
var RENDER_THROTTLE_MS = 200;
var LOG_RATE_LIMIT = 5;
var LOG_RATE_WINDOW_MS = 1000;
var LEGACY_EXTRA_STATUS_KEYS = ["tools", "subagents", "todos"];

class CmuxStateCoordinator {
  options;
  sessions = new Map;
  primaryState;
  pendingQuestion;
  pendingPermission;
  currentSnapshot = {};
  activeTools = new Map;
  toolCallCount = 0;
  recentFiles = [];
  lastFileEditAt = new Map;
  todoState;
  progressTracker = new ProgressTracker;
  lastRenderAt = 0;
  renderTimer;
  renderPending = false;
  logTimestamps = [];
  lastEventAt = 0;
  staleTimer;
  doneTimer;
  constructor(options) {
    this.options = options;
  }
  async initialize() {
    await this.clearPresentationOnStartupBestEffort();
  }
  async cleanup() {
    await this.flush();
    this.primaryState = undefined;
    this.pendingQuestion = undefined;
    this.pendingPermission = undefined;
    this.activeTools.clear();
    this.todoState = undefined;
    this.progressTracker.reset();
    if (this.staleTimer) {
      clearTimeout(this.staleTimer);
      this.staleTimer = undefined;
    }
    if (this.doneTimer) {
      clearTimeout(this.doneTimer);
      this.doneTimer = undefined;
    }
    await this.clearPresentationBestEffort();
    this.currentSnapshot = {};
  }
  touchEventTimestamp() {
    this.lastEventAt = Date.now();
    this.resetStaleTimer();
  }
  async handleSessionStatus(sessionID, status) {
    this.touchEventTimestamp();
    if (status === "busy") {
      await this.markBusy(sessionID);
      return;
    }
    if (status === "idle") {
      await this.markIdle(sessionID);
    }
  }
  async handleSessionIdle(sessionID) {
    this.touchEventTimestamp();
    await this.markIdle(sessionID);
  }
  async handleSessionError(sessionID) {
    this.touchEventTimestamp();
    const metadata = await this.resolveSession(sessionID ?? "unknown-session", true);
    if (!metadata)
      return;
    this.setSessionActivity(metadata, "error");
    this.primaryState = metadata.kind === "primary" ? this.sessions.get(metadata.id) : this.primaryState;
    if (metadata.kind === "primary") {
      this.pendingPermission = undefined;
      this.pendingQuestion = undefined;
      this.clearTransientAuxiliaryState();
      await this.options.cmux.notify({
        title: `Error: ${this.options.project.label}`,
        body: formatSessionLabel(metadata)
      });
    } else if (this.options.config.notifySubagents) {
      await this.options.cmux.notify({
        title: `Subagent error: ${this.options.project.label}`,
        body: formatSessionLabel(metadata)
      });
    }
    await this.throttledLog({
      level: "error",
      source: "opencode",
      message: `${this.options.project.label}: error in ${formatSessionLabel(metadata)}`
    });
    await this.render();
  }
  async handleQuestionAsked(header, sessionID) {
    this.touchEventTimestamp();
    const nextQuestion = { header, sessionID };
    if (this.pendingQuestion?.header === nextQuestion.header && this.pendingQuestion?.sessionID === nextQuestion.sessionID) {
      return;
    }
    this.pendingQuestion = nextQuestion;
    await this.throttledLog({
      level: "info",
      source: "opencode",
      message: `${this.options.project.label}: question - ${header}`
    });
    if (this.options.config.notifyQuestions) {
      const metadata = sessionID ? await this.resolveSession(sessionID, true) : undefined;
      const marker = metadata?.kind === "primary" && metadata.ancestryVerified ? PRIMARY_ATTENTION_MARKER : "";
      await this.options.cmux.notify({
        title: `${marker}Question: ${this.options.project.label}`,
        body: header
      });
    }
    await this.render();
  }
  async handleQuestionResolved() {
    this.touchEventTimestamp();
    if (!this.pendingQuestion)
      return;
    this.pendingQuestion = undefined;
    await this.render();
  }
  async handlePermissionAsked(title, sessionID) {
    this.touchEventTimestamp();
    if (this.pendingPermission?.title === title)
      return;
    this.pendingPermission = { title };
    await this.throttledLog({
      level: "warning",
      source: "opencode",
      message: `${this.options.project.label}: waiting for permission - ${title}`
    });
    if (this.options.config.notifyPermissions) {
      const metadata = sessionID ? await this.resolveSession(sessionID, true) : undefined;
      const marker = metadata?.kind === "primary" && metadata.ancestryVerified ? PRIMARY_ATTENTION_MARKER : "";
      await this.options.cmux.notify({
        title: `${marker}Permission needed: ${this.options.project.label}`,
        subtitle: title
      });
    }
    await this.render();
  }
  async handlePermissionResolved() {
    this.touchEventTimestamp();
    if (!this.pendingPermission)
      return;
    this.pendingPermission = undefined;
    await this.render();
  }
  async handleToolStarted(tool, args) {
    this.touchEventTimestamp();
    await this.clearNotificationsBestEffort();
    const callID = `${tool}-${++this.toolCallCount}`;
    this.activeTools.set(callID, {
      tool,
      startedAt: Date.now(),
      args
    });
    this.progressTracker.recordToolCall();
    if (this.options.config.logToolCalls) {
      const label = describeToolCall(tool, args);
      const verbose = this.options.config.logToolCallsVerbose && args ? ` ${JSON.stringify(args)}` : "";
      await this.throttledLog({
        level: "progress",
        source: "opencode",
        message: `${this.options.project.label}: running ${label}${verbose}`
      });
    }
    await this.render();
  }
  async handleToolCompleted(tool, args) {
    this.touchEventTimestamp();
    for (const [callID, active] of this.activeTools) {
      if (active.tool === tool) {
        this.activeTools.delete(callID);
        break;
      }
    }
    if (this.options.config.logToolCalls) {
      const label = describeToolCall(tool, args);
      const verbose = this.options.config.logToolCallsVerbose && args ? ` ${JSON.stringify(args)}` : "";
      await this.throttledLog({
        level: "info",
        source: "opencode",
        message: `${this.options.project.label}: finished ${label}${verbose}`
      });
    }
    await this.refreshGitStateIfNeeded(tool, args);
    await this.render();
  }
  async handleFileEdited(filePath, _sessionID) {
    this.touchEventTimestamp();
    const relative = toRelativePath(filePath, this.options.project.root);
    const now = Date.now();
    const lastEdit = this.lastFileEditAt.get(relative);
    if (lastEdit !== undefined && now - lastEdit < FILE_EDIT_DEBOUNCE_MS) {
      return;
    }
    this.lastFileEditAt.set(relative, now);
    const existingIndex = this.recentFiles.indexOf(relative);
    if (existingIndex !== -1) {
      this.recentFiles.splice(existingIndex, 1);
    }
    this.recentFiles.push(relative);
    if (this.recentFiles.length > MAX_RECENT_FILES) {
      const evicted = this.recentFiles.shift();
      if (evicted !== undefined)
        this.lastFileEditAt.delete(evicted);
    }
    if (this.options.config.logFileEdits) {
      await this.throttledLog({
        level: "progress",
        source: "opencode",
        message: `${this.options.project.label}: edited ${relative}`
      });
    }
  }
  async handleSessionCreated(sessionID) {
    this.touchEventTimestamp();
    const metadata = await this.resolveSession(sessionID, true);
    if (metadata?.kind === "primary") {
      await this.clearPresentationBestEffort();
      this.currentSnapshot = {};
    } else {
      await this.clearNotificationsBestEffort();
    }
    if (this.options.config.logSessionLifecycle) {
      const label = metadata ? formatSessionLabel(metadata) : sessionID;
      await this.throttledLog({
        level: "info",
        source: "opencode",
        message: `${this.options.project.label}: session started - ${label}`
      });
    }
  }
  async handleSessionUpdated(sessionID) {
    this.touchEventTimestamp();
    const metadata = await this.resolveSession(sessionID, true);
    if (!metadata)
      return;
    const existing = this.sessions.get(sessionID);
    if (existing) {
      this.setSessionActivity(metadata, existing.activity);
      if (metadata.kind === "primary") {
        this.primaryState = this.sessions.get(sessionID);
        if (existing.activity === "busy" && this.options.config.logSessionLifecycle) {
          await this.throttledLog({
            level: "progress",
            source: "opencode",
            message: `${this.options.project.label}: working on ${formatSessionLabel(metadata)}`
          });
        }
      }
      await this.render();
    }
  }
  async handleSessionDeleted(sessionID) {
    this.touchEventTimestamp();
    const existing = this.sessions.get(sessionID);
    const metadata = await this.resolveSession(sessionID, true) ?? existing?.metadata;
    this.sessions.delete(sessionID);
    if (metadata?.kind === "primary") {
      this.primaryState = undefined;
      this.pendingQuestion = undefined;
      this.pendingPermission = undefined;
      this.activeTools.clear();
      this.todoState = undefined;
      this.progressTracker.reset();
      if (this.doneTimer) {
        clearTimeout(this.doneTimer);
        this.doneTimer = undefined;
      }
    }
    if (this.options.config.logSessionLifecycle) {
      const label = metadata ? formatSessionLabel(metadata) : sessionID;
      await this.throttledLog({
        level: "info",
        source: "opencode",
        message: `${this.options.project.label}: session deleted - ${label}`
      });
    }
    if (metadata?.kind === "primary") {
      await this.cleanup();
      return;
    }
    await this.render();
  }
  async handleSessionCompacted(sessionID) {
    this.touchEventTimestamp();
    if (this.options.config.logSessionLifecycle) {
      const metadata = await this.resolveSession(sessionID, true);
      const label = metadata ? formatSessionLabel(metadata) : sessionID;
      await this.throttledLog({
        level: "info",
        source: "opencode",
        message: `${this.options.project.label}: session compacted - ${label}`
      });
    }
  }
  async handleTodoUpdated(items) {
    this.touchEventTimestamp();
    const total = items.length;
    const completed = items.filter((item) => item.completed).length;
    this.todoState = { total, completed };
    this.progressTracker.updateTodos(total, completed);
    if (this.options.config.logTodos) {
      await this.throttledLog({
        level: "progress",
        source: "opencode",
        message: `${this.options.project.label}: todos: ${completed}/${total} complete`
      });
    }
    await this.render();
  }
  async syncGitState() {
    if (!this.options.config.gitIntegration)
      return;
    const root = this.options.project.root;
    if (!root)
      return;
    try {
      const gitInfo = detectGitInfo(root);
      if (!gitInfo.branch)
        return;
      await this.options.cmux.reportGitBranch(gitInfo.branch, gitInfo.dirty);
    } catch {}
  }
  async markBusy(sessionID) {
    const metadata = await this.resolveSession(sessionID, true);
    if (!metadata)
      return;
    const previous = this.sessions.get(sessionID);
    this.setSessionActivity(metadata, "busy");
    if (metadata.kind === "primary") {
      this.primaryState = this.sessions.get(sessionID);
      this.resetStaleTimer();
      if (this.doneTimer) {
        clearTimeout(this.doneTimer);
        this.doneTimer = undefined;
      }
      if (previous?.activity !== "busy") {
        this.progressTracker.start();
        await this.throttledLog({
          level: "progress",
          source: "opencode",
          message: `${this.options.project.label}: working on ${formatSessionLabel(metadata)}`
        });
      }
    } else if (this.options.config.logSubagents && previous?.activity !== "busy") {
      await this.throttledLog({
        level: "info",
        source: "opencode",
        message: `${this.options.project.label}: subagent started - ${formatSessionLabel(metadata)}`
      });
    }
    await this.render();
  }
  async markIdle(sessionID) {
    const metadata = await this.resolveSession(sessionID, true);
    if (!metadata)
      return;
    const previous = this.sessions.get(sessionID);
    this.setSessionActivity(metadata, "idle");
    if (metadata.kind === "primary") {
      this.primaryState = this.sessions.get(sessionID);
      this.pendingPermission = undefined;
      if (this.pendingQuestion?.sessionID === undefined || this.pendingQuestion?.sessionID === sessionID) {
        this.pendingQuestion = undefined;
      }
      if (previous?.activity === "busy") {
        this.clearTransientAuxiliaryState();
        this.progressTracker.reset();
        await this.renderNow();
        await this.throttledLog({
          level: "success",
          source: "opencode",
          message: `${this.options.project.label}: done - ${formatSessionLabel(metadata)}`
        });
        await this.options.cmux.notify({
          title: `${metadata.ancestryVerified ? PRIMARY_ATTENTION_MARKER : ""}Done: ${this.options.project.label}`,
          body: formatSessionLabel(metadata)
        });
        await this.clearCompletedProgressBestEffort();
      }
    } else {
      if (this.options.config.logSubagents && previous?.activity === "busy") {
        await this.throttledLog({
          level: "success",
          source: "opencode",
          message: `${this.options.project.label}: subagent finished - ${formatSessionLabel(metadata)}`
        });
      }
      if (this.options.config.notifySubagents && previous?.activity === "busy") {
        await this.options.cmux.notify({
          title: `Subagent done: ${this.options.project.label}`,
          body: formatSessionLabel(metadata)
        });
      }
    }
    if (metadata.kind !== "primary" || previous?.activity !== "busy") {
      await this.render();
    }
    this.resetDoneTimer();
  }
  async resolveSession(sessionID, fresh = false) {
    return this.options.sessionResolver.getSessionMetadata(sessionID, { fresh });
  }
  async clearNotificationsBestEffort() {
    try {
      await this.options.cmux.clearNotifications();
    } catch {}
  }
  async clearCompletedProgressBestEffort() {
    try {
      await this.options.cmux.clearProgress();
    } catch {}
  }
  hasLivePresentationState() {
    return !!(this.primaryState || this.pendingQuestion || this.pendingPermission || this.activeTools.size > 0 || this.currentSnapshot.status || this.currentSnapshot.progress);
  }
  async clearPresentationOnStartupBestEffort() {
    if (!this.canClearPresentationSafely())
      return;
    const clearIfSafe = async (clear) => {
      if (this.hasLivePresentationState()) {
        return;
      }
      try {
        await clear();
      } catch {}
    };
    await clearIfSafe(() => this.options.cmux.clearNotifications());
    await clearIfSafe(() => this.options.cmux.clearStatus(this.localStatusKey()));
    await clearIfSafe(() => this.options.cmux.clearStatus(this.options.config.statusKey));
    for (const key of LEGACY_EXTRA_STATUS_KEYS) {
      await clearIfSafe(() => this.options.cmux.clearStatus(this.legacyExtraStatusKey(key)));
    }
  }
  async clearPresentationBestEffort() {
    if (!this.canClearPresentationSafely())
      return;
    const cleanup = [
      this.options.cmux.clearNotifications(),
      this.options.cmux.clearStatus(this.localStatusKey()),
      this.options.cmux.clearStatus(this.options.config.statusKey),
      ...LEGACY_EXTRA_STATUS_KEYS.map((key) => this.options.cmux.clearStatus(this.legacyExtraStatusKey(key)))
    ];
    await Promise.allSettled(cleanup);
  }
  canClearPresentationSafely() {
    return this.options.cmux.preciseTabTargeting;
  }
  legacyExtraStatusKey(key) {
    return `${this.options.config.statusKey}:${key}`;
  }
  localStatusKey() {
    return `${this.options.config.statusKey}:${sanitizeStatusKeyPart(this.statusSeed())}`;
  }
  statusSeed() {
    const preciseCmuxParts = [
      this.options.cmux.workspaceID,
      this.options.cmux.tabID,
      this.options.cmux.surfaceID
    ].filter((part) => !!part);
    if (preciseCmuxParts.length === 3)
      return preciseCmuxParts.join(":");
    const fallbackParts = [
      ...preciseCmuxParts,
      this.primaryState?.metadata.id,
      this.options.project.id,
      this.options.project.root,
      `pid-${process.pid}`
    ].filter((part) => !!part);
    return fallbackParts.join(":") || this.options.config.statusKey;
  }
  clearTransientAuxiliaryState() {
    this.activeTools.clear();
    this.todoState = undefined;
    for (const [sessionID, session] of this.sessions) {
      if (session.metadata.kind === "subagent" && session.activity === "busy") {
        this.sessions.set(sessionID, {
          ...session,
          activity: "idle"
        });
      }
    }
  }
  tabAccentColor() {
    return colorFromSeed(this.statusSeed());
  }
  async refreshGitStateIfNeeded(tool, args) {
    if (tool !== "bash")
      return;
    if (!this.options.config.gitIntegration)
      return;
    const command = this.extractBashCommand(args);
    if (!command || !isGitCommand(command))
      return;
    await this.syncGitState();
  }
  extractBashCommand(args) {
    if (!args)
      return;
    const command = args.command;
    if (typeof command === "string" && command.trim())
      return command;
    const cmd = args.cmd;
    if (typeof cmd === "string" && cmd.trim())
      return cmd;
    return;
  }
  setSessionActivity(metadata, activity) {
    this.sessions.set(metadata.id, {
      metadata,
      activity
    });
  }
  buildSnapshot() {
    const subagentCount = getBusySubagentCount(this.sessions.values());
    if (this.pendingPermission) {
      return {
        status: {
          text: "waiting",
          icon: "lock",
          color: "#ef4444"
        },
        progress: this.options.config.progressEnabled ? {
          value: this.progressTracker.estimate("waiting"),
          label: `${this.options.project.label}: ${this.pendingPermission.title}`
        } : undefined
      };
    }
    if (this.pendingQuestion) {
      return {
        status: {
          text: "question",
          icon: "help-circle",
          color: "#a855f7"
        },
        progress: this.options.config.progressEnabled ? {
          value: this.progressTracker.estimate("waiting"),
          label: `${this.options.project.label}: ${this.pendingQuestion.header}`
        } : undefined
      };
    }
    if (this.primaryState?.activity === "busy" || this.activeTools.size > 0 || subagentCount > 0) {
      return {
        status: {
          text: this.buildWorkingStatusText(subagentCount),
          icon: "terminal",
          color: this.tabAccentColor()
        },
        progress: this.options.config.progressEnabled ? {
          value: this.progressTracker.estimate("working"),
          label: this.primaryState ? `${this.options.project.label}: ${formatSessionLabel(this.primaryState.metadata)}` : `${this.options.project.label}: working`
        } : undefined
      };
    }
    if (this.primaryState?.activity === "error") {
      return {
        status: {
          text: "error",
          icon: "alert-circle",
          color: "#ef4444"
        }
      };
    }
    if (this.primaryState?.activity === "idle" && this.options.config.keepDoneStatus) {
      return {
        status: {
          text: "done",
          icon: "check-circle",
          color: "#22c55e"
        },
        progress: this.options.config.progressEnabled ? {
          value: this.progressTracker.estimate("idle"),
          label: `${this.options.project.label}: done`
        } : undefined
      };
    }
    return {};
  }
  buildWorkingStatusText(subagentCount) {
    const toolCount = this.activeTools.size;
    const parts = ["working"];
    if (toolCount > 0) {
      parts.push(`${toolCount} ${pluralize("tool", toolCount)}`);
    }
    if (subagentCount > 0) {
      parts.push(`${subagentCount} ${pluralize("subagent", subagentCount)}`);
    }
    return parts.join(" - ");
  }
  async render() {
    const now = Date.now();
    const elapsed = now - this.lastRenderAt;
    if (elapsed >= RENDER_THROTTLE_MS) {
      await this.renderNow();
    } else if (!this.renderPending) {
      this.renderPending = true;
      this.renderTimer = setTimeout(async () => {
        try {
          this.renderPending = false;
          this.renderTimer = undefined;
          await this.renderNow();
        } catch (err) {
          this.renderPending = false;
          this.renderTimer = undefined;
          this.options.logger.log("error", `Deferred render failed: ${err}`);
        }
      }, RENDER_THROTTLE_MS - elapsed);
    }
  }
  async renderNow() {
    this.lastRenderAt = Date.now();
    const next = this.buildSnapshot();
    await this.applyStatus(next);
    await this.applyProgress(next);
    this.currentSnapshot = next;
  }
  async throttledLog(payload) {
    const now = Date.now();
    const cutoff = now - LOG_RATE_WINDOW_MS;
    while (this.logTimestamps.length > 0 && this.logTimestamps[0] <= cutoff) {
      this.logTimestamps.shift();
    }
    if (this.logTimestamps.length >= LOG_RATE_LIMIT) {
      return false;
    }
    this.logTimestamps.push(now);
    await this.options.cmux.log(payload);
    return true;
  }
  resetStaleTimer() {
    if (this.staleTimer) {
      clearTimeout(this.staleTimer);
      this.staleTimer = undefined;
    }
    const timeoutMs = this.options.config.staleSessionTimeoutMs;
    if (!timeoutMs || timeoutMs <= 0)
      return;
    if (this.primaryState?.activity !== "busy")
      return;
    this.staleTimer = setTimeout(async () => {
      try {
        if (this.primaryState?.activity === "busy" && Date.now() - this.lastEventAt >= timeoutMs) {
          const metadata = this.primaryState.metadata;
          this.setSessionActivity(metadata, "idle");
          this.primaryState = this.sessions.get(metadata.id);
          this.pendingQuestion = undefined;
          this.pendingPermission = undefined;
          this.clearTransientAuxiliaryState();
          this.progressTracker.reset();
          await this.options.cmux.log({
            level: "warning",
            source: "opencode",
            message: `${this.options.project.label}: stale session cleared - ${formatSessionLabel(metadata)} (no events for ${Math.round(timeoutMs / 1000)}s)`
          });
          await this.renderNow();
        }
      } catch (err) {
        this.options.logger.log("error", `Stale session timer failed: ${err}`);
      }
    }, timeoutMs);
  }
  resetDoneTimer() {
    if (this.doneTimer) {
      clearTimeout(this.doneTimer);
      this.doneTimer = undefined;
    }
    const timeoutMs = this.options.config.doneTimeoutMs;
    if (!timeoutMs || timeoutMs <= 0)
      return;
    if (!this.options.config.keepDoneStatus)
      return;
    if (this.primaryState?.activity !== "idle")
      return;
    this.doneTimer = setTimeout(async () => {
      try {
        if (this.primaryState?.activity === "idle") {
          this.primaryState = undefined;
          this.clearTransientAuxiliaryState();
          this.progressTracker.reset();
          await this.renderNow();
        }
      } catch (err) {
        this.options.logger.log("error", `Done timer failed: ${err}`);
      }
    }, timeoutMs);
  }
  async flush() {
    if (this.renderPending && this.renderTimer) {
      clearTimeout(this.renderTimer);
      this.renderTimer = undefined;
      this.renderPending = false;
      await this.renderNow();
    }
  }
  async dispose() {
    await this.cleanup();
  }
  async applyStatus(next) {
    const currentStatus = this.currentSnapshot.status;
    const nextStatus = next.status;
    if (!nextStatus) {
      if (currentStatus) {
        await this.options.cmux.clearStatus(this.localStatusKey());
      }
      return;
    }
    if (currentStatus?.text === nextStatus.text && currentStatus.icon === nextStatus.icon && currentStatus.color === nextStatus.color) {
      return;
    }
    await this.options.cmux.setStatus(this.localStatusKey(), nextStatus);
  }
  async applyProgress(next) {
    const currentProgress = this.currentSnapshot.progress;
    const nextProgress = next.progress;
    if (!nextProgress) {
      return;
    }
    if (currentProgress?.value === nextProgress.value && currentProgress.label === nextProgress.label) {
      return;
    }
    await this.options.cmux.setProgress(nextProgress);
  }
}
function hashString(value) {
  let hash = 0;
  for (let i = 0;i < value.length; i++) {
    hash = (hash << 5) - hash + value.charCodeAt(i) >>> 0;
  }
  return hash;
}
function pluralize(word, count) {
  return count === 1 ? word : `${word}s`;
}
function sanitizeStatusKeyPart(value) {
  const sanitized = value.replace(/[^a-zA-Z0-9._-]+/g, "-").replace(/^-+|-+$/g, "");
  return sanitized || hashString(value).toString(36);
}
function colorFromSeed(seed) {
  const hash = hashString(seed);
  const hue = hash % 360;
  return hslToHex(hue, 80, 58);
}
function hslToHex(hue, saturationPercent, lightnessPercent) {
  const saturation = saturationPercent / 100;
  const lightness = lightnessPercent / 100;
  const chroma = (1 - Math.abs(2 * lightness - 1)) * saturation;
  const huePrime = hue / 60;
  const x = chroma * (1 - Math.abs(huePrime % 2 - 1));
  const match = lightness - chroma / 2;
  const [red, green, blue] = huePrime < 1 ? [chroma, x, 0] : huePrime < 2 ? [x, chroma, 0] : huePrime < 3 ? [0, chroma, x] : huePrime < 4 ? [0, x, chroma] : huePrime < 5 ? [x, 0, chroma] : [chroma, 0, x];
  return `#${toHex(red + match)}${toHex(green + match)}${toHex(blue + match)}`;
}
function toHex(channel) {
  return Math.round(channel * 255).toString(16).padStart(2, "0");
}

// src/index.ts
function describePermissionRequest(input) {
  if (typeof input.title === "string" && input.title.trim()) {
    return input.title.trim();
  }
  if (typeof input.tool === "string" && input.tool.trim()) {
    return input.tool.trim();
  }
  return "Permission request";
}
var plugin = async (ctx) => {
  const config = loadConfig();
  const logger = createPluginLogger(ctx.client);
  const environment = detectCmuxEnvironment(process.env);
  if (!environment.isManagedWorkspace) {
    await logger.log("debug", "cmux not detected, plugin disabled", {
      socketPath: environment.socketPath
    });
    return {};
  }
  const cmux = createCmuxClient({
    binary: config.cmuxBin,
    environment,
    logger,
    transport: config.transport
  });
  const sessionResolver = new OpencodeSessionResolver(ctx.client, logger);
  const project = resolveProjectContext(ctx);
  const coordinator = new CmuxStateCoordinator({
    cmux,
    config,
    logger,
    project,
    sessionResolver
  });
  logger.log("info", "Initialized opencode-cmux plugin", {
    project: project.label,
    workspaceID: environment.workspaceID,
    socketPath: environment.socketPath,
    transport: cmux.transport,
    hasSocket: environment.hasSocket
  });
  setTimeout(() => {
    (async () => {
      await coordinator.initialize();
      await coordinator.syncGitState();
    })();
  }, 0);
  let cleanupStarted = false;
  process.once("beforeExit", () => {
    if (cleanupStarted)
      return;
    cleanupStarted = true;
    coordinator.cleanup();
  });
  function logHookError(hook, err) {
    try {
      logger.log("error", `Hook "${hook}" failed: ${err}`);
    } catch {}
  }
  return {
    async event({ event }) {
      try {
        const normalized = normalizeEvent(event);
        if (!normalized)
          return;
        switch (normalized.type) {
          case "session.status":
            await coordinator.handleSessionStatus(normalized.sessionID, normalized.status);
            return;
          case "session.idle":
            await coordinator.handleSessionIdle(normalized.sessionID);
            return;
          case "session.error":
            await coordinator.handleSessionError(normalized.sessionID);
            return;
          case "question.asked":
            await coordinator.handleQuestionAsked(normalized.header, normalized.sessionID);
            return;
          case "question.resolved":
            await coordinator.handleQuestionResolved();
            return;
          case "permission.replied":
            await coordinator.handlePermissionResolved();
            return;
          case "file.edited":
            await coordinator.handleFileEdited(normalized.filePath, normalized.sessionID);
            return;
          case "session.created":
            await coordinator.handleSessionCreated(normalized.sessionID);
            return;
          case "session.updated":
            await coordinator.handleSessionUpdated(normalized.sessionID);
            return;
          case "session.deleted":
            await coordinator.handleSessionDeleted(normalized.sessionID);
            return;
          case "session.compacted":
            await coordinator.handleSessionCompacted(normalized.sessionID);
            return;
          case "todo.updated":
            await coordinator.handleTodoUpdated(normalized.items);
            return;
        }
      } catch (err) {
        logHookError("event", err);
      }
    },
    async "permission.ask"(input) {
      try {
        await coordinator.handlePermissionAsked(describePermissionRequest(input), input.sessionID);
      } catch (err) {
        logHookError("permission.ask", err);
      }
    },
    async "tool.execute.before"(input, output) {
      try {
        await coordinator.handleToolStarted(input.tool, output?.args);
      } catch (err) {
        logHookError("tool.execute.before", err);
      }
    },
    async "tool.execute.after"(input, output) {
      try {
        await coordinator.handleToolCompleted(input.tool, output?.args);
      } catch (err) {
        logHookError("tool.execute.after", err);
      }
    }
  };
};
var src_default = plugin;
export {
  src_default as default
};
