-- Reads RPG Dialogue's per-character saved data (RPGDialogueCharDB). Read-only.
-- RPG Dialogue keeps its runtime namespace private, so this reads the SavedVariables table
-- the game hands both addons. Field shapes follow RPG Dialogue's SavedData.lua (schema 7).
local _, ns = ...

local U = ns.U
local W = ns.Words
local R = {}
ns.Sources = ns.Sources or {}
ns.Sources.RPGD = R

function R.Loaded()
  return ns.db.sources.rpgd and type(_G.RPGDialogueCharDB) == "table"
end

local function db() return _G.RPGDialogueCharDB end

function R.TownName(id)
  return (ns.RPGDNames and ns.RPGDNames.towns[id]) or U.Humanize(id)
end

function R.ThreadName(id)
  return (ns.RPGDNames and ns.RPGDNames.threads[id]) or U.Humanize(id)
end

-- Everything Compose needs, normalised. Missing pieces stay nil.
function R.Read()
  if not R.Loaded() then return nil end
  local c = db()
  local out = {}

  -- Alignment and traits
  local a = type(c.align) == "table" and c.align or {}
  out.align = { light = tonumber(a.light) or 0, order = tonumber(a.order) or 0, honor = tonumber(a.honor) or 0, taint = tonumber(a.taint) or 0 }
  out.traits = {}
  for name, n in pairs(type(c.traits) == "table" and c.traits or {}) do
    if type(n) == "number" then out.traits[name] = n end
  end
  local list = {}
  for name, n in pairs(out.traits) do if n >= 3 then list[#list + 1] = { name = name, n = n } end end
  table.sort(list, function(x, y) if x.n ~= y.n then return x.n > y.n end return x.name < y.name end)
  out.dominant = {}
  for i = 1, math.min(2, #list) do out.dominant[i] = list[i].name end

  -- Origin: { id, name, blurb } (the blurb is in the character's own voice)
  if type(c.origin) == "table" and c.origin.id ~= "other" then
    out.origin = { name = U.Plain(c.origin.name), blurb = U.Plain(c.origin.blurb), id = c.origin.id }
  end

  -- Opinions, newest first
  out.opinions = {}
  for topic, rec in pairs(type(c.opinions) == "table" and c.opinions or {}) do
    if type(rec) == "table" and type(rec.stance) == "string" then
      out.opinions[#out.opinions + 1] = { topic = topic, stance = rec.stance, t = tonumber(rec.t) or 0,
        changed = type(rec.contradicts) == "table",
        was = type(rec.contradicts) == "table" and type(rec.contradicts.stance) == "string" and rec.contradicts.stance or nil }
    end
  end
  table.sort(out.opinions, function(x, y) return x.t > y.t end)

  -- Town standing
  out.towns = {}
  for id, rec in pairs(type(c.towns) == "table" and c.towns or {}) do
    local v = type(rec) == "table" and tonumber(rec.value)
    if v then out.towns[#out.towns + 1] = { id = id, name = R.TownName(id), value = v } end
  end
  table.sort(out.towns, function(x, y) return x.value > y.value end)

  -- People: named NPCs with a feeling either way
  out.friends, out.rivals = {}, {}
  out.met = 0
  for _, m in pairs(type(c.npc) == "table" and c.npc or {}) do
    if type(m) == "table" and U.Plain(m.name) and (tonumber(m.times) or 0) > 0 then
      out.met = out.met + 1
      local aff = tonumber(m.affinity) or 0
      local rec = { name = U.Plain(m.name), affinity = aff, times = m.times or 0, zone = U.Plain(m.zone), last = tonumber(m.last) or 0 }
      if aff >= 3 then out.friends[#out.friends + 1] = rec elseif aff <= -3 then out.rivals[#out.rivals + 1] = rec end
      if not out.lastTalk or rec.last > out.lastTalk.last then out.lastTalk = rec end
    end
  end
  table.sort(out.friends, function(x, y) if x.affinity ~= y.affinity then return x.affinity > y.affinity end return x.times > y.times end)
  table.sort(out.rivals, function(x, y) return x.affinity < y.affinity end)
  out.conversations = tonumber(c.conversations) or 0

  -- Zones in the order first reached
  out.zones = {}
  for zone, t in pairs(type(c.zones) == "table" and c.zones or {}) do
    if type(zone) == "string" and zone ~= "" then out.zones[#out.zones + 1] = { name = zone, t = tonumber(t) or 0 } end
  end
  table.sort(out.zones, function(x, y) return x.t < y.t end)

  -- Throughlines (stories)
  out.threads = {}
  for id, t in pairs(type(c.threads) == "table" and c.threads or {}) do
    if type(t) == "table" and t.state and t.state ~= "dormant" and t.state ~= "faded" then
      out.threads[#out.threads + 1] = { id = id, title = R.ThreadName(id), state = t.state, t = tonumber(t.t) or 0,
        beats = U.Count(t.beats) }
    end
  end
  table.sort(out.threads, function(x, y) return x.t > y.t end)

  -- Deeds: dungeons cleared, levels, first death
  out.cleared = {}
  for id, d in pairs(type(c.deeds) == "table" and c.deeds or {}) do
    local place = type(id) == "string" and id:match("^cleared:(.+)$")
    if place and U.Plain(place) and type(d) == "table" then out.cleared[#out.cleared + 1] = { name = place, t = tonumber(d.t) or 0 } end
  end
  table.sort(out.cleared, function(x, y) return x.t > y.t end)
  out.kills = type(c.kills) == "table" and tonumber(c.kills.total) or 0
  out.killsByName = type(c.kills) == "table" and type(c.kills.byName) == "table" and c.kills.byName or {}

  -- Deaths
  out.deathCount = tonumber(c.deathCount) or 0
  out.deaths = {}
  for _, d in ipairs(type(c.deaths) == "table" and c.deaths or {}) do
    if type(d) == "table" then
      out.deaths[#out.deaths + 1] = { t = tonumber(d.t) or 0, zone = d.zone, killer = type(d.killer) == "table" and U.Plain(d.killer.name) or nil, cause = d.cause }
    end
  end

  -- Home, drink, madness
  if type(c.homeInn) == "table" then
    out.homeInn = U.Plain(c.homeInn.name)
    out.homePrev = U.Plain(c.homeInn.previous)
    out.homeSince = tonumber(c.homeInn.since)
  end
  -- The creature most often put down
  local topName, topN = nil, 0
  for name, n in pairs(out.killsByName) do
    if type(n) == "number" and n > topN then topName, topN = name, n end
  end
  out.grudge = topName and U.Plain(topName) and { name = U.Plain(topName), n = topN } or nil
  out.drunk = tonumber(c.drunk) or 0
  out.drunkAt = tonumber(c.drunkAt) or 0
  out.insanity = type(c.insanity) == "table" and tonumber(c.insanity.level) or 0

  -- Diary: the newest real entry (not a fold summary)
  local journal = type(c.journal) == "table" and c.journal or {}
  out.journalCount = #journal
  for i = #journal, 1, -1 do
    local e = journal[i]
    if type(e) == "table" and e.kind ~= "summary" and e.kind ~= "origin" and type(e.text) == "string" then
      out.lastEntry = { text = U.Plain(e.text), t = tonumber(e.t) or 0, zone = e.zone, otherHand = e.otherHand }
      break
    end
  end

  -- Letters that reached the mailbox, books read, topics heard of
  out.lettersArrived = 0
  for _, l in pairs(type(c.letters) == "table" and c.letters or {}) do
    if type(l) == "table" and l.arrived then out.lettersArrived = out.lettersArrived + 1 end
  end
  out.books = {}
  for title, b in pairs(type(c.books) == "table" and c.books or {}) do
    if U.Plain(title) then out.books[#out.books + 1] = { title = U.Plain(title), n = type(b) == "table" and tonumber(b.n) or 1 } end
  end
  table.sort(out.books, function(x, y) if x.n ~= y.n then return x.n > y.n end return x.title < y.title end)
  out.topics = U.Count(c.topics)
  -- Claims you made, and how many were found out.
  local claims = type(c.claims) == "table" and c.claims or {}
  out.claimsMade = U.Count(claims.player)
  out.liesExposed = U.Count(claims.exposed)
  out.heard = U.Count(type(c.claims) == "table" and c.claims.heard or nil)

  -- Arrivals, for the mood model (zone -> time)
  out.arrived = type(c.arrived) == "table" and c.arrived or {}
  return out
end

-- RPG Dialogue's own alignment title for this character, or nil.
function R.AlignTitle(align, faction)
  if not align then return nil end
  local best, mag
  for _, t in ipairs(W.ALIGN_TITLES) do
    local v = (align[t.axis] or 0) * t.sign
    if v >= 50 then
      local m = math.max(math.abs(align.light), math.abs(align.order), math.abs(align.honor))
      if not best or m > mag then best, mag = t, m end
    end
  end
  if not best then return nil end
  return best[faction or "Alliance"] or best.Alliance
end

function R.Tier(value)
  for _, t in ipairs(W.TIERS) do
    if value <= t.max then return t end
  end
  return W.TIERS[#W.TIERS]
end
