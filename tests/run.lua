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
    if k == "RegisterUnitEvent" then return function(self, e, unit) self.events[e] = true; self.unit = unit end end
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
StaticPopupDialogs = {}
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
    if f.events[name] and f.scripts.OnEvent and (not rawget(f, "unit") or rawget(f, "unit") == (...)) then f.scripts.OnEvent(f, name, ...) end
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
check(p.about.TE == 3 and p.about.T3.HI.TX and p.about.T3.HI.TX:find("Lion's Pride"), "history written in template 3")
check(not p.about.T3.HI.TX:find("died"), "deaths stay out of the History prose")
local statDeaths
for _, e in ipairs(p.characteristics.MI) do if e.ID == 1 and e.NA == "Deaths" then statDeaths = e.VA end end
check(statDeaths == "3, the first to Hogger", "deaths are a statistic: " .. tostring(statDeaths))
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

-- Contexts: talking, reading, AFK; mounts and flights by race and faction
UnitName = function(u) if u == "npc" then return "Innkeeper Farley" end return "Aldric" end
state.zone, state.sub, state.resting = "Elwynn Forest", "Lion's Pride Inn", true
event("GOSSIP_SHOW")
ns.Compose.SourcesChanged(); ns.Compose.Refresh()
check(ns.Compose.Currently(ns.Mood.Current()):find("with Innkeeper Farley in the Lion's Pride Inn"), "talking with an NPC: " .. ns.Compose.Currently(ns.Mood.Current()))
ns.World.SetContext("none")
UnitIsAFK = function() return true end
ns.Compose.SourcesChanged(); ns.Compose.Refresh()
check(ns.Compose.Currently(ns.Mood.Current()):find("lost in thought") or ns.Compose.Currently(ns.Mood.Current()):find("middle distance"), "AFK reads as lost in thought")
UnitIsAFK = function() return false end
state.resting = false
IsMounted = function() return true end
ns.Compose.SourcesChanged(); ns.Compose.Refresh()
check(ns.Compose.Currently(ns.Mood.Current()):find("on horseback through"), "a human rides a horse")
state.buffs[#state.buffs + 1] = "Summon Felsteed"
ns.Compose.SourcesChanged(); ns.Compose.Refresh()
check(ns.Compose.Currently(ns.Mood.Current()):find("fel%-fire steed"), "a felsteed by its name")
table.remove(state.buffs)
IsMounted = function() return false end
UnitOnTaxi = function() return true end
state.zone = "Darkshore"
ns.Compose.SourcesChanged(); ns.Compose.Refresh()
check(ns.Compose.Currently(ns.Mood.Current()):find("hippogryph"), "Alliance over Kalimdor: a hippogryph")
UnitOnTaxi = function() return false end
UnitName = function() return "Aldric" end
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
ns.Compose.SourcesChanged(); ns.Compose.Refresh()
local hist = ns.Compose.History()
check(hist:find("Wears the colours of the Silver Lanterns and holds the rank of lamplighter there"), "history: guild")
check(hist:find("Has done good work for Stormwind and the Argent Dawn"), "history: reputations")
check(hist:find("Felt downcast in Duskwood today and wide%-eyed in Westfall yesterday"), "history: these past days")
check(ns.Compose.Bearing():find("Has stories about the gold of Elwynn's mines"), "personality: conversation hooks")
state.buffs[#state.buffs + 1] = "Shadowform"
ns.Compose.SourcesChanged(); ns.Compose.Refresh()
check(ns.Compose.Currently(ns.Mood.Current()):find("wreathed in shadow"), "shapeshift form in Currently")
table.remove(state.buffs)
-- Moving a glance with /atrp slot: the two swap, and Auto TRP keeps both
SlashCmdList.AUTOTRP("slot marks 4")
check(p.misc.PE["4"].TI ~= "Ambition" and p.misc.PE["5"].TI == "Ambition", "glances swap slots")
check(ns.TRP.Status("glance_marks") == "auto" and ns.TRP.Status("glance_ambition") == "auto", "and neither is given up")
SlashCmdList.AUTOTRP("slot marks 5")

-- Buffs lift the mood
ns.Compose.SourcesChanged(); ns.Compose.Refresh()
local scores = ns.Mood.Scores(ns.cache.world)
check((scores.bolstered or 0) >= 15, "four buffs: bolstered " .. tostring(scores.bolstered))
check((scores.eager or 0) >= 15, "close to a level: eager")
-- A death shakes the character, and grief lingers after
event("PLAYER_DEAD")
local m = ns.Mood.Current()
check(m.key == "shaken", "a death leaves them shaken (" .. m.key .. ")")
table.insert(RPGDialogueCharDB.deaths, { t = NOW - 1800, zone = "Duskwood" })
table.insert(RPGDialogueCharDB.deaths, { t = NOW - 600, zone = "Duskwood" })
ns.Compose.SourcesChanged(); ns.Compose.Refresh()
scores = ns.Mood.Scores(ns.cache.world)
check((scores.downcast or 0) > 30 and (scores.frustrated or 0) > 15, "recent deaths: downcast and frustrated")
-- Emotes
event("CHAT_MSG_TEXT_EMOTE", "You cry.", "Aldric")
check((ns.char.mood.emo.sorrowful or 0) > 20, "crying makes them sorrowful")
-- Manual mood and intent
ns.Mood.SetManual("smitten")
check(ns.Mood.Current().key == "smitten", "/atrp feel overrides")
ns.char.intent = { text = "looking for passage to Theramore", untilT = NOW + 100 }
ns.Compose.SourcesChanged(); ns.Compose.Refresh()
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

-- Review fixes
-- 1. Paused while OOC: no one-second loop.
runTimers()
ns.db.pauseOOC = true
p.character.RP = 2
ns.UI.Update(false)
local queued = #timers
ns.UI.Update(false)
check(#timers <= 1 and queued <= 1, "paused while OOC: nothing keeps rescheduling (" .. #timers .. ")")
runTimers(); runTimers()
check(#timers == 0, "and the loop doesn't continue")
p.character.RP = 1
ns.db.pauseOOC = false
-- 2. An editor saving an older copy over Auto TRP's text is rewritten, not taken as yours.
NOW = NOW + 400
local mine = ns.TRP.Owned()
p.about.T3.HI.TX = "Old text."
mine.history = "Something newer"
ns.db.previous[ns.char.profileID].history = "Old text."
ns.TRP.Apply({ history = "Fresh history." }, { history = true })
check(p.about.T3.HI.TX == "Fresh history." and ns.TRP.Status("history") == "auto", "an editor's revert is rewritten, not released")
-- 3. While TRP3's editor is open, About and characteristics wait.
TRP3_API.navigation = { page = { getCurrentContext = function() return { isEditMode = true } end } }
ns.TRP.Apply({ history = "While editing." }, { history = true })
check(p.about.T3.HI.TX == "Fresh history.", "nothing written into an open editor's section")
TRP3_API.navigation = nil
-- 4. A switched-off glance with the player's words is theirs.
p.misc.PE["9"] = nil
ns.char.glanceSlots.marks = 6
p.misc.PE["6"] = { AC = false, TI = "My scar", TX = "Ask me about it." }
ns.TRP.Owned().glance_marks = nil
ns.UI.Update(true)
check(p.misc.PE["6"].TX == "Ask me about it." and ns.TRP.Status("glance_marks") == "yours", "a switched-off glance with your text is left alone")
ns.char.glanceSlots.marks = 5
NOW = NOW - 400
-- 5. Restore only touches what Auto TRP wrote.
table.insert(p.characteristics.MI, { ID = 7, NA = "Pronouns", VA = "he/him" })

-- Race and class places, spells
UnitRace = function() return "Night Elf", "NightElf" end
state.zone, state.sub = "Felwood", "Emerald Sanctuary"
ns.Compose.SourcesChanged(); ns.Compose.Refresh()
local sc, wy = ns.Mood.Scores(ns.cache.world)
local felwood = false
for _, r in ipairs(wy.sorrowful or {}) do if r == "a corrupted forest" then felwood = true end end
check(felwood, "a night elf grieves in Felwood")
UnitRace = function() return "Human", "Human" end
state.zone, state.sub = "Orgrimmar", "Valley of Strength"
ns.Compose.Refresh()
sc = ns.Mood.Scores(ns.cache.world)
check((sc.tense or 0) >= 15, "an Alliance character in Orgrimmar is tense (brave, so a little less)")
state.zone, state.sub = "Duskwood", "Raven Hill"
C_Spell = { GetSpellName = function(id) return ({ [2006] = "Resurrection", [10059] = "Portal: Stormwind" })[id] end }
event("UNIT_SPELLCAST_SUCCEEDED", "player", "cast", 2006)
check((ns.char.mood.emo.righteous or 0) > 20, "resurrecting someone feels righteous")
event("UNIT_SPELLCAST_SUCCEEDED", "player", "cast", 10059)
ns.Compose.Refresh()
check(ns.Compose.Currently(ns.Mood.Current()):find("opening a portal to Stormwind"), "a mage's portal shows in Currently: " .. ns.Compose.Currently(ns.Mood.Current()))
ns.World.SetContext("none")
C_Spell = nil

-- Temperament by race and class; the hour by race; the last conversation
UnitRace = function() return "Dwarf", "Dwarf" end
ns.Compose.Refresh()
check(ns.Mood.Bias("merry") > 1.3, "a dwarf takes to drink merrily")
UnitRace = function() return "Night Elf", "NightElf" end
IsIndoors = function() return false end
state.resting = false
ns.Compose.Refresh()
local sc2, wy2 = ns.Mood.Scores(ns.cache.world)
local night = false
for _, r in ipairs(wy2.ease or {}) do if r:find("^the night suits") then night = true end end
check(night, "a night elf is at ease at night")
UnitRace = function() return "Human", "Human" end
IsIndoors = function() return true end
RPGDialogueCharDB.npc.farley.last = NOW - 60
RPGDialogueCharDB.npc.farley.zone = "Elwynn Forest"
local savedDeath = RPGDialogueCharDB.deaths[1].t
RPGDialogueCharDB.deaths[1].t = NOW - 300000
for _, d in ipairs(RPGDialogueCharDB.deaths) do if d.t > NOW - 300000 then d.t = NOW - 300000 end end
ns.char.finds = nil
ns.Compose.SourcesChanged(); ns.Compose.Refresh()
local lg = ns.Compose.LatelyGlance()
check(lg.TX:find("Was just talking warmly with Innkeeper Farley in Elwynn Forest"), "Lately: a conversation just now: " .. lg.TX)
RPGDialogueCharDB.deaths[1].t = savedDeath

-- Dungeon atmosphere; meeting a friend
IsInInstance = function() return true, "party" end
state.zone, state.sub = "The Deadmines", nil
ns.Compose.Refresh()
check(ns.Compose.Currently(ns.Mood.Current()):find("dripping tunnels of the Deadmines"), "dungeon atmosphere")
IsInInstance = function() return false, "none" end
state.zone, state.sub = "Duskwood", "Raven Hill"
UnitIsPlayer = function() return true end
UnitName = function(u) if u == "target" then return "Mirelle" end return "Aldric" end
ns.char.mood.emo.elated = nil
event("PLAYER_TARGET_CHANGED")
check((ns.char.mood.emo.elated or 0) > 10 and ns.char.mood.why.elated == "ran into Mirelle", "running into a Social Diary friend")
UnitName = function() return "Aldric" end

-- City districts; reputation; enemies
state.zone, state.sub, state.resting = "Ironforge", "The Great Forge", true
ns.Compose.Refresh()
check(ns.Compose.Currently(ns.Mood.Current()):find("heat and clangour of the Great Forge"), "city district in Currently")
state.zone, state.sub, state.resting = "Duskwood", "Raven Hill", false
event("CHAT_MSG_SYSTEM", "You are now Revered with Argent Dawn.")
check(ns.char.honours and ns.char.honours[1].standing == "Revered", "a new standing is remembered")
ns.Compose.Refresh()
check(ns.Compose.History():find("earned revered standing with the Argent Dawn"), "and told in History")
UnitIsPlayer = function() return true end
UnitFactionGroup = function(u) if u == "target" then return "Horde" end return "Alliance" end
UnitName = function(u) if u == "target" then return "Grukk" end return "Aldric" end
UnitRace = function(u) if u == "target" then return "Orc", "Orc" end return "Human", "Human" end
ns.char.mood.emo.tense = nil
event("PLAYER_TARGET_CHANGED")
check((ns.char.mood.emo.tense or 0) > 5 and ns.char.mood.why.tense == "face to face with an enemy orc", "an enemy orc makes them tense")
UnitFactionGroup = function() return "Alliance" end
UnitName = function() return "Aldric" end
UnitRace = function() return "Human", "Human" end

-- Lately: a fight, a job
RPGDialogueCharDB.deaths[1].t = NOW - 300000
for _, d in ipairs(RPGDialogueCharDB.deaths) do if d.t > NOW - 300000 then d.t = NOW - 300000 end end
ns.char.finds = nil
RPGDialogueCharDB.npc.farley.last = NOW - 90000
UnitCanAttack = function() return true end
UnitIsPlayer = function() return false end
UnitClassification = function() return "normal" end
UnitName = function(u) if u == "target" then return "Defias Pillager" end return "Aldric" end
event("PLAYER_REGEN_DISABLED")
UnitName = function() return "Aldric" end
event("PLAYER_REGEN_ENABLED")
ns.Compose.SourcesChanged(); ns.Compose.Refresh()
check(ns.Compose.LatelyGlance().TX == "Fresh from a fight with a Defias Pillager.", "Lately: a fight just now: " .. ns.Compose.LatelyGlance().TX)
UnitClassification = function() return "worldboss" end
UnitName = function(u) if u == "target" then return "Hogger" end return "Aldric" end
event("PLAYER_REGEN_DISABLED")
UnitName = function() return "Aldric" end
event("PLAYER_REGEN_ENABLED")
check(ns.Compose.LatelyGlance().TX == "Fresh from a fight with Hogger.", "a named foe takes no article")
ns.char.lastFight = nil
ChronicleCharDB.quests = { { time = NOW - 30, title = "The Collector", status = "completed", zone = "Elwynn Forest" } }
ns.Compose.SourcesChanged(); ns.Compose.Refresh()
check(ns.Compose.LatelyGlance().TX:find('Just saw a job through: "The Collector", in Elwynn Forest'), "Lately: a job just done")
ChronicleCharDB.quests = {}

-- Fading moods; Currently stays short
ns.Mood.SetManual(nil)
for k in pairs(ns.char.mood.emo) do ns.char.mood.emo[k] = nil end
state.buffs = {}
ns.char.mood.emo.wonder = 26
state.zone, state.sub, state.resting = "Westfall", nil, false
GetGameTime = function() return 12, 0 end
GetMoney = function() return 99999999 end
UnitXP = function() return 100 end
ns.char.mood.road, ns.char.mood.lastSocial = 0, NOW
ns.char.lastFight = nil
ns.Compose.Refresh()
local fm = ns.Mood.Current(ns.cache.world)
check(fm.key == "wonder" and fm.adj:find("^Still "), "a fading feeling reads 'Still ...': " .. fm.key .. " / " .. fm.adj)
GetGameTime = function() return 22, 10 end
UnitXP = function() return 950 end
state.zone, state.sub = "Duskwood", "Raven Hill"
ns.char.intent = { text = string.rep("looking for a very particular someone ", 3), untilT = NOW + 100 }
check(#ns.Compose.Currently(fm) <= 200 or ns.Compose.Currently(fm):find("Looking for"), "a long Currently is trimmed (or only the intent is long)")
ns.char.intent = nil

-- A party by class; a raid
state.grouped = true
IsInGroup = function() return true end
UnitExists = function(u) return u == "party1" or u == "party2" or u == "party3" end
UnitClass = function(u)
  if u == "party1" then return "Priest", "PRIEST" elseif u == "party2" or u == "party3" then return "Warrior", "WARRIOR" end
  return "Priest", "PRIEST"
end
GetNumGroupMembers = function() return 4 end
ns.Compose.Refresh()
check(ns.Compose.CompanyGlance().TX == "Travelling with a priest and two warriors.", "party by class: " .. ns.Compose.CompanyGlance().TX)
IsInRaid = function() return true end
GetNumGroupMembers = function() return 20 end
ns.Compose.Refresh()
check(ns.Compose.CompanyGlance().TX:find("host of twenty") or ns.Compose.CompanyGlance().TX:find("host of 20"), "a raid is a host")
IsInRaid = function() return false end
IsInGroup = function() return state.grouped end
state.grouped = false
UnitExists = function() return false end
GetNumGroupMembers = function() return 0 end

-- Walk-ups follow the mood (when switched on)
ns.db.fields.walkup = true
ns.Mood.SetManual("sociable")
ns.UI.Update(true)
check(p.character.WU == 2, "sociable: open to walk-ups")
ns.Mood.SetManual("angry")
NOW = NOW + 30
ns.UI.Update(true)
check(p.character.WU == 1, "angry: not open to walk-ups")
ns.Mood.SetManual("wonder")
NOW = NOW + 30
ns.UI.Update(true)
check(p.character.WU == 1 and ns.TRP.Status("walkup") == "auto", "a neutral mood leaves it as it was")
ns.Mood.SetManual(nil)
NOW = NOW - 60

-- A hunter's pet falls; a new character wonders
UnitClass = function() return "Hunter", "HUNTER" end
UnitName = function(u) if u == "pet" then return "Fang" end return "Aldric" end
UnitIsDeadOrGhost = function(u) return u == "pet" end
ns.char.mood.emo.sorrowful = nil
event("UNIT_HEALTH", "pet")
check((ns.char.mood.emo.sorrowful or 0) > 20 and ns.char.mood.why.sorrowful == "Fang fell", "a hunter grieves a fallen pet")
UnitIsDeadOrGhost = function() return false end
UnitClass = function() return "Priest", "PRIEST" end
UnitName = function() return "Aldric" end
UnitLevel = function() return 3 end
ns.Compose.Refresh()
local sc3 = ns.Mood.Scores(ns.cache.world)
check((sc3.wonder or 0) >= 15, "a new character finds the world new")
UnitLevel = function() return 22 end

-- Second review fixes
ns.char.mood.emo.proud = nil
event("CHAT_MSG_COMBAT_FACTION_CHANGE", "Reputation with Stormwind increased by 25.")
local p1 = ns.char.mood.emo.proud or 0
event("CHAT_MSG_COMBAT_FACTION_CHANGE", "Reputation with Stormwind increased by 25.")
check(p1 > 0 and (ns.char.mood.emo.proud or 0) == p1, "reputation ticks are throttled per faction")
local nFinds = #(ns.char.finds or {})
event("CHAT_MSG_LOOT", "You create: |cffa335ee|Hitem:2|h[Lionheart Helm]|h|r.")
check(#(ns.char.finds or {}) == nFinds, "crafting isn't a find")
ns.char.honours = nil
event("CHAT_MSG_COMBAT_FACTION_CHANGE", "You are now Exalted with Ironforge.")
check(ns.char.honours and ns.char.honours[1].standing == "Exalted", "a new standing via the reputation channel")

-- A German client: the zone's own name differs, its map ID doesn't
C_Map = { GetBestMapForUnit = function() return 1448 end }
GetLocale = function() return "deDE" end
UnitRace = function() return "Nachtelf", "NightElf" end
state.zone, state.sub = "Teufelswald", nil
ns.Compose.Refresh()
local sc4, wy4 = ns.Mood.Scores(ns.cache.world)
local found = false
for _, r in ipairs(wy4.sorrowful or {}) do if r == "a corrupted forest" then found = true end end
check(found, "zone touches work on a German client (Felwood by map ID)")
C_Map = nil
GetLocale = function() return "enUS" end
UnitRace = function() return "Human", "Human" end
C_Spell = { GetSpellName = function(id) return ({ [2575] = "Mining" })[id] end }
event("UNIT_SPELLCAST_SUCCEEDED", "player", "cast", 2575)
ns.Compose.Refresh()
check(ns.Compose.Currently(ns.Mood.Current()):find("mineral vein") or ns.Compose.Currently(ns.Mood.Current()):find("chipping ore"), "mining shows in Currently")
ns.World.SetContext("none")
C_Spell = nil
state.zone, state.sub = "Duskwood", "Raven Hill"

-- A hard week
ns.char.days = {}
for i = 0, 4 do ns.char.days[os.date("%Y-%m-%d", NOW - i * 86400)] = { moods = { downcast = 5 }, zones = { Duskwood = 5 } } end
local wt = ns.Compose.WeekTone()
check(wt == ns.Words.WEEK_TONE.hard[1] or wt == ns.Words.WEEK_TONE.hard[2], "a run of bad days is noticed: " .. tostring(wt))
ns.char.days = {}

-- Changing your tune; lies found out; letters
RPGDialogueCharDB.opinions.night_elves = { stance = "admire", t = NOW - 10, contradicts = { stance = "distrust" } }
RPGDialogueCharDB.claims = { player = { a = {}, b = {} }, exposed = { a = NOW } }
RPGDialogueCharDB.letters = { l1 = { arrived = NOW }, l2 = { arrived = NOW }, l3 = { arrived = NOW } }
ns.Compose.SourcesChanged(); ns.Compose.Refresh()
check(ns.Compose.Bearing():find("Used to feel differently about the night elves"), "Personality: changed tune")
check(ns.Compose.Bearing():find("caught in a lie"), "History: a lie found out")
check(ns.Compose.History():find("letters find %a+ on the road"), "History: letters received")
RPGDialogueCharDB.opinions.night_elves = nil

-- Restore puts everything back
local ok = ns.TRP.Restore()
check(ok and p.character.CU == "Hanging about." and p.about.TE == 1, "restore puts the profile back as it was")
local kept = false
for _, e in ipairs(p.characteristics.MI) do if e.ID == 7 then kept = true end end
check(kept, "restore keeps what you added since")
check(ns.TRP.Status("history") == "yours", "after restore every field is the player's")

-- Banned phrases (tests/banned_phrases.txt): never in the wording, never in what's written.
do
  local banned = {}
  for line in io.lines("tests/banned_phrases.txt") do
    if not line:match("^%s*#") and line:match("%S") then
      local phrase, max = line:match("^(.-)%s*|%s*max%s*(%d+)%s*$")
      banned[#banned + 1] = { phrase = (phrase or line):gsub("^%s+", ""):gsub("%s+$", ""):lower(), max = tonumber(max) or 0 }
    end
  end
  local source = {}
  for _, f in ipairs({ "AutoTRP/Data/Words.lua", "AutoTRP/Compose.lua", "AutoTRP/Mood.lua", "AutoTRP/Sources/World.lua" }) do
    for line in io.lines(f) do
      if not line:match("^%s*%-%-") then source[#source + 1] = (line:gsub("%-%-[^\"]*$", "")):lower() end
    end
  end
  local text = table.concat(source, "\n")
  local sh = ns.Compose.Sheet()
  local written = table.concat({ sh.bearing or "", sh.history or "", sh.physical or "", sh.currently or "" }, "\n"):lower()
  for _, g in pairs(sh.glances) do written = written .. "\n" .. (g.TX or ""):lower() end
  local bad = {}
  for _, b in ipairs(banned) do
    local n, i = 0, 1
    while true do
      local s = text:find(b.phrase, i, true)
      if not s then break end
      n, i = n + 1, s + 1
    end
    if n > b.max then bad[#bad + 1] = b.phrase .. " (" .. n .. ")" end
    if b.max == 0 and written:find(b.phrase, 1, true) then bad[#bad + 1] = b.phrase .. " (in the profile)" end
  end
  check(#bad == 0, "no banned phrases: " .. table.concat(bad, ", "))
end

-- Nothing in the looks and moods names gear, kit or a feature the game can't back up.
do
  local W = ns.Words
  local nouns = {}
  for line in io.lines("tests/unbacked_nouns.txt") do
    if not line:match("^%s*#") and line:match("%S") then nouns[#nouns + 1] = line:gsub("%s+$", ""):lower() end
  end
  local lists = {}
  local function add(t) if type(t) == "table" then lists[#lists + 1] = t end end
  for _, m in pairs(W.MOODS) do add(m.tells) end
  for _, m in pairs(W.CALM) do add(m.tells) end
  for _, f in pairs(W.FESTIVALS) do add(f.tells) end
  for _, t in pairs(W.RACE_TELLS) do for _, l in pairs(t) do add(l) end end
  for _, t in pairs(W.CLASS_TELLS) do for _, l in pairs(t) do add(l) end end
  for _, l in pairs(W.RACE_LOOK) do add(l) end
  for _, l in pairs(W.CLASS_LOOK) do add(l) end
  for _, l in pairs(W.PHYSIQUE) do add(l) end
  local bad = {}
  for _, list in ipairs(lists) do
    for _, line in ipairs(list) do
      local plain = " " .. line:gsub("{%l+}", ""):lower():gsub("[^%a' ]", " ") .. " "
      for _, n in ipairs(nouns) do
        if plain:find(" " .. n .. "s? ") then bad[#bad + 1] = n .. ": " .. line end
      end
    end
  end
  check(#bad == 0, "looks and moods only name what the game backs up: " .. table.concat(bad, " | "))

  -- Gear tags: a line naming a hat is used only when there is a hat, by its real name.
  local world = { gear = { names = { [16] = "Staff of Westfall" } } }
  check(ns.U.Backed("Polishing {their} {head} in silence.", world) == nil, "no helm, no line about a helm")
  check(ns.U.Backed("Leaning on {their} {mainhand}.", world) == "Leaning on {their} Staff of Westfall.", "a weapon by its own name")
  world.gear.names[1] = "Crown of the Lost"
  check(ns.U.Backed("Polishing {their} {head} in silence.", world) == "Polishing {their} Crown of the Lost in silence.", "a helm by its own name")
  check(ns.U.Backed("Brushing out {pet}'s coat.", world) == nil, "no pet, no line about one")
end

-- Reagents are told only when they're in the bags.
do
  local oldClass, oldCount = UnitClass, GetItemCount
  UnitClass = function() return "Warlock", "WARLOCK" end
  GetItemCount = function() return 0 end
  ns.World.Invalidate(); ns.Compose.Refresh()
  check(not ns.Compose.Physical():find("Soul Shard"), "no shards in the bags, none in the profile")
  GetItemCount = function(id) return id == 6265 and 12 or 0 end
  ns.World.Invalidate(); ns.Compose.Refresh()
  check(ns.Compose.Physical():find("Keeps twelve Soul Shards in %a+ bags"), "shards in the bags: " .. ns.Compose.Physical())
  UnitClass, GetItemCount = oldClass, oldCount
  ns.World.Invalidate(); ns.Compose.Refresh()
end

-- Gear wear follows the game's durability, naming the worst piece.
do
  local g = ns.cache.world.gear
  local d, w = g.durability, g.worstName
  g.worstName = "Robe of the Moccasin"
  g.durability = 0
  check(ns.Compose.Wear(ns.cache.world).text:find("Robe of the Moccasin is broken outright"), "broken gear: " .. ns.Compose.Wear(ns.cache.world).text)
  g.durability = 0.5
  check(ns.Compose.Wear(ns.cache.world).text:find("shows hard use"), "half-worn gear")
  check(ns.Compose.MarksGlance().TI ~= "Battered Kit", "half-worn gear isn't battered")
  g.durability = 0.9
  check(ns.Compose.Wear(ns.cache.world) == nil, "nearly whole gear says nothing")
  g.durability = 1
  check(ns.Compose.Wear(ns.cache.world).text:find("well kept"), "whole gear is well kept")
  g.durability, g.worstName = d, w
end

-- A coin pouch only when they carry coin.
do
  local world = ns.cache.world
  local m = world.money
  check(ns.U.Backed("{their} {pouch} is light", world) == "{their} coin pouch is light", "a coin pouch when there's coin")
  world.money = 0
  check(ns.U.Backed("{their} {pouch} is light", world) == nil, "no coin, no pouch")
  world.money = m
end

-- Statistics: each has its own switch, and wealth is told by the purse.
do
  local sh = ns.Compose.Sheet()
  check(sh.stats.wealth and sh.stats.wealth:find("gold"), "wealth statistic: " .. tostring(sh.stats.wealth))
  check(sh.history:find(ns.Compose.WealthBand(ns.cache.world).flair:sub(1, 12), 1, true), "wealth flair in History")
  ns.db.fields.stat_wealth = false
  check(not ns.TRP.Enabled("stat_wealth") and ns.TRP.Enabled("stat_lands"), "one statistic switched off, the rest on")
  ns.db.fields.stats = false
  check(not ns.TRP.Enabled("stat_lands"), "the master switch turns all statistics off")
  ns.db.fields.stats, ns.db.fields.stat_wealth = true, true
end

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
    print("\n-- Personality --\n" .. sh.bearing)
    print("\n-- History --\n" .. sh.history)
    print("\n-- Physical --\n" .. sh.physical)
  end
end

print(fails == 0 and "\nall passed" or ("\n" .. fails .. " failed"))
os.exit(fails == 0 and 0 or 1)
