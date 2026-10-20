import assert from "node:assert/strict";
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { after, before, test } from "node:test";
import plugin from "../index.js";

const marker = "[[opencode-main-attention]] ";
const temporaryDirectory = mkdtempSync(join(tmpdir(), "opencode-cmux-primary-sound-"));
const capturePath = join(temporaryDirectory, "cmux.jsonl");
const fakeCmuxPath = new URL("./fake-cmux.js", import.meta.url).pathname;

before(() => {
  writeFileSync(capturePath, "");
  process.env.CMUX_TEST_CAPTURE = capturePath;
  process.env.CMUX_WORKSPACE_ID = "workspace-test";
  process.env.OPENCODE_CMUX_BIN = fakeCmuxPath;
  process.env.OPENCODE_CMUX_TRANSPORT = "cli";
  process.env.OPENCODE_CMUX_NOTIFY_SUBAGENTS = "true";
  process.env.OPENCODE_CMUX_LOG_SUBAGENTS = "false";
  process.env.OPENCODE_CMUX_LOG_TOOLS = "false";
  process.env.OPENCODE_CMUX_LOG_FILE_EDITS = "false";
  process.env.OPENCODE_CMUX_LOG_SESSION_LIFECYCLE = "false";
  process.env.OPENCODE_CMUX_LOG_TODOS = "false";
  process.env.OPENCODE_CMUX_PROGRESS = "false";
  process.env.OPENCODE_CMUX_GIT = "false";
  process.env.OPENCODE_CMUX_DONE_TIMEOUT = "0";
});

after(() => {
  rmSync(temporaryDirectory, { recursive: true, force: true });
});

test("routes attention sound only for notifications from verified primary sessions", async () => {
  // Given: primary, child, and unresolved OpenCode sessions.
  const sessions = new Map([
    ["primary", { title: "Primary" }],
    ["child", { title: "Child", parentID: "primary" }],
  ]);
  const hooks = await plugin({
    client: {
      app: { log: async () => {} },
      session: {
        get: async ({ path }) => {
          if (path.id === "unresolved") {
            throw new Error("session unavailable");
          }
          return { data: sessions.get(path.id) };
        },
      },
    },
    directory: temporaryDirectory,
    project: { id: "sound-routing", worktree: temporaryDirectory },
    worktree: temporaryDirectory,
  });

  // When: each notification-producing path runs through the public plugin hooks.
  await hooks.event({
    event: { type: "session.status", properties: { sessionID: "primary", status: "busy" } },
  });
  await hooks.event({
    event: { type: "session.status", properties: { sessionID: "primary", status: "idle" } },
  });
  await hooks.event({
    event: { type: "session.status", properties: { sessionID: "unresolved", status: "busy" } },
  });
  await hooks.event({
    event: { type: "session.status", properties: { sessionID: "unresolved", status: "idle" } },
  });
  await hooks.event({
    event: {
      type: "question.asked",
      properties: { header: "Primary question", sessionID: "primary" },
    },
  });
  await hooks.event({
    event: {
      type: "question.asked",
      properties: { header: "Child question", sessionID: "child" },
    },
  });
  await hooks.event({
    event: {
      type: "question.asked",
      properties: { header: "Missing-session question" },
    },
  });
  await hooks.event({
    event: {
      type: "question.asked",
      properties: { header: "Unresolved question", sessionID: "unresolved" },
    },
  });
  await hooks["permission.ask"]({ title: "Primary permission", sessionID: "primary" });
  await hooks["permission.ask"]({ title: "Child permission", sessionID: "child" });
  await hooks["permission.ask"]({ title: "Missing-session permission" });
  await hooks["permission.ask"]({ title: "Unresolved permission", sessionID: "unresolved" });
  await hooks.event({
    event: { type: "session.status", properties: { sessionID: "child", status: "busy" } },
  });
  await hooks.event({
    event: { type: "session.status", properties: { sessionID: "child", status: "idle" } },
  });
  await hooks.event({
    event: { type: "session.error", properties: { sessionID: "primary" } },
  });

  // Then: only positively resolved primary intervention notifications carry the marker.
  const commands = readFileSync(capturePath, "utf8")
    .trim()
    .split("\n")
    .filter(Boolean)
    .map((line) => JSON.parse(line));
  const titles = commands
    .filter((arguments_) => arguments_[0] === "notify")
    .map((arguments_) => arguments_[arguments_.indexOf("--title") + 1]);

  assert.deepEqual(titles.map((title) => title.startsWith(marker)), [
    true,
    false,
    true,
    false,
    false,
    false,
    true,
    false,
    false,
    false,
    false,
    false,
  ]);
  assert.deepEqual(titles.map((title) => title.replace(marker, "").split(":")[0]), [
    "Done",
    "Done",
    "Question",
    "Question",
    "Question",
    "Question",
    "Permission needed",
    "Permission needed",
    "Permission needed",
    "Permission needed",
    "Subagent done",
    "Error",
  ]);
});
