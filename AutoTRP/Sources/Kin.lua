-- Auto TRP's record of a character's people: time spent in their capital and home lands
-- against time abroad, the homecomings (back in the capital after days away), the racial
-- gifts they use and when one mattered (a fear thrown off, a poison stopped, a root
-- slipped), the tongues they speak aloud (counted by language, never read), their home
-- city's regard, the places that matter to their people (W.RACE_PLACES) and the old
-- enemies of their people they cut down. Kept per character in AutoTRPCharDB.kin and read
-- into ns.cache.kin. Only game events and game APIs: no other addon is needed.
--
-- Light by design: the clock is a thirty-second tick that adds up seconds and, outside a
-- fight, reads the zone; the combat log handler bails out on a table lookup for anything
-- but three sub-events; spell names are looked up once per spell; every list is capped.
local _, ns = ...

local U = ns.U
local W = ns.Words
local KW = W.KIN
local K = {}
ns.Sources = ns.Sources or {}
ns.Sources.Kin = K

K.TICK = 30            -- seconds between looks at where they are
K.MAX_STEP = 120       -- a longer gap (a loading screen, a stall) isn't counted
K.VISIT_GAP = 3 * 86400 -- back in the capital after this long away is a homecoming
K.SETTLE = 3600        -- places seen in the record's first hour were known before it
K.CAP_ZONES = 40
K.CAP_LANGS = 12
K.CAP_RACIALS = 12

local function race()
  local r = select(2, U.Call(UnitRace, "player"))
  if r == "Undead" then r = "Scourge" end
  return r
end
K.Race = race

local function store()
  if not ns.char then return nil end
  local d = ns.char.kin
  if type(d) ~= "table" then d = {}; ns.char.kin = d end
  d.since = tonumber(d.since) or U.Now()
  for _, k in ipairs({ "time", "zones", "visits", "racials", "mattered", "langs", "known", "places", "foes" }) do
    if type(d[k]) ~= "table" then d[k] = {} end
  end
  return d
end
K.Store = store

local function settled(d) return U.Now() - (d.since or 0) > K.SETTLE end

-- t[key] += n, keeping at most cap keys (the least counted goes).
local function bump(t, key, n, cap)
  n = n or 1
  if type(t[key]) == "number" then t[key] = t[key] + n; return end
  if cap and U.Count(t) >= cap then
    local lo, lk
    for k, v in pairs(t) do if type(v) == "number" and (not lo or v < lo) then lo, lk = v, k end end
    if lk and lo <= n then t[lk] = nil else return end
  end
  t[key] = n
end

-- The zone by its English name (from the map ID on any client), and the subzone.
local function where()
  local zone = U.Plain(U.Call(GetRealZoneText))
  local mapFn = _G.C_Map and _G.C_Map.GetBestMapForUnit
  local mapID = mapFn and U.Call(mapFn, "player")
  local key = (type(mapID) == "number" and W.ZONE_BY_MAP and W.ZONE_BY_MAP[mapID]) or zone
  local sub = U.Plain(U.Call(GetSubZoneText))
  if sub == zone then sub = nil end
  return key, sub
end

-- "capital", "home" or "abroad" (nil for a people with no home here).
function K.Kind(zoneKey, r)
  local home = KW.HOME[r or race() or ""]
  if not home or not zoneKey then return nil end
  if zoneKey == home.capital then return "capital" end
  if home.lands[zoneKey] then return "home" end
  return "abroad"
end

---------------------------------------------------------------------------
-- Recording
---------------------------------------------------------------------------
-- A place that matters to their people (zone or subzone): the first visit, then each
-- visit again after an hour away.
function K.Place(key)
  local d = store()
  local list = W.RACE_PLACES[race() or ""]
  if not d or not key or not list or not list[key] then return false end
  local now = U.Now()
  local p = d.places[key]
  if p then
    if now - (p.last or 0) > 3600 then p.n = (p.n or 1) + 1 end
    p.last = now
    return false
  end
  d.places[key] = { t = now, last = now, n = 1, before = not settled(d) or nil }
  return true
end

-- Back in the capital after days away.
function K.Homecoming(away)
  local d = store()
  if not d then return end
  local v = d.visits
  v.n = (v.n or 0) + 1
  v.log = type(v.log) == "table" and v.log or {}
  table.insert(v.log, { t = U.Now(), away = math.floor(away) })
  while #v.log > 6 do table.remove(v.log, 1) end
  local home = KW.HOME[race() or ""]
  if ns.Mood and home then ns.Mood.Push("homecoming", 30, "back in " .. home.capital .. " after " .. K.Days(away)) end
end

-- Where they are, and the time since the last look added to it.
local cur
function K.Tick()
  local d = store()
  if not d then return end
  local now = U.Now()
  if cur and cur.at then
    local dt = now - cur.at
    if dt > 0 and dt <= K.MAX_STEP and cur.kind and not U.Call(_G.UnitIsAFK, "player") then
      d.time[cur.kind] = (d.time[cur.kind] or 0) + dt
      if cur.zone then bump(d.zones, cur.zone, dt, K.CAP_ZONES) end
    end
  end
  if cur and U.Call(InCombatLockdown) then cur.at = now; return end
  local key, sub = where()
  local r = race()
  local kind = K.Kind(key, r)
  if kind == "capital" then
    if d.lastCapital and now - d.lastCapital >= K.VISIT_GAP then K.Homecoming(now - d.lastCapital) end
    d.lastCapital = now
  end
  if kind == "capital" or kind == "home" then d.lastHome = now end
  if sub then K.Place(sub) end
  if key then K.Place(key) end
  cur = { zone = key, kind = kind, at = now }
end
function K.ResetClock() cur = nil end

-- What was done to them just now, from the combat log: crowd control, a snare, a poison
-- or a bleed ticking.
local lastCC, lastSnare, lastDot
function K.Hurt(kind, t)
  if kind == "snare" then lastSnare = t or U.Now()
  elseif kind == "poison" or kind == "bleed" then lastDot = { kind = kind, t = t or U.Now() }
  else lastCC = { kind = kind, t = t or U.Now() } end
end

local function healthShare()
  local hp, max = U.Call(UnitHealth, "player"), U.Call(UnitHealthMax, "player")
  if type(hp) ~= "number" or type(max) ~= "number" or max <= 0 then return 1 end
  return hp / max
end

-- Why a racial gift mattered just now, or nil.
function K.Mattered(name)
  local def = KW.RACIALS[name]
  local now = U.Now()
  if not def or not def.when then return nil end
  if def.when == "mind" then
    if lastCC and KW.MIND[lastCC.kind] and now - lastCC.t <= 5 then return lastCC.kind end
  elseif def.when == "root" then
    if lastCC and KW.ROOT[lastCC.kind] and now - lastCC.t <= 6 then return "root" end
    if lastSnare and now - lastSnare <= 6 then return "snare" end
  elseif def.when == "dot" then
    if lastDot and now - lastDot.t <= 6 then return lastDot.kind end
  elseif def.when == "fight" then
    if U.Call(InCombatLockdown) or U.Call(UnitAffectingCombat, "player") then return "fight" end
  elseif def.when == "low" then
    if healthShare() < 0.35 then return "low" end
  elseif def.when == "mend" then
    if healthShare() < 0.7 then return "mend" end
  end
  return nil
end

-- A racial gift used: counted, and noted when it mattered.
function K.Racial(name, why)
  local d = store()
  if not d or not KW.RACIALS[name] then return false end
  local r = d.racials[name]
  if type(r) ~= "table" then
    if U.Count(d.racials) >= K.CAP_RACIALS then return false end
    r = { n = 0, m = 0 }
    d.racials[name] = r
  end
  local now = U.Now()
  r.n, r.t = (r.n or 0) + 1, now
  if why then
    r.m = (r.m or 0) + 1
    table.insert(d.mattered, { t = now, name = name, why = why })
    while #d.mattered > 6 do table.remove(d.mattered, 1) end
  end
  return true
end

-- A line said aloud (/say or /yell) in a language: counted, never read.
function K.Spoke(lang)
  local d = store()
  if not d then return end
  if type(lang) ~= "string" or lang == "" then lang = d.default end
  if type(lang) ~= "string" then return end
  bump(d.langs, lang, 1, K.CAP_LANGS)
end

-- The tongues they know, and the one they speak by default.
function K.Languages()
  local d = store()
  if not d then return end
  local default = U.Call(_G.GetDefaultLanguage, "player")
  if type(default) == "string" then d.default = default end
  local n = tonumber((U.Call(_G.GetNumLanguages))) or 0
  if n > 0 then
    local known = {}
    for i = 1, math.min(n, 8) do
      local name = U.Call(_G.GetLanguageByIndex, i)
      if type(name) == "string" then known[#known + 1] = name end
    end
    d.known = known
  end
end

-- An old enemy of their people, by the creature's name: which kind (cached per name).
local foeOf, foeCached = {}, 0
function K.FoeKind(name, r)
  if type(name) ~= "string" then return nil end
  local hit = foeOf[name]
  if hit ~= nil then return hit or nil end
  hit = false
  for _, f in ipairs(KW.FOES[r or race() or ""] or {}) do
    if f.names and f.names[name] then hit = f.key end
    for _, p in ipairs(not hit and f.prefix or {}) do if name:sub(1, #p) == p then hit = f.key; break end end
    for _, w in ipairs(not hit and f.word or {}) do if name:find(w, 1, true) then hit = f.key; break end end
    if hit then break end
  end
  if foeCached >= 300 then foeOf, foeCached = {}, 0 end
  foeOf[name], foeCached = hit, foeCached + 1
  return hit or nil
end
function K.ResetFoes() foeOf, foeCached = {}, 0 end

function K.Kill(name)
  local d = store()
  local key = d and K.FoeKind(name)
  if not key then return false end
  local f = d.foes[key]
  if type(f) ~= "table" then f = { n = 0, first = U.Now() }; d.foes[key] = f end
  f.n, f.t = f.n + 1, U.Now()
  return true
end

-- Their home city's regard: the standing (1 hated .. 8 exalted), read outside a fight.
function K.Standing()
  local d = store()
  local home = KW.HOME[race() or ""]
  if not d or not home then return end
  local n = tonumber((U.Call(_G.GetNumFactions))) or 0
  for i = 1, math.min(n, 100) do
    local name, _, standing = U.Call(_G.GetFactionInfo, i)
    if name == home.faction and tonumber(standing) then
      standing = tonumber(standing)
      if not d.rep or d.rep.id ~= standing then d.rep = { id = standing, t = U.Now(), was = d.rep and d.rep.id or nil } end
      return standing
    end
  end
end

-- What the profile tells from is read again on the next update after any of these.
for _, name in ipairs({ "Place", "Homecoming", "Racial", "Kill" }) do
  local fn = K[name]
  K[name] = function(...)
    local a, b = fn(...)
    if ns.Compose then ns.Compose.SourcesChanged() end
    return a, b
  end
end

---------------------------------------------------------------------------
-- Reading it back: a fresh table each time.
---------------------------------------------------------------------------
function K.Read()
  local d = store()
  if not d then return nil end
  local r = race()
  local now = U.Now()
  local o = { race = r, home = KW.HOME[r or ""], since = d.since }
  o.capital = (d.time.capital or 0)
  o.homeland = (d.time.home or 0)
  o.abroad = (d.time.abroad or 0)
  o.atHome = o.capital + o.homeland
  o.total = o.atHome + o.abroad
  o.lastCapital, o.lastHome = d.lastCapital, d.lastHome
  if o.home then o.awayFor = now - (d.lastCapital or d.since) end
  o.visits = d.visits.n or 0
  o.visitLog = {}
  for i = #(d.visits.log or {}), 1, -1 do o.visitLog[#o.visitLog + 1] = d.visits.log[i] end
  o.racials = {}
  for name, v in pairs(d.racials) do
    if type(v) == "table" then o.racials[#o.racials + 1] = { name = name, n = v.n or 0, m = v.m or 0, t = v.t or 0 } end
  end
  table.sort(o.racials, function(a, b) if a.n ~= b.n then return a.n > b.n end return a.name < b.name end)
  o.mattered = {}
  for i = #d.mattered, 1, -1 do o.mattered[#o.mattered + 1] = d.mattered[i] end
  o.langs, o.spoken = {}, 0
  for lang, n in pairs(d.langs) do if type(n) == "number" then o.langs[lang] = n; o.spoken = o.spoken + n end end
  o.known, o.default = {}, d.default
  for _, l in ipairs(d.known) do o.known[l] = true end
  o.places = {}
  local list = W.RACE_PLACES[r or ""] or {}
  for key, p in pairs(d.places) do
    local def = list[key]
    if type(p) == "table" and def then
      o.places[#o.places + 1] = { name = key, t = p.t or 0, last = p.last or p.t or 0, n = p.n or 1, before = p.before, mood = def[1], why = def[3] }
    end
  end
  table.sort(o.places, function(a, b) if a.t ~= b.t then return a.t > b.t end return a.name < b.name end)
  o.foes = {}
  for _, f in ipairs(KW.FOES[r or ""] or {}) do
    local rec = d.foes[f.key]
    if type(rec) == "table" and (rec.n or 0) > 0 then o.foes[#o.foes + 1] = { key = f.key, say = f.say, n = rec.n, t = rec.t or 0 } end
  end
  table.sort(o.foes, function(a, b) if a.n ~= b.n then return a.n > b.n end return a.key < b.key end)
  o.rep = d.rep and d.rep.id or nil
  return o
end

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------
local me, pet
local function guids()
  if not me then me = U.Call(UnitGUID, "player") end
  return me, U.Call(UnitGUID, "pet")
end
ns.On("PLAYER_ENTERING_WORLD", function() me = nil; K.ResetClock(); K.Tick() end)
ns.On("ZONE_CHANGED_NEW_AREA", K.Tick)
ns.On("ZONE_CHANGED", function() if not U.Call(InCombatLockdown) then K.Tick() end end)
ns.On("ZONE_CHANGED_INDOORS", function() if not U.Call(InCombatLockdown) then K.Tick() end end)

-- Racial gifts: each spell's name looked up once.
local spellName = {}
local function nameOf(id)
  local n = spellName[id]
  if n ~= nil then return n or nil end
  n = (_G.C_Spell and _G.C_Spell.GetSpellName and U.Call(_G.C_Spell.GetSpellName, id)) or U.Call(_G.GetSpellInfo, id)
  spellName[id] = type(n) == "string" and n or false
  return type(n) == "string" and n or nil
end
ns.OnUnit("UNIT_SPELLCAST_SUCCEEDED", "player", function(_, _, _, spellID)
  if type(spellID) ~= "number" then return end
  local name = nameOf(spellID)
  if name and KW.RACIALS[name] then K.Racial(name, K.Mattered(name)) end
end)

-- The combat log: out at once unless it's one of these three.
local WATCH = { SPELL_AURA_APPLIED = 1, SPELL_PERIODIC_DAMAGE = 2, PARTY_KILL = 3 }
local SCHOOL = { [8] = "poison", [1] = "bleed" }
function K.OnCombatLog(...)
  local _, sub, _, src, _, _, _, dst, dstName, _, _, _, a13, a14, a15 = ...
  local k = WATCH[sub]
  if not k then return end
  local mine = me or guids()
  if k == 1 then
    if dst == mine and a15 == "DEBUFF" and type(a13) == "string" then
      local cc = W.CROWD_CONTROL and W.CROWD_CONTROL[a13]
      if cc then K.Hurt(cc) elseif KW.SNARES[a13] then K.Hurt("snare") end
    end
  elseif k == 2 then
    if dst == mine and SCHOOL[a14] then K.Hurt(SCHOOL[a14]) end
  else
    if src ~= mine and src ~= select(2, guids()) then return end
    if type(dst) == "string" and dst:find("^Player%-") then return end
    K.Kill(dstName)
  end
end
ns.On("COMBAT_LOG_EVENT_UNFILTERED", function()
  local fn = _G.CombatLogGetCurrentEventInfo
  if type(fn) == "function" then K.OnCombatLog(U.CallAll(fn)) end
end)

-- Speech: who said it (only the player's own lines count) and the language. The words
-- themselves are never read.
local function mine(sender)
  local name = U.Call(UnitName, "player")
  return type(sender) == "string" and type(name) == "string" and (sender == name or sender:sub(1, #name + 1) == name .. "-")
end
ns.On("CHAT_MSG_SAY", function(_, _, sender, lang) if mine(sender) then K.Spoke(lang) end end)
ns.On("CHAT_MSG_YELL", function(_, _, sender, lang) if mine(sender) then K.Spoke(lang) end end)

-- The home city's regard: after the game says it changed, outside a fight.
local repDirty = false
ns.On("UPDATE_FACTION", function() if U.Call(InCombatLockdown) then repDirty = true else K.Standing() end end)
ns.On("PLAYER_REGEN_ENABLED", function() if repDirty then repDirty = false; K.Standing() end end)

ns.Listen("LOGIN", function()
  if not store() then return end
  K.Languages()
  K.Standing()
  K.Tick()
  ns.Ticker(K.TICK, K.Tick)
end)

---------------------------------------------------------------------------
-- Writing it: small pieces Compose.lua puts in place. Only what the record backs.
---------------------------------------------------------------------------
local function seed(key) return (ns.char and ns.char.seedName or "") .. ":kin:" .. key end
local function pick(list, key, vars)
  local line = U.Pick(list, seed(key))
  if type(line) ~= "string" then return nil end
  return (line:gsub("{(%a+)}", function(k) if vars and vars[k] ~= nil then return vars[k] end end))
end
local function within(t, s) return type(t) == "number" and t > 0 and U.Now() - t <= s and U.Now() - t >= -60 end

-- "a day", "nine days", "three weeks", "over a month".
function K.Days(seconds)
  local d = math.max(1, math.floor(seconds / 86400 + 0.5))
  if d == 1 then return "a day" end
  if d >= 60 then return "over " .. U.Number(math.floor(d / 30)) .. " months" end
  if d >= 30 then return "over a month" end
  if d >= 14 then return U.Number(math.floor(d / 7)) .. " weeks" end
  return U.Number(d) .. " days"
end

-- Time played, said briefly: "under an hour", "31 hours", "6 days".
function K.Span(seconds)
  seconds = seconds or 0
  if seconds < 3600 then return "under an hour" end
  local h = math.floor(seconds / 3600 + 0.5)
  if h < 48 then return h .. " " .. U.Plural(h, "hour") end
  local d = math.floor(seconds / 86400 + 0.5)
  return d .. " days"
end

-- "the Ruins of Lordaeron", "the Hinterlands", "Moonglade".
local THE = { Ruins = true, Valley = true, Hall = true, Temple = true, Thandol = true }
function K.PlaceName(name)
  if type(name) ~= "string" then return name end
  if name:find("^The ") then return U.Mid(name) end
  local w = name:match("^(%a+)")
  if w and THE[w] then return "the " .. name end
  return name
end

local function tongue(r) local t = KW.TONGUE[r or ""]; return t, t and (KW.TONGUE_SAY[r] or t) end

-- Lately: { { t, prio, g = { TI, TX, IC } } }.
function K.Lately(c)
  local k = c and c.kin
  local out = {}
  if not k then return out end
  local v = k.visitLog[1]
  if v and k.home and within(v.t, 86400) and KW.HOMECOMING[k.race or ""] then
    local tx = pick(KW.HOMECOMING[k.race], "home:" .. v.t, { capital = k.home.capital, days = K.Days(v.away or 0) })
    out[#out + 1] = { t = v.t, prio = 1, g = { TI = "Home Again", IC = "INV_Misc_Rune_01", TX = U.Pron(tx) } }
  end
  for _, p in ipairs(k.places) do
    local def = KW.PLACE[p.mood or ""]
    if def and not p.before and within(p.t, 86400) then
      out[#out + 1] = { t = p.t, prio = 1, g = { TI = def.title, IC = def.icon, TX = U.Pron(pick(def.lines, "place:" .. p.name, { place = K.PlaceName(p.name) })) } }
      break
    end
  end
  local m = k.mattered[1]
  if m and within(m.t, 1800) then
    local pred = K.MatteredLine(m)
    if pred then out[#out + 1] = { t = m.t, prio = 2, g = { TI = m.name, IC = "Spell_Holy_SealOfMight", TX = U.Pron(U.Cap(pred) .. ", within the hour.") } } end
  end
  return out
end

-- A use that mattered, as a past-tense predicate.
function K.MatteredLine(m)
  local pool = KW.MATTERED[m.why or ""]
  if m.why == "low" then pool = pool and pool[m.name] end
  return pool and pick(pool, "matter:" .. tostring(m.t), nil) or nil
end

-- Marks: { { prio, title, text, icon } } for what a gift just used leaves on them.
function K.Marks(c)
  local k, world = c and c.kin, c and c.world or {}
  local out = {}
  if not k then return out end
  local names = world.auras and world.auras.names or {}
  for _, r in ipairs(k.racials) do
    local def = KW.MARK[r.name]
    if def and ((def.aura and names[r.name]) or within(r.t, def["for"] or 60)) then
      out[#out + 1] = { prio = 4.7, title = def.title, text = pick(def.lines, "mark:" .. r.name .. ":" .. r.t), icon = def.icon }
    end
  end
  return out
end

-- Personality: the bond to their people, and the gifts and old enemies, strongest first.
function K.Bearing(c, n)
  local k, world = c and c.kin, c and c.world or {}
  local out = {}
  if not k then return out end
  local cands = {}
  local function add(score, list, key, vars) local l = pick(list, key, vars); if l then cands[#cands + 1] = { score = score, key = key, text = l } end end
  local home = k.home
  if home then
    local vars = { capital = home.capital, home = home.say, faction = W.FactionName and W.FactionName(home.faction) or home.faction }
    local ran = U.Now() - (k.since or U.Now())
    if k.awayFor and k.awayFor >= 14 * 86400 and ran >= 14 * 86400 then
      vars.span = K.Days(k.awayFor)
      add(3, KW.BOND.away, "away", vars)
    elseif k.visits >= 3 then
      vars.times = U.Times(k.visits)
      add(2.4, KW.BOND.visits, "visits", vars)
    end
    if k.total >= 10 * 3600 then
      local share = k.atHome / k.total
      if share >= 0.6 then add(2.2, KW.BOND.home, "home", vars)
      elseif share <= 0.15 and k.total >= 20 * 3600 and not (k.awayFor and k.awayFor >= 14 * 86400) then add(2.1, KW.BOND.abroad, "abroad", vars) end
    end
    if k.rep and k.rep >= 7 then add(1.6, KW.BOND.trusted, "trusted", vars)
    elseif k.rep == 6 and k.total >= 10 * 3600 and k.atHome / k.total >= 0.4 then add(1.2, KW.BOND.liked, "liked", vars) end
  end
  local foe = k.foes[1]
  if foe and foe.n >= 25 then add(2.3, KW.BOND.foes, "foes:" .. foe.key, { foe = (foe.say:gsub("^of ", "")) }) end
  local top = k.racials[1]
  local habit = top and KW.HABIT[top.name]
  if habit and top.n >= 25 then
    add(2, (top.m >= 5 and habit.many) or habit.few or habit.many, "racial:" .. top.name, { times = U.Times(top.n) })
  end
  table.sort(cands, function(a, b) if a.score ~= b.score then return a.score > b.score end return a.key < b.key end)
  for i = 1, math.min(n or 2, #cands) do out[i] = cands[i].text end
  return out
end

-- Their people's own home lands: reaching them is no journey ("made the journey to Elwynn
-- Forest" for a human). History leaves them out; the glances still feel them.
local HOMELANDS = {
  Human = { ["Elwynn Forest"] = true, ["Northshire Abbey"] = true, ["Westfall"] = true },
  Dwarf = { ["Dun Morogh"] = true, ["Loch Modan"] = true }, Gnome = { ["Dun Morogh"] = true, ["Tinker Town"] = true },
  NightElf = { ["Teldrassil"] = true }, Orc = { ["Durotar"] = true }, Troll = { ["Durotar"] = true, ["Sen'jin Village"] = true },
  Tauren = { ["Mulgore"] = true, ["The Barrens"] = true }, Scourge = { ["Tirisfal Glades"] = true },
  Undead = { ["Tirisfal Glades"] = true },
}
local function journey(k, p) return not (HOMELANDS[k.race or ""] or {})[p.name] end

-- History news: { { t, rank, text, key } }, only what is recent (History checks again).
function K.Events(c)
  local k = c and c.kin
  local out = {}
  if not k then return out end
  local v = k.visitLog[1]
  if v and k.home then
    out[#out + 1] = { t = v.t, rank = 4, key = "kin:home",
      text = pick(KW.EV.homecoming, "evhome:" .. v.t, { capital = k.home.capital, days = K.Days(v.away or 0) }) }
  end
  local fresh = {}
  for _, p in ipairs(k.places) do
    if not p.before and U.Now() - p.t <= 21 * 86400 and #fresh < 2 and journey(k, p) then fresh[#fresh + 1] = p end
  end
  if #fresh > 0 then
    local names = {}
    for i, p in ipairs(fresh) do names[i] = K.PlaceName(p.name) end
    out[#out + 1] = { t = fresh[1].t, rank = 5, key = "kin:place", text = pick(KW.EV.place, "evplace:" .. fresh[1].name, { place = U.Join(names) }) }
  end
  local m = k.mattered[1]
  if m then
    local pred = K.MatteredLine(m)
    if pred then out[#out + 1] = { t = m.t, rank = 6, key = "kin:mattered", text = pred } end
  end
  return out
end

-- History's longer record: present-perfect predicates ("gone home to Ironforge four times").
function K.Older(c, told)
  local k = c and c.kin
  local out = {}
  if not k then return out end
  told = told or {}
  if k.home and k.visits >= 2 then
    out[#out + 1] = pick(KW.EV.visits, "oldvisits", { capital = k.home.capital, times = U.Times(k.visits) })
  end
  local places = {}
  for i = #k.places, 1, -1 do
    local p = k.places[i]
    if #places < 3 and journey(k, p) and not (told["kin:place"] and not p.before and U.Now() - p.t <= 21 * 86400) then places[#places + 1] = K.PlaceName(p.name) end
  end
  if #places >= 2 then out[#out + 1] = pick(KW.EV.places, "oldplaces", { list = U.Join(places) }) end
  local foe = k.foes[1]
  if foe and foe.n >= 20 then out[#out + 1] = pick(KW.EV.foes, "oldfoes", { n = U.Roughly(foe.n), foe = foe.say }) end
  return out
end

-- About: Physical, the voice: which tongue they speak aloud (nil until it means something).
function K.Voice(c)
  local k = c and c.kin
  if not k or k.spoken < 20 then return nil end
  local own, ownSay = tongue(k.race)
  local common = k.default
  if not own or not common or own == common or not k.known[own] then return nil end
  local share = (k.langs[own] or 0) / k.spoken
  local vars = { tongue = ownSay, common = common }
  if share >= 0.5 then return pick(KW.VOICE.mostly, "voice", vars) end
  if share >= 0.1 then return pick(KW.VOICE.some, "voice", vars) end
  if share == 0 and k.spoken >= 30 then return pick(KW.VOICE.never, "voice", vars) end
  return nil
end

-- About: Physical, how being here sits with one of their people (nil for most places).
function K.Here(c)
  local k, world = c and c.kin, c and c.world or {}
  local byRace = KW.HERE[(k and k.race) or world.race or ""]
  if not byRace or world.instance and world.instance ~= "none" and not byRace[world.zoneKey or ""] then return nil end
  local list = (world.subzone and byRace[world.subzone]) or (world.zoneKey and byRace[world.zoneKey])
  if not list and k and k.home and k.awayFor and k.awayFor >= 7 * 86400 and K.Kind(world.zoneKey, k.race) == "abroad" then
    list = byRace.abroad
  end
  return list and pick(list, "here:" .. tostring(world.zoneKey)) or nil
end

-- Statistics: { kinhome, racial, kinfoes } (absent when there's nothing yet).
local WHEN_SAY = { dot = "against poison or bleeding", mind = "against fear", root = "to slip a hold", low = "with the fight going badly",
  fight = "in the middle of a fight", mend = "to mend" }
function K.Stats(c)
  local k = c and c.kin
  local out = {}
  if not k then return out end
  if k.home and k.total >= 60 then out.kinhome = K.Span(k.atHome) .. " at home, " .. K.Span(k.abroad) .. " abroad" end
  local top = k.racials[1]
  if top then
    local def = KW.RACIALS[top.name]
    out.racial = top.name .. ", " .. (top.n == 1 and "once" or ((top.n >= 1000 and U.Number(top.n) or tostring(top.n)) .. " times"))
      .. ((top.m > 0 and def and WHEN_SAY[def.when]) and (", " .. (top.m < top.n and (top.m .. " of them ") or top.n > 1 and "every one " or "")
        .. WHEN_SAY[def.when]) or "")
  end
  local parts = {}
  for i = 1, math.min(3, #k.foes) do
    local f = k.foes[i]
    parts[i] = (f.n >= 100 and U.Number(f.n) or tostring(f.n)) .. " " .. f.say
  end
  if #parts > 0 then out.kinfoes = table.concat(parts, ", ") end
  return out
end
