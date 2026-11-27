-- Auto TRP's own reading of the character, from what the player actually does in the game,
-- so the profile is just as full with Total RP 3 alone. It keeps counts, never words or
-- names of other players: who you heal is "another player", what you /say is one more line
-- said (its content is never read), a trade is what changed hands, not with whom.
-- From the counts it works out what RPG Dialogue would otherwise give: alignment, traits,
-- standing in the towns you rest in, the people (NPCs) you deal with most, the stories you
-- follow (quest chains and the lands' troubles), the books you read, your first trainer.
-- Read() returns the same shape as Sources/RPGDialogue.lua's, with own = true, so Compose
-- reads either one (Compose.Persona). Kept per character in AutoTRPCharDB.self, bounded.
local _, ns = ...

local U = ns.U
local W = ns.Words
local S = {}
ns.Sources = ns.Sources or {}
ns.Sources.Self = S

S.KEEP_NPCS, S.KEEP_TOWNS, S.KEEP_BOOKS = 40, 30, 60

local COUNTERS = {
  "heals", "strangerHeals", "strangerBuffs", "rez", -- kindness to other players
  "critters", "greyNeutral", "ganks", "raids", -- cruelty: the harmless, the weak, the other side's people
  "hardFights", "easyFights", "pvpFights", "guarding", -- courage, caution, and standing up for a town
  "gifts", "coinGiven", "auctions", "spent", -- generosity and greed
  "prayers", "holyCasts", -- faith
  "says", "emotes", "whispers", "groupedMin", "soloMin", "quietHours", -- company
  "playful", "unsmilingHours", -- humour
  "quests", "abandoned", "pickpockets", -- keeping faith with those who ask
  "talks", "minutes",
}

local function store()
  if not ns.char then return nil end
  local s = ns.char.self
  if type(s) ~= "table" then s = {}; ns.char.self = s end
  s.since = tonumber(s.since) or U.Now()
  if type(s.n) ~= "table" then s.n = {} end
  for _, k in ipairs(COUNTERS) do s.n[k] = tonumber(s.n[k]) or 0 end
  if type(s.towns) ~= "table" then s.towns = {} end
  if type(s.npcs) ~= "table" then s.npcs = {} end
  if type(s.books) ~= "table" then s.books = {} end
  if type(s.origin) ~= "table" then s.origin = {} end
  if type(s.hour) ~= "table" then s.hour = { min = 0 } end
  return s
end
S.Store = store

local function bump(key, by)
  local s = store()
  if s then s.n[key] = (s.n[key] or 0) + (by or 1) end
end
S.Bump = bump

-- Keeps a keyed table to `max` entries, forgetting the least-used (then the oldest).
local function bound(t, max)
  local count, worst, wk = 0, nil, nil
  for k, v in pairs(t) do
    count = count + 1
    local score = (tonumber(v.n) or 0) * 1e10 + (tonumber(v.last) or 0)
    if not worst or score < worst then worst, wk = score, k end
  end
  if count > max and wk then t[wk] = nil end
end

---------------------------------------------------------------------------
-- Where you are: towns are the places you rest in. An inn counts for the town around it.
---------------------------------------------------------------------------
local lastTown
local function isCapital(zone)
  for _, z in pairs(W.CAPITALS or {}) do if z == zone then return true end end
  return false
end
function S.Town()
  if not U.Call(IsResting) then return nil end
  local zone = U.Plain(U.Call(GetRealZoneText))
  local sub = U.Plain(U.Call(GetSubZoneText))
  if not zone then return nil end
  if isCapital(zone) then return zone, zone end
  if sub and sub ~= zone and not ns.World.IsInn(sub) then lastTown = { name = sub, zone = zone }; return sub, zone end
  if lastTown and lastTown.zone == zone then return lastTown.name, zone end
  return W.SELF_INN_TOWN[sub or ""] or zone, zone
end

local function townRec(name, zone)
  local s = store()
  if not s or not name then return nil end
  local t = s.towns[name]
  if not t then
    t = { min = 0, quests = 0, zone = zone, n = 0 }
    s.towns[name] = t
    bound(s.towns, S.KEEP_TOWNS)
  end
  return t
end

---------------------------------------------------------------------------
-- The clock: once a minute, how the minute was spent.
---------------------------------------------------------------------------
-- Flags for the hour so far: anything said, any emote, any company, anything playful.
function S.Tick(seconds)
  local s = store()
  if not s then return end
  local m = (seconds or 60) / 60
  s.n.minutes = s.n.minutes + m
  local grouped = U.Call(IsInGroup) or U.Call(IsInRaid)
  if grouped then s.n.groupedMin = s.n.groupedMin + m; s.hour.grouped = true else s.n.soloMin = s.n.soloMin + m end
  local town, zone = S.Town()
  if town then
    local t = townRec(town, zone)
    t.min = t.min + m; t.last = U.Now(); t.n = math.floor(t.min)
  end
  s.hour.min = (s.hour.min or 0) + m
  if s.hour.min >= 60 then
    if not s.hour.social and not s.hour.grouped then bump("quietHours") end
    if not s.hour.playful then bump("unsmilingHours") end
    s.hour = { min = 0 }
  end
end

---------------------------------------------------------------------------
-- The combat log: only the player's own heals, buffs, resurrections and kills, one test
-- each. Every other line costs one comparison.
---------------------------------------------------------------------------
local PLAYER, OUTSIDER = 0x400, 0x8
local function has(flags, bit)
  return type(flags) == "number" and math.floor(flags / bit) % 2 == 1
end
local WANTED = { SPELL_HEAL = true, SPELL_AURA_APPLIED = true, SPELL_RESURRECT = true }
local me
ns.On("COMBAT_LOG_EVENT_UNFILTERED", function()
  local info = _G.CombatLogGetCurrentEventInfo
  if type(info) ~= "function" then return end
  local _, sub, _, src = info()
  if not WANTED[sub] then return end
  me = me or U.Call(UnitGUID, "player")
  if src ~= me or not me then return end
  local _, _, _, _, _, _, _, dest, _, destFlags, _, _, _, _, auraType = info()
  if dest == me or not has(destFlags, PLAYER) then return end
  local stranger = has(destFlags, OUTSIDER)
  if sub == "SPELL_HEAL" then
    bump(stranger and "strangerHeals" or "heals")
  elseif sub == "SPELL_AURA_APPLIED" then
    if stranger and auraType == "BUFF" then bump("strangerBuffs") end
  else
    bump("rez")
  end
end)

-- Who a fight is against, read once as it starts (out of combat a moment before).
local function greyLevel(level)
  local range = U.Call(_G.GetQuestGreenRange)
  if type(range) == "number" then return level - range - 1 end
  if level < 40 then return level - 5 - math.floor(level / 10) end
  return level - 1 - math.floor(level / 5)
end
function S.FightStarted()
  if not U.Call(UnitExists, "target") or not U.Call(UnitCanAttack, "player", "target") then return end
  local mine = tonumber(U.Call(UnitLevel, "player")) or 1
  local theirs = tonumber(U.Call(UnitLevel, "target"))
  if U.Call(UnitIsPlayer, "target") then
    if theirs and theirs > 0 and theirs <= mine - 10 then bump("ganks") else bump("pvpFights") end
    return
  end
  local myFaction, theirFaction = U.Call(UnitFactionGroup, "player"), U.Call(UnitFactionGroup, "target")
  if theirFaction and myFaction and theirFaction ~= myFaction and theirFaction ~= "Neutral" then bump("raids") end
  if U.Call(UnitCreatureType, "target") == "Critter" then bump("critters"); return end
  local class = U.Call(UnitClassification, "target")
  local elite = class == "elite" or class == "rareelite" or class == "worldboss"
  if theirs == -1 or elite or (theirs and theirs >= mine + 3) then bump("hardFights")
  elseif theirs and theirs <= greyLevel(mine) then
    bump("easyFights")
    if (U.Call(UnitReaction, "target", "player") or 0) >= 4 then bump("greyNeutral") end
  end
  if U.Call(IsResting) and S.Town() then bump("guarding") end
end
ns.On("PLAYER_REGEN_DISABLED", function() S.FightStarted() end)

---------------------------------------------------------------------------
-- The people you deal with: quest-givers, vendors, innkeepers, trainers (NPCs only).
---------------------------------------------------------------------------
local lastNPC, lastNPCAt = nil, 0
function S.MetNPC(kind)
  local guid = U.Call(UnitGUID, "npc")
  if type(guid) ~= "string" or not guid:find("^Creature") or U.Call(UnitIsPlayer, "npc") then return end
  local name = U.Plain(U.Call(UnitName, "npc"))
  if not name then return end
  for _, pat in ipairs(W.SELF_NPC_SKIP) do if name:find(pat) then return end end
  local now = U.Now()
  if name == lastNPC and now - lastNPCAt < 120 then return end   -- one visit, however many windows
  lastNPC, lastNPCAt = name, now
  local s = store()
  if not s then return end
  local zone = U.Plain(U.Call(GetRealZoneText))
  local rec = s.npcs[name]
  if not rec then
    rec = { n = 0, zone = zone, kind = kind }
    s.npcs[name] = rec
    bound(s.npcs, S.KEEP_NPCS)
  end
  rec.n, rec.last, rec.zone = rec.n + 1, now, zone or rec.zone
  if kind == "trainer" then rec.kind = "trainer" end
  bump("talks")
  return name, zone
end
ns.On("GOSSIP_SHOW", function() S.MetNPC("gossip") end)
ns.On("QUEST_DETAIL", function() S.MetNPC("quest") end)
ns.On("QUEST_GREETING", function() S.MetNPC("quest") end)
ns.On("QUEST_COMPLETE", function() S.MetNPC("quest") end)
ns.On("MERCHANT_SHOW", function() S.MetNPC("vendor") end)
-- Class trainers (not crafts): the first one at the very start of the road is where it began.
ns.On("TRAINER_SHOW", function()
  if U.Call(_G.IsTradeskillTrainer) then return end
  local name, zone = S.MetNPC("trainer")
  local s = store()
  if name and s and not s.origin.trainer and (tonumber(U.Call(UnitLevel, "player")) or 99) <= 6 then
    s.origin.trainer, s.origin.trainerZone, s.origin.t = name, zone, U.Now()
  end
end)

---------------------------------------------------------------------------
-- Quests: turned in (and where), and given up on.
---------------------------------------------------------------------------
ns.On("QUEST_TURNED_IN", function()
  bump("quests")
  local town, zone = S.Town()
  if town then local t = townRec(town, zone); t.quests = t.quests + 1; t.last = U.Now() end
end)
if type(_G.hooksecurefunc) == "function" and type(_G.AbandonQuest) == "function" then
  pcall(hooksecurefunc, "AbandonQuest", function() bump("abandoned") end)
end

---------------------------------------------------------------------------
-- Words and gestures: counted, never read. Only the player's own.
---------------------------------------------------------------------------
local function mine(sender)
  local name = U.Call(UnitName, "player")
  return type(sender) == "string" and type(name) == "string" and (sender == name or sender:sub(1, #name + 1) == name .. "-")
end
local function social() local s = store(); if s then s.hour.social = true end end
ns.On("CHAT_MSG_SAY", function(_, _, sender) if mine(sender) then bump("says"); social() end end)
ns.On("CHAT_MSG_YELL", function(_, _, sender) if mine(sender) then bump("says"); social() end end)
ns.On("CHAT_MSG_EMOTE", function(_, _, sender) if mine(sender) then bump("emotes"); social() end end)
ns.On("CHAT_MSG_WHISPER_INFORM", function() bump("whispers"); social() end)
ns.On("CHAT_MSG_TEXT_EMOTE", function(_, msg)
  if type(msg) ~= "string" or not msg:find("^You ") then return end
  bump("emotes"); social()
  local l = msg:lower()
  if l:find("^you pray") then bump("prayers") end
  for _, pat in ipairs(W.SELF_PLAYFUL_EMOTES) do
    if l:find(pat) then bump("playful"); local s = store(); if s then s.hour.playful = true end break end
  end
end)

-- Drink, from the game's own messages; auctions posted.
local drunkLevel = {}
for i = 1, 4 do
  local m = _G["DRUNK_MESSAGE_SELF" .. i]
  if type(m) == "string" then drunkLevel[m] = i - 1 end
end
ns.On("CHAT_MSG_SYSTEM", function(_, msg)
  if type(msg) ~= "string" then return end
  local lvl = drunkLevel[msg]
  if lvl then
    local s = store()
    if s then s.drunk, s.drunkAt = lvl, U.Now() end
  elseif msg == _G.ERR_AUCTION_STARTED then
    bump("auctions")
  end
end)

-- Spells: holy work, toys and fireworks, and picked pockets. Each spell is sorted once.
local spellKind = {}
local function kindOf(spellID)
  local k = spellKind[spellID]
  if k ~= nil then return k end
  local name = (C_Spell and C_Spell.GetSpellName and U.Call(C_Spell.GetSpellName, spellID)) or U.Call(_G.GetSpellInfo, spellID)
  k = false
  if type(name) == "string" then
    if name == "Pick Pocket" then k = "pickpockets"
    elseif W.SELF_PLAYFUL_SPELLS[name] then k = "playful"
    else
      for _, pat in ipairs(W.SELF_HOLY) do if name:find(pat) then k = "holyCasts"; break end end
    end
  end
  spellKind[spellID] = k
  return k
end
ns.OnUnit("UNIT_SPELLCAST_SUCCEEDED", "player", function(_, _, _, spellID)
  if type(spellID) ~= "number" then return end
  local k = kindOf(spellID)
  if not k then return end
  bump(k)
  if k == "playful" then local s = store(); if s then s.hour.playful = true end end
end)

---------------------------------------------------------------------------
-- Coin: what changes hands at a merchant or in a trade.
---------------------------------------------------------------------------
local at, coin = nil, nil
ns.On("MERCHANT_SHOW", function() at = "merchant" end)
ns.On("MERCHANT_CLOSED", function() if at == "merchant" then at = nil end end)
ns.On("PLAYER_MONEY", function()
  local now = U.Call(GetMoney)
  if type(now) ~= "number" then return end
  if coin and at == "merchant" and now < coin then bump("spent", coin - now) end
  coin = now
end)
-- A trade both sides accepted: a gift is something given for nothing back. Who it was with
-- is never kept.
ns.On("TRADE_ACCEPT_UPDATE", function(_, player, target)
  if player ~= 1 or target ~= 1 then return end
  local gave, got = tonumber(U.Call(_G.GetPlayerTradeMoney)) or 0, tonumber(U.Call(_G.GetTargetTradeMoney)) or 0
  local gaveItems, gotItems = 0, 0
  for i = 1, 6 do
    if U.Call(_G.GetTradePlayerItemInfo, i) then gaveItems = gaveItems + 1 end
    if U.Call(_G.GetTradeTargetItemInfo, i) then gotItems = gotItems + 1 end
  end
  if (gave > 0 or gaveItems > 0) and got == 0 and gotItems == 0 then bump("gifts") end
  if gave > got then bump("coinGiven", gave - got) end
end)

---------------------------------------------------------------------------
-- Books: what the character sat down and read. Letters written by players are left out.
---------------------------------------------------------------------------
ns.On("ITEM_TEXT_BEGIN", function()
  local title = U.Plain(U.Call(_G.ItemTextGetItem))
  if not title or W.SELF_NOT_BOOKS[title] or U.Plain(U.Call(_G.ItemTextGetCreator)) then return end
  local s = store()
  if not s then return end
  local b = s.books[title]
  if b then b.n = b.n + 1; b.last = U.Now() return end
  s.books[title] = { n = 1, t = U.Now(), last = U.Now() }
  bound(s.books, S.KEEP_BOOKS)
  if ns.Compose then ns.Compose.SourcesChanged() end
end)

ns.Listen("LOGIN", function()
  store()
  coin = U.Call(GetMoney)
  ns.Ticker(60, function() S.Tick(60) end)
end)

---------------------------------------------------------------------------
-- Reading it: the same shape as RPG Dialogue's, from the counts.
---------------------------------------------------------------------------
-- Points to a trait on RPG Dialogue's scale (1 or 2 a mild lean, 3 and up a defining one).
local function trait(points)
  if points <= 0 then return 0 end
  return math.min(10, math.floor(2 * math.log(1 + points) / math.log(2)))
end
-- A score to an axis on RPG Dialogue's -100..100 scale: steady, never all the way.
local function axis(score, k)
  return math.floor(100 * score / (math.abs(score) + k) + 0.5)
end

-- The town standing on RPG Dialogue's scale: time rested there and jobs done for its people,
-- held back until the town's faction thinks well of you too.
local function standing(t, factions)
  local v = math.floor((t.min or 0) / 20) + 3 * (t.quests or 0)
  local cap = (t.quests or 0) >= 5 and 54 or 29
  local fac = W.SELF_TOWN_FACTION[t.name] or W.SELF_TOWN_FACTION[t.zone or ""]
  local rep = fac and factions[fac]
  if rep and rep >= 6 and (t.quests or 0) >= 5 then cap = rep >= 8 and 100 or rep >= 7 and 79 or 64 end
  return math.min(v, cap)
end

-- Stories: the quest chains and the lands' troubles, from the quests seen through.
local function stories(finished)
  local out, covered = {}, {}
  local now = U.Now()
  for _, st in ipairs(W.SELF_STORIES) do
    local done, last, ended = 0, 0, false
    for _, q in ipairs(st.quests) do
      local f = finished[q]
      if f then done = done + 1; if (f.t or 0) > last then last = f.t or 0 end end
    end
    for _, q in ipairs(st.ends or {}) do
      local f = finished[q]
      if f then ended = true; done = math.max(done, 1); if (f.t or 0) > last then last = f.t or 0 end end
    end
    if done > 0 then
      local state = ended and "resolved" or (now - last <= 30 * 86400 and "unfolding") or nil
      if state then
        out[#out + 1] = { id = "own:" .. st.id, title = st.title, state = state, t = last, beats = done, own = true }
        covered[st.zone] = true
      end
    end
  end
  -- A land where many jobs were done and no chain above tells its story.
  local byZone = {}
  for _, q in pairs(finished) do
    if q.zone then
      local z = byZone[q.zone] or { n = 0, t = 0 }
      z.n, z.t = z.n + 1, math.max(z.t, q.t or 0)
      byZone[q.zone] = z
    end
  end
  for zone, z in pairs(byZone) do
    if z.n >= 6 and not covered[zone] and z.t > 1 and now - z.t <= 30 * 86400 then
      local title = W.SELF_ZONE_STORY[zone] or ("the troubles of " .. U.Mid(zone))
      out[#out + 1] = { id = "own:zone:" .. zone, title = title, state = "unfolding", t = z.t, beats = z.n, own = true }
    end
  end
  table.sort(out, function(a, b) if a.t ~= b.t then return a.t > b.t end return a.id < b.id end)
  return out
end

function S.Read(c)
  local s = store()
  if not s then return nil end
  c = c or ns.cache or {}
  local n = s.n
  local world = c.world or {}
  local out = { own = true }

  -- Alignment, from what was done to and for others.
  local light = n.strangerHeals / 10 + n.strangerBuffs / 3 + n.rez * 2 + n.heals / 300
    - n.critters * 2 - n.greyNeutral - n.ganks * 5 - n.raids
  local order = n.quests * 0.3 + n.guarding * 2 - n.ganks * 3 - n.raids * 2 - n.abandoned
  local honor = n.quests * 0.2 - n.abandoned * 2 - n.pickpockets * 0.5
  out.align = { light = axis(light, 40), order = axis(order, 60), honor = axis(honor, 40), taint = 0 }

  -- Traits, on RPG Dialogue's scale.
  local hours = n.minutes / 60
  local hoard = 0
  if type(world.money) == "number" and world.level then
    local r = world.money / math.max(1, world.level ^ 2)
    if r >= 400 and n.spent < world.money then hoard = r >= 1500 and 2 or 1 end
  end
  out.traits = {
    kind = trait(n.strangerHeals / 25 + n.strangerBuffs / 4 + n.rez + n.heals / 400),
    cruel = trait(n.critters / 3 + n.greyNeutral / 5 + n.ganks),
    brave = trait(n.hardFights / 10 + n.pvpFights / 5 + n.guarding / 3),
    cautious = trait(n.easyFights / 15),
    generous = trait(n.gifts + n.coinGiven / 50000),
    greedy = trait(n.auctions / 8 + hoard),
    pious = trait(n.prayers + n.holyCasts / 150),
    skeptical = 0,
    charming = trait(n.groupedMin / 120 + n.says / 15 + n.emotes / 10 + n.whispers / 20),
    reserved = trait(n.quietHours / 3),
    witty = trait(n.playful / 3),
    stern = trait(n.unsmilingHours / 4),
  }
  local list = {}
  for name, v in pairs(out.traits) do if v >= 3 then list[#list + 1] = { name = name, n = v } end end
  table.sort(list, function(x, y) if x.n ~= y.n then return x.n > y.n end return x.name < y.name end)
  out.dominant = {}
  for i = 1, math.min(2, #list) do out.dominant[i] = list[i].name end

  -- Towns: where they rest and work, the best thought of first.
  local factions = {}
  for _, f in ipairs(world.factions or {}) do factions[f.name] = f.standing end
  out.towns = {}
  for name, t in pairs(s.towns) do
    t.name = name
    local v = standing(t, factions)
    t.name = nil
    if v > 0 then out.towns[#out.towns + 1] = { id = name, name = name, value = v, own = true } end
  end
  table.sort(out.towns, function(a, b) if a.value ~= b.value then return a.value > b.value end return a.name < b.name end)

  -- People: the NPCs dealt with most. Friends are the ones gone back to again and again.
  out.friends, out.rivals, out.met = {}, {}, 0
  for name, m in pairs(s.npcs) do
    out.met = out.met + 1
    local rec = { name = name, affinity = math.min(9, math.floor((m.n or 0) / 3)), times = m.n or 0, zone = m.zone,
      last = m.last or 0, kind = m.kind }
    if (m.n or 0) >= 8 then out.friends[#out.friends + 1] = rec end
    if not out.lastTalk or rec.last > out.lastTalk.last then
      out.lastTalk = { name = name, affinity = 0, times = rec.times, zone = rec.zone, last = rec.last }
    end
  end
  table.sort(out.friends, function(a, b) if a.times ~= b.times then return a.times > b.times end return a.name < b.name end)
  out.conversations = n.talks

  -- Lands in the order first reached (the mood model's record of arrivals).
  out.zones = {}
  local seen = ns.char.seen and type(ns.char.seen.zones) == "table" and ns.char.seen.zones or {}
  for name, t in pairs(seen) do
    if type(name) == "string" and tonumber(t) then out.zones[#out.zones + 1] = { name = name, t = tonumber(t) } end
  end
  table.sort(out.zones, function(a, b) return a.t < b.t end)

  -- Stories, and dungeons come back out of (a master felled inside).
  local finished = ns.Compose and ns.Compose.Finished(c) or {}
  out.threads = stories(finished)
  out.cleared = {}
  local deeds = c.deeds
  if deeds then
    local inside = {}
    for _, i in ipairs(deeds.instances or {}) do
      if i.kind == "party" or i.kind == "raid" then inside[i.name] = true end
    end
    local at = {}
    for _, b in ipairs(deeds.bosses or {}) do
      if b.where and inside[b.where] and (b.t or 0) > (at[b.where] or 0) then at[b.where] = b.t end
    end
    for place, t in pairs(at) do out.cleared[#out.cleared + 1] = { name = place, t = t } end
    table.sort(out.cleared, function(a, b) return a.t > b.t end)
  end

  -- What RPG Dialogue alone knows stays empty; the rest from the game.
  out.opinions, out.killsByName, out.arrived = {}, {}, {}
  out.kills, out.insanity, out.lettersArrived, out.topics, out.claimsMade, out.liesExposed, out.heard = 0, 0, 0, 0, 0, 0, 0
  out.journalCount = 0
  out.deaths = ns.char.deeds and type(ns.char.deeds.deaths) == "table" and ns.char.deeds.deaths or {}
  out.deathCount = ns.char.deeds and tonumber(ns.char.deeds.deathCount) or 0
  out.drunk, out.drunkAt = s.drunk or 0, s.drunkAt or 0

  out.books = {}
  for title, b in pairs(s.books) do out.books[#out.books + 1] = { title = title, n = b.n or 1 } end
  table.sort(out.books, function(x, y) if x.n ~= y.n then return x.n > y.n end return x.title < y.title end)

  -- Where it began: the first trainer, if Auto TRP was there for it; else the one gone
  -- back to most.
  out.start = {}
  if s.origin.trainer then
    out.start.trainer, out.start.zone, out.start.first = s.origin.trainer, s.origin.trainerZone, true
  else
    local best
    for name, m in pairs(s.npcs) do
      if m.kind == "trainer" and (m.n or 0) >= 3 and (not best or m.n > best.n) then best = { name = name, n = m.n, zone = m.zone } end
    end
    if best then out.start.trainer, out.start.zone = best.name, best.zone end
  end
  out.counts = n
  out.hours = hours
  return out
end
