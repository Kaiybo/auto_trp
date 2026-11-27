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
    local a = U.Call(C_UnitAuras.GetAuraDataByIndex, unit, i, filter)
    if type(a) == "table" then return World.Safe(a.name), World.Safe(a.dispelName), World.Safe(a.spellId) end
    return nil
  end
  local fn = filter == "HARMFUL" and _G.UnitDebuff or _G.UnitBuff
  if type(fn) ~= "function" then return nil end
  local name, _, _, kind, _, _, _, _, _, spellId = U.CallAll(fn, unit, i)
  name = World.Safe(name)
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
  local out = { buffs = 0, debuffs = 0, worldBuffs = 0, kinds = {}, names = {}, harm = {} }
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
    out.harm[name] = true
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

-- name, quality, subType, then item level, required level, equip slot and set id.
local function itemInfo(link)
  local fn = (C_Item and C_Item.GetItemInfo) or _G.GetItemInfo
  if type(fn) ~= "function" or not link then return nil end
  local name, _, quality, ilvl, req, _, subType, _, equipLoc, _, _, _, _, _, _, setID = U.CallAll(fn, link)
  return World.Safe(name), World.Safe(quality), World.Safe(subType), World.Safe(ilvl), World.Safe(req),
    World.Safe(equipLoc), World.Safe(setID)
end

-- Every slot the game can show, read once: head to tabard (the ammo slot aside).
local ALL_SLOTS = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19 }
-- The armour proper (what decides cloth, leather, mail or plate; cloaks are always cloth).
World.ARMOUR_SLOTS = { 1, 3, 5, 6, 7, 8, 9, 10 }
-- What counts toward how fine and how current the gear is (not the shirt or tabard).
local GRADED = { 1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18 }

-- A set's name from its id, where the client can say.
local function setName(id)
  if type(id) ~= "number" or id <= 0 then return nil end
  local fn = _G.GetItemSetInfo or (C_Item and C_Item.GetItemSetInfo)
  local name = U.Call(fn, id)
  if type(name) == "table" then name = name.name end
  return U.Plain(World.Safe(name))
end

function World.Gear()
  local g = { qualitySum = 0, items = 0, names = {}, q = {}, slots = {}, armourCount = {}, qualityCount = {},
    sets = {}, enchanted = {} }
  for _, id in ipairs(ALL_SLOTS) do
    local link = call("GetInventoryItemLink", "player", id)
    if type(link) == "string" then
      local name, q, sub, ilvl, req, loc, set = itemInfo(link)
      if not name then g.incomplete = true   -- not cached yet: read again when it arrives
      else
        -- A permanent enchantment is the second field of the item string.
        local ench = tonumber(link:match("item:%-?%d+:(%d+)") or "")
        g.slots[id] = { name = U.Plain(name), q = q, sub = sub, ilvl = ilvl, req = req, loc = loc, set = set,
          enchant = ench and ench > 0 or nil }
        g.names[id], g.q[id] = U.Plain(name), q
        if ench and ench > 0 then g.enchanted[#g.enchanted + 1] = id end
      end
    end
  end
  local s = g.slots
  for _, id in ipairs(SLOTS) do
    local q = s[id] and s[id].q
    if type(q) == "number" then g.qualitySum = g.qualitySum + q; g.items = g.items + 1 end
  end
  if g.items > 0 then g.quality = math.floor(g.qualitySum / g.items + 0.5) end
  -- Quality mix, item level and required level over everything graded
  local ilvlSum, ilvlN = 0, 0
  for _, id in ipairs(GRADED) do
    local it = s[id]
    if it and type(it.q) == "number" then
      g.qualityCount[it.q] = (g.qualityCount[it.q] or 0) + 1
      local lv = (type(it.ilvl) == "number" and it.ilvl > 1 and it.ilvl) or (type(it.req) == "number" and it.req > 1 and it.req + 5)
      if lv then ilvlSum, ilvlN = ilvlSum + lv, ilvlN + 1 end
    end
  end
  if ilvlN > 0 then g.ilvl = math.floor(ilvlSum / ilvlN + 0.5); g.ilvlN = ilvlN end
  -- Cloth, leather, mail or plate: what most of the armour proper is
  for _, id in ipairs(World.ARMOUR_SLOTS) do
    local sub = s[id] and s[id].sub
    if W.ARMOR[sub or ""] then g.armourCount[sub] = (g.armourCount[sub] or 0) + 1; g.armourPieces = (g.armourPieces or 0) + 1 end
  end
  local top, topN = nil, 0
  for sub, n in pairs(g.armourCount) do
    if n > topN or (n == topN and sub < top) then top, topN = sub, n end
  end
  g.armourType = top
  g.armourMixed = top and topN < (g.armourPieces or 0) * 0.7 or nil
  -- Matched pieces: the same set, by name where the client gives one
  local bySet = {}
  for _, id in ipairs(ALL_SLOTS) do
    local it = s[id]
    if it and type(it.set) == "number" and it.set > 0 then
      local e = bySet[it.set]
      if not e then e = { id = it.set, n = 0, q = it.q, slots = {} }; bySet[it.set] = e end
      e.n = e.n + 1
      e.slots[#e.slots + 1] = id
    end
  end
  for setID, e in pairs(bySet) do
    if e.n >= 2 then
      e.name = setName(setID)
      g.sets[#g.sets + 1] = e
    end
  end
  table.sort(g.sets, function(a, b) if a.n ~= b.n then return a.n > b.n end return a.id < b.id end)
  -- What the older readers expect
  local chest, main, off, ranged = s[5] and s[5].sub, s[16] and s[16].sub, s[17] and s[17].sub, s[18] and s[18].sub
  g.armor = chest and W.ARMOR[chest]
  g.main = main and W.WEAPONS[main]
  g.mainType = main
  g.off = off and W.WEAPONS[off]
  g.ranged = ranged and W.WEAPONS[ranged]
  for _, id in ipairs({ 19, 5, 1, 3, 15, 16, 17, 18, 7, 10, 8 }) do
    local it = s[id]
    if it and type(it.q) == "number" and it.q >= 3 and (not g.finest or it.q > g.finest.quality) then
      g.finest = { name = it.name, quality = it.q, slot = id }
    end
  end
  g.offType = off
  g.tabard = s[19] and s[19].name
  g.cloak = s[15] and s[15].name
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
  g.worstName = worstSlot and s[worstSlot] and s[worstSlot].name
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

-- Druid, shaman and priest shapes, by the aura's (or the stance bar's) English name.
local FORM_KEYS = {
  ["Bear Form"] = "bear", ["Dire Bear Form"] = "bear", ["Cat Form"] = "cat", ["Travel Form"] = "travel",
  ["Aquatic Form"] = "aquatic", ["Moonkin Form"] = "moonkin", ["Ghost Wolf"] = "ghostwolf", ["Shadowform"] = "shadowform",
}
function World.FormKey(auras)
  for name, key in pairs(FORM_KEYS) do
    if auras and auras.names and auras.names[name] then return key end
  end
  local idx = call("GetShapeshiftForm")
  if type(idx) == "number" and idx > 0 then
    -- Classic returns (icon, name, active, castable); later clients (icon, active, castable, spellID).
    local _, second, _, fourth = call("GetShapeshiftFormInfo", idx)
    local name = type(second) == "string" and second or nil
    if not name and type(fourth) == "number" then
      name = (C_Spell and C_Spell.GetSpellName and U.Call(C_Spell.GetSpellName, fourth)) or call("GetSpellInfo", fourth)
    end
    return FORM_KEYS[World.Safe(name) or ""]
  end
  return nil
end
-- The shape as a phrase ("in the shape of a great bear"), one of several by seed.
function World.Form(auras, seed)
  local key = World.FormKey(auras)
  local list = key and W.FORM_LINES and W.FORM_LINES[key]
  if not list then return nil end
  return seed and U.Pick(list, seed .. "form" .. key) or list[1]
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
  s.restKnown = type(_G.GetXPExhaustion) == "function"
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
  if not slow or ((slow.dirty or U.Now() - slow.t > 300) and not s.combat) then
    slow = { t = U.Now(), factions = World.Factions(), professions = World.Professions(), gear = World.Gear(),
      reagents = World.Reagents(s.class) }
    World.slow = slow
  end
  s.factions, s.professions, s.gear, s.reagents = slow.factions, slow.professions, slow.gear, slow.reagents or {}
  s.formKey = World.FormKey(s.auras)
  s.form = World.Form(s.auras)
  s.drunk = World.Drunk()
  local guild, guildRank = call("GetGuildInfo", "player")
  s.guild, s.guildRank = U.Plain(World.Safe(guild)), U.Plain(World.Safe(guildRank))
  local pvpRank = call("UnitPVPRank", "player")
  if type(pvpRank) == "number" and pvpRank >= 5 then s.pvpRank = U.Plain((call("GetPVPRankInfo", pvpRank))) end
  s.raid = call("IsInRaid") and true or false
  s.away = call("UnitIsAFK", "player") and true or false
  s.context = World.Context()
  World.MomentState(s)
  return s
end

-- Drink: the game says so in a system line ("You feel tipsy."), never as an aura. Kept for
-- half an hour, or until "You feel sober again."
local drunk
World.DRUNK_SECONDS = 1800
ns.On("CHAT_MSG_SYSTEM", function(_, msg)
  msg = World.Safe(msg)
  if type(msg) ~= "string" then return end
  for level = 1, 4 do
    local line = _G["DRUNK_MESSAGE_SELF" .. level]
    if type(line) == "string" and msg == line then
      drunk = level > 1 and { level = level - 1, t = U.Now() } or nil
      return
    end
  end
end)
-- 1 tipsy, 2 drunk, 3 completely smashed; nil when sober (or long enough ago).
function World.Drunk()
  if drunk and U.Now() - drunk.t <= World.DRUNK_SECONDS then return drunk.level end
  return nil
end
function World.SetDrunk(level) drunk = level and { level = level, t = U.Now() } or nil end

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
  skinning = 45, disenchant = 45, lockpick = 30, pickpocket = 30, map = 45, teleport = 30, trade = 60, follow = 900,
  feedpet = 45, spirithealer = 60 }

function World.SetContext(kind, detail)
  context = { kind = kind, detail = detail, t = U.Now() }
end

function World.Context()
  if context and U.Now() - context.t <= (CONTEXT_LENGTH[context.kind] or World.CONTEXT_SECONDS) then return context end
  return nil
end

ns.On("MAIL_SHOW", function() World.SetContext("mail") end)
local function talkingTo()
  -- A quest shared by another player opens the quest window with them as "npc": never
  -- named (Currently is public), and not "talking" to anyone either.
  local guid = World.Safe(call("UnitGUID", "npc"))
  if call("UnitIsPlayer", "npc") or (type(guid) == "string" and guid:find("^Player")) then return end
  local who = World.Safe(call("UnitName", "npc"))
  if type(who) == "string" and who ~= "" then World.SetContext("talk", U.Plain(who)) end
end
ns.On("GOSSIP_SHOW", talkingTo)
ns.On("QUEST_DETAIL", talkingTo)
ns.On("QUEST_GREETING", talkingTo)
ns.On("ITEM_TEXT_BEGIN", function()
  local title = U.Plain(World.Safe(call("ItemTextGetItem")))
  -- A page with a writer is a player's letter: reading, but never its title (the subject a
  -- player wrote would land in Currently).
  if U.Plain(World.Safe(call("ItemTextGetCreator"))) then World.SetContext("reading"); World.Context().letter = true; return end
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
  local tele = name:match("^Teleport: (.+)$")
  if tele then World.SetContext("teleport", tele); if ns.UI then ns.UI.Poke(false) end return end
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



---------------------------------------------------------------------------
-- CURRENTLY: the moment, as the game shows it. More of what the game says right now
-- (queues, breath, a fall, a ship, a sign hung out), the hooks that notice what you're
-- busy with, and the pieces Currently is written from.
---------------------------------------------------------------------------
local mirror = {}
World.mirror = mirror
local function poke() if ns.UI and ns.UI.Poke then ns.UI.Poke(false) end end

function World.ClearContext(kind)
  if context and (not kind or context.kind == kind) then context = nil end
end

-- The first battleground you're queued for, by name.
function World.Queued()
  local max = call("GetMaxBattlefieldID")
  if type(max) ~= "number" then max = 3 end
  for i = 1, math.min(max, 5) do
    local status, name = call("GetBattlefieldStatus", i)
    if status == "queued" and type(name) == "string" then return U.Plain(name) end
  end
  return nil
end

-- Cheap reads added to the snapshot: flags, a fall, breath, the sea, a queue, a pole.
function World.MomentState(s)
  s.dnd = call("UnitIsDND", "player") and true or false
  s.falling = call("IsFalling") and true or false
  if not s.swimming then mirror.BREATH, mirror.EXHAUSTION = nil, nil end
  s.underwater = mirror.BREATH and true or false
  s.fatigue = mirror.EXHAUSTION and true or false
  s.queued = World.Queued()
  s.capital = W.CAPITAL_ZONES[s.zoneKey or ""] or false
  local sea = (W.SEA_ZONES[s.zoneKey or ""] and s.zone) or (W.SEA_ZONES[s.subzone or ""] and s.subzone)
  if sea and not s.swimming and not s.dead and not s.taxi then
    s.sea = sea
    -- The Horde crosses between the continents by zeppelin; the boat out of Booty Bay sails the South Seas.
    s.transport = (s.faction == "Horde" and sea ~= "South Seas") and "zeppelin" or "ship"
  end
  local g = s.gear
  if g and g.mainType == "Fishing Poles" and g.names and g.names[16] then s.pole = g.names[16] end
  local names = s.auras and s.auras.names or {}
  s.prowling = names["Prowl"] and true or false
  s.rogueStealth = names["Stealth"] and true or false
end

ns.On("MIRROR_TIMER_START", function(_, timer)
  if timer == "BREATH" or timer == "EXHAUSTION" then mirror[timer] = true; poke() end
end)
ns.On("MIRROR_TIMER_STOP", function(_, timer)
  if timer == "BREATH" or timer == "EXHAUSTION" then mirror[timer] = nil; poke() end
end)
-- Frames the game opens for you: who you're dealing with, never their name.
for event, kind in pairs({ BARBER_SHOP_OPEN = "barber", PET_STABLE_SHOW = "stable", CONFIRM_BINDER = "innkeeper",
  GUILDBANKFRAME_OPENED = "guildbank", GUILD_REGISTRAR_SHOW = "registrar", OPEN_TABARD_FRAME = "tabard",
  TRADE_SHOW = "trade", CONFIRM_XP_LOSS = "spirithealer" }) do
  ns.On(event, function() World.SetContext(kind); poke() end)
end
ns.On("MERCHANT_SHOW", function()
  if call("CanMerchantRepair") then World.SetContext("repair") end
end)
ns.On("AUTOFOLLOW_BEGIN", function() World.SetContext("follow"); poke() end)
ns.On("AUTOFOLLOW_END", function() World.ClearContext("follow"); poke() end)
ns.On("DUEL_FINISHED", function() World.ClearContext("duel") end)
ns.On("UPDATE_BATTLEFIELD_STATUS", poke)
ns.On("PLAYER_LOGIN", function()
  local map = _G.WorldMapFrame
  if type(map) == "table" and type(map.HookScript) == "function" then
    pcall(map.HookScript, map, "OnShow", function()
      if not U.Call(InCombatLockdown) then World.SetContext("map"); poke() end
    end)
  end
end)

local function timeKey(s)
  if s.indoors or s.instance then return nil end
  return s.night and "night" or s.dawn and "dawn" or s.dusk and "dusk" or nil
end
World.TimeKey = timeKey

-- A place's line, by the hour when the place has one for it (two times in three). Returns
-- the line and whether it already tells the hour.
local function placeLine(s, name, list, seed)
  local tk = timeKey(s)
  local hours = tk and name and W.PLACE_TIME[name] and W.PLACE_TIME[name][tk]
  if hours and #hours > 0 and (U.Hash(seed .. name .. "hour") % 3 ~= 0 or type(list) ~= "table") then
    return U.Pick(hours, seed .. name .. tk), true
  end
  if type(list) == "string" then return list, false end
  if type(list) == "table" and #list > 0 then return U.Pick(list, seed .. (name or "")), false end
  return nil, false
end
World.PlaceLine = placeLine

-- The moment in pieces: main (what and where), whether it tells the hour, extras (what
-- goes with it, best first) and asides (a second sentence, best first).
function World.Moment(s, seed)
  seed = seed or ""
  local m = { extras = {}, asides = {} }
  local sub = s.subzone
  local subThe = sub
  if sub and World.IsInn(sub) and not sub:find("^The ") then subThe = "the " .. sub end
  local where = U.Mid(s.zone) or "the wilds"
  local place = subThe and (U.Mid(subThe) .. (s.zone and s.zone ~= sub and (" in " .. U.Mid(s.zone)) or "")) or s.zone or "the road"
  local spot = U.Mid(subThe) or where
  local ctx = s.context
  local tags = {
    where = where, place = place, around = sub and ("around " .. place) or ("in " .. where), sub = U.Mid(sub) or where,
    pet = s.pet or "{their} companion", sea = s.sea and U.Mid(s.sea), pole = s.pole, bg = s.queued,
    who = ctx and ctx.detail or "someone", dest = ctx and ctx.detail or "afar",
    what = ctx and ctx.kind == "reading" and (ctx.detail and ("\"" .. ctx.detail .. "\"") or ctx.letter and "a letter") or "a book",
  }
  local function fill(text, over)
    if type(text) ~= "string" then return nil end
    text = text:gsub("{([%a']+)}", function(k)
      local v = over and over[k]
      if v == nil then v = tags[k] end
      if v ~= nil then return v end
    end)
    return U.Pron(text)
  end
  local function pick(list, key, over)
    if type(list) ~= "table" or #list == 0 then return nil end
    return fill(U.Pick(list, seed .. key), over)
  end
  local act = { place = spot }
  local main, timed
  if s.dead and not s.ghost then
    main = pick(W.MOMENT.fallen, "fallen")
  elseif s.ghost or s.dead then
    main = U.Hash(seed .. "ghostway") % 2 == 0 and pick(W.MOMENT.ghost, "ghost") or pick(W.TRAVEL.ghost, "ghost")
  elseif s.taxi then
    local beast
    if s.faction == "Horde" then beast = W.BAT_ZONES[s.zoneKey or ""] and "a bat" or "a wind rider"
    else beast = W.KALIMDOR[s.zoneKey or ""] and "a hippogryph" or "a gryphon" end
    main = pick(W.TRAVEL.taxi, "taxi", { beast = beast })
  elseif s.transport then
    main = pick(W.TRANSPORT[s.transport], "sea")
  elseif s.instance == "pvp" then
    local bg = W.BG_FLAVOR[s.zoneKey or ""] or W.BG_FLAVOR[s.zone or ""]
    if sub and U.Hash(seed .. "bgat") % 2 == 0 then main = pick(W.BG_AT, "bgat")
    else main = pick(bg or W.TRAVEL.battleground, "bg") end
  elseif s.falling and not s.swimming and not s.flying then
    main = pick(W.MOMENT.falling, "fall")
  elseif s.fatigue then
    main = pick(W.MOMENT.deepwater, "deep")
  elseif s.underwater then
    main = pick(W.MOMENT.underwater, "under")
  elseif ctx and ctx.kind == "craft" and W.CRAFT[ctx.detail] then
    main = U.Pick(W.CRAFT[ctx.detail], seed .. "craft") .. " in " .. spot
  elseif s.away then
    main = pick(W.ACTIVITY.away, "away", act)
  elseif ctx and W.ACTIVITY[ctx.kind] then
    main = pick(W.ACTIVITY[ctx.kind], ctx.kind, act)
  elseif s.auras and (s.auras.eating or s.auras.drinking) then
    main = pick(s.auras.eating and W.ACTIVITY.eating or W.ACTIVITY.drinking, "meal", act)
  elseif s.instance == "party" or s.instance == "raid" then
    local inst = W.INSTANCE_FLAVOR[s.zoneKey or ""] or W.INSTANCE_FLAVOR[s.zone or ""]
    if type(inst) == "string" then inst = { inst } end
    main = pick(inst or W.TRAVEL.dungeon, "inst")
  elseif s.resting and World.IsInn(sub) then
    main = pick(W.TRAVEL.inn, "inn")
  elseif s.stealthed then
    local list = (s.prowling and W.STEALTH.DRUID) or (s.rogueStealth and W.STEALTH.ROGUE) or W.TRAVEL.stealth
    main = pick(list, "stealth")
  elseif s.swimming then
    main = pick(U.Hash(seed .. "swimway") % 2 == 0 and W.MOMENT.swimming or W.TRAVEL.swimming, "swim")
  elseif s.flying then
    main = pick(W.TRAVEL.flying, "fly")
  else
    -- The place itself: a district, a town or landmark, the capital, the zone.
    local line
    if sub and W.CITY_FLAVOR[sub] then
      line, timed = placeLine(s, sub, W.CITY_FLAVOR[sub], seed)
    elseif sub and W.SUBZONE_FLAVOR[sub] then
      line, timed = placeLine(s, sub, W.SUBZONE_FLAVOR[sub], seed)
      -- "on the boardwalks of Booty Bay in Stranglethorn Vale": the land too, when the line doesn't say it.
      if line and not timed and s.zone and not s.capital and not line:find(s.zone, 1, true)
        and not line:find(" in ", 1, true) then line = line .. " in " .. U.Mid(s.zone) end
    elseif s.capital then
      line, timed = placeLine(s, s.zoneKey, W.ZONE_FLAVOR[s.zoneKey] or W.MOMENT.capital, seed)
    elseif s.resting then
      line = U.Pick(W.TRAVEL.town, seed .. "town")
    else
      local key = s.zoneKey or ""
      if (W.ZONE_FLAVOR[key] or W.PLACE_TIME[key]) and U.Hash(seed .. "flavor") % 4 ~= 0 then
        line, timed = placeLine(s, key, W.ZONE_FLAVOR[key], seed)
      end
    end
    if s.mounted then
      local mount = World.Mount(s)
      if line and U.Hash(seed .. "mountline") % 2 == 0 then
        main = fill(line)
        m.extras[#m.extras + 1] = mount
      else
        main, timed = pick(W.TRAVEL.mounted, "mounted", { mount = mount }), false
      end
    else
      main = line and fill(line) or pick(W.TRAVEL.road, "road")
    end
  end
  m.main, m.timed = main or ("in " .. where), timed and true or false

  -- Extras
  local alive = not s.dead and not s.ghost
  if alive and s.formKey and W.FORM_LINES[s.formKey] and not s.taxi and not s.transport then
    m.extras[#m.extras + 1] = U.Pick(W.FORM_LINES[s.formKey], seed .. "form" .. s.formKey)
  end
  if alive and s.grouped and s.instance ~= "pvp" and (s.groupSize or 0) >= 2 then
    local n = s.groupSize
    if s.raid then m.extras[#m.extras + 1] = pick(W.EXTRA.raid, "raid", { total = U.Number(n) })
    elseif n == 2 then m.extras[#m.extras + 1] = pick(W.EXTRA.pair, "pair")
    else m.extras[#m.extras + 1] = pick(W.EXTRA.party, "party", { n = U.Number(n - 1), total = U.Number(n) }) end
  end
  local pet = alive and petPhrase(s, seed)
  if pet then m.extras[#m.extras + 1] = pet end
  if alive and s.pole and not (ctx and ctx.kind == "fishing") then m.extras[#m.extras + 1] = pick(W.EXTRA.pole, "pole") end

  -- Asides
  if s.auras and s.auras.resSick and alive then m.ressick = pick(W.ASIDE.ressick, "ressick"); m.asides[#m.asides + 1] = m.ressick end
  if s.queued and s.instance ~= "pvp" then m.asides[#m.asides + 1] = pick(W.QUEUED, "queued") end
  if s.dnd then m.asides[#m.asides + 1] = pick(W.ASIDE.dnd, "dnd") end
  local fest = s.festival and W.FESTIVAL_TOWN[s.festival]
  if fest and alive and not s.instance then
    if s.capital then m.asides[#m.asides + 1] = pick(fest, "fest", { where = s.zone })
    elseif s.festival == "hallowsend" and s.resting and World.IsInn(sub) then m.asides[#m.asides + 1] = pick(fest, "fest", { where = "the inn" }) end
  end
  return m
end

-- "resting at the Lion's Pride Inn in Goldshire" and one thing more. Never the exact spot
-- in the open world: a profile is public, and "around Goldshire" is plenty.
-- terse: the place and what they're doing only. Returns the text and whether it tells the hour.
function World.Activity(s, seed, terse)
  local m = World.Moment(s, seed or "")
  local text = m.main
  if not terse and m.extras[1] then text = text .. ", " .. m.extras[1] end
  return text, m.timed
end

function World.TimeOfDay(s, seed)
  local key = timeKey(s)
  if not key then return nil end
  return U.Pick(W.TIME_OF_DAY[key], (seed or "") .. "tod" .. key)
end
