-- More of Total RP 3's profile (0.23.0), each piece only from what the game records:
--   * Name colour (characteristics.CH) from the class colour.
--   * Profile music (about.MU) from the music of the land your hearthstone is in, else the
--     land you're in, where there's a fitting piece of the game's own music.
--   * More Additional information entries after the statistics: Faction, Guild, Level, and
--     (0.23.0, from Sources/Style.lua) Role and Speciality, each with its own switch, in the
--     same ordered block. Speciality took the place of an earlier Talents entry, which is
--     retired: an entry Auto TRP wrote under that name is taken down again.
--   * An out-of-character line in "Currently" (character.CO): what you're doing OOC
--     ("Levelling in Duskwood.", "Looking for a group in the Barrens."). Off by default.
-- Loaded after Compose.lua and before TRP.lua: the new entries join Compose.STATS before
-- TRP.lua builds its fields, so they share the statistics' order, switches, backup, restore
-- and "switched off means taken down". The name colour and music fields are in TRP.lua.
local _, ns = ...

local U, Compose = ns.U, ns.Compose
local More = {}
ns.More = More

-- Defaults (Core.lua fills them in on load like the rest).
for k, v in pairs({ namecolour = true, music = true, ooc_doing = false,
  stat_faction = true, stat_guild = true, stat_level = true, stat_talents = true,
  stat_role = true, stat_speciality = true }) do
  if ns.DEFAULTS.fields[k] == nil then ns.DEFAULTS.fields[k] = v end
end

---------------------------------------------------------------------------
-- Additional information entries
---------------------------------------------------------------------------
More.INFO = {
  { key = "faction", label = "Faction", icon = "Ability_Warrior_BattleShout" },
  { key = "guild", label = "Guild", icon = "INV_Shirt_GuildTabard_01" },
  { key = "level", label = "Level", icon = "Spell_Holy_InnerFire" },
  { key = "role", label = "Role", icon = "Ability_Warrior_DefensiveStance" },
  { key = "speciality", label = "Speciality", icon = "INV_Misc_Book_11" },
  -- Retired for Speciality (it never has a value now, so what it wrote comes down).
  { key = "talents", label = "Talents", icon = "INV_Misc_Book_11", retired = true },
}
for _, e in ipairs(More.INFO) do Compose.STATS[#Compose.STATS + 1] = e end

-- "Alliance", "Horde, Stone Guard" (an honour rank once it's a real one).
function More.Faction(world)
  local f = world and world.faction
  if f ~= "Alliance" and f ~= "Horde" then return nil end
  return f .. (world.pvpRank and (", " .. world.pvpRank) or "")
end

-- "Lamplighter of the Silver Lanterns".
function More.Guild(world)
  local g = world and world.guild
  if not g then return nil end
  if world.guildRank then return world.guildRank .. " of " .. U.Mid(g) end
  return g
end

-- "22, Cleric of the Light": the level, and the rank the Title gives for it.
function More.Level(world)
  local level = world and world.level
  if type(level) ~= "number" or level < 1 then return nil end
  local rank = Compose.Title()
  return tostring(level) .. (rank and (", " .. rank) or "")
end

-- "Healer, mostly": the role their group fights show (Sources/Style.lua).
function More.Role(style)
  local S = ns.Sources.Style
  return S and S.RoleStat(style) or nil
end

-- "Holy, 31 points" (", and 20 in Discipline" when a second tree has a share worth saying).
-- Read from the talent trees each time, so a new point shows at once.
function More.Speciality()
  local S = ns.Sources.Style
  return S and S.SpecStat({ spec = S.Spec() }) or nil
end

-- A player who had switched the Talents entry off has Speciality off too.
ns.Listen("INIT", function()
  local f = ns.db and ns.db.fields
  if f and not ns.db.specialityFrom then
    if f.stat_talents == false then f.stat_speciality = false end
    ns.db.specialityFrom = "talents"
  end
end)

local baseStats = Compose.Stats
function Compose.Stats()
  local out = baseStats()
  local world = ns.cache.world
  out.faction, out.guild, out.level = More.Faction(world), More.Guild(world), More.Level(world)
  out.role, out.speciality = More.Role(ns.cache.style), More.Speciality()
  return out
end

---------------------------------------------------------------------------
-- Name colour: the class colour, as Total RP 3 keeps it ("c79c6e"). A player's own
-- !ClassColors choice wins over the game's.
---------------------------------------------------------------------------
function More.NameColour(world)
  local class = world and world.class
  if not class then return nil end
  local function from(t)
    local c = type(t) == "table" and t[class]
    if type(c) ~= "table" or type(c.r) ~= "number" or type(c.g) ~= "number" or type(c.b) ~= "number" then return nil end
    local function byte(x) return math.floor(U.Clamp(x, 0, 1) * 255 + 0.5) end
    return ("%02x%02x%02x"):format(byte(c.r), byte(c.g), byte(c.b))
  end
  return from(_G.CUSTOM_CLASS_COLORS) or from(_G.RAID_CLASS_COLORS)
end

---------------------------------------------------------------------------
-- Profile music: the game's own music for the land your hearthstone is in, else for where
-- you are. Total RP 3 keeps it as a file ID, looked up by the music's name in its own music
-- list (LibRPMedia), so only music this client has is ever chosen.
---------------------------------------------------------------------------
More.MUSIC = {
  ["Stormwind City"] = "stormwind04_zone", ["Stormwind"] = "stormwind04_zone", ["Ironforge"] = "zone_ironforge",
  ["Darnassus"] = "zone_darnassus", ["Orgrimmar"] = "orgrimmar01_zone", ["Undercity"] = "undercity01_zone",
  ["Thunder Bluff"] = "thunderbluff_walking", ["The Crossroads"] = "zone_crossroads",
  ["Elwynn Forest"] = "dayforest", ["Teldrassil"] = "dayforest", ["Ashenvale"] = "dayforest",
  ["Duskwood"] = "dayevilforest", ["Tirisfal Glades"] = "dayevilforest", ["Silverpine Forest"] = "dayevilforest",
  ["Westfall"] = "dayplains", ["Mulgore"] = "dayplains",
  ["The Barrens"] = "daybarrendry", ["Durotar"] = "daybarrendry",
  ["Dun Morogh"] = "daymountain", ["Loch Modan"] = "daymountain", ["Alterac Mountains"] = "daymountain",
  ["Tanaris"] = "daydesert", ["Silithus"] = "daydesert",
  ["Stranglethorn Vale"] = "dayjungle", ["Un'Goro Crater"] = "dayjungle", ["Feralas"] = "dayjungle",
  ["Searing Gorge"] = "dayvolcanic", ["Burning Steppes"] = "dayvolcanic",
  ["Swamp of Sorrows"] = "soggyplace_zone", ["Dustwallow Marsh"] = "soggyplace_zone", ["Wetlands"] = "soggyplace_zone",
  ["Western Plaguelands"] = "zone_plaguelands", ["Eastern Plaguelands"] = "zone_plaguelands",
  ["Felwood"] = "zone_cursedland_felwood",
}
-- Where a hearthstone is set (an inn's town) -> the land it's in.
More.BIND_ZONE = {
  ["Goldshire"] = "Elwynn Forest", ["Northshire Abbey"] = "Elwynn Forest", ["Darkshire"] = "Duskwood",
  ["Sentinel Hill"] = "Westfall", ["Kharanos"] = "Dun Morogh", ["Thelsamar"] = "Loch Modan",
  ["Menethil Harbor"] = "Wetlands", ["Booty Bay"] = "Stranglethorn Vale", ["Gadgetzan"] = "Tanaris",
  ["Theramore Isle"] = "Dustwallow Marsh", ["Dolanaar"] = "Teldrassil", ["Astranaar"] = "Ashenvale",
  ["Razor Hill"] = "Durotar", ["Camp Taurajo"] = "The Barrens", ["Ratchet"] = "The Barrens",
  ["Bloodhoof Village"] = "Mulgore", ["Brill"] = "Tirisfal Glades", ["The Sepulcher"] = "Silverpine Forest",
  ["Stonard"] = "Swamp of Sorrows", ["Splintertree Post"] = "Ashenvale", ["Cenarion Hold"] = "Silithus",
  ["Light's Hope Chapel"] = "Eastern Plaguelands", ["Marshal's Refuge"] = "Un'Goro Crater",
  ["Thorium Point"] = "Searing Gorge", ["Camp Mojache"] = "Feralas", ["Feathermoon Stronghold"] = "Feralas",
  ["Trade District"] = "Stormwind City", ["Old Town"] = "Stormwind City", ["Dwarven District"] = "Stormwind City",
  ["Valley of Strength"] = "Orgrimmar",
}

local function musicID(name)
  local m = type(TRP3_API) == "table" and type(TRP3_API.utils) == "table" and TRP3_API.utils.music
  if type(m) == "table" and type(m.convertPathToID) == "function" then
    local id = U.Call(m.convertPathToID, name)
    if type(id) == "number" then return id end
  end
  local stub = _G.LibStub
  if type(stub) == "table" and type(stub.GetLibrary) == "function" then
    local lib = U.Call(stub.GetLibrary, stub, "LibRPMedia-1.2", true)
    if type(lib) == "table" and type(lib.GetMusicInfoByName) == "function" then
      local info = U.Call(lib.GetMusicInfoByName, lib, name)
      if type(info) == "table" and type(info.file) == "number" then return info.file end
    end
  end
end

-- Returns the file ID and the music's name, or nil.
function More.Music(world)
  if not world then return nil end
  local places = {}
  if world.bind then places[#places + 1] = More.BIND_ZONE[world.bind] or world.bind end
  if world.zoneKey then places[#places + 1] = world.zoneKey end
  for _, place in ipairs(places) do
    local name = More.MUSIC[place]
    local id = name and musicID(name)
    if id then return id, name end
  end
end

---------------------------------------------------------------------------
-- "Currently" out of character: a short line on what you're doing, from the game's own flags.
---------------------------------------------------------------------------
local function listed()
  local L = _G.C_LFGList
  if type(L) ~= "table" then return false end
  if type(L.HasActiveEntryInfo) == "function" then return U.Call(L.HasActiveEntryInfo) and true or false end
  if type(L.GetActiveEntryInfo) == "function" then return U.Call(L.GetActiveEntryInfo) ~= nil end
  return false
end

function More.Doing(world)
  if not world then return nil end
  if world.away then return "Away from keyboard." end
  local zone = world.zone and U.Mid(world.zone)
  local inZone = zone and (" in " .. zone) or ""
  if listed() then return (world.grouped and "Looking for more for a group" or "Looking for a group") .. inZone .. "." end
  if world.instance == "pvp" or world.instance == "arena" then return "In a battleground" .. (zone and (": " .. world.zone) or "") .. "." end
  if world.instance == "raid" and zone then return "Raiding " .. zone .. "." end
  if world.instance == "party" and zone then return "In " .. zone .. (world.grouped and " with a group." or ".") end
  if world.grouped then return "In a group" .. inZone .. "." end
  local max = U.Call(_G.GetMaxPlayerLevel)
  if type(max) ~= "number" then max = 60 end
  if type(world.level) == "number" and world.level < max then return "Levelling" .. inZone .. "." end
  if world.resting then return "Resting" .. inZone .. "." end
  return zone and ("Out" .. inZone .. ".") or nil
end

local baseNote = Compose.OOCNote
function Compose.OOCNote()
  local f = ns.db and ns.db.fields or {}
  local doing = f.ooc_doing and More.Doing(ns.cache and ns.cache.world)
  if doing and not f.ooc then return doing end
  if doing then return doing .. " " .. baseNote() end
  return baseNote()
end

---------------------------------------------------------------------------
-- Into the sheet (Compose.Sheet), so UI.lua passes them on like everything else.
---------------------------------------------------------------------------
local baseSheet = Compose.Sheet
function Compose.Sheet(fresh, mood, only)
  local s = baseSheet(fresh, mood, only)
  s.ooc = Compose.OOCNote()
  if s.stats then
    local world = ns.cache.world
    s.namecolour = More.NameColour(world)
    s.music, s.musicName = More.Music(world)
  end
  return s
end

-- A new talent point or group finder listing is news for the profile.
ns.On("CHARACTER_POINTS_CHANGED", function() if ns.UI then ns.UI.Poke(true) end end)
ns.On("LFG_LIST_ACTIVE_ENTRY_UPDATE", function() if ns.UI then ns.UI.Poke(false) end end)
