-- Offline test: a tiny mock of the game, Total RP 3, RPG Dialogue, Social Diary and
-- Chronicle; loads Auto TRP in TOC order and checks what it writes.
-- Run from the repo root: lua5.1 tests/run.lua
local NOW = 1795000000
local fails = 0
local function check(cond, msg)
  if cond then print("ok   " .. msg) else fails = fails + 1; print("FAIL " .. msg) end
end

---------------------------------------------------------------------------
-- Game API mock
---------------------------------------------------------------------------
local frames = {}
local function newFrame()
  local f = { scripts = {}, events = {} }
  local mt = {}
  mt.__index = function(t, k)
    if k == "RegisterEvent" then return function(self, e) self.events[e] = true end end
    if k == "SetScript" then return function(self, n, fn) self.scripts[n] = fn end end
    if k == "CreateFontString" or k == "CreateTexture" then return function() return newFrame() end end
    if k == "GetChecked" then return function() return true end end
    return function() return nil end
  end
  setmetatable(f, mt)
  frames[#frames + 1] = f
  return f
end
CreateFrame = function() return newFrame() end
UIParent = newFrame()
GetServerTime = function() return NOW end
time = function() return NOW end
local timers = {}
C_Timer = { After = function(_, fn) timers[#timers + 1] = fn end, NewTicker = function() end }
local function runTimers() local t = timers; timers = {}; for _, fn in ipairs(t) do fn() end end
DEFAULT_CHAT_FRAME = { AddMessage = function(_, m) print("     chat: " .. m:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")) end }
SlashCmdList = {}
UISpecialFrames = {}
tinsert = table.insert
StaticPopup_Show = function() end
local state = { zone = "Elwynn Forest", sub = "Lion's Pride Inn", resting = true, combat = false, grouped = false }
GetRealZoneText = function() return state.zone end
GetZoneText = GetRealZoneText
GetSubZoneText = function() return state.sub end
IsResting = function() return state.resting end
UnitAffectingCombat = function() return state.combat end
InCombatLockdown = function() return state.combat end
UnitIsDeadOrGhost = function() return false end
UnitIsGhost = function() return false end
UnitOnTaxi = function() return false end
IsMounted = function() return false end
IsSwimming = function() return false end
IsFlying = function() return false end
IsIndoors = function() return true end
IsInInstance = function() return false, "none" end
IsInGroup = function() return state.grouped end
IsInRaid = function() return false end
GetNumGroupMembers = function() return state.grouped and 3 or 0 end
UnitLevel = function() return 22 end
UnitRace = function() return "Human", "Human" end
UnitClass = function() return "Priest", "PRIEST" end
UnitFactionGroup = function() return "Alliance" end
UnitName = function() return "Aldric" end
UnitGUID = function() return "Player-1-0001" end
GetRealmName = function() return "Forever" end
GetBindLocation = function() return "Goldshire" end
UnitHealth = function() return 100 end
UnitHealthMax = function() return 100 end
GetGameTime = function() return 22, 10 end
UnitStat = function(_, i) return 0, ({ 30, 35, 40, 70, 75 })[i] end
UnitPower = function() return 800 end
UnitPowerMax = function() return 1000 end
UnitXP = function() return 950 end
UnitXPMax = function() return 1000 end
GetMoney = function() return 250000 end
GetZonePVPInfo = function() return "friendly" end
UnitExists = function() return false end
state.buffs = { "Power Word: Fortitude", "Divine Spirit", "Mark of the Wild", "Arcane Intellect" }
UnitBuff = function(_, i) return state.buffs[i] end
UnitDebuff = function() return nil end
local GEAR = { [5] = { "Robe of the Moccasin", 2, "Cloth" }, [16] = { "Staff of Westfall", 3, "Staves" },
  [19] = { "Stormwind Tabard", 1, "Miscellaneous" }, [1] = { "Crown of the Lost", 4, "Cloth" } }
GetInventoryItemLink = function(_, slot) return GEAR[slot] and ("item:" .. slot) end
GetItemInfo = function(link) local g = GEAR[tonumber(link:match("%d+"))]; if g then return g[1], link, g[2], 20, 1, "Armor", g[3] end end
GetInventoryItemDurability = function() return 40, 50 end
date = function(fmt, t) return os.date(fmt, t or NOW) end
GetNumFactions = function() return 3 end
local FACTIONS = { { "Stormwind", 7 }, { "Argent Dawn", 6 }, { "Booty Bay", 4 } }
GetFactionInfo = function(i) local f = FACTIONS[i]; return f[1], "", f[2], 0, 0, 0, false, false, false, false, true end
GetGuildInfo = function() return "The Silver Lanterns", "Lamplighter" end
GetNumSkillLines = function() return 1 end
GetSkillLineInfo = function() return "Herbalism", false, false, 120 end

---------------------------------------------------------------------------
-- Total RP 3 mock (shapes from Total RP 3's Core/Profiles.lua and Core/Player.lua)
---------------------------------------------------------------------------
local fired = {}
local profiles = {
  ["abc*"] = { profileName = "Aldric", player = {
    characteristics = { v = 1, FN = "Aldric", LN = "Venn", MI = {}, PS = {} },
    about = { v = 1, TE = 1, T1 = {}, T2 = {}, T3 = { PH = {}, PS = {}, HI = {} } },
    character = { v = 1, RP = 1, CU = "Hanging about." }, misc = { v = 1, PE = {}, ST = {} } } },
}
local currentID = "abc*"
local function deepcopy(t) if type(t) ~= "table" then return t end local o = {} for k, v in pairs(t) do o[k] = deepcopy(v) end return o end
TRP3_API = {
  globals = { player_id = "Aldric-Forever" },
  profile = {
    getPlayerCurrentProfile = function() return profiles[currentID] end,
    getPlayerCurrentProfileID = function() return currentID end,
    isProfileNameAvailable = function(n) for _, p in pairs(profiles) do if p.profileName == n then return false end end return true end,
    duplicateProfile = function(p, name) local id = "new" .. tostring(#name); local c = deepcopy(p); c.profileName = name; profiles[id] = c; return id end,
    selectProfile = function(id) currentID = id end,
  },
}
TRP3_Addon = { Events = { REGISTER_DATA_UPDATED = "REGISTER_DATA_UPDATED" },
  TriggerEvent = function(_, ev, who, id, section) fired[#fired + 1] = section end }

---------------------------------------------------------------------------
-- Source data
---------------------------------------------------------------------------
RPGDialogueCharDB = {
  schema = 7, conversations = 41,
  align = { light = 62, order = 30, honor = -12, taint = 0 },
  traits = { kind = 6, brave = 4, cautious = 1, curious = 2, witty = 1 },
  origin = { id = "human_farmhand", name = "Farmhand from the Westbrook fields",
    blurb = "I grew up hauling water for the Maclures. When the gnolls came over the river, I picked up a pitchfork and didn't put it down." },
  opinions = {
    the_light = { stance = "faith", t = NOW - 100 }, defias = { stance = "masons_wronged", t = NOW - 200 },
    peace = { stance = "for", t = NOW - 300 }, gnolls = { stance = "weird", t = NOW - 50 },
  },
  towns = { goldshire = { value = 48 }, northshire = { value = 22 }, westfall_sentinel = { value = -25 } },
  npc = {
    remy = { name = "Remy \"Two Times\"", times = 5, affinity = -4 },
    dughan = { name = "Marshal Dughan", times = 7, affinity = 6 },
    farley = { name = "Innkeeper Farley", times = 9, affinity = 4 },
  },
  zones = { ["Elwynn Forest"] = NOW - 90000, ["Westfall"] = NOW - 60000, ["Redridge Mountains"] = NOW - 20000, ["Duskwood"] = NOW - 5000 },
  threads = { elwynn_gold = { state = "resolved", beats = { a = 1, b = 2 }, t = NOW - 3600 } },
  deeds = { ["cleared:The Deadmines"] = { t = NOW - 7200, n = 1 } },
  kills = { total = 812, byName = { ["Kobold Vermin"] = 63, ["Defias Thug"] = 41, ["Prowler"] = 12 } },
  deathCount = 3,
  deaths = { { t = NOW - 80000, zone = "Elwynn Forest", killer = { name = "Hogger" } } },
  homeInn = { name = "Lion's Pride Inn" },
  drunk = 0, insanity = { level = 0 },
  journal = { { t = NOW - 600, text = "Back at the Lion's Pride. Farley poured me one on the house and wouldn't hear a word about the mines." } },
}
SocialDiaryCharDB = { data = {
  characters = { ["Player-1-0002"] = { names = { { first = "Mirelle" } }, lastSeen = NOW - 400 } },
  diary = { ["Player-1-0002"] = { tags = { "friend" }, relationship = "Sworn sister" } },
  sessions = {},
} }
ChronicleCharDB = {
  goals = { { text = "find the Defias hideout", done = false, created = NOW - 10 } },
  deaths = {}, bosses = { ["1"] = { name = "Edwin VanCleef", kills = 1, lastSuccess = NOW - 7000, instanceName = "The Deadmines" } },
  dungeons = { ["The Deadmines"] = {} }, professions = { Herbalism = { rank = 120 } }, quests = {}, zones = {}, rares = {},
  notes = { { text = "PRIVATE: do not publish" } },
}

---------------------------------------------------------------------------
-- Load Auto TRP in TOC order
---------------------------------------------------------------------------
local ns = {}
for line in io.lines("AutoTRP/AutoTRP.toc") do
  if line:match("%.lua$") then
    local path = "AutoTRP/" .. line:gsub("\\", "/")
    local chunk = assert(loadfile(path))
    chunk("AutoTRP", ns)
  end
end
local function event(name, ...)
  for _, f in ipairs(frames) do
    if f.events[name] and f.scripts.OnEvent then f.scripts.OnEvent(f, name, ...) end
  end
end
event("ADDON_LOADED", "AutoTRP")
event("PLAYER_LOGIN")

---------------------------------------------------------------------------
-- Tests
---------------------------------------------------------------------------
print("\n--- preview (no profile chosen yet) ---")
print((ns.UI.PreviewText():gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")))

check(not ns.TRP.Managed(), "nothing is written before a profile is chosen")
local ok = ns.TRP.UseCurrent()
check(not ok, "the default profile is refused")

ok = ns.UI.Setup()
check(ns.char.profileID ~= nil and ns.char.profileID ~= "abc*", "setup makes and selects a new profile")
ns.UI.Update(true)
local p = profiles[ns.char.profileID].player
check(p.character.CU and p.character.CU:find("Lion's Pride Inn"), "Currently mentions the inn: " .. tostring(p.character.CU))
check(p.characteristics.TI == "Cleric of the Light", "rank title by level (human priest): " .. tostring(p.characteristics.TI))
check(p.characteristics.FT == "Lightsworn, Friend of Goldshire", "full title: " .. tostring(p.characteristics.FT))
check(p.characteristics.PS[1].LT == "Good" and p.characteristics.PS[1].RT == "Evil", "plain good/evil bar")
for i = 1, 5 do check(p.misc.PE[tostring(i)] and p.misc.PE[tostring(i)].AC and p.misc.PE[tostring(i)].TX ~= nil, "glance " .. i .. " filled") end
check(p.about.T3.PH.TX and p.about.T3.PH.TX:find("Crown of the Lost"), "physical mentions the finest gear")
check(p.about.TE == 3 and p.about.T3.HI.TX and p.about.T3.HI.TX:find("Hogger"), "history written in template 3")
check(not p.about.T3.HI.TX:find("PRIVATE"), "Chronicle notes are never read")
check(p.misc.PE["1"] and p.misc.PE["1"].AC, "mood glance written")
check(#p.characteristics.PS >= 3, "personality bars written")
check(p.characteristics.v > 1 and p.about.v > 1 and p.misc.v > 1, "section versions bumped")
check(#fired > 0, "REGISTER_DATA_UPDATED fired")
check(profiles["abc*"].player.character.CU == "Hanging about.", "the default profile is untouched")

-- The player edits their history: Auto TRP must let it be.
p.about.T3.HI.TX = "My own story."
ns.UI.Update(true)
check(p.about.T3.HI.TX == "My own story.", "a field the player edited is left alone")
check(ns.TRP.Status("history") == "yours", "and marked as theirs")
ns.TRP.Claim("history")
ns.UI.Update(true)
check(p.about.T3.HI.TX ~= "My own story.", "claim hands it back")

-- No writes in combat
state.combat = true
p.character.CU = p.character.CU
local before = p.character.CU
state.zone, state.sub, state.resting = "Duskwood", "Raven Hill", false
ns.UI.Update(true)
check(p.character.CU == before, "nothing written in combat")
state.combat = false
ns.UI.Update(true)
check(p.character.CU ~= before, "written after combat: " .. tostring(p.character.CU))

-- Reactive: an event alone (no /atrp update) carries a change into the profile.
runTimers()
NOW = NOW + 60
state.zone, state.sub, state.resting = "Westfall", "Sentinel Hill", false
local beforeCU = p.character.CU
event("ZONE_CHANGED_NEW_AREA")
runTimers()
check(p.character.CU ~= beforeCU and p.character.CU:find("Westfall"), "a zone change reaches Currently by itself: " .. tostring(p.character.CU))
NOW = NOW + 5
state.combat = true
event("UNIT_AURA", "player")
runTimers()
state.combat = false
state.zone, state.sub = "Redridge Mountains", "Lakeshire"
event("PLAYER_REGEN_ENABLED")
NOW = NOW + 20
runTimers()
check(p.character.CU:find("Redridge") or p.character.CU:find("Lakeshire") or p.character.CU:find("Everstill"), "held during combat, written right after: " .. tostring(p.character.CU))
NOW = NOW - 85
state.zone, state.sub = "Duskwood", "Raven Hill"

-- Switching profile pauses
currentID = "abc*"
check(not ns.TRP.Managed(), "another profile in use pauses writing")
currentID = ns.char.profileID

-- Factions, guild, hooks, the mood journal
ns.char.days = {
  [os.date("%Y-%m-%d", NOW)] = { moods = { downcast = 9, ease = 2 }, zones = { Duskwood = 10 } },
  [os.date("%Y-%m-%d", NOW - 86400)] = { moods = { wonder = 5 }, zones = { Westfall = 6 } },
}
ns.Compose.Refresh()
local hist = ns.Compose.History()
check(hist:find("wears the colours of the Silver Lanterns, ranked lamplighter"), "history: guild")
check(hist:find("revered by Stormwind and honored by the Argent Dawn"), "history: reputations")
check(hist:find("These past days: downcast in Duskwood today and wide%-eyed in Westfall yesterday"), "history: these past days")
check(ns.Compose.Bearing():find("Ask them about the gold of Elwynn's mines"), "personality: conversation hooks")
state.buffs[#state.buffs + 1] = "Shadowform"
ns.Compose.Refresh()
check(ns.Compose.Currently(ns.Mood.Current()):find("wreathed in shadow"), "shapeshift form in Currently")
table.remove(state.buffs)
-- Moving a glance
ns.db.glanceSlots.marks, ns.db.glanceSlots.ambition = 4, 5
ns.char.owned[ns.char.profileID].glance_marks = nil
ns.char.owned[ns.char.profileID].glance_ambition = nil
ns.TRP.Claim("glance_marks"); ns.TRP.Claim("glance_ambition")
ns.UI.Update(true)
check(p.misc.PE["4"].TI ~= "Ambition" and p.misc.PE["5"].TI == "Ambition", "glances can swap slots")
ns.db.glanceSlots.marks, ns.db.glanceSlots.ambition = 5, 4
ns.TRP.Claim("glance_marks"); ns.TRP.Claim("glance_ambition")
ns.UI.Update(true)

check(ns.Compose.Plural("Wolf") == "Wolves" and ns.Compose.Plural("Young Harpy") == "Young Harpies" and ns.Compose.Plural("Defias Watchman") == "Defias Watchmen", "plurals")
check(hist:find("thinned the ranks of the Kobold Vermin considerably"), "history: grudge")
check(hist:find("That was one weeks? ago") == nil, "no 'one weeks'")
check(ns.Compose.RelationshipStatus() == nil, "a sworn sister is not a spouse")
SocialDiaryCharDB.data.diary["Player-1-0002"].relationship = "Wife"
ns.Compose.Refresh()
check(ns.Compose.RelationshipStatus() == 3, "a wife in Social Diary: married")
SocialDiaryCharDB.data.diary["Player-1-0002"].relationship = "Sworn sister"

-- Milestones and finds
event("PLAYER_LEVEL_UP", 30)
event("CHAT_MSG_LOOT", "You receive loot: |cffa335ee|Hitem:1|h[Blade of Hanna]|h|r.")
ns.Compose.Refresh()
local h2 = ns.Compose.History()
check(h2:find("rose to Priest in Duskwood"), "history: a rank milestone")
check(h2:find("Prized possessions: Blade of Hanna, found in Duskwood"), "history: prized possessions")
RPGDialogueCharDB.deaths[1].t = NOW - 300000
ns.Compose.Refresh()
check(ns.Compose.LatelyGlance().TI == "A New Prize", "lately: a fresh find")
RPGDialogueCharDB.deaths[1].t = NOW - 80000
ns.char.mood.emo.thrilled = nil; ns.char.mood.emo.elated = nil

-- Buffs lift the mood
ns.Compose.Refresh()
local scores = ns.Mood.Scores(ns.cache.world)
check((scores.bolstered or 0) >= 15, "four buffs: bolstered " .. tostring(scores.bolstered))
check((scores.eager or 0) >= 15, "close to a level: eager")
-- A death shakes the character, and grief lingers after
event("PLAYER_DEAD")
local m = ns.Mood.Current()
check(m.key == "shaken", "a death leaves them shaken (" .. m.key .. ")")
table.insert(RPGDialogueCharDB.deaths, { t = NOW - 1800, zone = "Duskwood" })
table.insert(RPGDialogueCharDB.deaths, { t = NOW - 600, zone = "Duskwood" })
ns.Compose.Refresh()
scores = ns.Mood.Scores(ns.cache.world)
check((scores.downcast or 0) > 30 and (scores.frustrated or 0) > 15, "recent deaths: downcast and frustrated")
-- Emotes
event("CHAT_MSG_TEXT_EMOTE", "You cry.", "Aldric")
check((ns.char.mood.emo.sorrowful or 0) > 20, "crying makes them sorrowful")
-- Manual mood and intent
ns.Mood.SetManual("smitten")
check(ns.Mood.Current().key == "smitten", "/atrp feel overrides")
ns.char.intent = { text = "looking for passage to Theramore", untilT = NOW + 100 }
ns.Compose.Refresh()
check(ns.Compose.Currently(ns.Mood.Current()):find("Looking for passage to Theramore%."), "intent appended to Currently")

print("\n--- written profile ---")
local writtenHistory = p.about.T3.HI.TX
print("CU: " .. tostring(p.character.CU))
print("TI: " .. tostring(p.characteristics.TI) .. " | FT: " .. tostring(p.characteristics.FT) .. " | RE: " .. tostring(p.characteristics.RE) .. " | BP: " .. tostring(p.characteristics.BP))
for _, e in ipairs(p.characteristics.MI) do print("MI " .. tostring(e.NA) .. ": " .. tostring(e.VA)) end
for _, t in ipairs(p.characteristics.PS) do print(("PS %s %d %s"):format(t.LT, t.V2, t.RT)) end
for i = 1, 5 do local g = p.misc.PE[tostring(i)]; if g then print("PE" .. i .. " " .. tostring(g.TI) .. ": " .. tostring(g.TX)) end end
print("\nPersonality:\n" .. tostring(p.about.T3.PS.TX))
print("\nHistory:\n" .. tostring(p.about.T3.HI.TX))
print("\nPhysical:\n" .. tostring(p.about.T3.PH.TX))

-- Restore puts everything back
local ok = ns.TRP.Restore()
check(ok and p.character.CU == "Hanging about." and p.about.TE == 1, "restore puts the profile back as it was")
check(ns.TRP.Status("history") == "yours", "after restore every field is the player's")

-- SAMPLES=1 lua5.1 tests/run.lua prints a few race/class combinations.
if os.getenv("SAMPLES") then
  local combos = { { "Scourge", "ROGUE", "Horde" }, { "Dwarf", "HUNTER", "Alliance" }, { "Tauren", "WARRIOR", "Horde" },
    { "NightElf", "PRIEST", "Alliance" }, { "Troll", "SHAMAN", "Horde" }, { "Gnome", "MAGE", "Alliance" }, { "Orc", "WARLOCK", "Horde" } }
  for i, c in ipairs(combos) do
    UnitRace = function() return c[1], c[1] end
    UnitClass = function() return c[2], c[2] end
    UnitFactionGroup = function() return c[3] end
    ns.char.seedName = "sample" .. i
    RPGDialogueCharDB.origin = nil
    local sh = ns.Compose.Sheet()
    print(("\n=== %s %s: %s / %s ==="):format(c[1], c[2], sh.title, sh.fulltitle))
    print("CU: " .. sh.currently)
    print("Mood: " .. sh.glances.mood.TX)
    print("Ambition: " .. sh.glances.ambition.TX .. " | Motto: " .. sh.motto)
    print("Physical: " .. sh.physical:gsub("\n\n", " "))
    print("History start: " .. (sh.history:match("^[^\n]+")))
  end
end

print(fails == 0 and "\nall passed" or ("\n" .. fails .. " failed"))
os.exit(fails == 0 and 0 or 1)
