-- What the game itself says about the moment: where you are, what you're doing, what you're
-- wearing, what's on you (buffs, sickness), your purse, the hour and the season.
-- Every call is protected; a missing API just leaves its detail out.
local _, ns = ...

local U = ns.U
local W = ns.Words
local World = {}
ns.World = World

local function call(name, ...)
  return U.Call(_G[name], ...)
end

-- Midnight-era "secret" values can be shown but not compared: treat them as unknown.
function World.Safe(v) return U.Unsecret(v) end

---------------------------------------------------------------------------
-- Auras: buffs and debuffs, through whichever API this client has.
---------------------------------------------------------------------------
local function aura(unit, i, filter)
  if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
    local ok, a = pcall(C_UnitAuras.GetAuraDataByIndex, unit, i, filter)
    if ok and type(a) == "table" then return World.Safe(a.name), World.Safe(a.dispelName), World.Safe(a.spellId) end
    if ok then return nil end
  end
  local fn = filter == "HARMFUL" and _G.UnitDebuff or _G.UnitBuff
  if type(fn) ~= "function" then return nil end
  local ok, name, _, _, kind, _, _, _, _, _, spellId = pcall(fn, unit, i)
  name = ok and World.Safe(name) or nil
  if name then return name, World.Safe(kind), World.Safe(spellId) end
  return nil
end

-- Big buffs worth remembering: the kind a whole city cheers for.
local WORLD_BUFFS = {
  ["Rallying Cry of the Dragonslayer"] = true, ["Songflower Serenade"] = true, ["Spirit of Zandalar"] = true,
  ["Warchief's Blessing"] = true, ["Fengus' Ferocity"] = true, ["Mol'dar's Moxie"] = true,
  ["Slip'kik's Savvy"] = true, ["Sayge's Dark Fortune of Damage"] = true, ["Boon of Blackfathom"] = true,
}

function World.Auras()
  local out = { buffs = 0, debuffs = 0, worldBuffs = 0, kinds = {}, names = {} }
  for i = 1, 40 do
    local name = aura("player", i, "HELPFUL")
    if not name then break end
    out.names[name] = true
    if name == "Food" or name == "Refreshment" or name == "Food & Drink" then out.eating = true
    elseif name == "Drink" then out.drinking = true
    elseif name == "Well Fed" or name:find("Well Fed") then out.wellFed = true
    elseif WORLD_BUFFS[name] then out.worldBuffs = out.worldBuffs + 1; out.buffs = out.buffs + 1
    else out.buffs = out.buffs + 1 end
  end
  for i = 1, 40 do
    local name, kind = aura("player", i, "HARMFUL")
    if not name then break end
    if name == "Resurrection Sickness" then out.resSick = true
    else
      out.debuffs = out.debuffs + 1
      if type(kind) == "string" then out.kinds[kind] = true end
    end
  end
  return out
end

---------------------------------------------------------------------------
-- Gear: armour, weapons, tabard, how well kept and how fine.
---------------------------------------------------------------------------
local SLOTS = { 1, 3, 5, 6, 7, 8, 9, 10, 15, 16, 17, 18 }

local function itemInfo(link)
  local fn = (C_Item and C_Item.GetItemInfo) or _G.GetItemInfo
  if type(fn) ~= "function" or not link then return nil end
  local ok, name, _, quality, _, _, _, subType = pcall(fn, link)
  if ok then return World.Safe(name), World.Safe(quality), World.Safe(subType) end
end

function World.Gear()
  local g = { qualitySum = 0, items = 0, names = {}, q = {} }
  local function slot(id)
    local link = call("GetInventoryItemLink", "player", id)
    if not link then return nil end
    local name, q, sub = itemInfo(link)
    if not name then g.incomplete = true end   -- not cached yet: read again when it arrives
    return name, q, sub
  end
  for _, id in ipairs(SLOTS) do
    local _, q = slot(id)
    if type(q) == "number" then g.qualitySum = g.qualitySum + q; g.items = g.items + 1 end
  end
  if g.items > 0 then g.quality = math.floor(g.qualitySum / g.items + 0.5) end
  local _, _, chest = slot(5)
  g.armor = chest and W.ARMOR[chest]
  local _, _, main = slot(16)
  g.main = main and W.WEAPONS[main]
  local _, _, off = slot(17)
  g.off = off and W.WEAPONS[off]
  local _, _, ranged = slot(18)
  g.ranged = ranged and W.WEAPONS[ranged]
  for _, id in ipairs({ 19, 5, 1, 3, 15, 16, 17, 18, 7, 10, 8 }) do
    local name, q = slot(id)
    if type(q) == "number" and q >= 3 and (not g.finest or q > g.finest.quality) then
      g.finest = { name = U.Plain(name), quality = q, slot = id }
    end
  end
  for _, id in ipairs({ 1, 3, 5, 15, 16, 17, 18, 19 }) do
    local name, q = slot(id)
    if name then g.names[id] = U.Plain(name); g.q[id] = q end
  end
  g.offType = off
  g.tabard = U.Plain((slot(19)))
  g.cloak = U.Plain((slot(15)))
  -- Durability: the worst-kept piece
  local worst, worstSlot
  for _, id in ipairs(SLOTS) do
    local cur, max = call("GetInventoryItemDurability", id)
    if type(cur) == "number" and type(max) == "number" and max > 0 then
      local r = cur / max
      if not worst or r < worst then worst, worstSlot = r, id end
    end
  end
  g.durability = worst
  g.worstName = worstSlot and U.Plain((slot(worstSlot)))
  return g
end

---------------------------------------------------------------------------
-- Bags
---------------------------------------------------------------------------
-- The class's reagents and tools actually in the bags: { { name =, count = } }.
function World.Reagents(class)
  local out = {}
  local count = (C_Item and C_Item.GetItemCount) or _G.GetItemCount
  for _, r in ipairs(W.CLASS_REAGENTS[class or ""] or {}) do
    local n = U.Call(count, r[1])
    if type(n) == "number" and n > 0 then
      local name = itemInfo("item:" .. r[1])
      if not name then out.incomplete = true end
      out[#out + 1] = { name = U.Plain(name) or r[2], count = n }
    end
  end
  return out
end
function World.FreeBagSlots()
  local free = 0
  local get = (C_Container and C_Container.GetContainerNumFreeSlots) or _G.GetContainerNumFreeSlots
  if type(get) ~= "function" then return nil end
  for bag = 0, 4 do
    local n = U.Call(get, bag)
    if type(n) == "number" then free = free + n end
  end
  return free
end

---------------------------------------------------------------------------
-- Standing with the world's factions (Honored and up), through either API.
---------------------------------------------------------------------------
local STANDING_WORD = { [6] = "Honored", [7] = "Revered", [8] = "Exalted" }

function World.Factions()
  local out = {}
  local function add(name, standing, isHeader, hasRep)
    if type(name) == "string" and (not isHeader or hasRep) and STANDING_WORD[standing] then
      out[#out + 1] = { name = U.Plain(name), standing = standing, word = STANDING_WORD[standing] }
    end
  end
  if C_Reputation and C_Reputation.GetNumFactions and C_Reputation.GetFactionDataByIndex then
    local n = U.Call(C_Reputation.GetNumFactions) or 0
    for i = 1, n do
      local d = U.Call(C_Reputation.GetFactionDataByIndex, i)
      if type(d) == "table" then add(World.Safe(d.name), d.reaction, d.isHeader, d.isHeaderWithRep) end
    end
  elseif _G.GetNumFactions and _G.GetFactionInfo then
    local n = call("GetNumFactions") or 0
    for i = 1, n do
      local name, _, standing, _, _, _, _, _, isHeader, _, hasRep = call("GetFactionInfo", i)
      add(World.Safe(name), standing, isHeader, hasRep)
    end
  end
  table.sort(out, function(a, b) if a.standing ~= b.standing then return a.standing > b.standing end return a.name < b.name end)
  return out
end

-- Professions and their skill, read live (Classic skill lines).
local PROFESSIONS = {
  Alchemy = true, Blacksmithing = true, Enchanting = true, Engineering = true, Herbalism = true,
  Leatherworking = true, Mining = true, Skinning = true, Tailoring = true, Cooking = true,
  ["First Aid"] = true, Fishing = true, Jewelcrafting = true,
}
function World.Professions()
  local out = {}
  local n = call("GetNumSkillLines") or 0
  for i = 1, n do
    local name, header, _, rank = call("GetSkillLineInfo", i)
    name = World.Safe(name)
    if not header and PROFESSIONS[name] and type(rank) == "number" and rank > 0 then
      out[#out + 1] = { name = name, rank = rank }
    end
  end
  table.sort(out, function(a, b) return a.rank > b.rank end)
  return out
end

-- Druid, shaman and priest shapes.
local FORMS = {
  ["Bear Form"] = "in the shape of a great bear", ["Dire Bear Form"] = "in the shape of a great bear",
  ["Cat Form"] = "in the shape of a prowling cat", ["Travel Form"] = "in the shape of a running stag",
  ["Aquatic Form"] = "in the shape of a sleek sea lion", ["Moonkin Form"] = "in moonkin form, feathers ruffled",
  ["Ghost Wolf"] = "running as a ghost wolf", ["Shadowform"] = "wreathed in shadow",
}
function World.Form(auras)
  for name, phrase in pairs(FORMS) do
    if auras and auras.names and auras.names[name] then return phrase end
  end
  local idx = call("GetShapeshiftForm")
  if type(idx) == "number" and idx > 0 then
    -- Classic returns (icon, name, active, castable); later clients (icon, active, castable, spellID).
    local _, second, _, fourth = call("GetShapeshiftFormInfo", idx)
    local name = type(second) == "string" and second or nil
    if not name and type(fourth) == "number" then
      name = (C_Spell and C_Spell.GetSpellName and U.Call(C_Spell.GetSpellName, fourth)) or call("GetSpellInfo", fourth)
    end
    return FORMS[World.Safe(name) or ""]
  end
  return nil
end

---------------------------------------------------------------------------
-- Seasons: the festivals of the year, by the calendar.
---------------------------------------------------------------------------
function World.Festival()
  local d = date and date("*t")
  if type(d) ~= "table" then return nil end
  local m, day = d.month, d.day
  if (m == 12 and day >= 15) or (m == 1 and day <= 2) then return "winterveil" end
  if m == 10 and day >= 18 or (m == 11 and day <= 1) then return "hallowsend" end
  if m == 2 and day >= 7 and day <= 20 then return "love" end
  if (m == 6 and day >= 21) or (m == 7 and day <= 5) then return "midsummer" end
  if m == 9 and day >= 20 or (m == 10 and day <= 4) then return "brewfest" end
  if m == 1 and day >= 20 or (m == 2 and day <= 3) then return "lunar" end
  if m == 4 and day >= 1 and day <= 14 then return "noblegarden" end
  return nil
end

---------------------------------------------------------------------------
-- The moment
---------------------------------------------------------------------------
function World.Snapshot()
  local s = {}
  s.zone = U.Plain(call("GetRealZoneText")) or U.Plain(call("GetZoneText"))
  s.subzone = U.Plain(call("GetSubZoneText"))
  if s.subzone == s.zone then s.subzone = nil end
  -- zoneKey: the zone's English name for the lookup tables, from its map ID when there is one
  -- (so non-English clients get the same touches); zone stays as the game shows it.
  -- English clients already have the English name; others look it up by map ID.
  local locale = U.Call(GetLocale)
  if type(locale) == "string" and not locale:find("^en") then
    local mapID = C_Map and C_Map.GetBestMapForUnit and World.Safe(U.Call(C_Map.GetBestMapForUnit, "player"))
    s.zoneKey = (type(mapID) == "number" and W.ZONE_BY_MAP[mapID]) or s.zone
  else
    s.zoneKey = s.zone
  end
  s.resting = call("IsResting") and true or false
  s.combat = World.Safe(call("UnitAffectingCombat", "player")) and true or false
  s.dead = World.Safe(call("UnitIsDeadOrGhost", "player")) and true or false
  s.ghost = call("UnitIsGhost", "player") and true or false
  s.taxi = call("UnitOnTaxi", "player") and true or false
  s.mounted = call("IsMounted") and true or false
  s.swimming = call("IsSwimming") and true or false
  s.flying = call("IsFlying") and true or false
  s.indoors = call("IsIndoors") and true or false
  s.stealthed = call("IsStealthed") and true or false
  local inInstance, kind = call("IsInInstance")
  s.instance = inInstance and kind ~= "none" and kind or nil
  s.grouped = (call("IsInGroup") or call("IsInRaid")) and true or false
  s.groupSize = call("GetNumGroupMembers") or 0
  s.level = call("UnitLevel", "player")
  s.race = select(2, call("UnitRace", "player"))
  s.class = select(2, call("UnitClass", "player"))
  s.faction = call("UnitFactionGroup", "player")
  s.name = call("UnitName", "player")
  s.bind = U.Plain(call("GetBindLocation"))
  s.pvpZone = call("GetZonePVPInfo")
  s.pvpFlag = call("UnitIsPVP", "player") and true or false
  local hp, max = World.Safe(call("UnitHealth", "player")), World.Safe(call("UnitHealthMax", "player"))
  if type(hp) == "number" and type(max) == "number" and max > 0 then s.health = hp / max end
  local mana, manaMax = World.Safe(call("UnitPower", "player", 0)), World.Safe(call("UnitPowerMax", "player", 0))
  if type(mana) == "number" and type(manaMax) == "number" and manaMax > 0 then s.mana = mana / manaMax end
  local xp, xpMax = World.Safe(call("UnitXP", "player")), World.Safe(call("UnitXPMax", "player"))
  if type(xp) == "number" and type(xpMax) == "number" and xpMax > 0 then s.xp = xp / xpMax end
  s.rested = call("GetXPExhaustion")
  s.money = call("GetMoney")
  local hour = call("GetGameTime")
  s.hour = type(hour) == "number" and hour or nil
  s.night = s.hour and (s.hour >= 21 or s.hour < 5) or false
  s.dawn = s.hour and s.hour >= 5 and s.hour < 8 or false
  s.dusk = s.hour and s.hour >= 18 and s.hour < 21 or false
  s.auras = World.Auras()
  s.freeSlots = World.FreeBagSlots()
  s.festival = World.Festival()
  if call("UnitExists", "pet") then
    s.pet = U.Plain(call("UnitName", "pet"))
    s.petKind = U.Plain(call("UnitCreatureFamily", "pet"))
    if s.class == "HUNTER" then s.petHappy = World.Safe(call("GetPetHappiness")) end
  end
  s.stats = {}
  for i, name in ipairs({ "strength", "agility", "stamina", "intellect", "spirit" }) do
    local _, v = call("UnitStat", "player", i)
    if type(v) == "number" then s.stats[name] = v end
  end
  -- Reputations, skills and gear change rarely: read again only when the game says so.
  local slow = World.slow
  if not slow or slow.dirty or U.Now() - slow.t > 300 then
    slow = { t = U.Now(), factions = World.Factions(), professions = World.Professions(), gear = World.Gear(),
      reagents = World.Reagents(s.class) }
    World.slow = slow
  end
  s.factions, s.professions, s.gear, s.reagents = slow.factions, slow.professions, slow.gear, slow.reagents or {}
  s.form = World.Form(s.auras)
  local guild, guildRank = call("GetGuildInfo", "player")
  s.guild, s.guildRank = U.Plain(World.Safe(guild)), U.Plain(World.Safe(guildRank))
  local pvpRank = call("UnitPVPRank", "player")
  if type(pvpRank) == "number" and pvpRank >= 5 then s.pvpRank = U.Plain((call("GetPVPRankInfo", pvpRank))) end
  s.raid = call("IsInRaid") and true or false
  s.away = call("UnitIsAFK", "player") and true or false
  s.context = World.Context()
  return s
end

function World.Invalidate() if World.slow then World.slow.dirty = true end end
for _, e in ipairs({ "UPDATE_FACTION", "SKILL_LINES_CHANGED", "PLAYER_EQUIPMENT_CHANGED", "UPDATE_INVENTORY_DURABILITY",
  "PLAYER_GUILD_UPDATE" }) do
  ns.On(e, function() World.Invalidate() end)
end
-- Item info arrives all the time (tooltips, the auction house, loot): only worth a new read
-- when the last one was waiting on a name.
ns.On("GET_ITEM_INFO_RECEIVED", function()
  local slow = World.slow
  if slow and ((slow.gear and slow.gear.incomplete) or (slow.reagents and slow.reagents.incomplete)) then World.Invalidate() end
end)

---------------------------------------------------------------------------
-- What you're busy with: set by events, kept for a few minutes.
---------------------------------------------------------------------------
local context
World.CONTEXT_SECONDS = 180

-- Some moments are brief.
local CONTEXT_LENGTH = { shadowmeld = 30, cannibalize = 30, hearth = 20, portal = 90, mining = 60, herbs = 60,
  skinning = 45, disenchant = 45, lockpick = 30, pickpocket = 30 }

function World.SetContext(kind, detail)
  context = { kind = kind, detail = detail, t = U.Now() }
end

function World.Context()
  if context and U.Now() - context.t <= (CONTEXT_LENGTH[context.kind] or World.CONTEXT_SECONDS) then return context end
  return nil
end

ns.On("MAIL_SHOW", function() World.SetContext("mail") end)
local function talkingTo()
  local who = World.Safe(call("UnitName", "npc"))
  if type(who) == "string" and who ~= "" then World.SetContext("talk", U.Plain(who)) end
end
ns.On("GOSSIP_SHOW", talkingTo)
ns.On("QUEST_DETAIL", talkingTo)
ns.On("QUEST_GREETING", talkingTo)
ns.On("ITEM_TEXT_BEGIN", function()
  local title = U.Plain(World.Safe(call("ItemTextGetItem")))
  if title then World.SetContext("reading", title) end
end)
ns.On("DUEL_REQUESTED", function() World.SetContext("duel") end)
ns.On("DUEL_INBOUNDS", function() World.SetContext("duel") end)
ns.OnUnit("UNIT_SPELLCAST_START", "player", function(_, _, _, spellID)
  if spellID == 8690 or spellID == 556 then World.SetContext("hearth") end
end)
-- Poses from your own emotes: sit, sleep, dance. Any other emote ends them.
ns.On("CHAT_MSG_TEXT_EMOTE", function(_, msg)
  msg = World.Safe(msg)
  if type(msg) ~= "string" or not msg:find("^You ") then return end
  local l = msg:lower()
  if l:find("^you sit") then World.SetContext("sitting")
  elseif l:find("^you lie down") or l:find("^you go to sleep") or l:find("^you sleep") then World.SetContext("sleeping")
  elseif l:find("^you dance") or l:find("^you burst into dance") then World.SetContext("dancing") end
end)
ns.On("BANKFRAME_OPENED", function() World.SetContext("bank") end)
ns.On("AUCTION_HOUSE_SHOW", function() World.SetContext("auction") end)
ns.On("MERCHANT_SHOW", function() World.SetContext("merchant") end)
ns.On("TRAINER_SHOW", function() World.SetContext("trainer") end)
ns.On("TAXIMAP_OPENED", function() World.SetContext("flightmaster") end)
local function craft()
  local name = U.Plain((call("GetTradeSkillLine"))) or U.Plain((call("GetCraftDisplaySkillLine")))
  if name and W.CRAFT[name] then World.SetContext("craft", name) end
end
ns.On("TRADE_SKILL_SHOW", craft)
ns.On("CRAFT_SHOW", craft)
ns.OnUnit("UNIT_SPELLCAST_CHANNEL_START", "player", function(_, unit, _, spellID)
  local name = World.Safe(call("UnitChannelInfo", "player"))
  if name == "Fishing" or spellID == 7620 or spellID == 7731 or spellID == 7732 or spellID == 18248 then
    World.SetContext("fishing")
  end
end)

-- Spells and racial abilities you cast (successful casts only).
local function spellName(id)
  if type(id) ~= "number" then return nil end
  local n = (C_Spell and C_Spell.GetSpellName and U.Call(C_Spell.GetSpellName, id)) or call("GetSpellInfo", id)
  return World.Safe(n)
end
-- Every spell and ability cast, counted by name, for the most cast spell (Personality and
-- the Statistics). Not counted: auto-attacks, the hearthstone, gathering, crafting, and
-- anything that isn't the character's own spell (potions, food, mounts from items...).
function World.CountCast(name, spellID)
  if not ns.char or type(name) ~= "string" then return false end
  if W.CAST_IGNORE[name] or W.CAST_IGNORE_ID[spellID or 0] then return false end
  local ctx = World.Context()
  if ctx and ctx.kind == "craft" then return false end
  if type(_G.IsPlayerSpell) == "function" and type(spellID) == "number" then
    local own = U.Call(_G.IsPlayerSpell, spellID)
    if own == false then return false end
  end
  local casts = ns.char.casts
  if type(casts) ~= "table" then casts = { since = U.Now(), n = {} }; ns.char.casts = casts end
  if type(casts.n) ~= "table" then casts.n = {} end
  casts.n[name] = (casts.n[name] or 0) + 1
  return true
end

ns.OnUnit("UNIT_SPELLCAST_SUCCEEDED", "player", function(_, _, _, spellID)
  local name = spellName(spellID)
  if type(name) ~= "string" then return end
  World.CountCast(name, spellID)
  local dest = name:match("^Portal: (.+)$")
  if dest then World.SetContext("portal", dest); if ns.UI then ns.UI.Poke(false) end return end
  local def = W.SPELLS[name]
  if not def then return end
  if def.context then World.SetContext(def.context) end
  if def.mood and ns.Mood and ns.db.reactPlaces then ns.Mood.Push(def.mood[1], def.mood[2], U.Pron(def.mood[3])) end
  if def.context and ns.UI then ns.UI.Poke(false) end
end)

-- Inns and taverns, by the words in their names.
local INN_WORDS = { "Inn", "Tavern", "Rest", "Lodge", "Hall", "Barracks", "Hostel", "Brewery" }
function World.IsInn(sub)
  if type(sub) ~= "string" then return false end
  for _, w in ipairs(INN_WORDS) do if sub:find(w) then return true end end
  return false
end

-- What they're riding: the mount's own name when it says, else class or race.
function World.Mount(s)
  for name in pairs(s.auras and s.auras.names or {}) do
    for _, m in ipairs(W.MOUNTS) do
      if name:find(m[1]) then return m[2] end
    end
  end
  return W.RACE_MOUNT[s.race or ""] or "riding"
end

local function petPhrase(s, seed)
  if not s.pet or s.mounted or s.taxi then return nil end
  local list = W.PET[s.class or ""]
  if not list then return nil end
  local p = U.Pick(list, seed .. "pet")
  return U.Pron((p:gsub("{pet}", function() return s.pet end):gsub("{kind}", function() return (s.petKind or "companion"):lower() end)))
end

-- "resting at the Lion's Pride Inn in Goldshire" etc. Never the exact spot in the open
-- world: a profile is public, and "around Goldshire" is plenty.
-- terse: leave out the form and the pet (when Currently would run long).
function World.Activity(s, seed, terse)
  local sub = s.subzone
  if sub and World.IsInn(sub) and not sub:find("^The ") then sub = "the " .. sub end
  local place = sub and (U.Mid(sub) .. ", " .. (s.zone or "")) or s.zone or "the road"
  local where = U.Mid(s.zone) or "the wilds"
  local text
  -- A travel phrase with the place filled in ({where} the zone, {place} the spot,
  -- {around} "around <spot>" or "in <zone>").
  local function fill(list, around)
    return (U.Pick(list, seed .. (list[1] or "")):gsub("{(%a+)}", function(k)
      if k == "where" then return where elseif k == "place" then return place elseif k == "around" then return around end
    end))
  end
  if s.ghost or s.dead then
    return (U.Pick(W.TRAVEL.ghost, seed .. "ghost"):gsub("{where}", function() return where end))
  end
  if s.taxi then
    local beast
    if s.faction == "Horde" then beast = W.BAT_ZONES[s.zoneKey or ""] and "a bat" or "a wind rider"
    else beast = W.KALIMDOR[s.zoneKey or ""] and "a hippogryph" or "a gryphon" end
    return (U.Pick(W.TRAVEL.taxi, seed .. "taxi"):gsub("{beast}", beast):gsub("{where}", function() return where end))
  end
  local ctx = s.context
  if ctx and ctx.kind == "craft" then
    text = U.Pick(W.CRAFT[ctx.detail], seed .. "craft") .. " in " .. (U.Mid(sub) or where)
  elseif s.away then
    text = U.Pick(W.ACTIVITY.away, seed .. "away"):gsub("{place}", function() return U.Mid(sub) or where end)
  elseif ctx and W.ACTIVITY[ctx.kind] then
    text = U.Pick(W.ACTIVITY[ctx.kind], seed .. ctx.kind):gsub("{place}", function() return U.Mid(sub) or where end)
      :gsub("{who}", function() return ctx.detail or "someone" end):gsub("{dest}", function() return ctx.detail or "afar" end):gsub("{what}", function() return ctx.detail and ("\"" .. ctx.detail .. "\"") or "a book" end)
    text = U.Pron(text)
  elseif s.auras and (s.auras.eating or s.auras.drinking) then
    local list = s.auras.eating and W.ACTIVITY.eating or W.ACTIVITY.drinking
    text = U.Pick(list, seed .. "meal"):gsub("{place}", function() return U.Mid(sub) or where end)
  elseif s.instance == "party" or s.instance == "raid" then
    local inst = W.INSTANCE_FLAVOR[s.zone or ""]
    text = inst and U.Pick(inst, seed .. "inst") or fill(W.TRAVEL.dungeon)
  elseif s.instance == "pvp" then
    text = fill(W.TRAVEL.battleground)
  elseif s.resting and World.IsInn(s.subzone) then
    text = fill(W.TRAVEL.inn)
  elseif s.subzone and W.CITY_FLAVOR[s.subzone] then
    text = U.Pick(W.CITY_FLAVOR[s.subzone], seed .. "city")
  elseif s.resting then
    text = fill(W.TRAVEL.town)
  elseif s.stealthed then
    text = fill(W.TRAVEL.stealth, s.subzone and ("around " .. place) or ("in " .. where))
  elseif s.swimming then
    text = fill(W.TRAVEL.swimming)
  elseif s.flying then
    text = fill(W.TRAVEL.flying)
  elseif s.mounted then
    text = fill(W.TRAVEL.mounted):gsub("{mount}", function() return World.Mount(s) end)
  else
    -- Out in the open: where they are, and nothing they aren't doing.
    local flavor = W.ZONE_FLAVOR[s.zoneKey or ""]
    if flavor and U.Hash(seed .. "flavor") % 2 == 0 then
      text = U.Pick(flavor, seed .. "fl")
    else
      local around = s.subzone and ("around " .. place) or ("in " .. where)
      text = fill(W.TRAVEL.road, around)
    end
  end
  text = U.Pron(text)
  if terse then return text end
  if s.form and not s.taxi then text = text .. ", " .. s.form end
  local pet = petPhrase(s, seed)
  if pet then text = text .. ", " .. pet end
  return text
end

function World.TimeOfDay(s, seed)
  if s.indoors or s.instance then return nil end
  local key = s.night and "night" or s.dawn and "dawn" or s.dusk and "dusk"
  if not key then return nil end
  return U.Pick(W.TIME_OF_DAY[key], (seed or "") .. "tod" .. key)
end
