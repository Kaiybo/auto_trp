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
  for _, k in ipairs({ "zones", "dungeons", "rares", "deaths" }) do
    if type(d[k]) ~= "table" then d[k] = {} end
  end
  d.n = tonumber(d.n) or 0
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
  -- The rest of the road, from the game itself: lands and dungeons by first visit, rare
  -- beasts felled, deaths (newest first, as in Chronicle) and when the record began.
  out.zones, out.dungeons, out.rares = {}, 0, 0
  for name, t in pairs(d.zones) do out.zones[#out.zones + 1] = { name = name, t = tonumber(t) or 0 } end
  table.sort(out.zones, function(a, b) if a.t ~= b.t then return a.t < b.t end return a.name < b.name end)
  for _ in pairs(d.dungeons) do out.dungeons = out.dungeons + 1 end
  for _ in pairs(d.rares) do out.rares = out.rares + 1 end
  out.deaths = {}
  for i = #d.deaths, 1, -1 do out.deaths[#out.deaths + 1] = d.deaths[i] end
  out.deathCount = #d.deaths
  out.created = d.since
  for name, b in pairs(d.bosses) do out.bosses[#out.bosses + 1] = { name = name, first = b.t or 0, t = b.last or b.t or 0, where = b.where } end
  table.sort(out.bosses, function(a, b) return a.t > b.t end)
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

---------------------------------------------------------------------------
-- The road, deaths and rare beasts, straight from the game
---------------------------------------------------------------------------
D.KEEP_DEATHS = 200   -- the count goes on; only the oldest details are let go

-- Where the character is now: a land the first time it's seen, a dungeon or raid the first
-- time it's entered.
function D.Place(t)
  local d = store()
  if not d then return end
  local name, kind = U.Call(GetInstanceInfo)
  name = U.Plain(name)
  local changed
  if (kind == "party" or kind == "raid") and name then
    if not d.dungeons[name] then d.dungeons[name] = t or U.Now(); changed = true end
  elseif kind ~= "pvp" and kind ~= "arena" then
    local z = zone()
    if z and not d.zones[z] then d.zones[z] = t or U.Now(); changed = true end
  end
  if changed and ns.Compose then ns.Compose.SourcesChanged() end
end
ns.On("ZONE_CHANGED_NEW_AREA", function() D.Place() end)
ns.On("PLAYER_ENTERING_WORLD", function() D.Place() end)

-- A death, with whatever last hurt the character (from the combat log) as the killer.
local lastHit   -- { name, t }
function D.Death(killer, where, t)
  local d = store()
  if not d then return end
  t = t or U.Now()
  if not killer and lastHit and t - lastHit.t <= 10 then killer = lastHit.name end
  d.deaths[#d.deaths + 1] = { t = t, zone = where or zone(), killer = U.Plain(killer) }
  d.deathsLost = tonumber(d.deathsLost) or 0
  while #d.deaths > D.KEEP_DEATHS do table.remove(d.deaths, 2); d.deathsLost = d.deathsLost + 1 end  -- keep the first
  lastHit = nil
  if ns.Compose then ns.Compose.SourcesChanged() end
end
ns.On("PLAYER_DEAD", function() D.Death() end)

-- A rare beast felled by the character or their group. Rares are recognised when seen
-- (target, mouseover, nameplate), since the combat log doesn't say.
local rareSeen = {}   -- GUID -> name
local function look(unit)
  local guid = U.Call(UnitGUID, unit)
  if not guid or rareSeen[guid] then return end
  local cls = U.Call(UnitClassification, unit)
  if (cls == "rare" or cls == "rareelite") and not U.Call(UnitIsPlayer, unit) then
    rareSeen[guid] = U.Plain(U.Call(UnitName, unit))
  end
end
ns.On("PLAYER_TARGET_CHANGED", function() look("target") end)
ns.On("UPDATE_MOUSEOVER_UNIT", function() look("mouseover") end)
ns.On("NAME_PLATE_UNIT_ADDED", function(_, unit) if unit then look(unit) end end)

function D.Rare(name, t)
  local d = store()
  name = U.Plain(name)
  if not d or not name or d.rares[name] then return false end
  d.rares[name] = t or U.Now()
  if ns.Compose then ns.Compose.SourcesChanged() end
  return true
end

local MINE = 0x7   -- COMBATLOG_OBJECT_AFFILIATION_MINE | PARTY | RAID
local DAMAGE = { SWING_DAMAGE = true, RANGE_DAMAGE = true, SPELL_DAMAGE = true, SPELL_PERIODIC_DAMAGE = true,
  ENVIRONMENTAL_DAMAGE = true }
ns.On("COMBAT_LOG_EVENT_UNFILTERED", function()
  local fn = _G.CombatLogGetCurrentEventInfo
  if type(fn) ~= "function" then return end
  local ok, _, sub, _, srcGUID, srcName, srcFlags, _, dstGUID = pcall(fn)
  if not ok then return end
  sub, srcName, srcFlags, dstGUID = U.Unsecret(sub), U.Unsecret(srcName), U.Unsecret(srcFlags), U.Unsecret(dstGUID)
  if type(sub) ~= "string" then return end
  if DAMAGE[sub] then
    if dstGUID and dstGUID == U.Call(UnitGUID, "player") then
      local name = srcName
      if sub == "ENVIRONMENTAL_DAMAGE" then name = nil end
      lastHit = { name = name, t = U.Now() }
    end
  elseif sub == "PARTY_KILL" or sub == "UNIT_DIED" then
    local rare = dstGUID and rareSeen[dstGUID]
    if not rare then return end
    local bit = _G.bit
    if sub == "PARTY_KILL" and bit and srcFlags and bit.band(srcFlags, MINE) == 0 then return end
    rareSeen[dstGUID] = nil
    D.Rare(rare)
  end
end)
