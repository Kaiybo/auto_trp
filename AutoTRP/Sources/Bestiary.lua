-- The bestiary: what the character has fought and seen, from the game alone. When they
-- target a creature (or a fight starts) a handful of reads note what it is: its kind
-- (UnitCreatureType: Beast, Humanoid, Undead, Demon, ...), its family (Wolf, Spider, ...),
-- how rare or strong it is (UnitClassification) and its level against theirs. A kill
-- (Sources/Deeds.lua's PARTY_KILL, by name) is then counted by kind and family; the first
-- of each kind, the greatest thing brought down, rares and elites seen but let be, world
-- bosses seen, the kind that has killed them most and the notable people and creatures
-- met by name (W.BESTIARY.NOTABLE) are kept too.
-- Other players and anything a player controls (their pets) are skipped entirely. Nothing
-- here loops in combat: the trimming waits for the fight to end. Kept per character in
-- AutoTRPCharDB.bestiary, bounded; read into ns.cache.bestiary.
local _, ns = ...

local U = ns.U
local W = ns.Words
local B = {}
ns.Sources = ns.Sources or {}
ns.Sources.Bestiary = B

B.KEEP_NAMES, B.KEEP_FAMILIES, B.KEEP_SEEN, B.KEEP_TYPES, B.KEEP_ZONES = 80, 40, 30, 16, 6
B.RECENT = 14 * 86400   -- what "lately" means for the kinds fought

local STRONG = { elite = true, rareelite = true, worldboss = true, rare = true }
local CLASS_WEIGHT = { worldboss = 20, rareelite = 9, elite = 6, rare = 3 }

local function store()
  if not ns.char then return nil end
  local b = ns.char.bestiary
  if type(b) ~= "table" then b = {}; ns.char.bestiary = b end
  b.since = tonumber(b.since) or U.Now()
  for _, k in ipairs({ "types", "families", "names", "seen", "notable" }) do
    if type(b[k]) ~= "table" then b[k] = {} end
  end
  b.kills = tonumber(b.kills) or 0
  b.strongKills = tonumber(b.strongKills) or 0
  -- The level the record began at: a "first" is only claimed when it began near the start.
  b.startLevel = tonumber(b.startLevel) or tonumber((U.Call(UnitLevel, "player"))) or 1
  return b
end
B.Store = store

local function zone() return U.Plain(U.Call(GetRealZoneText)) end

-- Keeps a keyed table to `max` entries, forgetting the least-used, then the oldest.
local function bound(t, max)
  local count = U.Count(t)
  while count > max do
    local worst, wk
    for k, v in pairs(t) do
      local score = (tonumber(v.n) or tonumber(v.kills) or 0) * 1e10 + (tonumber(v.last) or tonumber(v.t) or 0)
      if not worst or score < worst then worst, wk = score, k end
    end
    if not wk then break end
    t[wk] = nil
    count = count - 1
  end
end

local function inCombat() return U.Call(InCombatLockdown) or U.Call(UnitAffectingCombat, "player") end

local dirty = false
function B.Trim()
  local b = store()
  if not b then return end
  bound(b.names, B.KEEP_NAMES); bound(b.families, B.KEEP_FAMILIES); bound(b.seen, B.KEEP_SEEN)
  bound(b.types, B.KEEP_TYPES); bound(b.notable, 40)
  for _, t in pairs(b.types) do if type(t.zones) == "table" then bound(t.zones, B.KEEP_ZONES) end end
  dirty = false
end
local function later() if dirty and not inCombat() then B.Trim() end end

-- How a creature measures up: its level against theirs (a skull counts as ten above) and
-- how rare or strong the game calls it.
function B.Weight(class, diff)
  return (diff or 0) + (CLASS_WEIGHT[class or ""] or 0)
end

-- What the target is, in a few reads; nil for a player, a player's pet or nothing at all.
local function look(unit)
  if not U.Call(UnitExists, unit) or U.Call(UnitIsPlayer, unit) or U.Call(UnitPlayerControlled, unit) then return nil end
  local name = U.Plain(U.Call(UnitName, unit))
  if not name then return nil end
  local mine = tonumber(U.Call(UnitLevel, "player")) or 1
  local lvl = tonumber(U.Call(UnitLevel, unit))
  local skull = lvl == -1
  return {
    name = name,
    type = U.Plain(U.Call(UnitCreatureType, unit)),
    family = U.Plain(U.Call(UnitCreatureFamily, unit)),
    class = U.Call(UnitClassification, unit),
    level = (lvl and lvl > 0) and lvl or nil, mine = mine,
    diff = skull and 10 or (lvl and lvl > 0 and lvl - mine or 0),
    hostile = U.Call(UnitCanAttack, "player", unit) and true or false,
  }
end
B.Look = look

-- A creature taken in: its kind kept by name (for the kill to find), a rare or elite seen,
-- a world boss sighted, a notable figure met. `fought` when a fight started on it.
function B.Note(info, fought, where)
  local b = store()
  if not b or type(info) ~= "table" or not info.name then return end
  local now = U.Now()
  where = where or zone()
  local notable = W.BESTIARY and W.BESTIARY.NOTABLE[info.name]
  if notable then
    local m = b.notable[info.name]
    if not m then
      b.notable[info.name] = { t = now, last = now, zone = where, n = 1, kind = notable }
      if ns.Compose then ns.Compose.SourcesChanged() end
    elseif now - (m.last or 0) > 600 then
      m.n, m.last = (m.n or 1) + 1, now
    end
  end
  if not info.hostile and not fought then return end
  if info.type == nil and info.family == nil and not STRONG[info.class or ""] then return end
  local rec = b.names[info.name]
  if not rec then
    rec = {}
    b.names[info.name] = rec
    dirty = true
  end
  rec.type, rec.family, rec.class, rec.level, rec.mine, rec.diff, rec.last =
    info.type, info.family, info.class, info.level, info.mine, info.diff, now
  -- Rares, elites and world bosses, seen: whether they were fought is noted when it happens.
  if STRONG[info.class or ""] and not (info.class == "elite" and U.Call(IsInInstance)) then
    local s = b.seen[info.name]
    local first = not s
    if not s then
      s = { t = now, zone = where, class = info.class, type = info.type, family = info.family, n = 0 }
      b.seen[info.name] = s
      dirty = true
    end
    s.last = now
    if fought then s.fought = true end
    -- A world boss in the open (not a raid's master) or a dragon is something to see.
    if first then
      local raid = U.Call(IsInInstance)
      if info.class == "worldboss" and not raid then
        s.world = true
        if ns.Mood then ns.Mood.Push("wonder", 50, "saw " .. info.name .. " in the open") end
      elseif info.class == "rare" or info.class == "rareelite" then
        if ns.Mood then ns.Mood.Push("intrigued", 15, "spotted a rare creature") end
      end
      if ns.Compose then ns.Compose.SourcesChanged() end
    end
  end
  if info.type == "Dragonkin" and not b.dragonSeen then
    b.dragonSeen = { t = now, zone = where, name = info.name }
    if ns.Mood then ns.Mood.Push("wonder", 35, "saw a dragon") end
  end
  if fought then b.lastFoe = { name = info.name, type = info.type, t = now } end
  later()
end

-- A creature killed (Deeds' PARTY_KILL, by name): counted by kind and family, with the
-- first of each kind and the greatest kill. No loops: a few lookups.
function B.Kill(name, t)
  local b = store()
  name = U.Plain(name)
  if not b or not name then return end
  local rec = b.names[name]
  if not rec then return end   -- never sized up: nothing to say what it was
  local now = t or U.Now()
  local where = zone()
  b.kills = b.kills + 1
  rec.kills = (rec.kills or 0) + 1
  if rec.type then
    local ty = b.types[rec.type]
    if not ty then
      ty = { kills = 0, first = now, firstName = name, firstZone = where, zones = {} }
      b.types[rec.type] = ty
      b.freshType = { type = rec.type, t = now, name = name, zone = where }
      dirty = true
    end
    ty.kills, ty.last = ty.kills + 1, now
    if where then
      if not ty.zones[where] then dirty = true end
      ty.zones[where] = (ty.zones[where] or 0) + 1
    end
    -- Lately: a window that starts again once it's two weeks old.
    if not ty.recent or now - (ty.recent.since or 0) > B.RECENT then ty.recent = { n = 0, since = now } end
    ty.recent.n, ty.recent.zone = ty.recent.n + 1, where or ty.recent.zone
  end
  if rec.family then
    local fa = b.families[rec.family]
    if not fa then fa = { kills = 0, type = rec.type, first = now }; b.families[rec.family] = fa; dirty = true end
    fa.kills, fa.last = fa.kills + 1, now
  end
  if STRONG[rec.class or ""] then b.strongKills = b.strongKills + 1 end
  local s = b.seen[name]
  if s then s.fought, s.killed = true, (s.killed or 0) + 1 end
  -- The greatest: weighed by level against theirs and how strong the game calls it.
  local w = B.Weight(rec.class, rec.diff)
  local g = b.greatest
  if g and g.name == name and w >= (g.w or 0) then
    g.kills = (g.kills or 1) + 1
  elseif (not g or w > (g.w or 0)) and (w >= 3 or STRONG[rec.class or ""]) then
    b.greatest = { name = name, w = w, class = rec.class, level = rec.level, mine = rec.mine, diff = rec.diff,
      type = rec.type, family = rec.family, zone = where, t = now, kills = 1 }
    if ns.Compose then ns.Compose.SourcesChanged() end
  end
  if dirty then later() end
end

-- A death: the kind of the foe that did it (the fight's foe, or the target if still on it).
function B.Death(killer)
  local b = store()
  if not b then return end
  local rec = killer and b.names[killer]
  local kind = rec and rec.type
  if not kind and b.lastFoe and U.Now() - (b.lastFoe.t or 0) < 30 then kind = b.lastFoe.type end
  if not kind then return end
  local ty = b.types[kind]
  if not ty then ty = { kills = 0, zones = {} }; b.types[kind] = ty end
  ty.deaths = (ty.deaths or 0) + 1
  ty.lastDeath = U.Now()
end

---------------------------------------------------------------------------
-- Reading
---------------------------------------------------------------------------
local function topZone(zones)
  local best, bn = nil, 0
  for z, n in pairs(zones or {}) do if n > bn or (n == bn and best and z < best) then best, bn = z, n end end
  return best, bn
end

-- { kills, since, types = { { type, kills, first, firstName, firstZone, zone (most kills),
--   recent, deaths } most killed first }, families = { { family, type, kills } }, greatest,
--   seen = { { name, class, type, family, zone, t, last, fought, killed, world } latest first },
--   worldBosses, notable = { { name, kind, t, zone, n } first met first }, freshType, dragonSeen }
function B.Read()
  local b = store()
  if not b then return nil end
  local now = U.Now()
  local out = { kills = b.kills, since = b.since, types = {}, families = {}, seen = {}, worldBosses = {}, notable = {},
    greatest = b.greatest, freshType = b.freshType, dragonSeen = b.dragonSeen, deaths = 0,
    strongKills = b.strongKills, seenBy = {},
    -- Firsts are only claimed when the record began near the start of the road.
    fromStart = (b.startLevel or 1) <= 5 }
  for name, t in pairs(b.types) do
    local z = topZone(t.zones)
    out.types[#out.types + 1] = { type = name, kills = t.kills or 0, first = t.first, firstName = t.firstName,
      firstZone = t.firstZone, zone = z, deaths = t.deaths or 0, last = t.last,
      recentZone = t.recent and t.recent.zone,
      recent = (t.recent and now - (t.recent.since or 0) <= B.RECENT) and t.recent.n or 0 }
    out.deaths = out.deaths + (t.deaths or 0)
  end
  table.sort(out.types, function(x, y) if x.kills ~= y.kills then return x.kills > y.kills end return x.type < y.type end)
  for name, f in pairs(b.families) do out.families[#out.families + 1] = { family = name, type = f.type, kills = f.kills or 0 } end
  table.sort(out.families, function(x, y) if x.kills ~= y.kills then return x.kills > y.kills end return x.family < y.family end)
  for name, s in pairs(b.seen) do
    local e = { name = name, class = s.class, type = s.type, family = s.family, zone = s.zone, t = s.t or 0,
      last = s.last or s.t or 0, fought = s.fought, killed = s.killed or 0, world = s.world }
    out.seen[#out.seen + 1] = e
    out.seenBy[name] = e
    if s.world then out.worldBosses[#out.worldBosses + 1] = e end
  end
  table.sort(out.seen, function(x, y) if x.last ~= y.last then return x.last > y.last end return x.name < y.name end)
  table.sort(out.worldBosses, function(x, y) if x.t ~= y.t then return x.t < y.t end return x.name < y.name end)
  for name, m in pairs(b.notable) do
    out.notable[#out.notable + 1] = { name = name, kind = m.kind, t = m.t or 0, zone = m.zone, n = m.n or 1 }
  end
  table.sort(out.notable, function(x, y) if x.t ~= y.t then return x.t < y.t end return x.name < y.name end)
  return out
end

---------------------------------------------------------------------------
-- Events: a target looked at, a fight begun, a fight over, a death.
---------------------------------------------------------------------------
ns.On("PLAYER_TARGET_CHANGED", function()
  local info = look("target")
  if info then B.Note(info, false) end
end)
ns.On("PLAYER_REGEN_DISABLED", function()
  local info = look("target")
  if info and info.hostile then B.Note(info, true) end
end)
ns.On("PLAYER_REGEN_ENABLED", function() if dirty then B.Trim() end end)
ns.On("PLAYER_DEAD", function()
  local killer
  local f = ns.char and ns.char.lastFight
  if f and type(f.foe) == "table" and not f.foe.player then killer = f.foe.name end
  if U.Call(UnitExists, "target") and U.Call(UnitCanAttack, "player", "target") and not U.PlayerOwned("target") then
    killer = U.Plain(U.Call(UnitName, "target")) or killer
  end
  B.Death(killer)
end)
