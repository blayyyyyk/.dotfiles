"""Snapshot and rebuild iTerm2 windows/tabs/splits, each pane's cwd, and the
claude session running in it. Shared by save_layout.py, restore_layout.py and
the AutoLaunch script layout_autosave.py."""
import datetime
import json
import os
import shlex
import subprocess

import iterm2

HOME = os.path.expanduser("~")
DIR = os.path.join(HOME, ".config/iterm2/layouts")
SHELLS = {"zsh", "-zsh", "bash", "-bash", "fish", "login"}


# ---------- snapshot ----------

def claude_session(tty):
    """tty -> claude pid on it -> ~/.claude/sessions/<pid>.json."""
    if not tty:
        return None
    ps = subprocess.run(["ps", "-t", tty.replace("/dev/", ""), "-o", "pid=,comm="],
                        capture_output=True, text=True).stdout
    for line in ps.splitlines():
        pid, comm = line.split(None, 1)
        if "claude" in comm:
            try:
                with open(f"{HOME}/.claude/sessions/{pid}.json") as f:
                    s = json.load(f)
                return {"sessionId": s["sessionId"], "cwd": s.get("cwd")}
            except (OSError, ValueError, KeyError):
                return None
    return None


async def _node(n):
    if isinstance(n, iterm2.Session):
        v = {}
        for k in ["path", "jobName", "commandLine", "tty", "profileName"]:
            v[k] = await n.async_get_variable(k)
        v["claude"] = claude_session(v["tty"])
        return {"type": "session", "grid": [n.grid_size.width, n.grid_size.height], **v}
    return {"type": "split", "vertical": n.vertical,
            "children": [await _node(c) for c in n.children]}


async def snapshot(app):
    windows = []
    for w in app.terminal_windows:
        f = await w.async_get_frame()
        tabs = [{"title": await t.async_get_variable("titleOverride"),
                 "root": await _node(t.root)} for t in w.tabs]
        windows.append({"frame": [f.origin.x, f.origin.y, f.size.width, f.size.height],
                        "tabs": tabs})
    return {"savedAt": datetime.datetime.now().isoformat(timespec="seconds"),
            "windows": windows}


def leaves(snap):
    out = []

    def walk(n):
        if n["type"] == "session":
            out.append(n)
        else:
            for c in n["children"]:
                walk(c)
    for w in snap["windows"]:
        for t in w["tabs"]:
            walk(t["root"])
    return out


def summary(snap):
    ls = leaves(snap)
    n_claude = sum(1 for l in ls if l.get("claude"))
    tabs = sum(len(w["tabs"]) for w in snap["windows"])
    return f"{len(snap['windows'])} window(s), {tabs} tab(s), {len(ls)} pane(s), {n_claude} Claude"


def is_trivial(snap):
    """Nothing worth restoring: no panes, or one pane with no claude in it."""
    ls = leaves(snap)
    return len(ls) == 0 or (len(ls) == 1 and not ls[0].get("claude"))


def write(snap, name):
    path = os.path.join(DIR, f"{name}.json")
    tmp = path + ".tmp"
    with open(tmp, "w") as fh:
        json.dump(snap, fh, indent=1)
    os.replace(tmp, path)
    with open(os.path.join(DIR, "latest.json.tmp"), "w") as fh:
        json.dump(snap, fh, indent=1)
    os.replace(os.path.join(DIR, "latest.json.tmp"), os.path.join(DIR, "latest.json"))
    return path


def list_snapshots():
    """[(name, path)] newest first, excluding the latest.json alias."""
    out = []
    for f in os.listdir(DIR):
        if f.endswith(".json") and f != "latest.json":
            p = os.path.join(DIR, f)
            out.append((os.path.getmtime(p), f[:-5], p))
    return [(n, p) for _, n, p in sorted(out, reverse=True)]


def prune_auto(keep=20):
    autos = [p for n, p in list_snapshots() if n.startswith("auto-")]
    for p in autos[keep:]:
        os.remove(p)


def load(name):
    if os.path.isabs(name):
        path = name
    else:
        path = os.path.join(DIR, name if name.endswith(".json") else f"{name}.json")
    with open(path) as fh:
        return json.load(fh)


# ---------- restore ----------

def command_for(leaf):
    c = leaf.get("claude")
    if c:
        return f"cd {shlex.quote(c.get('cwd') or leaf['path'] or HOME)} && claude --resume {c['sessionId']}"
    return f"cd {shlex.quote(leaf.get('path') or HOME)}"


async def _build(n, session, out):
    if n["type"] == "session":
        out.append((session, n))
        return
    kids = n["children"]
    sessions = [session]
    for _ in kids[1:]:
        # Splitter.vertical == True means side-by-side panes (vertical dividers).
        sessions.append(await sessions[-1].async_split_pane(vertical=n["vertical"]))
    for kid, s in zip(kids, sessions):
        await _build(kid, s, out)


async def restore(conn, snap, dry=False):
    """Rebuild every window in snap. Returns the new window ids."""
    await iterm2.async_get_app(conn)  # registers the delegate split_pane needs
    created = []
    for w in snap["windows"]:
        win = await iterm2.Window.async_create(conn)
        created.append(win.window_id)
        await win.async_set_frame(iterm2.Frame(iterm2.Point(*w["frame"][:2]),
                                               iterm2.Size(*w["frame"][2:])))
        for i, t in enumerate(w["tabs"]):
            tab = win.tabs[0] if i == 0 else await win.async_create_tab()
            out = []
            await _build(t["root"], tab.current_session, out)
            for s, leaf in out:
                s.preferred_size = iterm2.Size(*leaf["grid"])
            await tab.async_update_layout()
            if t.get("title"):
                await tab.async_set_title(t["title"])
            for s, leaf in out:
                cmd = command_for(leaf)
                await s.async_send_text((f"echo {shlex.quote(cmd)}" if dry else cmd) + "\n")
    return created
