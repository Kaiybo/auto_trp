-- The company the character keeps, from the game alone: the group they're in (its size, the
-- classes and races in it, whether they lead it, guildmates and pick-ups, how long they've
-- been together), their pet, their guild, and how much of the road they walk alone.
--
-- Privacy first: other players are never named or stored. Companions are remembered only as
-- a hash of their GUID, so Auto TRP can count familiar faces across sessions without ever
-- knowing who they were. Names are compared only against Social Diary friends, in memory.
-- Nothing is read or recorded in combat; the roster is looked at again once a fight ends.
-- Kept per character in AutoTRPCharDB.company.
local _, ns = ...

local U = ns.U
local Co = {}
ns.Sources = ns.Sources or {}
ns.Sources.Company = Co

Co.KEEP_COMPANIONS = 400   -- the longest unseen are forgotten past this
Co.KEEP_PETS = 12
Co.GROUP_GAP = 1800        -- a group seen again within half an hour is the same outing
Co.GUILD_ROSTER_EVERY = 600

local function store()
  if not ns.char then return nil end
  local st = ns.char.company
  if type(st) ~= "table" then st = {}; ns.char.company = st end
  st.since = tonumber(st.since) or U.Now()
  st.sessions = tonumber(st.sessions) or 0
  st.soloDungeons = tonumber(st.soloDungeons) or 0
  if type(st.time) ~= "table" then st.time = { group = 0, alone = 0 } end
  if type(st.companions) ~= "table" then st.companions = {} end
  if type(st.pets) ~= "table" then st.pets = {} end
  return st
end
Co.Store = store

local function inCombat()
  return U.Call(InCombatLockdown) or U.Call(UnitAffectingCombat, "player")
end

local function grouped()
  return (U.Call(IsInRaid) or U.Call(IsInGroup)) and true or false
end

-- A companion's mark: a salted hash of their GUID. Never their name.
function Co.Mark(guid)
  if type(guid) ~= "string" or guid == "" then return nil end
  return tostring(U.Hash("atrp-company:" .. guid))
end

-- The units of the group other than the player.
local function others()
  local units = {}
  if U.Call(IsInRaid) then
    local n = U.Call(GetNumGroupMembers) or 0
    local me = U.Call(UnitGUID, "player")
    for i = 1, math.min(n, 40) do
      local u = "raid" .. i
      if U.Call(UnitExists, u) then
        local isMe = U.Call(UnitIsUnit, u, "player")
        if isMe == nil and me then isMe = U.Call(UnitGUID, u) == me end
        if not isMe then units[#units + 1] = u end
      end
    end
  else
    for i = 1, 4 do
      local u = "party" .. i
      if U.Call(UnitExists, u) then units[#units + 1] = u end
    end
  end
  return units
end

---------------------------------------------------------------------------
-- Recording (out of combat only)
---------------------------------------------------------------------------
local pendingRoster = false

-- The group changed: start or close an outing, and mark who is in it.
function Co.Roster()
  local st = store()
  if not st then return end
  if inCombat() then pendingRoster = true; return end
  pendingRoster = false
  local now = U.Now()
  if grouped() then
    local g = st.group
    if type(g) ~= "table" or now - (tonumber(g.seen) or 0) > Co.GROUP_GAP then
      st.sessions = st.sessions + 1
      g = { since = now, seen = now, id = st.sessions, size = 0 }
      st.group = g
    end
    g.seen = now
    local list = others()
    g.size = math.max(g.size or 0, #list + 1)
    for _, u in ipairs(list) do
      local mark = Co.Mark(U.Call(UnitGUID, u))
      if mark then
        local rec = st.companions[mark]
        if type(rec) ~= "table" then rec = { n = 0 }; st.companions[mark] = rec end
        if rec.s ~= g.id then rec.n = (rec.n or 0) + 1; rec.s = g.id end
        rec.last = now
      end
    end
    -- Forget the longest unseen when there are too many.
    local count = U.Count(st.companions)
    while count > Co.KEEP_COMPANIONS do
      local oldest, ot
      for k, r in pairs(st.companions) do
        if not ot or (r.last or 0) < ot then oldest, ot = k, r.last or 0 end
      end
      st.companions[oldest] = nil
      count = count - 1
    end
  elseif type(st.group) == "table" then
    st.lastGrouped = st.group.seen or now
    st.lastOuting = (st.group.seen or now) - (st.group.since or now)
    st.group = nil
  end
end

-- Entering an instance: a dungeon entered with nobody along is a solo attempt.
function Co.Entered()
  local st = store()
  if not st or inCombat() then return end
  local inside, kind = U.Call(IsInInstance)
  if not inside or kind ~= "party" then st.inside = nil; return end
  local where = U.Plain(U.Call(GetRealZoneText))
  if st.inside == where then return end
  st.inside = where
  if not grouped() then
    st.soloDungeons = st.soloDungeons + 1
    st.lastSolo = { zone = where, t = U.Now() }
  end
end

-- The pet: first seen, how often it's been called, how often it has fallen.
function Co.NotePet()
  local st = store()
  if not st or not U.Call(UnitExists, "pet") then return nil end
  local name = U.Plain(ns.World.Safe(U.Call(UnitName, "pet")))
  if not name or name == "Unknown" then return nil end
  local now = U.Now()
  local p = st.pets[name]
  if type(p) ~= "table" then
    p = { first = now, n = 0 }
    st.pets[name] = p
  end
  p.kind = U.Plain(ns.World.Safe(U.Call(UnitCreatureFamily, "pet"))) or p.kind
  if now - (p.last or 0) > 600 then p.n = (p.n or 0) + 1 end
  p.last = now
  local count = U.Count(st.pets)
  while count > Co.KEEP_PETS do
    local oldest, ot
    for k, q in pairs(st.pets) do
      if k ~= name and (not ot or (q.last or 0) < ot) then oldest, ot = k, q.last or 0 end
    end
    if not oldest then break end
    st.pets[oldest] = nil
    count = count - 1
  end
  return name, p
end

local petDown = false
function Co.PetHealth()
  local st = store()
  if not st then return end
  local dead = ns.World.Safe(U.Call(UnitIsDeadOrGhost, "pet")) and true or false
  if dead and not petDown then
    local name = U.Plain(ns.World.Safe(U.Call(UnitName, "pet")))
    local p = name and st.pets[name]
    if type(p) == "table" then p.deaths = (p.deaths or 0) + 1 end
  end
  petDown = dead
end

-- The guild: since when, and the rank held.
function Co.NoteGuild(guild, rank)
  local st = store()
  if not st then return end
  if not guild then st.guild = nil; return end
  if type(st.guild) ~= "table" or st.guild.name ~= guild then
    st.guild = { name = guild, since = U.Now() }
  end
  st.guild.rank = rank
end

-- Time grouped and time alone, lightly (the ticker; AFK and resting in town don't count).
function Co.Tick(seconds)
  local st = store()
  if not st then return end
  if U.Call(UnitIsAFK, "player") or U.Call(IsResting) then return end
  if grouped() then
    st.time.group = st.time.group + seconds
    if type(st.group) == "table" then st.group.seen = U.Now() end
  else
    st.time.alone = st.time.alone + seconds
  end
end

local rosterAt = 0
local function askGuildRoster()
  if inCombat() or not U.Call(IsInGuild) then return end
  if U.Now() - rosterAt < Co.GUILD_ROSTER_EVERY then return end
  rosterAt = U.Now()
  local fn = (C_GuildInfo and C_GuildInfo.GuildRoster) or _G.GuildRoster
  U.Call(fn)
end

ns.On("GROUP_ROSTER_UPDATE", function() Co.Roster() end)
ns.On("PLAYER_ENTERING_WORLD", function() Co.Roster(); Co.Entered() end)
ns.On("ZONE_CHANGED_NEW_AREA", function() Co.Entered() end)
ns.On("PLAYER_REGEN_ENABLED", function() if pendingRoster then Co.Roster() end end)
-- A guild change asks again soon, but never more than once a minute: asking for the roster
-- can itself bring PLAYER_GUILD_UPDATE, which must not turn into a loop of requests.
ns.On("PLAYER_GUILD_UPDATE", function()
  rosterAt = math.min(rosterAt, U.Now() - Co.GUILD_ROSTER_EVERY + 60)
  askGuildRoster()
end)
ns.OnUnit("UNIT_PET", "player", function() if not inCombat() then Co.NotePet() end end)
ns.OnUnit("UNIT_HEALTH", "pet", function() Co.PetHealth() end)
ns.Listen("LOGIN", function()
  Co.Roster()
  askGuildRoster()
  ns.Ticker(60, function()
    Co.Tick(60)
    askGuildRoster()
  end)
end)

---------------------------------------------------------------------------
-- Reading: what the company looks like now, for Compose.
---------------------------------------------------------------------------
-- The group as it stands: counts only, never another player's name (except a Social Diary
-- friend's, matched in memory). friendNames: { [name] = true } or nil.
function Co.Group(friendNames)
  if not grouped() then return nil end
  local st = store() or { companions = {} }
  local raid = U.Call(IsInRaid) and true or false
  local g = {
    size = U.Call(GetNumGroupMembers) or 0, raid = raid, classes = {}, classOrder = {}, races = {}, raceOrder = {},
    guildmates = 0, others = 0, familiar = 0, friends = {}, friendClass = {},
  }
  g.lead = U.Call(UnitIsGroupLeader, "player") and true or false
  local myLevel = U.Call(UnitLevel, "player")
  local low, high
  for _, u in ipairs(others()) do
    g.others = g.others + 1
    local name = friendNames and U.Plain(U.Call(UnitName, u))
    local _, class = U.Call(UnitClass, u)
    if name and friendNames[name] then
      g.friends[#g.friends + 1] = name
      if class then g.friendClass[class] = (g.friendClass[class] or 0) + 1 end
    elseif class then
      if not g.classes[class] then g.classOrder[#g.classOrder + 1] = class end
      g.classes[class] = (g.classes[class] or 0) + 1
    end
    local _, race = U.Call(UnitRace, u)
    if race then
      if not g.races[race] then g.raceOrder[#g.raceOrder + 1] = race end
      g.races[race] = (g.races[race] or 0) + 1
    end
    if U.Call(UnitIsInMyGuild, u) then g.guildmates = g.guildmates + 1 end
    local lv = U.Call(UnitLevel, u)
    if type(lv) == "number" and lv > 0 then
      low = (not low or lv < low) and lv or low
      high = (not high or lv > high) and lv or high
    end
    local mark = Co.Mark(U.Call(UnitGUID, u))
    local rec = mark and st.companions[mark]
    if type(rec) == "table" and (rec.n or 0) >= 2 then g.familiar = g.familiar + 1 end
  end
  if g.size < g.others + 1 then g.size = g.others + 1 end
  if type(myLevel) == "number" and low then
    if myLevel <= low - 4 then g.standing = "youngest"
    elseif myLevel >= high + 4 then g.standing = "eldest"
    elseif high - low <= 3 and math.abs(myLevel - low) <= 3 then g.standing = "even" end
  end
  local inside, kind = U.Call(IsInInstance)
  g.battleground = inside and kind == "pvp" or false
  g.dungeon = inside and (kind == "party" or kind == "raid") or false
  if type(st.group) == "table" then g.forSeconds = U.Now() - (st.group.since or U.Now()) end
  return g
end

-- The pet as it stands, with what's been kept about it.
function Co.Pet(world)
  if not world or not world.pet then return nil end
  local st = store()
  local p = st and st.pets[world.pet]
  local lv = U.Call(UnitLevel, "pet")
  local out = { name = world.pet, kind = world.petKind, happy = world.petHappy, level = type(lv) == "number" and lv or nil }
  if type(p) == "table" then
    out.first, out.deaths, out.called = p.first, p.deaths or 0, p.n or 0
  end
  return out
end

-- Every pet kept: { name, kind, first, last, n, deaths }, longest kept first.
function Co.Pets()
  local st = store()
  local out = {}
  for name, p in pairs(st and st.pets or {}) do
    if type(p) == "table" then
      out[#out + 1] = { name = name, kind = p.kind, first = p.first or 0, last = p.last or 0, n = p.n or 0, deaths = p.deaths or 0 }
    end
  end
  table.sort(out, function(a, b) if a.n ~= b.n then return a.n > b.n end return a.name < b.name end)
  return out
end

function Co.Guild(world)
  if not world or not world.guild then return nil end
  local st = store()
  local g = { name = world.guild, rank = world.guildRank }
  local total, _, online = U.Call(GetNumGuildMembers)
  if type(online) ~= "number" then online = nil end
  if type(total) == "number" and total > 0 then g.total = total end
  if online and online > 1 then g.online = online - 1 end   -- not counting themselves
  if st and type(st.guild) == "table" and st.guild.name == world.guild then g.since = st.guild.since end
  return g
end

-- How much of the road they walk alone. share: time grouped of all time counted (nil until
-- there's enough to say); aloneFor: seconds since they were last in a group.
function Co.Solitude()
  local st = store()
  if not st then return {} end
  local out = { soloDungeons = st.soloDungeons, sessions = st.sessions, lastOuting = st.lastOuting }
  local total = st.time.group + st.time.alone
  if total >= 3 * 3600 then out.share = st.time.group / total end
  if not grouped() then
    local from = st.lastGrouped or st.since
    out.aloneFor = U.Now() - from
    out.neverGrouped = st.lastGrouped == nil
  end
  local recurring, week = 0, 0
  local now = U.Now()
  for _, r in pairs(st.companions) do
    if type(r) == "table" then
      if (r.n or 0) >= 2 then recurring = recurring + 1 end
      if now - (r.last or 0) <= 7 * 86400 then week = week + 1 end
    end
  end
  out.recurring, out.week, out.known = recurring, week, U.Count(st.companions)
  return out
end

-- Everything at once, for the cache.
function Co.Read(world, friendNames)
  if not ns.char then return nil end
  -- An outing missed (a reload mid-group) or one that ended unseen: catch up now.
  local st = store()
  if grouped() ~= (type(st.group) == "table") then Co.Roster() end
  if world and world.pet then Co.NotePet() end
  if world then Co.NoteGuild(world.guild, world.guildRank) end
  return {
    group = Co.Group(friendNames),
    pet = Co.Pet(world),
    pets = Co.Pets(),
    guild = Co.Guild(world),
    solitude = Co.Solitude(),
  }
end

-- "a few minutes", "an hour or so", "three days": a stretch of time as a person says it.
function Co.Span(seconds)
  if type(seconds) ~= "number" or seconds < 0 then return nil end
  local m, h, d = seconds / 60, seconds / 3600, seconds / 86400
  if m < 20 then return "a few minutes" end
  if m < 45 then return "half an hour" end
  if h < 1.6 then return "an hour or so" end
  if h < 3.5 then return "a couple of hours" end
  if h < 10 then return "some hours" end
  if d < 1.5 then return "a day" end
  if d < 6.5 then return U.Number(math.floor(d + 0.5)) .. " days" end
  if d < 11 then return "a week" end
  if d < 18 then return "a fortnight" end
  if d < 25 then return "three weeks" end
  if d < 45 then return "a month" end
  if d < 330 then return U.Number(math.floor(d / 30 + 0.5)) .. " months" end
  return "more than a year"
end
