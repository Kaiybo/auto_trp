-- Auto TRP's record of how the world's factions see the character, over time: every
-- faction's standing as the game last showed it, every gain and loss the game announced
-- (how much, on which day, and what caused it: a quest turned in, a creature killed), the
-- steps up and down between standings, the guards killed and killed by, and the war with the
-- other side (honourable kills and deaths to enemy players, by land, never by name).
-- Kept per character in AutoTRPCharDB.renown and read into ns.cache.renown. Game events
-- and game APIs only: Total RP 3 alone is enough.
--
-- From it come "What's said of them" (hearsay in History's people paragraph, each line built
-- from one stored record, never an invented deed), standing changes as History news, a few
-- Full title choices from real standing, the "Standing" statistic and a mood for falling out.
--
-- Light by design: a reputation line is one pattern match and a few table writes; the
-- faction list is only read out of combat, at most once every few seconds; every list is capped.
local _, ns = ...

local U = ns.U
local W = ns.Words
local R = {}
ns.Sources = ns.Sources or {}
ns.Sources.Renown = R

R.KEEP_FACTIONS, R.KEEP_CAUSES, R.KEEP_DAYS, R.KEEP_STEPS, R.KEEP_PLACES = 80, 6, 12, 16, 12
R.QUEST_WINDOW, R.KILL_WINDOW = 3, 2   -- seconds a turn-in or a kill stays the likely cause

-- Its statistic's switch, on by default (Core.lua fills defaults in on load).
if ns.DEFAULTS and ns.DEFAULTS.fields and ns.DEFAULTS.fields.stat_renown == nil then ns.DEFAULTS.fields.stat_renown = true end

local function store()
  if not ns.char then return nil end
  local r = ns.char.renown
  if type(r) ~= "table" then r = {}; ns.char.renown = r end
  r.since = tonumber(r.since) or U.Now()
  for _, k in ipairs({ "f", "steps", "guards", "honour" }) do
    if type(r[k]) ~= "table" then r[k] = {} end
  end
  return r
end
R.Store = store

-- Keeps a keyed table to `max` entries, forgetting the one score() rates lowest.
local function bound(t, max, score)
  local count, worst, wk = 0, nil, nil
  for k, v in pairs(t) do
    count = count + 1
    local s = score(v)
    if not worst or s < worst then worst, wk = s, k end
  end
  if count > max and wk then t[wk] = nil end
end
local function weight(f) return ((f.up or 0) + (f.down or 0)) * 1e10 + (f.last or 0) end

local function rec(r, name)
  local f = r.f[name]
  if not f then
    f = { up = 0, down = 0, n = 0, days = {}, why = {} }
    r.f[name] = f
    bound(r.f, R.KEEP_FACTIONS, weight)
    f = r.f[name] or f
  end
  f.up, f.down, f.n = tonumber(f.up) or 0, tonumber(f.down) or 0, tonumber(f.n) or 0
  if type(f.days) ~= "table" then f.days = {} end
  if type(f.why) ~= "table" then f.why = {} end
  return f
end

local function zone() return U.Plain(U.Call(GetRealZoneText)) end
-- The town within the land, when it is one (a camp or a stretch of shore reads as the land).
local function sub()
  local s = U.Plain(U.Call(GetSubZoneText))
  if s and W.SELF_TOWN_FACTION[s] then return s end
  return s and W.SELF_INN_TOWN[s] or nil
end

-- Guards, bruisers and the like: the people who keep a town's peace.
local function isGuard(name)
  if type(name) ~= "string" then return false end
  for _, pat in ipairs(W.RENOWN.GUARDS) do if name:find(pat) then return true end end
  return false
end
R.IsGuard = isGuard

---------------------------------------------------------------------------
-- Recording
---------------------------------------------------------------------------
local sessionLoss = {}   -- faction -> { n, told } this session, for the mood

-- A gain or loss of standing. amount: signed. cause: { kind = "quest", title } or
-- { kind = "kill", name }, with zone and sub; nil when nothing explains it.
function R.Change(faction, amount, cause)
  local r = store()
  faction = U.Plain(faction)
  amount = tonumber(amount)
  if not r or not faction or not amount or amount == 0 then return nil end
  local f = rec(r, faction)
  local now = U.Now()
  if amount > 0 then f.up = f.up + amount else f.down = f.down - amount end
  f.n, f.last = f.n + 1, now
  local day = math.floor(now / 86400)
  local d = f.days[#f.days]
  if not d or d.day ~= day then
    d = { day = day, up = 0, down = 0 }
    table.insert(f.days, d)
    while #f.days > R.KEEP_DAYS do table.remove(f.days, 1) end
  end
  d.t = now
  if amount > 0 then d.up = d.up + amount else d.down = d.down - amount end
  local key = "other"
  if cause and cause.kind == "quest" and cause.title then key = "q:" .. cause.title
  elseif cause and cause.kind == "kill" and cause.name then key = "k:" .. cause.name end
  local w = f.why[key]
  if not w then
    w = { kind = cause and cause.kind or "other", name = cause and (cause.title or cause.name) or nil, up = 0, down = 0, n = 0 }
    f.why[key] = w
    bound(f.why, R.KEEP_CAUSES, weight)
    w = f.why[key] or w
  end
  if amount > 0 then w.up = w.up + amount else w.down = w.down - amount end
  w.n, w.last = w.n + 1, now
  w.zone = (cause and cause.zone) or w.zone or zone()
  w.sub = (cause and cause.sub) or w.sub
  if amount < 0 then
    local s = sessionLoss[faction] or { n = 0, told = 0 }
    sessionLoss[faction] = s
    s.n = s.n + (-amount)
    if s.n >= 250 and now - s.told >= 3600 and ns.Mood then
      s.told, s.n = now, 0
      ns.Mood.Push("uneasy", 16, "has been losing standing with " .. W.FactionName(faction))
    end
  end
  return f, key
end

-- A step between standings, seen when the faction list is read.
local function step(r, faction, from, to)
  table.insert(r.steps, { t = U.Now(), faction = faction, from = from, to = to })
  while #r.steps > R.KEEP_STEPS do table.remove(r.steps, 1) end
  if to < from and ns.Mood then
    ns.Mood.Push("ashamed", 28, "fell out with " .. W.FactionName(faction))
    ns.Mood.Push("bitter", 10)
  end
end

-- Every faction the game lists, through either API. A faction seen before at another
-- standing has stepped up or down; one seen for the first time is only remembered.
function R.Scan()
  local r = store()
  if not r then return 0 end
  local n = 0
  local function seen(name, st, v)
    name = U.Plain(name)
    if not name or type(st) ~= "number" then return end
    n = n + 1
    local f = rec(r, name)
    local was = tonumber(f.st)
    if was and st ~= was then step(r, name, was, st) end
    f.st, f.v = st, tonumber(v) or f.v
  end
  local CR = _G.C_Reputation
  if CR and CR.GetNumFactions and CR.GetFactionDataByIndex then
    for i = 1, math.min(200, tonumber(U.Call(CR.GetNumFactions)) or 0) do
      local d = U.Call(CR.GetFactionDataByIndex, i)
      if type(d) == "table" and (not d.isHeader or d.isHeaderWithRep) then seen(d.name, tonumber(d.reaction), d.currentStanding) end
    end
  elseif _G.GetNumFactions and _G.GetFactionInfo then
    for i = 1, math.min(200, tonumber(U.Call(_G.GetNumFactions)) or 0) do
      local name, _, st, _, _, v, _, _, isHeader, _, hasRep = U.Call(_G.GetFactionInfo, i)
      if not isHeader or hasRep then seen(name, tonumber(st), v) end
    end
  end
  return n
end

-- A guard killed (by the character or their pet), or a guard that killed them.
function R.Guard(killed)
  local r = store()
  if not r then return end
  local place = sub() or zone()
  if not place then return end
  local g = r.guards[place]
  if not g then
    g = { k = 0, d = 0 }
    r.guards[place] = g
    bound(r.guards, R.KEEP_PLACES, function(v) return ((v.k or 0) + (v.d or 0)) * 1e10 + (v.t or 0) end)
    g = r.guards[place] or g
  end
  if killed then g.k = (g.k or 0) + 1 else g.d = (g.d or 0) + 1 end
  g.t, g.zone = U.Now(), zone()
end

-- The war: an honourable kill, or a death to an enemy player (never named), by land.
function R.Honour(won)
  local r = store()
  local z = zone()
  if not r or not z then return end
  local h = r.honour[z]
  if not h then
    h = { k = 0, d = 0 }
    r.honour[z] = h
    bound(r.honour, R.KEEP_PLACES, function(v) return ((v.k or 0) + (v.d or 0)) * 1e10 + (v.t or 0) end)
    h = r.honour[z] or h
  end
  if won then h.k = (h.k or 0) + 1 else h.d = (h.d or 0) + 1 end
  h.t = U.Now()
end

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------
-- "Reputation with %s increased by %d." as a pattern, from the game's own string.
local function pattern(global, fallback)
  local fmt = type(_G[global]) == "string" and _G[global] or fallback
  local p = fmt:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
  p = p:gsub("%%%%s", "(.-)"):gsub("%%%%d", "(%%d+)")
  return "^" .. p
end
local P_UP = pattern("FACTION_STANDING_INCREASED", "Reputation with %s increased by %d.")
local P_DOWN = pattern("FACTION_STANDING_DECREASED", "Reputation with %s decreased by %d.")

-- What most likely caused a change: the quest just turned in, else the creature just killed.
local lastQuest, lastKill, questTitle
local recent = {}   -- changes of the last few seconds with no cause yet: a turn-in may follow
local function causeNow()
  local now = U.Now()
  if lastQuest and now - lastQuest.t <= R.QUEST_WINDOW then return lastQuest end
  if lastKill and now - lastKill.t <= R.KILL_WINDOW then return lastKill end
  return nil
end

function R.Message(msg)
  if type(msg) ~= "string" then return false end
  local faction, n = msg:match(P_UP)
  local sign = 1
  if not faction then faction, n = msg:match(P_DOWN); sign = -1 end
  n = tonumber(n)
  if not faction or not n then return false end
  local cause = causeNow()
  local f, key = R.Change(faction, sign * n, cause)
  if f and key == "other" then
    table.insert(recent, { faction = U.Plain(faction), amount = sign * n, t = U.Now() })
    while #recent > 8 do table.remove(recent, 1) end
  end
  if ns.Compose then ns.Compose.SourcesChanged() end
  return true
end
ns.On("CHAT_MSG_COMBAT_FACTION_CHANGE", function(_, msg) R.Message(ns.World.Safe(msg)) end)

-- A change the game announced just before the turn-in belongs to it.
local function claim(cause)
  local r = store()
  if not r then return end
  local now = U.Now()
  for i = #recent, 1, -1 do
    local e = recent[i]
    if now - e.t <= R.QUEST_WINDOW then
      local f = r.f[e.faction]
      local o = f and f.why.other
      if o then
        local a = math.abs(e.amount)
        if e.amount > 0 then o.up = math.max(0, o.up - a); f.up = f.up - a else o.down = math.max(0, o.down - a); f.down = f.down - a end
        o.n = math.max(0, (o.n or 1) - 1)
        if o.n == 0 then f.why.other = nil end
        f.n = f.n - 1
        local d = f.days[#f.days]
        if d then if e.amount > 0 then d.up = d.up - a else d.down = d.down - a end end
        R.Change(e.faction, e.amount, cause)
      end
    end
    table.remove(recent, i)
  end
end

function R.QuestTurnedIn(title)
  title = U.Plain(title)
  if not title then return end
  lastQuest = { kind = "quest", title = title, t = U.Now(), zone = zone(), sub = sub() }
  claim(lastQuest)
end
ns.On("QUEST_COMPLETE", function() questTitle = U.Plain(U.Call(GetTitleText)) end)
ns.On("QUEST_TURNED_IN", function(_, questID)
  local QL = _G.C_QuestLog
  local title = QL and QL.GetTitleForQuestID and questID and U.Plain(U.Call(QL.GetTitleForQuestID, questID)) or nil
  R.QuestTurnedIn(title or questTitle)
  questTitle = nil
end)

-- Kills come through Sources/Deeds.lua's one combat-log test (no second listener here).
function R.Killed(name)
  name = U.Plain(name)
  if not name then return end
  lastKill = { kind = "kill", name = name, t = U.Now(), zone = zone(), sub = sub() }
  if isGuard(name) then R.Guard(true) end
end
local D = ns.Sources.Deeds
if D and type(D.Kill) == "function" then
  local kill = D.Kill
  D.Kill = function(name, ...)
    local ok, err = pcall(R.Killed, name)
    if not ok then ns.Error("Renown.Killed", err) end
    return kill(name, ...)
  end
end

-- A death: to a guard, or to an enemy player (only counted, never named).
function R.Died()
  local byPlayer, foe = false, nil
  if U.Call(UnitExists, "target") and U.Call(UnitCanAttack, "player", "target") then
    if U.Call(UnitIsPlayer, "target") then byPlayer = true elseif not U.PlayerOwned("target") then foe = U.Plain(U.Call(UnitName, "target")) end
  else
    local f = ns.char and ns.char.lastFight
    if f and U.Now() - (f.t or 0) < 20 and type(f.foe) == "table" then
      if f.foe.player then byPlayer = true else foe = f.foe.name end
    end
  end
  if byPlayer then R.Honour(false) elseif isGuard(foe) then R.Guard(false) end
end
ns.On("PLAYER_DEAD", function() R.Died() end)
ns.On("CHAT_MSG_COMBAT_HONOR_GAIN", function() R.Honour(true) end)

-- The faction list: read a few seconds after it changes, and never in a fight.
local scheduled, dirty = false, false
local function inFight() return U.Call(InCombatLockdown) or U.Call(UnitAffectingCombat, "player") end
local function scanSoon()
  if scheduled then return end
  scheduled = true
  ns.After(5, function()
    scheduled = false
    if inFight() then dirty = true return end
    dirty = false
    R.Scan()
  end)
end
ns.On("UPDATE_FACTION", scanSoon)
ns.On("PLAYER_REGEN_ENABLED", function() if dirty then scanSoon() end end)
ns.Listen("LOGIN", function() store(); ns.After(15, scanSoon) end)

---------------------------------------------------------------------------
-- Reading it
---------------------------------------------------------------------------
-- { factions = { { name, st, up, down, last, days, why }, most moved first }, steps,
--   guards, honour, since }. A fresh table each time.
function R.Read()
  local r = store()
  if not r then return nil end
  local out = { factions = {}, byName = {}, steps = r.steps, guards = r.guards, honour = r.honour, since = r.since }
  for name, f in pairs(r.f) do
    local e = { name = name, st = tonumber(f.st), up = f.up or 0, down = f.down or 0, last = f.last or 0, days = f.days or {}, why = f.why or {} }
    out.factions[#out.factions + 1] = e
    out.byName[name] = e
  end
  table.sort(out.factions, function(a, b)
    local x, y = a.up + a.down, b.up + b.down
    if x ~= y then return x > y end
    return a.name < b.name
  end)
  return out
end

-- How much was gained and lost with a faction since `since`.
function R.Since(e, since)
  local up, down, last = 0, 0, 0
  for _, d in ipairs(e.days or {}) do
    if (d.t or 0) >= since then up, down, last = up + (d.up or 0), down + (d.down or 0), math.max(last, d.t or 0) end
  end
  return up, down, last
end

-- The biggest cause of gains (dir "up") or losses ("down") that names a deed, or nil.
function R.TopCause(e, dir)
  local best
  for key, w in pairs(e.why or {}) do
    if key ~= "other" and w.name and (w[dir] or 0) > 0 and (not best or w[dir] > best[dir] or (w[dir] == best[dir] and key < best.key)) then
      best = { key = key, kind = w.kind, name = w.name, up = w.up or 0, down = w.down or 0, n = w.n or 0, zone = w.zone, sub = w.sub, last = w.last }
    end
  end
  return best
end

local function seed(key) return (ns.char and ns.char.seedName or "") .. ":renown:" .. key end
local function fill(line, vars)
  return (line:gsub("{(%a+)}", function(k) if vars[k] ~= nil then return vars[k] end end))
end
local function pick(list, key, vars) return fill(U.Pick(list, seed(key)), vars) end
local function people(name) return W.RENOWN.PEOPLE[name] or W.FactionName(name) end
local function quote(t)
  local C = ns.Compose
  return C and C.Colour and C.Colour("\"" .. t .. "\"", "f2e8d0") or ("\"" .. t .. "\"")
end
local function plural(name) return ns.Compose and ns.Compose.Plural and ns.Compose.Plural(name) or name end
local function where(c) return U.Mid(c.sub or c.zone or "") end

-- Why a faction thinks as it does, from its biggest cause: a quest, or a creature killed.
local function why(c, good, key)
  local Wn = W.RENOWN
  local vars = { quest = c.kind == "quest" and quote(c.name) or nil, foes = c.kind == "kill" and plural(c.name) or nil,
    where = (c.sub or c.zone) and where(c) or nil, times = U.Times(c.n) }
  if c.kind == "quest" then
    return pick(good and (c.n >= 2 and Wn.GOOD_QUESTS or Wn.GOOD_QUEST) or Wn.WHY_QUEST, key, vars)
  end
  if not vars.where then return nil end
  return pick(good and Wn.GOOD_KILL or Wn.WHY_KILL, key, vars)
end

-- The story told of a town: the chain or trouble of its land the character saw most of.
local function townStory(t, finished)
  local best, bn = nil, 0
  for _, st in ipairs(W.SELF_STORIES or {}) do
    if st.zone == t.zone then
      local done = 0
      for _, q in ipairs(st.quests or {}) do if finished[q] then done = done + 1 end end
      for _, q in ipairs(st.ends or {}) do if finished[q] then done = done + 2 end end
      if done > bn or (done == bn and best and st.id < best.id) then best, bn = st, done end
    end
  end
  if bn >= 2 then return best end
  return nil
end

-- What's said of them: at most k pieces of hearsay (3 by default), each from one stored
-- record. Each: { text, kind, from = the record it came from }.
function R.Rumours(c, k)
  c = c or ns.cache or {}
  k = k or 3
  local rn = c.renown or R.Read()
  if not rn then return {} end
  local Wn = W.RENOWN
  local world = c.world or {}
  local now = U.Now()
  local found = {}
  local used = {}
  local function add(score, kind, text, from)
    if text then found[#found + 1] = { score = score, kind = kind, text = text, from = from } end
  end

  -- A town where they've done many jobs: the regulars, and the story of the land.
  local towns = ns.char and ns.char.self and type(ns.char.self.towns) == "table" and ns.char.self.towns or {}
  local best
  for name, t in pairs(towns) do
    if (t.quests or 0) >= 4 and t.zone and (not best or t.quests > best.t.quests or (t.quests == best.t.quests and name < best.name)) then
      best = { name = name, t = t }
    end
  end
  if best then
    local finished = ns.Compose and ns.Compose.Finished(c) or {}
    local st = townStory(best.t, finished)
    local vars = { town = best.name, n = U.Number(best.t.quests) }
    if st then
      vars.story = st.title
      add(4.5, "town", pick(Wn.TOWN_STORY, "town:" .. best.name, vars), { kind = "town", town = best.name, story = st.id, quests = best.t.quests })
    else
      add(4, "town", pick(Wn.TOWN_JOBS, "town:" .. best.name, vars), { kind = "town", town = best.name, quests = best.t.quests })
    end
  end

  -- Factions fallen out with, warmed to, and cooling lately.
  for _, e in ipairs(rn.factions) do
    local vars = { people = people(e.name) }
    if e.down >= 100 and (e.down > e.up or (e.st and e.st <= 4)) then
      local cs = R.TopCause(e, "down")
      local w = cs and why(cs, false, "why:" .. e.name)
      if w then
        vars.why = w
        add(5 + math.min(1, e.down / 3000), "fallout", pick(Wn.FALLOUT, "fallout:" .. e.name, vars),
          { kind = "faction", faction = e.name, cause = cs.key, down = cs.down })
      end
    end
    if e.up >= 300 and e.up > 2 * e.down and (not e.st or e.st >= 5) then
      local cs = R.TopCause(e, "up")
      local w = cs and cs.up >= 100 and why(cs, true, "good:" .. e.name)
      if w then
        vars.why = w
        add(3 + math.min(1, e.up / 6000), "good", pick(Wn.GOOD, "good:" .. e.name, vars),
          { kind = "faction", faction = e.name, cause = cs.key, up = cs.up })
      end
    end
    local up, down, last = R.Since(e, now - 14 * 86400)
    if down >= 50 and down > up then
      add(2 + math.min(1, down / 1000), "cooling", pick(Wn.COOLING, "cooling:" .. e.name, vars),
        { kind = "faction", faction = e.name, down = down, t = last })
    end
  end

  -- Guards: the ones killed, else the ones who killed them.
  local gk, gd
  for place, g in pairs(rn.guards or {}) do
    if (g.k or 0) > 0 and (not gk or g.k > gk.g.k or (g.k == gk.g.k and place < gk.place)) then gk = { place = place, g = g } end
    if (g.d or 0) > 0 and (not gd or g.d > gd.g.d or (g.d == gd.g.d and place < gd.place)) then gd = { place = place, g = g } end
  end
  if gk then
    add(4 + math.min(1, gk.g.k / 10), "guards", pick(Wn.GUARDS_KILLED, "guards:" .. gk.place, { place = U.Mid(gk.place), n = U.Number(gk.g.k) }),
      { kind = "guards", place = gk.place, killed = gk.g.k })
  elseif gd then
    add(3, "guards", pick(Wn.GUARDS_WON, "guards:" .. gd.place, { place = U.Mid(gd.place), times = U.Times(gd.g.d) }),
      { kind = "guards", place = gd.place, killedBy = gd.g.d })
  end

  -- The war: the land where they've taken most from the other side (or lost most to it).
  local enemy = world.faction == "Horde" and "Alliance" or world.faction == "Alliance" and "Horde" or nil
  if enemy then
    local hk, hd
    for z, h in pairs(rn.honour or {}) do
      if (h.k or 0) >= 3 and (not hk or h.k > hk.h.k or (h.k == hk.h.k and z < hk.zone)) then hk = { zone = z, h = h } end
      if (h.d or 0) >= 3 and (not hd or h.d > hd.h.d or (h.d == hd.h.d and z < hd.zone)) then hd = { zone = z, h = h } end
    end
    if hk then
      add(3 + math.min(1, hk.h.k / 100), "honour", pick(Wn.HONOUR, "honour:" .. hk.zone, { enemy = enemy, zone = U.Mid(hk.zone), n = U.Number(hk.h.k) }),
        { kind = "honour", zone = hk.zone, kills = hk.h.k })
    elseif hd then
      add(2.5, "honour", pick(Wn.HONOUR_LOST, "honour:" .. hd.zone, { enemy = enemy, zone = U.Mid(hd.zone), times = U.Times(hd.h.d) }),
        { kind = "honour", zone = hd.zone, deaths = hd.h.d })
    end
  end

  -- The strongest first; one of each kind, and a faction told once.
  table.sort(found, function(a, b) if a.score ~= b.score then return a.score > b.score end return a.text < b.text end)
  local out, kinds = {}, {}
  for _, f in ipairs(found) do
    local fac = f.from.faction
    if #out < k and not kinds[f.kind] and not (fac and used[fac]) then
      out[#out + 1] = f
      kinds[f.kind] = true
      if fac then used[fac] = true end
    end
  end
  return out
end

-- Standing changes, as History news: { t, text, key }. A step down, else a run of losses;
-- a great deal of work done for a faction that no new standing has told of yet.
function R.News(c, recentSeconds)
  c = c or ns.cache or {}
  local rn = c.renown or R.Read()
  if not rn then return {} end
  local Wn = W.RENOWN
  local now = U.Now()
  local since = now - (recentSeconds or 21 * 86400)
  local out, told = {}, {}
  for k = #rn.steps, 1, -1 do
    local s = rn.steps[k]
    if (s.t or 0) >= since and s.to < s.from and not told[s.faction] then
      told[s.faction] = true
      local vars = { faction = W.FactionName(s.faction), word = (Wn.STANDING[s.to] or ""):lower() }
      out[#out + 1] = { t = s.t, rank = 3, key = "renown:" .. s.faction, text = pick(s.to <= 4 and Wn.EV_FELL or Wn.EV_SLIP, "ev:" .. s.faction, vars) }
    end
  end
  local honoured = {}
  for _, h in ipairs(ns.char and ns.char.honours or {}) do if (h.t or 0) >= since then honoured[h.faction] = true end end
  for _, e in ipairs(rn.factions) do
    if not told[e.name] then
      local up, down, last = R.Since(e, since)
      local vars = { faction = W.FactionName(e.name) }
      if down >= 250 and down > up then
        told[e.name] = true
        out[#out + 1] = { t = last, key = "renown:" .. e.name, text = pick(Wn.EV_LOST, "ev:" .. e.name, vars) }
      elseif up >= 1500 and down * 4 < up and not honoured[e.name] then
        told[e.name] = true
        out[#out + 1] = { t = last, key = "renown:" .. e.name, text = pick(Wn.EV_WORK, "ev:" .. e.name, vars) }
      end
    end
  end
  table.sort(out, function(a, b) if a.t ~= b.t then return a.t > b.t end return a.key < b.key end)
  while #out > 2 do table.remove(out) end
  return out
end

-- A Full title from real standing: Revered or Exalted with a faction, modestly put.
function R.Title(world)
  local top = world and world.factions and world.factions[1]
  if not top or (top.standing or 0) < 7 then return nil end
  local list = W.RENOWN.TITLE[top.standing >= 8 and "Exalted" or "Revered"]
  return fill(U.Pick(list, seed("title:" .. top.name)), { faction = W.FactionName(top.name) })
end

-- The "Standing" statistic: "Exalted with 1, Revered with 3, Honored with 2", and how many
-- they've fallen out of favour with (only those Auto TRP saw them lose standing with).
function R.Stat(world, rn)
  local count = {}
  for _, f in ipairs(world and world.factions or {}) do
    if f.word then count[f.word] = (count[f.word] or 0) + 1 end
  end
  local parts = {}
  -- One faction honoured or better is what Best standing already says, so then the friendly
  -- ones join in ("Honored with 1 faction, Friendly with 3").
  local high = (count.Exalted or 0) + (count.Revered or 0) + (count.Honored or 0)
  local words = { "Exalted", "Revered", "Honored" }
  if high <= 1 then
    for _, e in ipairs(rn and rn.factions or {}) do
      if e.st == 5 then count.Friendly = (count.Friendly or 0) + 1 end
    end
    words[#words + 1] = "Friendly"
  end
  for _, w in ipairs(words) do
    -- "Revered with 2 factions, Honored with 3": the noun once, on the first.
    if count[w] then parts[#parts + 1] = w .. " with " .. count[w] .. (#parts == 0 and (" " .. U.Plural(count[w], "faction")) or "") end
  end
  local cold = 0
  for _, e in ipairs(rn and rn.factions or {}) do
    if e.st and e.st <= 3 and e.down > 0 then cold = cold + 1 end
  end
  if cold > 0 then parts[#parts + 1] = (#parts > 0 and ("out of favour with " .. cold) or ("Out of favour with " .. cold .. " " .. U.Plural(cold, "faction"))) end
  if #parts == 0 then return nil end
  return table.concat(parts, ", ")
end
