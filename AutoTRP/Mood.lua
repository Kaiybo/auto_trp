-- How the character feels. Dozens of small signals feed a few dozen emotions:
--   * events push an emotion up and time lets it fade (a death, a level, a rare drop, an
--     emote you used, a choice in conversation that went against your nature);
--   * the moment adds its own (buffs, sickness, wounds, an inn, enemy land, an empty purse,
--     a festival, a fresh run of deaths).
-- Your RPG Dialogue temperament bends all of it. The strongest feeling wins and a close
-- second colours it. Every score keeps its reasons, which /atrp mood shows.
local _, ns = ...

local U = ns.U
local W = ns.Words
local Mood = {}
ns.Mood = Mood

-- Minutes for a pushed emotion to halve.
Mood.HALF_LIFE = {
  shaken = 40, rattled = 15, elated = 60, triumphant = 45, satisfied = 20, wonder = 30,
  homecoming = 40, sociable = 20, intrigued = 90, sorrowful = 45, angry = 25, smitten = 40,
  devout = 30, merry = 30, ease = 20, thrilled = 40, flush = 60, conflicted = 60, righteous = 45,
  proud = 60, ashamed = 60, newsy = 45, fierce = 10, accomplished = 40, determined = 60,
}
Mood.THRESHOLD = 15
Mood.TICK = 30

local function state()
  local st = ns.char.mood
  st.emo = st.emo or {}
  st.why = st.why or {}
  st.fights = st.fights or {}
  st.quests = st.quests or {}
  return st
end

---------------------------------------------------------------------------
-- Temperament: how hard each feeling lands for this character.
---------------------------------------------------------------------------
local BIAS = {
  brave = { shaken = 0.7, rattled = 0.7, tense = 0.7, fierce = 1.3, frustrated = 1.2 },
  cautious = { shaken = 1.2, tense = 1.3, uneasy = 1.3, fierce = 0.7 },
  kind = { sorrowful = 1.3, conflicted = 1.3, righteous = 1.2, angry = 0.8 },
  cruel = { angry = 1.3, fierce = 1.3, conflicted = 0.5, sorrowful = 0.7 },
  pious = { devout = 1.4, righteous = 1.3, haunted = 0.8, conflicted = 1.2 },
  skeptical = { devout = 0.6, righteous = 0.7, haunted = 0.8 },
  greedy = { flush = 1.4, thrilled = 1.4, worried = 1.4 },
  generous = { worried = 0.7, flush = 0.8, sociable = 1.2 },
  curious = { wonder = 1.3, intrigued = 1.3, newsy = 1.2 },
  witty = { merry = 1.2, frustrated = 0.8 },
  stern = { merry = 0.7, angry = 1.1 },
  charming = { sociable = 1.3, smitten = 1.2, lonely = 1.3 },
  reserved = { sociable = 0.6, lonely = 0.6, company = 0.8 },
}

function Mood.Bias(name)
  local rpgd = ns.cache and ns.cache.rpgd
  local traits = rpgd and rpgd.traits or {}
  local m = 1
  for trait, list in pairs(BIAS) do
    if (traits[trait] or 0) >= 3 and list[name] then m = m * list[name] end
  end
  local world = ns.cache and ns.cache.world
  if world then
    -- Veterans are steadier: harder to shake, harder to impress.
    if (world.level or 1) >= 50 and (name == "shaken" or name == "rattled" or name == "wonder" or name == "tense") then m = m * 0.8 end
    local rb = W.RACE_BIAS[world.race or ""]
    local cb = W.CLASS_BIAS[world.class or ""]
    if rb and rb[name] then m = m * rb[name] end
    if cb and cb[name] then m = m * cb[name] end
  end
  return m
end

---------------------------------------------------------------------------
-- Stored emotions
---------------------------------------------------------------------------
local function decayed(name, v, dt)
  local hl = Mood.HALF_LIFE[name] or 30
  if dt <= 0 then return v end
  return v * 0.5 ^ (dt / (hl * 60))
end

local function settle()
  local st, now = state(), U.Now()
  local dt = now - (st.t or now)
  for name, v in pairs(st.emo) do
    local nv = decayed(name, v, dt)
    if nv >= 1 then st.emo[name] = nv else st.emo[name] = nil; st.why[name] = nil end
  end
  st.t = now
end

-- Pushes an emotion up. why: a few words for /atrp mood ("died in Duskwood").
function Mood.Push(name, amount, why)
  if not ns.char then return end
  settle()
  local st = state()
  st.emo[name] = U.Clamp((st.emo[name] or 0) + amount * Mood.Bias(name), 0, 100)
  if why then st.why[name] = why end
  if amount >= 15 then ns.Fire("MOOD_CHANGED", name) end
end

---------------------------------------------------------------------------
-- The moment
---------------------------------------------------------------------------
local function allDeaths()
  local list = {}
  local c = ns.cache or {}
  local cutoff = U.Now() - 6 * 3600
  for _, d in ipairs(c.rpgd and c.rpgd.deaths or {}) do if d.t >= cutoff then list[#list + 1] = d.t end end
  for _, d in ipairs(c.chronicle and c.chronicle.deaths or {}) do
    if d.t < cutoff then break end   -- Chronicle lists newest first
    local dup = false
    for _, t in ipairs(list) do if math.abs(t - d.t) < 30 then dup = true break end end
    if not dup then list[#list + 1] = d.t end
  end
  return list
end

local function within(list, seconds, now)
  local n = 0
  for _, t in ipairs(list) do if type(t) == "number" and now - t <= seconds then n = n + 1 end end
  return n
end

-- Scores right now, and why. Returns scores, reasons (name -> { text, ... }).
function Mood.Scores(world)
  settle()
  local st, now = state(), U.Now()
  local s, why = {}, {}
  -- Live feelings are bent by temperament here; pushed ones were bent on the way in.
  local function add(name, v, reason, stored)
    if not v or v <= 0 then return end
    if not stored then v = v * Mood.Bias(name) end
    s[name] = (s[name] or 0) + v
    if reason then why[name] = why[name] or {}; table.insert(why[name], U.Pron(reason)) end
  end
  for name, v in pairs(st.emo) do add(name, v, st.why[name], true) end

  world = world or ns.World.Snapshot()
  local c = ns.cache or {}
  local rpgd, chron, sd = c.rpgd, c.chronicle, c.sd
  local auras = world.auras or {}
  local calm = not world.combat and not world.dead

  -- Death: grief settles in after the shock, and a run of them is maddening.
  local deaths = allDeaths()
  local recent = within(deaths, 6 * 3600, now)
  if recent > 0 and not world.dead then
    local fresh = within(deaths, 3600, now) > 0
    add("downcast", 22 + 12 * (recent - 1) + (fresh and 12 or 0), recent == 1 and "died not long ago" or ("died " .. recent .. " times today"))
  end
  local streak = within(deaths, 2 * 3600, now)
  if streak >= 2 then add("frustrated", math.min(60, 22 * (streak - 1)), "keeps dying") end
  if auras.resSick then add("drained", 50, "resurrection sickness") end

  -- What's on them: blessings lift, sickness drags.
  if (auras.worldBuffs or 0) > 0 then add("glorious", 45 + 15 * auras.worldBuffs, "a city's blessing") end
  if (auras.buffs or 0) >= 3 then add("bolstered", math.min(60, 8 + 8 * auras.buffs), auras.buffs .. " blessings and wards") end
  if auras.wellFed then add("fed", 22, "a good meal") end
  if auras.eating or auras.drinking then add("ease", 12, "eating"); add("fed", 15) end
  if calm and (auras.debuffs or 0) > 0 then
    local k = auras.kinds or {}
    add("ailing", 15 + 10 * auras.debuffs + ((k.Disease or k.Poison) and 12 or 0), k.Disease and "diseased" or k.Poison and "poisoned" or "afflicted")
    if k.Curse then add("haunted", 15, "cursed") end
  end

  -- The body
  if calm and world.health and world.health < 0.5 then add("wounded", (0.5 - world.health) * 120, "badly hurt") end
  if calm and world.mana and world.mana < 0.15 and (world.class == "MAGE" or world.class == "PRIEST" or world.class == "WARLOCK") then
    add("weary", 15, "spent")
  end
  if world.xp and world.xp >= 0.9 then add("eager", 20 + (world.xp - 0.9) * 200, "close to something") end
  if (world.level or 99) < 6 then add("wonder", 18, "new to the world") end

  -- The road, rest and company
  local road = st.road or 0
  add("weary", U.Clamp((road / 3600 - 1) * 25, 0, 80), road > 3600 and "long hours on the road" or nil)
  if world.resting and ns.World.IsInn(world.subzone) then add("ease", 35 + (world.rested and 5 or 0), "at an inn")
  elseif world.resting then add("ease", 12, "somewhere safe") end
  if world.grouped then
    add("company", 22, "in a group")
    local friends = 0
    if sd then
      for i = 1, (world.groupSize or 0) do
        local n = U.Call(UnitName, (U.Call(IsInRaid) and "raid" or "party") .. i)
        for _, f in ipairs(sd.friends) do if n and f.name == n then friends = friends + 1 end end
      end
    end
    if friends > 0 then add("elated", 15 + 10 * friends, "with friends") end
  end
  local lastSocial = st.lastSocial or now
  if not world.grouped and now - lastSocial > 2 * 3600 then
    add("lonely", U.Clamp((now - lastSocial) / 3600 - 2, 0, 1) * 22, "alone a long while")
  end
  local fights = within(st.fights, 600, now)
  if fights >= 4 then add("fierce", math.min(50, 8 * fights), fights .. " fights in ten minutes") end
  local quests = within(st.quests, 1800, now)
  if quests >= 3 then add("accomplished", 12 * quests, quests .. " jobs done") end

  -- The place
  if world.instance == "party" or world.instance == "raid" then add("tense", 30, "in a dungeon") end
  if world.instance == "pvp" then add("fierce", 30, "on a battlefield") end
  if not world.instance then
    if world.pvpZone == "hostile" then add("tense", 18, "enemy land")
    elseif world.pvpZone == "sanctuary" then add("ease", 10, "a sanctuary")
    elseif world.pvpZone == "contested" and world.pvpFlag then add("tense", 10, "contested land") end
  end
  if world.stealthed then add("tense", 10, "hiding") end
  if world.zoneKey and W.EERIE_ZONES[world.zoneKey] and not world.resting then
    add("uneasy", 18 + (world.night and 15 or 0), world.night and (world.zone .. " at night") or world.zone)
  elseif world.night and not world.resting and not world.grouped and not world.instance then
    add("uneasy", 8, "alone at night")
  end
  if world.festival and W.FESTIVALS[world.festival] then add("festive", 20, "the season") end

  -- Places that mean something to this race or class (subzone first, then zone).
  for _, list in ipairs(ns.db.reactPlaces and { W.RACE_PLACES[world.race or ""] or false, W.CLASS_PLACES[world.class or ""] or false } or {}) do
    local hit = list and ((world.subzone and list[world.subzone]) or (world.zoneKey and list[world.zoneKey]))
    if hit then add(hit[1], hit[2], hit[3]) end
  end
  local rt = W.RACE_TIME[world.race or ""]
  if rt and not world.indoors and not world.instance then
    local hit = (world.night and rt.night) or (world.dawn and rt.dawn) or (world.dusk and rt.dusk)
    if hit then add(hit[1], hit[2], hit[3]) end
  end
  if world.zoneKey and world.zoneKey == W.CAPITALS[world.race or ""] then add("ease", 15, "among {their} own people") end
  if world.zone and W.ENEMY_CAPITALS[world.faction or ""] and W.ENEMY_CAPITALS[world.faction][world.zoneKey] then
    add("tense", 25, "the enemy's capital")
  end
  if world.petHappy == 1 then add("uneasy", 15, (world.pet or "the pet") .. " is unhappy")
  elseif world.petHappy == 3 then add("ease", 6, (world.pet or "the pet") .. " is happy") end
  local ctx = world.context
  if ctx then
    if ctx.kind == "fishing" then add("ease", 22, "fishing")
    elseif ctx.kind == "craft" then add("satisfied", 15, "at work on a craft")
    elseif ctx.kind == "mail" then add("newsy", 8) end
  end

  -- Purse and pack
  if type(world.money) == "number" and world.level then
    local poor = (world.level ^ 2) * 20
    if world.money < poor then add("worried", 25, "a thin purse") end
  end
  if world.freeSlots and world.freeSlots == 0 then add("burdened", 25, "bags full")
  elseif world.freeSlots and world.freeSlots <= 2 then add("burdened", 12, "bags nearly full") end
  local dur = world.gear and world.gear.durability
  if dur and dur < 0.2 then
    add("weary", 15, "gear falling apart")
    if dur < 0.05 then add("frustrated", 15, "gear broken") end
  end

  -- Inside: drink, madness, taint, purpose
  if rpgd then
    if (rpgd.insanity or 0) > 0 then add("haunted", rpgd.insanity * 0.8, "madness") end
    if (rpgd.align.taint or 0) >= 30 then add("haunted", rpgd.align.taint / 3, "a taint") end
    if (rpgd.drunk or 0) > 0 and now - (rpgd.drunkAt or 0) < 1800 then
      add("merry", 30 + 10 * math.min(rpgd.drunk, 3), "drink")
    end
  end
  if chron and #chron.goals > 0 then add("determined", 14, "a goal") end

  return s, why
end

-- A line from a list, among only those the game backs up (see U.Backed).
local function pick(list, seed, world)
  local ok = U.BackedList(list, world)
  if #ok == 0 then return nil end
  return U.Pron(U.Pick(ok, seed))
end

local function def(name, world)
  if name == "festive" and world and W.FESTIVALS[world.festival or ""] then
    local f = W.FESTIVALS[world.festival]
    return { title = f.title, icon = W.MOODS.festive.icon, adj = f.adj, tells = f.tells }
  end
  return W.MOODS[name]
end

-- The mood to show: { key, title, icon, adj, tell, also, reasons }
function Mood.Current(world)
  world = world or (ns.cache and ns.cache.world) or ns.World.Snapshot()
  local scores, why = Mood.Scores(world)
  local st, now = state(), U.Now()
  if st.manual and st.manual.untilT and now < st.manual.untilT and W.MOODS[st.manual.name] then
    scores[st.manual.name] = 1000
    why[st.manual.name] = { "your choice" }
  end
  local ranked = {}
  for name, v in pairs(scores) do
    if W.MOODS[name] and v >= Mood.THRESHOLD then ranked[#ranked + 1] = { name = name, v = v } end
  end
  table.sort(ranked, function(a, b) if a.v ~= b.v then return a.v > b.v end return a.name < b.name end)
  local seed = (ns.char and ns.char.seedName or "") .. math.floor(now / 3600)
  local d, key
  if ranked[1] then
    key = ranked[1].name
    d = def(key, world)
  else
    local rpgd = ns.cache and ns.cache.rpgd
    key = rpgd and rpgd.dominant and rpgd.dominant[1] or "default"
    d = W.CALM[key] or W.CALM.default
    key = "calm:" .. key
  end
  -- A tell from the general list, this race's, or this class's: one of the three.
  -- Only pools with a line the game backs up (no naming a weapon they aren't carrying).
  local pools = {}
  local function pool(list) if #U.BackedList(list, world) > 0 then pools[#pools + 1] = list end end
  pool(d.tells)
  local rt = W.RACE_TELLS[world.race or ""]
  if rt and rt[key] then pool(rt[key]) end
  local ct = W.CLASS_TELLS[world.class or ""]
  if ct and ct[key] then pool(ct[key]) end
  local tell = #pools > 0 and pick(pools[(U.Hash(seed .. key .. "pool") % #pools) + 1], seed .. key .. "t", world)
    or pick(W.CALM.default.tells, seed .. "t", world)
  local adj = pick(d.adj, seed .. key, world)
  -- A feeling from something that happened, mostly worn off now: say it's fading.
  if ranked[1] and st.emo[key] and st.emo[key] >= 0.6 * ranked[1].v and ranked[1].v < 30
    and not adj:find("^Still") and not adj:find("^Not") then
    adj = "Still " .. adj:gsub("^%u", string.lower)
  end
  local out = {
    key = key, title = d.title, icon = d.icon,
    adj = adj, tell = tell,
    reasons = ranked[1] and why[ranked[1].name] or nil, ranked = ranked,
  }
  local second = ranked[2]
  if second and second.v >= ranked[1].v * 0.6 then
    local d2 = def(second.name, world)
    out.also = (pick(d2.adj, seed .. second.name, world) or ""):lower()
    if out.also == "" then out.also = nil end
    out.alsoKey = second.name
  end
  return out
end

-- /atrp feel <mood>: the player decides, for an hour.
function Mood.SetManual(name)
  local st = state()
  if not name then st.manual = nil return true end
  if not W.MOODS[name] then return false end
  st.manual = { name = name, untilT = U.Now() + 3600 }
  return true
end

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------
local lowest, fightStart = 1, nil

local function prune(list, seconds)
  local now = U.Now()
  for i = #list, 1, -1 do if now - list[i] > seconds then table.remove(list, i) end end
end

ns.On("PLAYER_DEAD", function()
  local zone = U.Plain(U.Call(GetRealZoneText))
  Mood.Push("shaken", 70, zone and ("died in " .. zone) or "died")
end)
ns.On("PLAYER_LEVEL_UP", function(_, level)
  Mood.Push("elated", 55, "grew stronger")
  -- A new rank every ten levels: remember where it happened and how it felt.
  level = tonumber(level)
  if not ns.char or not level or (level % 10 ~= 0 and level ~= 60) then return end
  -- The same ladder as the Title (race and faction first), so History and Title agree.
  local who = { class = select(2, U.Call(UnitClass, "player")), race = select(2, U.Call(UnitRace, "player")),
    faction = U.Call(UnitFactionGroup, "player") }
  local ranks = (ns.Compose and ns.Compose.Ranks(who)) or W.RANKS[who.class or ""] or W.RANKS.default
  local band = level >= 60 and 7 or (math.floor(level / 10) + 1)
  ns.char.milestones = ns.char.milestones or {}
  local current = Mood.Current()
  table.insert(ns.char.milestones, {
    level = level, rank = ranks[band], zone = U.Plain(U.Call(GetRealZoneText)), t = U.Now(),
    mood = current and not current.key:find("^calm:") and current.title or nil,
  })
end)
ns.On("QUEST_TURNED_IN", function()
  if not ns.char then return end
  Mood.Push("satisfied", 18, "a job done")
  local st = state()
  table.insert(st.quests, U.Now()); prune(st.quests, 3600)
end)
ns.On("ENCOUNTER_END", function(_, _, name, _, _, success)
  if success == 1 then Mood.Push("triumphant", 60, type(name) == "string" and ("brought down " .. name) or "a great foe fell") end
end)
local foe
ns.On("PLAYER_REGEN_DISABLED", function()
  lowest = 1; fightStart = U.Now()
  foe = nil
  if U.Call(UnitCanAttack, "player", "target") then
    local name = U.Plain(ns.World.Safe(U.Call(UnitName, "target")))
    -- Generic creatures take "a"; players, bosses, rares and elites are named as they are.
    local kind = ns.World.Safe(U.Call(UnitClassification, "target"))
    local named = U.Call(UnitIsPlayer, "target") or (kind and kind ~= "normal" and kind ~= "minus" and kind ~= "trivial")
    foe = name and { name = name, named = named and true or false } or nil
  end
end)
local function onHealth(_, unit)
  if unit == "player" then
    local hp, max = ns.World.Safe(U.Call(UnitHealth, "player")), ns.World.Safe(U.Call(UnitHealthMax, "player"))
    if type(hp) == "number" and type(max) == "number" and max > 0 and hp > 0 then lowest = math.min(lowest, hp / max) end
  elseif type(unit) == "string" and unit:find("^party%d$") then
    -- A companion falls
    ns.partyDead = ns.partyDead or {}
    local dead = ns.World.Safe(U.Call(UnitIsDeadOrGhost, unit)) and true or false
    local name = U.Call(UnitName, unit)
    if dead and name and not ns.partyDead[name] then
      Mood.Push("sorrowful", 18, "watched " .. name .. " fall")
      Mood.Push("angry", 10)
    end
    if name then ns.partyDead[name] = dead end
  end
end
-- A companion falls: a hunter grieves, a warlock is merely put out.
local petDead = false
ns.OnUnit("UNIT_HEALTH", "pet", function()
  local dead = ns.World.Safe(U.Call(UnitIsDeadOrGhost, "pet")) and true or false
  if dead and not petDead then
    local name = U.Plain(ns.World.Safe(U.Call(UnitName, "pet"))) or "the pet"
    local class = select(2, U.Call(UnitClass, "player"))
    if class == "HUNTER" then Mood.Push("sorrowful", 30, name .. " fell")
    elseif class == "WARLOCK" then Mood.Push("frustrated", 10, name .. " was banished back") end
  end
  petDead = dead
end)

-- Only these units: the game filters, so the rest of the world's health bars cost nothing.
for _, u in ipairs({ "player", "party1", "party2", "party3", "party4" }) do ns.OnUnit("UNIT_HEALTH", u, onHealth) end
ns.On("PLAYER_REGEN_ENABLED", function()
  if not ns.char or U.Call(UnitIsDeadOrGhost, "player") then return end
  local st = state()
  table.insert(st.fights, U.Now()); prune(st.fights, 900)
  if lowest < 0.25 then Mood.Push("rattled", 40, "a close call") elseif lowest < 0.5 then Mood.Push("rattled", 15, "a hard fight") end
  if fightStart and U.Now() - fightStart > 45 and lowest >= 0.25 then Mood.Push("triumphant", 15, "won a long fight") end
  -- The fight, for the Lately glance.
  ns.char.lastFight = { foe = foe, t = U.Now(), close = lowest < 0.25, long = fightStart and U.Now() - fightStart > 45 }
  lowest, fightStart, foe = 1, nil, nil
end)
ns.On("GROUP_ROSTER_UPDATE", function()
  if ns.char and (U.Call(IsInGroup) or U.Call(IsInRaid)) then state().lastSocial = U.Now() end
end)

-- Loot: a rare find thrills, an epic one more so.
local QUALITY_HEX = { a335ee = 4, ["0070dd"] = 3, ff8000 = 5 }
ns.On("CHAT_MSG_LOOT", function(_, msg)
  msg = ns.World.Safe(msg)
  if type(msg) ~= "string" or not msg:find("^You ") or msg:find("^You create") then return end
  local q = tonumber(msg:match("|cnIQ(%d+):"))
  if not q then local hex = msg:match("|cff(%x%x%x%x%x%x)"); q = hex and QUALITY_HEX[hex:lower()] end
  local item = msg:match("%[(.-)%]")
  if q and q >= 4 and item and ns.char then
    -- Remember the great finds (the last five).
    ns.char.finds = ns.char.finds or {}
    table.insert(ns.char.finds, { item = item, quality = q, zone = U.Plain(U.Call(GetRealZoneText)), t = U.Now() })
    while #ns.char.finds > 5 do table.remove(ns.char.finds, 1) end
  end
  if q and q >= 4 then Mood.Push("thrilled", 60, item and ("found " .. item) or "a rare find")
  elseif q == 3 then Mood.Push("thrilled", 30, item and ("found " .. item) or "a good find") end
end)

-- Money: a windfall
local lastMoney
ns.On("PLAYER_MONEY", function()
  local m = U.Call(GetMoney)
  if type(m) ~= "number" then return end
  local level = U.Call(UnitLevel, "player") or 1
  if lastMoney and m - lastMoney >= level ^ 2 * 25 then Mood.Push("flush", 35, "came into money") end
  lastMoney = m
end)

-- Duels: "X has defeated Y in a duel"
ns.On("CHAT_MSG_SYSTEM", function(_, msg)
  msg = ns.World.Safe(msg)
  if type(msg) ~= "string" then return end
  local winner, loser = msg:match("^(.-) has defeated (.-) in a duel")
  if not winner then return end
  local me = U.Call(UnitName, "player")
  me = type(me) == "string" and me:match("^(%S+)") or me
  winner, loser = winner:match("^(%S+)") or winner, loser:match("^(%S+)") or loser
  if winner == me then Mood.Push("proud", 35, "won a duel against " .. loser)
  elseif loser == me then Mood.Push("frustrated", 25, "lost a duel to " .. winner) end
end)

-- Reputation: rising, falling, a new standing (remembered for History).
-- Reputation: a gentle push at most once per faction every half hour (never from the
-- endless ticks inside a dungeon); reaching a new standing is a big moment, remembered.
local repAt = {}
local STANDINGS = { Honored = true, Revered = true, Exalted = true }
local function standing(msg)
  local word, faction = msg:match("^You are now (%a+) with (.-)%.?$")
  if not word or not STANDINGS[word] or not ns.char then return false end
  Mood.Push("proud", word == "Exalted" and 50 or 30, word:lower() .. " with " .. faction)
  ns.char.honours = ns.char.honours or {}
  table.insert(ns.char.honours, { standing = word, faction = faction, t = U.Now(), zone = U.Plain(U.Call(GetRealZoneText)) })
  while #ns.char.honours > 6 do table.remove(ns.char.honours, 1) end
  return true
end
ns.On("CHAT_MSG_COMBAT_FACTION_CHANGE", function(_, msg)
  msg = ns.World.Safe(msg)
  if type(msg) ~= "string" or standing(msg) then return end
  if U.Call(IsInInstance) then return end
  local up = msg:match("^Reputation with (.-) increased")
  local down = msg:match("^Reputation with (.-) decreased")
  local faction = up or down
  if not faction then return end
  local now = U.Now()
  if repAt[faction] and now - repAt[faction] < 1800 then return end
  repAt[faction] = now
  if up then Mood.Push("proud", 10, "standing with " .. faction) else Mood.Push("ashamed", 12, "lost standing with " .. faction) end
end)
ns.On("CHAT_MSG_SYSTEM", function(_, msg)
  msg = ns.World.Safe(msg)
  if type(msg) == "string" then standing(msg) end
end)
-- A new home: noticed by the hearthstone's bind point changing (works in any language).
local boundTo
function Mood.CheckHome()
  local bind = U.Plain(U.Call(GetBindLocation))
  if bind and boundTo and bind ~= boundTo then Mood.Push("homecoming", 25, "made " .. bind .. " home") end
  boundTo = bind or boundTo
end
ns.On("LEARNED_SPELL_IN_TAB", function() Mood.Push("satisfied", 10, "learned something new") end)
ns.On("LEARNED_SPELL_IN_SKILL_LINE", function() Mood.Push("satisfied", 10, "learned something new") end)
ns.On("CHAT_MSG_LOOT", function(_, msg)
  msg = ns.World.Safe(msg)
  local item = type(msg) == "string" and msg:match("^You create: .-%[(.-)%]")
  if item then Mood.Push("satisfied", 8, "made " .. item) end
end)

ns.On("CHAT_MSG_SKILL", function() Mood.Push("satisfied", 8, "getting better at a craft") end)

-- Emotes the player uses.
ns.On("CHAT_MSG_TEXT_EMOTE", function(_, msg, sender)
  msg = ns.World.Safe(msg)
  if type(msg) ~= "string" then return end
  local me = U.Call(UnitName, "player")
  sender = ns.World.Safe(sender)
  if not (msg:find("^You ") or (type(sender) == "string" and me and sender:match("^[^%-]+") == me)) then return end
  local lower = msg:lower()
  for name, verbs in pairs(W.EMOTES) do
    for _, v in ipairs(verbs) do
      if lower:find("^you " .. v) then
        if name == "ease" then state().road = math.max(0, (state().road or 0) - 1800) end
        Mood.Push(name, 35, "you " .. v)
        return
      end
    end
  end
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
    if U.Count(seen.zones) > 1 then Mood.Push("wonder", 45, "first time in " .. zone) end
  end
  local bind = U.Plain(U.Call(GetBindLocation))
  local home = ns.cache and ns.cache.rpgd and ns.cache.rpgd.homeInn
  local sub = U.Plain(U.Call(GetSubZoneText))
  local isHome = (bind and (zone == bind or sub == bind)) or (home and (zone == home or sub == home))
  if isHome and st.awayFrom and now - st.awayFrom > 3600 then Mood.Push("homecoming", 35, "home again") end
  if isHome then st.awayFrom = nil elseif not st.awayFrom then st.awayFrom = now end
end)

-- Running into people you know (Social Diary friends and foes), at most once every half hour
-- per person. Only your target: cheap, and only someone you chose to look at.
local metAt = {}
ns.On("PLAYER_TARGET_CHANGED", function()
  if not ns.db.reactPeople or not U.Call(UnitIsPlayer, "target") then return end
  local name = ns.World.Safe(U.Call(UnitName, "target"))
  if type(name) ~= "string" then return end
  local now = U.Now()
  if metAt[name] and now - metAt[name] < 1800 then return end
  local sd = ns.cache and ns.cache.sd
  for _, f in ipairs(sd and sd.friends or {}) do
    if f.name == name then metAt[name] = now; Mood.Push("elated", 20, "ran into " .. name) return end
  end
  for _, f in ipairs(sd and sd.foes or {}) do
    if f.name == name then metAt[name] = now; Mood.Push("angry", 20, "crossed paths with " .. name) return end
  end
  -- Someone of the other faction (not a duel partner of your own).
  local theirs, mine = ns.World.Safe(U.Call(UnitFactionGroup, "target")), ns.World.Safe(U.Call(UnitFactionGroup, "player"))
  if type(theirs) == "string" and type(mine) == "string" and theirs ~= mine and theirs ~= "Neutral" then
    metAt[name] = now
    local race = ns.World.Safe(U.Call(UnitRace, "target"))
    Mood.Push("tense", 15, "face to face with " .. (type(race) == "string" and ("an enemy " .. race:lower()) or "the enemy"))
  end
end)

ns.On("ZONE_CHANGED", function()
  if not ns.char then return end
  local sub = U.Plain(U.Call(GetSubZoneText))
  if not sub then return end
  local seen = ns.char.seen
  seen.places = seen.places or {}
  if not seen.places[sub] then
    seen.places[sub] = U.Now()
    if U.Count(seen.places) > 3 then Mood.Push("wonder", 10, "found " .. sub) end
  end
end)

---------------------------------------------------------------------------
-- Every tick: road-weariness, and news from the other addons.
---------------------------------------------------------------------------
local function sumAffinity(rpgd)
  local n = 0
  for _, f in ipairs(rpgd.friends) do n = n + f.affinity end
  for _, f in ipairs(rpgd.rivals) do n = n + f.affinity end
  return n
end

local function sumStanding(rpgd)
  local n = 0
  for _, t in ipairs(rpgd.towns) do n = n + t.value end
  return n
end

-- Compares a number with what it was last tick and calls back on a change.
local function watch(seen, key, value, onChange)
  if value == nil then return end
  local before = seen[key]
  seen[key] = value
  if before ~= nil and value ~= before then onChange(value - before) end
end

-- Time on the road (called by the ticker only).
function Mood.Road(seconds)
  if not ns.char then return end
  local st = state()
  if U.Call(IsResting) then
    st.road = math.max(0, (st.road or 0) - seconds * 6)
  else
    st.road = (st.road or 0) + seconds
  end
end

function Mood.Tick()
  Mood.Road(Mood.TICK)
  Mood.Watch()
end

-- News from the other addons since last time (safe to call any time).
function Mood.Watch()
  if not ns.char then return end
  local st = state()
  local seen = ns.char.seen
  local rpgd = ns.cache and ns.cache.rpgd
  if rpgd then
    watch(seen, "conversations", rpgd.conversations, function(d)
      if d > 0 then Mood.Push("sociable", math.min(24, d * 8), "talking with people"); st.lastSocial = U.Now() end
    end)
    local beats = 0
    for _, t in ipairs(rpgd.threads) do beats = beats + t.beats end
    watch(seen, "beats", beats, function(d) if d > 0 then Mood.Push("intrigued", 30, "heard something that matters") end end)
    watch(seen, "cleared", #rpgd.cleared, function(d) if d > 0 then Mood.Push("triumphant", 50, "cleared " .. U.Mid(rpgd.cleared[1].name)) end end)
    watch(seen, "light", math.floor(rpgd.align.light), function(d)
      if d <= -2 then Mood.Push("conflicted", 30, "did something dark") elseif d >= 2 then Mood.Push("righteous", 25, "did the right thing") end
    end)
    watch(seen, "honor", math.floor(rpgd.align.honor), function(d)
      if d <= -2 then Mood.Push("conflicted", 20, "told a lie") end
    end)
    watch(seen, "affinity", sumAffinity(rpgd), function(d)
      if d > 0 then Mood.Push("sociable", 10, "made a friend") elseif d < 0 then Mood.Push("angry", 12, "a falling-out") end
    end)
    watch(seen, "standing", math.floor(sumStanding(rpgd)), function(d)
      if d >= 3 then Mood.Push("proud", 30, "earned some goodwill") elseif d <= -3 then Mood.Push("ashamed", 30, "lost some goodwill") end
    end)
    watch(seen, "letters", rpgd.lettersArrived, function(d) if d > 0 then Mood.Push("newsy", 35, "a letter came") end end)
    watch(seen, "lies", rpgd.liesExposed, function(d) if d > 0 then Mood.Push("ashamed", 35, "caught in a lie") end end)
    watch(seen, "deathsRPGD", rpgd.deathCount, function() end)
  end
  local chron = ns.cache and ns.cache.chronicle
  if chron then
    watch(seen, "goalsDone", chron.goalsDone, function(d) if d > 0 then Mood.Push("elated", 40, "reached a goal") end end)
    watch(seen, "rares", chron.rares, function(d) if d > 0 then Mood.Push("thrilled", 25, "spotted a rare beast") end end)
  end
  -- A name earned: proud, and a quiet line in your own chat (never sent to anyone).
  if ns.Compose and ns.Compose.NoticeNames then
    for _, e in ipairs(ns.Compose.NoticeNames()) do
      Mood.Push("proud", 40, "came to be called " .. e.nick)
      if not ns.db.quiet then
        local worn = ns.Compose.Earned()
        local still = worn and worn.key ~= e.key and (" You still go by \"" .. worn.nick .. "\"; |cffffd100/atrp names|r to choose.") or ""
        ns.Print("|cffd0d0ffA name has stuck: \"" .. e.nick .. "\" (" .. e.deed:gsub("^%u", string.lower) .. ")."
          .. (e.motto and (" The saying that came with it: \"" .. e.motto .. "\"") or "") .. "|r" .. still)
      end
    end
  end
end

ns.Listen("LOGIN", function()
  local st = state()
  st.t = st.t and st.t > 0 and st.t or U.Now()
  st.lastSocial = st.lastSocial or U.Now()
  lastMoney = U.Call(GetMoney)
end)

---------------------------------------------------------------------------
-- The mood journal: each real day's feelings and places, kept for two weeks, so History
-- can say how the last few days have gone.
---------------------------------------------------------------------------
Mood.KEEP_DAYS = 14

local function today(offset)
  local t = U.Now() - (offset or 0) * 86400
  return date and date("%Y-%m-%d", t) or tostring(math.floor(t / 86400))
end
Mood.Day = today

function Mood.Log(current, world)
  if not ns.char or not current then return end
  ns.char.days = ns.char.days or {}
  local days = ns.char.days
  local key = today()
  local d = days[key]
  if not d then
    d = { moods = {}, zones = {} }
    days[key] = d
    -- Forget the oldest days.
    local list = {}
    for k in pairs(days) do list[#list + 1] = k end
    table.sort(list)
    for i = 1, #list - Mood.KEEP_DAYS do days[list[i]] = nil end
  end
  if not current.key:find("^calm:") then d.moods[current.key] = (d.moods[current.key] or 0) + 1 end
  if world and world.zone then d.zones[world.zone] = (d.zones[world.zone] or 0) + 1 end
end

local function most(t)
  local best, n
  for k, v in pairs(t or {}) do if not n or v > n or (v == n and k < best) then best, n = k, v end end
  return best
end

-- { { label = "today", mood = "downcast", zone = "Duskwood" }, ... } newest first.
function Mood.RecentDays(count)
  local out = {}
  local days = ns.char and ns.char.days or {}
  local labels = { [0] = "today", [1] = "yesterday", [2] = "the day before" }
  local weekday = { "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" }
  for i = 0, (count or 3) - 1 do
    local d = days[today(i)]
    if d then
      local m = most(d.moods)
      if m or most(d.zones) then
        local wd = date and tonumber(date("%w", U.Now() - i * 86400))
        out[#out + 1] = { label = labels[i] or (wd and ("on " .. weekday[wd + 1])) or (i .. " days ago"), mood = m, zone = most(d.zones) }
      end
    end
  end
  return out
end

-- A quiet line in your own chat when your mood turns (never sent to anyone).
local lastNoteKey, lastNoteAt = nil, 0
function Mood.Note(current)
  if not ns.db or not ns.db.moodNotes or ns.db.quiet or not current then return end
  if current.key:find("^calm:") or current.key == lastNoteKey then return end
  local now = U.Now()
  if lastNoteKey ~= nil and now - lastNoteAt < 300 then return end
  local first = lastNoteKey == nil
  lastNoteKey, lastNoteAt = current.key, now
  if first then return end   -- not on login
  local why = current.reasons and current.reasons[1]
  ns.Print("|cffd0d0ffYou feel " .. current.title:lower() .. (why and (": " .. why) or "") .. ".|r")
end
