-- Auto TRP's own record of where the character has been: every land set foot in (when it
-- was first seen) and how long has been spent in each, so the road in History, Lands
-- explored, Days on the road and the favourite haunt work without RPG Dialogue or
-- Chronicle. Kept per character in AutoTRPCharDB.travels. Dungeons, raids and
-- battlegrounds are noted but are not lands, and time spent away from the keyboard
-- doesn't count.
local _, ns = ...

local U = ns.U
local T = {}
ns.Sources = ns.Sources or {}
ns.Sources.Travels = T

T.TICK = 30        -- seconds between counts of time spent
T.GAP = 90         -- a longer gap than this (a loading screen, a freeze) counts only this much

local function store()
  if not ns.char then return nil end
  local d = ns.char.travels
  if type(d) ~= "table" then d = {}; ns.char.travels = d end
  if type(d.zones) ~= "table" then d.zones = {} end
  if not tonumber(d.since) then
    d.since = U.Now()
    -- Lands first seen before this record began (the mood's "first time in ..." notes) are
    -- taken in once, with their time, so the road doesn't start over.
    local seen = ns.char.seen and ns.char.seen.zones
    for name, t in pairs(type(seen) == "table" and seen or {}) do
      if type(name) == "string" and name ~= "" and not d.zones[name] then
        d.zones[name] = { t = tonumber(t) or d.since, secs = 0 }
      end
    end
  end
  return d
end

-- An instance by its kind ("party", "raid", "pvp", "arena", "scenario"), or by name for one
-- noted before its kind was known.
local function isInstance(name, z)
  if z and z.inst then return true end
  local W = ns.Words
  return (W and W.INSTANCE_FLAVOR and W.INSTANCE_FLAVOR[name]) and true or false
end
T.IsInstance = isInstance

local function where()
  local zone = U.Plain(U.Call(GetRealZoneText)) or U.Plain(U.Call(GetZoneText))
  local inInstance, kind = U.Call(IsInInstance)
  return zone, (inInstance and kind and kind ~= "none") and kind or nil
end

-- The land being counted, and since when.
local here, lastAt

-- Credits the time since the last count to where the character is, then notes where
-- they are now. Called on every zone change and every T.TICK seconds.
function T.Count(now)
  local d = store()
  if not d then return end
  now = now or U.Now()
  if here and lastAt and now > lastAt then
    local z = d.zones[here]
    local away = ns.World and ns.World.Safe and ns.World.Safe(U.Call(UnitIsAFK, "player"))
    if z and away ~= true then z.secs = (tonumber(z.secs) or 0) + math.min(now - lastAt, T.GAP) end
  end
  local zone, kind = where()
  lastAt = now
  if not zone then here = nil return end
  local z = d.zones[zone]
  if not z then
    z = { t = now, secs = 0 }
    d.zones[zone] = z
    if ns.Compose then ns.Compose.SourcesChanged() end
  end
  if kind then z.inst = kind end
  here = zone
end

-- { lands = { { name, t }, ... } first seen first (no instances), haunts = { { name, secs },
--   ... } most time first (no instances), secs = all the time counted there, since }.
-- A fresh table each time, so what's built from it notices a change.
function T.Read()
  local d = store()
  if not d then return nil end
  local out = { lands = {}, haunts = {}, secs = 0, since = d.since }
  for name, z in pairs(d.zones) do
    if type(z) == "table" and not isInstance(name, z) then
      out.lands[#out.lands + 1] = { name = name, t = tonumber(z.t) or 0 }
      local s = tonumber(z.secs) or 0
      if s > 0 then
        out.haunts[#out.haunts + 1] = { name = name, secs = s }
        out.secs = out.secs + s
      end
    end
  end
  table.sort(out.lands, function(a, b) if a.t ~= b.t then return a.t < b.t end return a.name < b.name end)
  table.sort(out.haunts, function(a, b) if a.secs ~= b.secs then return a.secs > b.secs end return a.name < b.name end)
  return out
end

-- "40 minutes", "14 hours", "3 days": time spent, as a person would say it. figures: as
-- figures ("9 hours") rather than words ("nine hours"), for the statistics and chat.
function T.Span(secs, figures)
  local function n(x) return figures and tostring(x) or U.Number(x) end
  local h = secs / 3600
  if h < 1 then
    local m = math.max(1, math.floor(secs / 60))
    return n(m) .. U.Plural(m, " minute", " minutes")
  end
  if h < 48 then
    local k = math.floor(h)
    return n(k) .. U.Plural(k, " hour", " hours")
  end
  return n(math.floor(h / 24)) .. " days"
end

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------
ns.On("ZONE_CHANGED_NEW_AREA", function() T.Count() end)
ns.On("PLAYER_ENTERING_WORLD", function()
  here, lastAt = nil, nil   -- a loading screen isn't time spent anywhere
  T.Count()
end)
ns.Listen("LOGIN", function()
  T.Count()
  ns.Ticker(T.TICK, function() T.Count() end)
end)
