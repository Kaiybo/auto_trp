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
-- The quest log: what the character has taken on and not yet finished. Read only when
-- asked for, and again only after the log has changed.
---------------------------------------------------------------------------
local inLog, logDirty = {}, true
local function markLog() logDirty = true end
for _, ev in ipairs({ "QUEST_ACCEPTED", "QUEST_REMOVED", "QUEST_LOG_UPDATE", "QUEST_TURNED_IN", "PLAYER_ENTERING_WORLD" }) do
  ns.On(ev, markLog)
end

-- The titles in the quest log (headers left out), in the log's order.
function D.InLog()
  if not logDirty then return inLog end
  local out = {}
  local QL = _G.C_QuestLog
  local n = U.Call(_G.GetNumQuestLogEntries)
  if type(n) == "number" and type(_G.GetQuestLogTitle) == "function" then
    for i = 1, n do
      local title, _, _, isHeader = U.Call(_G.GetQuestLogTitle, i)
      title = U.Plain(title)
      if title and not isHeader then out[#out + 1] = title end
    end
  elseif QL and type(QL.GetNumQuestLogEntries) == "function" and type(QL.GetInfo) == "function" then
    for i = 1, tonumber(U.Call(QL.GetNumQuestLogEntries)) or 0 do
      local info = U.Call(QL.GetInfo, i)
      local title = type(info) == "table" and not info.isHeader and U.Plain(info.title)
      if title then out[#out + 1] = title end
    end
  end
  inLog, logDirty = out, false
  return inLog
end
