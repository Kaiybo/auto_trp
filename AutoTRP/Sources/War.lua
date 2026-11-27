-- Auto TRP's record of the war between the factions: each battleground's flags, bases and
-- graveyards (only what the player did, matched against their own name), the time spent in
-- each, honour rank and honourable kills, and the war in the open world: time flagged, the
-- contested lands fought in, enemy players brought down and the ones who brought the
-- character down (by class and race, counted, never named), ganks suffered, towns defended.
-- Games fought and won per battleground are Life's (Sources/Life.lua); this adds the rest.
-- Kept per character in AutoTRPCharDB.war and read into ns.cache.war. Only game events and
-- game APIs: no other addon is needed.
--
-- Light by design: the combat log handler looks up its sub-event in a small table and bails
-- out on anything else; a kill is only queued in a fight (by GUID, in memory) and its class
-- and race are looked up once the fight is over; every list is capped.
local _, ns = ...

local U = ns.U
local War = {}
ns.Sources = ns.Sources or {}
ns.Sources.War = War

War.CAP_ZONES = 30   -- contested lands, towns defended
War.CAP_GROUNDS = 6  -- battlegrounds kept (three in the classic game, room for more)
War.GANK = 10        -- an attacker this many levels above (or a skull) makes it a gank

-- Battlegrounds by instance ID, so the game's language doesn't matter.
War.KIND_BY_ID = { [489] = "wsg", [529] = "ab", [30] = "av" }
War.KIND_BY_NAME = { ["Warsong Gulch"] = "wsg", ["Arathi Basin"] = "ab", ["Alterac Valley"] = "av" }

local function store()
  if not ns.char then return nil end
  local d = ns.char.war
  if type(d) ~= "table" then d = {}; ns.char.war = d end
  d.since = tonumber(d.since) or U.Now()
  for _, k in ipairs({ "grounds", "rank", "flag", "contested", "killed", "fell", "defended" }) do
    if type(d[k]) ~= "table" then d[k] = {} end
  end
  for _, k in ipairs({ "killed", "fell" }) do
    local t = d[k]
    if type(t.class) ~= "table" then t.class = {} end
    if type(t.race) ~= "table" then t.race = {} end
  end
  return d
end
War.Store = store

local function bump(t, key, n, cap)
  local L = ns.Sources.Life
  if L and L.Bump then return L.Bump(t, key, n, cap) end
  t[key] = (t[key] or 0) + (n or 1)
end
local function top(t)
  local best, bn
  for k, v in pairs(type(t) == "table" and t or {}) do
    if type(v) == "number" and (not bn or v > bn or (v == bn and tostring(k) < tostring(best))) then best, bn = k, v end
  end
  return best, bn or 0
end

local function myName()
  local n = U.Call(UnitName, "player")
  return type(n) == "string" and (n:match("^([^%-]+)") or n) or nil
end
local function faction() return U.Call(UnitFactionGroup, "player") end
local function enemyOf(f) return f == "Alliance" and "Horde" or f == "Horde" and "Alliance" or nil end

local function changed() if ns.Compose then ns.Compose.SourcesChanged() end end

---------------------------------------------------------------------------
-- Battlegrounds
---------------------------------------------------------------------------
local function groundOf(d, name, kind)
  name = U.Plain(name)
  if not name then return nil end
  local g = d.grounds[name]
  if type(g) ~= "table" then
    if U.Count(d.grounds) >= War.CAP_GROUNDS then return nil end
    g = {}
    d.grounds[name] = g
  end
  g.kind = g.kind or kind or War.KIND_BY_NAME[name]
  return g
end

-- What the game says this battleground is: its name and kind.
function War.Where()
  local name, _, _, _, _, _, _, id = U.Call(GetInstanceInfo)
  name = U.Plain(name) or U.Plain(U.Call(GetRealZoneText))
  return name, War.KIND_BY_ID[tonumber(id) or -1] or (name and War.KIND_BY_NAME[name])
end

-- Into a battleground: a game begins (one per entry; a reload inside carries on with it).
function War.Enter(name, kind)
  local d = store()
  name = U.Plain(name)
  if not d or not name then return end
  local gm = d.game
  if type(gm) == "table" and gm.name == name and U.Now() - (gm.seen or 0) < 600 then gm.seen = U.Now(); return gm end
  if type(gm) == "table" then War.Leave() end
  d.game = { name = name, kind = kind or War.KIND_BY_NAME[name], start = U.Now(), seen = U.Now(), held = {},
    flags = 0, returns = 0, assaults = 0, defends = 0, graves = 0 }
  return d.game
end

-- Out again: the time is added to the ground's, and the game is done with.
function War.Leave()
  local d = store()
  local gm = d and d.game
  if type(gm) ~= "table" then return end
  local g = groundOf(d, gm.name, gm.kind)
  if g then g.secs = (g.secs or 0) + math.min(3 * 3600, math.max(0, (gm.done or U.Now()) - (gm.start or U.Now()))) end
  d.game = nil
  changed()
end

-- Something the player did in the game: "flags", "returns", "assaults", "defends", "graves".
local MOOD = {
  flags = { "triumphant", 40, "carried the flag home" },
  returns = { "proud", 16, "brought {their} own flag back" },
  assaults = { "fierce", 14, "took a base from the enemy" },
  defends = { "proud", 14, "held a base against the enemy" },
  graves = { "fierce", 14, "took a graveyard from the enemy" },
}
function War.Deed(what)
  local d = store()
  local gm = d and d.game
  if type(gm) ~= "table" or not MOOD[what] then return false end
  gm[what] = (gm[what] or 0) + 1
  local g = groundOf(d, gm.name, gm.kind)
  if g then g[what] = (g[what] or 0) + 1 end
  local m = MOOD[what]
  if ns.Mood then ns.Mood.Push(m[1], m[2], m[3] .. " in " .. U.Mid(gm.name)) end
  changed()
  return true
end

-- Who holds a base or a graveyard: "Alliance", "Horde", or nil while it's contested.
function War.Held(place, side)
  local d = store()
  local gm = d and d.game
  if type(gm) ~= "table" or type(place) ~= "string" then return end
  if U.Count(gm.held) < 20 or gm.held[place] ~= nil then gm.held[place] = side or false end
end

-- The game is over (Life counted the result): what the player did in it, and how many
-- bases their side held at the end.
function War.Result(name, won)
  local d = store()
  if not d then return end
  name = U.Plain(name)
  local gm = type(d.game) == "table" and d.game.name == name and d.game or nil
  local mine = faction()
  local held = 0
  for _, side in pairs(gm and gm.held or {}) do if side == mine then held = held + 1 end end
  local last = { name = name, won = won and true or false, t = U.Now(), side = mine,
    kind = (gm and gm.kind) or War.KIND_BY_NAME[name or ""], held = held > 0 and held or nil }
  if gm then
    War.Scoreboard(gm)
    for _, k in ipairs({ "flags", "returns", "assaults", "defends", "graves" }) do
      if (gm[k] or 0) > 0 then last[k] = gm[k] end
    end
    gm.done = U.Now()
    last.secs = gm.done - (gm.start or gm.done)
  end
  groundOf(d, name, last.kind)
  d.last = last
  changed()
end

-- The scoreboard at the end: the player's own row (by their own name, nobody else's) can
-- say more than the chat did, for Alterac Valley's graveyards and towers above all.
local SCORE_COLUMNS = {
  wsg = { "flags", "returns" },
  ab = { "assaults", "defends" },
  av = { "graves", "defends", "assaults", "defends" },
}
function War.Scoreboard(gm)
  local cols = SCORE_COLUMNS[gm and gm.kind or ""]
  local me = myName()
  if not cols or not me then return end
  local n = tonumber((U.Call(_G.GetNumBattlefieldScores))) or 0
  for i = 1, math.min(n, 80) do
    local name = U.Call(_G.GetBattlefieldScore, i)
    if type(name) == "string" and (name:match("^([^%-]+)") or name) == me then
      local got = {}
      for k, what in ipairs(cols) do
        local v = tonumber((U.Call(_G.GetBattlefieldStatData, i, k)))
        if v then got[what] = (got[what] or 0) + v end
      end
      local d = store()
      local g = d and groundOf(d, gm.name, gm.kind)
      for what, v in pairs(got) do
        if v > (gm[what] or 0) then
          if g then g[what] = (g[what] or 0) + v - (gm[what] or 0) end
          gm[what] = v
        end
      end
      return
    end
  end
end

-- The battleground's own lines. Only a line that starts with the player's own name is the
-- player's doing; everyone else stays out of it.
local function esc(s) return (s:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")) end
function War.OnBGSystem(msg)
  msg = ns.World and ns.World.Safe(msg) or msg
  local d = store()
  if type(msg) ~= "string" or not d or type(d.game) ~= "table" then return end
  -- Bases changing hands: "The Alliance has taken the Stables!"
  local side, place = msg:match("^The (%a+) has taken the (.-)!")
  if side == "Alliance" or side == "Horde" then War.Held(place, side); return end
  local me = myName()
  if not me then return end
  local mine = "^" .. esc(me) .. " "
  if not msg:find(mine) then
    -- "The Horde flag was returned to its base by Aldric!"
    if msg:find("returned to its base by " .. esc(me) .. "!", 1) then War.Deed("returns") end
    -- Someone else's assault leaves the base contested.
    local other = msg:match("has assaulted the (.-)!") or msg:match("claims the (.-)!")
    if other then War.Held(other, nil) end
    return
  end
  local rest = msg:sub(#me + 2)
  if rest:find("^captured the") then War.Deed("flags"); return end
  local verb, what = rest:match("^(%a+ ?%a*) the (.-)!")
  if not verb then return end
  local grave = what:find("[Gg]raveyard") or what:find("Aid Station")
  if verb == "has assaulted" or verb == "claims" or verb == "has taken" then
    War.Held(what, nil)
    War.Deed(grave and "graves" or "assaults")
  elseif verb == "has defended" then
    War.Deed("defends")
  end
end
for _, e in ipairs({ "CHAT_MSG_BG_SYSTEM_ALLIANCE", "CHAT_MSG_BG_SYSTEM_HORDE", "CHAT_MSG_BG_SYSTEM_NEUTRAL" }) do
  ns.On(e, function(_, msg) War.OnBGSystem(msg) end)
end

-- Life counts the result once per battleground; the rest of it is told here.
do
  local L = ns.Sources.Life
  local battle = L and L.Battle
  if battle then
    L.Battle = function(name, won, ...)
      local a, b = battle(name, won, ...)
      War.Result(name, won)
      return a, b
    end
  end
end

---------------------------------------------------------------------------
-- Honour: rank and honourable kills, from the game itself
---------------------------------------------------------------------------
-- The rank now: { n = 1..14, name } or nil (no rank yet).
function War.RankNow()
  local idx = tonumber((U.Call(_G.UnitPVPRank, "player")))
  if not idx or idx < 5 then return nil end
  local name, num = U.Call(_G.GetPVPRankInfo, idx)
  name = U.Plain(name)
  if not name then return nil end
  return { n = tonumber(num) or (idx - 4), name = name }
end

-- A rank reached or lost, noted when it changes. The first look takes in what's there.
function War.CheckRank()
  local d = store()
  if not d then return end
  local r = War.RankNow()
  local rk = d.rank
  local n = r and r.n or 0
  if rk.n == nil then rk.n, rk.name, rk.best, rk.bestName = n, r and r.name, n, r and r.name; return end
  if n == rk.n then return end
  rk.log = type(rk.log) == "table" and rk.log or {}
  table.insert(rk.log, { from = rk.name, to = r and r.name, up = n > rk.n, t = U.Now() })
  while #rk.log > 10 do table.remove(rk.log, 1) end
  rk.n, rk.name = n, r and r.name
  if n > (rk.best or 0) then rk.best, rk.bestName = n, r.name end
  changed()
end
ns.On("PLAYER_PVP_RANK_CHANGED", War.CheckRank)

---------------------------------------------------------------------------
-- The open world
---------------------------------------------------------------------------
local inBG = false   -- the combat log asks this, not the game
local me             -- the player's GUID, read once
local function myGUID()
  if not me then me = U.Call(UnitGUID, "player") end
  return me
end
local function isPlayer(g) return type(g) == "string" and g:find("^Player%-") ~= nil end
local function hostile(flags) return type(flags) == "number" and math.floor(flags / 0x40) % 2 == 1 end

-- The town the player is in, if it's one of their own faction's: { name } or nil.
function War.OwnTown()
  local W = ns.Words
  local sub = U.Plain(U.Call(GetSubZoneText))
  local zone = U.Plain(U.Call(GetRealZoneText))
  local mine = faction()
  local towns = W.WAR and W.WAR.TOWNS or {}
  local town = sub and ((W.SELF_INN_TOWN or {})[sub] or sub)
  if town and towns[town] == mine then return town end
  if zone and towns[zone] == mine then return zone end
  return nil
end

-- An enemy player brought down in the open: by class and race, and where.
function War.Killed(class, race, zone, pvpType, town)
  local d = store()
  if not d then return end
  local k = d.killed
  k.n = (k.n or 0) + 1
  if class then bump(k.class, class, 1, 12) end
  if race then bump(k.race, race, 1, 12) end
  if zone and pvpType == "contested" then bump(d.contested, zone, 1, War.CAP_ZONES) end
  k.last = { t = U.Now(), zone = zone, class = class, race = race }
  if town then
    bump(d.defended, town, 1, War.CAP_ZONES)
    d.defendLast = { town = town, t = U.Now() }
    if ns.Mood then ns.Mood.Push("righteous", 22, "drove an enemy out of " .. town) end
  end
  changed()
end

-- Brought down by an enemy player in the open: by class and race; a gank if they stood ten
-- levels or more above.
function War.Fell(class, race, zone, pvpType, gank)
  local d = store()
  if not d then return end
  local f = d.fell
  f.n = (f.n or 0) + 1
  if class then bump(f.class, class, 1, 12) end
  if race then bump(f.race, race, 1, 12) end
  if zone and pvpType == "contested" then bump(d.contested, zone, 1, War.CAP_ZONES) end
  if gank then
    d.ganks = (tonumber(d.ganks) or 0) + 1
    d.gankLast = { t = U.Now(), zone = zone }
    if ns.Mood then ns.Mood.Push("humbled", 16, "set upon by someone far stronger") end
  end
  changed()
end

-- Time flagged for the war, out of time played, a tick at a time (gaps aren't counted).
function War.Tick(now)
  local d = store()
  if not d then return end
  now = now or U.Now()
  local fl = d.flag
  local dt = now - (fl.at or now)
  fl.at = now
  if inBG and type(d.game) == "table" then d.game.seen = now end
  if dt <= 0 or dt > 120 then return end
  fl.played = (fl.played or 0) + dt
  if not inBG and U.Call(UnitIsPVP, "player") then fl.secs = (fl.secs or 0) + dt end
end

-- Kills waiting on the end of the fight, and the last enemy player to hit the player.
local pending = {}
local attacker, attackerAt, attackerLevel
local function levelOf(guid)
  for _, u in ipairs({ "target", "mouseover" }) do
    if U.Call(UnitGUID, u) == guid then return tonumber((U.Call(UnitLevel, u))) end
  end
  return nil
end
local function whoIs(guid)
  local _, class, _, race = U.Call(_G.GetPlayerInfoByGUID, guid)
  return type(class) == "string" and class or nil, type(race) == "string" and race or nil
end
local function here()
  return U.Plain(U.Call(GetRealZoneText)), U.Call(GetZonePVPInfo)
end

function War.Resolve()
  if #pending == 0 then return end
  local list = pending
  pending = {}
  local zone, kind = here()
  local town = War.OwnTown()
  for _, guid in ipairs(list) do
    local class, race = whoIs(guid)
    War.Killed(class, race, zone, kind, town)
  end
end

local WATCH = { PARTY_KILL = 1, SWING_DAMAGE = 2, SPELL_DAMAGE = 2, RANGE_DAMAGE = 2, SPELL_PERIODIC_DAMAGE = 2 }
function War.OnCombatLog(_, sub, _, src, _, srcFlags, _, dst, _, dstFlags)
  local k = WATCH[sub]
  if not k or inBG then return end
  local guid = me or myGUID()
  if k == 1 then
    if src == guid and isPlayer(dst) and hostile(dstFlags) and #pending < 20 then pending[#pending + 1] = dst end
    return
  end
  if dst ~= guid or not isPlayer(src) or not hostile(srcFlags) then return end
  if src ~= attacker then attacker, attackerLevel = src, levelOf(src) end
  attackerAt = U.Now()
end
ns.On("COMBAT_LOG_EVENT_UNFILTERED", function()
  local fn = _G.CombatLogGetCurrentEventInfo
  if type(fn) == "function" then War.OnCombatLog(fn()) end
end)

ns.On("PLAYER_REGEN_ENABLED", War.Resolve)
ns.On("PLAYER_DEAD", function()
  War.Resolve()
  if not attacker or inBG or U.Now() - (attackerAt or 0) > 10 then return end
  local class, race = whoIs(attacker)
  local zone, kind = here()
  local mine = tonumber((U.Call(UnitLevel, "player"))) or 0
  local gank = attackerLevel ~= nil and (attackerLevel < 0 or attackerLevel - mine >= War.GANK)
  War.Fell(class, race, zone, kind, gank)
  attacker, attackerAt, attackerLevel = nil, nil, nil
end)

-- Where the player is: a battleground starts a game, leaving one ends it.
function War.CheckPlace()
  local inside, kind = U.Call(IsInInstance)
  local now = inside and kind == "pvp"
  if now then
    local name, bgKind = War.Where()
    War.Enter(name, bgKind)
  elseif inBG or (ns.char and type(ns.char.war) == "table" and ns.char.war.game) then
    War.Leave()
  end
  inBG = now and true or false
  me = nil
end
ns.On("PLAYER_ENTERING_WORLD", War.CheckPlace)
ns.On("ZONE_CHANGED_NEW_AREA", War.CheckPlace)

ns.Listen("LOGIN", function()
  if not store() then return end
  War.CheckPlace()
  War.CheckRank()
  War.Tick()
  ns.Ticker(30, War.Tick)
end)

---------------------------------------------------------------------------
-- Reading it back: a fresh table each time.
---------------------------------------------------------------------------
local KEYS = { "flags", "returns", "assaults", "defends", "graves" }
function War.Read()
  local d = store()
  if not d then return nil end
  local o = { since = d.since, side = faction() }
  o.enemy = enemyOf(o.side)
  -- Each battleground: Life's games and wins, and what was done there.
  local by = {}
  local lp = ns.char.life and ns.char.life.pvp or {}
  for name, n in pairs(type(lp.byName) == "table" and lp.byName or {}) do
    by[name] = { name = name, games = n, won = math.min(n, (lp.wonBy or {})[name] or 0) }
  end
  for name, g in pairs(d.grounds) do
    local e = by[name] or { name = name, games = 0, won = 0 }
    by[name] = e
    e.kind, e.secs = g.kind or War.KIND_BY_NAME[name], g.secs or 0
    for _, k in ipairs(KEYS) do e[k] = g[k] or 0 end
  end
  o.grounds = {}
  for _, e in pairs(by) do
    e.kind = e.kind or War.KIND_BY_NAME[e.name]
    for _, k in ipairs(KEYS) do e[k] = e[k] or 0 end
    e.secs = e.secs or 0
    e.lost = math.max(0, e.games - e.won)
    o.grounds[#o.grounds + 1] = e
  end
  table.sort(o.grounds, function(a, b) if a.games ~= b.games then return a.games > b.games end return a.name < b.name end)
  o.last = d.last
  local gm = d.game
  if type(gm) == "table" then
    o.game = { name = gm.name, kind = gm.kind, start = gm.start }
    for _, k in ipairs(KEYS) do o.game[k] = gm[k] or 0 end
  end
  -- Honour
  local r = War.RankNow()
  o.rank, o.rankN = r and r.name, r and r.n or 0
  o.best, o.bestN = d.rank.bestName, d.rank.best or 0
  local _, _, highest = U.Call(_G.GetPVPLifetimeStats)
  highest = tonumber(highest)
  if highest and highest >= 5 and highest - 4 > o.bestN then
    local name = U.Plain((U.Call(_G.GetPVPRankInfo, highest)))
    if name then o.best, o.bestN = name, highest - 4 end
  end
  o.rankLog = d.rank.log or {}
  o.hk = tonumber((U.Call(_G.GetPVPLifetimeStats))) or 0
  o.hkSession = tonumber((U.Call(_G.GetPVPSessionStats))) or 0
  -- The open world
  local fl = d.flag
  o.played, o.flagged = fl.played or 0, fl.secs or 0
  o.flagShare = o.played >= 36000 and o.flagged / o.played or nil   -- ten hours watched, at least
  o.kills, o.deaths, o.ganks = d.killed.n or 0, d.fell.n or 0, tonumber(d.ganks) or 0
  o.killClass, o.killClassN = top(d.killed.class)
  o.killRace, o.killRaceN = top(d.killed.race)
  o.fellClass, o.fellClassN = top(d.fell.class)
  o.fellRace, o.fellRaceN = top(d.fell.race)
  o.killLast, o.gankLast = d.killed.last, d.gankLast
  o.contested = U.Count(d.contested)
  o.contestedTop = top(d.contested)
  o.defends = 0
  for _, n in pairs(d.defended) do o.defends = o.defends + n end
  o.defendTop, o.defendTopN = top(d.defended)
  o.defendLast = d.defendLast
  return o
end
