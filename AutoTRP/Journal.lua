-- The journal: a day-by-day account the character "writes" from what actually happened in
-- each play session. It listens to the game itself (no other addon needed): lands entered,
-- jobs turned in, dungeons and their masters, levels, deaths, great finds, the purse, company,
-- inns, flights and crafts. When a session ends (or /atrp journal is run) the day's entry is
-- written in the first person from that record and nothing else; the wording is in
-- Words.lua (W.JOURNAL). Every sentence comes from something recorded. Other players are
-- never named, except the friends you marked in Social Diary (if you let Auto TRP name them).
-- Since 0.22.0 it also draws on what Life, Company, Goals and Mood record as it happens:
-- fish and the best catch, things made, duels, battlegrounds, a new mount, books read, the
-- day's emotes, the pet, the guild, chains moved along, standings, a familiar face, help
-- from others, rolls, jobs given up and a long day; a day worth marking (every tenth level,
-- a first dungeon, death or mount) opens on it, and the first session of a new week looks
-- back on the one before. Wording in Data/JournalWords.lua as well.
-- Kept per character in AutoTRPCharDB.journal: { days = { [date] = log }, entries = { [date] = entry },
-- weeks = { [monday's date] = entry } }.
local _, ns = ...

local U = ns.U
local W = ns.Words
local J = {}
ns.Journal = J

J.KEEP_DAYS = 30     -- entries kept
J.KEEP_LOGS = 3      -- the raw record behind an entry is kept this many days
J.MAX_EVENTS = 150   -- per day; past this only the day's totals keep counting
J.KEEP_WEEKS = 6     -- weekly look-backs kept
J.KINDS = 10         -- named things counted per day (fish, crafts, emotes)

local function store()
  if not ns.char then return nil end
  local j = ns.char.journal
  if type(j) ~= "table" then j = {}; ns.char.journal = j end
  if type(j.days) ~= "table" then j.days = {} end
  if type(j.entries) ~= "table" then j.entries = {} end
  if type(j.weeks) ~= "table" then j.weeks = {} end
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
  keys = {}
  for k in pairs(j.weeks or {}) do keys[#keys + 1] = k end
  table.sort(keys)
  for i = 1, #keys - J.KEEP_WEEKS do j.weeks[keys[i]] = nil end
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
-- A line another part of Auto TRP has for today (Sources/Seasons.lua: an anniversary, a
-- return, a festival): { k = "season", text = "..." }, told with the day's other news.
function J.Note(e)
  if type(e) ~= "table" or type(e.text) ~= "string" then return nil end
  local d = day()
  if d then for _, v in ipairs(d.ev) do if v.k == e.k and v.text == e.text then return nil end end end
  return add(e)
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
    -- The first dungeon of a life seen from the start (Deeds keeps every one entered).
    if (kind == "party" or kind == "raid") and J.WholeLife() then
      local others, mine = 0, nil
      for name, i in pairs(ns.char.deeds and ns.char.deeds.instances or {}) do
        if type(i) == "table" and (i.kind == "party" or i.kind == "raid") then
          if name == e.zone then mine = i else others = others + 1 end
        end
      end
      if others == 0 and (not mine or (mine.visits or 1) <= 1) then e.firstEver = true end
    end
  end
  for _, v in ipairs(d.ev) do if v.k == "zone" and v.zone == e.zone then e.again = true end end
  if e.zone == d.start.zone then e.again = true end
  if e.again then e.first = nil end   -- somewhere already seen today isn't new ground
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
  -- A step in a storyline (Goals' chains), or the job that ends one.
  local chain = W.EARNED_QUEST and W.EARNED_QUEST[title] and title or (W.CHAIN_STEPS and W.CHAIN_STEPS[title])
  local goal = chain and W.CHAIN_GOAL and W.CHAIN_GOAL[chain]
  add({ k = "quest", title = title, zone = d.cur, chain = goal, ends = goal and chain == title or nil })
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
  add({ k = "level", level = level, rank = rank, ms = level % 10 == 0 or nil })
end)

-- Whether Auto TRP has known this character from their first steps (its record began at
-- level 5 or under), so a "first" is really the first.
local function wholeLife()
  local lv = ns.char and ns.char.life and ns.char.life.levels
  local low
  for k in pairs(type(lv) == "table" and lv or {}) do if type(k) == "number" and (not low or k < low) then low = k end end
  return low ~= nil and low <= 5
end
J.WholeLife = wholeLife

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
  -- Deeds has counted it already: the first death of a life Auto TRP has seen from the start.
  local deeds = ns.char and ns.char.deeds
  local first = deeds and tonumber(deeds.deathCount) == 1 and wholeLife() or nil
  local e = add({ k = "death", foe = killer, zone = inside and (U.Plain(U.Call(GetInstanceInfo)) or h.zone) or h.zone,
    sub = not inside and h.sub or nil, first = first })
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
  -- Faces met before (Company's marks, never names), friends aside. Out of combat only.
  local familiar = 0
  local Co = ns.Sources and ns.Sources.Company
  if now and Co and Co.Group and not inCombat() then
    local g = Co.Group(nil)
    familiar = g and g.familiar or 0
  end
  -- A group carried over from yesterday is today's company too.
  local carried = false
  if now and grouped then
    carried = true
    for _, v in ipairs(d.ev) do if v.k == "group" then carried = false; break end end
  end
  if now and (not grouped or carried) then
    local f = friendsHere()
    add({ k = "group", size = size, friends = f, familiar = math.max(0, familiar - #f) })
  elseif now then
    for i = #d.ev, 1, -1 do
      local v = d.ev[i]
      if v.k == "group" then
        v.familiar = math.max(v.familiar or 0, familiar - #(v.friends or {}))
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
  if type(msg) ~= "string" then return end
  local skill, rank = msg:match("^Your skill in (.-) has increased to (%d+)")
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

---------------------------------------------------------------------------
-- More of the day (0.22.0), as the other records take it down. Each is a count or a short
-- event on today's log; every list is capped.
---------------------------------------------------------------------------
local function tally(field)
  local d = day()
  if not d then return nil end
  if type(d[field]) ~= "table" then d[field] = {} end
  return d[field], d
end
local function bumpIn(t, k, n)
  if t[k] then t[k] = t[k] + (n or 1); return end
  if U.Count(t) >= J.KINDS then return end
  t[k] = n or 1
end

-- Fish: how many, of what, and the best of the day (rarer first, then a kind never caught before).
function J.Fish(name, n, q, new)
  local f = tally("fish")
  if not f or not name then return end
  n = n or 1
  f.n = (f.n or 0) + n
  f.kinds = f.kinds or {}
  bumpIn(f.kinds, name, n)
  q = tonumber(q) or 1
  local score = q * 10 + (new and 5 or 0)
  if not f.best or score > (f.best.s or 0) then f.best = { name = name, q = q, new = new or nil, s = score } end
end
function J.Made(item, n, prof)
  local m = tally("made")
  if not m or not item then return end
  m.n = (m.n or 0) + (n or 1)
  m.items = m.items or {}
  bumpIn(m.items, item, n or 1)
  if prof and prof ~= "other" then m.prof = m.prof or {}; bumpIn(m.prof, prof, n or 1) end
end
function J.Duel(won)
  local du = tally("duels")
  if du then if won then du.won = (du.won or 0) + 1 else du.lost = (du.lost or 0) + 1 end end
end
function J.Emote(verb)
  local em = tally("emotes")
  if em and type(verb) == "string" then bumpIn(em, verb:lower(), 1) end
end

-- What the other records hear, passed on. Each wrapped function keeps doing what it did.
local Life = ns.Sources and ns.Sources.Life
if Life then
  local fish, make, duel, battle, kb, mount, page, emote = Life.Fish, Life.Make, Life.Duel, Life.Battle,
    Life.KillingBlow, Life.Mount, Life.Page, Life.Emote
  local function settled()
    local l = ns.char and ns.char.life
    return l and U.Now() - (l.since or U.Now()) > (Life.SETTLE or 3600)
  end
  Life.Fish = function(name, n, q, ...)
    local plain = U.Plain(name)
    local lf = ns.char and ns.char.life and ns.char.life.fish
    local known = plain and lf and lf.byName and lf.byName[plain]
    local ok, b = fish(name, n, q, ...)
    if ok then J.Fish(plain, n, q, not known and settled()) end
    return ok, b
  end
  Life.Make = function(item, n, prof, ...)
    local ok, b = make(item, n, prof, ...)
    if ok then J.Made(U.Plain(item), n, prof) end
    return ok, b
  end
  Life.Duel = function(won, ...)
    local a, b = duel(won, ...)
    J.Duel(won)
    return a, b
  end
  Life.Battle = function(name, won, ...)
    local a, b = battle(name, won, ...)
    if U.Plain(name) then add({ k = "bg", name = U.Plain(name), won = won and true or false }) end
    return a, b
  end
  Life.KillingBlow = function(...)
    local a, b = kb(...)
    local d = day()
    if d then d.kb = (d.kb or 0) + 1 end
    return a, b
  end
  Life.Mount = function(name, ...)
    local ok, b = mount(name, ...)
    local seen = ok and ns.char and ns.char.life and ns.char.life.mounts.seen
    local plain = U.Plain(name)
    local m = seen and plain and seen[plain]
    if m and not m.before then
      local lvl = tonumber((U.Call(UnitLevel, "player"))) or 0
      add({ k = "mount", name = plain, first = (U.Count(seen) == 1 and (wholeLife() or (lvl >= 40 and lvl <= 41))) or nil })
    end
    return ok, b
  end
  Life.Page = function(title, letter, ...)
    local ok, b = page(title, letter, ...)
    if ok and not letter and U.Plain(title) then add({ k = "book", title = U.Plain(title) }) end
    return ok, b
  end
  Life.Emote = function(verb, ...)
    local a, b = emote(verb, ...)
    J.Emote(verb)
    return a, b
  end
end

-- From the mood: help from others, rolls won and lost (no winner named), jobs given up.
local Mood = ns.Mood
if Mood and Mood.Push then
  local push = Mood.Push
  Mood.Push = function(name, amount, why, ...)
    if type(why) == "string" and ns.char then
      if name == "grateful" and why:find("tended") then
        local d = day()
        if d then d.healed = (d.healed or 0) + (tonumber(why:match("^(%d+) people")) or 1) end
      elseif name == "grateful" and why:find("^blessing") then
        local d = day()
        if d then d.blessed = (d.blessed or 0) + (tonumber(why:match("from (%d+) people")) or 1) end
      else
        local item = why:match("^lost the roll for (.+)$")
        if item then add({ k = "roll", item = item, won = false }) end
        item = not item and why:match("^won the roll for (.+)$")
        if item then add({ k = "roll", item = item, won = true }) end
      end
    end
    return push(name, amount, why, ...)
  end
end
if Mood and Mood.Abandoned then
  local abandoned = Mood.Abandoned
  Mood.Abandoned = function(title, ...)
    local t = U.Plain(title)
    if t and ns.char then add({ k = "abandon", title = t }) end
    return abandoned(title, ...)
  end
end

-- The pet: hungry, content again, fallen. By the name the player gave it.
local function petName() return U.Plain(ns.World.Safe(U.Call(UnitName, "pet"))) end
local function petOnce(name, what)
  local d = day()
  if not d or not name then return end
  for _, v in ipairs(d.ev) do if v.k == "pet" and v.name == name and v.what == what and what ~= "died" then return end end
  add({ k = "pet", name = name, what = what })
end
local petHappy
ns.OnUnit("UNIT_HAPPINESS", "pet", function()
  local h = U.Call(GetPetHappiness)
  if type(h) ~= "number" then return end
  if h == 1 and petHappy and petHappy > 1 then petOnce(petName(), "hungry")
  elseif h == 3 and petHappy and petHappy < 3 then petOnce(petName(), "content") end
  petHappy = h
end)
local Co = ns.Sources and ns.Sources.Company
if Co and Co.PetHealth then
  local health = Co.PetHealth
  Co.PetHealth = function(...)
    local name = petName()
    local pets = ns.char and ns.char.company and ns.char.company.pets
    local before = name and pets and type(pets[name]) == "table" and (pets[name].deaths or 0)
    local a, b = health(...)
    local after = name and pets and type(pets[name]) == "table" and (pets[name].deaths or 0)
    if before and after and after > before then petOnce(name, "died") end
    return a, b
  end
end

-- A standing earned (Friendly and up), as the game announces it.
local STANDING = { Friendly = "friendly", Honored = "honoured", Revered = "revered", Exalted = "exalted" }
ns.On("CHAT_MSG_COMBAT_FACTION_CHANGE", function(_, msg)
  msg = ns.World.Safe(msg)
  if type(msg) ~= "string" then return end
  local word, faction = msg:match("^You are now (%a+) with (.-)%.?$")
  faction = U.Plain(faction)
  if not word or not STANDING[word] or not faction then return end
  add({ k = "standing", word = STANDING[word], faction = faction })
end)

-- The guild: joined, left, or a new rank in it. The first look only notes where things stand.
function J.Guild()
  local j = store()
  if not j or inCombat() then return end
  local name, rank, index = U.Call(GetGuildInfo, "player")
  name, rank = U.Plain(name), U.Plain(rank)
  local inGuild = U.Call(IsInGuild) and true or false
  if inGuild and not name then return end   -- not loaded yet
  local was = j.guild
  j.guild = name and { name = name, rank = rank, index = tonumber(index) } or false
  if was == nil then return end
  if name and (not was or was.name ~= name) then add({ k = "guild", what = "join", guild = name })
  elseif not name and was and not inGuild then add({ k = "guild", what = "left", guild = was.name })
  elseif name and was and rank and was.rank ~= rank and tonumber(index) and was.index and tonumber(index) < was.index then
    add({ k = "guild", what = "rank", guild = name, rank = rank })
  end
end
ns.On("PLAYER_GUILD_UPDATE", function() J.Guild() end)

-- A session begins: the purse's starting point, and where the day picks up.
local started = false
local sessionStart
ns.On("PLAYER_ENTERING_WORLD", function()
  if not ns.char then return end
  if not started then
    started = true
    sessionStart = U.Now()
    lastMoney = U.Call(GetMoney)
    grouped = (U.Call(IsInGroup) or U.Call(IsInRaid)) and true or false
    local d = day()
    if d then d.sessions = (d.sessions or 0) + 1 end
    J.Guild()
    if not inCombat() then J.WeekDue() end
  end
  J.Zone()
end)
-- The longest stretch played in one go today.
local function noteSession(d)
  if d and sessionStart then d.longest = math.max(d.longest or 0, U.Now() - math.max(sessionStart, d.first or 0)) end
end

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

-- A line from a list, filled in: the text, and the line as written (to know its subject).
local function pick(list, key, tag, vars)
  local line = U.Pick(list, seedFor(key, tag))
  if type(line) ~= "string" then return nil end
  return fill(line, vars or {}), line
end

-- "I'll" and "Light" keep their capitals mid-sentence; other first words are lowered.
local KEEP_CAP = { I = true, ["I'll"] = true, ["I'm"] = true, ["I've"] = true, ["I'd"] = true, Light = true, Elune = true }
local function lower(s)
  local w = s:match("^([%a']+)")
  if w and (KEEP_CAP[w] or w:find("^%u%u")) then return s end
  return (s:gsub("^%u", string.lower))
end

local function article(word) return (word:lower():match("^[aeiou]") and "an " or "a ") .. word end
-- An item as a person names one: "a Linen Bandage", but "Heavy Linen Gloves".
local function itemWord(name)
  if name:find("[^s]s$") then return name end
  return article(name)
end

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
  return best, n
end

-- Who is writing: their temperament (RPG Dialogue's, or Auto TRP's own reading through
-- Compose.Persona), their race and their class.
local function writer()
  local rpgd = ns.Compose and ns.cache and ns.Compose.Persona(ns.cache)
  local race = select(2, U.Call(UnitRace, "player"))
  if race == "Undead" then race = "Scourge" end
  return { traits = rpgd and rpgd.dominant or {}, race = race, class = select(2, U.Call(UnitClass, "player")) }
end
-- How the character takes things: the pools to look in, most particular first.
local function temperKeys()
  local w, keys = writer(), {}
  for _, t in ipairs(w.traits) do keys[#keys + 1] = t end
  if w.race then keys[#keys + 1] = w.race end
  if w.class then keys[#keys + 1] = w.class end
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
J.Writer = writer

local function joinClauses(list)
  if #list == 0 then return nil end
  if #list == 1 then return list[1] end
  local out = list[1]
  for i = 2, #list do out = out .. (i == #list and ", and " or ", ") .. lower(list[i]) end
  return out
end

-- Whether a line brings its own subject ("I...", "There was...", "{pet} went..."): one that
-- doesn't can't follow one that does after "and".
local OWN = { I = true, ["I'm"] = true, ["I've"] = true, ["I'd"] = true, ["I'll"] = true, My = true, There = true, It = true,
  A = true, An = true, The = true, Someone = true, Somebody = true, Another = true, Some = true, Not = true, No = true,
  Nothing = true, Plenty = true, Much = true, Most = true, Others = true, One = true, Our = true, We = true }
local function bit(text, template)
  if not text then return nil end
  local w = template and template:match("^([%a']+)")
  local proper = template and template:find("^{") ~= nil
  return { text = text, own = proper or (w and OWN[w]) or false, proper = proper }
end

-- Days as numbers (days since 1 January 1970), worked out by hand so they never depend on
-- the client's clock functions; weeks start on a Monday.
local WEEKDAYS = { "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" }
local MONTHS = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October",
  "November", "December" }
local function daysOf(key)
  local y, m, d = tostring(key or ""):match("^(%d+)-(%d+)-(%d+)$")
  y, m, d = tonumber(y), tonumber(m), tonumber(d)
  if not y then return nil end
  if m <= 2 then y = y - 1 end
  local era = math.floor(y / 400)
  local yoe = y - era * 400
  local doy = math.floor((153 * ((m + 9) % 12) + 2) / 5) + d - 1
  local doe = yoe * 365 + math.floor(yoe / 4) - math.floor(yoe / 100) + doy
  return era * 146097 + doe - 719468
end
local function ymd(z)
  z = z + 719468
  local era = math.floor(z / 146097)
  local doe = z - era * 146097
  local yoe = math.floor((doe - math.floor(doe / 1460) + math.floor(doe / 36524) - math.floor(doe / 146096)) / 365)
  local doy = doe - (365 * yoe + math.floor(yoe / 4) - math.floor(yoe / 100))
  local mp = math.floor((5 * doy + 2) / 153)
  local d = doy - math.floor((153 * mp + 2) / 5) + 1
  local m = mp < 10 and mp + 3 or mp - 9
  return yoe + era * 400 + (m <= 2 and 1 or 0), m, d
end
local function keyOf(z) local y, m, d = ymd(z); return string.format("%04d-%02d-%02d", y, m, d) end
local function weekOf(key) local z = daysOf(key); return z and keyOf(z - (z + 3) % 7) end
local function weekday(key) local z = daysOf(key); return z and WEEKDAYS[(z + 3) % 7 + 1] end
J.WeekOf, J.KeyOf, J.DaysOf = weekOf, keyOf, daysOf

-- How far along the next standing is, from the reputation bars (Goals reads them).
local NEXT_STANDING = { [4] = "friendly", [5] = "honoured", [6] = "revered", [7] = "exalted" }

-- The entry for one day: { text, lines = { { text, kind } }, mood, sum }, or nil if nothing happened.
function J.Compose(key)
  local j = store()
  local d = j and j.days[key]
  if not d then return nil end
  local JW = W.JOURNAL
  local live = key == dayKey()
  if live then
    local h = here()
    d.last = h.zone and h or d.last
    noteSession(d)
  end
  local ev = d.ev
  local lines = {}
  local function line(text, kind) if text and text ~= "" then lines[#lines + 1] = { text = text, kind = kind } end end

  -- Split the day into stretches, one per land in the order entered.
  local function seg(t)
    t.quests, t.chains, t.bosses, t.deaths, t.close, t.inns, t.bgs = {}, {}, {}, {}, {}, {}, {}
    return t
  end
  local segs = { seg({ zone = d.start.zone, start = true }) }
  local misc = { loot = {}, levels = {}, skills = {}, groups = {}, books = {}, mounts = {}, rolls = {}, standings = {},
    guild = {}, pets = {}, abandons = {}, season = {} }
  local ms = {}   -- what makes the day one to mark
  local moved = false
  for _, e in ipairs(ev) do
    local s = segs[#segs]
    if e.k == "zone" then
      moved = true
      segs[#segs + 1] = seg({ zone = e.zone, first = e.first, again = e.again, flew = e.flew, instance = e.instance,
        size = e.size, friends = e.friends })
      if e.firstEver and not ms.dungeon then ms.dungeon = e.zone end
    elseif e.k == "quest" then
      s.quests[#s.quests + 1] = e.title
      if e.chain then s.chains[#s.chains + 1] = e end
    elseif e.k == "boss" then s.bosses[#s.bosses + 1] = e.name; s.bossGroup = s.bossGroup or e.grouped
    elseif e.k == "death" then s.deaths[#s.deaths + 1] = e; if e.first then ms.death = true end
    elseif e.k == "close" then s.close[#s.close + 1] = e
    elseif e.k == "inn" then s.inns[#s.inns + 1] = e.name
    elseif e.k == "bg" then s.bgs[#s.bgs + 1] = e
    elseif e.k == "loot" then misc.loot[#misc.loot + 1] = e
    elseif e.k == "level" then
      misc.levels[#misc.levels + 1] = e
      if e.ms and e.level > (ms.level or 0) then ms.level, ms.rank = e.level, e.rank end
    elseif e.k == "skill" then misc.skills[#misc.skills + 1] = e
    elseif e.k == "group" then misc.groups[#misc.groups + 1] = e
    elseif e.k == "book" then misc.books[#misc.books + 1] = e.title
    elseif e.k == "mount" then misc.mounts[#misc.mounts + 1] = e; if e.first and not ms.mount then ms.mount = e.name end
    elseif e.k == "roll" then misc.rolls[#misc.rolls + 1] = e
    elseif e.k == "standing" then misc.standings[#misc.standings + 1] = e
    elseif e.k == "guild" then misc.guild[#misc.guild + 1] = e
    elseif e.k == "pet" then misc.pets[#misc.pets + 1] = e
    elseif e.k == "abandon" then misc.abandons[#misc.abandons + 1] = e.title
    elseif e.k == "season" then misc.season[#misc.season + 1] = e end
  end
  local fish, made, duels = d.fish or {}, d.made or {}, d.duels or {}
  local busy = #ev > 0 or (fish.n or 0) > 0 or (made.n or 0) > 0 or (duels.won or 0) + (duels.lost or 0) > 0
    or (d.healed or 0) > 0
  if not busy and (d.last.t or 0) - (d.first or 0) < 600 then return nil end

  -- The end of the day, and an inn at the end isn't told twice.
  local last = d.last or d.start
  local finalSeg = segs[#segs]
  if last.inn and last.sub then
    for i = #finalSeg.inns, 1, -1 do if finalSeg.inns[i] == last.sub then table.remove(finalSeg.inns, i) end end
  end

  -- 0. A day to mark opens on it: the top of the climb, a first mount, a first dungeon, a
  -- tenth step of strength, a first death.
  local msKind, rankTold
  do
    local M = JW.milestone
    local function with(a, b)
      local out = {}
      for _, l in ipairs(a or {}) do out[#out + 1] = l end
      for _, l in ipairs(b or {}) do out[#out + 1] = l end
      return out
    end
    local text, tpl
    local rankVars = { rank = ms.rank and article(ms.rank) or nil }
    if ms.level == 60 then
      msKind = "level"
      text, tpl = pick(with(M.level[60], ms.rank and M.level.any), key, "ms60", rankVars)
    elseif ms.mount then
      msKind = "mount"
      text = pick(M.mount, key, "msmount", { mount = ms.mount })
    elseif ms.dungeon then
      msKind = "dungeon"
      text = pick(M.dungeon, key, "msdungeon", { zone = U.Mid(ms.dungeon) })
    elseif ms.level then
      msKind = "level"
      text, tpl = pick(with(M.level[ms.level], ms.rank and M.level.any), key, "mslv" .. ms.level, rankVars)
    elseif ms.death then
      msKind = "death"
      text = pick(M.death, key, "msdeath")
    end
    rankTold = tpl and tpl:find("{rank}", 1, true) ~= nil
    if text then line(U.Cap(text), "milestone") end
  end

  local function hasActs(s) return #s.quests > 0 or #s.bosses > 0 or #s.deaths > 0 or #s.close > 0 or #s.inns > 0 or #s.bgs > 0 end
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
    if s.instance == "pvp" then return pick(s.first and JW.bg_new or JW.bg, key, "bg" .. i .. s.zone, vars) end
    if s.instance == "raid" then return pick(JW.raid, key, "raid" .. s.zone, vars) end
    if s.instance then return pick(s.first and JW.instance_new or JW.instance, key, "inst" .. s.zone, vars) end
    if s.flew then return pick(s.first and JW.flew_new or JW.flew, key, "fly" .. i .. s.zone, vars) end
    if s.first then return pick(JW.arrive_new, key, "new" .. s.zone, vars) end
    if s.again then return pick(JW.arrive_back, key, "back" .. i .. s.zone, vars) end
    return pick(JW.arrive_on, key, "on" .. i .. s.zone, vars)
  end

  -- 1. Where the day started (and whether I woke at an inn), and the road.
  local startPlace = placeOf(d.start) or "where I was"
  local tod = todOf(d.start.hour)
  local todWords = tod and pick(JW.tod[tod], key, "tod1") or "today"
  local pass = {}
  local lastBg
  for i, s in ipairs(segs) do if #s.bgs > 0 then lastBg = i end end
  for i, s in ipairs(segs) do
    local clauses = {}
    local there = " there"
    if s.start then
      local vars = { place = startPlace, zone = U.Mid(d.start.zone or "these parts"), tod = todWords }
      local woke = d.start.inn and d.start.sub
      if moved then
        clauses[1] = pick(woke and JW.open_inn_move or JW.open_move, key, "open", vars)
        there = " before I left"
      else
        clauses[1] = pick(woke and JW.open_inn_stay or JW.open_stay, key, "stay", vars)
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
      clauses[#clauses + 1] = questClause(s, there)
      local c = s.chains[#s.chains]
      if c then clauses[#clauses + 1] = pick(c.ends and JW.chain_end or JW.chain_step, key, "ch" .. c.title, { chain = c.chain }) end
      for _, inn in ipairs(s.inns) do clauses[#clauses + 1] = pick(JW.inn_mid, key, "inn" .. inn, { inn = innName(inn) }) end
      line(joinClauses(clauses), s.start and "open" or "travel")
      -- A battle's outcome, and the blows struck.
      if #s.bgs > 0 then
        local won, lost = 0, 0
        for _, b in ipairs(s.bgs) do if b.won then won = won + 1 else lost = lost + 1 end end
        local text
        if won + lost == 1 then text = pick(won == 1 and JW.bg_won or JW.bg_lost, key, "bgr" .. i)
        elseif won > 0 and lost > 0 then text = pick(JW.bg_mixed, key, "bgm" .. i, { won = U.Number(won), lost = U.Number(lost) })
        else text = pick(won > 0 and JW.bg_won or JW.bg_lost, key, "bgr" .. i) end
        if i == lastBg and (d.kb or 0) > 0 then
          text = text .. ", and " .. lower(pick(JW.kb, key, "kb", { n = U.Number(d.kb) }))
        end
        line(text, "travel")
      end
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

  -- 2. The work of the day: fishing, crafts, books, a new mount, duels, the day's manner.
  local work, extra = {}, {}
  local function put(list, text, template) local b = bit(text, template); if b then list[#list + 1] = b end end
  if (fish.n or 0) > 0 and fish.best then
    local best, top = itemWord(fish.best.name), most(fish.kinds)
    if fish.n == 1 then put(work, pick(JW.fish_one, key, "fish1", { best = best }))
    elseif (fish.best.q or 1) >= 2 or fish.best.new then put(work, pick(JW.fish_best, key, "fishb", { n = U.Number(fish.n), best = best }))
    else put(work, pick(JW.fish_plain, key, "fishp", { n = U.Number(fish.n), top = top or fish.best.name })) end
  end
  if (made.n or 0) > 0 then
    local top = most(made.items)
    local prof = most(made.prof)
    if made.n == 1 and top then put(work, pick(JW.craft_one, key, "craft1", { item = itemWord(top) }))
    elseif prof then put(work, pick(JW.craft_many, key, "craftm", { n = U.Number(made.n), craft = prof:lower(), top = top or "" }))
    else put(work, pick(JW.craft_plain, key, "craftp", { n = U.Number(made.n), top = top or "" })) end
  end
  if #misc.skills > 0 then
    local names = {}
    for i, s in ipairs(misc.skills) do names[i] = s.name:lower() end
    put(work, pick(JW.skill, key, "sk" .. names[1], { list = U.Join(names) }))
  end
  if #misc.books == 1 then put(work, pick(JW.book_one, key, "book1", { title = misc.books[1] }))
  elseif #misc.books > 1 then
    local names = {}
    for i = 1, math.min(3, #misc.books) do names[i] = quoteTitle(misc.books[i]) end
    put(work, pick(JW.book_many, key, "bookn", { list = U.Join(names) }))
  end
  for _, m in ipairs(misc.mounts) do
    if not (msKind == "mount" and m.name == ms.mount) then put(work, pick(JW.mount_new, key, "mnt" .. m.name, { mount = m.name })) end
  end
  local dw, dl = duels.won or 0, duels.lost or 0
  if dw > 0 and dl > 0 then
    put(work, pick(JW.duel_mixed, key, "duelm", { all = U.Number(dw + dl), won = U.Number(dw), lost = U.Number(dl) }))
  elseif dw > 0 then
    put(work, pick(dw == 1 and JW.duel_won_one or JW.duel_won, key, "duelw", { n = U.Number(dw), times = U.Times(dw) }))
  elseif dl > 0 then
    put(work, pick(dl == 1 and JW.duel_lost_one or JW.duel_lost, key, "duell", { n = U.Number(dl), times = U.Times(dl) }))
  end
  do
    local verb, n = most(d.emotes)
    local doing = verb and JW.EMOTE_DOING[verb]
    if doing and n >= 6 then put(work, pick(JW.emote, key, "emote", { doing = doing })) end
  end

  -- 3. Company and fortune: an anniversary, a return or a festival (Sources/Seasons.lua);
  -- groups, faces, help, finds, rolls, growing stronger, standing, the guild, the pet, jobs given up.
  for _, e in ipairs(misc.season) do extra[#extra + 1] = { text = e.text, own = true, proper = true } end
  if #misc.groups > 0 then
    local names, seenName, familiar = {}, {}, 0
    for _, g in ipairs(misc.groups) do
      for _, n in ipairs(g.friends or {}) do if not seenName[n] then seenName[n] = true; names[#names + 1] = n end end
      familiar = math.max(familiar, g.familiar or 0)
    end
    -- A group that only went into a dungeon is told there already.
    local toldInside = false
    for _, s in ipairs(segs) do if s.instance and s.size then toldInside = true end end
    if #names > 0 and not toldInside then
      put(extra, pick(JW.group_friends, key, "gf", { who = U.Join(names) }))
    elseif not toldInside then
      put(extra, pick(#misc.groups > 1 and JW.group_many or JW.group_one, key, "g",
        { times = U.Times(#misc.groups), n = U.Number(#misc.groups) }))
    end
    if familiar == 1 then put(extra, pick(JW.familiar_one, key, "fam"))
    elseif familiar > 1 then put(extra, pick(JW.familiar, key, "fam", { n = U.Number(familiar) })) end
  end
  if (d.healed or 0) == 1 then put(extra, pick(JW.healed, key, "heal"))
  elseif (d.healed or 0) > 1 then put(extra, pick(JW.healed_many, key, "heal", { n = U.Number(d.healed), times = U.Times(d.healed) }))
  elseif (d.blessed or 0) > 0 then put(extra, pick(JW.blessed, key, "bless")) end
  local looted = {}
  for _, l in ipairs(misc.loot) do looted[l.item] = true end
  local rollLost, rollWon
  for _, r in ipairs(misc.rolls) do
    if r.won then rollWon = rollWon or (not looted[r.item] and r.item) or nil else rollLost = rollLost or r.item end
  end
  if rollLost then put(extra, pick(JW.roll_lost, key, "rl" .. rollLost, { item = rollLost })) end
  if rollWon then put(extra, pick(JW.roll_won, key, "rw" .. rollWon, { item = rollWon })) end
  if #misc.loot > 0 then
    local items, best = {}, 0
    for i = 1, math.min(3, #misc.loot) do items[i] = misc.loot[i].item end
    for _, l in ipairs(misc.loot) do best = math.max(best, l.q or 0) end
    put(extra, pick(best >= 4 and JW.loot_epic or JW.loot, key, "loot" .. items[1], { list = U.Join(items) }))
  end
  if #misc.levels > 0 then
    local rank
    for _, l in ipairs(misc.levels) do rank = l.rank or rank end
    local text, tpl
    if #misc.levels > 1 then text, tpl = pick(JW.level_many, key, "lv", { times = U.Times(#misc.levels) })
    else text, tpl = pick(JW.level, key, "lv1") end
    if rank and not rankTold then text = text .. "; " .. lower(pick(JW.rank, key, "rk" .. rank, { rank = article(rank) })) end
    put(extra, text, tpl)
  end
  local st = misc.standings[#misc.standings]
  if st then put(extra, pick(JW.standing, key, "rep" .. st.faction, { standing = st.word, faction = W.FactionName(st.faction) })) end
  for _, g in ipairs(misc.guild) do
    local pool = g.what == "join" and JW.guild_join or g.what == "left" and JW.guild_left or JW.guild_rank
    put(extra, pick(pool, key, "guild" .. g.what, { guild = g.guild, rank = g.rank }))
  end
  do
    local byPet, order = {}, {}
    for _, p in ipairs(misc.pets) do
      local r = byPet[p.name]
      if not r then r = { died = 0 }; byPet[p.name] = r; order[#order + 1] = p.name end
      if p.what == "died" then r.died = r.died + 1 else r[p.what] = true end
    end
    for _, name in ipairs(order) do
      local r = byPet[name]
      if r.died > 1 then put(extra, pick(JW.pet_died_many, key, "petd" .. name, { pet = name, times = U.Times(r.died) }))
      elseif r.died == 1 then put(extra, pick(JW.pet_died, key, "petd" .. name, { pet = name }))
      elseif r.hungry and not r.content then put(extra, pick(JW.pet_hungry, key, "peth" .. name, { pet = name }))
      elseif r.content then put(extra, pick(JW.pet_content, key, "petc" .. name, { pet = name })) end
    end
  end
  if #misc.abandons == 1 then put(extra, pick(JW.abandon_one, key, "ab", { q = misc.abandons[1] }))
  elseif #misc.abandons > 1 then put(extra, pick(JW.abandon_many, key, "ab", { n = U.Number(#misc.abandons), q = misc.abandons[1] })) end

  -- Two short ones share a sentence (one that brings its own subject isn't followed by one
  -- that borrows it).
  local function pour(list, kind)
    local i = 1
    while i <= #list do
      local a, b = list[i], list[i + 1]
      if b and #a.text + #b.text < 110 and not a.text:find(";") and not b.text:find(";") and not (a.own and not b.own) then
        line(a.text .. ", and " .. (b.proper and b.text or lower(b.text)), kind); i = i + 2
      else
        line(a.text, kind); i = i + 1
      end
    end
  end
  pour(work, "work")
  pour(extra, "misc")

  -- 4. Looking ahead (live only: what the game shows now), and how long the day ran.
  if (d.longest or 0) >= 3 * 3600 and ns.Sources.Company and ns.Sources.Company.Span then
    line(pick(JW.long_day, key, "long", { span = ns.Sources.Company.Span(d.longest) }), "ahead")
  end
  if live and not inCombat() then
    local ahead
    local G = ns.Goals
    local closest
    for _, r in ipairs(G and G.Reputations and G.Reputations() or {}) do
      if NEXT_STANDING[r.standing] and r.frac >= 0.85 and (not closest or r.frac > closest.frac) then closest = r end
    end
    if closest then
      ahead = pick(JW.ahead_rep, key, "arep" .. closest.name,
        { faction = W.FactionName(closest.name), standing = NEXT_STANDING[closest.standing] })
    else
      local lvl, xp, max = U.Call(UnitLevel, "player"), U.Call(UnitXP, "player"), U.Call(UnitXPMax, "player")
      if type(lvl) == "number" and lvl < 60 and type(xp) == "number" and type(max) == "number" and max > 0 and xp / max >= 0.85 then
        ahead = pick(JW.ahead_level, key, "alv" .. lvl)
      end
    end
    line(ahead, "ahead")
  end

  -- 5. How the day ended: where, how the character felt, the purse; a feeling that held
  -- all day; a last thought in their own voice.
  local days = ns.char.days or {}
  local moods = days[key] and days[key].moods
  local mood, moodN = most(moods)
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
  local total = 0
  for _, n in pairs(moods or {}) do total = total + n end
  if mood and moodN and moodN >= 4 and moodN / total >= 0.6 then
    local pool = JW.dominant[mood] or (val > 0 and JW.dominant.good) or (val < 0 and JW.dominant.bad)
    if pool then line(pick(pool, key, "dom" .. mood), "mood") end
  end
  -- The last thought: how the day went, in the character's own voice (race first, then
  -- temperament), and now and then a word in their class's manner.
  do
    local w = writer()
    local R = JW.reflect[val > 0 and "good" or val < 0 and "bad" or "calm"]
    local list = {}
    for _, l in ipairs(R.default) do list[#list + 1] = l end
    for _, l in ipairs(R[w.race or ""] or {}) do list[#list + 1] = l; list[#list + 1] = l end
    for _, t in ipairs(w.traits) do
      if JW.reflect_trait[t] then for _, l in ipairs(JW.reflect_trait[t]) do list[#list + 1] = l end; break end
    end
    line(pick(list, key, "reflect"), "reflect")
  end
  if U.Hash(seedFor(key, "sign")) % 3 == 0 then
    local w = writer()
    local list = JW.signoff[w.class or ""] or JW.signoff[w.race or ""]
    if list then line(pick(list, key, "sign"), "signoff") end
  end

  -- Into prose: the road; the work and the company; the close.
  local GROUP = { milestone = 1, open = 1, travel = 1, boss = 1, death = 1, close = 1, work = 2, misc = 3,
    ahead = 3, ["end"] = 4, mood = 4, reflect = 4, signoff = 4 }
  local g = { {}, {}, {}, {} }
  for _, l in ipairs(lines) do
    local s = U.Cap(l.text)
    if not s:find("[%.!%?]\"?$") then s = s .. "." end
    l.text = s
    local n = GROUP[l.kind] or 3
    g[n][#g[n] + 1] = s
  end
  local paras = { table.concat(g[1], " ") }
  local middle = {}
  if #g[2] >= 2 and #g[3] >= 2 then
    paras[#paras + 1] = table.concat(g[2], " ")
    for _, s in ipairs(g[3]) do middle[#middle + 1] = s end
  else
    for _, s in ipairs(g[2]) do middle[#middle + 1] = s end
    for _, s in ipairs(g[3]) do middle[#middle + 1] = s end
  end
  if #middle == 0 and #g[1] <= 2 then
    paras[1] = table.concat(g[1], " ") .. " " .. table.concat(g[4], " ")
  elseif #middle == 1 or (#middle == 0) then
    for _, s in ipairs(g[4]) do middle[#middle + 1] = s end
    paras[#paras + 1] = table.concat(middle, " ")
  else
    paras[#paras + 1] = table.concat(middle, " ")
    paras[#paras + 1] = table.concat(g[4], " ")
  end

  -- What the week's look back needs from the day.
  local sum = { zones = {}, new = {}, q = 0, bosses = {}, deaths = 0, lv = #misc.levels, fish = fish.n or 0, made = made.n or 0,
    books = #misc.books, duels = dw + dl, bg = 0, mood = mood, val = val, ms = msKind }
  local zseen = {}
  for _, s in ipairs(segs) do
    if s.zone and not s.instance and not zseen[s.zone] and #sum.zones < 4 then zseen[s.zone] = true; sum.zones[#sum.zones + 1] = s.zone end
    if s.first and s.zone and not s.instance and #sum.new < 4 then sum.new[#sum.new + 1] = s.zone end
    sum.q = sum.q + #s.quests
    for _, b in ipairs(s.bosses) do if #sum.bosses < 4 then sum.bosses[#sum.bosses + 1] = b end end
    sum.deaths = sum.deaths + #s.deaths
    sum.bg = sum.bg + #s.bgs
  end
  for _, l in ipairs(misc.loot) do if not sum.loot or (l.q or 0) > (sum.lootQ or 0) then sum.loot, sum.lootQ = l.item, l.q end end
  if misc.mounts[1] then sum.mount = misc.mounts[1].name end
  if st then sum.standing = { word = st.word, faction = st.faction } end
  return { text = table.concat(paras, "\n\n"), lines = lines, t = U.Now(), mood = mood, sum = sum }
end

---------------------------------------------------------------------------
-- The week behind: on the first session of a new week, a short look back from the days kept.
---------------------------------------------------------------------------
function J.ComposeWeek(wk)
  local j = store()
  local z0 = daysOf(wk)
  if not j or not z0 then return nil end
  local days = {}
  for i = 0, 6 do
    local k = keyOf(z0 + i)
    local e = j.entries[k]
    if type(e) == "table" and type(e.sum) == "table" then days[#days + 1] = e.sum end
  end
  if #days < 2 then return nil end
  local JW, B = W.JOURNAL.week, W.JOURNAL.week_bits
  local key = "week" .. wk
  local lines = {}
  -- Where: the lands most days were spent in.
  local zc, order = {}, {}
  for _, s in ipairs(days) do
    for _, z in ipairs(s.zones or {}) do if not zc[z] then zc[z] = 0; order[#order + 1] = z end; zc[z] = zc[z] + 1 end
  end
  table.sort(order, function(a, b) if zc[a] ~= zc[b] then return zc[a] > zc[b] end return a < b end)
  local zl = {}
  for i = 1, math.min(3, #order) do zl[i] = U.Mid(order[i]) end
  if #zl > 0 then lines[#lines + 1] = pick(#zl == 1 and JW.open_one or JW.open, key, "open", { zones = U.Join(zl) }) end
  local new, seenNew = {}, {}
  for _, s in ipairs(days) do
    for _, z in ipairs(s.new or {}) do if not seenNew[z] and #new < 4 then seenNew[z] = true; new[#new + 1] = U.Mid(z) end end
  end
  if #new > 0 then lines[#lines + 1] = pick(#new == 1 and JW.new_one or JW.new, key, "new", { list = U.Join(new) }) end
  -- What mattered, counted.
  local t = { q = 0, lv = 0, deaths = 0, fish = 0, made = 0, books = 0, bg = 0, duels = 0 }
  local bosses, bseen, loot, lootQ, mount, standing = {}, {}, nil, 0, nil, nil
  for _, s in ipairs(days) do
    for k in pairs(t) do t[k] = t[k] + (tonumber(s[k]) or 0) end
    for _, b in ipairs(s.bosses or {}) do if not bseen[b] and #bosses < 3 then bseen[b] = true; bosses[#bosses + 1] = b end end
    if s.loot and (s.lootQ or 0) > lootQ then loot, lootQ = s.loot, s.lootQ or 0 end
    mount = s.mount or mount
    standing = s.standing or standing
  end
  local bits = {}
  local function b(list, tag, vars) if #bits < 6 then bits[#bits + 1] = pick(list, key, tag, vars) end end
  if #bosses > 0 then b(B.bosses, "b", { list = U.Join(bosses) }) end
  if t.lv == 1 then b(B.level_one, "lv") elseif t.lv > 1 then b(B.levels, "lv", { n = U.Number(t.lv), times = U.Times(t.lv) }) end
  if mount then b(B.mount, "mount", { mount = mount }) end
  if standing then b(B.standing, "rep", { standing = standing.word, faction = W.FactionName(standing.faction) }) end
  if loot then b(B.loot, "loot", { item = loot }) end
  if t.q == 1 then b(B.quest_one, "q") elseif t.q > 1 then b(B.quests, "q", { n = U.Number(t.q) }) end
  if t.bg == 1 then b(B.bg_one, "bg") elseif t.bg > 1 then b(B.bg, "bg", { n = U.Number(t.bg) }) end
  if t.duels == 1 then b(B.duel_one, "du") elseif t.duels > 1 then b(B.duels, "du", { n = U.Number(t.duels) }) end
  if t.fish > 1 then b(B.fish, "fish", { n = U.Number(t.fish) }) end
  if t.made > 1 then b(B.made, "made", { n = U.Number(t.made) }) end
  if t.books == 1 then b(B.book_one, "book") elseif t.books > 1 then b(B.books, "book", { n = U.Number(t.books) }) end
  if t.deaths == 1 then b(B.death_one, "death") elseif t.deaths > 1 then b(B.deaths, "death", { n = U.Number(t.deaths) }) end
  if #bits > 0 then lines[#lines + 1] = pick(JW.deeds, key, "deeds", { list = U.Join(bits) }) end
  -- How it felt: the days' moods.
  local good, bad, moods = 0, 0, {}
  for _, s in ipairs(days) do
    if (s.val or 0) > 0 then good = good + 1 elseif (s.val or 0) < 0 then bad = bad + 1 end
    if s.mood then moods[s.mood] = (moods[s.mood] or 0) + 1 end
  end
  local how = (good >= 2 and good > bad * 2) and "good" or (bad >= 2 and bad > good * 2) and "bad"
    or (good > 0 and bad > 0) and "mixed" or "calm"
  lines[#lines + 1] = pick(JW[how], key, "how", { good = U.Number(good), bad = U.Number(bad) })
  local top, topN = most(moods)
  if top and topN >= 2 and W.JOURNAL.feel[top] then
    lines[#lines + 1] = pick(JW.feel, key, "feel", { feel = pick(W.JOURNAL.feel[top], key, "feelw") })
  end
  lines[#lines + 1] = voiced(W.JOURNAL.week_close, key, "close", {})
  local out = {}
  for i, l in ipairs(lines) do
    local s = U.Cap(l)
    if not s:find("[%.!%?]\"?$") then s = s .. "." end
    out[i] = s
  end
  return { text = table.concat(out, " "), t = U.Now(), week = wk, days = #days,
    title = pick(W.JOURNAL.week_title, key, "title") }
end

-- The look back, written once, on the first session of a week after one that was played.
function J.WeekDue()
  local j = store()
  if not j or inCombat() then return nil end
  local z = daysOf(dayKey())
  if not z then return nil end
  local prev = keyOf(z - (z + 3) % 7 - 7)
  if j.weeks[prev] then return nil end
  local e = J.ComposeWeek(prev)
  if e then j.weeks[prev] = e; prune(j) end
  return e
end
function J.Week(wk) local j = store(); return j and j.weeks[wk] end

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
  J.WeekDue()
  prune(j)
end

function J.Entry(key)
  local j = store()
  return j and j.entries[key or dayKey()]
end

-- "Thursday, 26 November" (with the year when it isn't this one).
local function heading(key)
  local z = daysOf(key)
  if not z then return tostring(key) end
  local y, m, dd = ymd(z)
  local ty = ymd(daysOf(dayKey()) or z)
  return WEEKDAYS[(z + 3) % 7 + 1] .. ", " .. tostring(dd) .. " " .. MONTHS[m] .. (y ~= ty and (" " .. tostring(y)) or "")
end
J.Heading = heading

-- "today", "yesterday", "on Tuesday", "on 3 November".
local function whenWords(key)
  if key == dayKey() then return "today" end
  if key == dayKey(1) then return "yesterday" end
  for i = 2, 6 do if key == dayKey(i) then return "on " .. (weekday(key) or key) end end
  local z = daysOf(key)
  if z then local _, m, dd = ymd(z); return "on " .. tostring(dd) .. " " .. MONTHS[m] end
  return "on " .. key
end
J.When = whenWords

-- "the week of 23 November"
local function weekLabel(wk)
  local z = daysOf(wk)
  if not z then return "the week" end
  local _, m, dd = ymd(z)
  return "The week of " .. tostring(dd) .. " " .. MONTHS[m]
end
J.WeekLabel = weekLabel

-- The day's feeling, as the journal shows it beside the date: an icon and a word.
local function moodTag(e, icons)
  local m = e and e.mood and W.MOODS[e.mood]
  if not m or not m.title then return "" end
  local icon = icons ~= false and m.icon and ("|TInterface\\Icons\\" .. m.icon .. ":14:14|t ") or ""
  return "  " .. icon .. "|cff9a9a9a" .. m.title .. "|r"
end
J.MoodTag = moodTag

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
  ns.Print("|cffc8a165" .. heading(dayKey()) .. "|r" .. moodTag(e, false))
  for para in (e.text .. "\n\n"):gmatch("(.-)\n\n") do if para ~= "" then ns.Print(para) end end
end

-- The whole journal, newest first: each week under its own marker, with its look back (when
-- one was written) ahead of its days; each day under its date and its feeling.
function J.Text()
  local j = store()
  local out = {}
  local lastWeek
  for _, it in ipairs(J.List()) do
    local wk = weekOf(it.key)
    if wk ~= lastWeek then
      lastWeek = wk
      if #out > 0 then out[#out + 1] = "" end
      out[#out + 1] = "|cff8a8a8a~  " .. weekLabel(wk) .. "  ~|r"
      local w = j and wk and j.weeks[wk]
      if w then
        out[#out + 1] = "|cffa8b8d8" .. (w.title or "The week behind me") .. "|r"
        out[#out + 1] = "|cffd8d8e8" .. w.text .. "|r"
      end
      out[#out + 1] = ""
    end
    out[#out + 1] = "|cffc8a165" .. heading(it.key) .. "|r" .. moodTag(it.entry)
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
