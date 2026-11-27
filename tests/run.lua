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
UnitGUID = function(u) if u == "npc" then return "Creature-0-1-0-1-295-000001" end return "Player-1-0001" end
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
state.debuffs = {}
UnitDebuff = function(_, i) local d = state.debuffs[i]; if d then return d[1], "", 1, d[2] end end
local GEAR = { [5] = { "Robe of the Moccasin", 2, "Cloth" }, [16] = { "Staff of Westfall", 3, "Staves" },
  [19] = { "Stormwind Tabard", 1, "Miscellaneous" }, [1] = { "Crown of the Lost", 4, "Cloth" } }
-- A piece: { name, quality, subType, ilvl, equipLoc, setID, enchantID }
GetInventoryItemLink = function(_, slot) local g = GEAR[slot]; return g and ("item:" .. slot .. ":" .. (g[7] or 0)) end
GetItemInfo = function(link)
  local g = GEAR[tonumber(link:match("%d+"))]
  if g then return g[1], link, g[2], g[4] or 20, 1, "Armor", g[3], 1, g[5], nil, 0, 0, 0, 0, 0, g[6] end
end
local SETS = { [81] = "Battlegear of Valor", [82] = "Defias Leather" }
GetItemSetInfo = function(id) return SETS[id] end
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
check(p.characteristics.IC == "INV_Misc_Coin_02", "the profile icon follows the earned nickname: " .. tostring(p.characteristics.IC))
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
check(ns.Compose.Currently(ns.Mood.Current()):find("lost in thought") or ns.Compose.Currently(ns.Mood.Current()):find("middle distance") or ns.Compose.Currently(ns.Mood.Current()):find("miles away") or ns.Compose.Currently(ns.Mood.Current()):find("daydreaming"), "AFK reads as lost in thought")
UnitIsAFK = function() return false end
state.resting = false
IsMounted = function() return true end
ns.Compose.SourcesChanged(); ns.Compose.Refresh()
check(ns.Compose.Currently(ns.Mood.Current()):find("on horseback"), "a human rides a horse")
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
check(hist:find("the Silver Lanterns and holds the rank of lamplighter there", 1, true), "history: guild")
check(hist:find("done good work for Stormwind and the Argent Dawn"), "history: reputations")
check(hist:find("Felt downcast in Duskwood today and wide%-eyed in Westfall yesterday"), "history: these past days")
-- History favours what's recent: news within three weeks leads, older deeds join the record.
check(hist:find("Aldric helped bring down Edwin VanCleef", 1, true) or hist:find("Aldric came to be called", 1, true), "history: the news comes first")
do
  local realTime = GetServerTime
  GetServerTime = function() return NOW + 40 * 86400 end
  ns.Compose.Refresh()
  local old = ns.Compose.History()
  print("\nHistory, forty days on:\n" .. old)
  check(not old:find("for the first time", 1, true), "weeks later, the news has moved on")
  check(old:find("\"Mine-Warden\"", 1, true) and old:find("Westbrook", 1, true), "the name and the roots stay")
  check(old:find("been down into the Deadmines", 1, true), "and older deeds are told briefly")
  -- A change of guild is noticed and told.
  ns.cache.world.guild = "The Iron Wake"
  local changed = ns.Compose.History()
  check(changed:find("left the Silver Lanterns for the Iron Wake", 1, true), "a change of guild is news: " .. changed:match("[^\n]*Iron Wake[^\n]*"))
  GetServerTime = realTime
  ns.char.changes, ns.char.watched = nil, nil
  ns.Compose.Refresh()
end
check(ns.Compose.Bearing():find("about the gold of Elwynn's mines"), "personality: conversation hooks")
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
check(ns.Compose.Currently(ns.Mood.Current()):find("portal to Stormwind") or ns.Compose.Currently(ns.Mood.Current()):find("way to Stormwind"), "a mage's portal shows in Currently: " .. ns.Compose.Currently(ns.Mood.Current()))
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
check(lg.TX:find("warmly with Innkeeper Farley in Elwynn Forest"), "Lately: a conversation just now: " .. lg.TX)
RPGDialogueCharDB.deaths[1].t = savedDeath

-- Dungeon atmosphere; meeting a friend
IsInInstance = function() return true, "party" end
state.zone, state.sub = "The Deadmines", nil
ns.Compose.Refresh()
check(ns.Compose.Currently(ns.Mood.Current()):find("Deadmines") or ns.Compose.Currently(ns.Mood.Current()):find("Moonbrook"), "dungeon atmosphere")
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
check(ns.Compose.Currently(ns.Mood.Current()):find("Great Forge") or ns.Compose.Currently(ns.Mood.Current()):find("great anvil"), "city district in Currently")
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
check(ns.Compose.LatelyGlance().TX:find("a Defias Pillager%.$"), "Lately: a fight just now: " .. ns.Compose.LatelyGlance().TX)
UnitClassification = function() return "worldboss" end
UnitName = function(u) if u == "target" then return "Hogger" end return "Aldric" end
event("PLAYER_REGEN_DISABLED")
UnitName = function() return "Aldric" end
event("PLAYER_REGEN_ENABLED")
check(ns.Compose.LatelyGlance().TX:find(" Hogger%.$") and not ns.Compose.LatelyGlance().TX:find("a Hogger"), "a named foe takes no article")
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
check(ns.Compose.CompanyGlance().TX:find("a priest and two warriors", 1, true), "party by class: " .. ns.Compose.CompanyGlance().TX)
IsInRaid = function() return true end
GetNumGroupMembers = function() return 20 end
ns.Compose.Refresh()
check(ns.Compose.CompanyGlance().TI == "Part of a Host" and (ns.Compose.CompanyGlance().TX:find("twenty") or ns.Compose.CompanyGlance().TX:find("20")), "a raid is a host: " .. ns.Compose.CompanyGlance().TX)
IsInRaid = function() return false end
IsInGroup = function() return state.grouped end
state.grouped = false
UnitExists = function() return false end
GetNumGroupMembers = function() return 0 end
ns.char.company = nil

-- Company from the game alone: the group, pets, guild and solitude, never a stranger's name.
do
  local C, Co = ns.Compose, ns.Sources.Company
  local saved = { UnitExists = UnitExists, UnitClass = UnitClass, UnitName = UnitName, UnitGUID = UnitGUID, UnitRace = UnitRace,
    UnitLevel = UnitLevel, IsInGroup = IsInGroup, IsInRaid = IsInRaid, GetNumGroupMembers = GetNumGroupMembers,
    IsInInstance = IsInInstance, GetGuildInfo = GetGuildInfo, UnitIsDeadOrGhost = UnitIsDeadOrGhost }
  local keep = { RPGDialogueCharDB, SocialDiaryCharDB, ChronicleCharDB }
  local STRANGERS = { "Strangerone", "Grimbold", "Thessaly", "Quillon", "Raidtwo", "Raidthree" }
  -- Every bit of text Auto TRP would write, for the privacy checks.
  local function everything()
    C.SourcesChanged()
    local sh = C.Sheet()
    local parts = { sh.currently, sh.bearing, sh.history, sh.physical, sh.title, sh.fulltitle, sh.motto, sh.nickname }
    for _, g in pairs(sh.glances) do parts[#parts + 1] = g.TI; parts[#parts + 1] = g.TX end
    for _, v in pairs(sh.stats or {}) do parts[#parts + 1] = tostring(v) end
    return table.concat(parts, "\n"), sh
  end
  local function noStrangers(text, what)
    local found = {}
    for _, n in ipairs(STRANGERS) do if text:find(n, 1, true) then found[#found + 1] = n end end
    check(#found == 0, what .. ": no stranger is named " .. table.concat(found, ","))
  end
  local function saveData(t, seen)
    seen = seen or {}
    if type(t) ~= "table" or seen[t] then return tostring(t) end
    seen[t] = true
    local out = {}
    for k, v in pairs(t) do out[#out + 1] = tostring(k) .. "=" .. saveData(v, seen) end
    return table.concat(out, ";")
  end
  local function company(tx) return C.CompanyGlance().TX end

  -- No other addon at all: everything below comes from the game.
  RPGDialogueCharDB, SocialDiaryCharDB, ChronicleCharDB = nil, nil, nil
  ns.char.company = nil
  local party = {
    party1 = { "Strangerone", "Player-1-00A1", "Warrior", "WARRIOR", "Dwarf", 30, true },
    party2 = { "Grimbold", "Player-1-00A2", "Mage", "MAGE", "Dwarf", 31, true },
    party3 = { "Thessaly", "Player-1-00A3", "Mage", "MAGE", "Dwarf", 29, false },
  }
  local inGroup, leader = true, true
  IsInGroup = function() return inGroup end
  IsInRaid = function() return false end
  GetNumGroupMembers = function() return inGroup and 4 or 0 end
  UnitExists = function(u) return inGroup and party[u] ~= nil end
  UnitName = function(u) if party[u] then return party[u][1] end return "Aldric" end
  UnitGUID = function(u) if party[u] then return party[u][2] end return "Player-1-0001" end
  UnitClass = function(u) if party[u] then return party[u][3], party[u][4] end return "Priest", "PRIEST" end
  UnitRace = function(u) if party[u] then return party[u][5], party[u][5] end return "Human", "Human" end
  UnitLevel = function(u) if party[u] then return party[u][6] end return 22 end
  UnitIsInMyGuild = function(u) return party[u] and party[u][7] end
  UnitIsGroupLeader = function(u) return u == "player" and leader end
  event("GROUP_ROSTER_UPDATE")
  C.SourcesChanged(); C.Refresh()
  local g = ns.cache.company.group
  check(g and g.others == 3 and g.guildmates == 2 and g.lead and g.classes.MAGE == 2 and g.standing == "youngest",
    "a party read from the game: three others, two guildmates, leading, the youngest")
  local gl = C.CompanyGlance()
  check(gl.TI == "Leading the Way" and gl.TX:find("a warrior and two mages", 1, true), "a party they lead, by class: " .. gl.TX)
  check(gl.TX:find("two of them") or gl.TX:find("with two from"), "guildmates are counted: " .. gl.TX)
  local young = false
  for _, l in ipairs(ns.Words.COMPANY.youngest) do if gl.TX:lower():find(l, 1, true) then young = true end end
  check(young, "the youngest of the group, from the level spread: " .. gl.TX)
  noStrangers(everything(), "a party")
  local stored = saveData(ns.char.company)
  check(not stored:find("Strangerone") and not stored:find("Grimbold") and not stored:find("00A1"),
    "the saved record holds neither names nor GUIDs")

  -- A while together; then they part, and meet again on another day: familiar faces.
  ns.char.company.group.since = NOW - 4000
  C.Refresh()
  check(company():find("an hour or so", 1, true), "how long they've been together: " .. company())
  inGroup = false
  event("GROUP_ROSTER_UPDATE")
  check(ns.char.company.group == nil and ns.char.company.lastGrouped, "a group that ends is closed")
  NOW = NOW + 7200
  inGroup = true
  leader = false
  party.party3[7] = true
  event("GROUP_ROSTER_UPDATE")
  C.Refresh()
  g = ns.cache.company.group
  check(g.familiar == 3 and ns.char.company.sessions == 2, "the same three again, on another outing, are familiar faces")
  gl = C.CompanyGlance()
  check(gl.TI == "In Company" and (gl.TX:find("from the Silver Lanterns") or gl.TX:find("of the Silver Lanterns")),
    "all guildmates: " .. gl.TX)
  party.party3[7] = false
  gl = C.CompanyGlance()
  C.Refresh()
  gl = C.CompanyGlance()
  check(gl.TX:find("two of them") or gl.TX:find("with two from"), "two guildmates of three: " .. gl.TX)
  UnitIsInMyGuild = function() return false end
  C.Refresh()
  gl = C.CompanyGlance()
  check(gl.TX:find("familiar") or gl.TX:find("no strangers") or gl.TX:find("earlier roads") or gl.TX:find("from before") or gl.TX:find("every one"),
    "familiar faces are counted, never named: " .. gl.TX)
  noStrangers(everything(), "familiar faces")

  -- A Social Diary friend in the group is named (when allowed); the others never are.
  SocialDiaryCharDB = { data = {
    characters = { ["Player-1-00A1"] = { names = { { first = "Strangerone" } }, lastSeen = NOW - 400 } },
    diary = { ["Player-1-00A1"] = { tags = { "friend" } } }, sessions = {} } }
  C.SourcesChanged(); C.Refresh()
  check(C.PartyWords(ns.cache.company.group) == "Strangerone and two mages", "a Social Diary friend by name: "
    .. tostring(C.PartyWords(ns.cache.company.group)))
  ns.db.nameFriends = false
  C.SourcesChanged(); C.Refresh()
  check(C.PartyWords(ns.cache.company.group) == "a warrior and two mages", "and not when naming friends is off")
  noStrangers(everything(), "friends switched off")
  ns.db.nameFriends = true
  SocialDiaryCharDB = nil

  -- A raid, mostly of one race; a battleground.
  local raid = {}
  for i = 1, 12 do raid["raid" .. i] = { "Raid" .. ({ "two", "three" })[i % 2 + 1], "Player-1-0R" .. i, "Rogue", "ROGUE",
    i <= 8 and "Gnome" or "Human", 40, false } end
  raid.raid1 = nil
  IsInRaid = function() return true end
  GetNumGroupMembers = function() return 12 end
  UnitExists = function(u) return u == "raid1" or raid[u] ~= nil end
  UnitIsUnit = function(a, b) return a == "raid1" and b == "player" end
  local oldName, oldGUID, oldRace = UnitName, UnitGUID, UnitRace
  UnitName = function(u) if raid[u] then return raid[u][1] end return "Aldric" end
  UnitGUID = function(u) if raid[u] then return raid[u][2] end return "Player-1-0001" end
  UnitRace = function(u) if raid[u] then return raid[u][5], raid[u][5] end return "Human", "Human" end
  UnitClass = function(u) if raid[u] then return "Rogue", "ROGUE" end return "Priest", "PRIEST" end
  UnitLevel = function(u) if raid[u] then return 40 end return 22 end
  event("GROUP_ROSTER_UPDATE")
  C.Refresh()
  g = ns.cache.company.group
  check(g.raid and g.others == 11 and g.races.Gnome == 7, "a raid read from raid units, without the player")
  gl = C.CompanyGlance()
  check(gl.TI == "Part of a Host" and gl.TX:find("twelve") and (gl.TX:find("gnomes")), "a host, mostly gnomes: " .. gl.TX)
  IsInInstance = function() return true, "pvp" end
  C.Refresh()
  gl = C.CompanyGlance()
  check(gl.TI == "On the Battlefield" and gl.TX:find("Alliance") and gl.TX:find("twelve"), "a battleground team: " .. gl.TX)
  noStrangers(everything(), "a raid")
  IsInInstance = saved.IsInInstance
  UnitIsUnit = nil

  -- Alone: how long, and how they usually go.
  inGroup = false
  IsInRaid = function() return false end
  GetNumGroupMembers = function() return 0 end
  UnitExists = function() return false end
  UnitName, UnitGUID, UnitRace = saved.UnitName, saved.UnitGUID, saved.UnitRace
  UnitClass, UnitLevel = saved.UnitClass, saved.UnitLevel
  event("GROUP_ROSTER_UPDATE")
  ns.char.company.lastGrouped = NOW - 3 * 86400
  ns.char.company.time = { group = 3000, alone = 30000 }
  GetGuildInfo = function() return nil end
  C.SourcesChanged(); C.Refresh()
  gl = C.CompanyGlance()
  check(gl.TI == "Travels Alone" and gl.TX:find("three days", 1, true), "alone for three days: " .. gl.TX)
  local mostly = false
  for _, l in ipairs(ns.Words.COMPANY.loner) do if gl.TX:find(l, 1, true) then mostly = true end end
  check(mostly, "and nearly always alone, from the time tracked: " .. gl.TX)
  ns.char.company.time = { group = 20000, alone = 3000 }
  C.Refresh()
  check(C.CompanyGlance().TI == "Between Companies", "usually in company, alone for now")
  ns.char.company.time = { group = 8000, alone = 20000 }
  Co.Tick(60)
  check(ns.char.company.time.alone == 20060, "time alone is counted by the minute")
  -- A dungeon entered alone.
  IsInInstance = function() return true, "party" end
  GetRealZoneText = function() return "Shadowfang Keep" end
  event("ZONE_CHANGED_NEW_AREA")
  event("ZONE_CHANGED_NEW_AREA")
  check(ns.char.company.soloDungeons == 1, "a dungeon entered alone counts once")
  IsInInstance = saved.IsInInstance
  GetRealZoneText = function() return state.zone end
  event("ZONE_CHANGED_NEW_AREA")
  C.SourcesChanged(); C.Refresh()
  local hist = C.History()
  check(hist:find("usually travels alone, though not always", 1, true) or hist:find("more often than not", 1, true)
    or hist:find("joining others now and then", 1, true), "History: how they usually travel")
  check(hist:find("dungeon", 1, true) and hist:find("once", 1, true), "History: a dungeon braved alone: " .. hist)
  local lh = hist:lower()
  check(lh:find("three companions", 1, true) or lh:find("three faces", 1, true) or lh:find("three have", 1, true)
    or lh:find("three of the same", 1, true), "History: familiar companions, counted: " .. hist)
  noStrangers(hist, "History")

  -- The guild, with people about.
  GetGuildInfo = saved.GetGuildInfo
  IsInGuild = function() return true end
  GetNumGuildMembers = function() return 48, 2, 14 end
  ns.char.company.guild = { name = "The Silver Lanterns", since = NOW - 40 * 86400 }
  ns.char.company.since = NOW - 60 * 86400
  C.Refresh()
  gl = C.CompanyGlance()
  check(gl.TI == "Guild Colours" and gl.TX:find("a dozen or more") and gl.TX:find("the Silver Lanterns"), "guildmates about: " .. gl.TX)
  hist = C.History()
  check(hist:find("a month", 1, true) and hist:find("lamplighter", 1, true), "History: how long in the guild")
  GetNumGuildMembers = function() return 48, 0, 1 end
  C.Refresh()
  gl = C.CompanyGlance()
  check(gl.TI == "Guild Colours" and not gl.TX:find("are about"), "a guild with nobody about: " .. gl.TX)

  -- A hunter's pet: its name, kind, happiness, how long, how often it fell.
  UnitClass = function() return "Hunter", "HUNTER" end
  UnitExists = function(u) return u == "pet" end
  UnitName = function(u) if u == "pet" then return "Fang" end return "Aldric" end
  UnitCreatureFamily = function() return "Wolf" end
  GetPetHappiness = function() return 3 end
  UnitLevel = function(u) if u == "pet" then return 21 end return 22 end
  C.Refresh()
  ns.char.company.pets.Fang.first = NOW - 20 * 86400
  ns.char.company.pets.Claw = { first = NOW - 50 * 86400, last = NOW - 25 * 86400, n = 1, kind = "Cat" }
  UnitIsDeadOrGhost = function(u) return u == "pet" end
  event("UNIT_HEALTH", "pet")
  UnitIsDeadOrGhost = function() return false end
  event("UNIT_HEALTH", "pet")
  UnitIsDeadOrGhost = function(u) return u == "pet" end
  event("UNIT_HEALTH", "pet")
  UnitIsDeadOrGhost = saved.UnitIsDeadOrGhost
  event("UNIT_HEALTH", "pet")
  check(ns.char.company.pets.Fang.deaths == 2, "a pet's falls are counted")
  C.Refresh()
  gl = C.CompanyGlance()
  check(gl.TI == "Travels Light" and gl.TX:find("Fang") and gl.TX:find("wolf") and gl.TX:find("plainly devoted")
    and gl.TX:find("three weeks") and gl.TX:find("twice"), "a hunter's pet: " .. gl.TX)
  hist = C.History()
  check(hist:find("Fang", 1, true) and hist:find("three weeks", 1, true) and hist:find("Claw the cat", 1, true),
    "History: the pet, and the one before it")
  -- A warlock's demons: the one called most.
  UnitClass = function() return "Warlock", "WARLOCK" end
  UnitName = function(u) if u == "pet" then return "Zigzag" end return "Aldric" end
  UnitCreatureFamily = function() return "Imp" end
  ns.char.company.pets = { Grubthor = { first = NOW - 9 * 86400, last = NOW - 86400, n = 3, kind = "Voidwalker" } }
  C.Refresh()
  ns.char.company.pets.Zigzag.n = 9
  C.Refresh()
  gl = C.CompanyGlance()
  check(gl.TX:find("Zigzag") and gl.TX:find("imp"), "a warlock's demon: " .. gl.TX)
  hist = C.History()
  check(hist:find("Zigzag", 1, true) and hist:find("demon", 1, true), "History: the demon called most")

  -- Nothing is recorded in combat; the roster is read once the fight ends.
  UnitClass, UnitName, UnitLevel, UnitExists = saved.UnitClass, saved.UnitName, saved.UnitLevel, saved.UnitExists
  local sessions = ns.char.company.sessions
  inGroup = true
  UnitExists = function(u) return u == "party1" end
  UnitGUID = function(u) if u == "party1" then return "Player-1-00B9" end return "Player-1-0001" end
  state.combat = true
  event("GROUP_ROSTER_UPDATE")
  check(ns.char.company.sessions == sessions, "nothing recorded in combat")
  state.combat = false
  event("PLAYER_REGEN_ENABLED")
  check(ns.char.company.sessions == sessions + 1, "the roster is read once combat ends")

  -- With no other addon, a bare character still gets a full Company glance and people paragraph.
  inGroup = false
  UnitExists, UnitGUID = saved.UnitExists, saved.UnitGUID
  event("GROUP_ROSTER_UPDATE")
  local _, sh = everything()
  local people
  for para in (sh.history or ""):gmatch("[^\n]+") do
    if (para:find("alone", 1, true) or para:find("company", 1, true)) and para:find("lamplighter", 1, true) then people = para end
  end
  check(people and select(2, people:gsub("%. ", "")) >= 2, "a people paragraph from the game alone: " .. tostring(people))
  print("\nCompany, game data only: " .. sh.glances.company.TX .. "\nPeople: " .. tostring(people))

  IsInGroup, IsInRaid, GetNumGroupMembers = saved.IsInGroup, saved.IsInRaid, saved.GetNumGroupMembers
  UnitExists, UnitClass, UnitName, UnitGUID, UnitRace, UnitLevel = saved.UnitExists, saved.UnitClass, saved.UnitName,
    saved.UnitGUID, saved.UnitRace, saved.UnitLevel
  GetGuildInfo, UnitIsDeadOrGhost = saved.GetGuildInfo, saved.UnitIsDeadOrGhost
  UnitIsInMyGuild, UnitIsGroupLeader, GetNumGuildMembers, IsInGuild, UnitCreatureFamily, GetPetHappiness = nil, nil, nil, nil, nil, nil
  RPGDialogueCharDB, SocialDiaryCharDB, ChronicleCharDB = keep[1], keep[2], keep[3]
  NOW = NOW - 7200
  ns.char.company = nil
  C.SourcesChanged(); C.Refresh()
end

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
check(p.character.WU == 2 and ns.TRP.Status("walkup") == "auto", "a neutral mood: open to walk-ups, never left unset")
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
check(ns.Compose.Currently(ns.Mood.Current()):find("mineral vein") or ns.Compose.Currently(ns.Mood.Current()):find("chipping ore") or ns.Compose.Currently(ns.Mood.Current()):find("mining ore"), "mining shows in Currently")
ns.World.SetContext("none")
C_Spell = nil
state.zone, state.sub = "Duskwood", "Raven Hill"

-- A hard week
ns.char.days = {}
for i = 0, 4 do ns.char.days[os.date("%Y-%m-%d", NOW - i * 86400)] = { moods = { downcast = 5 }, zones = { Duskwood = 5 } } end
local wt = ns.Compose.WeekTone()
local isHard = false
for _, l in ipairs(ns.Words.WEEK_TONE.hard) do if wt == l then isHard = true end end
check(isHard, "a run of bad days is noticed: " .. tostring(wt))
ns.char.days = {}

-- Changing your tune; lies found out; letters
RPGDialogueCharDB.opinions.night_elves = { stance = "admire", t = NOW - 10, contradicts = { stance = "distrust" } }
RPGDialogueCharDB.claims = { player = { a = {}, b = {} }, exposed = { a = NOW } }
RPGDialogueCharDB.letters = { l1 = { arrived = NOW }, l2 = { arrived = NOW }, l3 = { arrived = NOW } }
ns.Compose.SourcesChanged(); ns.Compose.Refresh()
check(ns.Compose.Bearing():find("Used to distrust the night elves, and has since changed"), "Personality: changed tune: " .. ns.Compose.Bearing())
check(ns.Compose.Bearing():find("caught in a lie"), "History: a lie found out")
check(not ns.Compose.History():find("letters"), "letters stay out of History")
check(ns.Compose.Stats().letters == nil and ns.Compose.Stats().met == nil, "letters and people met are no longer statistics")
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
  for _, f in ipairs({ "AutoTRP/Data/Words.lua", "AutoTRP/Data/Places.lua", "AutoTRP/Compose.lua", "AutoTRP/Mood.lua", "AutoTRP/Sources/World.lua",
    "AutoTRP/Data/Kin.lua", "AutoTRP/Sources/Kin.lua" }) do
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
  -- About: Physical's own looks: race bearing, stance, health, auras, drink, sickness
  for _, l in pairs(W.RACE_BEARING) do add(l) end
  for _, t in pairs(W.PHYS_STANCE) do for _, l in pairs(t) do add(l) end end
  for _, b in ipairs(W.PHYS_HEALTH) do add(b.text) end
  for _, b in ipairs(W.PHYS_DRUNK) do add(b.text) end
  for _, a in pairs(W.PHYS_AILMENT) do add(a.text) end
  for _, a in ipairs(W.AURA_LOOK) do add(a.text) end
  for _, l in pairs(W.PHYS_QUALITY) do add(l) end
  for _, l in pairs(W.PHYS_FIT) do add(l) end
  for _, l in pairs(W.PHYS_ARMOUR) do add(l) end
  for _, k in ipairs({ "PHYS_RESTED", "PHYS_UNRESTED", "PHYS_UNHURT", "PHYS_RESSICK", "PHYS_STEALTH", "PHYS_GHOST",
    "PHYS_FORM", "PHYS_MOUNT", "PHYS_ARMOUR_MIX", "PHYS_ARMOUR_LIGHT" }) do add(W[k]) end
  -- Personality lines are dispositions: they name nothing a character holds either.
  for _, l in pairs(W.CLASS_TEMPER) do add(l) end
  for _, l in pairs(W.RACE_TEMPER) do add(l) end
  for _, t in pairs(W.RACE_CLASS_TEMPER) do for _, l in pairs(t) do add(l) end end
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

-- About: Physical and the Marks glance, from the live game alone: armour by type, weapons by
-- how they're carried, matched sets, enchantments, jewellery, auras, drink, shapes, health.
do
  local C = ns.Compose
  local keepGear, keepBuffs = {}, state.buffs
  for k, v in pairs(GEAR) do keepGear[k] = v end
  local keepClass, keepLevel, keepHealth, keepStat = UnitClass, UnitLevel, UnitHealth, UnitStat
  local keepAddons = { RPGDialogueCharDB, SocialDiaryCharDB, ChronicleCharDB }
  RPGDialogueCharDB, SocialDiaryCharDB, ChronicleCharDB = nil, nil, nil
  C.SourcesChanged()
  local function wear(pieces, class, level)
    for k in pairs(GEAR) do GEAR[k] = nil end
    for k, v in pairs(pieces) do GEAR[k] = v end
    UnitClass = function() return class, class end
    UnitLevel = function() return level end
    ns.World.Invalidate(); C.Refresh()
    return C.Physical(), C.MarksGlance()
  end
  local plain = function(s) return (s:gsub("{col:%x+}", ""):gsub("{/col}", "")) end

  -- A warrior in plate, with a great axe, a matched set and an enchanted weapon
  state.buffs = {}
  UnitStat = function(_, i) return 0, ({ 120, 60, 90, 20, 30 })[i] end
  local ph, mk = wear({
    [1] = { "Helm of Valor", 3, "Plate", 58, "INVTYPE_HEAD", 81 },
    [3] = { "Spaulders of Valor", 3, "Plate", 58, "INVTYPE_SHOULDER", 81 },
    [5] = { "Breastplate of Valor", 3, "Plate", 58, "INVTYPE_CHEST", 81 },
    [7] = { "Legplates of Valor", 3, "Plate", 58, "INVTYPE_LEGS", 81 },
    [10] = { "Gauntlets of Valor", 3, "Plate", 58, "INVTYPE_HAND", 81 },
    [8] = { "Sabatons of Valor", 3, "Plate", 58, "INVTYPE_FEET", 81 },
    [6] = { "Ironbark Belt", 2, "Mail", 52, "INVTYPE_WAIST" },
    [16] = { "Arcanite Reaper", 3, "Two-Handed Axes", 63, "INVTYPE_2HWEAPON", nil, 1900 },
    [11] = { "Band of Accuria", 4, "Miscellaneous", 78, "INVTYPE_FINGER" },
    [15] = { "Cape of the Black Baron", 3, "Cloth", 63, "INVTYPE_CLOAK" },
  }, "WARRIOR", 58)
  print("\nPhysical (warrior, plate):\n" .. ph .. "\nMarks: " .. mk.TI .. ": " .. mk.TX)
  local txt = plain(ph)
  check(select(2, ph:gsub("\n\n", "")) == 2, "Physical is three paragraphs")
  check(txt:find("plate"), "armour by type: plate")
  check(txt:find("Arcanite Reaper, a great axe") , "a two-hander by name and kind: " .. txt)
  check(txt:find("Battlegear of Valor") and txt:lower():find("six"), "matched set by name and count")
  check(txt:find("Reaper[^.]*%. [^.]*enchant"), "an enchanted weapon, told after it")
  check(txt:find("Band of Accuria"), "an epic ring is told")
  check(txt:find("Cape of the Black Baron"), "the cloak is told")
  check(not txt:find("Ironbark Belt"), "an ordinary belt isn't")
  check(txt:find("broad%-shouldered") or txt:find("heavy with muscle") or txt:find("powerfully built") or txt:find("brawny"), "build from live stats with no addons")
  check(mk.TI == "Matched Set" and mk.TX:find("Battlegear of Valor"), "a matched set is the mark: " .. mk.TI)

  -- A rogue in leather with two daggers; and the same in a mix of leather and mail
  ph, mk = wear({
    [5] = { "Cutthroat's Vest", 2, "Leather", 30 }, [7] = { "Cutthroat's Pants", 2, "Leather", 30 },
    [8] = { "Cutthroat's Boots", 2, "Leather", 30 }, [10] = { "Cutthroat's Gloves", 2, "Leather", 30 },
    [16] = { "Assassin's Blade", 3, "Daggers", 30, "INVTYPE_WEAPON" }, [17] = { "Kris of Orgrimmar", 2, "Daggers", 30, "INVTYPE_WEAPON" },
  }, "ROGUE", 30)
  txt = plain(ph)
  check(txt:find("leather"), "armour by type: leather")
  check(txt:find("Assassin's Blade and Kris of Orgrimmar"), "dual wield names both: " .. txt)
  check(mk.TI == "Two Weapons", "two weapons are the mark: " .. mk.TI)
  ph = wear({
    [5] = { "Cutthroat's Vest", 2, "Leather", 30 }, [7] = { "Chainmail Pants", 2, "Mail", 30 },
    [8] = { "Chainmail Boots", 2, "Mail", 30 }, [10] = { "Cutthroat's Gloves", 2, "Leather", 30 },
  }, "ROGUE", 30)
  check(plain(ph):find("mix of leather and mail") or plain(ph):find("patchwork of leather and mail"), "mixed armour is told as a mix")
  check(plain(ph):find("Carries no weapon") or plain(ph):find("Goes unarmed"), "no weapon, unarmed")

  -- A paladin with a sword and shield; a hunter with a bow; a mage with a wand and an off-hand
  ph = wear({ [5] = { "Ornate Breastplate", 2, "Mail", 30 }, [16] = { "Sword of Serenity", 3, "One-Handed Swords", 30, "INVTYPE_WEAPON" },
    [17] = { "Aegis of Stormwind", 3, "Shields", 30, "INVTYPE_SHIELD" } }, "PALADIN", 30)
  check(plain(ph):find("Aegis of Stormwind") and plain(ph):find("Sword of Serenity"), "sword and shield: " .. plain(ph))
  ph = wear({ [5] = { "Scaled Vest", 2, "Mail", 40 }, [18] = { "Ironwood Longbow", 3, "Bows", 40, "INVTYPE_RANGED" } }, "HUNTER", 40)
  check(plain(ph):find("Ironwood Longbow, a bow"), "a bow by name: " .. plain(ph))
  ph = wear({ [5] = { "Robe of Power", 3, "Cloth", 40 }, [16] = { "Dagger of Wisdom", 2, "Daggers", 40, "INVTYPE_WEAPON" },
    [17] = { "Tome of Knowledge", 2, "Miscellaneous", 40, "INVTYPE_HOLDABLE" }, [18] = { "Wand of Fire", 2, "Wands", 40, "INVTYPE_RANGEDRIGHT" } }, "MAGE", 40)
  check(plain(ph):find("Tome of Knowledge held in the other hand") or plain(ph):find("Tome of Knowledge in the other hand"), "an off-hand held: " .. plain(ph))
  check(plain(ph):find("Wand of Fire") and not plain(ph):find("Wand of Fire, a wand"), "a wand by name, without \"Wand of Fire, a wand\": " .. plain(ph))
  -- Gear long outgrown
  ph = wear({ [5] = { "Old Robe", 2, "Cloth", 15 }, [7] = { "Old Pants", 2, "Cloth", 15 }, [8] = { "Old Boots", 2, "Cloth", 15 },
    [10] = { "Old Gloves", 2, "Cloth", 15 } }, "MAGE", 40)
  check(plain(ph):find("outgrown") or plain(ph):find("could do better"), "outgrown gear is told")
  -- A plate class in cloth at fifty
  ph = wear({ [5] = { "Old Robe", 2, "Cloth", 50 }, [7] = { "Old Pants", 2, "Cloth", 50 }, [8] = { "Old Boots", 2, "Cloth", 50 } }, "WARRIOR", 50)
  check(plain(ph):find("calling would choose") or plain(ph):find("for one of"), "light armour for the class")

  -- Auras: a spell on them is the mark; sickness and drink outrank it; wounds outrank all
  wear({ [5] = { "Robe of Power", 3, "Cloth", 40 } }, "PRIEST", 40)
  state.buffs = { "Power Word: Fortitude", "Inner Fire" }
  C.Refresh()
  ph, mk = C.Physical(), C.MarksGlance()
  check(mk.TI == "Inner Fire" and ph:find("holy fire"), "Inner Fire shows: " .. mk.TI)
  check(not ph:find("Mark of the Wild"), "a blessing that isn't on them isn't told")
  state.buffs = { "Lightning Shield" }; C.Refresh()
  check(C.MarksGlance().TI == "Crackling", "Lightning Shield shows")
  state.buffs = { "Demon Armor" }; C.Refresh()
  check(C.MarksGlance().TI == "Fel-Warded", "Demon Armor shows")
  state.buffs = { "Frost Armor" }; C.Refresh()
  check(C.MarksGlance().TI == "Rimed in Frost", "Frost Armor shows")
  state.buffs = { "Greater Blessing of Kings" }; C.Refresh()
  check(C.Physical():find("paladin's blessing"), "a blessing by its prefix")
  state.buffs = { "Inner Fire" }
  state.debuffs = { { "Plague", "Disease" } }; C.Refresh()
  check(C.MarksGlance().TI == "Sickly" and C.Physical():find("disease"), "a disease outranks a spell: " .. C.MarksGlance().TI)
  state.debuffs = { { "Venom Sting", "Poison" } }; C.Refresh()
  check(C.MarksGlance().TI == "Poisoned", "a poison shows")
  state.debuffs = { { "Curse of Weakness", "Curse" } }; C.Refresh()
  check(C.MarksGlance().TI == "Cursed", "a curse shows")
  state.debuffs = {}
  DRUNK_MESSAGE_SELF1, DRUNK_MESSAGE_SELF3 = "You feel sober again.", "You feel drunk."
  event("CHAT_MSG_SYSTEM", "You feel drunk.")
  C.Refresh()
  check(C.MarksGlance().TI == "Smells of Ale", "drink from the game's own line, no RPG Dialogue: " .. C.MarksGlance().TI)
  event("CHAT_MSG_SYSTEM", "You feel sober again.")
  C.Refresh()
  check(C.MarksGlance().TI == "Inner Fire", "sober again")
  UnitHealth = function() return 20 end
  C.Refresh()
  check(C.MarksGlance().TI == "Badly Hurt" and (C.Physical():find("Badly hurt") or C.Physical():find("Hurt badly")), "badly hurt outranks everything")
  UnitHealth = keepHealth
  state.buffs = { "Bear Form" }; C.Refresh()
  check(C.MarksGlance().TI == "Bear-Shaped" and C.Physical():find("great bear"), "a druid's shape shows")
  state.buffs = { "Well Fed" }; C.Refresh()
  check(C.Physical():find("eaten well") or C.Physical():find("Well fed"), "Well Fed shows")
  state.buffs = {}; C.Refresh()
  ph = C.Physical()
  check(select(2, ph:gsub("\n\n", "")) == 2, "three paragraphs with nothing on them")
  -- Not a catalogue: no two sentences in a row open the same way ("Wears X. Wears Y.")
  local repeats = {}
  for _, pieces in ipairs({
    { [1] = { "Helm of Valor", 3, "Plate", 58 }, [3] = { "Spaulders of Valor", 3, "Plate", 58 }, [5] = { "Breastplate of Valor", 3, "Plate", 58 },
      [15] = { "Cape", 2, "Cloth", 50 }, [19] = { "Tabard", 1, "Miscellaneous" }, [16] = { "Axe", 3, "One-Handed Axes", 50 },
      [17] = { "Shield", 3, "Shields", 50 }, [18] = { "Bow", 2, "Bows", 50 }, [11] = { "Ring", 4, "Miscellaneous" }, [2] = { "Neck", 4, "Miscellaneous" } },
  }) do
    for _, class in ipairs({ "WARRIOR", "PALADIN", "HUNTER" }) do
      local text = plain(wear(pieces, class, 50))
      local last
      for first in text:gmatch("([%a']+)[^.]*%.%s*") do
        if first == last then repeats[#repeats + 1] = class .. ": " .. first end
        last = first
      end
    end
  end
  check(#repeats == 0, "Physical sentences don't open alike back to back: " .. table.concat(repeats, ", "))

  -- Everything named is really worn: no item from the list above survives a change of gear
  ph = wear({ [5] = { "Robe of Power", 3, "Cloth", 40 } }, "MAGE", 40)
  check(not ph:find("Reaper") and not ph:find("Valor") and not ph:find("Longbow"), "only what is worn now is named")

  for k in pairs(GEAR) do GEAR[k] = nil end
  for k, v in pairs(keepGear) do GEAR[k] = v end
  state.buffs, state.debuffs = keepBuffs, {}
  UnitClass, UnitLevel, UnitHealth, UnitStat = keepClass, keepLevel, keepHealth, keepStat
  RPGDialogueCharDB, SocialDiaryCharDB, ChronicleCharDB = keepAddons[1], keepAddons[2], keepAddons[3]
  C.SourcesChanged()
  ns.World.Invalidate(); C.Refresh()
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
  check(sh.history:find(ns.U.Pron(ns.Compose.WealthBand(ns.cache.world).flair):sub(1, 20), 1, true), "wealth flair in History")
  ns.db.fields.stat_wealth = false
  check(not ns.TRP.Enabled("stat_wealth") and ns.TRP.Enabled("stat_lands"), "one statistic switched off, the rest on")
  ns.db.fields.stats = false
  check(not ns.TRP.Enabled("stat_lands"), "the master switch turns all statistics off")
  ns.db.fields.stats, ns.db.fields.stat_wealth = true, true
end

-- Nickname, motto and icon are earned by something the character saw through, and History
-- says where they came from.
do
  local sh = ns.Compose.Sheet()
  check(sh.nickname == "Mine-Warden" and sh.motto == "Gold isn't worth a life.", "a finished story earns a nickname and motto: " .. tostring(sh.nickname))
  check(sh.icon == "INV_Misc_Coin_02", "the icon follows the nickname: " .. tostring(sh.icon))
  check(sh.history:find("Saw the gold of Elwynn's mines through to the end", 1, true) and sh.history:find("\"Mine-Warden\"", 1, true)
    and sh.history:find("Gold isn't worth a life", 1, true), "History explains the nickname and motto")
  check(sh.history:find("\"VanCleef's Bane\"", 1, true), "and names the other name that stuck")
  check(sh.stats.names == "Mine-Warden and VanCleef's Bane", "Names earned statistic, the worn one first: " .. tostring(sh.stats.names))
  local threads = RPGDialogueCharDB.threads
  RPGDialogueCharDB.threads = {}
  ns.Compose.SourcesChanged(); ns.Compose.Refresh()
  sh = ns.Compose.Sheet(true)
  check(sh.nickname == "VanCleef's Bane" and sh.motto == "Every mask comes off.", "no story: the dungeon master felled names them: " .. tostring(sh.nickname))
  check(sh.icon == "INV_Misc_Mask_01", "with the master's own icon: " .. tostring(sh.icon))
  check(sh.history:find("Was there when Edwin VanCleef fell in the Deadmines", 1, true), "and History says so")
  ChronicleCharDB.bosses["2"] = { name = "Archmage Arugal", kills = 1, lastSuccess = NOW - 90000, instanceName = "Shadowfang Keep" }
  ChronicleCharDB.bosses["3"] = { name = "Some Random Ogre", kills = 1, lastSuccess = NOW - 100 }
  ns.Compose.SourcesChanged(); ns.Compose.Refresh()
  sh = ns.Compose.Sheet(true)
  check(sh.nickname == "Arugal's Bane", "the hardest master felled, not the latest: " .. tostring(sh.nickname))
  ChronicleCharDB.bosses["2"], ChronicleCharDB.bosses["3"] = nil, nil
  ChronicleCharDB.quests = { { time = NOW - 500, title = "The Defias Brotherhood", status = "completed", zone = "Westfall" },
    { time = NOW - 900, title = "Wanted: Hogger", status = "completed", zone = "Elwynn Forest" } }
  ns.Compose.SourcesChanged(); ns.Compose.Refresh()
  sh = ns.Compose.Sheet(true)
  check(sh.nickname == "Defias-Breaker" and sh.motto, "a quest chain outranks a boss: " .. tostring(sh.nickname))
  ChronicleCharDB.quests = { { time = NOW - 900, title = "Wanted: Hogger", status = "completed", zone = "Elwynn Forest" } }
  ChronicleCharDB.bosses = {}
  ns.Compose.SourcesChanged(); ns.Compose.Refresh()
  sh = ns.Compose.Sheet(true)
  check(sh.nickname == "Hogger's Bane" and sh.history:find("Collected the bounty on Hogger", 1, true), "a bounty collected: " .. tostring(sh.nickname))
  ChronicleCharDB.quests = {}
  ns.Compose.SourcesChanged(); ns.Compose.Refresh()
  sh = ns.Compose.Sheet(true)
  check(ns.Compose.Earned() == nil and sh.nickname == "of Elwynn" and sh.motto and sh.icon == "ClassIcon_Priest",
    "nothing earned: a homeland nickname, a class motto, the class crest: " .. tostring(sh.nickname) .. " / " .. tostring(sh.motto))
  ChronicleCharDB.bosses = { ["1"] = { name = "Edwin VanCleef", kills = 1, lastSuccess = NOW - 7000, instanceName = "The Deadmines" } }
  RPGDialogueCharDB.threads = threads
  ns.Compose.SourcesChanged(); ns.Compose.Refresh()
end

-- Earned names, more closely: bounties, how deeds rank, choosing a name, a name earned just
-- now, and the data itself.
do
  local C, W = ns.Compose, ns.Words
  local function bounty(t) local target, short = C.BountyTarget(t); return tostring(target) .. "|" .. tostring(short) end
  check(bounty('Wanted: "Hogger"') == "Hogger|Hogger", "a bounty title in quotes: " .. bounty('Wanted: "Hogger"'))
  check(bounty("WANTED: Murkdeep!") == "Murkdeep|Murkdeep", "a shouted bounty: " .. bounty("WANTED: Murkdeep!"))
  check(bounty("Wanted - Arnak Grimtotem") == "Arnak Grimtotem|Grimtotem", "a bounty with a dash: " .. bounty("Wanted - Arnak Grimtotem"))
  check(bounty("Wanted: Lieutenant Fangore") == "Lieutenant Fangore|Fangore", "a bounty with a rank")
  check(C.BountyTarget("Wanted: Syndicate Personnel") == nil, "a bounty on a crowd earns no name")
  check(C.BountyTarget("The Wanted Poster") == nil, "only titles that start with Wanted")

  local threads, bosses = RPGDialogueCharDB.threads, ChronicleCharDB.bosses
  RPGDialogueCharDB.threads, ChronicleCharDB.bosses = {}, {}
  local function with(quests)
    ChronicleCharDB.quests = quests
    C.SourcesChanged(); C.Refresh()
    return C.Sheet(true)
  end
  local sh = with({ { time = NOW - 300, title = "Wanted: Lieutenant Fangore", status = "completed", zone = "Redridge Mountains" } })
  check(sh.nickname == "Fangore's Bane" and sh.motto == "Rank doesn't stop a blade.", "a known bounty has its own saying: " .. tostring(sh.motto))
  sh = with({ { time = NOW - 9000, title = "Princess Must Die!", status = "completed", zone = "Elwynn Forest" },
    { time = NOW - 100, title = "The Defias Brotherhood", status = "completed", zone = "Westfall" } })
  check(sh.nickname == "Defias-Breaker", "the longer chain names them, even done later: " .. tostring(sh.nickname))
  sh = with({ { time = NOW - 100, title = "Mor'Ladim", status = "completed", zone = "Duskwood" },
    { time = NOW - 9000, title = "Morbent Fel", status = "completed", zone = "Duskwood" } })
  check(sh.nickname == "Lamp-Lighter", "between equal chains the first one done sticks: " .. tostring(sh.nickname))
  sh = with({ { time = NOW - 100, title = "Whirlwind Weapon", status = "completed" } })
  check(sh.nickname == "of Elwynn", "another class's chain earns a priest nothing")
  RPGDialogueCharDB.threads = { stalvan = { state = "resolved", beats = { a = 1 }, t = NOW - 50 } }
  sh = with({ { time = NOW - 100, title = "The Legend of Stalvan", status = "completed", zone = "Duskwood" } })
  check(#C.EarnedAll() == 1 and sh.nickname == "Stalvan's Witness", "the same name from a story and a chain counts once")
  RPGDialogueCharDB.threads = {}

  -- Choosing which name to wear
  ChronicleCharDB.bosses = { ["1"] = { name = "Edwin VanCleef", kills = 1, lastSuccess = NOW - 7000, instanceName = "The Deadmines" } }
  sh = with({ { time = NOW - 900, title = "The Defias Brotherhood", status = "completed", zone = "Westfall" },
    { time = NOW - 800, title = "Wanted: Hogger", status = "completed", zone = "Elwynn Forest" } })
  check(#C.EarnedAll() == 3 and sh.nickname == "Defias-Breaker", "three names, the best worn")
  SlashCmdList.AUTOTRP("names")
  ns.TRP.Claim("nickname")
  SlashCmdList.AUTOTRP("name 3")
  check(C.Nickname() == "Hogger's Bane" and C.Icon() == "INV_Misc_Note_06", "/atrp name wears a lesser one: " .. tostring(C.Nickname()))
  check(ns.TRP.FIELDS.nickname.read(profiles[ns.char.profileID]) == "Hogger's Bane", "and writes it: " .. tostring(ns.TRP.FIELDS.nickname.read(profiles[ns.char.profileID])))
  SlashCmdList.AUTOTRP("name vancleef's bane")
  check(C.Nickname() == "VanCleef's Bane", "/atrp name takes the name itself")
  SlashCmdList.AUTOTRP("name 9")
  check(C.Nickname() == "VanCleef's Bane", "a number with no name changes nothing")
  SlashCmdList.AUTOTRP("name auto")
  check(ns.char.chosenName == nil and C.Nickname() == "Defias-Breaker", "/atrp name auto goes back to the best")
  ns.char.chosenName = "quest:Gone Forever"
  check(C.Nickname() == "Defias-Breaker", "a chosen name no longer earned falls back")
  ns.char.chosenName = nil

  -- A name earned just now: noticed once, proud, a line in chat, and the Lately glance.
  ns.char.names = nil
  check(#C.NoticeNames() == 0 and ns.char.names["quest:The Defias Brotherhood"], "names already earned are taken in quietly")
  local said = {}
  local oldChat = DEFAULT_CHAT_FRAME.AddMessage
  DEFAULT_CHAT_FRAME.AddMessage = function(_, m) said[#said + 1] = m end
  ns.char.mood.emo.proud = nil
  ChronicleCharDB.quests[#ChronicleCharDB.quests + 1] = { time = NOW - 5, title = "The People's Militia", status = "completed", zone = "Westfall" }
  ChronicleCharDB.quests[#ChronicleCharDB.quests + 1] = { time = NOW - 200000, title = "Big Game Hunter", status = "completed" }
  C.SourcesChanged(); C.Refresh()
  ns.Mood.Watch()
  DEFAULT_CHAT_FRAME.AddMessage = oldChat
  local line = table.concat(said, " ")
  check(line:find("A name has stuck: \"Militia-Hand\"", 1, true) and line:find("Look after your own", 1, true), "a new name is told in chat: " .. line)
  check(not line:find("Bangalash", 1, true), "a deed days old is taken in quietly")
  check((ns.char.mood.emo.proud or 0) >= 20, "a new name makes them proud")
  check(line:find("You still go by \"Defias-Breaker\"", 1, true), "and says which name is still worn")
  check(#C.NoticeNames() == 0, "and is told only once")
  local g = C.LatelyGlance()
  check(g.TI == "A Name Earned" and g.TX:find("Militia-Hand", 1, true), "Lately: a name earned lately: " .. tostring(g.TX))
  NOW = NOW + 3 * 86400
  C.SourcesChanged(); C.Refresh()
  check(C.LatelyGlance().TI ~= "A Name Earned", "and lets it go after a couple of days")
  NOW = NOW - 3 * 86400

  -- The data: every entry is whole, every story is one RPG Dialogue has, names are unique.
  local bad, nicks = {}, {}
  local function whole(where, e)
    if type(e.nick) ~= "string" or e.nick == "" or type(e.icon) ~= "string" then bad[#bad + 1] = where end
    if e.motto and not e.motto:find("[%.!%?]$") then bad[#bad + 1] = where .. " motto" end
  end
  for id, e in pairs(W.EARNED_STORY) do
    whole("story " .. id, e)
    if not ns.RPGDNames.threads[id] then bad[#bad + 1] = "story " .. id .. " not in RPG Dialogue" end
  end
  for title, e in pairs(W.EARNED_QUEST) do
    whole("quest " .. title, e)
    if type(e.deed) ~= "string" or not e.tier then bad[#bad + 1] = "quest " .. title .. " deed/tier" end
  end
  for i, e in ipairs(W.EARNED_BOSS) do
    whole("boss " .. tostring(e.name), e)
    if nicks[e.nick] then bad[#bad + 1] = "boss nick twice: " .. e.nick end
    nicks[e.nick] = true
  end
  check(#bad == 0, "earned-name data is whole: " .. table.concat(bad, ", "))
  check(#W.EARNED_BOSS >= 30, "every dungeon and raid master: " .. #W.EARNED_BOSS)

  ChronicleCharDB.quests = {}
  RPGDialogueCharDB.threads, ChronicleCharDB.bosses = threads, bosses
  ns.char.names = nil
  C.SourcesChanged(); C.Refresh()
end

-- Auto TRP's own record of deeds: names are earned without Chronicle, and nothing it sees
-- is lost when Chronicle is off.
do
  local C, Deeds = ns.Compose, ns.Sources.Deeds
  local chron, threads = ChronicleCharDB, RPGDialogueCharDB.threads
  ChronicleCharDB, RPGDialogueCharDB.threads = nil, {}
  ns.char.deeds, ns.char.names = nil, nil
  C.SourcesChanged(); C.Refresh()
  check(C.Earned() == nil and C.Nickname() == "of Elwynn", "no Chronicle, nothing seen yet: no earned name")
  -- Turning a quest in: the title from the quest window...
  GetTitleText = function() return "The Defias Brotherhood" end
  GetQuestID = function() return 166 end
  state.zone = "Westfall"
  event("QUEST_COMPLETE")
  event("QUEST_TURNED_IN", 166, 0, 0)
  check(ns.char.deeds.quests["The Defias Brotherhood"] and ns.char.deeds.quests["The Defias Brotherhood"].zone == "Westfall",
    "a quest turned in is recorded with where it was")
  -- ...or from the quest log by its ID.
  C_QuestLog = { GetTitleForQuestID = function(id) return id == 88 and "Princess Must Die!" or nil end }
  event("QUEST_TURNED_IN", 88, 0, 0)
  check(ns.char.deeds.quests["Princess Must Die!"], "or by its ID, without the quest window")
  C_QuestLog = nil
  local t1 = ns.char.deeds.quests["The Defias Brotherhood"].t
  NOW = NOW + 10
  event("QUEST_COMPLETE"); event("QUEST_TURNED_IN", 166, 0, 0)
  check(ns.char.deeds.quests["The Defias Brotherhood"].t == t1, "only the first time counts")
  NOW = NOW - 10
  C.Refresh()
  check(C.Nickname() == "Defias-Breaker", "a chain recorded by Auto TRP earns its name without Chronicle: " .. tostring(C.Nickname()))
  -- A master brought down
  GetInstanceInfo = function() return "Shadowfang Keep", "party" end
  event("ENCOUNTER_END", 1, "Archmage Arugal", 1, 5, 0)
  check(not ns.char.deeds.bosses["Archmage Arugal"], "a failed attempt isn't a kill")
  event("ENCOUNTER_END", 1, "Archmage Arugal", 1, 5, 1)
  event("ENCOUNTER_END", 1, "Archmage Arugal", 1, 5, 1)
  local b = ns.char.deeds.bosses["Archmage Arugal"]
  check(b and b.where == "Shadowfang Keep" and b.kills == 2, "a master's fall is recorded once, with the place and the count")
  C.Refresh()
  local names = {}
  for _, e in ipairs(C.EarnedAll()) do names[#names + 1] = e.nick end
  check(table.concat(names, ",") == "Defias-Breaker,Pig-Sticker,Arugal's Bane", "every name from the record: " .. table.concat(names, ","))
  local st = C.Stats()
  check(st.foes == "1" and st.jobs == "2", "statistics count the record too: " .. tostring(st.foes) .. "/" .. tostring(st.jobs))
  -- Chains finished before the record began, where the game can list them.
  local TITLES = { [101] = "The Green Hills of Stranglethorn", [102] = "Kill Some Boars", [103] = 'Wanted: "Hogger"' }
  C_QuestLog = { GetAllCompletedQuestIDs = function() return { 101, 102, 103, 104 } end,
    GetTitleForQuestID = function(id) return TITLES[id] end }
  local said = {}
  local oldChat = DEFAULT_CHAT_FRAME.AddMessage
  DEFAULT_CHAT_FRAME.AddMessage = function(_, m) said[#said + 1] = m end
  C.NoticeNames()
  check(ns.Sources.Deeds.Backfill() == 2, "the backfill takes in only quests that earn a name")
  check(ns.char.deeds.quests["The Green Hills of Stranglethorn"] and not ns.char.deeds.quests["Kill Some Boars"], "and leaves the rest")
  check(ns.Sources.Deeds.Backfill() == 0, "and takes nothing in twice")
  C.Refresh(); ns.Mood.Watch()
  DEFAULT_CHAT_FRAME.AddMessage = oldChat
  check(#said == 0 and C.LatelyGlance().TI ~= "A Name Earned", "names from before are taken in quietly")
  local hasPages = false
  for _, e in ipairs(C.EarnedAll()) do if e.nick == "Page-Gatherer" then hasPages = true end end
  check(hasPages, "and earn their names")
  C_QuestLog = nil
  check(ns.Sources.Deeds.Backfill() == 0, "no backfill where the game can't list them")
  -- With Chronicle back, the earlier of the two times stands and nothing is counted twice.
  ChronicleCharDB = chron
  ChronicleCharDB.quests = { { time = NOW - 99999, title = "The Defias Brotherhood", status = "completed", zone = "Westfall" } }
  ChronicleCharDB.bosses = { ["1"] = { name = "Archmage Arugal", kills = 1, lastSuccess = NOW - 5000, instanceName = "Shadowfang Keep" } }
  C.SourcesChanged(); C.Refresh()
  check(C.Finished()["The Defias Brotherhood"].t == NOW - 99999, "the earlier time of the two sources stands")
  check(#C.Bosses() == 1 and C.Bosses()[1].first == NOW - 5000, "a master in both counts once")
  check(C.Stats().foes == "1", "and once in the statistics")
  ChronicleCharDB.quests, ChronicleCharDB.bosses = {}, { ["1"] = { name = "Edwin VanCleef", kills = 1, lastSuccess = NOW - 7000, instanceName = "The Deadmines" } }
  RPGDialogueCharDB.threads = threads
  ns.char.deeds, ns.char.names = nil, nil
  GetTitleText, GetQuestID, GetInstanceInfo = nil, nil, nil
  state.zone = "Duskwood"
  C.SourcesChanged(); C.Refresh()
end

-- 0.20.0 fixes: statistics in order, switched off means taken down, the mood journal command,
-- ranks on the character's own ladder, goals as written, jobs and victories without Chronicle.
do
  local C, Deeds = ns.Compose, ns.Sources.Deeds
  local said = {}
  local oldChat = DEFAULT_CHAT_FRAME.AddMessage
  local function listen() said = {}; DEFAULT_CHAT_FRAME.AddMessage = function(_, m) said[#said + 1] = m end end
  local function stop() DEFAULT_CHAT_FRAME.AddMessage = oldChat end
  local function labels()
    local out = {}
    for _, e in ipairs(p.characteristics.MI) do out[#out + 1] = tostring(e.NA) end
    return table.concat(out, ",")
  end
  local function statIndex(label)
    for i, e in ipairs(p.characteristics.MI) do if e.ID == 1 and e.NA == label then return i end end
  end

  -- Statistics are written in their own order, after everything else, and stay that way.
  listen(); SlashCmdList.AUTOTRP("claim all"); stop()
  local order, last, inOrder = {}, 0, true
  for i, st in ipairs(C.STATS) do order[st.label] = i end
  for _, e in ipairs(p.characteristics.MI) do
    if e.ID == 1 and order[e.NA] then
      if order[e.NA] < last then inOrder = false end
      last = order[e.NA]
    end
  end
  check(inOrder, "statistics are written in their own order: " .. labels())
  local nickAt
  for i, e in ipairs(p.characteristics.MI) do if e.ID == 3 then nickAt = i end end
  check(nickAt and statIndex("Deaths") > nickAt, "and after the nickname")
  -- A profile from an earlier version, with its statistics in no order and one of the player's
  -- own entries among them: gathered into one ordered run, the player's entry left where it was.
  local MI = p.characteristics.MI
  local mine = {}
  for i = #MI, 1, -1 do if MI[i].ID == 1 then table.insert(mine, 1, table.remove(MI, i)) end end
  local scrambled = {}
  for i = #mine, 1, -1 do scrambled[#scrambled + 1] = mine[i] end
  table.insert(scrambled, 2, { ID = 1, NA = "Favourite ale", VA = "Thunderbrew" })
  for _, e in ipairs(scrambled) do MI[#MI + 1] = e end
  local aleAt = statIndex("Favourite ale")
  local v0 = p.characteristics.v
  ns.UI.Update(true)
  check(statIndex("Favourite ale") < statIndex("Deaths") and statIndex("Deaths") < statIndex("Lands explored")
    and statIndex("Lands explored") < statIndex("Names earned"), "scattered statistics are tidied into order: " .. labels())
  check(p.characteristics.v ~= v0, "and the change is sent out")
  local tidy = labels()
  ns.UI.Update(true)
  check(labels() == tidy, "a tidy profile isn't shuffled again")
  -- A statistic that appears later goes into its place, not at the end.
  ChronicleCharDB.rares = { a = {}, b = {} }
  C.SourcesChanged(); ns.UI.Update(true)
  check(statIndex("Rare beasts") == statIndex("Named foes felled") + 1, "a new statistic takes its place in the order: " .. labels())

  -- Switched off, a statistic is taken off the profile; switched on, it comes back.
  ns.db.fields.stat_deaths = false
  ns.UI.Update(true)
  check(statIndex("Deaths") == nil and ns.TRP.Status("stat_deaths") == "off", "a statistic switched off is taken down")
  ns.db.fields.stat_deaths = true
  ns.UI.Update(true)
  check(statIndex("Deaths") ~= nil, "and comes back when switched on")
  -- The whole set at once.
  ns.db.fields.stats = false
  ns.UI.Update(true)
  check(statIndex("Wealth") == nil and statIndex("Lands explored") == nil and statIndex("Favourite ale") ~= nil,
    "the master switch takes them all down, and not the player's own")
  ns.db.fields.stats = true
  ns.UI.Update(true)
  check(statIndex("Wealth") ~= nil, "and puts them back")
  -- One the player edited is theirs: switching it off leaves their words.
  p.characteristics.MI[statIndex("Crafts")].VA = "Herbalism, and a bit of everything"
  ns.db.fields.stat_crafts = false
  ns.UI.Update(true)
  check(statIndex("Crafts") and p.characteristics.MI[statIndex("Crafts")].VA == "Herbalism, and a bit of everything"
    and ns.TRP.Status("stat_crafts") == "off", "an edited statistic isn't taken down")
  ns.db.fields.stat_crafts = true
  check(ns.TRP.Status("stat_crafts") == "yours", "it's the player's now")
  -- A glance switched off is hidden, its text kept; back on, it shows again.
  local slot = tostring(ns.char.glanceSlots.marks)
  ns.db.fields.glance_marks = false
  ns.UI.Update(true)
  check(p.misc.PE[slot].AC == false and p.misc.PE[slot].TX, "a glance switched off is hidden")
  local v1 = p.misc.v
  ns.UI.Update(true)
  check(p.misc.v == v1, "and isn't hidden over and over")
  ns.db.fields.glance_marks = true
  ns.UI.Update(true)
  check(p.misc.PE[slot].AC == true and ns.TRP.Status("glance_marks") == "auto", "and shows again when switched on")
  ChronicleCharDB.rares = {}

  -- /atrp days
  ns.char.days = { [os.date("%Y-%m-%d", NOW)] = { moods = { downcast = 9 }, zones = { Duskwood = 10 } } }
  listen(); SlashCmdList.AUTOTRP("days"); stop()
  check(said[2] and said[2]:find("Today: Downcast, mostly in Duskwood"), "/atrp days lists the mood journal: " .. tostring(said[2]))
  ns.char.days = {}
  listen(); SlashCmdList.AUTOTRP("days"); stop()
  check(said[1] and said[1]:find("Nothing in the mood journal yet"), "and says so when it's empty")

  -- Rank milestones use the character's own ladder, as the Title does.
  UnitRace = function() return "Undead", "Scourge" end
  UnitClass = function() return "Rogue", "ROGUE" end
  UnitFactionGroup = function() return "Horde" end
  ns.char.milestones = nil
  event("PLAYER_LEVEL_UP", 10)
  check(ns.char.milestones and ns.char.milestones[1].rank == "Footpad", "a Forsaken rogue is made Footpad at ten: "
    .. tostring(ns.char.milestones and ns.char.milestones[1].rank))
  -- One saved by an earlier version from the plain class ladder is told by its level.
  ns.char.milestones = { { level = 30, rank = "Cutthroat", zone = "Hillsbrad Foothills", t = NOW - 100 } }
  C.Refresh()
  check(C.History():find("rose to Deathstalker in Hillsbrad Foothills"), "an old milestone reads on the right ladder")
  ns.char.milestones = nil
  UnitRace = function() return "Human", "Human" end
  UnitClass = function() return "Priest", "PRIEST" end
  UnitFactionGroup = function() return "Alliance" end

  -- Every race and class has a rank ladder, and the whole sheet can be written for each.
  local RACES = { Human = "Alliance", Dwarf = "Alliance", NightElf = "Alliance", Gnome = "Alliance",
    Orc = "Horde", Scourge = "Horde", Tauren = "Horde", Troll = "Horde", Goblin = "Horde" }
  local CLASSES = { "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID", "DEATHKNIGHT" }
  local broken = {}
  for race, faction in pairs(RACES) do
    for _, class in ipairs(CLASSES) do
      UnitRace = function() return race, race end
      UnitClass = function() return class, class end
      UnitFactionGroup = function() return faction end
      ns.World.slow = nil
      local okSheet, sh = pcall(C.Sheet)
      local ladder = C.Ranks({ race = race, class = class, faction = faction })
      if not okSheet or #ladder ~= 7 or not sh.title or not sh.history then
        broken[#broken + 1] = race .. "/" .. class .. (okSheet and "" or (": " .. tostring(sh)))
      end
    end
  end
  check(#broken == 0, "every race and class has a ladder and a whole sheet: " .. table.concat(broken, ", "))

  -- With no other addon and nothing earned, every combination still gets a full profile.
  do
    local keep = { RPGDialogueCharDB, SocialDiaryCharDB, ChronicleCharDB, ns.char.deeds, ns.char.names, ns.char.milestones, ns.char.finds }
    RPGDialogueCharDB, SocialDiaryCharDB, ChronicleCharDB = nil, nil, nil
    ns.char.deeds, ns.char.names, ns.char.milestones, ns.char.finds = nil, nil, nil, nil
    local thin = {}
    for race, faction in pairs(RACES) do
      for _, class in ipairs(CLASSES) do
        UnitRace = function() return race, race end
        UnitClass = function() return class, class end
        UnitFactionGroup = function() return faction end
        ns.World.slow = nil
        C.SourcesChanged()
        local okSheet, sh = pcall(C.Sheet)
        local missing = {}
        if not okSheet then missing[1] = tostring(sh) else
          for _, k in ipairs({ "currently", "bearing", "history", "physical", "title", "fulltitle", "motto", "nickname", "icon", "walkup", "ooc" }) do
            if sh[k] == nil or sh[k] == "" then missing[#missing + 1] = k end
          end
          if not sh.traits or #sh.traits < 3 then missing[#missing + 1] = "traits" end
          if select(2, (sh.bearing or ""):gsub("%. ", "")) < 2 then missing[#missing + 1] = "bearing (short)" end
          if select(2, (sh.history or ""):gsub("%. ", "")) < 2 then missing[#missing + 1] = "history (short)" end
          for _, g in ipairs({ "mood", "lately", "company", "ambition", "marks" }) do
            local v = sh.glances[g]
            if not v or not v.TX or v.TX == "" or not v.TI or not v.IC then missing[#missing + 1] = "glance " .. g end
          end
          for _, k in ipairs({ "deaths", "lands", "road", "dungeons", "foes", "rares", "slain", "jobs", "wealth", "crafts", "standing", "books", "names", "spell",
            "fish", "made", "gathered", "duels", "battles", "gold", "inns", "hit" }) do
            if not sh.stats[k] then missing[#missing + 1] = "stat " .. k end
          end
        end
        if #missing > 0 then thin[#thin + 1] = race .. "/" .. class .. ": " .. table.concat(missing, ",") end
      end
    end
    check(#thin == 0, "a bare character of every race and class has every field filled: " .. table.concat(thin, " | "))

    -- Auto TRP's own record from game events fills the statistics without any other addon.
    UnitRace = function() return "Human", "Human" end
    UnitClass = function() return "Priest", "PRIEST" end
    UnitFactionGroup = function() return "Alliance" end
    ns.char.deeds = nil
    local log
    CombatLogGetCurrentEventInfo = function() return unpack(log) end
    for i = 1, 12 do
      log = { 0, "PARTY_KILL", false, "Player-1-0001", "Aldric", 0, 0, "Creature-1", "Defias Bandit" }
      event("COMBAT_LOG_EVENT_UNFILTERED")
    end
    log = { 0, "PARTY_KILL", false, "Player-2-0002", "Someone", 0, 0, "Creature-2", "Murloc" }
    event("COMBAT_LOG_EVENT_UNFILTERED")
    ns.char.lastFight = { foe = "Hogger", t = NOW }
    event("PLAYER_DEAD")
    local inInst = IsInInstance
    IsInInstance = function() return true, "party" end
    GetInstanceInfo = function() return "The Deadmines" end
    event("ZONE_CHANGED_NEW_AREA")
    IsInInstance = inInst
    local seenZones = ns.char.seen.zones
    ns.char.seen.zones = { ["Elwynn Forest"] = NOW - 3 * 86400, Westfall = NOW - 86400 }
    C.SourcesChanged(); C.Refresh()
    local st = C.Stats()
    check(st.slain == "12, 12 of them Defias Bandits", "kills from the combat log, only the player's: " .. tostring(st.slain))
    check(st.deaths == "1, the first to Hogger", "a death, with who did it: " .. tostring(st.deaths))
    check(st.dungeons == "1", "a dungeon entered: " .. tostring(st.dungeons))
    ns.char.seen.zones = ns.char.seen.zones or {}
    ns.char.seen.zones["The Deadmines"] = NOW - 5 * 86400
    C.SourcesChanged(); C.Refresh()
    local isLand = false
    for _, z in ipairs(ns.cache.deeds.zones) do if z.name == "The Deadmines" then isLand = true end end
    check(not isLand, "a dungeon entered isn't counted as a land")
    ns.char.seen.zones["The Deadmines"] = nil
    check(st.lands == "2" and st.road == "3", "lands and days on the road from Auto TRP's own record: "
      .. tostring(st.lands) .. ", " .. tostring(st.road))
    ns.char.seen.zones = seenZones
    CombatLogGetCurrentEventInfo = nil
    RPGDialogueCharDB, SocialDiaryCharDB, ChronicleCharDB = keep[1], keep[2], keep[3]
    ns.char.deeds, ns.char.names, ns.char.milestones, ns.char.finds = keep[4], keep[5], keep[6], keep[7]
    C.SourcesChanged()
  end
  UnitRace = function() return "Human", "Human" end
  UnitClass = function() return "Warlock", "WARLOCK" end
  UnitFactionGroup = function() return "Alliance" end
  C.Refresh()
  check(C.Title() == "Summoner", "a human warlock has a title: " .. tostring(C.Title()))
  UnitClass = function() return "Priest", "PRIEST" end
  ns.World.slow = nil
  C.Refresh()

  -- A Chronicle goal keeps its own ending.
  local goals = ChronicleCharDB.goals
  ChronicleCharDB.goals = { { text = "Will I ever see Theramore?", done = false, created = NOW } }
  C.SourcesChanged(); C.Refresh()
  check(C.AmbitionGlance().TX == "Will I ever see Theramore?", "a goal with its own ending gets no extra full stop: " .. C.AmbitionGlance().TX)
  ChronicleCharDB.goals = { { text = string.rep("walk the length of the world ", 8), done = false, created = NOW } }
  C.SourcesChanged(); C.Refresh()
  check(C.AmbitionGlance().TX:find("%.%.%.$") and not C.AmbitionGlance().TX:find("%.%.%.%.$"), "a long goal ends in '...' only")
  ChronicleCharDB.goals = goals

  -- Without Chronicle: a job just done, and a master felled again, reach Lately.
  local chron = ChronicleCharDB
  ChronicleCharDB = nil
  ns.char.deeds, ns.char.names, ns.char.finds, ns.char.lastFight = nil, nil, nil, nil
  RPGDialogueCharDB.npc.farley.last = NOW - 90000
  GetTitleText = function() return "The Collector" end
  GetQuestID = function() return 123 end
  state.zone = "Elwynn Forest"
  event("QUEST_COMPLETE"); event("QUEST_TURNED_IN", 123, 0, 0)
  C.Refresh()
  check(C.LatelyGlance().TX:find('"The Collector", in Elwynn Forest'), "a job done reaches Lately without Chronicle: " .. C.LatelyGlance().TX)
  ns.char.deeds.quests["The Collector"].t = NOW - 7200
  ns.char.deeds.bosses["Hogger"] = { t = NOW - 5 * 86400, last = NOW - 5 * 86400, where = "Elwynn Forest", kills = 1 }
  C.SourcesChanged(); C.Refresh()
  check(C.LatelyGlance().TI ~= "Fresh Victory", "a master felled days ago isn't news")
  GetInstanceInfo = function() return "Elwynn Forest", "none" end
  event("ENCOUNTER_END", 1, "Hogger", 1, 5, 1)
  C.Refresh()
  check(C.LatelyGlance().TI == "Fresh Victory", "felled again, it's news at once")
  -- The record forgets its oldest quests past the limit, but never one that earns a name.
  local keep = Deeds.KEEP_QUESTS
  Deeds.KEEP_QUESTS = 3
  ns.char.deeds = nil
  Deeds.Quest("The Defias Brotherhood", 166, "Westfall", NOW - 500)
  Deeds.Quest("Kill Some Boars", 1, "Elwynn Forest", NOW - 400)
  Deeds.Quest("Bounty on Murlocs", 2, "Elwynn Forest", NOW - 300)
  Deeds.Quest("A Fishy Peril", 3, "Elwynn Forest", NOW - 200)
  local q = ns.char.deeds.quests
  check(q["The Defias Brotherhood"] and not q["Kill Some Boars"], "the oldest quest is forgotten, never a name-earning one")
  Deeds.KEEP_QUESTS = keep
  ChronicleCharDB = chron
  ns.char.deeds, ns.char.names = nil, nil
  GetTitleText, GetQuestID, GetInstanceInfo = nil, nil, nil
  state.zone = "Duskwood"
  C.SourcesChanged(); C.Refresh()

  -- Item info arriving re-reads gear only when the last read was waiting on a name.
  ns.World.slow = { t = NOW, gear = {}, reagents = {} }
  event("GET_ITEM_INFO_RECEIVED", 1234, true)
  check(not ns.World.slow.dirty, "item info for something else costs nothing")
  ns.World.slow.gear.incomplete = true
  event("GET_ITEM_INFO_RECEIVED", 1234, true)
  check(ns.World.slow.dirty, "item info the gear was waiting on reads it again")
  ns.World.slow = nil
end

-- The most cast spell: counted from the character's own casts, swings, hearthstone,
-- gathering, crafting and items left out; a statistic, and a line in Personality.
do
  local C = ns.Compose
  local SPELLS = { [2061] = "Flash Heal", [139] = "Renew", [6603] = "Attack", [8690] = "Hearthstone", [746] = "Linen Bandage",
    [3908] = "Tailoring", [17] = "Power Word: Shield" }
  local oldInfo = GetSpellInfo
  GetSpellInfo = function(id) return SPELLS[id] end
  IsPlayerSpell = function(id) return id ~= 746 end
  ns.char.casts = nil
  check(C.Stats().spell == "None yet" and not (C.Bearing() or ""):find("Flash Heal"), "nothing cast yet: None yet, no line")
  local function cast(id, times) for _ = 1, times do event("UNIT_SPELLCAST_SUCCEEDED", "player", "cast-guid", id) end end
  cast(2061, 9); cast(139, 4); cast(6603, 40); cast(8690, 3); cast(746, 20)
  ns.World.SetContext("craft", "Tailoring"); cast(3908, 30); ns.World.SetContext("none")
  local n = ns.char.casts.n
  check(n["Flash Heal"] == 9 and n["Renew"] == 4, "the character's own spells are counted")
  check(not n["Attack"] and not n["Hearthstone"] and not n["Linen Bandage"] and not n["Tailoring"],
    "swings, the hearthstone, items and crafting are not")
  check(C.Stats().spell:find("^Flash Heal, "), "a few casts: the statistic, not yet a habit: " .. C.Stats().spell)
  cast(2061, 1)
  check(C.Stats().spell == "Flash Heal, 10 times", "the most cast spell is a statistic: " .. tostring(C.Stats().spell))
  check(not C.Bearing():find("Flash Heal"), "but not yet a habit worth a line")
  cast(17, 60)
  local top = C.TopSpells(2)
  check(top[1].name == "Power Word: Shield" and top[2].name == "Flash Heal" and #top == 2, "the most cast comes first")
  local b = C.Bearing()
  check(b:find("Power Word: Shield", 1, true) and b:find("spell", 1, true), "Personality names the habit: " .. b:match("[^\n]*Shield[^\n]*"))
  check(C.Stats().spell == "Power Word: Shield, 60 times", "and the statistic follows: " .. tostring(C.Stats().spell))
  local rpgd = RPGDialogueCharDB
  RPGDialogueCharDB = nil
  C.SourcesChanged(); C.Refresh()
  check((C.Bearing() or ""):find("Power Word: Shield", 1, true), "without RPG Dialogue, the habit: " .. tostring(C.Bearing()))
  check(#(C.Bearing() or "") > 60, "and a class's disposition, so Personality isn't bare")
  local tr = C.Traits()
  local kind
  for _, t in ipairs(tr or {}) do if t.LT == "Kind" then kind = t.V2 end end
  check(tr and #tr >= 3 and kind == 14, "without RPG Dialogue, the traits lean by class and race")
  check(select(2, C.History():gsub("%. ", "")) >= 2, "a sparse History still says rank and where: " .. C.History():match("^[^\n]*"))
  RPGDialogueCharDB = rpgd
  UnitClass = function() return "Warrior", "WARRIOR" end
  C.SourcesChanged(); C.Refresh()
  check(C.Bearing():find("ability", 1, true), "a warrior's is an ability")
  UnitClass = function() return "Priest", "PRIEST" end
  local said = {}
  local oldChat = DEFAULT_CHAT_FRAME.AddMessage
  DEFAULT_CHAT_FRAME.AddMessage = function(_, m) said[#said + 1] = m end
  SlashCmdList.AUTOTRP("spells")
  DEFAULT_CHAT_FRAME.AddMessage = oldChat
  check(table.concat(said):find("Power Word: Shield 60, Flash Heal 10, Renew 4", 1, true), "/atrp spells lists them: " .. table.concat(said))
  check(ns.TRP.FIELDS.stat_spell ~= nil, "the statistic has its own switch")
  ns.char.casts, IsPlayerSpell, GetSpellInfo = nil, nil, oldInfo
  C.SourcesChanged(); C.Refresh()
end

-- Total RP 3 alone: no RPG Dialogue, Social Diary or Chronicle. A session of play is
-- simulated through game events, and Auto TRP's own reading (Sources/Self.lua) has to give
-- a profile as full as the addons would: traits, Personality, five paragraphs of History,
-- an alignment in the Full title, real glances and statistics, and no other player named.
do
  local C, Self = ns.Compose, ns.Sources.Self
  local keep = { RPGDialogueCharDB, SocialDiaryCharDB, ChronicleCharDB }
  local keepChar = {}
  for _, k in ipairs({ "self", "deeds", "names", "milestones", "finds", "casts", "lastFight", "chosenName", "changes", "watched" }) do keepChar[k] = ns.char[k] end
  local keepZones = ns.char.seen.zones
  local apiNames = { "UnitGUID", "UnitName", "UnitLevel", "UnitIsPlayer", "UnitExists", "UnitCanAttack", "UnitClassification",
    "GetTitleText", "GetQuestID", "ItemTextGetItem", "ItemTextGetCreator", "CombatLogGetCurrentEventInfo", "GetPlayerTradeMoney",
    "GetTargetTradeMoney" }
  local keepAPI = {}
  for _, k in ipairs(apiNames) do keepAPI[k] = _G[k] end
  local keepState = { zone = state.zone, sub = state.sub, resting = state.resting, grouped = state.grouped }
  RPGDialogueCharDB, SocialDiaryCharDB, ChronicleCharDB = nil, nil, nil
  for k in pairs(keepChar) do ns.char[k] = nil end
  ns.char.seen.zones = { ["Elwynn Forest"] = NOW - 20 * 86400, Westfall = NOW - 9 * 86400, ["Redridge Mountains"] = NOW - 4 * 86400,
    Duskwood = NOW - 86400 }
  state.zone, state.sub, state.resting = "Elwynn Forest", "Lion's Pride Inn", true

  -- The unit under the cursor: the NPC in a window, the target in a fight.
  local npc, target = {}, {}
  UnitGUID = function(u) if u == "npc" then return npc.guid end return "Player-1-0001" end
  UnitName = function(u) if u == "npc" then return npc.name end if u == "target" then return target.name end return "Aldric" end
  UnitIsPlayer = function(u) return (u == "target" and target.player) or (u == "npc" and npc.player) or false end
  local level = 2
  UnitLevel = function(u) if u == "target" then return target.level end return level end
  UnitExists = function(u) return u == "target" and target.name ~= nil end
  UnitCanAttack = function() return target.name ~= nil end
  UnitClassification = function() return target.class or "normal" end
  local function visit(ev, name, guid) npc.name, npc.guid = name, guid or ("Creature-0-1-" .. name); event(ev) end

  -- The first trainer, at the very start; then the people of Goldshire, again and again.
  visit("TRAINER_SHOW", "Priestess Josetta")
  level = 22
  for _ = 1, 10 do visit("GOSSIP_SHOW", "Innkeeper Farley"); visit("QUEST_DETAIL", "Marshal Dughan") end
  for _ = 1, 9 do visit("MERCHANT_SHOW", "Brog Hamfist"); visit("GOSSIP_SHOW", "Innkeeper Farley") end
  visit("GOSSIP_SHOW", "Stormwind City Guard")
  visit("QUEST_DETAIL", "Wanted Poster", "GameObject-0-1-99")
  npc.player = true; visit("GOSSIP_SHOW", "Brannigan", "Player-9-0009"); npc.player = false
  event("MERCHANT_CLOSED")

  -- Jobs done in Goldshire: storylines, one of them seen through.
  local qid = 500
  local function turnIn(title, zone)
    state.zone = zone or "Elwynn Forest"
    qid = qid + 1
    GetTitleText = function() return title end
    GetQuestID = function() return qid end
    event("QUEST_COMPLETE"); event("QUEST_TURNED_IN", qid, 0, 0)
  end
  for _, q in ipairs({ "Riverpaw Gnoll Bounty", "Protect the Frontier", "Find the Lost Guards", "Wanted: \"Hogger\"",
    "Young Lovers", "Kobold Camp Cleanup", "A Fishy Peril" }) do turnIn(q) end
  state.resting = false
  turnIn("The Killing Fields", "Westfall"); turnIn("Poor Old Blanchy", "Westfall")
  state.zone, state.resting = "Elwynn Forest", true

  -- Kindness to strangers (and a party member), from the combat log; others' lines cost nothing.
  local log
  CombatLogGetCurrentEventInfo = function() return unpack(log) end
  local function cl(sub, src, destFlags, aura)
    log = { 0, sub, false, src, "x", 0, 0, "Player-9-0009", "Brannigan", destFlags, 0, 2061, "Flash Heal", 2, aura }
    event("COMBAT_LOG_EVENT_UNFILTERED")
  end
  for _ = 1, 400 do cl("SPELL_HEAL", "Player-1-0001", 0x408) end
  for _ = 1, 40 do cl("SPELL_HEAL", "Player-1-0001", 0x402) end
  for _ = 1, 12 do cl("SPELL_AURA_APPLIED", "Player-1-0001", 0x408, "BUFF") end
  for _ = 1, 3 do cl("SPELL_RESURRECT", "Player-1-0001", 0x408) end
  for _ = 1, 50 do cl("SPELL_HEAL", "Player-7-0007", 0x408) end
  local n = ns.char.self.n
  check(n.strangerHeals == 400 and n.heals == 40 and n.strangerBuffs == 12 and n.rez == 3,
    "the player's own heals, buffs and resurrections on others are counted, strangers apart: "
    .. n.strangerHeals .. "/" .. n.heals .. "/" .. n.strangerBuffs .. "/" .. n.rez)

  -- Fights: elites and stronger foes are brave; a lowbie of the other side is a gank.
  state.resting = false
  for _ = 1, 30 do target = { name = "Defias Pillager", level = 25, class = "elite" }; event("PLAYER_REGEN_DISABLED") end
  target = { name = "Kestrel", level = 9, player = true }; event("PLAYER_REGEN_DISABLED")
  target = {}
  state.resting = true
  check(n.hardFights == 30 and n.ganks == 1, "fights are read by who they're against: " .. n.hardFights .. "/" .. n.ganks)

  -- Words and gestures, counted (whose, not what); a book, and a player's letter left out.
  for _ = 1, 20 do event("CHAT_MSG_SAY", "well met", "Aldric") end
  for _ = 1, 5 do event("CHAT_MSG_SAY", "hello Aldric", "Kestrel") end
  for _ = 1, 4 do event("CHAT_MSG_TEXT_EMOTE", "You dance with joy.") end
  for _ = 1, 3 do event("CHAT_MSG_TEXT_EMOTE", "You pray to the Gods.") end
  event("CHAT_MSG_TEXT_EMOTE", "Kestrel dances.")
  check(n.says == 20 and n.prayers == 3 and n.playful == 4, "your own /say, prayers and dances are counted, no one else's")
  ItemTextGetItem = function() return "The Kaldorei and the Well of Eternity" end
  ItemTextGetCreator = function() return nil end
  event("ITEM_TEXT_BEGIN")
  ItemTextGetItem = function() return "A note for you" end
  ItemTextGetCreator = function() return "Mirelle" end
  event("ITEM_TEXT_BEGIN")
  check(ns.char.self.books["The Kaldorei and the Well of Eternity"] and not ns.char.self.books["A note for you"],
    "books are kept, a player's letter isn't")
  -- A gift: something handed over for nothing back.
  GetPlayerTradeMoney, GetTargetTradeMoney = function() return 50000 end, function() return 0 end
  event("TRADE_ACCEPT_UPDATE", 1, 1)
  check(n.gifts == 1, "a gift in a trade is counted")

  -- Five hours resting in Goldshire, the last of them in company.
  for i = 1, 300 do state.grouped = i > 240; Self.Tick(60) end
  state.grouped = false
  check(ns.char.self.towns["Goldshire"] and ns.char.self.towns["Goldshire"].min >= 300 and ns.char.self.towns["Goldshire"].quests == 7,
    "time and jobs in Goldshire count for Goldshire, inn and all")

  C.SourcesChanged()
  local sh = C.Sheet()
  local own = C.Persona()
  check(own and own.own, "with Total RP 3 alone, the character is read from what the player does")
  check(own.npcs == nil and own.friends[1] and own.friends[1].name == "Innkeeper Farley" and own.friends[2].name == "Marshal Dughan",
    "the NPCs dealt with most are the people: " .. tostring(own.friends[1] and own.friends[1].name))
  local tr = {}
  for _, t in ipairs(sh.traits or {}) do tr[t.LT] = t.V2 end
  check(#(sh.traits or {}) >= 5 and (tr.Kind or 0) >= 17 and (tr.Good or 0) >= 14 and (tr.Brave or 0) >= 14,
    "the trait bars come from what was done (kind to strangers, brave against elites): Kind " .. tostring(tr.Kind)
    .. ", Good " .. tostring(tr.Good) .. ", Brave " .. tostring(tr.Brave) .. ", " .. #(sh.traits or {}) .. " bars")
  local b = sh.bearing or ""
  check(b:find("Aldric is kind", 1, true) and b:find("Kaldorei and the Well of Eternity", 1, true)
    and b:find("gnoll raids on Elwynn's border", 1, true),
    "Personality: temperament from behaviour, the book read and the stories followed: " .. b)
  local h = sh.history or ""
  local paras = 1
  for _ in h:gmatch("\n\n") do paras = paras + 1 end
  check(paras >= 5, "History has all its paragraphs: " .. paras)
  check(h:find("Priestess Josetta in Elwynn Forest", 1, true), "History tells where the training began")
  check(h:find("saw the gnoll raids on Elwynn's border through to the end", 1, true), "a storyline seen through is news")
  check(h:find("Innkeeper Farley", 1, true) and h:find("liked in Goldshire", 1, true), "History names the people and the town")
  check(sh.fulltitle == "Lightsworn, Friend of Goldshire", "the Full title has alignment and standing: " .. tostring(sh.fulltitle))
  check(sh.glances.company.TI == "Local Ties" and sh.glances.company.TX:find("Goldshire", 1, true),
    "Company: local ties: " .. sh.glances.company.TX)
  check(sh.glances.lately.TI ~= "Lately" or not sh.glances.lately.TX:find("around"), "Lately has news: " .. sh.glances.lately.TX)
  check(sh.stats.books == "1" and sh.stats.jobs == "9" and sh.stats.names:find("Hogger's Bane", 1, true)
    and sh.stats.crafts ~= "None yet", "the statistics fill: books " .. sh.stats.books .. ", jobs " .. sh.stats.jobs .. ", names " .. sh.stats.names)
  local all = {}
  local function gather(v) if type(v) == "string" then all[#all + 1] = v elseif type(v) == "table" then for _, x in pairs(v) do gather(x) end end end
  gather(sh)
  local text = table.concat(all, "\n")
  check(not text:find("Brannigan") and not text:find("Kestrel") and not text:find("Mirelle"), "no other player is named anywhere")
  if os.getenv("SAMPLES") then
    print("\n=== Total RP 3 alone ===\n" .. sh.title .. " / " .. sh.fulltitle .. "\n\n-- Personality --\n" .. b .. "\n\n-- History --\n" .. h)
    for _, k in ipairs({ "mood", "lately", "company", "ambition", "marks" }) do print(k .. ": " .. sh.glances[k].TI .. ": " .. sh.glances[k].TX) end
    local bars = {}
    for _, t in ipairs(sh.traits) do bars[#bars + 1] = t.LT .. "/" .. t.RT .. " " .. t.V2 end
    print("traits: " .. table.concat(bars, ", "))
  end

  -- With RPG Dialogue back, its choices lead and Auto TRP's own reading only fills gaps.
  RPGDialogueCharDB = keep[1]
  C.SourcesChanged(); C.Refresh()
  check(not C.Persona().own and C.FullTitle() == "Lightsworn, Friend of Goldshire" and C.Persona().friends[1].name == "Marshal Dughan",
    "with RPG Dialogue, its reading comes first")

  for _, k in ipairs(apiNames) do _G[k] = keepAPI[k] end
  for k, v in pairs(keepState) do state[k] = v end
  RPGDialogueCharDB, SocialDiaryCharDB, ChronicleCharDB = keep[1], keep[2], keep[3]
  for _, k in ipairs({ "self", "deeds", "names", "milestones", "finds", "casts", "lastFight", "chosenName", "changes", "watched" }) do ns.char[k] = keepChar[k] end
  ns.char.seen.zones = keepZones
  C.SourcesChanged(); C.Refresh()
end

-- Life on the road (Sources/Life.lua): every hook fed a fake event, with RPG Dialogue,
-- Social Diary and Chronicle all absent, then the writing it feeds.
do
  local C, L = ns.Compose, ns.Sources.Life
  local keep = { RPGDialogueCharDB, SocialDiaryCharDB, ChronicleCharDB, ns.char.deeds, ns.char.finds, ns.char.lastFight, ns.char.milestones }
  RPGDialogueCharDB, SocialDiaryCharDB, ChronicleCharDB = nil, nil, nil
  ns.char.deeds, ns.char.finds, ns.char.lastFight, ns.char.milestones = nil, nil, nil, nil
  ns.char.life = nil
  L.Store().since = NOW - 7200   -- the record has been running a while, so new things are news
  state.zone, state.sub, state.resting, state.combat = "Elwynn Forest", "Goldshire", false, false
  local function life() return ns.char.life end

  -- Fishing: a fishing loot window, fish counted (not grey junk), the first of a kind is news.
  IsFishingLoot = function() return true end
  event("LOOT_OPENED")
  for _ = 1, 6 do event("CHAT_MSG_LOOT", "You receive loot: |cffffffff|Hitem:6303::|h[Raw Slitherskin Mackerel]|h|r.") end
  event("CHAT_MSG_LOOT", "You receive loot: |cff9d9d9d|Hitem:1::|h[Waterlogged Envelope]|h|r.")
  IsFishingLoot = function() return false end
  check(life().fish.n == 6 and life().fish.byName["Raw Slitherskin Mackerel"] == 6, "fish caught are counted, grey junk isn't: " .. tostring(life().fish.n))
  check(life().fish.new and life().fish.new.name == "Raw Slitherskin Mackerel" and life().fish.new.zone == "Elwynn Forest", "a new kind of fish is news, with where")
  -- Gathering: herbs from a gathering loot window.
  ns.World.SetContext("herbs")
  event("LOOT_OPENED")
  event("CHAT_MSG_LOOT", "You receive loot: |cffffffff|Hitem:2447::|h[Peacebloom]|h|rx3.")
  check(life().gather.herbs == 3, "herbs gathered, with how many: " .. tostring(life().gather.herbs))
  ns.World.SetContext("mining"); event("LOOT_OPENED")
  event("CHAT_MSG_LOOT", "You receive loot: |cffffffff|Hitem:2770::|h[Copper Ore]|h|r.")
  check(life().gather.ore == 1, "ore mined")
  -- Crafting: "You create" at a trade.
  ns.World.SetContext("craft", "Cooking")
  event("CHAT_MSG_LOOT", "You create: |cffffffff|Hitem:6890::|h[Smoked Bear Meat]|h|rx5.")
  ns.World.SetContext("none")
  check(life().made.n == 5 and life().made.byProf.Cooking == 5 and life().made.byItem["Smoked Bear Meat"] == 5, "things made, by trade and item")
  -- Duels, from the system line; the other side's name is never kept.
  event("CHAT_MSG_SYSTEM", "Aldric has defeated Brannoc in a duel")
  event("CHAT_MSG_SYSTEM", "Brannoc has defeated Aldric in a duel")
  event("CHAT_MSG_SYSTEM", "Aldric has fled from Brannoc in a duel")
  event("DUEL_FINISHED")
  check(life().duels.won == 1 and life().duels.lost == 2, "duels won and lost (fleeing is a loss): " .. tostring(life().duels.won) .. "/" .. tostring(life().duels.lost))
  local saved = false
  local function find(t, s) for k, v in pairs(t) do if v == s or k == s or (type(v) == "table" and find(v, s)) then return true end end end
  check(not find(life(), "Brannoc"), "the other duellist's name is never kept")
  -- Money: looted coin, quest rewards, repairs, vendor buying and selling, the most held, auctions.
  event("CHAT_MSG_MONEY", "You loot 2 Gold, 3 Silver, 4 Copper")
  event("QUEST_TURNED_IN", 99, 450, 5000)
  local purse = 250000
  local oldMoney = GetMoney
  GetMoney = function() return purse end
  GetRepairAllCost = function() return 1500 end
  event("PLAYER_MONEY")
  event("MERCHANT_SHOW")
  purse = 248500; event("PLAYER_MONEY")
  purse = 248000; event("PLAYER_MONEY")
  purse = 249000; event("PLAYER_MONEY")
  event("MERCHANT_CLOSED")
  purse = 5000000; event("PLAYER_MONEY")
  purse = 250000; event("PLAYER_MONEY")
  GetMoney, GetRepairAllCost = oldMoney, nil
  local m = life().money
  check(m.looted == 20304 and m.quests == 5000, "coin looted and earned from jobs: " .. tostring(m.looted) .. ", " .. tostring(m.quests))
  check(m.repairs == 1500 and m.vendor == 500 and m.sold == 1000, "repairs, buying and selling at a vendor")
  check(m.most == 5000000, "the most gold ever held")
  event("CHAT_MSG_SYSTEM", "A buyer has been found for your auction of Linen Cloth.")
  check(m.auctions == 1, "an auction sold")
  -- Inns, the hearthstone, flight masters, a mount, a level, /played.
  state.resting, state.sub = true, "Lion's Pride Inn"
  event("PLAYER_UPDATE_RESTING")
  check(life().inns["Lion's Pride Inn"] and not life().inns["Lion's Pride Inn"].before, "resting at an inn")
  state.resting, state.sub = false, "Goldshire"
  event("UNIT_SPELLCAST_SUCCEEDED", "player", "cast", 8690)
  check(life().hearths == 1, "the hearthstone")
  local nodes = { { "Stormwind, Elwynn", "CURRENT" }, { "Lakeshire, Redridge", "REACHABLE" }, { "Far Away", "NONE" } }
  NumTaxiNodes = function() return #nodes end
  TaxiNodeGetType = function(i) return nodes[i][2] end
  TaxiNodeName = function(i) return nodes[i][1] end
  event("TAXIMAP_OPENED"); event("TAXIMAP_CLOSED")
  nodes[#nodes + 1] = { "Sentinel Hill, Westfall", "REACHABLE" }
  event("TAXIMAP_OPENED"); event("TAXIMAP_CLOSED")
  NumTaxiNodes, TaxiNodeGetType, TaxiNodeName = nil, nil, nil
  check(life().paths.known["Stormwind, Elwynn"] == 1 and life().paths.known["Sentinel Hill, Westfall"] == NOW and not life().paths.known["Far Away"],
    "flight masters: the first look takes in the known, a later one is new")
  IsMounted = function() return true end
  state.buffs[#state.buffs + 1] = "Brown Horse"
  L.CheckMount()
  table.remove(state.buffs)
  IsMounted = function() return false end
  L.CheckMount()
  check(life().mounts.seen["Brown Horse"], "a mount ridden for the first time")
  event("TIME_PLAYED_MSG", 90000, 3600)
  event("PLAYER_LEVEL_UP", 23)
  check(life().levels[23] and life().levels[23].played == 3600, "a level, with how long the one before took to play")
  -- Emotes, the company kept (counted, never named), coming back.
  for _ = 1, 30 do event("CHAT_MSG_TEXT_EMOTE", "You wave.") end
  check(life().emotes.wave == 30, "emotes the character uses")
  local oldName = UnitName
  local party = { party1 = "Mirelle", party2 = "Tobb" }
  UnitName = function(u) return party[u] or "Aldric" end
  state.grouped = true
  event("GROUP_ROSTER_UPDATE")
  event("GROUP_ROSTER_UPDATE")
  check(life().company.n == 2 and life().company.groups == 1, "people grouped with, each once per group")
  check(not find(life(), "Tobb") and not find(life(), "Mirelle"), "and never by name")
  check(L.TimesWith("Mirelle") == 1, "but a friend can be looked up by name")
  state.grouped = false
  event("GROUP_ROSTER_UPDATE")
  party = { party1 = "Hesk" }
  state.grouped, state.combat = true, true
  event("GROUP_ROSTER_UPDATE")
  check(life().company.n == 2, "nothing is counted in a fight")
  state.combat = false
  event("PLAYER_REGEN_ENABLED")
  check(life().company.n == 3 and life().company.groups == 2, "the roster is read when the fight ends")
  state.grouped = false
  event("GROUP_ROSTER_UPDATE")
  UnitName = oldName
  event("RESURRECT_REQUEST", "Someone"); event("PLAYER_ALIVE")
  event("CONFIRM_XP_LOSS"); event("PLAYER_UNGHOST")
  check(life().rez.other == 1 and life().rez.spirit == 1, "resurrected by someone else, and by the spirit healer")
  -- The combat log: the hardest hits, falls, killing blows on players (never by name).
  local log
  CombatLogGetCurrentEventInfo = function() return unpack(log) end
  local function cl(...) log = { ... }; event("COMBAT_LOG_EVENT_UNFILTERED") end
  cl(0, "SWING_DAMAGE", false, "Player-1-0001", "Aldric", 0, 0, "Creature-1", "Kobold", 0, 0, 120)
  cl(0, "SPELL_DAMAGE", false, "Player-1-0001", "Aldric", 0, 0, "Creature-1", "Kobold", 0, 0, 585, "Smite", 2, 340)
  cl(0, "SWING_DAMAGE", false, "Creature-2", "Defias Pillager", 0, 0, "Player-1-0001", "Aldric", 0, 0, 500)
  cl(0, "SPELL_DAMAGE", false, "Player-9-0009", "Gankalot", 0, 0, "Player-1-0001", "Aldric", 0, 0, 1, "Backstab", 1, 900)
  cl(0, "SPELL_HEAL", false, "Player-1-0001", "Aldric", 0, 0, "Player-1-0001", "Aldric", 0, 0, 2061, "Flash Heal", 2, 5000)
  cl(0, "PARTY_KILL", false, "Player-1-0001", "Aldric", 0, 0, "Player-9-0009", "Gankalot")
  cl(0, "ENVIRONMENTAL_DAMAGE", false, nil, nil, 0, 0, "Player-1-0001", "Aldric", 0, 0, "Falling", 80)
  check(life().hits.dealt.n == 340 and life().hits.dealt.spell == "Smite", "the hardest hit dealt, with the spell")
  check(life().hits.taken.n == 900 and life().hits.taken.from == nil, "the hardest hit taken; a player who dealt it isn't named")
  check(life().pvp.kb == 1 and not (ns.char.deeds and ns.char.deeds.kills and ns.char.deeds.kills.byName.Gankalot), "a killing blow on a player, never kept by name")
  check(life().env.Falling and life().env.Falling.n == 1, "a fall")
  cl(0, "ENVIRONMENTAL_DAMAGE", false, nil, nil, 0, 0, "Player-1-0001", "Aldric", 0, 0, "Falling", 800)
  event("PLAYER_DEAD")
  local dd = ns.char.deeds.deaths
  check(dd[#dd].cause == "Falling" and dd[#dd].killer == nil and life().env.Falling.deaths == 1, "a death from a fall is the fall's, not the last foe's")
  CombatLogGetCurrentEventInfo = nil
  -- A close call: under a tenth of health in a fight, and still standing at the end.
  local oldHealth = UnitHealth
  event("PLAYER_REGEN_DISABLED")
  UnitHealth = function() return 6 end
  event("UNIT_HEALTH", "player")
  UnitHealth = oldHealth
  event("PLAYER_REGEN_ENABLED")
  check(life().close.n == 1 and life().close.last.zone == "Elwynn Forest", "a close call")
  ns.char.lastFight = nil
  -- Gear: the first rare and epic piece put on; books and letters read.
  event("PLAYER_EQUIPMENT_CHANGED", 1, true)
  event("PLAYER_EQUIPMENT_CHANGED", 16, true)
  event("PLAYER_EQUIPMENT_CHANGED", 5, true)
  check(life().gear.epic.name == "Crown of the Lost" and life().gear.rare.name == "Staff of Westfall", "the first epic and rare piece worn")
  ItemTextGetItem = function() return "The Fall of Ameth'Aran" end
  ItemTextGetCreator = function() return nil end
  event("ITEM_TEXT_BEGIN")
  ItemTextGetCreator = function() return "Brannoc" end
  event("ITEM_TEXT_BEGIN")
  ItemTextGetItem, ItemTextGetCreator = nil, nil
  check(life().books["The Fall of Ameth'Aran"] and life().letters.n == 1, "a book by its title; a letter counted, its writer not kept")
  local mails = { false, false }
  GetInboxNumItems = function() return #mails end
  GetInboxHeaderInfo = function(i) return nil, nil, "x", "y", 0, 0, 3, false, mails[i] end
  event("MAIL_SHOW"); event("MAIL_INBOX_UPDATE")
  mails[1] = true; event("MAIL_INBOX_UPDATE")
  GetInboxNumItems, GetInboxHeaderInfo = nil, nil
  check(life().letters.n == 2, "a letter opened at the mailbox")
  -- A battleground: the result counted once.
  local oldInst = IsInInstance
  IsInInstance = function() return true, "pvp" end
  GetInstanceInfo = function() return "Warsong Gulch" end
  GetBattlefieldWinner = function() return 1 end
  event("UPDATE_BATTLEFIELD_STATUS"); event("UPDATE_BATTLEFIELD_STATUS")
  IsInInstance, GetInstanceInfo, GetBattlefieldWinner = oldInst, nil, nil
  check(life().pvp.fought == 1 and life().pvp.won == 1, "a battleground won, counted once")

  -- The writing, with no other addon at all.
  ns.World.slow = nil
  C.SourcesChanged(); C.Refresh()
  local st = C.Stats()
  check(st.fish == "6" and st.made == "5" and st.gathered == "3 herbs, 1 ore", "statistics: fish, things made, gathered: "
    .. tostring(st.fish) .. " | " .. tostring(st.made) .. " | " .. tostring(st.gathered))
  check(st.duels == "1 won, 2 lost" and st.battles == "1 fought, 1 won; 1 killing blow", "statistics: duels and battles: " .. tostring(st.duels) .. " | " .. tostring(st.battles))
  check(st.gold == "9,999 gold, 99 silver" and st.inns == "1", "statistics: most gold held (or the purse now, if more), inns: " .. tostring(st.gold) .. " | " .. tostring(st.inns))
  check(st.hit == "340 with Smite; 900 taken", "statistics: the hardest hits: " .. tostring(st.hit))
  check(st.books == "1", "books read without RPG Dialogue: " .. tostring(st.books))
  local hist = C.History()
  print("\nHistory from Auto TRP's own record alone:\n" .. hist)
  check(hist:find("Warsong Gulch", 1, true) and hist:find("Brown Horse", 1, true), "History: a battle and a new mount")
  check(hist:find("Crown of the Lost", 1, true), "History: fine gear put on")
  -- Five events at most make the news; with the weightier ones a month old, the rest come through.
  local function age(t) if t then t.t = NOW - 30 * 86400 end end
  age(life().pvp.last); age(life().mounts.seen["Brown Horse"]); age(life().gear.epic); age(life().gear.rare)
  local honours, zonesSeen = ns.char.honours, ns.char.seen.zones
  ns.char.honours, ns.char.seen.zones = nil, {}
  C.SourcesChanged(); C.Refresh()
  local news = C.History()
  print("\nHistory, the smaller news:\n" .. news)
  check(news:find("Slitherskin Mackerel", 1, true) and news:find("Elwynn Forest", 1, true), "History: a new kind of fish")
  check(news:find("Lion's Pride Inn", 1, true), "History: a new inn")
  check(news:find("The Fall of Ameth'Aran", 1, true) or news:find("only just came through", 1, true) or news:find("within a breath", 1, true), "History: a book or a close call")
  do
    local twice
    for sent in news:gmatch("[^%.]+") do
      local seen = {}
      for place in sent:gmatch(" in ([%u][%a']+ ?[%u]?[%a']*)") do
        if seen[place] then twice = sent end
        seen[place] = true
      end
    end
    check(not twice, "History's news names a place once a sentence: " .. tostring(twice))
  end
  ns.char.honours, ns.char.seen.zones = honours, zonesSeen
  life().pvp.last.t, life().mounts.seen["Brown Horse"].t, life().gear.epic.t = NOW, NOW, NOW
  check(not hist:find("Gankalot", 1, true) and not hist:find("Brannoc", 1, true) and not hist:find("died", 1, true), "History names no other player and no death")
  local marks = C.MarksGlance()
  check(marks.TI == "Sore", "Marks: a fall just now: " .. tostring(marks.TI) .. ": " .. tostring(marks.TX))
  life().env.Falling.t = NOW - 3600
  C.SourcesChanged(); C.Refresh()
  check(C.MarksGlance().TI == "Fresh From a Duel", "Marks: a duel just now: " .. C.MarksGlance().TI)
  for _, d in ipairs(life().duels.log) do d.t = NOW - 3600 end
  C.SourcesChanged(); C.Refresh()
  check(C.MarksGlance().TI == "Smells of Fish", "Marks: an afternoon's fishing: " .. C.MarksGlance().TI .. ": " .. C.MarksGlance().TX)
  -- The fall's death is news of its own in Lately (from Auto TRP's own record); age it, so
  -- the record's other news shows.
  for _, d in ipairs(ns.char.deeds and ns.char.deeds.deaths or {}) do d.t = NOW - 30 * 86400 end
  for z in pairs(ns.char.seen.zones or {}) do ns.char.seen.zones[z] = NOW - 30 * 86400 end
  C.SourcesChanged(); C.Refresh()
  local lately = C.LatelyGlance()
  local LATELY = { ["A Fresh Catch"] = true, ["Back From Battle"] = true, ["A New Mount"] = true, ["Fresh Kit"] = true,
    Reading = true, ["At Work"] = true, ["A New Inn"] = true, Fishing = true, ["Duel Won"] = true, ["Duel Lost"] = true }
  check(LATELY[lately.TI], "Lately: from Auto TRP's own record: " .. tostring(lately.TI) .. ": " .. tostring(lately.TX))
  local function latelyAfter(fn) fn(); C.SourcesChanged(); C.Refresh(); return C.LatelyGlance() end
  check(latelyAfter(function() life().pvp.last.t = NOW + 1 end).TI == "Back From Battle", "Lately: back from a battle")
  check(latelyAfter(function() life().fish.new.t = NOW + 2 end).TX:find("Slitherskin Mackerel", 1, true), "Lately: a fresh catch")
  check(latelyAfter(function() life().mounts.seen["Brown Horse"].t = NOW + 3 end).TX:find("a Brown Horse", 1, true), "Lately: a new mount")
  check(latelyAfter(function() life().books["The Fall of Ameth'Aran"].t = NOW + 4 end).TI == "Reading", "Lately: a book")
  life().made.run.n = 6
  check(latelyAfter(function() life().made.run.last = NOW + 5 end).TX:find("cooking", 1, true), "Lately: a stretch at a trade")

  -- Bigger counts: the longer record, and habits in Personality.
  local richMoney = GetMoney
  GetMoney = function() return 250000 end
  life().fish.n = 150
  life().fish.zones = { ["Elwynn Forest"] = 50, Westfall = 40, Duskwood = 30, ["Loch Modan"] = 30 }
  life().made.byProf.Cooking = 120
  life().gather.herbs = 140
  life().duels.won, life().duels.lost = 14, 3
  life().money.most, life().money.quests, life().money.repairs = 3120000, 900000, 300000
  for i = 1, 6 do life().inns["Inn " .. i] = { t = NOW - 30 * 86400, last = NOW - 30 * 86400, n = 1 } end
  for _ = 1, 40 do event("CHAT_MSG_TEXT_EMOTE", "You bow before Hesk.") end
  C.SourcesChanged(); C.Refresh()
  hist = C.History()
  print("\nHistory with a longer record:\n" .. hist)
  check(hist:find("caught more than a hundred fish in four different lands", 1, true), "History: fish caught, told as a count")
  check(hist:find("cooked more than a hundred meals", 1, true) and hist:find("picked more than a hundred herbs", 1, true), "History: cooking and herbs")
  check(hist:find("won fourteen of seventeen duels", 1, true), "History: duels")
  check(hist:find("had as much as 312 gold to", 1, true), "History: the most gold held")
  check(hist:find("rested at seven different inns", 1, true), "History: inns")
  local bearing = C.Bearing()
  print("\nPersonality:\n" .. bearing)
  local fishHabit, bowHabit = false, false
  for _, l in ipairs(ns.Words.LIFE.HABIT.fish_many) do if bearing:find(l, 1, true) then fishHabit = true end end
  for _, l in ipairs(ns.Words.LIFE.EMOTE.bow) do if bearing:find(l, 1, true) then bowHabit = true end end
  check(fishHabit and bowHabit, "Personality: habits the counts back (fishing, bowing)")
  check(bearing:find("The Fall of Ameth'Aran", 1, true), "Personality: a book read, without RPG Dialogue")
  life().fish.n = 10
  C.SourcesChanged(); C.Refresh()
  local noHabit = true
  for _, l in ipairs(ns.Words.LIFE.HABIT.fish_many) do if C.Bearing():find(l, 1, true) then noHabit = false end end
  for _, l in ipairs(ns.Words.LIFE.HABIT.fish_some) do if C.Bearing():find(l, 1, true) then noHabit = false end end
  check(noHabit, "no fishing habit when the counts don't back it")
  for _, k in ipairs({ "fish", "made", "gathered", "duels", "battles", "gold", "inns", "hit" }) do
    check(ns.TRP.FIELDS["stat_" .. k] ~= nil and ns.db.fields["stat_" .. k] == true, "statistic " .. k .. " has its own switch, on by default")
  end
  -- Bounded: the least counted kinds are pushed out past the cap.
  local t = {}
  for i = 1, 70 do L.Bump(t, "k" .. i, i, 60) end
  check(ns.U.Count(t) == 60 and t.k70 and not t.k1, "lists stay bounded")

  GetMoney = richMoney
  RPGDialogueCharDB, SocialDiaryCharDB, ChronicleCharDB = keep[1], keep[2], keep[3]
  ns.char.deeds, ns.char.finds, ns.char.lastFight, ns.char.milestones = keep[4], keep[5], keep[6], keep[7]
  ns.char.life = nil
  state.zone, state.sub, state.resting = "Duskwood", "Raven Hill", false
  ns.World.slow = nil
  C.SourcesChanged(); C.Refresh()
end

-- Every option at once, from the slash command (the panel's buttons call the same).
do
  local before = {}
  for k, v in pairs(ns.db.fields) do before[k] = v end
  local quiet, badge = ns.db.quiet, ns.db.showBadge
  SlashCmdList.AUTOTRP("all off")
  local anyOn = false
  for k, v in pairs(ns.db.fields) do if v then anyOn = k end end
  check(not anyOn and ns.db.quiet == false and ns.db.showBadge == false and ns.db.enabled ~= false, "all off: every option off, the addon itself still on: " .. tostring(anyOn) .. tostring(ns.db.quiet) .. tostring(ns.db.showBadge) .. tostring(ns.db.enabled))
  SlashCmdList.AUTOTRP("all on")
  local anyOff = false
  for k, v in pairs(ns.db.fields) do if not v and k ~= "stat_met" and k ~= "stat_letters" then anyOff = true end end
  check(not anyOff and ns.db.quiet == true, "all on: every option on")
  for k, v in pairs(before) do ns.db.fields[k] = v end
  ns.db.quiet, ns.db.showBadge = quiet, badge
end

-- 0.21.0, more of Total RP 3 (Register.lua): name colour, profile music, the Faction, Guild,
-- Level and Talents entries, and the out-of-character line. Each is written, becomes the
-- player's when they edit it, comes off when switched off, and /atrp restore puts it back.
do
  local C, T = ns.Compose, ns.TRP
  local quietWas, bindWas = ns.db.quiet, GetBindLocation
  ns.db.quiet = true
  RAID_CLASS_COLORS = { PRIEST = { r = 1, g = 1, b = 1 }, ROGUE = { r = 1, g = 0.96, b = 0.41 } }
  local TALENTS = { { "Discipline", 5 }, { "Holy", 21 }, { "Shadow", 0 } }
  GetNumTalentTabs = function() return #TALENTS end
  GetTalentTabInfo = function(i) local t = TALENTS[i]; return t[1], "icon", t[2], "bg" end
  -- Total RP 3 looks music up by name in its own list (LibRPMedia) and keeps the file ID.
  local MUSIC_IDS = { dayforest = 53210, dayevilforest = 53220, stormwind04_zone = 53190 }
  TRP3_API.utils = TRP3_API.utils or {}
  TRP3_API.utils.music = { convertPathToID = function(n) assert(n, "Music path can't be nil."); return MUSIC_IDS[n] end }
  local ch, about, char = p.characteristics, p.about, p.character
  local function info(label)
    for i, e in ipairs(ch.MI) do if e.ID == 1 and e.NA == label then return e.VA, i end end
  end
  state.zone, state.sub, state.resting, state.grouped = "Duskwood", "Raven Hill", false, false
  C.SourcesChanged()
  ns.UI.Update(true)   -- takes down what "all on" above left in fields switched off again
  SlashCmdList.AUTOTRP("claim all")
  ns.UI.Update(true)

  -- Written.
  check(ch.CH == "ffffff", "name colour from the class colour: " .. tostring(ch.CH))
  check(about.MU == 53210, "profile music from home (Goldshire, so Elwynn Forest's): " .. tostring(about.MU))
  check(info("Faction") == "Alliance", "Faction entry: " .. tostring(info("Faction")))
  check(info("Guild") == "Lamplighter of the Silver Lanterns", "Guild entry, with rank: " .. tostring(info("Guild")))
  check(info("Level") == "22, Cleric of the Light", "Level entry, with the rank title: " .. tostring(info("Level")))
  check(info("Talents") == "Holy, 5/21/0", "Talents entry from the talent trees: " .. tostring(info("Talents")))
  local _, iDeaths = info("Deaths")
  local _, iF = info("Faction"); local _, iG = info("Guild"); local _, iL = info("Level"); local _, iT = info("Talents")
  check(iDeaths and iDeaths < iF and iF < iG and iG < iL and iL < iT, "and they follow the statistics, in order")
  check(char.CO == nil or char.CO == "", "the OOC line stays off by default: " .. tostring(char.CO))
  -- Without a fitting piece for home, the music of where you are; with none at all, as it was.
  GetBindLocation = function() return "Lakeshire" end
  C.SourcesChanged(); ns.UI.Update(true)
  check(about.MU == 53220, "no music for home: where you are (Duskwood): " .. tostring(about.MU))
  state.zone = "Deadwind Pass"
  C.SourcesChanged(); ns.UI.Update(true)
  check(about.MU == 53220, "no music anywhere: the music is left as it was")
  state.zone = "Duskwood"
  GetBindLocation = bindWas
  -- Wrath-style talent API (id, name, description, icon, points).
  GetTalentTabInfo = function(i) local t = TALENTS[i]; return i, t[1], "desc", "icon", t[2] end
  check(C.Stats().talents == "Holy, 5/21/0", "talents read on either talent API")
  GetTalentTabInfo = function(i) local t = TALENTS[i]; return t[1], "icon", t[2], "bg" end
  -- No talents spent, no guild: no entry.
  local guildWas = GetGuildInfo
  GetGuildInfo = function() return nil end
  TALENTS[2][2], TALENTS[1][2] = 0, 0
  C.SourcesChanged(); ns.World.slow = nil; ns.UI.Update(true)
  check(info("Guild") == nil and info("Talents") == nil, "no guild and no talents: no entries")
  GetGuildInfo, TALENTS[2][2], TALENTS[1][2] = guildWas, 21, 5
  C.SourcesChanged(); ns.UI.Update(true)

  -- The OOC line: what you're doing, from the game's own flags.
  ns.db.fields.ooc_doing = true
  ns.UI.Update(true)
  check(char.CO == "Levelling in Duskwood.", "OOC line: levelling: " .. tostring(char.CO))
  C_LFGList = { HasActiveEntryInfo = function() return true end }
  ns.UI.Update(true)
  check(char.CO == "Looking for a group in Duskwood.", "OOC line: listed in the group finder: " .. tostring(char.CO))
  state.grouped = true
  ns.UI.Update(true)
  check(char.CO == "Looking for more for a group in Duskwood.", "OOC line: a group listed for more: " .. tostring(char.CO))
  C_LFGList = nil
  ns.UI.Update(true)
  check(char.CO == "In a group in Duskwood.", "OOC line: in a group: " .. tostring(char.CO))
  state.grouped = false
  C.SourcesChanged(); C.Refresh()
  ns.db.fields.ooc = true
  check(C.OOCNote():find("^Levelling in Duskwood%. Parts of this profile"), "with the note too: " .. C.OOCNote())
  ns.db.pauseOOC, char.RP = true, 2
  NOW = NOW + 60
  ns.UI.Update(false)
  check(tostring(char.CO):find("^Levelling"), "the OOC line isn't paused while out of character: " .. tostring(char.CO))
  ns.db.pauseOOC, char.RP = false, 1
  ns.db.fields.ooc = false
  ns.UI.Update(true)

  -- Switched off: taken down. Back on: back.
  ns.db.fields.namecolour, ns.db.fields.music, ns.db.fields.stat_guild, ns.db.fields.ooc_doing = false, false, false, false
  ns.UI.Update(true)
  check(ch.CH == nil and T.Status("namecolour") == "off", "name colour switched off is taken down")
  check(about.MU == nil, "profile music switched off is taken down")
  check(info("Guild") == nil and info("Faction") ~= nil, "the Guild entry switched off is taken down, the rest stay")
  check(char.CO == nil, "the OOC line switched off is taken down")
  ns.db.fields.namecolour, ns.db.fields.music, ns.db.fields.stat_guild = true, true, true
  ns.UI.Update(true)
  check(ch.CH == "ffffff" and about.MU == 53210 and info("Guild") ~= nil, "and they come back when switched on")
  ns.db.fields.stat_faction = false
  ns.db.fields.stats = false
  ns.UI.Update(true)
  check(info("Faction") == nil and info("Level") == nil, "the statistics' master switch covers the new entries")
  ns.db.fields.stats, ns.db.fields.stat_faction = true, true
  ns.UI.Update(true)

  -- Edited by the player: theirs, left alone.
  ch.CH = "C0FFEE"
  about.MU = 99999
  local _, iTal = info("Talents")
  ch.MI[iTal].VA = "Holy, and proud of it"
  ns.db.fields.ooc_doing = true
  ns.UI.Update(true)
  char.CO = "Back in ten."
  ns.UI.Update(true)
  check(ch.CH == "C0FFEE" and T.Status("namecolour") == "yours", "a name colour the player chose is theirs")
  check(about.MU == 99999 and T.Status("music") == "yours", "music the player chose is theirs")
  check(info("Talents") == "Holy, and proud of it" and T.Status("stat_talents") == "yours", "an edited Talents entry is theirs")
  check(char.CO == "Back in ten." and T.Status("ooc") == "yours", "an OOC line the player wrote is theirs")
  ns.db.fields.namecolour, ns.db.fields.ooc_doing = false, false
  ns.UI.Update(true)
  check(ch.CH == "C0FFEE" and char.CO == "Back in ten.", "and switching it off doesn't take the player's words down")
  ns.db.fields.namecolour = true

  -- /atrp restore puts back what was there before Auto TRP first wrote (here: nothing).
  SlashCmdList.AUTOTRP("claim all")
  ns.db.fields.ooc_doing = true
  ns.UI.Update(true)
  check(ch.CH == "ffffff" and about.MU == 53210 and char.CO == "Levelling in Duskwood.", "claimed back, all written again")
  SlashCmdList.AUTOTRP("restore")
  check(ch.CH == nil and about.MU == nil and info("Faction") == nil and info("Guild") == nil and info("Level") == nil
    and info("Talents") == nil and char.CO == nil, "restore puts the new fields back as they were")
  check(T.Status("namecolour") == "yours" and T.Status("music") == "yours" and T.Status("stat_talents") == "yours",
    "and hands them to the player")
  ns.db.fields.ooc_doing = false
  SlashCmdList.AUTOTRP("claim all")
  ns.UI.Update(true)

  -- Every new switch is one of ns.db.fields, so All on / All off pick them up.
  for _, k in ipairs({ "namecolour", "music", "ooc_doing", "stat_faction", "stat_guild", "stat_level", "stat_talents" }) do
    check(ns.db.fields[k] ~= nil and (T.FIELDS[k] or k == "ooc_doing"), "a switch for " .. k)
  end
  ns.db.quiet = quietWas
end


-- Secret values (Midnight-era clients): testing one taints the add-on, so they must read as unknown.
do
  local SECRET = newproxy()
  issecretvalue = function(v) return v == SECRET end
  local oldAFK = UnitIsAFK
  UnitIsAFK = function() return SECRET end
  local ok, snap = pcall(ns.World.Snapshot)
  check(ok and snap.away == false, "a secret AFK flag reads as unknown, not as away")
  check(ns.U.Call(function() return SECRET, 7 end) == nil and select(2, ns.U.Call(function() return SECRET, 7 end)) == 7,
    "U.Call scrubs secret returns and keeps the rest")
  local got = "untouched"
  ns.On("AUTOTRP_TEST_SECRET", function(_, a, b) got = { a, b } end)
  event("AUTOTRP_TEST_SECRET", SECRET, "plain")
  check(type(got) == "table" and got[1] == nil and got[2] == "plain", "event payloads scrub secret values")
  UnitIsAFK, issecretvalue = oldAFK, nil
end

-- Ambitions and what drives them (Sources/Goals.lua): the quest log and the game's own
-- state, with no RPG Dialogue, Social Diary or Chronicle at all; then the extras.
do
  local C, G, W = ns.Compose, ns.Goals, ns.Words
  local keep = { RPGDialogueCharDB, SocialDiaryCharDB, ChronicleCharDB, ns.char.deeds, ns.char.questsTaken }
  local mocks = { UnitLevel = UnitLevel, GetMoney = GetMoney, UnitXP = UnitXP, UnitClass = UnitClass, UnitRace = UnitRace,
    GetNumSkillLines = GetNumSkillLines, GetSkillLineInfo = GetSkillLineInfo, GetNumFactions = GetNumFactions,
    GetFactionInfo = GetFactionInfo, IsPlayerSpell = IsPlayerSpell, GetItemCount = GetItemCount, zone = state.zone }
  RPGDialogueCharDB, SocialDiaryCharDB, ChronicleCharDB = nil, nil, nil
  ns.char.deeds, ns.char.questsTaken = nil, nil
  local LOG, reads = {}, 0
  -- Entries: { header = true, title } or { title, level, tag, complete, obj = { { text, done } }, id }.
  GetNumQuestLogEntries = function() local n = 0; for _, q in ipairs(LOG) do if not q.header then n = n + 1 end end return #LOG, n end
  GetQuestLogTitle = function(i)
    reads = reads + 1
    local q = LOG[i]
    if not q then return nil end
    if q.header then return q.title, 0, nil, true end
    return q.title, q.level, q.tag, false, false, q.complete, 0, q.id
  end
  GetNumQuestLeaderBoards = function(i) return #(LOG[i] and LOG[i].obj or {}) end
  GetQuestLogLeaderBoard = function(j, i) local o = LOG[i].obj[j]; return o[1], "monster", o[2] end
  IsQuestWatched = function() return false end
  local level, gold, xp = 22, 2, 100
  UnitLevel = function() return level end
  GetMoney = function() return gold * 10000 end
  UnitXP = function() return xp end
  local SKILLS = {}
  GetNumSkillLines = function() return #SKILLS end
  GetSkillLineInfo = function(i) local s = SKILLS[i]; return s[1], false, false, s[2], 0, 0, s[3] end
  local REPS = {}
  GetNumFactions = function() return #REPS end
  GetFactionInfo = function(i) local r = REPS[i]; return r[1], "", r[2], r[3], r[4], r[5], false, false, false, false, true end
  local function fresh() G.Invalidate(); ns.World.slow = nil; C.SourcesChanged(); C.Refresh() end
  local function amb() fresh(); return C.AmbitionGlance() end
  local function show(g) return g.TI .. " / " .. g.IC .. " / " .. g.TX end
  state.zone = "Duskwood"

  -- Nothing in the log, no other addon: the next level or rank still gives a glance and Drives.
  local g = amb()
  check(g.TI == "Ambition" and g.TX:find("rank of Priest") or g.TX:find("Priest"), "no addons, empty log: the next rank: " .. show(g))
  check(C.Drives() and C.Drives():find("^Aldric "), "no addons: Drives still has a line: " .. tostring(C.Drives()))
  check(C.History():find(C.Drives(), 1, true), "and History ends with what drives them")
  xp = 900
  g = amb()
  check(g.TI == "Nearly There" and g.TX:find("twenty%-three") or g.TX:find("next level"), "close to the next level: " .. show(g))
  GetXPExhaustion = function() return 4000 end
  g = amb()
  check(g.TI == "Well Rested", "rested and close to a level: " .. show(g))
  GetXPExhaustion, xp = nil, 100

  -- A chain part-done, by its last quest's title and by an earlier step.
  LOG = { { header = true, title = "Westfall" }, { title = "The Defias Brotherhood", level = 18, id = 1 } }
  g = amb()
  check(g.TI == "Seeing It Through" and g.IC == "INV_Misc_Mask_01" and g.TX:find("the Defias business"), "a chain in progress: " .. show(g))
  LOG = { { header = true, title = "Tirisfal Glades" }, { title = "Down the Scarlet Path", level = 30, id = 2 } }
  level = 31
  g = amb()
  check(g.TI == "Seeing It Through" and g.TX:find("Scarlet Monastery business"), "an earlier step of a chain: " .. show(g))
  level = 22
  -- A chain already seen through isn't an ambition.
  LOG = { { header = true, title = "Westfall" }, { title = "The Defias Brotherhood", level = 18, id = 1 } }
  ns.Sources.Deeds.Quest("The Defias Brotherhood", 1, "Westfall", NOW - 100)
  g = amb()
  check(g.TI ~= "Seeing It Through", "a chain already finished is no ambition: " .. show(g))
  ns.char.deeds = nil
  -- Another class's chain isn't theirs.
  LOG = { { header = true, title = "Desolace" }, { title = "Verigan's Fist", level = 20, id = 3 } }
  check(amb().TI ~= "Seeing It Through", "a paladin's chain isn't a priest's ambition")

  -- Dungeon, raid and elite work.
  LOG = { { header = true, title = "The Deadmines" }, { title = "Collecting Memories", level = 18, id = 4 } }
  g = amb()
  check(g.TI == "A Job Waiting" and g.TX:find("Deadmines") or g.TX:find("party"), "a job in a dungeon: " .. show(g))
  LOG = { { header = true, title = "Molten Core" }, { title = "Thunderaan the Windseeker", level = 60, id = 5 } }
  level = 60
  g = amb()
  check(g.TI == "A Host Wanted", "a raid job: " .. show(g))
  level = 22
  LOG = { { header = true, title = "Stranglethorn Vale" }, { title = "Raptor Mastery", level = 24, tag = "Elite", id = 6 } }
  g = amb()
  check(g.TI == "Hard Work" and (g.TX:find("Raptor Mastery") or g.TX:find("Stranglethorn")), "an elite job: " .. show(g))

  -- Done and waiting to be handed in; nearly done; beyond them.
  LOG = { { header = true, title = "Elwynn Forest" }, { title = "The Collector", level = 10, complete = 1, id = 7 } }
  g = amb()
  check(g.TI == "Back to Collect" and g.TX:find('"The Collector"'), "a job ready to hand in: " .. show(g))
  LOG[3] = { title = "Wolves Across the Border", level = 6, complete = 1, id = 8 }
  g = amb()
  check(g.TI == "Back to Collect" and g.TX:find("two"), "two jobs to hand in: " .. show(g))
  LOG = { { header = true, title = "Westfall" }, { title = "Patrolling Westfall", level = 14, id = 9,
    obj = { { "Fleshripper slain: 13/15", false }, { "Harvest Watcher slain: 10/10", true } } } }
  g = amb()
  check(g.TI == "Nearly Done" and g.TX:find("Patrolling Westfall"), "nearly done: " .. show(g))
  LOG = { { header = true, title = "Badlands" }, { title = "Barbecued Buzzard Wings", level = 40, id = 10 } }
  g = amb()
  check(g.TI == "Work for Later", "a job far above their level: " .. show(g))

  -- The job on hand: the latest taken, from QUEST_ACCEPTED.
  LOG = { { header = true, title = "Duskwood" }, { title = "The Night Watch", level = 21, id = 11 },
    { title = "Raven Hill", level = 22, id = 12 } }
  fresh()
  event("QUEST_ACCEPTED", 3, 12)
  g = amb()
  check(g.TI == "On the Job" and g.TX:find("Raven Hill"), "the job just taken on: " .. show(g))
  -- A full log.
  LOG = { { header = true, title = "Redridge Mountains" } }
  for i = 1, 15 do LOG[#LOG + 1] = { title = "Errand " .. i, level = 20, id = 100 + i } end
  ns.char.questsTaken = nil
  g = amb()
  check(g.TI == "Busy Hands" and g.TX:find("fifteen"), "a full log: " .. show(g))
  LOG = {}

  -- Lazy and never in combat: read once per change, and not at all during a fight.
  fresh(); reads = 0
  G.Log(); G.Log()
  check(reads == 0, "the log isn't read again without a change")
  event("QUEST_LOG_UPDATE")
  state.combat = true
  G.Log()
  check(reads == 0, "and not during combat")
  state.combat = false
  LOG = { { header = true, title = "Duskwood" }, { title = "The Night Watch", level = 21, id = 11 } }
  G.Log()
  check(reads > 0 and G.Log().n == 1, "read after the fight")
  LOG = {}

  -- A mount: only when level and gold back it, and not for the classes that are given one.
  level, gold = 40, 60
  g = amb()
  check(g.TI == "Saving Up" and g.TX:find("horse"), "saving for a horse at forty: " .. show(g))
  gold = 120
  g = amb()
  check(g.TI == "Coin for a Mount" and g.TX:find("horse"), "the coin for a horse: " .. show(g))
  gold = 5
  g = amb()
  check(g.TI == "On Foot", "the level but not the coin: " .. show(g))
  level, gold = 38, 60
  check(amb().TI ~= "Saving Up", "no horse before forty")
  level = 40
  SKILLS = { { "Riding", 75, 75 } }
  check(amb().TI ~= "Saving Up", "no horse for someone who rides already")
  level, gold = 60, 300
  g = amb()
  check(g.TI == "Saving Up" and g.TX:find("swift horse"), "saving for a swift mount at sixty: " .. show(g))
  UnitRace = function() return "Tauren", "Tauren" end
  UnitFactionGroup = function() return "Horde" end
  check(amb().TX:find("great kodo"), "a tauren saves for a great kodo: " .. amb().TX)
  UnitRace, UnitFactionGroup = mocks.UnitRace, function() return "Alliance" end
  level, gold, SKILLS = 40, 60, {}
  UnitClass = function() return "Paladin", "PALADIN" end
  check(amb().TI ~= "Saving Up", "a paladin isn't saving for a horse")
  UnitClass = mocks.UnitClass
  level, gold = 22, 2

  -- A craft at the edge of its rank.
  SKILLS = { { "Tailoring", 150, 150 } }
  g = amb()
  check(g.TI == "Learning the Trade" and g.IC == "Trade_Tailoring" and g.TX:find("tailoring") or g.TX:find("lessons"), "a craft at its cap: " .. show(g))
  level = 15
  g = amb()
  check(g.TX:find("twenty") or g.TX:find("level allows"), "the next craft rank waits on a level: " .. show(g))
  level = 22
  SKILLS = { { "Tailoring", 144, 150 } }
  check(amb().TI == "Learning the Trade", "a craft close to its cap")
  SKILLS = { { "Tailoring", 160, 225 } }
  check(amb().TI ~= "Learning the Trade", "a craft mid-rank is no ambition")
  SKILLS = {}

  -- A reputation close to the next standing.
  REPS = { { "Argent Dawn", 5, 3000, 9000, 8600 }, { "Stormwind", 6, 9000, 21000, 12000 } }
  g = amb()
  check(g.TI == "Earning Trust" and g.TX:find("honoured by the Argent Dawn"), "close to the next standing: " .. show(g))
  REPS = { { "Argent Dawn", 5, 3000, 9000, 5000 } }
  check(amb().TI ~= "Earning Trust", "halfway along isn't close")
  REPS = {}

  -- Class trials at their level.
  UnitClass = function() return "Warlock", "WARLOCK" end
  IsPlayerSpell = function(id) return id ~= 697 end
  level = 12
  g = amb()
  check(g.TI == "A Trial Ahead" and g.IC == "Spell_Shadow_SummonVoidWalker" and g.TX:find("voidwalker"), "a warlock's voidwalker: " .. show(g))
  IsPlayerSpell = function() return true end
  check(amb().TI ~= "A Trial Ahead", "no trial once it's learned")
  UnitClass = function() return "Shaman", "SHAMAN" end
  GetItemCount = function(id) return id == 5175 and 1 or 0 end
  g = amb()
  check(g.TI == "A Trial Ahead" and g.TX:find("fire"), "a shaman's fire totem: " .. show(g))
  UnitClass = function() return "Rogue", "ROGUE" end
  level, SKILLS = 20, { { "Lockpicking", 40, 100 } }
  g = amb()
  check(g.TI == "A Trial Ahead" and g.TX:find("poison"), "a rogue's poisons: " .. show(g))
  SKILLS = { { "Lockpicking", 40, 100 }, { "Poisons", 1, 100 } }
  check(amb().TI ~= "A Trial Ahead", "a rogue who knows poisons")
  UnitClass, IsPlayerSpell, GetItemCount, SKILLS = mocks.UnitClass, mocks.IsPlayerSpell, mocks.GetItemCount, {}

  -- The next rank, a level away.
  level, xp = 29, 900
  g = amb()
  check(g.TI == "Rising" and g.TX:find("Priest"), "a level from the next rank: " .. show(g))
  level, xp = 22, 100

  -- Ranking: a chain over dungeon work over a job nearly done over a horse; Drives tells the
  -- top three of different kinds.
  level, gold = 40, 60
  LOG = { { header = true, title = "The Deadmines" }, { title = "Collecting Memories", level = 18, id = 4 },
    { header = true, title = "Westfall" }, { title = "The Defias Brotherhood", level = 18, id = 1 },
    { title = "Patrolling Westfall", level = 14, id = 9, obj = { { "Fleshripper slain: 14/15", false } } } }
  fresh()
  local list = C.Ambitions()
  check(list[1].kind == "chain" and list[2].kind == "dungeon" and list[3].kind == "nearly" and list[4].kind == "mount",
    "ranked: chain, dungeon, nearly done, mount: " .. list[1].kind .. ", " .. list[2].kind .. ", " .. list[3].kind .. ", " .. list[4].kind)
  local drives = C.Drives()
  check(drives:find("^Aldric ") and drives:find("Defias business") and drives:find("Deadmines") and not drives:find("horse"),
    "Drives: the top three: " .. drives)
  check(select(2, drives:gsub("%. ", "")) == 2, "Drives is three sentences")

  -- The extras: a Chronicle goal outranks the everyday but not a chain; an RPG Dialogue story.
  ChronicleCharDB = keep[3]
  g = amb()
  check(g.TI == "Seeing It Through", "a chain outranks a Chronicle goal: " .. show(g))
  LOG = { { header = true, title = "Westfall" }, { title = "Patrolling Westfall", level = 14, id = 9, obj = { { "Fleshripper slain: 14/15", false } } } }
  g = amb()
  check(g.TX == "Find the Defias hideout.", "a Chronicle goal outranks a job nearly done: " .. show(g))
  check(C.Drives():find("find the Defias hideout"), "and is in Drives: " .. C.Drives())
  ChronicleCharDB = nil
  RPGDialogueCharDB = keep[1]
  local threads = RPGDialogueCharDB.threads
  RPGDialogueCharDB.threads = { elwynn_gold = { state = "unfolding", beats = { a = 1 }, t = NOW - 60 } }
  LOG, level, gold = {}, 22, 2
  g = amb()
  check(g.TI == "Unfinished Business" and g.TX:find("gold of Elwynn"), "an unfinished story, without a bigger goal: " .. show(g))
  RPGDialogueCharDB.threads = threads
  RPGDialogueCharDB = nil

  -- The words: every kind has a title, an icon and four ways to say it, in the glance and
  -- in Drives; tags fill with she/her and they/them; chains and their steps line up.
  local thin, bad = {}, {}
  for kind, lines in pairs(W.GOALS) do
    if #lines < 4 then thin[#thin + 1] = "glance " .. kind end
    if not W.GOAL_GLANCE[kind] then thin[#thin + 1] = "title " .. kind end
    if not W.DRIVES[kind] or #W.DRIVES[kind] < 4 then thin[#thin + 1] = "drives " .. kind end
  end
  for kind in pairs(G.SCORE) do if not W.GOALS[kind] then thin[#thin + 1] = "no lines for " .. kind end end
  for title in pairs(W.EARNED_QUEST) do if not W.CHAIN_GOAL[title] then thin[#thin + 1] = "chain " .. title end end
  for step, last in pairs(W.CHAIN_STEPS) do if not W.EARNED_QUEST[last] then thin[#thin + 1] = "step " .. step end end
  check(#thin == 0, "every ambition has a title and four lines each way: " .. table.concat(thin, ", "))
  local fill = { q = '"x"', chain = "x", place = "x", zone = "x", mount = "a horse", gold = "x", cost = "x", prof = "x",
    rank = "x", next = "x", nextlevel = "x", faction = "x", standing = "x", what = "the {their} x", n = "x", left = "x",
    level = "x", goal = "x", t = "x" }
  local oldPron = ns.TRP.CustomPronouns
  for _, pron in ipairs({ "she/her", "they/them" }) do
    ns.TRP.CustomPronouns = function() return pron end
    for _, tbl in ipairs({ W.GOALS, W.DRIVES }) do
      for kind, lines in pairs(tbl) do
        for _, l in ipairs(lines) do
          local out = C.GoalLine({ l }, fill, kind)
          if not out or out:find("[{}]") or not out:find("^%u") then bad[#bad + 1] = kind .. ": " .. tostring(out or l) end
        end
      end
    end
  end
  ns.TRP.CustomPronouns = oldPron
  check(#bad == 0, "every ambition line fills its tags: " .. table.concat(bad, " | "))

  RPGDialogueCharDB, SocialDiaryCharDB, ChronicleCharDB, ns.char.deeds, ns.char.questsTaken = keep[1], keep[2], keep[3], keep[4], keep[5]
  UnitLevel, GetMoney, UnitXP, UnitClass, UnitRace = mocks.UnitLevel, mocks.GetMoney, mocks.UnitXP, mocks.UnitClass, mocks.UnitRace
  GetNumSkillLines, GetSkillLineInfo, GetNumFactions, GetFactionInfo = mocks.GetNumSkillLines, mocks.GetSkillLineInfo, mocks.GetNumFactions, mocks.GetFactionInfo
  GetNumQuestLogEntries, GetQuestLogTitle, GetNumQuestLeaderBoards, GetQuestLogLeaderBoard, IsQuestWatched = nil, nil, nil, nil, nil
  state.zone = mocks.zone
  fresh()
end

-- Race x class temperament: every pair the lore has gets a line of its own in Personality,
-- with no other addon and with a thin RPG Dialogue record; and no paragraph opens two
-- sentences in a row on a bare "Has".
do
  local W, U, C = ns.Words, ns.U, ns.Compose
  local RACES = { Human = "Alliance", Dwarf = "Alliance", NightElf = "Alliance", Gnome = "Alliance",
    Orc = "Horde", Scourge = "Horde", Tauren = "Horde", Troll = "Horde", Goblin = "Horde" }
  local CLASSES = { "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID", "DEATHKNIGHT" }
  local LORE = {
    Human = { "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST", "MAGE", "WARLOCK", "DEATHKNIGHT" },
    Dwarf = { "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST", "SHAMAN", "MAGE", "DEATHKNIGHT" },
    Gnome = { "WARRIOR", "HUNTER", "ROGUE", "PRIEST", "MAGE", "WARLOCK", "DEATHKNIGHT" },
    NightElf = { "WARRIOR", "HUNTER", "ROGUE", "PRIEST", "MAGE", "DRUID", "DEATHKNIGHT" },
    Orc = { "WARRIOR", "HUNTER", "ROGUE", "SHAMAN", "MAGE", "WARLOCK", "DEATHKNIGHT" },
    Troll = { "WARRIOR", "HUNTER", "ROGUE", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID", "DEATHKNIGHT" },
    Tauren = { "WARRIOR", "PALADIN", "HUNTER", "PRIEST", "SHAMAN", "DRUID", "DEATHKNIGHT" },
    Scourge = { "WARRIOR", "HUNTER", "ROGUE", "PRIEST", "MAGE", "WARLOCK", "DEATHKNIGHT" },
    Goblin = { "WARRIOR", "HUNTER", "ROGUE", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DEATHKNIGHT" },
  }
  local missing, thin = {}, {}
  for race, list in pairs(LORE) do
    for _, class in ipairs(list) do
      local pool = W.RACE_CLASS_TEMPER[race] and W.RACE_CLASS_TEMPER[race][class]
      if not pool then missing[#missing + 1] = race .. "/" .. class elseif #pool < 2 then thin[#thin + 1] = race .. "/" .. class end
    end
  end
  check(#missing == 0 and #thin == 0, "every lore pair has race x class lines, two at least: "
    .. table.concat(missing, ", ") .. " " .. table.concat(thin, ", "))
  for k, pool in pairs(W.CLASS_TEMPER) do if #pool < 6 then thin[#thin + 1] = "class " .. k end end
  for k, pool in pairs(W.RACE_TEMPER) do if #pool < 5 then thin[#thin + 1] = "race " .. k end end
  for k, pool in pairs(W.CLASS_MOTTO) do if #pool < 6 then thin[#thin + 1] = "class motto " .. k end end
  for k, pool in pairs(W.RACE_MOTTO) do if #pool < 6 then thin[#thin + 1] = "race motto " .. k end end
  check(#thin == 0, "six or more class tempers and mottos, five or more race tempers: " .. table.concat(thin, ", "))

  local keep = { RPGDialogueCharDB, SocialDiaryCharDB, ChronicleCharDB, ns.char.deeds, ns.char.names, ns.char.milestones, ns.char.finds }
  local function has(text, pool)
    for _, l in ipairs(pool) do if text:find(U.Pron(l), 1, true) then return true end end
    return false
  end
  local function hasRun(text)
    for para in (text .. "\n\n"):gmatch("(.-)\n\n") do
      local prev
      for s in (para .. " "):gmatch("(.-[%.!%?]\"?) ") do
        local w = s:match("^%s*(%a+)")
        if w == "Has" and prev == "Has" then return s end
        prev = w
      end
    end
  end
  local noPair, runs = {}, {}
  for _, bare in ipairs({ true, false }) do
    if bare then
      RPGDialogueCharDB, SocialDiaryCharDB, ChronicleCharDB = nil, nil, nil
      ns.char.deeds, ns.char.names, ns.char.milestones, ns.char.finds = nil, nil, nil, nil
    else
      -- A thin RPG Dialogue record: a temperament and nothing else to say.
      RPGDialogueCharDB = { schema = 7, conversations = 2, align = { light = 40 }, traits = { kind = 3 } }
    end
    for race, faction in pairs(RACES) do
      for _, class in ipairs(CLASSES) do
        UnitRace = function() return race, race end
        UnitClass = function() return class, class end
        UnitFactionGroup = function() return faction end
        ns.World.slow = nil
        C.SourcesChanged(); C.Refresh()
        local b = C.Bearing() or ""
        local pool = W.RACE_CLASS_TEMPER[race] and W.RACE_CLASS_TEMPER[race][class]
        if pool and not has(b, pool) then noPair[#noPair + 1] = (bare and "bare " or "thin ") .. race .. "/" .. class end
        local run = hasRun(b) or hasRun(C.History() or "")
        if run then runs[#runs + 1] = race .. "/" .. class .. ": " .. run end
      end
    end
  end
  check(#noPair == 0, "a race x class line in Personality for every pair that has one: " .. table.concat(noPair, ", "))
  check(#runs == 0, "no two sentences in a row open on a bare Has: " .. table.concat(runs, " | "))
  RPGDialogueCharDB, SocialDiaryCharDB, ChronicleCharDB = keep[1], keep[2], keep[3]
  ns.char.deeds, ns.char.names, ns.char.milestones, ns.char.finds = keep[4], keep[5], keep[6], keep[7]
  UnitRace = function() return "Human", "Human" end
  UnitClass = function() return "Priest", "PRIEST" end
  UnitFactionGroup = function() return "Alliance" end
  ns.World.slow = nil
  C.SourcesChanged(); C.Refresh()
end

-- Every line reads cleanly whoever the character is: no tag left unfilled with she/her or
-- they/them pronouns and full gear, and every mood has lines enough to vary.
do
  local W, U = ns.Words, ns.U
  local oldPron = ns.TRP.CustomPronouns
  local world = { money = 100, pet = "Fang", gear = { offType = "Shields",
    names = { [1] = "Cap", [3] = "Mantle", [5] = "Vest", [15] = "Cape", [19] = "Tabard", [16] = "Mace", [17] = "Buckler", [18] = "Bow" } } }
  local fillers = { t = "x", who = "x", where = "", place = "x", q = "x", item = "x", zone = "x", how = "", n = "two",
    party = "x", pet = "x", mood = "", rank = "x", list = "x", name = "x", inn = "x", dest = "x", what = "x", beast = "x",
    mount = "x", around = "x", kind = "x", nick = "x", motto = "x", deed = "x", spell = "x", noun = "x", guild = "x", rel = "x",
    span = "x", akind = "x", faction = "x", races = "x", times = "x" }
  local bad, seen = {}, {}
  local function scan(v, path)
    if type(v) == "string" then
      if seen[v] then return end
      seen[v] = true
      local line = U.Backed(v, world) or v
      line = line:gsub("{(%a+)}", function(k) return fillers[k] end)
      line = U.Pron(line)
      if line:find("{") then bad[#bad + 1] = path .. ": " .. line end
    elseif type(v) == "table" then
      for k, x in pairs(v) do scan(x, path .. "." .. tostring(k)) end
    end
  end
  for _, pron in ipairs({ "she/her", "they/them", "he/him" }) do
    ns.TRP.CustomPronouns = function() return pron end
    seen = {}
    for _, key in ipairs({ "MOODS", "CALM", "RACE_TELLS", "CLASS_TELLS", "FESTIVALS", "SAY", "TRAVEL", "ACTIVITY", "PET",
      "AMBITIONS", "RACE_LOOK", "CLASS_LOOK", "PHYSIQUE", "WEEK_TONE", "WEALTH", "DURABILITY", "CLASS_TEMPER", "RACE_TEMPER",
      "RACE_CLASS_TEMPER", "CLASS_MOTTO", "RACE_MOTTO", "COMPANY", "LIFE" }) do
      scan(W[key], key)
    end
  end
  ns.TRP.CustomPronouns = oldPron
  check(#bad == 0, "every line fills its tags: " .. table.concat(bad, " | "))
  local thin = {}
  for k, m in pairs(W.MOODS) do
    if #m.adj < 3 or #m.tells < 3 then thin[#thin + 1] = k end
  end
  for k, m in pairs(W.CALM) do
    if #m.adj < 3 or #m.tells < 3 then thin[#thin + 1] = "calm:" .. k end
  end
  check(#thin == 0, "every mood has at least three ways to say it: " .. table.concat(thin, ", "))
  ns.TRP.CustomPronouns = function() return "she/her" end
  check(U.Pron("{they} walk{s}, {they} watch{es}, {they} carr{ies}") == "she walks, she watches, she carries", "verb endings follow she")
  ns.TRP.CustomPronouns = function() return "they/them" end
  check(U.Pron("{they} walk{s}, {they} watch{es}, {they} carr{ies}") == "they walk, they watch, they carry", "verb endings follow they")
  ns.TRP.CustomPronouns = oldPron
end


-- 0.21.0 mood model: the game's own signals, with RPG Dialogue, Social Diary and Chronicle
-- all absent. Each signal pushes its feeling, with a reason, and never names a stranger.
do
  local M, W = ns.Mood, ns.Words
  local keep = { RPGDialogueCharDB, SocialDiaryCharDB, ChronicleCharDB }
  RPGDialogueCharDB, SocialDiaryCharDB, ChronicleCharDB = nil, nil, nil
  ns.Compose.SourcesChanged(); ns.Compose.Refresh()
  check(ns.cache.rpgd == nil and ns.cache.sd == nil and ns.cache.chronicle == nil, "mood signals: no other addon loaded")
  local st = ns.char.mood
  M.SetManual(nil)
  local function fresh() for k in pairs(st.emo) do st.emo[k] = nil end for k in pairs(st.why) do st.why[k] = nil end end
  local function got(mood, why, min)
    return (st.emo[mood] or 0) >= (min or 10) and (why == nil or st.why[mood] == why)
  end
  local function show(mood) return mood .. "=" .. tostring(st.emo[mood]) .. " (" .. tostring(st.why[mood]) .. ")" end
  local log
  CombatLogGetCurrentEventInfo = function() return unpack(log, 1, 21) end
  local function cleu(t) log = t; event("COMBAT_LOG_EVENT_UNFILTERED") end
  local ME = "Player-1-0001"

  -- Temperament without RPG Dialogue: race and class still bend, and Auto TRP's own traits.
  check(M.Bias("grateful") >= 1.19, "a priest takes kindness to heart, with no RPG Dialogue: " .. M.Bias("grateful"))
  ns.cache.self = { kind = 5 }
  check(M.Bias("grateful") > 1.5 and M.TopTrait() == "kind", "and Auto TRP's own traits bend it too")
  fresh()
  st.road, st.session, st.afk, st.awayPlayed, st.quests, st.fights, st.lastSocial = 0, 0, 0, 0, {}, {}, NOW
  local calmWorld = { level = 22, race = "Human", class = "PRIEST", auras = {}, resting = true, indoors = true }
  local cw = M.Current(calmWorld)
  check(cw.key == "calm:kind", "nothing stands out (" .. cw.key .. " " .. tostring(cw.reasons and cw.reasons[1]) .. "): calm, tinted by Auto TRP's own traits")
  ns.cache.self = nil

  -- Emotes aimed at you: a stranger isn't named, and is throttled.
  fresh()
  event("CHAT_MSG_TEXT_EMOTE", "Borin waves at you.", "Borin")
  check(got("cheerful", "someone waved at {them}"), "a wave from a stranger cheers them: " .. show("cheerful"))
  local c1 = st.emo.cheerful or 0
  event("CHAT_MSG_TEXT_EMOTE", "Borin waves at you.", "Borin")
  check((st.emo.cheerful or 0) == c1, "the same person waving again isn't news")
  event("CHAT_MSG_TEXT_EMOTE", "Grukk spits on you.", "Grukk")
  check(got("bitter", "someone spat at {them}"), "being spat on: bitter")
  event("CHAT_MSG_TEXT_EMOTE", "Sela waves.", "Sela")
  check(st.why.cheerful == "someone waved at {them}" and not tostring(st.why.cheerful):find("Sela"), "an emote not aimed at you is ignored")
  local named = false
  for _, w in pairs(st.why) do if w:find("Borin") or w:find("Grukk") then named = true end end
  check(not named, "no stranger's name is kept in the reasons")

  -- The combat log: heals and blessings from others.
  fresh()
  cleu({ 0, "SPELL_HEAL", false, "Player-9-0009", "Stranger", 0x511, 0, ME, "Aldric", 0, 0, 2050, "Lesser Heal", 2, 300, 0, 0, false })
  check(next(M.pending.healers) ~= nil and (st.emo.grateful or 0) == 0, "a heal is only noted in the fight")
  M.Flush()
  check(got("grateful", "someone tended {their} wounds", 15), "healed by someone: grateful " .. show("grateful"))
  local g1 = st.emo.grateful
  cleu({ 0, "SPELL_HEAL", false, "Player-9-0009", "Stranger", 0x511, 0, ME, "Aldric", 0, 0, 2050, "Lesser Heal", 2, 300, 0, 0, false })
  M.Flush()
  check(st.emo.grateful == g1, "the same healer again isn't a new kindness")
  cleu({ 0, "SPELL_HEAL", false, "Player-8-0008", "Other", 0x511, 0, ME, "Aldric", 0, 0, 2050, "Lesser Heal", 2, 300, 300, 0, false })
  M.Flush()
  check(st.emo.grateful == g1, "a heal that did nothing (all overhealing) doesn't count")
  fresh()
  cleu({ 0, "SPELL_AURA_APPLIED", false, "Player-7-0007", "Other", 0x511, 0, ME, "Aldric", 0, 0, 1243, "Power Word: Fortitude", 2, "BUFF" })
  M.Flush()
  check(got("grateful", "a blessing from a stranger"), "a blessing from someone: " .. show("grateful"))
  -- Not about you: out at once.
  cleu({ 0, "SPELL_HEAL", false, "Player-7-0007", "Other", 0x511, 0, "Player-6-0006", "Someone", 0, 0, 2050, "Lesser Heal", 2, 300, 0, 0, false })
  check(next(M.pending.healers) == nil, "the combat log ignores what isn't about you")

  -- Crowd control on you
  fresh()
  cleu({ 0, "SPELL_AURA_APPLIED", false, "Creature-0-1", "Mage", 0xa48, 0, ME, "Aldric", 0, 0, 118, "Polymorph", 64, "DEBUFF" })
  M.Flush()
  check(got("humbled", "turned into an animal", 20), "polymorphed: humbled " .. show("humbled"))
  fresh()
  cleu({ 0, "SPELL_AURA_APPLIED", false, "Creature-0-1", "Priest", 0xa48, 0, ME, "Aldric", 0, 0, 8122, "Psychic Scream", 32, "DEBUFF" })
  M.Flush()
  check(got("shaken", "sent running in terror"), "feared: shaken " .. show("shaken"))

  -- A crit streak
  fresh()
  for _ = 1, 3 do cleu({ 0, "SWING_DAMAGE", false, ME, "Aldric", 0x511, 0, "Creature-0-2", "Kobold", 0, 0, 50, 0, 1, 0, 0, 0, true }) end
  cleu({ 0, "SPELL_DAMAGE", false, ME, "Aldric", 0x511, 0, "Creature-0-2", "Kobold", 0, 0, 585, "Smite", 2, 40, 0, 2, 0, 0, 0, false })
  M.Flush()
  check(got("smug", "a run of telling blows", 20), "three crits in a row: smug " .. show("smug"))

  -- A long fall, deep water
  fresh()
  cleu({ 0, "ENVIRONMENTAL_DAMAGE", false, nil, nil, 0, 0, ME, "Aldric", 0, 0, "Falling", 60 })
  M.Flush()
  check(got("rattled", "a long fall", 20), "a long fall survived: rattled " .. show("rattled"))
  fresh()
  cleu({ 0, "ENVIRONMENTAL_DAMAGE", false, nil, nil, 0, 0, ME, "Aldric", 0, 0, "Drowning", 10 })
  M.Flush()
  check(got("shaken", "nearly drowned"), "drowning: shaken")
  event("MIRROR_TIMER_START", "EXHAUSTION", 60000, 60000, -1, false, "Fatigue")
  check(got("uneasy", "out too far in deep water"), "fatigue in deep water: uneasy")

  -- Fleeing: low, on the move, and no kill to show for it
  fresh()
  NOW = NOW + 60
  local oldHP, oldCan = UnitHealth, UnitCanAttack
  UnitCanAttack = function() return false end
  event("PLAYER_REGEN_DISABLED")
  UnitHealth = function() return 15 end
  GetUnitSpeed = function() return 7 end
  event("UNIT_HEALTH", "player")
  event("PLAYER_REGEN_ENABLED")
  UnitHealth, GetUnitSpeed = oldHP, nil
  check(got("humbled", "ran for {their} life", 20), "fled a fight on low health: humbled " .. show("humbled"))
  NOW = NOW - 60

  -- Something far stronger, and easy prey
  fresh()
  local oldLevel, oldGUID = UnitLevel, UnitGUID
  UnitCanAttack = function() return true end
  UnitIsPlayer = function() return false end
  UnitClassification = function() return "normal" end
  UnitGUID = function(u) if u == "target" then return "Creature-0-77" end return ME end
  UnitLevel = function(u) if u == "target" then return 27 end return 22 end
  event("PLAYER_REGEN_DISABLED")
  cleu({ 0, "PARTY_KILL", false, ME, "Aldric", 0x511, 0, "Creature-0-77", "Ogre", 0 })
  event("PLAYER_REGEN_ENABLED")
  check(got("proud", "brought down something far stronger", 25), "killed something five levels up: proud " .. show("proud"))
  fresh()
  UnitLevel = function(u) if u == "target" then return 10 end return 22 end
  for _ = 1, 5 do
    event("PLAYER_REGEN_DISABLED")
    cleu({ 0, "PARTY_KILL", false, ME, "Aldric", 0x511, 0, "Creature-0-77", "Kobold", 0 })
    event("PLAYER_REGEN_ENABLED")
  end
  check(got("bored", "nothing here is a match for {them} now"), "a run of easy prey: bored " .. show("bored"))
  st.greys = nil
  UnitLevel, UnitGUID, UnitCanAttack = oldLevel, oldGUID, oldCan

  -- Ganked by the enemy
  fresh()
  cleu({ 0, "SWING_DAMAGE", false, "Player-5-0005", "Grukk", 0x548, 0, ME, "Aldric", 0, 0, 90, 0, 1, 0, 0, 0, false })
  event("PLAYER_DEAD")
  check(got("bitter", "cut down by the enemy", 30), "killed by an enemy player: bitter " .. show("bitter"))
  fresh()
  event("PLAYER_DEAD")
  check((st.emo.bitter or 0) == 0, "a death to a beast isn't a grudge")

  -- Brought back, rolls, failure, duels, honour
  fresh()
  event("RESURRECT_REQUEST", "Borin")
  check(got("grateful", "someone came back for {them}", 30), "resurrected by someone: grateful")
  fresh()
  event("CHAT_MSG_LOOT", "You have selected Need for: |cff0070dd|Hitem:1|h[Blade of Hanna]|h|r")
  event("CHAT_MSG_LOOT", "Borin won: |cff0070dd|Hitem:1|h[Blade of Hanna]|h|r")
  check(got("bitter", "lost the roll for Blade of Hanna", 20), "a roll lost: bitter " .. show("bitter"))
  event("CHAT_MSG_LOOT", "You won: |cff1eff00|Hitem:2|h[Shiny Bauble]|h|r")
  check(got("smug", "won the roll for Shiny Bauble"), "a roll won: smug " .. show("smug"))
  fresh()
  event("CHAT_MSG_SYSTEM", "The Missing Diplomat failed.")
  check(got("bitter", "failed at \"The Missing Diplomat\""), "a job failed: bitter " .. show("bitter"))
  M.Abandoned("Hogger")
  check(got("humbled", "gave up on \"Hogger\""), "a job given up: humbled")
  fresh()
  event("CHAT_MSG_SYSTEM", "Aldric has defeated Borin in a duel")
  check(got("smug", "won a duel"), "a duel won: smug, the loser not named " .. show("smug"))
  event("CHAT_MSG_SYSTEM", "Borin has defeated Aldric in a duel")
  check(got("humbled", "lost a duel", 20), "a duel lost: humbled")
  fresh()
  event("CHAT_MSG_SYSTEM", "Aldric has fled from Borin in a duel")
  check(got("humbled", "lost a duel", 20), "fleeing a duel counts as losing it")
  fresh()
  event("CHAT_MSG_COMBAT_HONOR_GAIN", "Grukk dies, honorable kill Rank: Grunt (Estimated Honor Points: 12)")
  check(got("proud", "an honourable kill"), "an honourable kill: proud")

  -- The pet, learning, a craft
  fresh()
  GetPetHappiness = function() return 2 end
  event("UNIT_HAPPINESS", "pet")
  GetPetHappiness = function() return 1 end
  UnitName = function(u) if u == "pet" then return "Fang" end return "Aldric" end
  event("UNIT_HAPPINESS", "pet")
  UnitName = function() return "Aldric" end
  GetPetHappiness = nil
  check(got("worried", "Fang is going hungry"), "a pet going hungry: worried " .. show("worried"))
  fresh()
  local oldInfo = GetSpellInfo
  GetSpellInfo = function(id) return id == 585 and "Smite" or "Renew" end
  event("LEARNED_SPELL_IN_TAB", 585, 1)
  check(got("satisfied", "learned Smite"), "a new spell learned: " .. show("satisfied"))
  event("LEARNED_SPELL_IN_TAB", 139, 1)
  check(st.why.satisfied == "learned two new things", "a trainer visit is one feeling: " .. tostring(st.why.satisfied))
  GetSpellInfo = oldInfo
  event("CHAT_MSG_SKILL", "Your skill in Herbalism has increased to 150.")
  check(got("accomplished", "Herbalism up to 150", 20), "a new rank in a craft: accomplished " .. show("accomplished"))

  -- A level after a long climb; a new mount; back after days away
  fresh()
  st.played, st.levelPlayed = 12000, 0
  event("PLAYER_LEVEL_UP", 23)
  check(got("proud", "a long climb, over at last", 25), "a level after a long climb: proud " .. show("proud"))
  fresh()
  event("PLAYER_LEVEL_UP", 23)
  check((st.emo.proud or 0) == 0, "a quick level isn't a long climb")
  fresh()
  ns.char.seen.mounts = nil
  M.CheckMount({ mounted = true, auras = { names = { ["Brown Horse"] = true } } })
  check((st.emo.cheerful or 0) == 0, "the mounts on the first look aren't new")
  M.CheckMount({ mounted = true, auras = { names = { ["Black Stallion"] = true } } })
  check(got("cheerful", "a new mount: Black Stallion", 30), "a new mount: cheerful " .. show("cheerful"))
  fresh()
  st.lastSeen = NOW - 5 * 86400
  M.Welcome()
  check(got("cheerful", "back on the road after five days", 30), "back after days away: " .. show("cheerful"))

  -- New land after dark
  fresh()
  state.resting = false
  local oldZone = state.zone
  state.zone = "Thousand Needles"
  event("ZONE_CHANGED_NEW_AREA")
  check(got("uneasy", "somewhere new, after dark"), "a new land at night: uneasy " .. show("uneasy"))
  state.zone, state.resting = oldZone, true

  -- The moment: the hour, a long session, idleness, home, rest, the season
  fresh()
  local w = { level = 22, race = "Human", class = "PRIEST", auras = {}, hour = 2, night = true, indoors = true,
    away = true, bind = "Goldshire", rested = 1500, festival = "midsummer" }
  st.session, st.afk, st.awayPlayed, st.road = 4 * 3600, 1200, 5 * 3600, 0
  local sc, why = M.Scores(w)
  local function has(mood, text)
    for _, r in ipairs(why[mood] or {}) do if r == text then return true end end
    return false
  end
  check(has("exhausted", "on the go for four hours") and has("exhausted", "the small hours"), "a long session in the small hours: exhausted")
  check(has("bored", "idle twenty minutes"), "idle a long while: bored")
  check(has("homesick", "a long way from Goldshire") and (sc.homesick or 0) >= 30, "a long way from home: homesick")
  check(has("cheerful", "well rested") and has("cheerful", "the long summer days"), "well rested, and summer: cheerful")
  check((sc.exhausted or 0) >= 30, "and exhausted wins out: " .. tostring(sc.exhausted))
  st.session, st.afk, st.awayPlayed = 0, 0, 0
  fresh()
  st.stirred = NOW - 3 * 3600
  st.session = 4000
  sc, why = M.Scores({ level = 22, race = "Human", class = "PRIEST", auras = {} })
  check(has("bored", "nothing much happening"), "nothing happening for an hour: bored")
  st.session, st.stirred = 0, nil

  -- Lively with no other addon: a game event alone sets the mood.
  fresh()
  event("RESURRECT_REQUEST", "Borin")
  local cur = M.Current({ level = 22, race = "Human", class = "PRIEST", auras = {}, resting = true })
  check(cur.key == "grateful" and cur.title == "Grateful" and cur.tell and cur.adj, "the mood from a game signal alone: " .. cur.key)
  check(ns.Compose.Walkup(cur) == 2, "grateful: open to walk-ups")
  check(ns.Compose.Walkup({ key = "bitter" }) == 1 and ns.Compose.Walkup({ key = "exhausted" }) == 1, "bitter or exhausted: not open")

  -- Every new mood is fully written.
  local thin = {}
  for _, k in ipairs({ "grateful", "humbled", "bored", "homesick", "smug", "exhausted", "cheerful", "bitter" }) do
    local m = W.MOODS[k]
    if not m or #m.tells < 5 or #m.adj < 5 or not m.icon or not m.title then thin[#thin + 1] = k
    else
      if k ~= "humbled" and not W.VALENCE[k] then thin[#thin + 1] = k .. " valence" end
      for _, race in ipairs({ "Human", "Dwarf", "Gnome", "NightElf", "Orc", "Troll", "Tauren", "Scourge", "Goblin" }) do
        if not (W.RACE_TELLS[race] and W.RACE_TELLS[race][k]) then thin[#thin + 1] = k .. " " .. race end
      end
      local classes = 0
      for _, t in pairs(W.CLASS_TELLS) do if t[k] then classes = classes + 1 end end
      if classes < 3 then thin[#thin + 1] = k .. " classes" end
    end
  end
  check(#thin == 0, "every new mood has titles, lines, icon, valence, race and class tells: " .. table.concat(thin, ", "))

  fresh()
  CombatLogGetCurrentEventInfo = nil
  RPGDialogueCharDB, SocialDiaryCharDB, ChronicleCharDB = keep[1], keep[2], keep[3]
  ns.Compose.SourcesChanged(); ns.Compose.Refresh()

  -- With Social Diary back, a friend is named.
  event("CHAT_MSG_TEXT_EMOTE", "Mirelle hugs you.", "Mirelle")
  check(got("cheerful", "Mirelle hugged {them}", 20), "a Social Diary friend is named: " .. show("cheerful"))
  fresh()
end

-- The journal: a session played through the game's own events, written down at logout.
do
  local J, C = ns.Journal, ns.Compose
  local saved = { deeds = ns.char.deeds, days = ns.char.days, milestones = ns.char.milestones, finds = ns.char.finds,
    GetGameTime = GetGameTime, GetMoney = GetMoney, UnitName = UnitName, UnitExists = UnitExists, UnitCanAttack = UnitCanAttack,
    UnitIsPlayer = UnitIsPlayer, UnitClassification = UnitClassification, UnitHealth = UnitHealth, IsInGroup = IsInGroup,
    GetNumGroupMembers = GetNumGroupMembers, IsInInstance = IsInInstance, GetInstanceInfo = GetInstanceInfo }
  local banned = {}
  for l in io.lines("tests/banned_phrases.txt") do
    if not l:match("^%s*#") and l:match("%S") then banned[#banned + 1] = (l:match("^(.-)%s*|") or l):gsub("^%s+", ""):gsub("%s+$", ""):lower() end
  end
  local function noBanned(text)
    local bad = {}
    for _, b in ipairs(banned) do if text:lower():find(b, 1, true) then bad[#bad + 1] = b end end
    return bad
  end
  ns.char.journal, ns.char.days = nil, {}
  ns.char.seen.zones.Westfall, ns.char.seen.zones.Duskwood, ns.char.seen.zones["The Deadmines"] = nil, nil, nil
  local hour, money = 7, 250000
  GetGameTime = function() return hour, 0 end
  GetMoney = function() return money end
  local names = { target = "Defias Pillager", party1 = "Mirelle", party2 = "Thorvald" }
  UnitName = function(u) return names[u] or "Aldric" end
  state.zone, state.sub, state.resting, state.combat = "Elwynn Forest", "Goldshire", false, false
  event("PLAYER_ENTERING_WORLD")
  event("PLAYER_MONEY")
  J.Today().money = 0
  -- Westfall for the first time; three jobs; a close call and a death near Moonbrook.
  NOW = NOW + 600
  state.zone, state.sub = "Westfall", "Sentinel Hill"
  event("ZONE_CHANGED_NEW_AREA")
  for i, title in ipairs({ "The Killing Fields", "The People's Militia", "Westfall Stew" }) do
    GetTitleText = function() return title end
    GetQuestID = function() return 900 + i end
    event("QUEST_COMPLETE"); event("QUEST_TURNED_IN", 900 + i, 0, 0)
  end
  UnitExists = function(u) return u == "target" or u == "party1" or u == "party2" end
  UnitCanAttack = function(_, u) return u == "target" end
  UnitIsPlayer = function() return false end
  UnitClassification = function() return "normal" end
  state.sub = "Moonbrook"
  event("PLAYER_REGEN_DISABLED")
  UnitHealth = function() return 10 end
  event("UNIT_HEALTH", "player")
  UnitHealth = function() return 100 end
  event("PLAYER_REGEN_ENABLED")
  NOW = NOW + 300
  event("PLAYER_REGEN_DISABLED")
  event("PLAYER_DEAD")
  UnitExists = function(u) return u == "party1" or u == "party2" end
  -- A friend from Social Diary and a stranger join; the Deadmines and its master.
  IsInGroup = function() return true end
  GetNumGroupMembers = function() return 3 end
  C.SourcesChanged(); C.Refresh()
  event("GROUP_ROSTER_UPDATE")
  NOW = NOW + 600
  IsInInstance = function() return true, "party" end
  GetInstanceInfo = function() return "The Deadmines", "party" end
  state.zone, state.sub = "The Deadmines", nil
  event("ZONE_CHANGED_NEW_AREA")
  event("ENCOUNTER_END", 1, "Edwin VanCleef", 1, 5, 1)
  event("CHAT_MSG_LOOT", "You receive loot: |cffa335ee|Hitem:1|h[Cruel Barb]|h|r.")
  event("CHAT_MSG_LOOT", "You receive loot: |cff9d9d9d|Hitem:2|h[Broken Tooth]|h|r.")
  IsInInstance = function() return false, "none" end
  IsInGroup = function() return false end
  GetNumGroupMembers = function() return 0 end
  event("GROUP_ROSTER_UPDATE")
  state.zone, state.sub = "Westfall", "Moonbrook"
  event("ZONE_CHANGED_NEW_AREA")
  event("PLAYER_LEVEL_UP", 23)
  event("CHAT_MSG_SKILL", "Your skill in Herbalism has increased to 124.")
  event("CHAT_MSG_SKILL", "Your skill in Herbalism has increased to 125.")
  money = 250000 + 812
  event("PLAYER_MONEY")
  -- A flight to Duskwood (new ground), and the night at the inn in Darkshire.
  UnitOnTaxi = function() return true end
  event("PLAYER_CONTROL_LOST")
  state.zone = "Redridge Mountains"; event("ZONE_CHANGED_NEW_AREA")   -- flown over: not "entered"
  state.zone, state.sub = "Duskwood", "Darkshire"
  event("ZONE_CHANGED_NEW_AREA")
  UnitOnTaxi = function() return false end
  event("PLAYER_CONTROL_GAINED")
  hour = 22
  state.sub, state.resting = "Scarlet Raven Tavern", true
  event("ZONE_CHANGED")
  ns.char.days[ns.Mood.Day()] = { moods = { weary = 5, shaken = 2 }, zones = { Westfall = 4 } }
  -- In combat nothing is written; at logout, the day is.
  state.combat = true
  event("PLAYER_LOGOUT")
  check(J.Entry() == nil, "journal: nothing is written in combat")
  state.combat = false
  event("PLAYER_LOGOUT")
  local e = J.Entry()
  local text = e and e.text or ""
  print("\nJournal entry:\n" .. text)
  for _, want in ipairs({ "Goldshire", "Westfall", "The Killing Fields", "Defias Pillager", "Moonbrook", "the Deadmines",
    "Edwin VanCleef", "Cruel Barb", "Mirelle", "herbalism", "eight silver", "Duskwood", "the Scarlet Raven Tavern" }) do
    check(text:find(want, 1, true), "journal mentions " .. want)
  end
  local tiredWords = false
  for _, w in ipairs(ns.Words.JOURNAL.feel.weary) do if text:find(w, 1, true) then tiredWords = true end end
  check(tiredWords, "journal: the day's mood (weary) ends it")
  check(not text:find("Thorvald", 1, true) and not text:find("Broken Tooth", 1, true) and not text:find("Redridge", 1, true),
    "journal: no stranger named, no junk loot, no land only flown over")
  check(not text:find("{", 1, true) and not text:find("}", 1, true), "journal: no tags left")
  check(#noBanned(text) == 0, "journal: no banned phrases: " .. table.concat(noBanned(text), ", "))
  check(text:find("for the first time", 1, true) or text:find("never seen", 1, true) or text:find("new ground", 1, true)
    or text:find("hadn't been", 1, true) or text:find("first sight", 1, true) or text:find("never been", 1, true), "journal: a first visit is told as one")
  -- /atrp journal today prints it, in the player's own chat.
  local said = {}
  local oldChat = DEFAULT_CHAT_FRAME.AddMessage
  DEFAULT_CHAT_FRAME.AddMessage = function(_, m) said[#said + 1] = m end
  SlashCmdList.AUTOTRP("journal today")
  DEFAULT_CHAT_FRAME.AddMessage = oldChat
  check(table.concat(said, " "):find("Cruel Barb", 1, true), "/atrp journal today prints today's entry")
  local ok = pcall(SlashCmdList.AUTOTRP, "journal")
  check(ok and J.Text():find("Cruel Barb", 1, true), "/atrp journal opens the journal, newest first")
  -- On the profile: the first lines, never the deaths.
  local line = J.LatestLine()
  check(line and line:find("Goldshire", 1, true) and not line:find("Pillager", 1, true), "the profile quotes the start, not the deaths: " .. tostring(line))
  -- Every pick reads cleanly, for many characters.
  local leftovers = {}
  for i = 1, 40 do
    ns.char.seedName = "journal" .. i
    local t = J.Compose(ns.Mood.Day()).text
    if t:find("[{}]") or t:find('""', 1, true) or #noBanned(t) > 0 or t:find("  ", 1, true) or t:find(" ,", 1, true) or t:find("%.%.") then leftovers[#leftovers + 1] = t end
    if i <= 2 then print("\nJournal, another voice:\n" .. t) end
  end
  ns.char.seedName = "Aldric-Forever"
  check(#leftovers == 0, "journal: every variant reads cleanly: " .. (leftovers[1] or ""))

  -- Without RPG Dialogue, Social Diary or Chronicle: the journal still works, names no one,
  -- and History and Lately quote it.
  local rpgdDB, sdDB, chronDB = RPGDialogueCharDB, SocialDiaryCharDB, ChronicleCharDB
  RPGDialogueCharDB, SocialDiaryCharDB, ChronicleCharDB = nil, nil, nil
  C.SourcesChanged(); C.Refresh()
  check(C.Sheet() ~= nil, "a whole profile is written with none of the three addons")
  local hist = C.History()
  check(hist:find("journal", 1, true) and hist:find("Goldshire", 1, true), "History quotes the journal when there's no diary")
  local g = J.LatelyGlance()
  check(g and g.TX:find("journal", 1, true) and not g.TX:find("{", 1, true), "Lately can quote it: " .. tostring(g and g.TX))
  ns.char.journal = nil
  event("PLAYER_ENTERING_WORLD")
  IsInGroup = function() return true end
  GetNumGroupMembers = function() return 3 end
  ns.Sources.Deeds.Read()
  event("GROUP_ROSTER_UPDATE")
  GetQuestID = function() return 999 end
  event("QUEST_COMPLETE"); event("QUEST_TURNED_IN", 999, 0, 0)
  NOW = NOW + 700
  event("PLAYER_LOGOUT")
  local bare = J.Entry() and J.Entry().text or ""
  print("\nJournal without the other addons:\n" .. bare)
  check(bare:find('"Westfall Stew"', 1, true) and not bare:find('""', 1, true) and not bare:find("Mirelle", 1, true) and not bare:find("Thorvald", 1, true),
    "journal without the addons: written from the game alone, nobody named")
  ns.db.journalInProfile = false
  check(J.LatestLine() == nil and J.LatelyGlance() == nil, "switched off, the profile doesn't quote it")
  ns.db.journalInProfile = true
  RPGDialogueCharDB, SocialDiaryCharDB, ChronicleCharDB = rpgdDB, sdDB, chronDB
  for k, v in pairs(saved) do if k == "deeds" or k == "days" or k == "milestones" or k == "finds" then ns.char[k] = v else _G[k] = v end end
  GetTitleText, GetQuestID = nil, nil
  state.zone, state.sub, state.resting, state.combat = "Duskwood", "Raven Hill", false, false
  C.SourcesChanged(); C.Refresh()
  check(C.History():find("Back at the Lion's Pride", 1, true), "with RPG Dialogue's diary back, History quotes that instead")
end

-- Currently from the game alone: with no other addon, every place has words, every moment
-- the game shows (a ghost, a ship, a battleground, a queue, breath, a fall, a shape, a
-- barber's chair) reaches Currently, the hour is told once, and it reads as one line.
do
  local W, U, C, World = ns.Words, ns.U, ns.Compose, ns.World
  local keep = { RPGDialogueCharDB, SocialDiaryCharDB, ChronicleCharDB }
  RPGDialogueCharDB, SocialDiaryCharDB, ChronicleCharDB = nil, nil, nil
  local G = {}
  for _, k in ipairs({ "UnitIsGhost", "UnitIsDeadOrGhost", "IsInInstance", "IsSwimming", "IsFalling", "IsStealthed", "IsMounted",
    "IsIndoors", "GetGameTime", "UnitClass", "UnitRace", "UnitFactionGroup", "UnitDebuff", "GetBattlefieldStatus", "UnitIsDND",
    "IsInRaid", "IsInGroup", "GetNumGroupMembers", "CanMerchantRepair", "ItemTextGetItem", "UnitExists", "date" }) do G[k] = _G[k] end
  local function restore() for k, v in pairs(G) do _G[k] = v end end
  local saved = { zone = state.zone, sub = state.sub, resting = state.resting, buffs = state.buffs, grouped = state.grouped }
  state.buffs = {}
  local function cu() C.SourcesChanged(); C.Refresh(); return C.Currently(ns.Mood.Current()) end
  local function moment() C.Refresh(); return World.Moment(ns.cache.world, "test") end
  -- The longest plain stretch of a line (between its tags), for finding it in what's written.
  local function core(line)
    local best = ""
    for part in (line .. "{"):gmatch("([^{}]*){") do
      part = part:gsub("^[%s,%.]+", ""):gsub("[%s,%.]+$", "")
      if #part > #best then best = part end
    end
    return best:lower()
  end
  local function has(text, list)
    text = (text or ""):lower()
    for _, l in ipairs(type(list) == "table" and list or { list }) do
      local c = core(l)
      if #c >= 4 and text:find(c, 1, true) then return true end
    end
    return false
  end
  local function at(zone, sub, resting) state.zone, state.sub, state.resting = zone, sub, resting or false end

  -- Every zone the map knows has its own words, three ways or more, and the hour where it shows.
  local thin = {}
  for _, name in pairs(W.ZONE_BY_MAP) do
    local list = W.ZONE_FLAVOR[name] or W.BG_FLAVOR[name]
    if type(list) ~= "table" or #list < 3 then thin[#thin + 1] = name end
    if not W.BG_FLAVOR[name] and name ~= "Ironforge" and name ~= "Undercity" and not (W.PLACE_TIME[name] and W.PLACE_TIME[name].night) then
      thin[#thin + 1] = name .. " (night)"
    end
  end
  check(#thin == 0, "every zone by map ID has three lines or more and a night: " .. table.concat(thin, ", "))
  local n, short = 0, {}
  for name, list in pairs(W.SUBZONE_FLAVOR) do n = n + 1; if #list < 3 then short[#short + 1] = name end end
  for name, list in pairs(W.CITY_FLAVOR) do if type(list) ~= "table" or #list < 3 then short[#short + 1] = name end end
  check(n >= 200 and #short == 0, "over two hundred subzones and every district, three ways each (" .. n .. "): " .. table.concat(short, ", "))

  -- Every new line fills its tags, whatever the pronouns.
  local fillers = { where = "x", place = "x", around = "x", sub = "x", pet = "x", sea = "x", pole = "x", bg = "x", who = "x",
    dest = "x", what = "x", n = "two", total = "three", mount = "x", beast = "x", kind = "x" }
  local bad = {}
  local function scan(v, path)
    if type(v) == "string" then
      local line = U.Pron((v:gsub("{(%a+)}", function(k) return fillers[k] end)))
      if line:find("{") then bad[#bad + 1] = path .. ": " .. line end
    elseif type(v) == "table" then for k, x in pairs(v) do scan(x, path .. "." .. tostring(k)) end end
  end
  for _, pron in ipairs({ "she/her", "they/them" }) do
    local old = ns.TRP.CustomPronouns
    ns.TRP.CustomPronouns = function() return pron end
    for _, key in ipairs({ "SUBZONE_FLAVOR", "PLACE_TIME", "CITY_FLAVOR", "ZONE_FLAVOR", "BG_FLAVOR", "BG_AT", "QUEUED", "TRANSPORT",
      "FORM_LINES", "STEALTH", "MOMENT", "EXTRA", "ASIDE", "FESTIVAL_TOWN", "ACTIVITY" }) do scan(W[key], key) end
    ns.TRP.CustomPronouns = old
  end
  check(#bad == 0, "every Currently line fills its tags: " .. table.concat(bad, " | "))

  -- Places
  at("Westfall", "Sentinel Hill")
  local text = cu()
  check(has(text, W.SUBZONE_FLAVOR["Sentinel Hill"]) and text:find("Westfall"), "a town has its own words, and the land too: " .. text)
  at("Stranglethorn Vale", "Booty Bay", true)
  check(has(cu(), W.SUBZONE_FLAVOR["Booty Bay"]), "Booty Bay: " .. cu())
  at("Stormwind City", "The Park", true)
  check(has(cu(), W.CITY_FLAVOR["The Park"]), "a capital's district: " .. cu())
  at("Orgrimmar", nil, true)
  check(has(cu(), W.ZONE_FLAVOR["Orgrimmar"]), "a capital between its districts: " .. cu())
  -- The hour, told once: by the place's own night line, or by "under the stars", never both.
  IsIndoors = function() return false end
  GetGameTime = function() return 23, 0 end
  local nightLine, twice = false, {}
  for _, spot in ipairs({ { "Elwynn Forest", "Goldshire" }, { "Duskwood", "Darkshire" }, { "The Barrens", "The Crossroads" },
    { "Mulgore", nil }, { "Tanaris", nil }, { "Stormwind City", "Old Town" }, { "Durotar", "Razor Hill" }, { "Westfall", nil } }) do
    at(spot[1], spot[2])
    for i = 1, 4 do
      ns.char.seedName = "night" .. i
      local t = cu()
      local own
      for _, l in ipairs(W.PLACE_TIME[spot[2] or spot[1]] and W.PLACE_TIME[spot[2] or spot[1]].night or {}) do
        local s0, e0 = t:lower():find(core(l), 1, true)
        if s0 then own = t:sub(1, s0 - 1) .. t:sub(e0 + 1) end
      end
      if own then nightLine = true end
      if own and has(own, W.TIME_OF_DAY.night) then twice[#twice + 1] = t end
    end
  end
  ns.char.seedName = nil
  check(nightLine and #twice == 0, "night has its own words, and the hour is told once: " .. table.concat(twice, " | "))
  IsIndoors, GetGameTime = G.IsIndoors, G.GetGameTime

  -- Moments
  at("Duskwood", "Raven Hill")
  UnitIsDeadOrGhost = function() return true end
  check(has(cu(), W.MOMENT.fallen), "fallen and not yet risen: " .. cu())
  UnitIsGhost = function() return true end
  local ghost = cu()
  check(has(ghost, W.MOMENT.ghost) or has(ghost, W.TRAVEL.ghost), "a ghost on the way back: " .. ghost)
  UnitIsGhost, UnitIsDeadOrGhost = G.UnitIsGhost, G.UnitIsDeadOrGhost
  UnitDebuff = function(_, i) if i == 1 then return "Resurrection Sickness" end end
  check(has(cu(), W.ASIDE.ressick), "resurrection sickness lingers in a second sentence: " .. cu())
  UnitDebuff = G.UnitDebuff

  at("The Great Sea", nil)
  check(has(cu(), W.TRANSPORT.ship) and cu():find("the Great Sea", 1, true), "Alliance at sea: aboard a ship: " .. cu())
  UnitFactionGroup = function() return "Horde" end
  check(has(cu(), W.TRANSPORT.zeppelin), "Horde between the continents: a zeppelin: " .. cu())
  at("South Seas", nil)
  check(has(cu(), W.TRANSPORT.ship), "the Booty Bay boat is a ship for everyone: " .. cu())
  UnitFactionGroup = G.UnitFactionGroup

  IsInInstance = function() return true, "pvp" end
  at("Warsong Gulch", nil)
  check(has(cu(), W.BG_FLAVOR["Warsong Gulch"]), "in a battleground, by name: " .. cu())
  at("Arathi Basin", "Lumber Mill")
  local ab = cu()
  check(has(ab, W.BG_FLAVOR["Arathi Basin"]) or ab:find("Lumber Mill", 1, true), "Arathi Basin, around a base: " .. ab)
  IsInInstance = G.IsInInstance
  at("Elwynn Forest", "Goldshire", true)
  GetBattlefieldStatus = function(i) if i == 1 then return "queued", "Alterac Valley" end return "none" end
  check(cu():find("Alterac Valley", 1, true) and has(cu(), W.QUEUED), "queued for a battleground: " .. cu())
  GetBattlefieldStatus = G.GetBattlefieldStatus
  UnitIsDND = function() return true end
  check(has(cu(), W.ASIDE.dnd), "do not disturb: " .. cu())
  UnitIsDND = G.UnitIsDND

  at("Loch Modan", nil)
  IsSwimming = function() return true end
  event("MIRROR_TIMER_START", "BREATH", 60000, 60000, -1, false, "Breath")
  check(has(cu(), W.MOMENT.underwater), "holding a breath underwater: " .. cu())
  event("MIRROR_TIMER_STOP", "BREATH")
  event("MIRROR_TIMER_START", "EXHAUSTION", 60000, 60000, -1, false, "Fatigue")
  check(has(cu(), W.MOMENT.deepwater), "too far out in deep water: " .. cu())
  event("MIRROR_TIMER_STOP", "EXHAUSTION")
  check(not has(cu(), W.MOMENT.underwater) and not has(cu(), W.MOMENT.deepwater), "back to plain swimming when the timer stops")
  IsSwimming = G.IsSwimming
  IsFalling = function() return true end
  check(has(cu(), W.MOMENT.falling), "falling: " .. cu())
  IsFalling = G.IsFalling

  IsStealthed = function() return true end
  UnitClass = function() return "Rogue", "ROGUE" end
  state.buffs = { "Stealth" }
  check(has(cu(), W.STEALTH.ROGUE), "a rogue in stealth: " .. cu())
  UnitClass = function() return "Druid", "DRUID" end
  state.buffs = { "Cat Form", "Prowl" }
  check(has(cu(), W.STEALTH.DRUID), "a druid on the prowl: " .. cu())
  IsStealthed = G.IsStealthed
  local forms = {}
  for buff, key in pairs({ ["Bear Form"] = "bear", ["Cat Form"] = "cat", ["Travel Form"] = "travel", ["Aquatic Form"] = "aquatic",
    ["Moonkin Form"] = "moonkin", ["Ghost Wolf"] = "ghostwolf", ["Shadowform"] = "shadowform" }) do
    state.buffs = { buff }
    local m = moment()
    if not (m.extras[1] and has(m.extras[1], W.FORM_LINES[key])) then forms[#forms + 1] = buff end
  end
  check(#forms == 0, "every shape has its words: " .. table.concat(forms, ", "))
  state.buffs = {}
  UnitClass = G.UnitClass

  -- Company and kit
  at("Redridge Mountains", nil)
  IsInGroup = function() return true end
  GetNumGroupMembers = function() return 4 end
  local m = moment()
  check(m.extras[1] and (m.extras[1]:find("three") or m.extras[1]:find("four")), "a party, counted: " .. tostring(m.extras[1]))
  IsInRaid = function() return true end
  GetNumGroupMembers = function() return 25 end
  m = moment()
  check(m.extras[1] and m.extras[1]:find("twenty%-five"), "a raid, counted: " .. tostring(m.extras[1]))
  IsInRaid, IsInGroup, GetNumGroupMembers = G.IsInRaid, G.IsInGroup, G.GetNumGroupMembers
  local oldMain = GEAR[16]
  GEAR[16] = { "Strong Fishing Pole", 1, "Fishing Poles" }
  World.Invalidate()
  check(cu():find("Strong Fishing Pole", 1, true), "a fishing pole in hand, by its name: " .. cu())
  GEAR[16] = oldMain
  World.Invalidate()

  -- What they're busy with: frames, casts and books, from the game's own events.
  at("Ironforge", "The Commons", true)
  local busy = {}
  local function sees(evt, kind, ...)
    World.ClearContext()
    event(evt, ...)
    local t = cu()
    if not has(t, W.ACTIVITY[kind]) then busy[#busy + 1] = evt .. " -> " .. t end
  end
  sees("BARBER_SHOP_OPEN", "barber"); sees("PET_STABLE_SHOW", "stable"); sees("CONFIRM_BINDER", "innkeeper")
  sees("GUILDBANKFRAME_OPENED", "guildbank"); sees("GUILD_REGISTRAR_SHOW", "registrar"); sees("TRADE_SHOW", "trade")
  sees("CONFIRM_XP_LOSS", "spirithealer"); sees("AUTOFOLLOW_BEGIN", "follow", "Somebody")
  CanMerchantRepair = function() return true end
  sees("MERCHANT_SHOW", "repair")
  CanMerchantRepair = G.CanMerchantRepair
  ItemTextGetItem = function() return "The Seven Kingdoms" end
  sees("ITEM_TEXT_BEGIN", "reading")
  check(cu():find("The Seven Kingdoms", 1, true), "reading a book, by its title: " .. cu())
  check(#busy == 0, "the game's frames reach Currently: " .. table.concat(busy, " | "))
  World.SetContext("follow")
  event("AUTOFOLLOW_END")
  check(not World.Context(), "following stops when the game says so")
  check(not cu():find("Somebody", 1, true), "never names who they follow")
  for _, k in ipairs({ "map", "feedpet", "teleport" }) do
    World.SetContext(k, k == "teleport" and "Darnassus" or nil)
    local t = cu()
    check(has(t, W.ACTIVITY[k]) and (k ~= "teleport" or t:find("Darnassus")), "context " .. k .. ": " .. t)
  end
  check(W.SPELLS["Feed Pet"].context == "feedpet" and W.SPELLS["Feed Pet"].mood, "Feed Pet keeps its mood and shows in Currently")
  World.ClearContext()

  -- Festivals show where the game dresses for them: the capitals, and inns for Hallow's End.
  date = function(fmt, t) if fmt == "*t" then return { year = 2026, month = 12, day = 20, hour = 12 } end return G.date(fmt, t) end
  at("Stormwind City", "Trade District", true)
  check(has(cu(), W.FESTIVAL_TOWN.winterveil), "Winter Veil in Stormwind: " .. cu())
  at("Westfall", nil)
  check(not has(cu(), W.FESTIVAL_TOWN.winterveil), "and not out on the road")
  date = function(fmt, t) if fmt == "*t" then return { year = 2026, month = 10, day = 25, hour = 12 } end return G.date(fmt, t) end
  at("Elwynn Forest", "Lion's Pride Inn", true)
  check(cu():lower():find("the inn is decked out", 1, true) or cu():find("reached the inn", 1, true), "Hallow's End at the inn: " .. cu())
  date = G.date

  -- One line, never a list; and never a mark of the other addons.
  local lines, listy = {}, {}
  for _, spot in ipairs({ { "Elwynn Forest", "Goldshire" }, { "Ashenvale", "Astranaar" }, { "Tanaris", "Gadgetzan" },
    { "Silithus", "Cenarion Hold" }, { "Thunder Bluff", "Elder Rise" }, { "Felwood", nil }, { "Winterspring", "Everlook" } }) do
    at(spot[1], spot[2])
    IsInGroup = function() return true end
    GetNumGroupMembers = function() return 3 end
    UnitExists = function(u) return u == "pet" end
    local t = cu()
    lines[#lines + 1] = t
    local _, commas = t:gsub(",", "")
    if commas > 3 or #t > C.CURRENTLY_MAX or t:find("Mirelle") then listy[#listy + 1] = t end
  end
  print("\nCurrently, from the game alone:\n  " .. table.concat(lines, "\n  "))
  check(#listy == 0, "Currently reads as one line, not a list: " .. table.concat(listy, " | "))

  -- SAMPLES=1 also prints Currently across places, hours, shapes and company.
  if os.getenv("SAMPLES") then
    UnitClass = function() return "Hunter", "HUNTER" end
    UnitExists = function(u) return u == "pet" end
    local oldName = UnitName
    UnitName = function(u) if u == "pet" then return "Fang" end return "Aldric" end
    IsIndoors = function() return false end
    local spots = { { "Duskwood", "Darkshire" }, { "Stranglethorn Vale", "Grom'gol Base Camp" }, { "Dun Morogh", "Kharanos" },
      { "Tirisfal Glades", "Brill" }, { "The Barrens", nil }, { "Desolace", "Kodo Graveyard" }, { "Un'Goro Crater", "Marshal's Refuge" },
      { "Eastern Plaguelands", "Light's Hope Chapel" }, { "Undercity", "The Apothecarium" }, { "Moonglade", "Nighthaven" } }
    print("\nCurrently samples:")
    for i, spot in ipairs(spots) do
      at(spot[1], spot[2])
      GetGameTime = function() return ({ 23, 6, 19, 13 })[i % 4 + 1], 0 end
      IsMounted = function() return i % 3 == 0 end
      IsInGroup = function() return i % 4 == 1 end
      GetNumGroupMembers = function() return i % 4 == 1 and 5 or 0 end
      ns.char.seedName = "sample" .. i
      print("  " .. cu())
    end
    ns.char.seedName = nil
    UnitName = oldName
  end

  restore()
  IsMounted = function() return false end
  for k, v in pairs(saved) do state[k] = v end
  RPGDialogueCharDB, SocialDiaryCharDB, ChronicleCharDB = keep[1], keep[2], keep[3]
  World.ClearContext(); World.Invalidate()
  C.SourcesChanged(); C.Refresh()
end

-- The interface: settings panel, preview, welcome window, mood badge and /atrp help, built
-- against the generic frame mock (any method is a no-op).
do
  local UI = ns.UI
  local tip = {}
  GameTooltip = { SetOwner = function() tip = {} end, AddLine = function(_, t) tip[#tip + 1] = t end,
    SetText = function(_, t) tip[#tip + 1] = t end, Show = function() end, Hide = function() end }
  local said = {}
  local oldChat = DEFAULT_CHAT_FRAME.AddMessage
  local function listen() said = {}; DEFAULT_CHAT_FRAME.AddMessage = function(_, m) said[#said + 1] = m end end
  local function stop() DEFAULT_CHAT_FRAME.AddMessage = oldChat end
  local function heard(s) for _, m in ipairs(said) do if m:find(s, 1, true) then return true end end return false end

  -- Settings panel: made at login, filled the first time it's shown.
  local panel = UI.panel
  check(panel ~= nil and panel.built == false, "the settings panel's contents wait until it's opened")
  local ok, err = pcall(panel.scripts.OnShow, panel)
  check(ok and panel.built == true, "building the settings panel doesn't error: " .. tostring(err))
  local nOpts = 0
  for _, o in ipairs(UI.OPTIONS) do if o.path then nOpts = nOpts + 1 end end
  check(#UI.boxes == nOpts, "a checkbox for every option: " .. #UI.boxes .. "/" .. nOpts)
  local noTip, emptyHover = {}, {}
  for _, cb in ipairs(UI.boxes) do
    if not UI.TipFor(cb.opt) then noTip[#noTip + 1] = table.concat(cb.opt.path, ".") end
    cb.scripts.OnEnter(cb)
    if #tip < 2 then emptyHover[#emptyHover + 1] = table.concat(cb.opt.path, ".") end
  end
  check(#noTip == 0, "every option has a tooltip (UI.TIPS or tip =): " .. table.concat(noTip, ", "))
  check(#emptyHover == 0, "hovering every checkbox shows its name and what it does: " .. table.concat(emptyHover, ", "))
  local lines = UI.SourceLines()
  check(#lines == 4 and lines[1]:find("Total RP 3") and lines[1]:find("found") and lines[2]:find("RPG Dialogue"), "the source lines show what each addon adds")
  check(StaticPopupDialogs.AUTOTRP_RESTORE and StaticPopupDialogs.AUTOTRP_RESTORE.button1 == "Restore", "Restore asks first")

  -- Per-heading toggles flip only their own group.
  local function flat()
    local t = {}
    for _, o in ipairs(UI.OPTIONS) do
      if o.path then
        local v = ns.db
        for _, k in ipairs(o.path) do v = v[k] end
        t[table.concat(o.path, ".")] = v
      end
    end
    return t
  end
  local saved = flat()
  local groups = UI.Groups()
  check(#groups >= 4, "options come in groups under their headings: " .. #groups)
  local bad = {}
  for _, g in ipairs(groups) do
    for _, on in ipairs({ false, true }) do
      local before = flat()
      UI.SetGroupOptions(g.head, on)
      local after, inGroup = flat(), {}
      for _, o in ipairs(g.items) do inGroup[table.concat(o.path, ".")] = true end
      for k, v in pairs(after) do
        if inGroup[k] and v ~= on then bad[#bad + 1] = g.head .. ":" .. k .. " not " .. tostring(on) end
        if not inGroup[k] and v ~= before[k] then bad[#bad + 1] = g.head .. " changed " .. k end
      end
    end
  end
  check(#bad == 0, "each heading's On / Off flips its own group and nothing else: " .. table.concat(bad, "; "))
  for k, v in pairs(saved) do
    local path, t = {}, ns.db
    for part in k:gmatch("[^.]+") do path[#path + 1] = part end
    for i = 1, #path - 1 do t = t[path[i]] end
    t[path[#path]] = v
  end
  UI.UpdateBadge()

  -- Preview: builds, every tab lays out, glances carry their icons.
  ok, err = pcall(UI.Preview)
  check(ok and UI.previewFrame ~= nil, "building the preview doesn't error: " .. tostring(err))
  local f = UI.previewFrame
  for i = 1, #UI.PREVIEW_TABS do
    ok, err = pcall(UI.PreviewTab, i)
    check(ok and f.tab == i, "preview tab " .. UI.PREVIEW_TABS[i] .. " lays out: " .. tostring(err))
  end
  local tabs = UI.PreviewSections()
  local glanceIcon, statusAll, statsRows = false, true, 0
  for _, r in ipairs(tabs[1].rows) do
    if r.key == "glance_mood" and r.icon and UI.IconString(r.icon):find("^|TInterface\\Icons\\") then glanceIcon = true end
  end
  for t = 1, 4 do for _, r in ipairs(tabs[t].rows) do if r.key and not UI.STATUS_WORDS[r.status] then statusAll = false end end end
  for _, r in ipairs(tabs[4].rows) do if r.key:find("^stat_") then statsRows = statsRows + 1 end end
  check(glanceIcon, "the mood glance shows its icon")
  check(statusAll, "every preview field says whose it is")
  check(statsRows >= 10, "the statistics tab lists the statistics: " .. statsRows)
  check(UI.CopyText("{col:ffeecc}\"A quote\"{/col}\nand more") == "\"A quote\" and more", "the copy box holds plain text")
  ok = pcall(f.scripts.OnDragStop, f)
  check(ok, "moving the preview saves its place without error")
  check(UI.PreviewText():find("Currently", 1, true) ~= nil, "the text preview still works")

  -- Welcome window.
  local declined, declines = ns.char.declined, ns.char.declines
  ok, err = pcall(UI.ShowWelcome)
  check(ok and UI.welcomeFrame and UI.welcomeFrame.buttons.make and UI.welcomeFrame.buttons.never, "building the welcome window doesn't error: " .. tostring(err))
  check(#UI.WELCOME_LINES == 3, "the welcome says what it does in three lines")
  listen()
  local w = UI.welcomeFrame
  w.Hide = function(self) if self.scripts.OnHide then self.scripts.OnHide(self) end end
  w.buttons.never.scripts.OnClick(w.buttons.never)
  stop()
  check(ns.char.declined == true and (ns.char.declines or 0) == (declines or 0), "Don't ask again stops the prompt, without counting a plain no")
  ns.char.declined = false
  UI.ShowWelcome(); w.chose = false
  w:Hide()
  check(ns.char.declines == (declines or 0) + 1, "closing the welcome counts as not now")
  ns.char.declined, ns.char.declines = declined, declines

  -- Mood badge: tooltip, clicks, a glow when the mood turns.
  local b = UI.badge
  ns.char.lastWrite = { t = NOW - 120, fields = { "Currently", "Glance: mood" } }
  b.scripts.OnEnter(b)
  local all = table.concat(tip, "\n")
  check(all:find("last written 2 min ago", 1, true) and all:find("Changed: Currently, Glance: mood", 1, true), "the badge tooltip says when the profile was written and what changed")
  check(all:find("Shift-click", 1, true) and all:find("Ctrl-click", 1, true), "the badge tooltip lists the clicks")
  IsShiftKeyDown = function() return true end
  listen(); b.scripts.OnClick(b, "LeftButton"); stop()
  check(heard("Currently: ") and heard("only you see this"), "shift-click shows Currently in your own chat")
  IsShiftKeyDown = function() return false end
  IsControlKeyDown = function() return true end
  local opened, oldOpen = false, UI.OpenSettings
  UI.OpenSettings = function() opened = true end
  b.scripts.OnClick(b, "LeftButton")
  UI.OpenSettings = oldOpen
  IsControlKeyDown = nil; IsShiftKeyDown = nil
  check(opened, "ctrl-click opens the settings")
  local pulses, oldPulse = 0, UI.PulseBadge
  UI.PulseBadge = function() pulses = pulses + 1 end
  UI.UpdateBadge({ key = "elated", title = "Elated", icon = "INV_Misc_Book_11" })
  UI.UpdateBadge({ key = "elated", title = "Elated", icon = "INV_Misc_Book_11" })
  UI.UpdateBadge({ key = "downcast", title = "Downcast", icon = "INV_Misc_Book_11" })
  UI.PulseBadge = oldPulse
  check(pulses == 2, "the badge glows only when the mood turns: " .. pulses)
  check(pcall(UI.PulseBadge), "the glow builds without error")

  -- /atrp help lists every command in README's table.
  listen(); SlashCmdList.AUTOTRP("help"); stop()
  local help = table.concat(said, "\n"):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("||", "|")
  local missing, n = {}, 0
  local inTable = false
  for line in io.lines("README.md") do
    if line:match("^## Commands") then inTable = true elseif line:match("^## ") then inTable = false end
    if inTable and line:match("^| `/atrp") then
      local first = line:match("^|(.-[^\\])|")
      for cmd in first:gmatch("`(/atrp[^`]*)`") do
        cmd = cmd:gsub("\\|", "|")
        n = n + 1
        if not help:find(cmd, 1, true) then missing[#missing + 1] = cmd end
      end
    end
  end
  check(n >= 20 and #missing == 0, "/atrp help lists every command in README (" .. n .. "): missing " .. table.concat(missing, ", "))
  listen(); SlashCmdList.AUTOTRP("nonsense"); stop()
  check(heard("No command 'nonsense'") and heard("/atrp preview"), "an unknown command says so and lists the rest")
  GameTooltip = nil
end


-- Review fixes (0.21.0): names, repeats and doubles.
do
  -- The second feeling in Currently never repeats a word of the first ("Flushed with
  -- success and flushed with victory").
  local keepMood, keepSeed = ns.char.mood, ns.char.seedName
  local bad
  for i = 1, 120 do
    ns.char.mood = { emo = { elated = 80, triumphant = 75 }, t = NOW, why = {} }
    ns.char.seedName = "also" .. i
    local m = ns.Mood.Current(ns.cache.world)
    if m.also then
      for w in m.adj:lower():gmatch("%a+") do
        if #w >= 4 and (" " .. m.also .. " "):find("[^%a]" .. w .. "[^%a]") then bad = m.adj .. " / " .. m.also end
      end
    end
  end
  check(not bad, "the mood's second word never repeats the first: " .. tostring(bad))
  ns.char.mood, ns.char.seedName = keepMood, keepSeed

  -- An enemy player fought is never named: not in the Lately glance, not as a killer.
  local saved = { UnitCanAttack, UnitIsPlayer, UnitName, UnitClass, UnitFactionGroup, UnitExists, UnitClassification }
  UnitExists = function(u) return u == "target" or u == "player" end
  UnitCanAttack = function(_, u) return u == "target" end
  UnitIsPlayer = function(u) return u == "target" or u == "player" end
  UnitName = function(u) if u == "target" then return "Gankalot" end return "Aldric" end
  UnitClass = function(u) if u == "target" then return "Rogue", "ROGUE" end return "Priest", "PRIEST" end
  UnitFactionGroup = function(u) if u == "target" then return "Horde" end return "Alliance" end
  UnitClassification = function() return "normal" end
  event("PLAYER_REGEN_DISABLED")
  event("PLAYER_REGEN_ENABLED")
  local f = ns.char.lastFight
  check(f and type(f.foe) == "table" and f.foe.player and f.foe.name == "Horde rogue", "an enemy player is kept as what they are: " .. tostring(f and f.foe and f.foe.name))
  ns.Compose.SourcesChanged(); ns.Compose.Refresh()
  local lately = ns.Compose.LatelyGlance()
  check(not (lately and lately.TX or ""):find("Gankalot", 1, true), "the Lately glance never names an enemy player: " .. tostring(lately and lately.TX))
  local deaths = #ns.char.deeds.deaths
  event("PLAYER_DEAD")
  local last = ns.char.deeds.deaths[#ns.char.deeds.deaths]
  check(#ns.char.deeds.deaths == deaths + 1 and last.killer == nil, "a death to an enemy player keeps no name: " .. tostring(last and last.killer))
  -- A creature the fight was with still counts as the killer.
  UnitIsPlayer = function(u) return u == "player" end
  UnitName = function(u) if u == "target" then return "Hogger" end return "Aldric" end
  event("PLAYER_REGEN_DISABLED")
  event("PLAYER_REGEN_ENABLED")
  UnitExists = function(u) return u == "player" end
  event("PLAYER_DEAD")
  last = ns.char.deeds.deaths[#ns.char.deeds.deaths]
  check(last.killer == "Hogger", "a creature that killed them is still named: " .. tostring(last.killer))
  UnitCanAttack, UnitIsPlayer, UnitName, UnitClass, UnitFactionGroup, UnitExists, UnitClassification = unpack(saved)
  ns.char.lastFight = nil

  -- A roll won is one find, not two ("You won: [x]" then "You receive loot: [x]").
  local finds = ns.char.finds and #ns.char.finds or 0
  ns.char.finds = ns.char.finds or {}
  local before = #ns.char.finds
  event("CHAT_MSG_LOOT", "You won: |cffa335ee|Hitem:9|h[Gutgore Ripper]|h|r")
  event("CHAT_MSG_LOOT", "You receive loot: |cffa335ee|Hitem:9|h[Gutgore Ripper]|h|r.")
  local n = 0
  for _, fd in ipairs(ns.char.finds) do if fd.item == "Gutgore Ripper" then n = n + 1 end end
  check(n == 1, "a roll won is one find: " .. n)
  for i = #ns.char.finds, 1, -1 do if ns.char.finds[i].item == "Gutgore Ripper" then table.remove(ns.char.finds, i) end end

  -- A player's letter: reading, but never its subject.
  local gi, gc = ItemTextGetItem, ItemTextGetCreator
  ItemTextGetItem = function() return "Meet me at Gankalot's" end
  ItemTextGetCreator = function() return "Gankalot" end
  event("ITEM_TEXT_BEGIN")
  local ctx = ns.World.Context()
  check(ctx and ctx.kind == "reading" and ctx.detail == nil, "a player's letter is read, its subject never kept")
  ItemTextGetItem, ItemTextGetCreator = gi, gc
  ns.World.SetContext("none")

  -- A quest shared by another player: the quest window names them as "npc", Currently never does.
  local keepGUID, keepName, keepIsPlayer = UnitGUID, UnitName, UnitIsPlayer
  UnitGUID = function(u) return "Player-1-00C1" end
  UnitName = function(u) if u == "npc" then return "Gankalot" end return "Aldric" end
  UnitIsPlayer = function(u) return u == "npc" or u == "player" end
  ns.World.SetContext("none")
  event("QUEST_DETAIL")
  local c2 = ns.World.Context()
  check(not (c2 and c2.detail == "Gankalot"), "a quest shared by a player never names them in Currently")
  UnitGUID, UnitName, UnitIsPlayer = keepGUID, keepName, keepIsPlayer
  ns.World.SetContext("none")

  -- A companion falling: the mood's saved reason names only a Social Diary friend.
  local keepName2, keepDead = UnitName, UnitIsDeadOrGhost
  UnitName = function(u) if u == "party1" then return "Brannoc" end return "Aldric" end
  UnitIsDeadOrGhost = function(u) return u == "party1" end
  ns.partyDead = nil
  event("UNIT_HEALTH", "party1")
  local why = ns.char.mood.why and ns.char.mood.why.sorrowful
  check(why and not why:find("Brannoc", 1, true), "a companion's fall is saved without their name: " .. tostring(why))
  UnitName, UnitIsDeadOrGhost = keepName2, keepDead
  ns.partyDead = nil

  -- Joining a guild is told once: "took up the colours of X", not then "Wears the colours of X".
  local keepCh, keepW, keepCo = ns.char.changes, ns.char.watched, ns.char.company and ns.char.company.guild
  ns.char.changes = { { kind = "joined", to = "The Silver Lanterns", t = NOW - 60 } }
  ns.char.watched = { guild = "The Silver Lanterns", guildRank = "Lamplighter" }
  if ns.char.company then ns.char.company.guild = { name = "The Silver Lanterns", since = NOW - 60, rank = "Lamplighter" } end
  ns.Compose.SourcesChanged(); ns.Compose.Refresh()
  local h = ns.Compose.History()
  local again
  for _, v in ipairs({ "Wears the colours of", "Belongs to the Silver", "Is one of the Silver", "Answers to the Silver",
    "member of the Silver", "lot with the Silver" }) do if h:find(v, 1, true) then again = v end end
  check(h:find("took up the colours of the Silver Lanterns", 1, true) and not again and h:find("Holds the rank of lamplighter", 1, true),
    "a guild just joined is told once, with the rank: " .. tostring(again))
  ns.char.changes, ns.char.watched = keepCh, keepW
  if ns.char.company then ns.char.company.guild = keepCo end
  ns.Compose.SourcesChanged(); ns.Compose.Refresh()

  -- Pronouns agree: a dwarf's feet are planted "like he means to stay".
  local found
  for _, l in ipairs(ns.Words.PHYS_RACE_BEARING and ns.Words.PHYS_RACE_BEARING.Dwarf or {}) do
    if l:find("like {they} mean") then found = l end
  end
  local any = false
  local function scan(t, depth)
    if depth > 6 then return end
    for _, v in pairs(t) do
      if type(v) == "string" and v:find("{they} mean ", 1, true) then any = v
      elseif type(v) == "table" then scan(v, depth + 1) end
    end
  end
  scan(ns.Words, 0)
  check(not any, "no \"{they} mean\" without {s}: " .. tostring(any))
end

-- Race and homeland (Sources/Kin.lua): every hook fed a fake event, for every race, with
-- RPG Dialogue, Social Diary and Chronicle all absent; then the writing it feeds.
do
  local C, K, KW = ns.Compose, ns.Sources.Kin, ns.Words.KIN
  local keep = { RPGDialogueCharDB, SocialDiaryCharDB, ChronicleCharDB, ns.char.deeds, ns.char.finds, ns.char.lastFight, ns.char.milestones }
  ns.char.deeds, ns.char.finds, ns.char.lastFight, ns.char.milestones = nil, nil, nil, nil
  local keepG = { UnitRace = UnitRace, UnitHealth = UnitHealth, InCombatLockdown = InCombatLockdown, C_Spell = C_Spell,
    GetFactionInfo = GetFactionInfo, GetNumFactions = GetNumFactions, UnitAffectingCombat = UnitAffectingCombat }
  local keepNow, keepState = NOW, { state.zone, state.sub, state.combat, state.resting }
  RPGDialogueCharDB, SocialDiaryCharDB, ChronicleCharDB = nil, nil, nil
  local function setRace(r) UnitRace = function() return r, r end end
  local function fresh(r, age)
    setRace(r)
    ns.char.kin = nil
    K.ResetClock(); K.ResetFoes()
    K.Store().since = NOW - (age or 30 * 86400)
  end
  local function at(zone, sub) state.zone, state.sub = zone, sub or zone; K.Tick() end
  local function kin() return ns.char.kin end
  local function refresh() ns.World.slow = nil; C.SourcesChanged(); C.Refresh(); return ns.cache end
  local function log(...) local t = { ... }; CombatLogGetCurrentEventInfo = function() return unpack(t, 1, 15) end; event("COMBAT_LOG_EVENT_UNFILTERED"); CombatLogGetCurrentEventInfo = nil end
  local ME = "Player-1-0001"
  state.resting, state.combat = false, false

  -- The clock: time in the capital, the home lands and abroad, by where the last look found them.
  fresh("Dwarf")
  at("Ironforge"); NOW = NOW + 30
  at("Loch Modan"); NOW = NOW + 30
  at("Wetlands"); NOW = NOW + 30
  at("Wetlands")
  check(kin().time.capital == 30 and kin().time.home == 30 and kin().time.abroad == 30,
    "time in the capital, the home lands and abroad: " .. tostring(kin().time.capital) .. "/" .. tostring(kin().time.home) .. "/" .. tostring(kin().time.abroad))
  check(kin().zones.Ironforge == 30 and kin().zones.Wetlands == 30, "time by zone")
  NOW = NOW + 3600; at("Wetlands")
  check(kin().time.abroad == 30, "a long gap (a loading screen, logged out) isn't counted")
  check(K.Kind("Ironforge", "Gnome") == "capital" and K.Kind("Dun Morogh", "Gnome") == "home" and K.Kind("Ironforge", "Goblin") == nil,
    "home by race (a gnome's is Ironforge; a goblin has none here)")

  -- A homecoming: back in the capital after days away, with a mood and the news.
  kin().lastCapital = NOW - 5 * 86400
  ns.char.mood.emo.homecoming = 0
  at("Ironforge")
  check(kin().visits.n == 1 and kin().visits.log[1].away == 5 * 86400, "back in the capital after five days is a homecoming")
  check((ns.char.mood.emo.homecoming or 0) > 0, "and it lifts the mood (homecoming)")
  NOW = NOW + 30; at("Ironforge")
  check(kin().visits.n == 1, "staying on in the capital is not another homecoming")
  local k = refresh()
  local lately = C.LatelyGlance()
  check(lately.TI == "Home Again" and lately.TX:find("Ironforge", 1, true) and lately.TX:find("five days", 1, true) and not lately.TX:find("{", 1, true),
    "Lately: home again: " .. tostring(lately.TX))
  local hist = C.History()
  local saidHome = false
  for _, l in ipairs(KW.EV.homecoming) do if hist:find((l:gsub("{capital}", "Ironforge"):gsub("{days}", "five days")), 1, true) then saidHome = true end end
  check(saidHome, "History: the homecoming is news")

  -- A place of their people: the first visit is news; one seen in the record's first hour isn't.
  at("Searing Gorge")
  check(kin().places["Searing Gorge"] and not kin().places["Searing Gorge"].before, "a place that matters to dwarves is recorded")
  refresh()
  check(C.History():find("Searing Gorge", 1, true), "History: the place is news")
  local ev = K.Events(ns.cache)
  local placeEv
  for _, e in ipairs(ev) do if e.key == "kin:place" then placeEv = e end end
  check(placeEv and placeEv.text:find("Searing Gorge", 1, true), "a History predicate for the place")
  local placeG
  for _, g in ipairs(K.Lately(ns.cache)) do if g.g.TI == KW.PLACE.angry.title then placeG = g end end
  check(placeG and placeG.g.TX:find("Searing Gorge", 1, true), "Lately: a place of their people, by its feeling")
  fresh("Dwarf", 60)
  at("Uldaman")
  check(kin().places.Uldaman.before, "a place seen in the record's first hour was known before it")
  check(#K.Lately(refresh()) == 0, "and isn't news")

  -- Racial gifts: counted, and noted when they mattered.
  C_Spell = { GetSpellName = function(id) return ({ [20594] = "Stoneform", [7744] = "Will of the Forsaken", [20589] = "Escape Artist",
    [20580] = "Shadowmeld", [20572] = "Blood Fury", [20554] = "Berserking", [20549] = "War Stomp", [20577] = "Cannibalize",
    [20600] = "Perception", [2481] = "Find Treasure", [133] = "Fireball" })[id] end }
  local function cast(id) event("UNIT_SPELLCAST_SUCCEEDED", "player", "cast", id) end
  fresh("Dwarf")
  cast(20594)
  check(kin().racials.Stoneform.n == 1 and kin().racials.Stoneform.m == 0, "Stoneform with nothing on them: counted, didn't matter")
  log(NOW, "SPELL_PERIODIC_DAMAGE", false, "Creature-0-1-0-1-1-1", "Venom Spider", 0, 0, ME, "Aldric", 0, 0, 744, "Poison", 8)
  cast(20594)
  check(kin().racials.Stoneform.m == 1 and kin().mattered[1].why == "poison", "Stoneform against a poison mattered")
  log(NOW, "SPELL_PERIODIC_DAMAGE", false, "Creature-0-1-0-1-1-1", "Gnoll", 0, 0, ME, "Aldric", 0, 0, 772, "Rend", 1)
  cast(20594)
  check(kin().mattered[#kin().mattered].why == "bleed", "and against a bleed")
  cast(2481); cast(133)
  check(kin().racials["Find Treasure"].n == 1 and not kin().racials.Fireball, "Find Treasure counted; other spells aren't racial")
  fresh("Scourge")
  log(NOW, "SPELL_AURA_APPLIED", false, "Creature-0-1-0-1-2-2", "Scarlet Chaplain", 0, 0, ME, "Aldric", 0, 0, 5782, "Fear", 32, "DEBUFF")
  cast(7744)
  check(kin().mattered[1] and kin().mattered[1].why == "fear", "Will of the Forsaken out of a fear mattered")
  NOW = NOW + 30; cast(7744)
  check(kin().racials["Will of the Forsaken"].m == 1, "but not half a minute after it")
  UnitHealth = function() return 50 end
  cast(20577)
  check(kin().mattered[#kin().mattered].why == "mend", "Cannibalize, hurt, to mend")
  fresh("Gnome")
  log(NOW, "SPELL_AURA_APPLIED", false, "Creature-0-1-0-1-3-3", "Frostmane Seer", 0, 0, ME, "Aldric", 0, 0, 122, "Frost Nova", 16, "DEBUFF")
  cast(20589)
  check(kin().mattered[1].why == "root", "Escape Artist out of a root")
  NOW = NOW + 10
  log(NOW, "SPELL_AURA_APPLIED", false, "Creature-0-1-0-1-3-3", "Trogg", 0, 0, ME, "Aldric", 0, 0, 1715, "Hamstring", 1, "DEBUFF")
  cast(20589)
  check(kin().mattered[#kin().mattered].why == "snare", "and out of a snare")
  fresh("NightElf")
  InCombatLockdown = function() return true end
  cast(20580)
  InCombatLockdown = keepG.InCombatLockdown
  check(kin().mattered[1].why == "fight", "Shadowmeld in the middle of a fight")
  for _, r in ipairs({ { "Orc", 20572, "Blood Fury" }, { "Troll", 20554, "Berserking" }, { "Tauren", 20549, "War Stomp" } }) do
    fresh(r[1])
    UnitHealth = function() return 20 end
    cast(r[2])
    UnitHealth = function() return 90 end
    cast(r[2])
    local rec = kin().racials[r[3]]
    check(rec and rec.n == 2 and rec.m == 1 and kin().mattered[1].why == "low", r[3] .. " with the fight going badly mattered; at full health it didn't")
    check(K.MatteredLine(kin().mattered[1]) ~= nil, r[3] .. " has its own History line")
  end
  UnitHealth = keepG.UnitHealth
  fresh("Human"); cast(20600)
  check(kin().racials.Perception.n == 1, "Perception counted")
  for _ = 1, 8 do kin().mattered[#kin().mattered + 1] = { t = NOW, name = "Perception", why = "x" } end
  K.Racial("Perception", "x")
  check(#kin().mattered <= 6, "the log of gifts that mattered stays short")

  -- Lately and Marks from a gift just used.
  fresh("Scourge")
  UnitHealth = function() return 40 end
  cast(20577)
  UnitHealth = keepG.UnitHealth
  k = refresh()
  local lt = K.Lately(ns.cache)
  check(#lt == 1 and lt[1].g.TI == "Cannibalize" and lt[1].g.TX:find("within the hour", 1, true) and not lt[1].g.TX:find("{", 1, true),
    "Lately: a gift that mattered: " .. tostring(lt[1] and lt[1].g.TX))
  local mk = K.Marks(ns.cache)
  check(mk[1] and mk[1].title == "Fed on the Fallen", "Marks: just fed on the fallen")
  NOW = NOW + 3600
  check(#K.Marks(refresh()) == 0, "and the mark fades")

  -- Speech: counted by language, only the player's own lines, never read.
  fresh("NightElf")
  GetDefaultLanguage = function() return "Common" end
  GetNumLanguages = function() return 2 end
  GetLanguageByIndex = function(i) return ({ "Common", "Darnassian" })[i] end
  K.Languages()
  for _ = 1, 15 do event("CHAT_MSG_SAY", "Ishnu-alah, friend", "Aldric", "Darnassian") end
  for _ = 1, 10 do event("CHAT_MSG_SAY", "Good morning", "Aldric-Forever", "Common") end
  for _ = 1, 9 do event("CHAT_MSG_SAY", "Hello there", "Brannoc", "Common") end
  event("CHAT_MSG_YELL", "For the alliance", "Aldric", "Common")
  check(kin().langs.Darnassian == 15 and kin().langs.Common == 11, "lines said aloud counted by language (yells too), only the player's own")
  local seen = false
  local function find(t, s) for kk, v in pairs(t) do if (type(v) == "string" and v:find(s, 1, true)) or kk == s or (type(v) == "table" and find(v, s)) then return true end end end
  check(not find(kin(), "Ishnu") and not find(kin(), "Brannoc") and not find(kin(), "morning"), "what was said, and who else spoke, is never kept")
  refresh()
  local phys = C.Physical()
  local voiced = false
  for _, l in ipairs(KW.VOICE.mostly) do if phys:find((ns.U.Pron(l):gsub("{tongue}", "Darnassian"):gsub("{common}", "Common"):gsub("^%l", string.upper)), 1, true) then voiced = true end end
  check(voiced, "Physical: the voice, by the tongue they speak most")
  for _ = 1, 60 do event("CHAT_MSG_SAY", "x", "Aldric", "Common") end
  check(K.Voice(refresh()) and K.Voice(ns.cache):find("now and then") or K.Voice(ns.cache):find("some of the time"), "mostly Common, some Darnassian: " .. tostring(K.Voice(ns.cache)))
  GetDefaultLanguage, GetNumLanguages, GetLanguageByIndex = nil, nil, nil

  -- The home city's regard, read outside a fight.
  fresh("Human")
  local calls = 0
  GetFactionInfo = function(i) calls = calls + 1; return keepG.GetFactionInfo(i) end
  state.combat = true
  event("UPDATE_FACTION")
  check(calls == 0 and not kin().rep, "standing isn't read in a fight")
  state.combat = false
  event("PLAYER_REGEN_ENABLED")
  check(kin().rep and kin().rep.id == 7, "but once it ends: revered with Stormwind")
  GetFactionInfo = keepG.GetFactionInfo
  k = refresh()
  local trusted = false
  for _, l in ipairs(K.Bearing(ns.cache, 4)) do if l:find("Stormwind", 1, true) then trusted = true end end
  check(trusted, "Personality: the trust of their home city")

  -- Old enemies of their people: by the creature's name, the player's and their pet's kills only.
  fresh("Scourge")
  for _ = 1, 30 do log(NOW, "PARTY_KILL", false, ME, "Aldric", 0, 0, "Creature-0-1-0-1-4-4", "Scarlet Zealot", 0, 0) end
  log(NOW, "PARTY_KILL", false, ME, "Aldric", 0, 0, "Creature-0-1-0-1-5-5", "Rotting Dead", 0, 0)
  log(NOW, "PARTY_KILL", false, ME, "Aldric", 0, 0, "Creature-0-1-0-1-6-6", "Young Wolf", 0, 0)
  log(NOW, "PARTY_KILL", false, "Player-1-0099", "Someone", 0, 0, "Creature-0-1-0-1-4-4", "Scarlet Zealot", 0, 0)
  log(NOW, "PARTY_KILL", false, ME, "Aldric", 0, 0, "Player-1-0042", "Scarlet Pretender", 0, 0)
  check(kin().foes.scarlet.n == 30 and kin().foes.scourge.n == 1 and ns.U.Count(kin().foes) == 2,
    "Scarlet Crusade and Scourge kills counted; a wolf, another's kill and a player aren't")
  check(K.FoeKind("Moonrage Whitescalp", "Scourge") == "worgen" and K.FoeKind("Son of Arugal", "Scourge") == "worgen", "worgen by name")
  for _, r in ipairs({ { "NightElf", "Xavian Rogue", "satyrs" }, { "Dwarf", "Dark Iron Dwarf", "darkiron" }, { "Gnome", "Leper Gnome", "leper" },
    { "Human", "Defias Trapper", "defias" }, { "Orc", "Burning Blade Cultist", "burningblade" }, { "Troll", "Voodoo Troll", "voodoo" },
    { "Tauren", "Kolkar Pack Runner", "centaur" } }) do
    K.ResetFoes()
    check(K.FoeKind(r[2], r[1]) == r[3], r[1] .. ": " .. r[2] .. " is an old enemy (" .. r[3] .. ")")
  end
  K.ResetFoes()
  check(K.FoeKind("Scarlet Zealot", "Tauren") == nil, "and only their own people's enemies")
  k = refresh()
  local foeLine = false
  for _, l in ipairs(K.Bearing(ns.cache, 4)) do if l:find("the Scarlet Crusade", 1, true) and not l:find("%d") then foeLine = true end end
  check(foeLine, "Personality: old enemies cut down")
  check(C.History():find("of the Scarlet Crusade", 1, true), "History: the old enemies, in the longer record")

  -- Long away from the capital: a fact, not a guess.
  fresh("Dwarf", 60 * 86400)
  at("Stranglethorn Vale")
  kin().lastCapital = NOW - 40 * 86400
  k = refresh()
  local bear = C.Bearing()
  check(bear:find("Ironforge in over a month", 1, true) or bear:find("Ironforge for over a month", 1, true),
    "Personality: hasn't been to Ironforge in over a month: " .. bear)
  kin().lastCapital = NOW - 3 * 86400
  refresh()
  check(not C.Bearing():find("over a month", 1, true), "and not when they were there this week")
  -- Mostly at home, or mostly abroad, from the hours kept.
  kin().time = { capital = 20 * 3600, home = 10 * 3600, abroad = 3600 }
  refresh()
  local homeLine = false
  for _, l in ipairs(KW.BOND.home) do if C.Bearing():find((ns.U.Pron(l):gsub("{home}", "Dun Morogh and Khaz Modan")), 1, true) then homeLine = true end end
  check(homeLine, "Personality: keeps close to home")
  kin().time = { capital = 3600, home = 0, abroad = 40 * 3600 }
  refresh()
  local abroadLine = false
  for _, l in ipairs(KW.BOND.abroad) do if C.Bearing():find((ns.U.Pron(l):gsub("{home}", "Dun Morogh and Khaz Modan")), 1, true) then abroadLine = true end end
  check(abroadLine, "Personality: lives abroad")
  -- Gone home many times.
  kin().visits = { n = 4, log = { { t = NOW - 30 * 86400, away = 4 * 86400 } } }
  refresh()
  check(C.History():find("Ironforge four times", 1, true), "History: gone home four times: in the longer record")

  -- Statistics: their own switches, TRP fields and tooltips.
  fresh("Dwarf")
  kin().time = { capital = 31 * 3600, home = 2 * 3600, abroad = 6 * 86400 }
  kin().racials = { Stoneform = { n = 41, m = 9, t = NOW - 86400 } }
  kin().foes = { darkiron = { n = 212, t = NOW }, troggs = { n = 40, t = NOW } }
  refresh()
  local st = C.Stats()
  check(st.kinhome == "33 hours at home, 6 days abroad", "statistic: time at home / abroad: " .. tostring(st.kinhome))
  check(st.racial == "Stoneform, 41 times, 9 of them against poison or bleeding", "statistic: racial ability most used: " .. tostring(st.racial))
  check(st.kinfoes == "212 Dark Iron dwarves, 40 troggs", "statistic: old enemies slain: " .. tostring(st.kinfoes))
  for _, key in ipairs({ "kinhome", "racial", "kinfoes" }) do
    check(ns.TRP.FIELDS["stat_" .. key] ~= nil and ns.db.fields["stat_" .. key] == true, "statistic " .. key .. " has its own switch, on by default")
    check(ns.UI.TIPS["fields.stat_" .. key] and ns.UI.TipFor({ path = { "fields", "stat_" .. key } }) == ns.UI.TIPS["fields.stat_" .. key], "statistic " .. key .. " has its own tooltip")
  end
  fresh("Goblin")
  refresh()
  st = C.Stats()
  check(st.kinhome == "None yet" and st.racial == "None yet" and st.kinfoes == "None yet", "nothing counted yet still says so")

  -- Every race: home, a homecoming in its own words, how its lands sit with it, its enemies.
  for _, r in ipairs({ "Human", "Dwarf", "Gnome", "NightElf", "Orc", "Troll", "Tauren", "Scourge" }) do
    fresh(r)
    local home = KW.HOME[r]
    at(home.capital)
    check(K.Kind(home.capital, r) == "capital" and kin().lastCapital == NOW, r .. ": the capital is home")
    kin().lastCapital = NOW - 9 * 86400
    NOW = NOW + 30; at(home.capital)
    local g
    for _, x in ipairs(K.Lately(refresh())) do if x.g.TI == "Home Again" then g = x.g end end
    check(g and g.TX:find(home.capital, 1, true) and g.TX:find("nine days", 1, true) and not g.TX:find("{", 1, true), r .. ": home again in its own words: " .. tostring(g and g.TX))
    check(#KW.HOMECOMING[r] >= 4, r .. ": four or more homecoming lines")
    local zones = 0
    for zone, lines in pairs(KW.HERE[r]) do zones = zones + 1; check(#lines >= 2, r .. ": " .. zone .. " has more than one way of saying it") end
    check(zones >= 4 and KW.HERE[r].abroad, r .. ": how home, the capital, old ground and a long road abroad sit with it")
    check(#(KW.FOES[r] or {}) >= 3, r .. ": its people's old enemies")
    local places = 0
    for _ in pairs(ns.Words.RACE_PLACES[r]) do places = places + 1 end
    check(places >= 6, r .. ": six or more places that matter to its people (" .. places .. ")")
    for _, p in pairs(ns.Words.RACE_PLACES[r]) do check(KW.PLACE[p[1]] ~= nil, r .. ": every place's feeling has Lately lines (" .. p[1] .. ")") end
    -- In a land of their own: Physical says how it sits with them.
    local here = KW.HERE[r][home.capital]
    state.zone, state.sub = home.capital, home.capital
    refresh()
    local said = false
    for _, l in ipairs(here or {}) do if C.Physical():find((ns.U.Pron(l):gsub("^%l", string.upper)), 1, true) then said = true end end
    check(said, r .. ": Physical, at home in " .. home.capital)
  end
  -- A long road far from home.
  fresh("Scourge", 60 * 86400)
  at("Stranglethorn Vale")
  kin().lastCapital = NOW - 20 * 86400
  refresh()
  local far = false
  for _, l in ipairs(KW.HERE.Scourge.abroad) do if C.Physical():find((ns.U.Pron(l):gsub("^%l", string.upper)), 1, true) then far = true end end
  check(far, "Physical: a long road far from home")

  -- Every line uses only the pronoun tags that read for anyone, and fills every tag it has.
  local badTag = {}
  local OK = { they = true, them = true, their = true, ["they've"] = true, ["they're"] = true, s = true, es = true,
    capital = true, days = true, place = true, home = true, span = true, times = true, faction = true, n = true, foe = true,
    list = true, tongue = true, common = true }
  local function lint(t, depth)
    for _, v in pairs(t) do
      if type(v) == "string" then
        for tag in v:gmatch("{([%a']+)}") do if not OK[tag] then badTag[#badTag + 1] = tag .. ": " .. v end end
      elseif type(v) == "table" and depth < 6 then lint(v, depth + 1) end
    end
  end
  lint(KW, 0)
  check(#badTag == 0, "Kin lines use only {they}/{them}/{their}/{they've}/{they're} + {s}/{es}: " .. table.concat(badTag, " | "))

  -- Bounded: zones and languages are capped.
  fresh("Human")
  for i = 1, K.CAP_ZONES do kin().zones["Zone" .. i] = i end
  at("Elwynn Forest"); NOW = NOW + 30; at("Elwynn Forest")
  check(ns.U.Count(kin().zones) == K.CAP_ZONES and kin().zones["Elwynn Forest"] == 30 and not kin().zones.Zone1,
    "zones stay bounded: a new one pushes out the least visited")
  for i = 1, 20 do K.Spoke("Lang" .. i) end
  check(ns.U.Count(kin().langs) <= K.CAP_LANGS, "languages stay bounded")

  UnitRace, UnitHealth, InCombatLockdown, C_Spell = keepG.UnitRace, keepG.UnitHealth, keepG.InCombatLockdown, keepG.C_Spell
  GetFactionInfo, GetNumFactions, UnitAffectingCombat = keepG.GetFactionInfo, keepG.GetNumFactions, keepG.UnitAffectingCombat
  RPGDialogueCharDB, SocialDiaryCharDB, ChronicleCharDB = keep[1], keep[2], keep[3]
  ns.char.deeds, ns.char.finds, ns.char.lastFight, ns.char.milestones = keep[4], keep[5], keep[6], keep[7]
  NOW = keepNow
  state.zone, state.sub, state.combat, state.resting = keepState[1], keepState[2], keepState[3], keepState[4]
  ns.char.kin = nil
  K.ResetClock(); K.ResetFoes()
  ns.World.slow = nil
  C.SourcesChanged(); C.Refresh()
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
    print("Ambition: " .. sh.glances.ambition.TX .. " | Motto: " .. tostring(sh.motto))
    print("\n-- Personality --\n" .. sh.bearing)
    print("\n-- History --\n" .. sh.history)
    print("\n-- Physical --\n" .. sh.physical)
  end
  -- The same with no other addon and nothing earned: what race and class alone give.
  local keep = { RPGDialogueCharDB, SocialDiaryCharDB, ChronicleCharDB, ns.char.deeds, ns.char.names, ns.char.milestones, ns.char.finds }
  RPGDialogueCharDB, SocialDiaryCharDB, ChronicleCharDB = nil, nil, nil
  ns.char.deeds, ns.char.names, ns.char.milestones, ns.char.finds = nil, nil, nil, nil
  local bare = { { "Dwarf", "PALADIN", "Alliance", 34 }, { "Scourge", "PRIEST", "Horde", 22 }, { "Troll", "SHAMAN", "Horde", 47 },
    { "Human", "WARLOCK", "Alliance", 15 }, { "Goblin", "ROGUE", "Horde", 28 }, { "NightElf", "DRUID", "Alliance", 52 },
    { "Orc", "DEATHKNIGHT", "Horde", 58 }, { "Gnome", "WARRIOR", "Alliance", 8 } }
  local lvl = UnitLevel
  for i, c in ipairs(bare) do
    UnitRace = function() return c[1], c[1] end
    UnitClass = function() return c[2], c[2] end
    UnitFactionGroup = function() return c[3] end
    UnitLevel = function() return c[4] end
    ns.char.seedName = "bare" .. i
    ns.World.slow = nil
    ns.Compose.SourcesChanged()
    local sh = ns.Compose.Sheet()
    print(("\n=== bare %s %s (%d): %s / %s | %s | %s ==="):format(c[1], c[2], c[4], sh.title, sh.fulltitle, tostring(sh.nickname), tostring(sh.motto)))
    for _, g in ipairs({ "mood", "lately", "company", "ambition", "marks" }) do print(g .. ": " .. sh.glances[g].TX) end
    print("\n-- Personality --\n" .. sh.bearing)
    print("\n-- History --\n" .. sh.history)
    print("\n-- Physical --\n" .. sh.physical)
  end
  -- Race and homeland (Sources/Kin.lua): a record a few weeks old, for four peoples.
  local kinSamples = {
    { "Scourge", "ROGUE", "Horde", "Tirisfal Glades", { ["Will of the Forsaken"] = { n = 34, m = 12 }, Cannibalize = { n = 50, m = 30 } },
      { scarlet = { n = 140 }, worgen = { n = 22 } }, { Orcish = 30, Gutterspeak = 5 }, { "Gutterspeak" }, { "Ruins of Lordaeron", "Stratholme" } },
    { "Dwarf", "HUNTER", "Alliance", "Stranglethorn Vale", { Stoneform = { n = 41, m = 9 } }, { darkiron = { n = 64 } },
      { Common = 12, Dwarvish = 30 }, { "Dwarvish" }, { "Uldaman", "Thandol Span" } },
    { "NightElf", "DRUID", "Alliance", "Darnassus", { Shadowmeld = { n = 80, m = 3 } }, { satyrs = { n = 31 } },
      { Common = 50 }, { "Darnassian" }, { "Moonglade", "Felwood" } },
    { "Tauren", "WARRIOR", "Horde", "Mulgore", { ["War Stomp"] = { n = 120, m = 18 } }, { centaur = { n = 210 }, quilboar = { n = 40 } },
      { Orcish = 20, Taurahe = 22 }, { "Taurahe" }, { "Red Rocks" } },
  }
  local keepZone = { state.zone, state.sub }
  for i, s in ipairs(kinSamples) do
    UnitRace = function() return s[1], s[1] end
    UnitClass = function() return s[2], s[2] end
    UnitFactionGroup = function() return s[3] end
    UnitLevel = function() return 44 end
    ns.char.seedName = "kin" .. i
    state.zone, state.sub = s[4], s[4]
    local racials = {}
    for name, r in pairs(s[5]) do racials[name] = { n = r.n, m = r.m, t = NOW - 2 * 86400 } end
    local foes = {}
    for key, f in pairs(s[6]) do foes[key] = { n = f.n, t = NOW - 86400 } end
    local known = { [1] = s[3] == "Horde" and "Orcish" or "Common", [2] = s[8][1] }
    local places = {}
    for k2, p in ipairs(s[9]) do places[p] = { t = NOW - k2 * 5 * 86400, last = NOW - 86400, n = 2 } end
    ns.char.kin = { since = NOW - 50 * 86400, time = { capital = 8 * 3600, home = 6 * 3600, abroad = 70 * 3600 }, zones = {},
      visits = { n = 3, log = { { t = NOW - 6 * 3600, away = 12 * 86400 } } }, racials = racials,
      mattered = { { t = NOW - 3 * 86400, name = next(s[5]), why = ({ Scourge = "fear", Dwarf = "poison", NightElf = "fight", Tauren = "low" })[s[1]] } },
      langs = s[7], known = known, default = known[1], places = places, foes = foes, lastCapital = NOW - 6 * 3600 }
    if i == 2 then ns.char.kin.lastCapital = NOW - 45 * 86400; ns.char.kin.visits.log = {} end
    ns.World.slow = nil
    ns.Compose.SourcesChanged()
    local sh = ns.Compose.Sheet()
    print(("\n=== kin %s %s in %s ==="):format(s[1], s[2], s[4]))
    for _, g in ipairs({ "lately", "marks" }) do print(g .. ": " .. sh.glances[g].TI .. ": " .. sh.glances[g].TX) end
    print("stats: " .. sh.stats.kinhome .. " | " .. sh.stats.racial .. " | " .. sh.stats.kinfoes)
    print("\n-- Personality --\n" .. sh.bearing)
    print("\n-- History --\n" .. sh.history)
    print("\n-- Physical --\n" .. sh.physical)
  end
  ns.char.kin = nil
  state.zone, state.sub = keepZone[1], keepZone[2]
  UnitLevel = lvl
  RPGDialogueCharDB, SocialDiaryCharDB, ChronicleCharDB = keep[1], keep[2], keep[3]
  ns.char.deeds, ns.char.names, ns.char.milestones, ns.char.finds = keep[4], keep[5], keep[6], keep[7]
  ns.Compose.SourcesChanged()
end

print(fails == 0 and "\nall passed" or ("\n" .. fails .. " failed"))
os.exit(fails == 0 and 0 or 1)
