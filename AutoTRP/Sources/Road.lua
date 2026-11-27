-- Auto TRP's record of the road, land by land: how long the character has spent in each
-- (played time, away-from-keyboard and fights left out, and the days a stay lasted), the
-- level they arrived at and the levels gained there, the deaths and close calls there, the
-- dungeons entered from it and the masters brought down in them, the subzones, towns and
-- inns they've used there, its flight masters, the first and last visit and how often
-- they've come back. Quests turned in there come from Sources/Deeds.lua when it's read.
-- Kept per character in AutoTRPCharDB.road and read into ns.cache.road. Game events and
-- game APIs only: no other addon is needed.
--
-- Light by design: one ticker every thirty seconds does a few sums and nothing at all in a
-- fight (the time is credited once it ends); the events only bump counters; every list is
-- capped, and past R.CAP_ZONES lands the least visited (the oldest of those) is dropped.
local _, ns = ...

local U = ns.U
local R = {}
ns.Sources = ns.Sources or {}
ns.Sources.Road = R

R.CAP_ZONES = 60        -- lands kept (classic has fewer; the least visited, oldest first, go)
R.CAP_SUBS = 12         -- subzones kept per land (the least visited go)
R.CAP_SMALL = 6         -- towns, inns, flight masters, dungeons and masters kept per land
R.CAP_TRAIL = 16        -- the latest arrivals, for where they've been lately
R.TICK = 30             -- seconds between looks at the clock
R.GAP = 120             -- more than this between looks, and the time in between isn't counted
R.STAY_CAP = 10 * 86400 -- one stay counts for this long at most (a character parked for months)
R.RETURN = 1800         -- back in a land after this long away counts as another visit
R.AWAY = 7 * 86400      -- back after this long away is news
R.DAYS = 14             -- days of recent time kept per land

local function now() return U.Now() end
local function day(t) return math.floor(t / 86400) end

local function store()
  if not ns.char then return nil end
  local d = ns.char.road
  if type(d) ~= "table" then
    local life = ns.char.life
    d = { zones = {}, trail = {}, since = now(), closeSeen = life and type(life.close) == "table" and tonumber(life.close.n) or 0 }
    ns.char.road = d
    -- Lands reached before the record began: known, with when, but no time counted.
    local seen = type(ns.char.seen) == "table" and type(ns.char.seen.zones) == "table" and ns.char.seen.zones or {}
    local inside = ns.char.deeds and type(ns.char.deeds.instances) == "table" and ns.char.deeds.instances or {}
    local n = 0
    for name, t in pairs(seen) do
      if type(name) == "string" and tonumber(t) and not inside[name] and n < R.CAP_ZONES then
        d.zones[name] = { first = tonumber(t), last = tonumber(t), secs = 0, wall = 0, visits = 1, before = true }
        n = n + 1
      end
    end
  end
  if type(d.zones) ~= "table" then d.zones = {} end
  if type(d.trail) ~= "table" then d.trail = {} end
  d.since = tonumber(d.since) or now()
  return d
end
R.Store = store

-- t[key] += 1, keeping at most cap keys: a new key pushes out the least counted one.
local function bump(t, key, cap)
  if t[key] then t[key] = t[key] + 1; return end
  local count, lo, lk = 0, nil, nil
  for k, v in pairs(t) do
    count = count + 1
    if not lo or v < lo then lo, lk = v, k end
  end
  if count >= cap and lk then t[lk] = nil end
  t[key] = 1
end

-- A name kept once with when it was first seen, at most cap of them.
local function keep(t, key, t0, cap)
  if t[key] then return false end
  if U.Count(t) >= cap then return false end
  t[key] = t0
  return true
end

-- A land's record, made if it's new (dropping the least visited when there are too many).
local function record(d, name, t)
  local z = d.zones[name]
  if z then return z end
  if U.Count(d.zones) >= R.CAP_ZONES then
    local lo, lk
    for k, v in pairs(d.zones) do
      if not (d.cur and d.cur.zone == k) then
        local score = (v.visits or 1) * 1e10 + (v.last or 0)
        if not lo or score < lo then lo, lk = score, k end
      end
    end
    if lk then d.zones[lk] = nil end
  end
  z = { first = t, last = t, secs = 0, wall = 0, visits = 0 }
  d.zones[name] = z
  return z
end

local function level() return tonumber((U.Call(UnitLevel, "player"))) end
-- A building some clients give as the zone counts as the zone it's in (World.Where).
local function zoneName() return (ns.World.Where((U.Call(IsInInstance)) and true or false)) end

---------------------------------------------------------------------------
-- Recording
---------------------------------------------------------------------------
-- The time since the last look, to the land they're in: not a gap (logged out, a loading
-- screen that hung) and not while away from the keyboard.
local function credit(d, t)
  local cur = d.cur
  local gap = t - (cur.tick or t)
  cur.tick = t
  local z = d.zones[cur.zone]
  if not z or gap <= 0 or gap > R.GAP or U.Call(UnitIsAFK, "player") then return end
  z.secs = (z.secs or 0) + gap
  z.last = t
  local lv = level()
  if lv then z.lvlOut = math.max(z.lvlOut or 0, lv) end
  z.days = z.days or {}
  local today = day(t)
  z.days[today] = (z.days[today] or 0) + gap
  for k in pairs(z.days) do if k <= today - R.DAYS then z.days[k] = nil end end
end

-- Leaving the land they're in (t: when; the last look at the clock if they logged out).
function R.Leave(t)
  local d = store()
  local cur = d and d.cur
  if not cur then return end
  t = t or now()
  if t - (cur.tick or t) <= R.GAP and not U.Call(InCombatLockdown) then credit(d, t) end
  local z = d.zones[cur.zone]
  if z then
    local stay = math.max(0, math.min(t - (cur.since or t), R.STAY_CAP))
    z.wall = (z.wall or 0) + stay
    z.last = math.max(z.last or 0, t)
    d.left = { zone = cur.zone, t = t, stay = stay, secs = (z.secs or 0) - (cur.secs0 or 0) }
  end
  d.cur = nil
end

-- Arriving in a land (not a dungeon). Returns true when it's somewhere other than before.
function R.Arrive(name, t)
  local d = store()
  name = U.Plain(name)
  if not d or not name then return false end
  t = t or now()
  if d.cur and d.cur.zone == name then return false end
  -- Logged out somewhere else: the stay there ended at the last look at the clock.
  if d.cur then R.Leave((t - (d.cur.tick or t) > R.GAP) and d.cur.tick or t) end
  local z = record(d, name, t)
  local gone = (z.last and z.visits > 0) and (t - z.last) or nil
  if not gone or gone > R.RETURN then z.visits = (z.visits or 0) + 1 end
  if gone and gone > R.AWAY and ((z.secs or 0) >= 1800 or z.before) then
    d.back = { zone = name, t = t, away = gone }
  end
  z.lvlIn = z.lvlIn or level()
  z.last = t
  d.cur = { zone = name, since = t, tick = t, secs0 = z.secs or 0 }
  d.outside = name
  local tr = d.trail
  if not (tr[#tr] and tr[#tr].zone == name and gone and gone <= R.RETURN) then
    tr[#tr + 1] = { zone = name, t = t }
    while #tr > R.CAP_TRAIL do table.remove(tr, 1) end
  end
  if ns.Compose then ns.Compose.SourcesChanged() end
  return true
end

-- Where they are: a land, or inside a dungeon (whose land is the one they came in from).
function R.Where()
  local d = store()
  if not d then return end
  local inside, kind = U.Call(IsInInstance)
  if inside and kind and kind ~= "none" then
    local name = U.Plain((U.Call(GetInstanceInfo))) or zoneName()
    if d.cur then
      local t = now()
      R.Leave((t - (d.cur.tick or t) > R.GAP) and d.cur.tick or t)
    end
    d.inside = name
    local z = d.outside and d.zones[d.outside]
    if z and name and (kind == "party" or kind == "raid") then
      z.dungeons = z.dungeons or {}
      keep(z.dungeons, name, now(), R.CAP_SMALL)
    end
    return
  end
  d.inside = nil
  local name = zoneName()
  if name then R.Arrive(name) end
  R.Sub()
end

-- The clock: time in the land they're in, out of a fight and not away from the keyboard.
-- In a fight nothing is done; the time is counted at the next look after it.
function R.Tick()
  local d = store()
  if not d or U.Call(InCombatLockdown) then return end
  if not d.cur then
    if not d.inside then R.Where() end
    return
  end
  credit(d, now())
end

-- A subzone entered: counted once per arrival; rested in, it's a town (or an inn).
function R.Sub()
  local d = store()
  local cur = d and d.cur
  if not cur then return end
  local sub = U.Plain(U.Call(GetSubZoneText))
  local z = d.zones[cur.zone]
  if not z or not sub or sub == cur.zone then return end
  if cur.sub ~= sub then
    z.subs = z.subs or {}
    bump(z.subs, sub, R.CAP_SUBS)
    cur.sub = sub
  end
  if U.Call(IsResting) then
    local isInn = ns.World and ns.World.IsInn(sub)
    local key = isInn and "inns" or "towns"
    z[key] = z[key] or {}
    if cur[key] ~= sub then bump(z[key], sub, R.CAP_SMALL); cur[key] = sub end
  end
end

function R.LevelUp(lv)
  local d = store()
  local z = d and d.cur and d.zones[d.cur.zone]
  lv = tonumber(lv)
  if not z or not lv then return end
  z.ups = (z.ups or 0) + 1
  z.upLo = math.min(z.upLo or lv, lv)
  z.upHi = math.max(z.upHi or lv, lv)
  z.lvlOut = math.max(z.lvlOut or 0, lv)
end

-- A death out in the open (one in a dungeon isn't the land's).
function R.Death()
  local d = store()
  local z = d and not d.inside and d.cur and d.zones[d.cur.zone]
  if z then z.deaths = (z.deaths or 0) + 1 end
end

-- Close calls: Sources/Life.lua counts them; the new ones are the land's.
function R.Close()
  local d = store()
  if not d then return end
  local life = ns.char and ns.char.life
  local n = life and type(life.close) == "table" and tonumber(life.close.n) or 0
  local z = not d.inside and d.cur and d.zones[d.cur.zone]
  if z and d.closeSeen and n > d.closeSeen then z.close = (z.close or 0) + (n - d.closeSeen) end
  d.closeSeen = n
end

-- A master brought down: the dungeon's land keeps it.
function R.Boss(name)
  local d = store()
  name = U.Plain(name)
  local z = d and name and d.outside and d.zones[d.outside]
  if not z then return end
  z.bosses = z.bosses or {}
  keep(z.bosses, name, now(), R.CAP_SMALL)
end

-- The flight map: "Sentinel Hill, Westfall" is Westfall's.
function R.Paths(names)
  local d = store()
  if not d or type(names) ~= "table" then return end
  for _, n in ipairs(names) do
    n = U.Plain(n)
    local place, land = n and n:match("^(.-),%s*(.+)$")
    local z = land and d.zones[land]
    if z then
      z.paths = z.paths or {}
      keep(z.paths, place, now(), R.CAP_SMALL)
    end
  end
end

---------------------------------------------------------------------------
-- Reading it back: a fresh table each time.
---------------------------------------------------------------------------
local storyOf
local function stories()
  if storyOf then return storyOf end
  storyOf = {}
  for _, st in ipairs(ns.Words and ns.Words.SELF_STORIES or {}) do
    for _, q in ipairs(st.quests or {}) do storyOf[q] = st end
    for _, q in ipairs(st.ends or {}) do storyOf[q] = st end
  end
  return storyOf
end

local function topOf(t)
  local best, bn
  for k, v in pairs(type(t) == "table" and t or {}) do
    if type(v) == "number" and (not bn or v > bn or (v == bn and k < best)) then best, bn = k, v end
  end
  return best, bn or 0
end
local function namesBy(t)
  local out = {}
  for k, v in pairs(type(t) == "table" and t or {}) do out[#out + 1] = { name = k, t = tonumber(v) or 0 } end
  table.sort(out, function(a, b) if a.t ~= b.t then return a.t < b.t end return a.name < b.name end)
  return out
end

-- { zones = { { name, first, last, secs, wall, visits, here, lvlIn, lvlOut, ups, upLo, upHi,
--   quests, story = { title, n }, deaths, close, dungeons = { {name, t} }, bosses, subs,
--   town, inn, paths, recent (seconds this past week) }, in order of first visit },
--   byName, longest, mostVisited, lately, back, left, cur, trail }
function R.Read()
  local d = store()
  if not d then return nil end
  local t = now()
  -- Jobs done in each land, and the storyline most of them belonged to.
  local jobs = {}
  local deeds = ns.char and ns.char.deeds
  local map = stories()
  for title, q in pairs(deeds and type(deeds.quests) == "table" and deeds.quests or {}) do
    if type(q) == "table" and q.zone then
      local j = jobs[q.zone]
      if not j then j = { n = 0, by = {}, st = {} }; jobs[q.zone] = j end
      j.n = j.n + 1
      local st = map[title]
      if st then j.by[st.id] = (j.by[st.id] or 0) + 1; j.st[st.id] = st end
    end
  end
  local out = { zones = {}, byName = {}, trail = {}, cur = d.cur and d.cur.zone or nil, inside = d.inside }
  local today = day(t)
  for name, z in pairs(d.zones) do
    local e = { name = name, first = z.first or 0, last = z.last or 0, secs = z.secs or 0, wall = z.wall or 0,
      visits = math.max(1, z.visits or 1), before = z.before, lvlIn = z.lvlIn, lvlOut = z.lvlOut,
      ups = z.ups or 0, upLo = z.upLo, upHi = z.upHi, deaths = z.deaths or 0, close = z.close or 0,
      dungeons = namesBy(z.dungeons), bosses = namesBy(z.bosses), paths = namesBy(z.paths) }
    if d.cur and d.cur.zone == name then
      e.here = true
      e.wall = e.wall + math.max(0, math.min(t - (d.cur.since or t), R.STAY_CAP))
      e.last = t
    end
    local j = jobs[name]
    e.quests = j and j.n or 0
    if j then
      local id, n = topOf(j.by)
      if id then e.story = { title = j.st[id].title, n = n, id = id } end
    end
    e.sub, e.subN = topOf(z.subs)
    e.subsSeen = U.Count(z.subs)
    e.town = topOf(z.towns)
    e.inn, e.innN = topOf(z.inns)
    e.recent = 0
    for k, v in pairs(z.days or {}) do if k > today - 7 then e.recent = e.recent + v end end
    out.zones[#out.zones + 1] = e
    out.byName[name] = e
  end
  table.sort(out.zones, function(a, b) if a.first ~= b.first then return a.first < b.first end return a.name < b.name end)
  for _, e in ipairs(out.zones) do
    if e.secs > 0 and (not out.longest or e.secs > out.longest.secs) then out.longest = e end
    if e.visits > 1 and (not out.mostVisited or e.visits > out.mostVisited.visits) then out.mostVisited = e end
    if e.recent > 0 and (not out.lately or e.recent > out.lately.recent) then out.lately = e end
  end
  for i, a in ipairs(d.trail) do out.trail[i] = { zone = a.zone, t = a.t } end
  if d.back then out.back = { zone = d.back.zone, t = d.back.t, away = d.back.away } end
  if d.left then out.left = { zone = d.left.zone, t = d.left.t, stay = d.left.stay, secs = d.left.secs } end
  out.since = d.since
  return out
end

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------
ns.On("ZONE_CHANGED_NEW_AREA", function() R.Where() end)
ns.On("PLAYER_ENTERING_WORLD", function() R.Where() end)
ns.On("ZONE_CHANGED", function() R.Sub() end)
ns.On("ZONE_CHANGED_INDOORS", function() R.Sub() end)
ns.On("PLAYER_UPDATE_RESTING", function() R.Sub() end)
ns.On("PLAYER_LEVEL_UP", function(_, lv) R.LevelUp(lv) end)
ns.On("PLAYER_DEAD", function() R.Death() end)
-- After Sources/Life.lua's own handler, which counts the close call first.
ns.On("PLAYER_REGEN_ENABLED", function() R.Close() end)
ns.On("ENCOUNTER_END", function(_, _, name, _, _, success)
  if success == 1 and type(name) == "string" then R.Boss(name) end
end)
ns.On("TAXIMAP_OPENED", function()
  local n = tonumber((U.Call(_G.NumTaxiNodes))) or 0
  local names = {}
  for i = 1, math.min(n, 200) do
    local kind = U.Call(_G.TaxiNodeGetType, i)
    if kind == "REACHABLE" or kind == "CURRENT" then names[#names + 1] = U.Call(_G.TaxiNodeName, i) end
  end
  R.Paths(names)
end)

ns.Listen("LOGIN", function()
  local d = store()
  if not d then return end
  local life = ns.char.life
  d.closeSeen = life and type(life.close) == "table" and tonumber(life.close.n) or 0
  R.Where()
  ns.Ticker(R.TICK, R.Tick)
end)
