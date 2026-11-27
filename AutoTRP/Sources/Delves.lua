-- Dungeon and raid runs, kept as stories (0.22.0). Each run into a dungeon or raid: when it
-- began and ended, how big the group was and its classes (counted, never named; Social
-- Diary friends aside, by name only when that's allowed), the masters brought down in order
-- (ENCOUNTER_END) and the failed tries at each (ENCOUNTER_END with success 0: a wipe), the
-- group's deaths (counted from the combat log's UNIT_DIED for group members, never named)
-- and the character's own, the rare and better loot received inside, how far they got and
-- whether it was a full clear of the place's known masters (Data/Delves.lua). The last 40
-- runs are kept, and totals per place. Kept in AutoTRPCharDB.delves, read into
-- ns.cache.delves. Game events only; every API through U.Call.
--
-- Light: the combat log handler returns at once unless a run is going inside a dungeon or
-- raid, and then for anything but UNIT_DIED; the group is read only out of a fight.
local _, ns = ...

local U = ns.U
local Dv = {}
ns.Sources = ns.Sources or {}
ns.Sources.Delves = Dv

Dv.KEEP = 40          -- runs kept
Dv.KEEP_PLACES = 40   -- places with totals
Dv.AWAY = 1800        -- out of the place this long (a release and run back is shorter), the run is over
Dv.LOOT = 6           -- fine pieces kept per run

local function store()
  if not ns.char then return nil end
  local d = ns.char.delves
  if type(d) ~= "table" then d = {}; ns.char.delves = d end
  if type(d.runs) ~= "table" then d.runs = {} end
  if type(d.places) ~= "table" then d.places = {} end
  return d
end
Dv.Store = store

-- The place's entry in Data/Delves.lua (masters, wings, lines), by any of its names.
function Dv.Place(name)
  local W = ns.Words
  if type(name) ~= "string" or not W or not W.DELVES then return nil end
  return W.DELVES[name] or W.DELVES[W.DELVE_ALIAS[name] or ""]
end

-- How a run went against the place's known masters: the wing it was in (the one with most
-- of its masters down), whether every master of it fell, how many of how many, and the
-- first master of the wing left standing.
function Dv.Judge(run)
  local entry = Dv.Place(run.place)
  local down = {}
  local n = 0
  for _, b in ipairs(run.bosses or {}) do if not down[b.name] then down[b.name] = true; n = n + 1 end end
  if not entry then return { got = n } end
  local wings = entry.wings or { { bosses = entry.bosses } }
  local best, bestN = wings[1], -1
  for _, w in ipairs(wings) do
    local k = 0
    for _, b in ipairs(w.bosses) do if down[b] then k = k + 1 end end
    if k > bestN then best, bestN = w, k end
  end
  local of = #best.bosses
  local finalDown = down[best.bosses[of]]
  local standing
  for _, b in ipairs(best.bosses) do if not down[b] then standing = b; break end end
  -- Every master by name, or (should a name differ on this client) as many as there are
  -- and the last of them.
  local full = bestN >= of or (finalDown and n >= of)
  return { got = math.max(bestN, 0), of = of, full = full and true or false, wing = best.name,
    standing = (not full) and standing or nil, raid = entry.raid }
end

---------------------------------------------------------------------------
-- The run going on
---------------------------------------------------------------------------
local members = {}   -- GUIDs of the others in the group right now, for UNIT_DIED (never kept)
local active = false -- inside a dungeon or raid with a run going: the combat log listens
local rosterDue = false

local function inCombat() return U.Call(InCombatLockdown) or U.Call(UnitAffectingCombat, "player") end

-- Friends from Social Diary in the group, by name (only when naming them is allowed).
local function friendsIn(units)
  if not ns.db or not ns.db.nameFriends then return nil end
  local sd = ns.cache and ns.cache.sd
  local known = {}
  for _, f in ipairs(sd and sd.friends or {}) do known[f.name] = true end
  if not next(known) then return nil end
  local out
  for _, u in ipairs(units) do
    local name = U.Call(UnitName, u)
    name = type(name) == "string" and name:match("^[^%-]+") or nil
    if name and known[name] then out = out or {}; out[#out + 1] = name end
  end
  return out
end

-- The group, out of a fight: how many, their classes (the most of each seen this run) and
-- their GUIDs for the deaths.
function Dv.Roster()
  local d = store()
  local run = d and d.cur
  if not run then return end
  if inCombat() then rosterDue = true; return end
  rosterDue = false
  local raid = U.Call(IsInRaid)
  local units = {}
  if raid then
    for i = 1, 40 do units[#units + 1] = "raid" .. i end
  elseif U.Call(IsInGroup) then
    for i = 1, 4 do units[#units + 1] = "party" .. i end
  end
  local me = U.Call(UnitGUID, "player")
  local counts, n, present = {}, 0, {}
  members = {}
  for _, u in ipairs(units) do
    local guid = U.Call(UnitGUID, u)
    if guid and guid ~= me then
      n = n + 1
      members[guid] = true
      present[#present + 1] = u
      local _, class = U.Call(UnitClass, u)
      if type(class) == "string" then counts[class] = (counts[class] or 0) + 1 end
    end
  end
  run.size = math.max(run.size or 1, n + 1)
  run.classes = run.classes or {}
  for class, k in pairs(counts) do run.classes[class] = math.max(run.classes[class] or 0, k) end
  local fr = friendsIn(present)
  if fr then
    run.friends = run.friends or {}
    for _, name in ipairs(fr) do
      local have = false
      for _, f in ipairs(run.friends) do if f == name then have = true end end
      if not have and #run.friends < 4 then run.friends[#run.friends + 1] = name end
    end
  end
end

-- Totals for a place, kept per place (at most KEEP_PLACES of them; the least visited go).
local function placeOf(d, name, kind)
  local p = d.places[name]
  if p then return p end
  local count, low, lowK = 0, nil, nil
  for k, v in pairs(d.places) do
    count = count + 1
    if not low or (v.runs or 0) < low then low, lowK = v.runs or 0, k end
  end
  if count >= Dv.KEEP_PLACES and lowK then d.places[lowK] = nil end
  p = { kind = kind, runs = 0, clears = 0, wipes = 0, deaths = 0, mine = 0, best = 0, tries = {}, kills = {} }
  d.places[name] = p
  return p
end

local function bumpCapped(t, key, n, cap)
  if t[key] then t[key] = t[key] + n; return end
  local count, low, lowK = 0, nil, nil
  for k, v in pairs(t) do count = count + 1; if not low or v < low then low, lowK = v, k end end
  if count >= cap and lowK then t[lowK] = nil end
  t[key] = n
end

-- The run is over: told, totted up and kept.
function Dv.Finish()
  local d = store()
  local run = d and d.cur
  if not run then return nil end
  d.cur = nil
  active = false
  run.stop = run.out or U.Now()
  run.out, run.fight = nil, nil
  local j = Dv.Judge(run)
  run.full, run.got, run.of, run.wing = j.full, j.got, j.of, j.wing
  run.standing = j.standing
  local p = placeOf(d, run.place, run.kind)
  p.runs = p.runs + 1
  p.first = p.first or run.start
  p.last = run.stop
  p.wipes = p.wipes + (run.wipes or 0)
  p.deaths = p.deaths + (run.deaths or 0)
  p.mine = p.mine + (run.mine or 0)
  for boss, n in pairs(run.tries or {}) do bumpCapped(p.tries, boss, n, 12) end
  for _, b in ipairs(run.bosses or {}) do bumpCapped(p.kills, b.name, 1, 24) end
  if run.full then
    p.clears = p.clears + 1
    if not p.firstClear then p.firstClear = run.stop; run.firstClear = true end
  end
  if (run.got or 0) > (p.best or 0) then
    p.best = run.got
    p.bestLast = run.bosses[#run.bosses] and run.bosses[#run.bosses].name
  end
  d.runs[#d.runs + 1] = run
  while #d.runs > Dv.KEEP do table.remove(d.runs, 1) end
  if ns.Compose then ns.Compose.SourcesChanged() end
  return run
end

-- A run over for good: out of the place too long.
function Dv.Settle()
  local d = store()
  local run = d and d.cur
  if run and run.out and U.Now() - run.out >= Dv.AWAY then Dv.Finish() end
end

-- Into a dungeon or raid. The same place again soon after stepping out (a release and the
-- run back, a hearth for repairs) is the same run.
function Dv.Enter(place, kind)
  local d = store()
  place = U.Plain(place)
  if not d or not place then return end
  local run = d.cur
  if run and run.place == place and (not run.out or U.Now() - run.out < Dv.AWAY) then
    run.out = nil
  else
    if run then Dv.Finish() end
    run = { place = place, kind = kind, start = U.Now(), size = 1, classes = {}, bosses = {}, tries = {},
      wipes = 0, deaths = 0, mine = 0, loot = {} }
    d.cur = run
  end
  active = true
  Dv.Roster()
end

function Dv.Leave()
  local d = store()
  local run = d and d.cur
  if run and not run.out then run.out = U.Now() end
  active = false
end

-- ENCOUNTER_START / ENCOUNTER_END.
function Dv.EncounterStart(name)
  local d = store()
  local run = d and d.cur
  name = U.Plain(name)
  if not run or not name then return end
  run.fight = { name = name, lost = 0 }
end

function Dv.EncounterEnd(name, success)
  local d = store()
  local run = d and d.cur
  name = U.Plain(name)
  if not run or not name then return end
  local lost = run.fight and run.fight.name == name and run.fight.lost or 0
  run.fight = nil
  if success == 1 or success == true then
    run.bosses[#run.bosses + 1] = { name = name, t = U.Now(), tries = run.tries[name] or 0, lost = lost }
    if #run.bosses > 24 then table.remove(run.bosses, 1) end
  else
    run.wipes = run.wipes + 1
    bumpCapped(run.tries, name, 1, 12)
    run.lostTo = run.lostTo or {}
    bumpCapped(run.lostTo, name, lost, 12)
  end
  if ns.Compose then ns.Compose.SourcesChanged() end
end

-- A group member died (counted, never named); the character's own deaths apart.
function Dv.Died(mine)
  local d = store()
  local run = d and d.cur
  if not run then return end
  if mine then run.mine = run.mine + 1 else run.deaths = run.deaths + 1 end
  if run.fight then run.fight.lost = run.fight.lost + 1 end
end

-- Fine loot (rare or better) received inside, by name and quality.
function Dv.Loot(item, quality)
  local d = store()
  local run = d and d.cur
  item = U.Plain(item)
  if not run or run.out or not item or (quality or 0) < 3 then return end
  for _, l in ipairs(run.loot) do if l.name == item then return end end
  run.loot[#run.loot + 1] = { name = item, q = quality, t = U.Now() }
  while #run.loot > Dv.LOOT do
    -- The plainest goes first.
    local lo, li = nil, nil
    for i, l in ipairs(run.loot) do if not lo or l.q < lo then lo, li = l.q, i end end
    table.remove(run.loot, li)
  end
end

---------------------------------------------------------------------------
-- Reading
---------------------------------------------------------------------------
local function copyRun(r, ongoing)
  local o = {}
  for k, v in pairs(r) do o[k] = v end
  o.ongoing = ongoing or nil
  if ongoing then
    o.stop = r.out or U.Now()
    local j = Dv.Judge(r)
    o.full, o.got, o.of, o.wing, o.standing = j.full, j.got, j.of, j.wing, j.standing
  end
  local entry = Dv.Place(r.place)
  o.name = entry and entry.name or U.Mid(r.place)
  o.entry = entry
  o.others = math.max(0, (r.size or 1) - 1)
  return o
end

-- { runs = newest first (a run stepped out of counts, marked ongoing), inside = the run
--   going on right now or nil, places = { [place] = totals } }. A fresh table each time.
function Dv.Read()
  local d = store()
  if not d then return nil end
  Dv.Settle()
  local out = { runs = {}, places = {} }
  if d.cur and d.cur.out then out.runs[1] = copyRun(d.cur, true)
  elseif d.cur then out.inside = copyRun(d.cur, true) end
  for i = #d.runs, 1, -1 do out.runs[#out.runs + 1] = copyRun(d.runs[i]) end
  for name, p in pairs(d.places) do
    local o = {}
    for k, v in pairs(p) do o[k] = v end
    local entry = Dv.Place(name)
    o.name = entry and entry.name or U.Mid(name)
    o.entry = entry
    out.places[name] = o
  end
  return out
end

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------
local function check()
  local inside, kind = U.Call(IsInInstance)
  if inside and (kind == "party" or kind == "raid") then
    local name = U.Call(GetInstanceInfo)
    Dv.Enter(name or U.Call(GetRealZoneText), kind)
  else
    Dv.Leave()
    Dv.Settle()
  end
end
Dv.Check = check
ns.On("PLAYER_ENTERING_WORLD", check)
ns.On("ZONE_CHANGED_NEW_AREA", check)
ns.On("GROUP_ROSTER_UPDATE", function() if active then Dv.Roster() end end)
ns.On("PLAYER_REGEN_ENABLED", function() if active and rosterDue then Dv.Roster() end end)
ns.On("ENCOUNTER_START", function(_, _, name) if active then Dv.EncounterStart(name) end end)
ns.On("ENCOUNTER_END", function(_, _, name, _, _, success) if active then Dv.EncounterEnd(name, success) end end)
ns.On("PLAYER_DEAD", function() if active then Dv.Died(true) end end)

local QUALITY_HEX = { ["0070dd"] = 3, a335ee = 4, ff8000 = 5, e6cc80 = 6 }
function Dv.OnLoot(msg)
  if not active then return end
  msg = U.Unsecret(msg)
  if type(msg) ~= "string" then return end
  -- Only what the character receives ("You receive loot", "You receive item"), not others' rolls.
  if not msg:find("^You receive") then return end
  local item = msg:match("%[(.-)%]")
  if not item then return end
  local q = tonumber(msg:match("|cnIQ(%d+):"))
  if not q then
    local hex = msg:match("|cff(%x%x%x%x%x%x)")
    q = hex and QUALITY_HEX[hex:lower()]
  end
  if q then Dv.Loot(item, q) end
end
ns.On("CHAT_MSG_LOOT", function(_, msg) Dv.OnLoot(msg) end)

-- Deaths in the group: only UNIT_DIED, only inside, only for someone in the group.
ns.On("COMBAT_LOG_EVENT_UNFILTERED", function()
  if not active then return end
  local _, sub, _, _, _, _, _, dest = U.CallAll(_G.CombatLogGetCurrentEventInfo)
  if sub ~= "UNIT_DIED" or not dest or not members[dest] then return end
  Dv.Died(false)
end)

ns.Listen("LOGIN", function() ns.After(5, check) end)
