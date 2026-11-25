-- Reads AzerothForge Adventure Chronicle's per-character data (ChronicleCharDB): goals,
-- deaths, bosses, dungeons, professions, quests and zones. Read-only. Its private notes are
-- never read: a profile is public, notes are not.
-- Lists in Chronicle are newest first.
local _, ns = ...

local U = ns.U
local CH = {}
ns.Sources = ns.Sources or {}
ns.Sources.Chronicle = CH

local function db()
  local c = _G.Chronicle
  if type(c) == "table" and type(c.char) == "table" then return c.char end
  if type(_G.ChronicleCharDB) == "table" then return _G.ChronicleCharDB end
  return nil
end

function CH.Loaded()
  return ns.db.sources.chronicle and db() ~= nil
end

function CH.Read()
  if not CH.Loaded() then return nil end
  local c = db()
  local out = {}

  out.goals, out.goalsDone = {}, 0
  for _, g in ipairs(type(c.goals) == "table" and c.goals or {}) do
    if type(g) == "table" and g.done then out.goalsDone = out.goalsDone + 1 end
    if type(g) == "table" and not g.done and U.Plain(g.text) then
      out.goals[#out.goals + 1] = { text = U.Plain(g.text), t = tonumber(g.created) or 0 }
    end
  end
  table.sort(out.goals, function(a, b) return a.t > b.t end)

  out.deaths = {}
  for _, d in ipairs(type(c.deaths) == "table" and c.deaths or {}) do
    if type(d) == "table" then
      local killer = d.killer
      if type(killer) == "table" then killer = killer.name end
      out.deaths[#out.deaths + 1] = { t = tonumber(d.time) or 0, zone = U.Plain(d.zone), killer = U.Plain(killer) }
    end
  end
  out.deathCount = math.max(#out.deaths, type(c.stats) == "table" and tonumber(c.stats.deathCount) or 0)

  out.bosses = {}
  for _, b in pairs(type(c.bosses) == "table" and c.bosses or {}) do
    if type(b) == "table" and (tonumber(b.kills) or 0) > 0 and U.Plain(b.name) then
      out.bosses[#out.bosses + 1] = { name = U.Plain(b.name), t = tonumber(b.lastSuccess) or 0, where = U.Plain(b.instanceName) }
    end
  end
  table.sort(out.bosses, function(a, b) return a.t > b.t end)

  out.dungeons = U.Count(c.dungeons)

  out.professions = {}
  for name, p in pairs(type(c.professions) == "table" and c.professions or {}) do
    if type(p) == "table" and U.Plain(name) and (tonumber(p.rank) or 0) > 0 then
      out.professions[#out.professions + 1] = { name = name, rank = tonumber(p.rank), max = tonumber(p.maxRank) }
    end
  end
  table.sort(out.professions, function(a, b) return a.rank > b.rank end)

  out.questsDone = 0
  out.finished = {}   -- completed quest title -> { t, zone } (the first time it was done)
  for _, q in ipairs(type(c.quests) == "table" and c.quests or {}) do
    if type(q) == "table" and q.status == "completed" then
      out.questsDone = out.questsDone + 1
      local title = U.Plain(q.title)
      local t = tonumber(q.time) or 0
      if title and (not out.finished[title] or t < out.finished[title].t) then
        out.finished[title] = { t = t, zone = U.Plain(q.zone) }
      end
      if not out.lastQuest and U.Plain(q.title) then
        out.lastQuest = { title = U.Plain(q.title), t = tonumber(q.time) or 0, zone = U.Plain(q.zone) }
      end
    end
  end

  out.created = tonumber(c.created)
  out.zones = U.Count(c.zones)
  out.rares = U.Count(c.rares)
  out.appearance = CH.Appearance()
  return out
end

-- Chronicle's character summary (account-wide, keyed by GUID or name-realm): equipment
-- snapshot, attribute stats, guild, talent spec. Used for what you look like.
local function summary()
  local adb = _G.ChronicleDB
  if type(adb) ~= "table" or type(adb.characters) ~= "table" then return nil end
  local chron = _G.Chronicle
  if type(chron) == "table" and chron.characterKey and type(adb.characters[chron.characterKey]) == "table" then
    return adb.characters[chron.characterKey]
  end
  local guid, name = U.Call(UnitGUID, "player"), U.Call(UnitName, "player")
  local realm = U.Call(GetRealmName)
  for _, sum in pairs(adb.characters) do
    if type(sum) == "table" and ((guid and sum.guid == guid) or (sum.name == name and sum.realm == realm)) then return sum end
  end
end

-- Slots worth describing, most visible first.
local SHOWN = { 19, 5, 1, 3, 15, 16, 17, 18, 7, 10, 8, 6, 9 }

function CH.Appearance()
  local sum = summary()
  if type(sum) ~= "table" then return nil end
  local out = {}
  local eq = type(sum.equipment) == "table" and type(sum.equipment.slots) == "table" and sum.equipment.slots or nil
  if eq then
    out.slots = {}
    for slot, item in pairs(eq) do
      if type(item) == "table" and type(item.name) == "string" then
        out.slots[tonumber(slot) or slot] = { name = U.Plain(item.name), quality = tonumber(item.quality) or 1 }
      end
    end
    -- The finest piece on show: highest quality, then most visible slot.
    local best
    for _, slot in ipairs(SHOWN) do
      local item = out.slots[slot]
      if item and item.quality >= 3 and (not best or item.quality > best.quality) then best = item; best.slot = slot end
    end
    out.finest = best
  end
  local st = type(sum.characterStats) == "table" and sum.characterStats or nil
  if st then
    out.stats = { strength = tonumber(st.strength), agility = tonumber(st.agility), stamina = tonumber(st.stamina),
      intellect = tonumber(st.intellect), spirit = tonumber(st.spirit) }
  end
  out.guild = U.Plain(sum.guild)
  out.spec = type(sum.talents) == "table" and U.Plain(sum.talents.name) or nil
  return out
end
