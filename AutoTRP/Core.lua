-- Auto TRP: namespace, events, saved data, small helpers.
-- Auto TRP reads RPG Dialogue, Social Diary and Chronicle (never writes to them) and writes
-- only to the Total RP 3 profile it was given (see TRP.lua for the safety rules).
local addonName, ns = ...

ns.name = addonName
ns.VERSION = "0.21.0"

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------
local frame = CreateFrame("Frame")
local handlers = {}

-- Event payloads can carry Midnight-era "secret" values (combat, chat, units): testing or
-- comparing one taints the add-on, so handlers only ever see them as nil.
local function unsecret(v)
  local fn = _G.issecretvalue
  if v ~= nil and type(fn) == "function" then
    local ok, secret = pcall(fn, v)
    if not ok or secret then return nil end
  end
  return v
end
ns.Unsecret = unsecret

local function scrub(...)
  local n = select("#", ...)
  if n == 0 then return end
  local t = { ... }
  for i = 1, n do t[i] = unsecret(t[i]) end
  return unpack(t, 1, n)
end

function ns.On(event, fn)
  local list = handlers[event]
  if not list then
    if not pcall(frame.RegisterEvent, frame, event) then return false end
    list = {}
    handlers[event] = list
  end
  list[#list + 1] = fn
  return true
end

frame:SetScript("OnEvent", function(_, event, ...)
  local list = handlers[event]
  if not list then return end
  for i = 1, #list do
    local ok, err = pcall(list[i], event, scrub(...))
    if not ok then ns.Error(event, err) end
  end
end)

-- Unit events for one unit only (the game filters, so other units cost nothing).
function ns.OnUnit(event, unit, fn)
  local f = CreateFrame("Frame")
  if not pcall(f.RegisterUnitEvent, f, event, unit) then
    return ns.On(event, function(_, u, ...) if u == unit then fn(event, u, ...) end end) -- already scrubbed
  end
  f:SetScript("OnEvent", function(_, e, ...)
    local ok, err = pcall(fn, e, scrub(...))
    if not ok then ns.Error(e, err) end
  end)
  return true
end

-- Internal messages between our own files.
local listeners = {}
function ns.Listen(msg, fn)
  listeners[msg] = listeners[msg] or {}
  table.insert(listeners[msg], fn)
end
function ns.Fire(msg, ...)
  for _, fn in ipairs(listeners[msg] or {}) do
    local ok, err = pcall(fn, ...)
    if not ok then ns.Error(msg, err) end
  end
end

function ns.After(seconds, fn)
  if C_Timer and C_Timer.After then
    C_Timer.After(seconds, function()
      local ok, err = pcall(fn)
      if not ok then ns.Error("timer", err) end
    end)
  end
end

function ns.Ticker(seconds, fn)
  if C_Timer and C_Timer.NewTicker then
    return C_Timer.NewTicker(seconds, function()
      local ok, err = pcall(fn)
      if not ok then ns.Error("ticker", err) end
    end)
  end
end

---------------------------------------------------------------------------
-- Chat
---------------------------------------------------------------------------
local PREFIX = "|cffc8a165Auto TRP:|r "
function ns.Print(msg)
  if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. tostring(msg)) end
end

local reported = {}
function ns.Error(where, err)
  err = tostring(err)
  if reported[err] then return end
  reported[err] = true
  ns.Print("|cffff6060something went wrong (" .. tostring(where) .. "): " .. err .. "|r")
end

---------------------------------------------------------------------------
-- Saved data
---------------------------------------------------------------------------
ns.DEFAULTS = {
  enabled = true,
  -- What Auto TRP writes. Each one can be switched off; anything you edit yourself in
  -- Total RP 3 is left alone from then on (see TRP.lua).
  fields = {
    currently = true,   -- the "Currently" line: mood, what you're doing, where
    glances = true,     -- the five "At first glance" slots
    glance_mood = true, glance_lately = true, glance_company = true, glance_ambition = true, glance_marks = true,
    traits = true,      -- personality bars from your choices in RPG Dialogue
    bearing = true,     -- About > Personality: how you carry yourself, what you believe
    history = true,     -- About > History: origin, roads walked, people, deeds
    physical = true,    -- About > Physical: a sketch from your gear and build
    title = true,       -- short title from your alignment ("Lightsworn")
    fulltitle = true,   -- full title from your standing ("Respected in Goldshire")
    residence = true,   -- where your hearthstone is
    birthplace = true,  -- from your RPG Dialogue origin
    motto = true,       -- a saying taken from a story or quest chain you saw through
    nickname = true,    -- what people call you, for a story, quest chain or foe you saw through
    icon = true,        -- the profile icon: your nickname's, else your class crest
    relationship = true, -- relationship status, from a partner you named in Social Diary
    ooc = false,        -- an out-of-character note that the profile updates itself
    walkup = false,     -- "open to walk-ups" follows your mood (off by default)
    stats = true,       -- Statistics in Additional information (each one has its own switch too)
    stat_deaths = true, stat_lands = true, stat_road = true, stat_dungeons = true, stat_foes = true,
    stat_rares = true, stat_slain = true, stat_jobs = true, stat_wealth = true, stat_crafts = true,
    stat_standing = true, stat_names = true, stat_spell = true, stat_met = true, stat_books = true, stat_letters = true,
    stat_fish = true, stat_made = true, stat_gathered = true, stat_duels = true, stat_battles = true, stat_gold = true,
    stat_inns = true, stat_hit = true,
  },
  glanceSlots = { mood = 1, lately = 2, company = 3, ambition = 4, marks = 5 },
  sources = { rpgd = true, socialDiary = true, chronicle = true },
  diaryExcerpt = true,     -- quote your latest RPG Dialogue diary entry in History
  journalInProfile = true, -- without one, quote Auto TRP's own journal in History (and Lately, when nothing's fresher)
  richText = true,         -- colour quotes and item names on the About page
  chronicleGoals = true,   -- your open Chronicle goals as an ambition
  nameFriends = true,      -- name players you marked friend (or gave a relationship) in Social Diary
  currentlyEvery = 15,     -- seconds, at least, between rewrites of "Currently" and the glances
  quiet = false,           -- no chat lines when the profile is updated
  pauseOOC = false,        -- leave "Currently" and the glances alone while you're out of character
  reactPeople = true,      -- friends, foes and enemies you target move your mood
  reactPlaces = true,      -- places and spells that matter to your race and class
  moodNotes = true,        -- a quiet line in your own chat when your mood turns
  showBadge = true,        -- the small mood badge on screen
  -- badgePos = nil,       -- where the badge was dragged to
}

ns.CHAR_DEFAULTS = {
  profileID = nil,   -- the TRP3 profile Auto TRP may write to
  declined = false,  -- said "not now" to the first-time setup
  mood = { emo = {}, t = 0 },
  seen = {},         -- snapshots of the sources, to notice what changed
  -- names = nil,    -- earned name key -> when it was earned (nil until first looked at)
  -- chosenName = nil, -- the earned name to wear (/atrp name), else the best one
  -- casts = nil,    -- { since, n = { [spell name] = times cast } }, for the most cast spell
  -- deeds = nil,    -- Auto TRP's own record of quests turned in and masters felled (Sources/Deeds.lua)
  -- journal = nil,  -- the day-by-day journal: { days = raw logs, entries = written days } (Journal.lua)
}

local function fill(db, defaults)
  for k, v in pairs(defaults) do
    if db[k] == nil then
      if type(v) == "table" then db[k] = {}; fill(db[k], v) else db[k] = v end
    elseif type(v) == "table" and type(db[k]) == "table" then
      fill(db[k], v)
    end
  end
  return db
end

ns.On("ADDON_LOADED", function(_, loaded)
  if loaded ~= addonName then return end
  AutoTRPDB = fill(type(AutoTRPDB) == "table" and AutoTRPDB or {}, ns.DEFAULTS)
  -- 0.4.0: reactive by default (was 90 seconds).
  if AutoTRPDB.currentlyEvery == 90 then AutoTRPDB.currentlyEvery = 15 end
  AutoTRPCharDB = fill(type(AutoTRPCharDB) == "table" and AutoTRPCharDB or {}, ns.CHAR_DEFAULTS)
  ns.db, ns.char = AutoTRPDB, AutoTRPCharDB
  -- 0.5.0: who wrote what is kept per profile for the whole account (two characters can
  -- share a profile), and each character has its own glance slots.
  for _, name in ipairs({ "owned", "released" }) do
    ns.db[name] = ns.db[name] or {}
    for id, t in pairs(type(ns.char[name]) == "table" and ns.char[name] or {}) do
      ns.db[name][id] = ns.db[name][id] or t
    end
    ns.char[name] = nil
  end
  ns.char.backup = nil
  if type(ns.char.glanceSlots) ~= "table" then
    ns.char.glanceSlots = {}
    for k, v in pairs(ns.db.glanceSlots) do ns.char.glanceSlots[k] = v end
  end
  ns.Fire("INIT")
end)

ns.On("PLAYER_LOGIN", function() ns.Fire("LOGIN") end)

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------
local U = {}
ns.U = U

function U.Now()
  if GetServerTime then return GetServerTime() end
  return time()
end

-- Strips colour codes, textures and links.
function U.Plain(s)
  if type(s) ~= "string" then return nil end
  s = s:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|T.-|t", ""):gsub("|A.-|a", "")
  s = s:gsub("|H.-|h(.-)|h", "%1"):gsub("|n", " ")
  s = s:gsub("%s+", " "):gsub("^ ", ""):gsub(" $", "")
  if s == "" then return nil end
  return s
end

function U.Clamp(v, lo, hi)
  if v < lo then return lo elseif v > hi then return hi end
  return v
end

-- A small stable string hash (djb2), so wording picks don't flicker between updates.
function U.Hash(s)
  local h = 5381
  s = tostring(s)
  for i = 1, #s do h = (h * 33 + s:byte(i)) % 4294967296 end
  return h
end

-- Picks one entry of a list, stably for the same seed.
function U.Pick(list, seed)
  if type(list) ~= "table" or #list == 0 then return list end
  return list[(U.Hash(seed) % #list) + 1]
end

-- "a", "a and b", "a, b and c"
function U.Join(list)
  local n = #list
  if n == 0 then return "" end
  if n == 1 then return list[1] end
  return table.concat(list, ", ", 1, n - 1) .. " and " .. list[n]
end

function U.Cap(s)
  if type(s) ~= "string" then return s end
  return (s:gsub("^%l", string.upper))
end

-- "scarlet_crusade" -> "Scarlet Crusade"
function U.Humanize(id)
  if type(id) ~= "string" then return nil end
  local s = id:gsub("_", " ")
  return (s:gsub("(%a)([%w']*)", function(a, b) return a:upper() .. b end))
end

-- "The Deadmines" reads "the Deadmines" mid-sentence.
-- Lands whose names take "the" mid-sentence though the game leaves it off: "in the
-- Wetlands", never "in Wetlands".
U.TAKES_THE = { ["Wetlands"] = true, ["Eastern Plaguelands"] = true, ["Western Plaguelands"] = true, ["Badlands"] = true,
  ["Blasted Lands"] = true, ["Burning Steppes"] = true, ["Searing Gorge"] = true, ["Swamp of Sorrows"] = true }
function U.Mid(name)
  if type(name) ~= "string" then return name end
  if U.TAKES_THE[name] then return "the " .. name end
  return (name:gsub("^The ", "the "))
end

function U.Count(t)
  local n = 0
  if type(t) == "table" then for _ in pairs(t) do n = n + 1 end end
  return n
end

function U.Truncate(s, n)
  if type(s) ~= "string" or #s <= n then return s end
  local cut = s:sub(1, n)
  cut = cut:gsub("%s+%S*$", "")
  return cut .. "..."
end

function U.Plural(n, one, many)
  return n == 1 and one or (many or (one .. "s"))
end

-- Small numbers in words read better in prose.
local NUMBERS = { "once", "twice", "three times", "four times", "five times" }
function U.Times(n)
  return NUMBERS[n] or (U.Number(n) .. " times")
end

local COUNT_WORDS = { "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve",
  "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen" }
local TENS = { [2] = "twenty", [3] = "thirty", [4] = "forty", [5] = "fifty", [6] = "sixty", [7] = "seventy", [8] = "eighty", [9] = "ninety" }
-- Numbers under a hundred in words ("thirty-nine"); bigger ones as figures ("1,240").
function U.Number(n)
  if type(n) ~= "number" then return tostring(n) end
  if COUNT_WORDS[n] then return COUNT_WORDS[n] end
  if n >= 20 and n < 100 and n % 1 == 0 then
    local t, o = math.floor(n / 10), n % 10
    return TENS[t] .. (o > 0 and ("-" .. COUNT_WORDS[o]) or "")
  end
  local s = tostring(math.floor(n))
  while true do
    local k
    s, k = s:gsub("^(%d+)(%d%d%d)", "%1,%2")
    if k == 0 then break end
  end
  return s
end

-- "more than a hundred", "well over a thousand": a count as a person would say it.
function U.Roughly(n)
  if n >= 2000 then return "thousands of" end
  if n >= 1000 then return "well over a thousand" end
  if n >= 200 then return "hundreds of" end
  if n >= 100 then return "more than a hundred" end
  return U.Number(n)
end

U.Unsecret = unsecret

-- Every game API read goes through here, so no secret value ever reaches add-on logic.
function U.Call(fn, ...)
  if type(fn) ~= "function" then return nil end
  -- Up to eleven returns (the quest log and skill lines need that many).
  local ok, a, b, c, d, e, f, g, h, i, j, k = pcall(fn, ...)
  if ok then
    local S = U.Unsecret
    return S(a), S(b), S(c), S(d), S(e), S(f), S(g), S(h), S(i), S(j), S(k)
  end
  return nil
end

-- U.Call for an API that returns many values (the combat log, GetItemInfo): every value, unsecreted.
local function passAll(ok, ...)
  if not ok then return nil end
  if type(_G.issecretvalue) ~= "function" then return ... end
  return scrub(...)
end
function U.CallAll(fn, ...)
  if type(fn) ~= "function" then return nil end
  return passAll(pcall(fn, ...))
end

-- The player's pronouns for prose. Total RP 3's own pronoun field wins when it is set;
-- otherwise they/them, never a guess from the character's model.
function U.Pronouns()
  local p = ns.TRP and ns.TRP.CustomPronouns and ns.TRP.CustomPronouns()
  if type(p) == "string" then
    local l = p:lower()
    if l:find("^she") then return { sub = "she", obj = "her", pos = "her", be = "is", has = "has", does = "does", s = "s" } end
    if l:find("^he") then return { sub = "he", obj = "him", pos = "his", be = "is", has = "has", does = "does", s = "s" } end
  end
  return { sub = "they", obj = "them", pos = "their", be = "are", has = "have", does = "do", s = "" }
end

-- Gear and companions a line may name: {head} {shoulders} {chest} {cloak} {tabard}
-- {mainhand} {offhand} {ranged} {shield} {pet}, and {pouch} (a coin pouch, when they carry coin). They are filled with the real item's or
-- pet's name, and a line that names something the character doesn't have returns nil, so
-- the profile never mentions a hat that isn't on their head.
local GEAR_TAGS = { head = 1, shoulders = 3, chest = 5, cloak = 15, tabard = 19, mainhand = 16, offhand = 17, ranged = 18 }
function U.Backed(text, world)
  if type(text) ~= "string" or not text:find("{%l+}") then return text end
  local g = world and world.gear or {}
  local names = g.names or {}
  local missing = false
  local out = text:gsub("{(%l+)}", function(k)
    local v
    if GEAR_TAGS[k] then v = names[GEAR_TAGS[k]]
    elseif k == "shield" then v = g.offType == "Shields" and names[17] or nil
    elseif k == "pet" then v = world and world.pet
    elseif k == "pouch" then v = world and type(world.money) == "number" and world.money > 0 and "coin pouch" or nil
    else return nil end
    if not v then missing = true; return "" end
    return v
  end)
  if missing then return nil end
  return out
end

-- Only the lines in a list that the game backs up, filled in.
function U.BackedList(list, world)
  local out = {}
  for _, t in ipairs(type(list) == "table" and list or {}) do
    local b = U.Backed(t, world)
    if b then out[#out + 1] = b end
  end
  return out
end

-- Fills {they} {them} {their} {themselves} {they've} {they're} in word lists.
function U.Pron(text)
  if type(text) ~= "string" or not text:find("{") then return text end
  local p = U.Pronouns()
  local reflexive = p.sub == "they" and "themselves" or (p.obj .. "self")
  local map = {
    they = p.sub, them = p.obj, their = p.pos, themselves = reflexive,
    ["they've"] = p.sub == "they" and "they've" or (p.sub .. "'s"),
    ["they're"] = p.sub == "they" and "they're" or (p.sub .. "'s"),
    are = p.be, have = p.has,
    -- Verb endings after {they}: "{they} walk{s}" reads "they walk" or "she walks".
    s = p.s, es = p.s == "s" and "es" or "",
    ies = p.s == "s" and "ies" or "y",
  }
  return (text:gsub("{([%a']+)}", function(k) return map[k] or ("{" .. k .. "}") end))
end
