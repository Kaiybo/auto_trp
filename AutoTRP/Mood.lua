-- How the character feels. A handful of emotions, each with a strength that game events
-- push up and time lets fade, plus a few that simply follow the moment (an inn, a crypt at
-- night, a full tankard). The strongest wins; a close second colours it.
local _, ns = ...

local U = ns.U
local W = ns.Words
local Mood = {}
ns.Mood = Mood

-- Minutes for a pushed emotion to halve.
Mood.HALF_LIFE = {
  shaken = 40, rattled = 15, elated = 60, triumphant = 45, satisfied = 20,
  wonder = 30, homecoming = 40, sociable = 20, intrigued = 90,
}
Mood.THRESHOLD = 15
Mood.TICK = 30

local function state() return ns.char.mood end

local function decayed(name, v, dt)
  local hl = Mood.HALF_LIFE[name]
  if not hl or dt <= 0 then return v end
  return v * 0.5 ^ (dt / (hl * 60))
end

-- Brings stored emotions up to now.
local function settle()
  local st, now = state(), U.Now()
  local dt = now - (st.t or now)
  for name, v in pairs(st.emo) do
    local nv = decayed(name, v, dt)
    st.emo[name] = nv >= 1 and nv or nil
  end
  st.t = now
end

-- Temperament bends how hard things land.
local function temperament(name, amount)
  local rpgd = ns.cache and ns.cache.rpgd
  local traits = rpgd and rpgd.traits or {}
  local brave, cautious = traits.brave or 0, traits.cautious or 0
  if (name == "shaken" or name == "rattled") then
    if brave >= 3 then amount = amount * 0.7 end
    if cautious >= 3 then amount = amount * 1.2 end
  end
  if name == "wonder" and (traits.curious or 0) >= 3 then amount = amount * 1.3 end
  if name == "sociable" and (traits.reserved or 0) >= 3 then amount = amount * 0.6 end
  return amount
end

function Mood.Push(name, amount)
  if not ns.char then return end
  settle()
  local st = state()
  st.emo[name] = U.Clamp((st.emo[name] or 0) + temperament(name, amount), 0, 100)
  ns.Fire("MOOD_CHANGED", name)
end

-- Scores right now: stored (decayed) plus the ones that follow the moment.
function Mood.Scores(world)
  settle()
  local st, now = state(), U.Now()
  local s = {}
  for name, v in pairs(st.emo) do s[name] = v end
  world = world or ns.World.Snapshot()
  local rpgd = ns.cache and ns.cache.rpgd
  local chron = ns.cache and ns.cache.chronicle

  -- Road-weariness grows after an hour away from rest, and rest takes it away.
  local road = st.road or 0
  s.weary = U.Clamp((road / 3600 - 1) * 25, 0, 80)

  if world.resting and ns.World.IsInn(world.subzone) then
    s.ease = (s.ease or 0) + 35
  elseif world.resting then
    s.ease = (s.ease or 0) + 12
  end
  if world.instance == "party" or world.instance == "raid" then s.tense = (s.tense or 0) + 30 end
  if world.zone and W.EERIE_ZONES[world.zone] and not world.resting then
    s.uneasy = (s.uneasy or 0) + 18 + (world.night and 15 or 0)
  elseif world.night and not world.resting and not world.grouped and not world.instance then
    s.uneasy = (s.uneasy or 0) + 8
  end
  if world.grouped then s.company = (s.company or 0) + 22 end
  local lastSocial = st.lastSocial or now
  if not world.grouped and now - lastSocial > 2 * 3600 then
    s.lonely = U.Clamp((now - lastSocial) / 3600 - 2, 0, 1) * 22
  end

  if rpgd then
    if (rpgd.insanity or 0) > 0 then s.haunted = (s.haunted or 0) + rpgd.insanity * 0.8 end
    if (rpgd.drunk or 0) > 0 and now - (rpgd.drunkAt or 0) < 1800 then
      s.merry = (s.merry or 0) + 30 + 10 * math.min(rpgd.drunk, 3)
    end
  end
  if chron and #chron.goals > 0 then s.determined = (s.determined or 0) + 14 end
  return s
end

local function pick(list, seed)
  return U.Pron(U.Pick(list, seed))
end

-- The mood to show: { key, title, icon, adj, tell, also }
function Mood.Current(world)
  local scores = Mood.Scores(world)
  local ranked = {}
  for name, v in pairs(scores) do
    if W.MOODS[name] and v >= Mood.THRESHOLD then ranked[#ranked + 1] = { name = name, v = v } end
  end
  table.sort(ranked, function(a, b) if a.v ~= b.v then return a.v > b.v end return a.name < b.name end)
  local seed = (ns.char and ns.char.seedName or "") .. math.floor(U.Now() / 3600)
  local def, key
  if ranked[1] then
    key = ranked[1].name
    def = W.MOODS[key]
  else
    local rpgd = ns.cache and ns.cache.rpgd
    key = rpgd and rpgd.dominant and rpgd.dominant[1] or "default"
    def = W.CALM[key] or W.CALM.default
    key = "calm:" .. key
  end
  local out = {
    key = key, title = def.title, icon = def.icon,
    adj = pick(def.adj, seed .. key), tell = pick(def.tells, seed .. key .. "t"),
  }
  local second = ranked[2]
  if second and second.v >= ranked[1].v * 0.6 then
    local d2 = W.MOODS[second.name]
    out.also = pick(d2.adj, seed .. second.name):lower()
    out.alsoKey = second.name
  end
  return out
end

---------------------------------------------------------------------------
-- What moves it
---------------------------------------------------------------------------
local lowest = 1

ns.On("PLAYER_DEAD", function() Mood.Push("shaken", 70) end)
ns.On("PLAYER_LEVEL_UP", function() Mood.Push("elated", 55) end)
ns.On("QUEST_TURNED_IN", function() Mood.Push("satisfied", 18) end)
ns.On("ENCOUNTER_END", function(_, _, _, _, _, success)
  if success == 1 then Mood.Push("triumphant", 60) end
end)
ns.On("PLAYER_REGEN_DISABLED", function() lowest = 1 end)
ns.On("UNIT_HEALTH", function(_, unit)
  if unit ~= "player" then return end
  local hp, max = U.Call(UnitHealth, "player"), U.Call(UnitHealthMax, "player")
  if type(hp) == "number" and type(max) == "number" and max > 0 and hp > 0 then
    lowest = math.min(lowest, hp / max)
  end
end)
ns.On("PLAYER_REGEN_ENABLED", function()
  if U.Call(UnitIsDeadOrGhost, "player") then return end
  if lowest < 0.25 then Mood.Push("rattled", 40) elseif lowest < 0.5 then Mood.Push("rattled", 15) end
  lowest = 1
end)
ns.On("GROUP_ROSTER_UPDATE", function()
  if ns.char and (U.Call(IsInGroup) or U.Call(IsInRaid)) then ns.char.mood.lastSocial = U.Now() end
end)

ns.On("ZONE_CHANGED_NEW_AREA", function()
  if not ns.char then return end
  local zone = U.Plain(U.Call(GetRealZoneText))
  if not zone then return end
  local seen = ns.char.seen
  seen.zones = seen.zones or {}
  local st, now = state(), U.Now()
  if not seen.zones[zone] then
    seen.zones[zone] = now
    -- The first zones of a brand new character are just home, not wonder.
    if U.Count(seen.zones) > 1 then Mood.Push("wonder", 45) end
  end
  local bind = U.Plain(U.Call(GetBindLocation))
  local home = ns.cache and ns.cache.rpgd and ns.cache.rpgd.homeInn
  local isHome = (bind and zone == bind) or (home and zone == home)
  if not isHome and bind then
    -- GetBindLocation is the subzone (an inn's town); the zone holds it when we're there.
    local sub = U.Plain(U.Call(GetSubZoneText))
    isHome = sub == bind
  end
  if isHome and st.awayFrom and now - st.awayFrom > 3600 then Mood.Push("homecoming", 35) end
  if isHome then st.awayFrom = nil elseif not st.awayFrom then st.awayFrom = now end
end)

-- Road-weariness, and watching the other addons for news (a conversation, a story beat,
-- a dungeon cleared).
function Mood.Tick()
  if not ns.char then return end
  local st = state()
  local resting = U.Call(IsResting)
  if resting then
    st.road = math.max(0, (st.road or 0) - Mood.TICK * 6)
  else
    st.road = (st.road or 0) + Mood.TICK
  end
  local rpgd = ns.cache and ns.cache.rpgd
  if rpgd then
    local seen = ns.char.seen
    if seen.conversations and rpgd.conversations > seen.conversations then
      Mood.Push("sociable", math.min(24, (rpgd.conversations - seen.conversations) * 8))
      st.lastSocial = U.Now()
    end
    seen.conversations = rpgd.conversations
    local beats = 0
    for _, t in ipairs(rpgd.threads) do beats = beats + t.beats end
    if seen.beats and beats > seen.beats then Mood.Push("intrigued", 30) end
    seen.beats = beats
    local cleared = #rpgd.cleared
    if seen.cleared and cleared > seen.cleared then Mood.Push("triumphant", 50) end
    seen.cleared = cleared
  end
end

-- Logging out isn't time on the road.
ns.Listen("LOGIN", function()
  local st = state()
  st.t = st.t and st.t > 0 and st.t or U.Now()
  st.lastSocial = st.lastSocial or U.Now()
end)
