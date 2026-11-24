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
function World.Safe(v)
  local fn = _G.issecretvalue
  if type(fn) == "function" then
    local ok, secret = pcall(fn, v)
    if ok and secret then return nil end
  end
  return v
end

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
  if ok and name then return World.Safe(name), World.Safe(kind), World.Safe(spellId) end
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
  if ok then return name, quality, subType end
end

function World.Gear()
  local g = { qualitySum = 0, items = 0 }
  local function slot(id)
    local link = call("GetInventoryItemLink", "player", id)
    if not link then return nil end
    return itemInfo(link)
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
  g.tabard = U.Plain((slot(19)))
  g.cloak = U.Plain((slot(15)))
  -- Durability: the worst-kept piece
  local worst
  for _, id in ipairs(SLOTS) do
    local cur, max = call("GetInventoryItemDurability", id)
    if type(cur) == "number" and type(max) == "number" and max > 0 then
      local r = cur / max
      if not worst or r < worst then worst = r end
    end
  end
  g.durability = worst
  return g
end

---------------------------------------------------------------------------
-- Bags
---------------------------------------------------------------------------
function World.FreeBagSlots()
  local free = 0
  local get = (C_Container and C_Container.GetContainerNumFreeSlots) or _G.GetContainerNumFreeSlots
  if type(get) ~= "function" then return nil end
  for bag = 0, 4 do
    local ok, n = pcall(get, bag)
    if ok and type(n) == "number" then free = free + n end
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
    local _, _, _, spellID = call("GetShapeshiftFormInfo", idx)
    local name = spellID and ((C_Spell and C_Spell.GetSpellName and U.Call(C_Spell.GetSpellName, spellID)) or call("GetSpellInfo", spellID))
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
  s.resting = call("IsResting") and true or false
  s.combat = call("UnitAffectingCombat", "player") and true or false
  s.dead = call("UnitIsDeadOrGhost", "player") and true or false
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
  local hp, max = call("UnitHealth", "player"), call("UnitHealthMax", "player")
  if type(hp) == "number" and type(max) == "number" and max > 0 then s.health = hp / max end
  local mana, manaMax = call("UnitPower", "player", 0), call("UnitPowerMax", "player", 0)
  if type(mana) == "number" and type(manaMax) == "number" and manaMax > 0 then s.mana = mana / manaMax end
  local xp, xpMax = call("UnitXP", "player"), call("UnitXPMax", "player")
  if type(xp) == "number" and type(xpMax) == "number" and xpMax > 0 then s.xp = xp / xpMax end
  s.rested = call("GetXPExhaustion")
  s.money = call("GetMoney")
  local hour = call("GetGameTime")
  s.hour = type(hour) == "number" and hour or nil
  s.night = s.hour and (s.hour >= 21 or s.hour < 5) or false
  s.dawn = s.hour and s.hour >= 5 and s.hour < 8 or false
  s.dusk = s.hour and s.hour >= 18 and s.hour < 21 or false
  s.auras = World.Auras()
  s.gear = World.Gear()
  s.freeSlots = World.FreeBagSlots()
  s.festival = World.Festival()
  if call("UnitExists", "pet") then
    s.pet = U.Plain(call("UnitName", "pet"))
    s.petKind = U.Plain(call("UnitCreatureFamily", "pet"))
  end
  s.stats = {}
  for i, name in ipairs({ "strength", "agility", "stamina", "intellect", "spirit" }) do
    local _, v = call("UnitStat", "player", i)
    if type(v) == "number" then s.stats[name] = v end
  end
  s.factions = World.Factions()
  s.professions = World.Professions()
  s.form = World.Form(s.auras)
  local guild, guildRank = call("GetGuildInfo", "player")
  s.guild, s.guildRank = U.Plain(World.Safe(guild)), U.Plain(World.Safe(guildRank))
  local pvpRank = call("UnitPVPRank", "player")
  if type(pvpRank) == "number" and pvpRank >= 5 then s.pvpRank = U.Plain((call("GetPVPRankInfo", pvpRank))) end
  s.raid = call("IsInRaid") and true or false
  s.context = World.Context()
  return s
end

---------------------------------------------------------------------------
-- What you're busy with: set by events, kept for a few minutes.
---------------------------------------------------------------------------
local context
World.CONTEXT_SECONDS = 180

function World.SetContext(kind, detail)
  context = { kind = kind, detail = detail, t = U.Now() }
end

function World.Context()
  if context and U.Now() - context.t <= World.CONTEXT_SECONDS then return context end
  return nil
end

ns.On("MAIL_SHOW", function() World.SetContext("mail") end)
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
ns.On("UNIT_SPELLCAST_CHANNEL_START", function(_, unit, _, spellID)
  if unit ~= "player" then return end
  local name = World.Safe(call("UnitChannelInfo", "player"))
  if name == "Fishing" or spellID == 7620 or spellID == 7731 or spellID == 7732 or spellID == 18248 then
    World.SetContext("fishing")
  end
end)

-- Inns and taverns, by the words in their names.
local INN_WORDS = { "Inn", "Tavern", "Rest", "Lodge", "Hall", "Barracks", "Hostel", "Brewery" }
function World.IsInn(sub)
  if type(sub) ~= "string" then return false end
  for _, w in ipairs(INN_WORDS) do if sub:find(w) then return true end end
  return false
end

local function petPhrase(s, seed)
  if not s.pet or s.mounted or s.taxi then return nil end
  local list = W.PET[s.class or ""]
  if not list then return nil end
  local p = U.Pick(list, seed .. "pet")
  return (p:gsub("{pet}", s.pet):gsub("{kind}", (s.petKind or "companion"):lower()))
end

-- "resting at the Lion's Pride Inn in Goldshire" etc. Never the exact spot in the open
-- world: a profile is public, and "around Goldshire" is plenty.
function World.Activity(s, seed)
  local sub = s.subzone
  if sub and World.IsInn(sub) and not sub:find("^The ") then sub = "the " .. sub end
  local place = sub and (U.Mid(sub) .. ", " .. (s.zone or "")) or s.zone or "the road"
  local where = U.Mid(s.zone) or "the wilds"
  local text
  if s.ghost or s.dead then
    return U.Pick({ "a restless spirit drifting near " .. where, "somewhere between this world and the next, near " .. where }, seed)
  end
  if s.taxi then return U.Pick({ "on the wing over " .. where, "riding a flight over " .. where }, seed) end
  local ctx = s.context
  if ctx and ctx.kind == "craft" then
    text = W.CRAFT[ctx.detail] .. " in " .. (U.Mid(s.subzone) or where)
  elseif ctx and W.ACTIVITY[ctx.kind] then
    text = U.Pick(W.ACTIVITY[ctx.kind], seed .. ctx.kind):gsub("{place}", U.Mid(s.subzone) or where)
  elseif s.auras and (s.auras.eating or s.auras.drinking) then
    local list = s.auras.eating and W.ACTIVITY.eating or W.ACTIVITY.drinking
    text = U.Pick(list, seed .. "meal"):gsub("{place}", U.Mid(s.subzone) or where)
  elseif s.instance == "party" or s.instance == "raid" then
    text = U.Pick({ "deep inside " .. where, "delving into " .. where }, seed)
  elseif s.instance == "pvp" then
    text = "fighting for the banner in " .. where
  elseif s.resting and World.IsInn(s.subzone) then
    text = U.Pick({ "resting at " .. place, "warming up by the fire at " .. place, "taking a room at " .. place }, seed)
  elseif s.resting then
    text = U.Pick({ "about the streets of " .. place, "passing through " .. place }, seed)
  elseif s.stealthed then
    text = "keeping to the shadows " .. (s.subzone and ("around " .. place) or ("in " .. where))
  elseif s.swimming then
    text = "wading through the waters of " .. where
  elseif s.flying then
    text = "flying over " .. where
  elseif s.mounted then
    text = U.Pick({ "riding through " .. where, "on horseback in " .. where }, seed)
  else
    local flavor = W.ZONE_FLAVOR[s.zone or ""]
    if flavor and U.Hash(seed .. "flavor") % 3 ~= 0 then
      text = U.Pick(flavor, seed .. "fl")
    else
      local around = s.subzone and ("around " .. place) or ("in " .. where)
      text = U.Pick({ "on the road " .. around, "out " .. around, "travelling " .. around }, seed)
    end
  end
  if s.form and not s.taxi then text = text .. ", " .. s.form end
  local pet = petPhrase(s, seed)
  if pet then text = text .. ", " .. pet end
  return text
end

function World.TimeOfDay(s)
  if s.indoors or s.instance then return nil end
  if s.night then return "under the stars" end
  if s.dawn then return "at first light" end
  if s.dusk then return "as the light goes" end
  return nil
end
