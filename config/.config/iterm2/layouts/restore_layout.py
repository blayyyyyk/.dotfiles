"""Rebuild windows/tabs/splits from a snapshot and relaunch each pane:
`claude --resume <id>` where claude was running, otherwise cd to its dir."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import iterm2, layoutlib

DRY = "--dry" in sys.argv
ARGS = [a for a in sys.argv[1:] if a != "--dry"]

async def main(conn):
    await layoutlib.restore(conn, layoutlib.load(ARGS[0] if ARGS else "latest"), dry=DRY)

iterm2.run_until_complete(main)
