"""Snapshot all iTerm2 windows to ~/.config/iterm2/layouts/<name>.json."""
import datetime, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import iterm2, layoutlib

async def main(conn):
    app = await iterm2.async_get_app(conn)
    snap = await layoutlib.snapshot(app)
    name = sys.argv[1] if len(sys.argv) > 1 else datetime.datetime.now().strftime("%Y-%m-%d_%H%M")
    print(layoutlib.write(snap, name), "-", layoutlib.summary(snap))

iterm2.run_until_complete(main)
