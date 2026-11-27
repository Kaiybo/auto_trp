-- The journal: a day-by-day account the character "writes" from what actually happened in
-- each play session. It listens to the game itself (no other addon needed): lands entered,
-- jobs turned in, dungeons and their masters, levels, deaths, great finds, the purse, company,
-- inns, flights and crafts. When a session ends (or /atrp journal is run) the day's entry is
-- written in the first person from that record and nothing else; the wording is in
-- Words.lua (W.JOURNAL). Every sentence comes from something recorded. Other players are
-- never named, except the friends you marked in Social Diary (if you let Auto TRP name them).
-- Kept per character in AutoTRPCharDB.journal: { days = { [date] = log }, entries = { [date] = entry } }.
local _, ns = ...

local U = ns.U
local W = ns.Words
local J = {}
ns.Journal = J

J.KEEP_DAYS = 30     -- entries kept
J.KEEP_LOGS = 3      -- the raw record behind an entry is kept this many days
J.MAX_EVENTS = 150   -- per day; past this only the day's totals keep counting

local function store()
  if not ns.char then return nil end
  local j = ns.char.journal
  if type(j) ~= "table" then j = {}; ns.char.journal = j end
  if type(j.days) ~= "table" then j.days = {} end
  if type(j.entries) ~= "table" then j.entries = {} end
  return j
end

local function dayKey(offset) return ns.Mood.Day(offset) end

local function inCombat() return U.Call(InCombatLockdown) or U.Call(UnitAffectingCombat, "player") end

local function here()
  local zone = U.Plain(U.Call(GetRealZoneText)) or U.Plain(U.Call(GetZoneText))
  local sub = U.Plain(U.Call(GetSubZoneText))
  if sub == zone then sub = nil end
  local resting = U.Call(IsResting) and true or false
  return { zone = zone, sub = sub, inn = resting and sub and ns.World.IsInn(sub) or false, hour = U.Call(GetGameTime), t = U.Now() }
end

-- Forget entries past a month and the raw record past a few days.
local function prune(j)
  local keys = {}
  for k in pairs(j.entries) do keys[#keys + 1] = k end
  table.sort(keys)
  for i = 1, #keys - J.KEEP_DAYS do j.entries[keys[i]] = nil end
  keys = {}
  for k in pairs(j.days) do keys[#keys + 1] = k end
  table.sort(keys)
  for i = 1, #keys - J.KEEP_LOGS do j.days[keys[i]] = nil end
end

-- Today's log, started where the character is now.
local function day()
  local j = store()
  if not j then return nil end
  local key = dayKey()
  local d = j.days[key]
  if not d then
    local h = here()
    d = { start = h, last = h, cur = h.zone, ev = {}, money = 0, sessions = 0, first = h.t }
    j.days[key] = d
    prune(j)
  end
  d.dirty = true
  return d
end
J.Today = day

local function add(e)
  local d = day()
  if not d then return nil end
  if #d.ev >= J.MAX_EVENTS then return nil end
  e.t = U.Now()
  d.ev[#d.ev + 1] = e
  d.last.t = e.t
  return e, d
end

---------------------------------------------------------------------------
-- What's recorded
---------------------------------------------------------------------------
local flying       -- { from, known = zones seen before take-off }
local grouped = false
local foe          -- the foe at the start of the current fight: { name, named, player, desc }

-- Friends from Social Diary in the group right now (names only when allowed).
local function friendsHere()
  if not ns.db.nameFriends then return {} end
  local sd = ns.cache and ns.cache.sd
  if not sd and not inCombat() and ns.Sources.SocialDiary.Loaded() then sd = ns.Sources.SocialDiary.Read() end
  local known = {}
  for _, f in ipairs(sd and sd.friends or {}) do known[f.name] = true end
  if not next(known) then return {} end
  local out = {}
  local raid = U.Call(IsInRaid)
  for i = 1, raid and 40 or 4 do
    local name = U.Call(UnitName, (raid and "raid" or "party") .. i)
    name = type(name) == "string" and name:match("^[^%-]+") or nil
    if name and known[name] then out[#out + 1] = name end
  end
  return out
end

-- A zone entered. known: the zones seen before a flight took off (lands flown over don't count).
function J.Zone(known, flew)
  if flying then return end
  local d = day()
  if not d then return end
  local h = here()
  d.last = h
  if not h.zone or h.zone == d.cur then return end
  local seen = ns.char.seen and ns.char.seen.zones or {}
  local first
  if known then first = not known[h.zone]
  else first = seen[h.zone] ~= nil and U.Now() - seen[h.zone] <= 3 end
  local inside, kind = U.Call(IsInInstance)
  local e = { k = "zone", zone = h.zone, first = first or nil, flew = flew or nil }
  if inside and kind and kind ~= "none" then
    e.zone = U.Plain(U.Call(GetInstanceInfo)) or h.zone
    e.instance = kind
    if U.Call(IsInGroup) or U.Call(IsInRaid) then
      e.size = U.Call(GetNumGroupMembers) or 0
      e.friends = friendsHere()
    end
  end
  for _, v in ipairs(d.ev) do if v.k == "zone" and v.zone == e.zone then e.again = true end end
  if e.zone == d.start.zone then e.again = true end
  d.cur = h.zone
  add(e)
end

local function sub()
  local d = day()
  if not d then return end
  local h = here()
  d.last = h
  if h.inn then
    for _, v in ipairs(d.ev) do if v.k == "inn" and v.name == h.sub then return end end
    add({ k = "inn", name = h.sub, zone = h.zone })
  end
end

local pendingQuest
ns.On("QUEST_COMPLETE", function() pendingQuest = { title = U.Plain(U.Call(GetTitleText)), id = U.Call(GetQuestID) } end)
ns.On("QUEST_TURNED_IN", function(_, questID)
  local title
  local QL = _G.C_QuestLog
  if QL and QL.GetTitleForQuestID and questID then title = U.Plain(U.Call(QL.GetTitleForQuestID, questID)) end
  if not title and pendingQuest and (not pendingQuest.id or not questID or pendingQuest.id == questID) then title = pendingQuest.title end
  pendingQuest = nil
  if not title then return end
  local d = day()
  if not d then return end
  for _, v in ipairs(d.ev) do if v.k == "quest" and v.title == title then return end end
  add({ k = "quest", title = title, zone = d.cur })
end)

ns.On("ENCOUNTER_END", function(_, _, name, _, _, success)
  if success ~= 1 then return end
  name = U.Plain(name)
  if not name then return end
  add({ k = "boss", name = name, where = U.Plain(U.Call(GetInstanceInfo)),
    grouped = (U.Call(IsInGroup) or U.Call(IsInRaid)) and true or nil })
end)

ns.On("PLAYER_LEVEL_UP", function(_, level)
  level = tonumber(level)
  if not level then return end
  -- A new rank every ten levels: Mood.lua has just remembered it.
  local rank
  local ms = ns.char and ns.char.milestones
  local m = ms and ms[#ms]
  if m and m.level == level then rank = m.rank end
  add({ k = "level", level = level, rank = rank })
end)

-- Who a fight is with: players are never named, only what they are ("a Horde rogue").
local function who(unit)
  if not U.Call(UnitExists, unit) or not U.Call(UnitCanAttack, "player", unit) then return nil end
  if U.Call(UnitIsPlayer, unit) then
    local _, class = U.Call(UnitClass, unit)
    local faction = U.Call(UnitFactionGroup, unit)
    return { player = true, class = class, faction = faction }
  end
  local name = U.Plain(ns.World.Safe(U.Call(UnitName, unit)))
  if not name then return nil end
  local kind = ns.World.Safe(U.Call(UnitClassification, unit))
  return { name = name, named = kind and kind ~= "normal" and kind ~= "minus" and kind ~= "trivial" or nil }
end
ns.On("PLAYER_REGEN_DISABLED", function() foe = who("target"); if foe then foe.t = U.Now() end end)
ns.On("PLAYER_REGEN_ENABLED", function()
  local f = ns.char and ns.char.lastFight
  if f and f.close and U.Now() - (f.t or 0) <= 2 and foe and not U.Call(UnitIsDeadOrGhost, "player") then
    local h = here()
    add({ k = "close", foe = foe, zone = h.zone, sub = h.sub })
  end
  foe = nil
end)
ns.On("PLAYER_DEAD", function()
  local h = here()
  local killer = who("target") or foe
  local inside = U.Call(IsInInstance)
  local e = add({ k = "death", foe = killer, zone = inside and (U.Plain(U.Call(GetInstanceInfo)) or h.zone) or h.zone, sub = not inside and h.sub or nil })
  foe = nil
  return e
end)

-- Loot: rare and better, the character's own.
local QUALITY_HEX = { ["0070dd"] = 3, a335ee = 4, ff8000 = 5 }
ns.On("CHAT_MSG_LOOT", function(_, msg)
  msg = ns.World.Safe(msg)
  if type(msg) ~= "string" or not msg:find("^You receive") then return end
  local q = tonumber(msg:match("|cnIQ(%d+):"))
  if not q then local hex = msg:match("|cff(%x%x%x%x%x%x)"); q = hex and QUALITY_HEX[hex:lower()] end
  local item = U.Plain(msg:match("%[(.-)%]"))
  if not q or q < 3 or not item then return end
  add({ k = "loot", item = item, q = q })
end)

-- The purse: what changed over the day, in and out.
local lastMoney
ns.On("PLAYER_MONEY", function()
  local m = U.Call(GetMoney)
  if type(m) ~= "number" then return end
  local d = day()
  if d and lastMoney then d.money = (d.money or 0) + (m - lastMoney) end
  lastMoney = m
end)

ns.On("GROUP_ROSTER_UPDATE", function()
  local now = (U.Call(IsInGroup) or U.Call(IsInRaid)) and true or false
  local size = U.Call(GetNumGroupMembers) or 0
  local d = day()
  if not d then return end
  if now and not grouped then
    add({ k = "group", size = size, friends = friendsHere() })
  elseif now then
    for i = #d.ev, 1, -1 do
      local v = d.ev[i]
      if v.k == "group" then
        v.size = math.max(v.size or 0, size)
        local have = {}
        for _, n in ipairs(v.friends) do have[n] = true end
        for _, n in ipairs(friendsHere()) do if not have[n] then v.friends[#v.friends + 1] = n end end
        break
      end
    end
  end
  grouped = now
end)

-- Crafts and skills: "Your skill in Herbalism has increased to 125."
ns.On("CHAT_MSG_SKILL", function(_, msg)
  msg = ns.World.Safe(msg)
  local skill, rank = type(msg) == "string" and msg:match("^Your skill in (.-) has increased to (%d+)")
  if not skill then return end
  local d = day()
  if not d then return end
  for _, v in ipairs(d.ev) do if v.k == "skill" and v.name == skill then v.rank = tonumber(rank); return end end
  add({ k = "skill", name = skill, rank = tonumber(rank) })
end)

-- Flights: from where to where. Lands flown over aren't "entered".
ns.On("PLAYER_CONTROL_LOST", function()
  if flying or not U.Call(UnitOnTaxi, "player") then return end
  local known = {}
  for k in pairs(ns.char and ns.char.seen and ns.char.seen.zones or {}) do known[k] = true end
  flying = { from = U.Plain(U.Call(GetRealZoneText)), known = known }
end)
ns.On("PLAYER_CONTROL_GAINED", function()
  if not flying then return end
  local f = flying
  flying = nil
  add({ k = "flight", from = f.from, to = U.Plain(U.Call(GetRealZoneText)) })
  J.Zone(f.known, true)
end)

ns.On("ZONE_CHANGED_NEW_AREA", function() J.Zone() end)
ns.On("ZONE_CHANGED", sub)
ns.On("ZONE_CHANGED_INDOORS", sub)
ns.On("PLAYER_UPDATE_RESTING", sub)

-- A session begins: the purse's starting point, and where the day picks up.
local started = false
ns.On("PLAYER_ENTERING_WORLD", function()
  if not ns.char then return end
  if not started then
    started = true
    lastMoney = U.Call(GetMoney)
    grouped = (U.Call(IsInGroup) or U.Call(IsInRaid)) and true or false
    local d = day()
    if d then d.sessions = (d.sessions or 0) + 1 end
  end
  J.Zone()
end)

-- A session ends: the day is written down. (Also on each loading screen, which is cheap.)
local function finish() J.WriteAll() end
ns.On("PLAYER_LEAVING_WORLD", finish)
ns.On("PLAYER_LOGOUT", finish)

---------------------------------------------------------------------------
-- Writing it down
---------------------------------------------------------------------------
local function seedFor(key, tag) return (ns.char and ns.char.seedName or "") .. ":journal:" .. key .. ":" .. tostring(tag) end

local function fill(line, vars)
  return (line:gsub("{(%a+)}", function(k) if vars[k] ~= nil then return vars[k] end end))
end

local function pick(list, key, tag, vars)
  local line = U.Pick(list, seedFor(key, tag))
  if type(line) ~= "string" then return nil end
  return fill(line, vars or {})
end

-- "I'll" and "Light" keep their capitals mid-sentence; other first words are lowered.
local KEEP_CAP = { I = true, ["I'll"] = true, ["I'm"] = true, ["I've"] = true, ["I'd"] = true, Light = true }
local function lower(s)
  local w = s:match("^([%a']+)")
  if w and (KEEP_CAP[w] or w:find("^%u%u")) then return s end
  return (s:gsub("^%u", string.lower))
end

local function article(word) return (word:lower():match("^[aeiou]") and "an " or "a ") .. word end

local function quoteTitle(t) return "\"" .. t .. "\"" end

local function innName(s) return s:find("^The ") and U.Mid(s) or ("the " .. s) end

local function whereText(zone, sub)
  if sub and sub ~= zone then return "near " .. U.Mid(sub) end
  return zone and ("in " .. U.Mid(zone)) or ""
end

local CLASS_WORD = { DEATHKNIGHT = "death knight" }
local function foeText(f)
  if not f then return nil end
  if f.player then
    local class = f.class and (CLASS_WORD[f.class] or f.class:lower())
    if f.faction and class then return article(f.faction .. " " .. class) end
    if f.faction then return "one of the " .. f.faction end
    return "another traveller"
  end
  if not f.name then return nil end
  return f.named and f.name or article(f.name)
end

local function coins(c)
  c = math.abs(c or 0)
  local g, s = math.floor(c / 10000), math.floor((c % 10000) / 100)
  if g >= 1 then
    if s >= 10 and g < 10 then return U.Number(g) .. " gold and " .. U.Number(s) .. " silver" end
    return U.Number(g) .. " gold"
  end
  if s >= 1 then return U.Number(s) .. " silver" end
  return nil
end

local function todOf(hour)
  if type(hour) ~= "number" then return nil end
  if hour >= 5 and hour < 8 then return "dawn" end
  if hour < 12 and hour >= 8 then return "morning" end
  if hour == 12 then return "noon" end
  if hour > 12 and hour < 17 then return "afternoon" end
  if hour >= 17 and hour < 21 then return "evening" end
  return "night"
end

local function placeOf(p)
  if not p then return nil end
  if p.inn and p.sub then return innName(p.sub) end
  if p.sub then return U.Mid(p.sub) end
  return p.zone and U.Mid(p.zone)
end

local function most(t)
  local best, n
  for k, v in pairs(t or {}) do if not n or v > n or (v == n and k < best) then best, n = k, v end end
  return best
end

-- How the character takes things: their RPG Dialogue temperament when there is one, else
-- their race and class. Gives the pools to look in, most particular first.
local function temperKeys()
  local keys = {}
  local rpgd = ns.Compose and ns.cache and ns.Compose.Persona(ns.cache)
  for _, t in ipairs(rpgd and rpgd.dominant or {}) do keys[#keys + 1] = t end
  local race = select(2, U.Call(UnitRace, "player"))
  local class = select(2, U.Call(UnitClass, "player"))
  if race then keys[#keys + 1] = race end
  if class then keys[#keys + 1] = class end
  return keys
end
local function voiced(pools, key, tag, vars)
  local list = {}
  for _, l in ipairs(pools.default or {}) do list[#list + 1] = l end
  for _, k in ipairs(temperKeys()) do
    if pools[k] then
      -- The character's own leaning gets the better chance.
      for _, l in ipairs(pools[k]) do list[#list + 1] = l; list[#list + 1] = l end
      break
    end
  end
  return pick(list, key, tag, vars)
end

local function joinClauses(list)
  if #list == 0 then return nil end
  if #list == 1 then return list[1] end
  local out = list[1]
  for i = 2, #list do out = out .. (i == #list and ", and " or ", ") .. lower(list[i]) end
  return out
end

-- The entry for one day: { text, lines = { { text, kind } } }, or nil if nothing happened.
function J.Compose(key)
  local j = store()
  local d = j and j.days[key]
  if not d then return nil end
  local JW = W.JOURNAL
  local live = key == dayKey()
  if live then
    local h = here()
    d.last = h.zone and h or d.last
  end
  local ev = d.ev
  local lines = {}
  local function line(text, kind) if text and text ~= "" then lines[#lines + 1] = { text = text, kind = kind } end end

  -- Split the day into stretches, one per land in the order entered.
  local segs = { { zone = d.start.zone, start = true, quests = {}, bosses = {}, deaths = {}, close = {}, inns = {} } }
  local misc = { loot = {}, levels = {}, skills = {}, groups = {} }
  local moved = false
  for _, e in ipairs(ev) do
    local seg = segs[#segs]
    if e.k == "zone" then
      moved = true
      segs[#segs + 1] = { zone = e.zone, first = e.first, again = e.again, flew = e.flew, instance = e.instance,
        size = e.size, friends = e.friends, quests = {}, bosses = {}, deaths = {}, close = {}, inns = {} }
    elseif e.k == "quest" then seg.quests[#seg.quests + 1] = e.title
    elseif e.k == "boss" then seg.bosses[#seg.bosses + 1] = e.name; seg.bossGroup = seg.bossGroup or e.grouped
    elseif e.k == "death" then seg.deaths[#seg.deaths + 1] = e
    elseif e.k == "close" then seg.close[#seg.close + 1] = e
    elseif e.k == "inn" then seg.inns[#seg.inns + 1] = e.name
    elseif e.k == "loot" then misc.loot[#misc.loot + 1] = e
    elseif e.k == "level" then misc.levels[#misc.levels + 1] = e
    elseif e.k == "skill" then misc.skills[#misc.skills + 1] = e
    elseif e.k == "group" then misc.groups[#misc.groups + 1] = e end
  end
  local busy = #ev > 0
  if not busy and (d.last.t or 0) - (d.first or 0) < 600 then return nil end

  -- The end of the day, and an inn at the end isn't told twice.
  local last = d.last or d.start
  local finalSeg = segs[#segs]
  if last.inn and last.sub then
    for i = #finalSeg.inns, 1, -1 do if finalSeg.inns[i] == last.sub then table.remove(finalSeg.inns, i) end end
  end

  local function hasActs(s) return #s.quests > 0 or #s.bosses > 0 or #s.deaths > 0 or #s.close > 0 or #s.inns > 0 end
  local function questClause(s, there)
    local q = s.quests
    if #q == 0 then return nil end
    local vars = { there = there, q = q[1], n = U.Number(#q) }
    if #q == 1 then return pick(JW.quest_one, key, "q1" .. q[1], vars) end
    if #q <= 3 then
      local names = {}
      for i, t in ipairs(q) do names[i] = quoteTitle(t) end
      vars.list = U.Join(names)
      return pick(JW.quest_few, key, "q3" .. q[1], vars)
    end
    vars.list = quoteTitle(q[1]) .. " and " .. quoteTitle(q[#q])
    return pick(JW.quest_many, key, "qn" .. q[1], vars)
  end
  local function company(s)
    if not s.size or s.size < 2 then return "" end
    local others = s.size - 1
    local f = s.friends or {}
    if #f > 0 then
      local rest = others - #f
      local names = {}
      for i, n in ipairs(f) do names[i] = n end
      if rest > 0 then names[#names + 1] = U.Number(rest) .. " " .. U.Plural(rest, "other") end
      return " with " .. U.Join(names)
    end
    return " with " .. U.Number(others) .. " " .. U.Plural(others, "other")
  end
  local function arrival(s, i)
    local vars = { zone = U.Mid(s.zone), company = company(s) }
    if s.instance == "raid" then return pick(JW.raid, key, "raid" .. s.zone, vars) end
    if s.instance then return pick(s.first and JW.instance_new or JW.instance, key, "inst" .. s.zone, vars) end
    if s.flew then return pick(s.first and JW.flew_new or JW.flew, key, "fly" .. i .. s.zone, vars) end
    if s.first then return pick(JW.arrive_new, key, "new" .. s.zone, vars) end
    if s.again then return pick(JW.arrive_back, key, "back" .. i .. s.zone, vars) end
    return pick(JW.arrive_on, key, "on" .. i .. s.zone, vars)
  end

  -- 1. Where the day started, and the road.
  local p1 = {}
  local startPlace = placeOf(d.start) or "where I was"
  local tod = todOf(d.start.hour)
  local todWords = tod and pick(JW.tod[tod], key, "tod1") or "today"
  local pass = {}
  local described = 0
  for i, s in ipairs(segs) do
    local clauses = {}
    local there = " there"
    if s.start then
      if moved then
        clauses[1] = pick(JW.open_move, key, "open", { place = startPlace, tod = todWords })
        there = " before I left"
      else
        clauses[1] = pick(JW.open_stay, key, "stay", { place = startPlace, zone = U.Mid(d.start.zone or "these parts"), tod = todWords })
        there = ""
      end
    elseif not hasActs(s) and not s.first and not s.instance and i < #segs then
      pass[#pass + 1] = U.Mid(s.zone)
    else
      local a = arrival(s, i)
      if #pass > 0 then
        a = pick(JW.pass, key, "pass" .. i, { list = U.Join(pass) }) .. ", and " .. lower(a)
        pass = {}
      end
      clauses[1] = a
    end
    if clauses[1] then
      described = described + 1
      clauses[#clauses + 1] = questClause(s, there)
      for _, inn in ipairs(s.inns) do clauses[#clauses + 1] = pick(JW.inn_mid, key, "inn" .. inn, { inn = innName(inn) }) end
      line(joinClauses(clauses), s.start and "open" or "travel")
      if #s.bosses > 0 then
        local list = {}
        for n, b in ipairs(s.bosses) do list[n] = b end
        line(pick(s.bossGroup and JW.boss_group or JW.boss_solo, key, "boss" .. s.bosses[1], { list = U.Join(list) }), "boss")
      end
      -- Deaths and near misses, with how the character takes it.
      if #s.deaths > 0 then
        local lastD = s.deaths[#s.deaths]
        local where = whereText(lastD.zone or s.zone, lastD.sub)
        local text
        if #s.deaths > 1 then
          text = pick(JW.death_many, key, "dm" .. i, { times = U.Times(#s.deaths), where = whereText(s.zone) })
          local f = foeText(lastD.foe)
          if f then text = text .. pick(JW.death_last, key, "dl" .. i, { foe = f }) end
        else
          local f = foeText(lastD.foe)
          local list = not f and JW.death_unknown or (lastD.foe.player and JW.death_player or JW.death_one)
          text = pick(list, key, "d1" .. i, { foe = f or "", where = where })
        end
        local after = voiced(JW.after_death, key, "ad" .. i, {})
        line(U.Cap(text) .. (after and ("; " .. lower(after)) or ""), "death")
      elseif #s.close > 0 then
        local c = s.close[#s.close]
        local f = foeText(c.foe)
        if f then
          local text = pick(JW.close, key, "cl" .. i, { foe = f, where = whereText(c.zone or s.zone, c.sub) })
          local after = voiced(JW.after_close, key, "ac" .. i, {})
          line(U.Cap(text) .. (after and ("; " .. lower(after)) or ""), "close")
        end
      end
    end
  end
  if #pass > 0 then line(pick(JW.pass_end, key, "passend", { list = U.Join(pass) }), "travel") end

  -- 2. Company, finds, growing stronger, crafts.
  local extra, ownSubject = {}, {}
  if #misc.groups > 0 then
    local names, seenName = {}, {}
    for _, g in ipairs(misc.groups) do
      for _, n in ipairs(g.friends or {}) do if not seenName[n] then seenName[n] = true; names[#names + 1] = n end end
    end
    -- A group that only went into a dungeon is told there already.
    local toldInside = false
    for _, s in ipairs(segs) do if s.instance and s.size then toldInside = true end end
    if #names > 0 and not toldInside then
      extra[#extra + 1] = pick(JW.group_friends, key, "gf", { who = U.Join(names) })
    elseif not toldInside then
      extra[#extra + 1] = pick(#misc.groups > 1 and JW.group_many or JW.group_one, key, "g",
        { times = U.Times(#misc.groups), n = U.Number(#misc.groups) })
    end
  end
  if #misc.loot > 0 then
    local items, best = {}, 0
    for i = 1, math.min(3, #misc.loot) do items[i] = misc.loot[i].item; best = math.max(best, misc.loot[i].q or 0) end
    for _, l in ipairs(misc.loot) do best = math.max(best, l.q or 0) end
    local text = pick(best >= 4 and JW.loot_epic or JW.loot, key, "loot" .. items[1], { list = U.Join(items) })
    extra[#extra + 1] = text
    if text:find(items[1], 1, true) == 1 then ownSubject[text] = true end   -- "Cruel Barb came my way": not "...and grew stronger"
  end
  if #misc.levels > 0 then
    local rank
    for _, l in ipairs(misc.levels) do rank = l.rank or rank end
    local text = #misc.levels > 1 and pick(JW.level_many, key, "lv", { times = U.Times(#misc.levels) })
      or pick(JW.level, key, "lv1")
    if rank then text = text .. "; " .. lower(pick(JW.rank, key, "rk" .. rank, { rank = article(rank) })) end
    extra[#extra + 1] = text
  end
  if #misc.skills > 0 then
    local names = {}
    for i, s in ipairs(misc.skills) do names[i] = s.name:lower() end
    extra[#extra + 1] = pick(JW.skill, key, "sk" .. names[1], { list = U.Join(names) })
  end
  -- Two short ones share a sentence.
  local i = 1
  while i <= #extra do
    local a, b = extra[i], extra[i + 1]
    if b and #a + #b < 110 and not a:find(";") and not b:find(";") and not ownSubject[a] and not ownSubject[b] then
      line(a .. ", and " .. lower(b), "misc"); i = i + 2
    else
      line(a, "misc"); i = i + 1
    end
  end

  -- 3. How the day ended: where, how the character felt, the purse.
  local days = ns.char.days or {}
  local mood = most(days[key] and days[key].moods)
  if not mood and live then
    local cur = ns.Mood.Current(ns.cache and ns.cache.world)
    if cur and not cur.key:find("^calm:") then mood = cur.key end
  end
  local val = mood and W.VALENCE[mood] or 0
  local feelList = (mood and JW.feel[mood]) or (val > 0 and JW.feel.good) or (val < 0 and JW.feel.bad) or JW.feel.calm
  local feel = pick(feelList, key, "feel" .. tostring(mood))
  local money = (d.money or 0)
  local coin = coins(money)
  if coin and math.abs(money) >= 100 then
    local which = (money > 0 and "gain_" or "loss_") .. (val < 0 and "bad" or "good")
    feel = pick(JW.purse[which], key, "purse", { mood = feel, money = coin })
  end
  local endHour = todOf(last.hour)
  local late = endHour == "evening" or endHour == "night"
  local endPlace = placeOf(last)
  local flavorText
  if not last.inn and not last.sub then
    local pool = {}
    for _, f in ipairs(W.ZONE_FLAVOR[last.zone or ""] or {}) do
      if f:find("^in ") or f:find("^on ") or f:find("^under ") or f:find("^beneath ") or f:find("^among ")
        or f:find("^along ") or f:find("^deep in ") or f:find("^out on ") then pool[#pool + 1] = f end
    end
    if #pool > 0 then flavorText = U.Pick(pool, seedFor(key, "flavor")) end
  end
  local vars = { feel = feel, ["end"] = endPlace or "where I was",
    flavor = flavorText, tod = endHour and pick(JW.tod[endHour], key, "tod2") or "" }
  if last.sub and last.zone and not last.inn and last.zone ~= last.sub then vars["end"] = U.Mid(last.sub) .. " in " .. U.Mid(last.zone) end
  local closing
  if not late then closing = pick(JW.end_early, key, "end", vars)
  elseif last.inn then closing = pick(JW.end_inn, key, "end", vars)
  elseif flavorText then closing = pick(JW.end_flavor, key, "end", vars)
  else closing = pick(JW.end_at, key, "end", vars) end
  line(closing, "end")
  -- Now and then, a word in the character's own manner.
  if U.Hash(seedFor(key, "sign")) % 2 == 0 then
    local class = select(2, U.Call(UnitClass, "player"))
    local race = select(2, U.Call(UnitRace, "player"))
    local list = JW.signoff[class or ""] or JW.signoff[race or ""]
    if list then line(pick(list, key, "sign"), "signoff") end
  end

  -- Into prose: the road in one paragraph, the rest in the next.
  local paras, cur = {}, {}
  for n, l in ipairs(lines) do
    local s = U.Cap(l.text)
    if not s:find("[%.!%?]\"?$") then s = s .. "." end
    l.text = s
    if l.kind == "misc" and #cur > 1 and not paras.split then paras.split = true; paras[#paras + 1] = table.concat(cur, " "); cur = {} end
    if l.kind == "end" and not paras.split and #cur > 3 then paras.split = true; paras[#paras + 1] = table.concat(cur, " "); cur = {} end
    cur[#cur + 1] = s
  end
  if #cur > 0 then paras[#paras + 1] = table.concat(cur, " ") end
  paras.split = nil
  return { text = table.concat(paras, "\n\n"), lines = lines, t = U.Now() }
end

-- Writes every day that changed. Not in combat.
function J.WriteAll()
  local j = store()
  if not j or inCombat() then return end
  for key, d in pairs(j.days) do
    if d.dirty or key == dayKey() then
      local e = J.Compose(key)
      if e then j.entries[key] = e end
      d.dirty = nil
    end
  end
  prune(j)
end

function J.Entry(key)
  local j = store()
  return j and j.entries[key or dayKey()]
end

-- "today", "yesterday", "on Tuesday", "on 3 November".
local function whenWords(key)
  if key == dayKey() then return "today" end
  if key == dayKey(1) then return "yesterday" end
  for i = 2, 6 do if key == dayKey(i) then return "on " .. date("%A", U.Now() - i * 86400) end end
  local y, m, dd = key:match("^(%d+)-(%d+)-(%d+)$")
  if y and time then
    local t = time({ year = tonumber(y), month = tonumber(m), day = tonumber(dd), hour = 12 })
    return "on " .. tostring(tonumber(dd)) .. " " .. date("%B", t)
  end
  return "on " .. key
end
J.When = whenWords

local function heading(key)
  local y, m, dd = key:match("^(%d+)-(%d+)-(%d+)$")
  if not y or not date then return key end
  local ok, t = pcall(time, { year = tonumber(y), month = tonumber(m), day = tonumber(dd), hour = 12 })
  if not ok or type(t) ~= "number" then return key end
  return date("%A", t) .. ", " .. tostring(tonumber(dd)) .. " " .. date("%B", t)
end
J.Heading = heading

-- Entries newest first: { { key, entry } }.
function J.List()
  local j = store()
  local out = {}
  for k, e in pairs(j and j.entries or {}) do out[#out + 1] = { key = k, entry = e } end
  table.sort(out, function(a, b) return a.key > b.key end)
  return out
end

-- The newest entry within a week, and the first sentence or two of it fit for a public
-- profile (deaths and near misses stay out, as they do from History).
local function latest(maxDays)
  if not ns.db or ns.db.journalInProfile == false then return nil end
  local list = J.List()
  local top = list[1]
  if not top then return nil end
  local fresh = false
  for i = 0, maxDays - 1 do if top.key == dayKey(i) then fresh = true end end
  if not fresh then return nil end
  local picked, len = {}, 0
  for _, l in ipairs(top.entry.lines or {}) do
    if l.kind ~= "death" and l.kind ~= "close" and l.kind ~= "signoff" then
      if #picked >= 2 or (#picked > 0 and len + #l.text > 240) then break end
      picked[#picked + 1] = l.text
      len = len + #l.text
    end
  end
  if #picked == 0 then return nil end
  -- Quest titles inside the quote take single quotes.
  return (table.concat(picked, " "):gsub("\"", "'")), top.key
end

-- For History's last paragraph: one line, or nil. quote: how History quotes words.
function J.LatestLine(quote)
  local text, key = latest(7)
  if not text then return nil end
  local lead = U.Pick(W.JOURNAL.history, seedFor(key, "hist"))
  return fill(lead, { when = whenWords(key) }) .. " " .. (quote and quote(text) or ("\"" .. text .. "\""))
end

-- For the Lately glance when nothing fresher is happening.
function J.LatelyGlance()
  local text, key = latest(2)
  if not text then return nil end
  local first = text:match("^(.-[%.!%?])%s") or text
  local tx = fill(U.Pick(W.JOURNAL.glance, seedFor(key, "glance")), { when = whenWords(key), q = "\"" .. U.Truncate(first, 160) .. "\"" })
  return { TI = "Lately", IC = "INV_Misc_Book_09", TX = U.Pron(U.Cap(tx)) }
end

---------------------------------------------------------------------------
-- /atrp journal and /atrp journal today
---------------------------------------------------------------------------
function J.PrintToday()
  if not inCombat() then J.WriteAll() end
  local e = J.Entry(dayKey())
  if not e then
    ns.Print("Nothing in the journal for today yet. It's written from what happens as you play: lands, jobs, fights, finds and the rest.")
    return
  end
  ns.Print("|cffc8a165" .. heading(dayKey()) .. "|r")
  for para in (e.text .. "\n\n"):gmatch("(.-)\n\n") do if para ~= "" then ns.Print(para) end end
end

function J.Text()
  local out = {}
  for _, it in ipairs(J.List()) do
    out[#out + 1] = "|cffc8a165" .. heading(it.key) .. "|r"
    out[#out + 1] = it.entry.text
    out[#out + 1] = ""
  end
  if #out == 0 then return "|cff808080Nothing written yet. Each day's entry is written from what happens as you play, when you log out or open this.|r" end
  return table.concat(out, "\n")
end

local frame
function J.Show()
  if not inCombat() then J.WriteAll() end
  if not frame then
    local f = CreateFrame("Frame", "AutoTRPJournal", UIParent, "BasicFrameTemplateWithInset")
    f:SetSize(520, 560)
    f:SetPoint("CENTER")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:SetFrameStrata("DIALOG")
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("TOP", 0, -5)
    title:SetText("Auto TRP: journal")
    local scroll = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 12, -32)
    scroll:SetPoint("BOTTOMRIGHT", -32, 44)
    local text = CreateFrame("EditBox", nil, scroll)
    text:SetMultiLine(true)
    text:SetFontObject(ChatFontNormal)
    text:SetWidth(460)
    text:SetAutoFocus(false)
    text:SetScript("OnEscapePressed", function() f:Hide() end)
    text:SetScript("OnTextChanged", function(self, user) if user then self:SetText(f.body or "") end end)
    scroll:SetScrollChild(text)
    f.text = text
    local refresh = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    refresh:SetSize(140, 24)
    refresh:SetPoint("BOTTOMRIGHT", -12, 12)
    refresh:SetText("Write today's now")
    refresh:SetScript("OnClick", function() if not inCombat() then J.WriteAll() end; f.Refresh() end)
    function f.Refresh()
      f.body = J.Text()
      f.text:SetText(f.body)
      f.text:SetCursorPosition(0)
    end
    if UISpecialFrames then tinsert(UISpecialFrames, "AutoTRPJournal") end
    frame = f
  end
  frame.Refresh()
  frame:Show()
end
