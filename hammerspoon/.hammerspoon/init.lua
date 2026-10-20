require("hs.ipc") -- enables the `hs` command-line tool
hs.autoLaunch(true)
hs.window.animationDuration = 0

-- Cmd+Option+End: stack ForkLift / Spotify / Slack in thirds on the vertical monitor.
local VERTICAL_LAYOUT = {
  { bundleID = "com.binarynights.ForkLift", unit = { x = 0, y = 0, w = 1, h = 1 / 3 } },
  { bundleID = "com.spotify.client", unit = { x = 0, y = 1 / 3, w = 1, h = 1 / 3 } },
  { bundleID = "com.tinyspeck.slackmacgap", unit = { x = 0, y = 2 / 3, w = 1, h = 1 / 3 } },
}

local function verticalScreen()
  local named = hs.screen.find("S2725HS")
  if named then
    return named
  end
  -- Fallback: leftmost portrait screen.
  local best
  for _, s in ipairs(hs.screen.allScreens()) do
    local f = s:frame()
    if f.h > f.w and (not best or f.x < best:frame().x) then
      best = s
    end
  end
  return best
end

local function placeWindow(win, screen, unit)
  local sf = screen:frame()
  local target = hs.geometry.rect(
    sf.x + unit.x * sf.w,
    sf.y + unit.y * sf.h,
    unit.w * sf.w,
    unit.h * sf.h
  )
  -- Moving across screens sometimes lands short on the first try; set twice.
  win:setFrame(target)
  hs.timer.doAfter(0.3, function()
    win:setFrame(target)
  end)
end

local pendingTimers = {}

local function launchAndPlace(entry, screen)
  hs.application.launchOrFocusByBundleID(entry.bundleID)
  local deadline = hs.timer.secondsSinceEpoch() + 20
  pendingTimers[entry.bundleID] = hs.timer.doEvery(0.25, function()
    local app = hs.application.get(entry.bundleID)
    local win = app and (app:mainWindow() or app:allWindows()[1])
    if win and win:isStandard() then
      pendingTimers[entry.bundleID]:stop()
      pendingTimers[entry.bundleID] = nil
      placeWindow(win, screen, entry.unit)
    elseif hs.timer.secondsSinceEpoch() > deadline then
      pendingTimers[entry.bundleID]:stop()
      pendingTimers[entry.bundleID] = nil
      hs.alert.show("Layout: no window for " .. entry.bundleID)
    end
  end)
end

local function applyVerticalLayout()
  local screen = verticalScreen()
  if not screen then
    hs.alert.show("Layout: vertical monitor not found")
    return
  end
  for _, entry in ipairs(VERTICAL_LAYOUT) do
    launchAndPlace(entry, screen)
  end
end

hs.hotkey.bind({ "cmd", "alt" }, "end", applyVerticalLayout)

hs.alert.show("Hammerspoon config loaded")
