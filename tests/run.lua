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
C_Timer = { After = function() end, NewTicker = function() end }
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
  kills = { total = 812, byName = {} },
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
check(p.characteristics.TI == "Lightsworn", "alignment title")
check(p.characteristics.FT == "Friend of Goldshire", "full title from standing")
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

-- Switching profile pauses
currentID = "abc*"
check(not ns.TRP.Managed(), "another profile in use pauses writing")
currentID = ns.char.profileID

-- A death shakes the character
event("PLAYER_DEAD")
local m = ns.Mood.Current()
check(m.key == "shaken", "a death leaves them shaken (" .. m.key .. ")")

print("\n--- written profile ---")
print("CU: " .. tostring(p.character.CU))
print("TI: " .. tostring(p.characteristics.TI) .. " | FT: " .. tostring(p.characteristics.FT) .. " | RE: " .. tostring(p.characteristics.RE) .. " | BP: " .. tostring(p.characteristics.BP))
for _, e in ipairs(p.characteristics.MI) do print("MI " .. tostring(e.NA) .. ": " .. tostring(e.VA)) end
for _, t in ipairs(p.characteristics.PS) do print(("PS %s %d %s"):format(t.LT, t.V2, t.RT)) end
for i = 1, 3 do local g = p.misc.PE[tostring(i)]; if g then print("PE" .. i .. " " .. tostring(g.TI) .. ": " .. tostring(g.TX)) end end
print("\nPersonality:\n" .. tostring(p.about.T3.PS.TX))
print("\nHistory:\n" .. tostring(p.about.T3.HI.TX))

print(fails == 0 and "\nall passed" or ("\n" .. fails .. " failed"))
os.exit(fails == 0 and 0 or 1)
