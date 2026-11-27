-- Auto TRP's own record of what the character has seen through: every quest turned in (by
-- title, with where and when) and every dungeon or raid master brought down (ENCOUNTER_END).
-- Earned names come from it as well as from Chronicle, so they work without Chronicle and
-- nothing is missed while it's switched off. Kept per character in AutoTRPCharDB.deeds.
local _, ns = ...

local U = ns.U
local D = {}
ns.Sources = ns.Sources or {}
ns.Sources.Deeds = D

D.KEEP_QUESTS = 1500   -- the oldest are forgotten past this (a full career is well under it)

local function store()
  if not ns.char then return nil end
  local d = ns.char.deeds
  if type(d) ~= "table" then d = {}; ns.char.deeds = d end
  if type(d.quests) ~= "table" then d.quests = {} end
  if type(d.bosses) ~= "table" then d.bosses = {} end
  d.n = tonumber(d.n) or 0
  if type(d.deaths) ~= "table" then d.deaths = {} end
  if type(d.instances) ~= "table" then d.instances = {} end
  if type(d.kills) ~= "table" then d.kills = { total = 0, byName = {} } end
  d.flights = tonumber(d.flights) or 0
  d.since = tonumber(d.since) or U.Now()
  return d
end

local function zone() return U.Plain(U.Call(GetRealZoneText)) end

-- A quest turned in. title: as the game shows it. Only the first time counts.
function D.Quest(title, questID, where, t)
  local d = store()
  title = U.Plain(title)
  if not d or not title then return false end
  if d.quests[title] then return false end
  d.n = d.n + 1
  d.quests[title] = { t = t or U.Now(), zone = where or zone(), id = tonumber(questID), n = d.n }
  -- Forget the oldest when there are too many, but never one that earns a name: losing it
  -- would quietly take the name away.
  local count = 0
  for _ in pairs(d.quests) do count = count + 1 end
  if count > D.KEEP_QUESTS then
    local oldest, on
    for k, q in pairs(d.quests) do
      if not D.EarnsName(k) and (not on or (q.n or 0) < on) then oldest, on = k, q.n or 0 end
    end
    if oldest then d.quests[oldest] = nil end
  end
  if ns.Compose then ns.Compose.SourcesChanged() end
  return true
end

-- Whether finishing this quest earns a name (a chain's last step, or a bounty).
function D.EarnsName(title)
  local W = ns.Words
  return (W and W.EARNED_QUEST[title] or (ns.Compose and ns.Compose.BountyTarget(title))) and true or false
end

-- A master brought down. Each is kept once, with the first time and how many times.
function D.Boss(name, where, t)
  local d = store()
  name = U.Plain(name)
  if not d or not name then return false end
  local b = d.bosses[name]
  if b then
    b.kills = (b.kills or 1) + 1; b.last = t or U.Now()
    if ns.Compose then ns.Compose.SourcesChanged() end   -- a fresh victory for Lately
    return false
  end
  d.bosses[name] = { t = t or U.Now(), last = t or U.Now(), where = where, kills = 1 }
  if ns.Compose then ns.Compose.SourcesChanged() end
  return true
end

-- A death: when, where, and who did it if a fight was on (the last foe fought).
-- named: a boss, rare or elite, told by name; anything else is "a Defias Pillager".
function D.Death(killer, named)
  local d = store()
  if not d then return end
  d.deathCount = (tonumber(d.deathCount) or 0) + 1
  killer = U.Plain(killer)
  table.insert(d.deaths, { t = U.Now(), zone = zone(), killer = killer, common = (killer and not named) or nil })
  while #d.deaths > 20 do table.remove(d.deaths, 2) end   -- the first is kept, for "the first to"
  if ns.Compose then ns.Compose.SourcesChanged() end
end

-- A dungeon, raid or battleground entered for the first time (the latest time is kept too).
function D.Instance(name, kind)
  local d = store()
  name = U.Plain(name)
  if not d or not name then return end
  local i = d.instances[name]
  if i then i.last = U.Now(); i.visits = (i.visits or 1) + 1; return end
  d.instances[name] = { t = U.Now(), last = U.Now(), kind = kind, visits = 1 }
  if ns.Compose then ns.Compose.SourcesChanged() end
end

-- A creature the character (or their pet) killed, by name.
function D.Kill(name)
  local d = store()
  name = U.Plain(name)
  if not d or not name then return end
  d.kills.total = (d.kills.total or 0) + 1
  if not d.kills.byName[name] then d.kills.names = (d.kills.names or 0) + 1 end
  d.kills.byName[name] = (d.kills.byName[name] or 0) + 1
  local Be = ns.Sources.Bestiary   -- what it was (its kind, how strong), if they sized it up
  if Be then Be.Kill(name) end
end

-- Kills by name are kept for the 300 most killed; the rest are let go, out of combat, once
-- the list passes 400 names (the total stays exact).
D.KEEP_KILL_NAMES = 300
function D.TrimKills()
  local d = store()
  if not d or (d.kills.names or 0) <= D.KEEP_KILL_NAMES + 100 then return end
  local list = {}
  for n, k in pairs(d.kills.byName) do list[#list + 1] = { n = n, k = k } end
  table.sort(list, function(a, b) return a.k > b.k end)
  local keep = {}
  for i = 1, math.min(D.KEEP_KILL_NAMES, #list) do keep[list[i].n] = list[i].k end
  d.kills.byName = keep
  d.kills.names = math.min(D.KEEP_KILL_NAMES, #list)
end
ns.On("PLAYER_REGEN_ENABLED", function() D.TrimKills() end)

function D.Flight()
  local d = store()
  if d then d.flights = d.flights + 1 end
end

-- { finished = { [title] = { t, zone } }, bosses = { { name, first, t (the latest), where }, latest first },
--   lastQuest = { title, t, zone } (the latest seen turned in, not one taken in by the backfill) }
-- A fresh table each time, so what's built from it notices a change.
function D.Read()
  local d = store()
  if not d then return nil end
  local out = { finished = {}, bosses = {} }
  for title, q in pairs(d.quests) do
    out.finished[title] = { t = q.t or 0, zone = q.zone }
    if not q.before and (q.t or 0) > 1 and (not out.lastQuest or q.t > out.lastQuest.t) then
      out.lastQuest = { title = title, t = q.t, zone = q.zone }
    end
  end
  for name, b in pairs(d.bosses) do out.bosses[#out.bosses + 1] = { name = name, first = b.t or 0, t = b.last or b.t or 0, where = b.where } end
  table.sort(out.bosses, function(a, b) return a.t > b.t end)
  out.deathCount = tonumber(d.deathCount) or 0
  out.deaths = d.deaths
  out.instances = {}
  for name, i in pairs(d.instances) do
    out.instances[#out.instances + 1] = { name = name, t = i.t or 0, last = i.last or i.t or 0, kind = i.kind, visits = i.visits or 1 }
  end
  table.sort(out.instances, function(a, b) return a.t > b.t end)
  out.dungeons = 0
  for _, i in ipairs(out.instances) do if i.kind == "party" or i.kind == "raid" then out.dungeons = out.dungeons + 1 end end
  out.kills, out.killsByName = d.kills.total or 0, d.kills.byName
  out.flights = d.flights
  -- Lands, in the order first reached, from the mood model's record of arrivals. Dungeons,
  -- raids and battlegrounds entered are counted on their own, not as lands.
  out.zones = {}
  local inside = {}
  for name in pairs(d.instances) do inside[name] = true end
  local seen = ns.char and type(ns.char.seen) == "table" and type(ns.char.seen.zones) == "table" and ns.char.seen.zones or {}
  for name, t in pairs(seen) do
    if type(name) == "string" and tonumber(t) and not inside[name] then out.zones[#out.zones + 1] = { name = name, t = tonumber(t) } end
  end
  table.sort(out.zones, function(a, b) return a.t < b.t end)
  out.since = math.min(d.since, out.zones[1] and out.zones[1].t or math.huge)
  -- The game's own lifetime counts, where it keeps them.
  local hk = U.Call(_G.GetPVPLifetimeStats)
  out.honorKills = tonumber(hk) or 0
  return out
end

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------
-- The quest window's title is read when it opens to be turned in, since the game may have
-- forgotten the quest by the time QUEST_TURNED_IN arrives.
local pending
ns.On("QUEST_COMPLETE", function()
  pending = { title = U.Plain(U.Call(GetTitleText)), id = U.Call(GetQuestID) }
end)
ns.On("QUEST_TURNED_IN", function(_, questID)
  local title
  local QL = _G.C_QuestLog
  if QL and QL.GetTitleForQuestID and questID then title = U.Plain(U.Call(QL.GetTitleForQuestID, questID)) end
  if not title and pending and (not pending.id or not questID or pending.id == questID) then title = pending.title end
  pending = nil
  if title then D.Quest(title, questID) end
end)
ns.On("ENCOUNTER_END", function(_, _, name, _, _, success)
  if success ~= 1 or type(name) ~= "string" then return end
  local instance = U.Call(GetInstanceInfo)
  D.Boss(name, U.Plain(instance))
end)

ns.On("PLAYER_DEAD", function()
  -- The last foe fought (Mood.lua keeps it as { name, named }); another player is never
  -- named, since this reaches the Deaths statistic and the Lately glance.
  local f = ns.char and ns.char.lastFight
  local foe, named
  if f and U.Now() - (f.t or 0) < 20 then
    if type(f.foe) == "table" then foe, named = not f.foe.player and f.foe.name or nil, f.foe.named
    elseif type(f.foe) == "string" then foe, named = f.foe, true end
  end
  -- Still in the fight when it ended: the target is the likelier killer.
  if U.Call(UnitExists, "target") and U.Call(UnitCanAttack, "player", "target") then
    if U.PlayerOwned("target") then foe = nil
    else
      local name = U.Call(UnitName, "target")
      if name then
        local kind = U.Call(UnitClassification, "target")
        foe, named = name, kind and kind ~= "normal" and kind ~= "minus" and kind ~= "trivial"
      end
    end
  end
  D.Death(foe, named)
end)
local function checkInstance()
  local inside, kind = U.Call(IsInInstance)
  if inside and kind and kind ~= "none" then
    local name = U.Call(GetInstanceInfo)
    D.Instance(name or U.Call(GetRealZoneText), kind)
  end
end
ns.On("ZONE_CHANGED_NEW_AREA", checkInstance)
ns.On("PLAYER_ENTERING_WORLD", checkInstance)
-- Kills: only the combat log's PARTY_KILL lines by the player or their pet, one test each.
ns.On("COMBAT_LOG_EVENT_UNFILTERED", function()
  if type(_G.CombatLogGetCurrentEventInfo) ~= "function" then return end
  local _, sub, _, src, _, _, _, dest, destName, destFlags = CombatLogGetCurrentEventInfo()
  if sub ~= "PARTY_KILL" then return end
  if src ~= U.Call(UnitGUID, "player") and src ~= U.Call(UnitGUID, "pet") then return end
  -- Players killed are counted by Sources/Life.lua as killing blows, never by name; nor is
  -- anything another player controls (a hunter's pet, a warlock's demon), whose name its
  -- owner chose.
  if type(dest) == "string" and (dest:find("^Player%-") or dest:find("^Pet%-")) then return end
  if type(destFlags) == "number" and math.floor(destFlags / 0x100) % 2 == 1 then return end
  if type(destName) == "string" then D.Kill(destName) end
end)
local onTaxi = false
ns.On("PLAYER_CONTROL_LOST", function()
  if not onTaxi and U.Call(UnitOnTaxi, "player") then onTaxi = true; D.Flight() end
end)
ns.On("PLAYER_CONTROL_GAINED", function() onTaxi = false end)

-- Chains finished before Auto TRP kept its own record: where the game can list the quests
-- a character has ever completed and name them, the ones that earn a name are taken in
-- (their time unknown, so they count as the earliest). Once per session, a little after
-- login; nothing happens where the game can't say.
function D.Backfill()
  local QL = _G.C_QuestLog
  local d = store()
  if not d or not QL or type(QL.GetTitleForQuestID) ~= "function" then return 0 end
  local ids = U.Call(QL.GetAllCompletedQuestIDs)
  if type(ids) ~= "table" then return 0 end
  local added = 0
  for _, id in ipairs(ids) do
    local title = U.Plain(U.Call(QL.GetTitleForQuestID, id))
    if title and not d.quests[title] and D.EarnsName(title) then
      d.n = d.n + 1
      d.quests[title] = { t = 1, id = id, n = d.n, before = true }
      added = added + 1
    end
  end
  if added > 0 and ns.Compose then ns.Compose.SourcesChanged() end
  return added
end
ns.Listen("LOGIN", function() ns.After(20, D.Backfill) end)
