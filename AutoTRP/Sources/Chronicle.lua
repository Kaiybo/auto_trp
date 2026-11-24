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

  out.goals = {}
  for _, g in ipairs(type(c.goals) == "table" and c.goals or {}) do
    if type(g) == "table" and not g.done and type(g.text) == "string" then
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
    if type(b) == "table" and (tonumber(b.kills) or 0) > 0 and type(b.name) == "string" then
      out.bosses[#out.bosses + 1] = { name = U.Plain(b.name), t = tonumber(b.lastSuccess) or 0, where = U.Plain(b.instanceName) }
    end
  end
  table.sort(out.bosses, function(a, b) return a.t > b.t end)

  out.dungeons = U.Count(c.dungeons)

  out.professions = {}
  for name, p in pairs(type(c.professions) == "table" and c.professions or {}) do
    if type(p) == "table" and type(name) == "string" and (tonumber(p.rank) or 0) > 0 then
      out.professions[#out.professions + 1] = { name = name, rank = tonumber(p.rank), max = tonumber(p.maxRank) }
    end
  end
  table.sort(out.professions, function(a, b) return a.rank > b.rank end)

  out.questsDone = 0
  for _, q in ipairs(type(c.quests) == "table" and c.quests or {}) do
    if type(q) == "table" and q.status == "completed" then out.questsDone = out.questsDone + 1 end
  end

  out.zones = U.Count(c.zones)
  out.rares = U.Count(c.rares)
  return out
end
