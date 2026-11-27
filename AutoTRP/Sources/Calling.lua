-- Auto TRP's record of a character's calling: the signature work of their class, as the game
-- shows it. A warrior's stances and charges and the shield walls raised on their last legs; a
-- rogue's pockets picked, locks sprung, poisons and vanishings; a hunter's beasts tamed (by
-- kind), tracking, traps and feigned deaths; a mage's portals (and how many went through),
-- conjured food handed over, Polymorphs and Blinks; a warlock's summonings, soulstones placed
-- on others, demons by kind and healthstones; a priest's, shaman's, paladin's and druid's
-- resurrections, shields, blessings, totems, forms and sacrifices. Kept per character in
-- AutoTRPCharDB.calling, read into ns.cache.calling, and written into Personality, History,
-- Lately, Marks and four statistics, only as far as the counts go.
--
-- Light by design: a spell is sorted once by its ID (its name read once, through U.Call); the
-- combat log looks up the sub-event in a small table and bails out unless the player cast it
-- on another player; nothing is scanned; every list is capped. Other players are never kept:
-- a resurrection is "someone", a stranger only a count.
local _, ns = ...

local U = ns.U
local W = ns.Words
local C = {}
ns.Sources = ns.Sources or {}
ns.Sources.Calling = C

C.CAP_BEASTS, C.CAP_KINDS, C.CAP_LOG, C.CAP_FORMS = 12, 12, 40, 12
C.SETTLE = 3600      -- what's first seen in the record's first hour isn't news
C.PINCH = 0.35       -- health below this is a pinch: a Vanish or Shield Wall then is a save
C.FORM_MAX = 6 * 3600 -- a stretch in one shape is counted up to this long (a client left open)

local function store()
  if not ns.char then return nil end
  local d = ns.char.calling
  if type(d) ~= "table" then d = {}; ns.char.calling = d end
  d.since = tonumber(d.since) or U.Now()
  for _, k in ipairs({ "n", "forms", "beasts", "demons", "totems", "tracks", "dests", "first", "log", "runs" }) do
    if type(d[k]) ~= "table" then d[k] = {} end
  end
  return d
end
C.Store = store

local function zone() return U.Plain(U.Call(GetRealZoneText)) end
local function settled(d) return U.Now() - (d.since or 0) > C.SETTLE end

local function bump(key, by)
  local d = store()
  if d then d.n[key] = (tonumber(d.n[key]) or 0) + (by or 1) end
  return d
end
C.Bump = bump

-- t[key] += n, at most cap keys (a new one pushes out the least counted).
local function bumpIn(t, key, n, cap)
  if t[key] then t[key] = t[key] + n; return end
  local count, lo, lk = 0, nil, nil
  for k, v in pairs(t) do count = count + 1; if not lo or v < lo then lo, lk = v, k end end
  if count >= cap then if lo and lo <= n then t[lk] = nil else return end end
  t[key] = n
end

-- A rare act worth telling later: kept with when and where, the newest 40.
local function note(kind, extra)
  local d = store()
  if not d then return end
  local e = { k = kind, t = U.Now(), zone = zone() }
  for k, v in pairs(extra or {}) do e[k] = v end
  table.insert(d.log, e)
  while #d.log > C.CAP_LOG do table.remove(d.log, 1) end
  return e
end

-- A run of the same small work (poisons, pockets, conjuring), for the Marks glance.
local function run(kind, n)
  local d = store()
  if not d then return end
  local r = d.runs[kind]
  local now = U.Now()
  if type(r) ~= "table" or now - (r.last or 0) > 900 then r = { n = 0, start = now }; d.runs[kind] = r end
  r.n, r.last = r.n + (n or 1), now
end

local function firstTime(key)
  local d = store()
  if not d or d.first[key] then return end
  d.first[key] = settled(d) and U.Now() or 1
end

local function health()
  local hp, max = U.Call(UnitHealth, "player"), U.Call(UnitHealthMax, "player")
  if type(hp) ~= "number" or type(max) ~= "number" or max <= 0 then return 1 end
  return hp / max
end

---------------------------------------------------------------------------
-- Shapes and stances: time in each.
---------------------------------------------------------------------------
local FORM_SPELLS = { ["Battle Stance"] = true, ["Defensive Stance"] = true, ["Berserker Stance"] = true,
  ["Bear Form"] = true, ["Dire Bear Form"] = true, ["Cat Form"] = true, ["Travel Form"] = true, ["Aquatic Form"] = true,
  ["Moonkin Form"] = true, ["Tree of Life"] = true, ["Ghost Wolf"] = true, ["Shadowform"] = true,
  ["Blood Presence"] = true, ["Frost Presence"] = true, ["Unholy Presence"] = true }
C.FORM_SPELLS = FORM_SPELLS

function C.CloseForm()
  local d = store()
  local f = d and d.form
  if type(f) ~= "table" or not f.name then return end
  local s = math.min(math.max(0, U.Now() - (f.at or U.Now())), C.FORM_MAX)
  if s > 0 then bumpIn(d.forms, f.name, s, C.CAP_FORMS) end
  d.form = nil
end
function C.Form(name)
  local d = store()
  name = U.Plain(name)
  if not d or not name then return end
  if type(d.form) == "table" and d.form.name == name then return end
  C.CloseForm()
  d.form = { name = name, at = U.Now() }
end

local lastIdx
function C.OnShapeshift()
  local idx = U.Call(GetShapeshiftForm)
  if idx == lastIdx then return end
  lastIdx = idx
  if type(idx) ~= "number" or idx == 0 then C.CloseForm(); return end
  -- Classic returns (icon, name, active, castable); later clients (icon, active, castable, spellID).
  local _, second, _, fourth = U.Call(GetShapeshiftFormInfo, idx)
  local name = type(second) == "string" and second or nil
  if not name and type(fourth) == "number" then name = U.Call(GetSpellInfo, fourth) end
  if ns.World and ns.World.Safe then name = ns.World.Safe(name) end
  if type(name) == "string" and FORM_SPELLS[name] then C.Form(name) end
end
ns.On("UPDATE_SHAPESHIFT_FORM", C.OnShapeshift)
ns.On("UPDATE_SHAPESHIFT_FORMS", C.OnShapeshift)
ns.On("PLAYER_LOGOUT", function() C.CloseForm() end)

---------------------------------------------------------------------------
-- The player's own spells, sorted once by name.
---------------------------------------------------------------------------
-- A spell that is a save when cast on low health.
local PINCH = { Vanish = "vanish", ["Feign Death"] = "feign", ["Shield Wall"] = "shieldwall", ["Last Stand"] = "laststand",
  Blink = "blink", ["Divine Shield"] = "bubble", Barkskin = "barkskin", Fade = "fade", ["Death Coil"] = "deathcoil",
  ["Icebound Fortitude"] = "icebound" }
local COUNT = { Charge = "charge", Intercept = "intercept", Taunt = "taunt", ["Pick Lock"] = "locks", Sap = "sap",
  ["Mind Control"] = "mindcontrol", ["Ritual of Summoning"] = "rituals", ["Divine Intervention"] = "intervention",
  ["Lay on Hands"] = "layonhands", ["Death Grip"] = "grip", ["Raise Dead"] = "raisedead", ["Death Gate"] = "deathgate",
  Reincarnation = "reincarnation", ["Tame Beast"] = "tames", ["Pick Pocket"] = "pickpocket", Innervate = "innervateCast" }
local DEMONS = { ["Summon Imp"] = "Imp", ["Summon Voidwalker"] = "Voidwalker", ["Summon Succubus"] = "Succubus",
  ["Summon Felhunter"] = "Felhunter", ["Summon Felguard"] = "Felguard", Inferno = "Infernal", ["Ritual of Doom"] = "Doomguard" }
local ELEMENTS = {
  earth = { "Stoneskin", "Earthbind", "Strength of Earth", "Stoneclaw", "Tremor", "Earth Elemental" },
  fire = { "Searing", "Fire Nova", "Magma", "Flametongue", "Frost Resistance", "Fire Elemental", "Totem of Wrath" },
  water = { "Healing Stream", "Mana Spring", "Mana Tide", "Poison Cleansing", "Disease Cleansing", "Fire Resistance" },
  air = { "Grounding", "Windfury", "Grace of Air", "Nature Resistance", "Windwall", "Sentry", "Tranquil Air", "Wrath of Air" },
}
local TOTEM_ELEMENT = {}
for el, list in pairs(ELEMENTS) do for _, n in ipairs(list) do TOTEM_ELEMENT[n .. " Totem"] = el end end
TOTEM_ELEMENT["Totem of Wrath"] = "fire"

local function sortSpell(name)
  if FORM_SPELLS[name] then return { form = name } end
  if PINCH[name] then return { pinch = PINCH[name] } end
  if COUNT[name] then return { k = COUNT[name] } end
  if DEMONS[name] then return { demon = DEMONS[name] } end
  if TOTEM_ELEMENT[name] then return { totem = TOTEM_ELEMENT[name] } end
  local dest = name:match("^Portal: (.+)$")
  if dest then return { portal = dest } end
  dest = name:match("^Teleport: (.+)$")
  if dest then return { teleport = dest } end
  if name:find("^Conjure Water") or name:find("^Conjure Food") or name:find("^Conjure Refreshment") then return { k = "conjured", run = "conjure" } end
  if name:find("^Polymorph") then return { k = "polymorph" } end
  if name:find("^Create Healthstone") then return { k = "healthstones" } end
  if name:find("^Track ") then return { track = name:sub(7) } end
  if name:find(" Trap$") then return { k = "traps" } end
  if name:find(" Poison") and (name:find("^Instant") or name:find("^Deadly") or name:find("^Crippling") or name:find("^Mind%-numbing")
    or name:find("^Wound") or name:find("^Anesthetic")) then return { k = "poisons", run = "poison" } end
  return false
end

local spellCache = {}
function C.SpellAction(spellID)
  local a = spellCache[spellID]
  if a ~= nil then return a end
  local name = (C_Spell and C_Spell.GetSpellName and U.Call(C_Spell.GetSpellName, spellID)) or U.Call(GetSpellInfo, spellID)
  if ns.World and ns.World.Safe then name = ns.World.Safe(name) end
  a = type(name) == "string" and sortSpell(name) or false
  spellCache[spellID] = a
  return a
end

local tradeSkillOpen = false
ns.On("TRADE_SKILL_SHOW", function() tradeSkillOpen = true end)
ns.On("TRADE_SKILL_CLOSE", function() tradeSkillOpen = false end)

local pocketAt, pocketLootAt, pendingBeast, lastReincarnation
function C.OnCast(spellID)
  if type(spellID) ~= "number" then return end
  local a = C.SpellAction(spellID)
  if not a then return end
  if a.form then C.Form(a.form); return end
  if a.pinch then
    local d = bump(a.pinch)
    if d and health() < C.PINCH then
      d.n[a.pinch .. "Save"] = (d.n[a.pinch .. "Save"] or 0) + 1
      note("save", { what = a.pinch })
    end
    return
  end
  if a.k == "poisons" and tradeSkillOpen then return end   -- mixed at the trade, not put on a blade
  local d = store()
  if not d then return end
  if a.demon then
    bump("demons"); bumpIn(d.demons, a.demon, 1, C.CAP_KINDS)
    if not d.first["demon:" .. a.demon] then
      firstTime("demon:" .. a.demon)
      if d.first["demon:" .. a.demon] > 1 then note("demon", { what = a.demon }) end
    end
  elseif a.totem then
    bump("totems"); bumpIn(d.totems, a.totem, 1, 4)
  elseif a.track then
    bump("tracking"); bumpIn(d.tracks, a.track, 1, C.CAP_KINDS)
  elseif a.portal or a.teleport then
    local others = 0
    if a.portal then
      local n = tonumber((U.Call(GetNumGroupMembers))) or 0
      others = math.max(0, math.min(n - 1, 39))
      bump("portals"); bump("portalOthers", others)
    else
      bump("teleports")
    end
    bumpIn(d.dests, a.portal or a.teleport, 1, C.CAP_KINDS)
    if a.portal then note("portal", { what = a.portal, others = others }) end
  elseif a.k then
    bump(a.k)
    if a.run then run(a.run) end
    if a.k == "pickpocket" then pocketAt = U.Now()
    elseif a.k == "rituals" then note("ritual"); run("ritual")
    elseif a.k == "intervention" then note("intervention")
    elseif a.k == "layonhands" then note("layonhands")
    elseif a.k == "reincarnation" then lastReincarnation = U.Now(); note("reincarnation")
    elseif a.k == "tames" then
      pendingBeast = { t = U.Now(), zone = zone() }
      table.insert(d.beasts, pendingBeast)
      while #d.beasts > C.CAP_BEASTS do table.remove(d.beasts, 1) end
      note("tame")
    end
  end
  if ns.Compose then ns.Compose.SourcesChanged() end
end
ns.OnUnit("UNIT_SPELLCAST_SUCCEEDED", "player", function(_, _, _, spellID) C.OnCast(spellID) end)

-- The beast just tamed, by what the game calls it and its family.
function C.OnPet()
  local b = pendingBeast
  if not b or U.Now() - b.t > 30 then return end
  if not U.Call(UnitExists, "pet") then return end
  local safe = ns.World and ns.World.Safe or function(v) return v end
  b.name = U.Plain(safe(U.Call(UnitName, "pet")))
  b.family = U.Plain(safe(U.Call(UnitCreatureFamily, "pet")))
  pendingBeast = nil
  local d = store()
  local last = d and d.log[#d.log]
  if last and last.k == "tame" and not last.family then last.family = b.family end
end
ns.OnUnit("UNIT_PET", "player", function() C.OnPet() end)

-- Pick Pocket: the loot window that opens right after it, and what came out of it.
ns.On("LOOT_OPENED", function()
  if pocketAt and U.Now() - pocketAt <= 3 then
    pocketAt, pocketLootAt = nil, U.Now()
    bump("pockets"); run("pockets")
  end
end)
ns.On("CHAT_MSG_MONEY", function(_, msg)
  if not pocketLootAt or U.Now() - pocketLootAt > 5 then return end
  local L = ns.Sources.Life
  local copper = L and L.ParseMoney and L.ParseMoney(ns.World and ns.World.Safe(msg) or msg) or 0
  if copper > 0 then bump("pocketCoin", copper) end
end)
ns.On("CHAT_MSG_LOOT", function(_, msg)
  if not pocketLootAt or U.Now() - pocketLootAt > 5 then return end
  msg = ns.World and ns.World.Safe(msg) or msg
  if type(msg) == "string" and msg:find("^You receive loot") then bump("pocketItems") end
end)

-- A trade: conjured food and drink, and healthstones, handed over. Who to is never kept.
ns.On("TRADE_ACCEPT_UPDATE", function(_, player, target)
  if player ~= 1 or target ~= 1 then return end
  local feeds, stones = 0, 0
  for i = 1, 6 do
    local name, _, count = U.Call(GetTradePlayerItemInfo, i)
    name = U.Plain(name)
    if name then
      if name:find("^Conjured") then feeds = feeds + (tonumber(count) or 1)
      elseif name:find("Healthstone$") then stones = stones + (tonumber(count) or 1) end
    end
  end
  if feeds > 0 then bump("feeds", feeds); run("feeds", feeds) end
  if stones > 0 then bump("stonesGiven", stones) end
end)

-- Reincarnation, from the ankh gone when coming back with nobody's help.
local ankhs, rezOffered
ns.On("PLAYER_DEAD", function()
  local _, class = U.Call(UnitClass, "player")
  if class == "SHAMAN" then ankhs = tonumber((U.Call(GetItemCount, 17030))) end
  rezOffered = nil
end)
ns.On("RESURRECT_REQUEST", function() rezOffered = U.Now() end)
function C.CameBack()
  if not ankhs or U.Call(UnitIsDeadOrGhost, "player") then return end
  local now = tonumber((U.Call(GetItemCount, 17030)))
  local before = ankhs
  ankhs = nil
  if not now or now >= before or (rezOffered and U.Now() - rezOffered < 120) then return end
  if lastReincarnation and U.Now() - lastReincarnation < 60 then return end
  lastReincarnation = U.Now()
  bump("reincarnation"); note("reincarnation")
  if ns.Compose then ns.Compose.SourcesChanged() end
end
ns.On("PLAYER_ALIVE", C.CameBack)
ns.On("PLAYER_UNGHOST", C.CameBack)

---------------------------------------------------------------------------
-- The combat log: the player's own buffs, resurrections and Lay on Hands on another player.
---------------------------------------------------------------------------
local PLAYER, OUTSIDER = 0x400, 0x8
local function has(flags, bit) return type(flags) == "number" and math.floor(flags / bit) % 2 == 1 end
local WANTED = { SPELL_AURA_APPLIED = 1, SPELL_RESURRECT = 2, SPELL_HEAL = 3 }
local BUFFS = { ["Power Word: Shield"] = "pws", ["Power Word: Fortitude"] = "fort", ["Prayer of Fortitude"] = "fort",
  Thorns = "thorns", Innervate = "innervate", ["Soulstone Resurrection"] = "soulstone", ["Mark of the Wild"] = "mark",
  ["Gift of the Wild"] = "mark", ["Arcane Intellect"] = "intellect", ["Arcane Brilliance"] = "intellect" }
local REZ = { Resurrection = "rez", Redemption = "redemption", ["Ancestral Spirit"] = "ancestral", Rebirth = "rebirth",
  ["Raise Ally"] = "raiseally" }
local me
function C.OnCombatLog(...)
  local _, sub, _, src, _, _, _, dest, _, destFlags, _, _, spell = ...
  local kind = WANTED[sub]
  if not kind then return end
  me = me or U.Call(UnitGUID, "player")
  if not me or src ~= me or dest == me or not has(destFlags, PLAYER) then return end
  local stranger = has(destFlags, OUTSIDER)
  local key
  if kind == 1 then
    key = BUFFS[spell]
    if not key and type(spell) == "string" and (spell:find("^Blessing of") or spell:find("^Greater Blessing of")) then key = "blessing" end
    if not key then return end
    if key == "soulstone" then note("soulstone") elseif key == "innervate" then note("innervate") end
  elseif kind == 2 then
    key = REZ[spell]
    if not key then return end
    note("raised", { what = key, stranger = stranger or nil })
    run("raised")
  else
    if spell ~= "Lay on Hands" then return end
    key = "lohOthers"
  end
  local d = bump(key)
  if d and stranger then d.n[key .. "Strangers"] = (d.n[key .. "Strangers"] or 0) + 1 end
end
ns.On("COMBAT_LOG_EVENT_UNFILTERED", function()
  local fn = _G.CombatLogGetCurrentEventInfo
  if type(fn) == "function" then C.OnCombatLog(fn()) end
end)
ns.On("PLAYER_ENTERING_WORLD", function() me = nil end)

ns.Listen("LOGIN", function()
  if not store() then return end
  lastIdx = nil
  local d = store()
  -- A stretch left open by a client that closed without logging out isn't counted.
  if type(d.form) == "table" then d.form = nil end
  C.OnShapeshift()
end)

---------------------------------------------------------------------------
-- Reading it back: a fresh table each time.
---------------------------------------------------------------------------
local function sortedKinds(t)
  local out = {}
  for k, v in pairs(t or {}) do out[#out + 1] = { name = k, n = v } end
  table.sort(out, function(a, b) if a.n ~= b.n then return a.n > b.n end return a.name < b.name end)
  return out
end

function C.Read()
  local d = store()
  if not d then return nil end
  local o = { since = d.since, first = d.first, log = d.log, runs = d.runs, beasts = d.beasts }
  o.n = setmetatable({}, { __index = function() return 0 end })
  for k, v in pairs(d.n) do o.n[k] = tonumber(v) or 0 end
  local forms = {}
  for k, v in pairs(d.forms) do forms[k] = v end
  if type(d.form) == "table" and d.form.name then
    forms[d.form.name] = (forms[d.form.name] or 0) + math.min(math.max(0, U.Now() - (d.form.at or U.Now())), C.FORM_MAX)
  end
  o.forms = sortedKinds(forms)
  o.formTotal = 0
  for _, f in ipairs(o.forms) do o.formTotal = o.formTotal + f.n end
  o.demons, o.totems, o.tracks, o.dests = sortedKinds(d.demons), sortedKinds(d.totems), sortedKinds(d.tracks), sortedKinds(d.dests)
  return o
end

---------------------------------------------------------------------------
-- Writing
---------------------------------------------------------------------------
local PRON = { they = true, them = true, their = true, themselves = true, ["they've"] = true, ["they're"] = true,
  s = true, es = true, ies = true, are = true, have = true }

local function seed(key) return (ns.char and ns.char.seedName or "") .. ":calling:" .. key end

-- The lines of a list whose tags can all be filled, filled; one of them picked.
local function fill(list, vars, key, which, avoid)
  local ok = {}
  for _, line in ipairs(type(list) == "table" and list or {}) do
   if not (avoid and line:match("^(%a+)") == avoid) then
    local missing = false
    local out = line:gsub("{([%a']+)}", function(k)
      if PRON[k] then return nil end
      local v = vars and vars[k]
      if v == nil then missing = true; return "" end
      return v
    end)
    if not missing then ok[#ok + 1] = out end
   end
  end
  if #ok == 0 and avoid then return fill(list, vars, key, which) end
  if #ok == 0 then return nil end
  return U.Pick(ok, seed(key .. ":" .. tostring(which or "")))
end
C.Fill = fill

-- "four", "more than a hundred"; "twice", "hundreds of times".
local function count(n) return n >= 100 and U.Roughly(n) or U.Number(n) end
local function times(n) return n >= 100 and (U.Roughly(n) .. " times") or U.Times(n) end
local function hours(s)
  local h = math.floor(s / 3600)
  if h >= 1 then return count(h) .. " " .. U.Plural(h, "hour") end
  local m = math.max(1, math.floor(s / 60))
  return count(m) .. " " .. U.Plural(m, "minute")
end
C.Hours = hours
local function article(word)
  if type(word) ~= "string" then return word end
  return (word:find("^[AEIOUaeiou]") and "an " or "a ") .. word
end
local function plural(word)
  if ns.Compose and ns.Compose.Plural then return ns.Compose.Plural(word) end
  return word .. "s"
end
local function within(t, s) return type(t) == "number" and U.Now() - t <= s end

-- Druid shapes and warrior stances, for the words that go with them.
local FORM_KEY = { ["Bear Form"] = "bear", ["Dire Bear Form"] = "bear", ["Cat Form"] = "cat", ["Travel Form"] = "travel",
  ["Aquatic Form"] = "aquatic", ["Moonkin Form"] = "moonkin", ["Battle Stance"] = "battle", ["Defensive Stance"] = "defensive",
  ["Berserker Stance"] = "berserker" }
local function formShares(o)
  local by, order = {}, {}
  for _, f in ipairs(o.forms) do
    local k = FORM_KEY[f.name] or f.name
    if not by[k] then by[k] = { key = k, name = f.name, n = 0 }; order[#order + 1] = by[k] end
    by[k].n = by[k].n + f.n
  end
  table.sort(order, function(a, b) if a.n ~= b.n then return a.n > b.n end return a.key < b.key end)
  return order
end

local function beastKinds(o, k)
  local seen, kinds = {}, {}
  for i = #o.beasts, 1, -1 do
    local f = o.beasts[i].family
    if f and not seen[f] and #kinds < (k or 2) then seen[f] = true; kinds[#kinds + 1] = plural(f:lower()) end
  end
  return #kinds > 0 and U.Join(kinds) or nil
end
local function demonWord(name) return name and article(name:lower()) end
local function trackWord(name)
  if not name then return nil end
  local w = name:lower()
  if w == "undead" then return "the undead" end
  if w == "hidden" then return "the hidden" end
  return w
end
-- Whose work each kind of act in the log is, so a priest who once cast a portal scroll
-- isn't told as a mage.
local KIND_CLASS = { tame = { HUNTER = true }, portal = { MAGE = true }, ritual = { WARLOCK = true },
  soulstone = { WARLOCK = true }, demon = { WARLOCK = true }, intervention = { PALADIN = true }, layonhands = { PALADIN = true },
  reincarnation = { SHAMAN = true }, innervate = { DRUID = true },
  raised = { PRIEST = true, SHAMAN = true, PALADIN = true, DRUID = true, DEATHKNIGHT = true } }
local SAVE_CLASS = { vanish = "ROGUE", feign = "HUNTER", shieldwall = "WARRIOR", laststand = "WARRIOR", blink = "MAGE",
  bubble = "PALADIN", barkskin = "DRUID", fade = "PRIEST", deathcoil = "WARLOCK", icebound = "DEATHKNIGHT" }
local function ours(e, class)
  if e.k == "save" then return SAVE_CLASS[e.what or ""] == class end
  local by = KIND_CLASS[e.k]
  return by ~= nil and by[class or ""] == true
end
C.Ours = ours

local function raisedTotal(n) return n.rez + n.redemption + n.ancestral + n.rebirth + n.raiseally end
local function raisedStrangers(n)
  return n.rezStrangers + n.redemptionStrangers + n.ancestralStrangers + n.rebirthStrangers + n.raiseallyStrangers
end

-- Personality: how they practise their calling. { score, key, text } for Compose.Habits,
-- the strongest two at most.
function C.Habits(c)
  local o, world = c and c.calling, c and c.world or {}
  if not o then return {} end
  local n, class = o.n, world.class
  local H = W.CALLING.HABIT
  local cands = {}
  -- strength: how far past its threshold the count is.
  local function add(strength, key, vars, pool)
    if strength < 1 then return end
    local text = fill(pool or H[key], vars or {}, "habit:" .. key)
    if text then cands[#cands + 1] = { strength = strength, key = key, text = text, pool = pool or H[key], vars = vars or {} } end
  end
  local function v(x) return { n = count(x), times = times(x) } end
  local shares = formShares(o)
  local topForm = shares[1]
  if class == "WARRIOR" then
    if topForm and o.formTotal >= 5 * 3600 and topForm.n / o.formTotal >= 0.5 and H["stance_" .. topForm.key] then
      add(1 + o.formTotal / (20 * 3600), "stance_" .. topForm.key)
    end
    add((n.charge + n.intercept) / 100, "charges")
    add((n.shieldwallSave + n.laststandSave) / 10, "laststand")
  elseif class == "ROGUE" then
    add(n.pockets / 50, "pockets"); add(n.locks / 25, "locks"); add(n.vanishSave / 5, "vanish"); add(n.poisons / 50, "poisons")
  elseif class == "HUNTER" then
    local kinds = beastKinds(o)
    add(n.tames / 4, "tamer", { n = count(n.tames), kinds = kinds })
    local b = o.beasts[#o.beasts]
    if n.tames == 1 and b and b.name and world.pet == b.name and U.Now() - (b.t or U.Now()) >= 7 * 86400 then add(1.5, "loyal") end
    add(n.feignSave / 5, "feign"); add(n.traps / 50, "traps")
    local tr = o.tracks[1]
    if tr then add(tr.n / 50, "tracking", { track = trackWord(tr.name) }) end
  elseif class == "MAGE" then
    add(n.portals / 10, "portals", v(n.portals)); add(n.feeds / 50, "feeds", v(n.feeds))
    if n.feeds < 50 then add(n.conjured / 100, "conjures") end
    add(n.polymorph / 50, "polymorph"); add(n.blinkSave / 20, "blink")
  elseif class == "WARLOCK" then
    add(n.rituals / 10, "summoner", v(n.rituals)); add(n.soulstone / 5, "soulstone", v(n.soulstone))
    local dm = o.demons[1]
    if dm then add(dm.n / 20, "demon", { demon = demonWord(dm.name) }) end
    add(n.healthstones / 20, "healthstones")
  elseif class == "PRIEST" then
    local strangers = raisedStrangers(n)
    add(strangers / 5, "rez_strangers", { strangers = count(strangers) })
    if strangers < 5 then add(raisedTotal(n) / 20, "rez", v(raisedTotal(n))) end
    add(n.pws / 100, "shields", v(n.pws))
    if n.fortStrangers >= 30 then add(n.fort / 100, "fortitude", v(n.fort)) end
    add(n.mindcontrol / 20, "mindcontrol", v(n.mindcontrol))
  elseif class == "SHAMAN" then
    local top = o.totems[1]
    if top and n.totems >= 100 then
      local balanced = #o.totems == 4 and o.totems[4].n / n.totems >= 0.15
      if balanced and n.totems >= 300 then add(n.totems / 300, "totem_balance")
      elseif top.n / n.totems >= 0.4 then add(n.totems / 100, "totem_" .. top.name) end
    end
    for _, f in ipairs(o.forms) do
      if f.name == "Ghost Wolf" then add(f.n / (10 * 3600), "ghostwolf", { hours = hours(f.n) }) end
    end
    add(n.reincarnation / 3, "reincarnation", v(n.reincarnation)); add(n.ancestral / 20, "ancestral", v(n.ancestral))
  elseif class == "PALADIN" then
    local pool = {}
    for _, l in ipairs(H.blessings) do if n.blessingStrangers >= 30 or not l:find("stranger") then pool[#pool + 1] = l end end
    add(n.blessing / 200, "blessings", v(n.blessing), pool)
    add(n.redemption / 20, "redemption", v(n.redemption)); add(n.lohOthers / 3, "layonhands", v(n.lohOthers))
    if n.intervention >= 1 then add(1.2 + n.intervention / 5, "intervention", v(n.intervention)) end
  elseif class == "DRUID" then
    if topForm and o.formTotal >= 10 * 3600 and topForm.n / o.formTotal >= 0.5 and H["form_" .. topForm.key] then
      add(1 + o.formTotal / (40 * 3600), "form_" .. topForm.key)
    end
    add(n.rebirth / 5, "rebirth", v(n.rebirth)); add(n.innervate / 20, "innervate", v(n.innervate))
    local pool = {}
    for _, l in ipairs(H.thorns) do if n.thornsStrangers >= 20 or not l:find("stranger") then pool[#pool + 1] = l end end
    add(n.thorns / 100, "thorns", v(n.thorns), pool)
  elseif class == "DEATHKNIGHT" then
    add(n.grip / 100, "grip", v(n.grip)); add(n.raisedead / 50, "raisedead", v(n.raisedead))
    if topForm and topForm.n >= 10 * 3600 then add(topForm.n / (20 * 3600), "form", { form = topForm.name }) end
  end
  table.sort(cands, function(a, b) if a.strength ~= b.strength then return a.strength > b.strength end return a.key < b.key end)
  local out = {}
  for i = 1, math.min(2, #cands) do
    local cd = cands[i]
    local text = cd.text
    -- The second doesn't open the way the first does ("Would rather..., Would rather...").
    if i == 2 then text = fill(cd.pool, cd.vars, "habit:" .. cd.key, nil, out[1].text:match("^(%a+)")) or text end
    out[i] = { score = i == 1 and 2.6 or 1.9, key = "calling:" .. cd.key, text = text }
  end
  return out
end

-- History, the news: { t, rank, text, key } for the last three weeks (recent(t) says).
function C.Events(c, recent)
  local o, world = c and c.calling, c and c.world or {}
  if not o then return {} end
  local E = W.CALLING.EVENT
  local out = {}
  local function add(t, rank, list, vars, key)
    local text = fill(list, vars or {}, "ev:" .. key, t)
    if text then out[#out + 1] = { t = t, rank = rank, text = text, key = "calling:" .. key } end
  end
  local last, cnt, strangers = {}, {}, 0
  for _, e in ipairs(o.log) do
    if recent(e.t) and ours(e, world.class) then
      last[e.k] = e
      cnt[e.k] = (cnt[e.k] or 0) + 1
      if e.k == "raised" and e.stranger then strangers = strangers + 1 end
    end
  end
  local e = last.tame
  if e then
    local beast = e.family and article(e.family:lower()) or "a wild beast"
    add(e.t, 4, e.zone and E.tame or E.tame_nozone, { beast = beast, zone = e.zone and U.Mid(e.zone) }, "tame")
  end
  if last.portal then
    if cnt.portal == 1 then add(last.portal.t, 6, E.portal, { dest = last.portal.what }, "portal")
    else add(last.portal.t, 6, E.portals, { n = count(cnt.portal), times = times(cnt.portal) }, "portal") end
  end
  if last.ritual then
    add(last.ritual.t, 6, cnt.ritual == 1 and E.ritual or E.rituals, { times = times(cnt.ritual) }, "ritual")
  end
  if last.soulstone then add(last.soulstone.t, 7, E.soulstone, nil, "soulstone") end
  if last.raised then
    local k = cnt.raised
    if strangers >= 2 then add(last.raised.t, 5, E.raised_strangers, { n = count(strangers) }, "raised")
    elseif k >= 2 then add(last.raised.t, 5, E.raised_many, { n = count(k) }, "raised")
    elseif last.raised.what == "rebirth" then add(last.raised.t, 5, E.rebirth, nil, "raised")
    else add(last.raised.t, 5, E.raised, nil, "raised") end
  end
  for _, k in ipairs({ "intervention", "layonhands", "reincarnation" }) do
    if last[k] then add(last[k].t, k == "intervention" and 3 or 4, E[k], nil, k) end
  end
  if last.save and E[last.save.what] then add(last.save.t, 6, E[last.save.what], nil, "save") end
  if last.demon then add(last.demon.t, 5, E.demon, { demon = demonWord(last.demon.what) }, "demon") end
  if (cnt.innervate or 0) >= 3 then add(last.innervate.t, 8, E.innervate, { times = times(cnt.innervate) }, "innervate") end
  table.sort(out, function(a, b) if a.rank ~= b.rank then return a.rank < b.rank end return a.t > b.t end)
  for i = #out, 4, -1 do out[i] = nil end
  return out
end

-- History, the older record: up to two present-perfect phrases, for after "{they've}".
function C.Older(c, toldRecent)
  local o, world = c and c.calling, c and c.world or {}
  if not o then return {} end
  toldRecent = toldRecent or {}
  local n, class = o.n, world.class
  local O = W.CALLING.OLDER
  local cands = {}
  local function add(strength, key, vars, told)
    if strength < 1 or (told and toldRecent["calling:" .. told]) then return end
    local text = fill(O[key], vars, "older:" .. key)
    if text then cands[#cands + 1] = { strength = strength, text = text, key = key } end
  end
  local function v(x) return { n = count(x), times = times(x) } end
  local shares = formShares(o)
  local function formHours(threshold)
    local f = shares[1]
    if f and f.n >= threshold then add(f.n / threshold, "form_hours", { hours = hours(f.n), form = f.name }) end
  end
  if class == "WARRIOR" then
    add((n.charge + n.intercept) / 50, "charges", v(n.charge + n.intercept))
    add((n.shieldwallSave + n.laststandSave) / 5, "shieldwall", v(n.shieldwallSave + n.laststandSave), "save")
    formHours(20 * 3600)
  elseif class == "ROGUE" then
    add(n.pockets / 25, "pockets", v(n.pockets)); add(n.locks / 10, "locks", v(n.locks)); add(n.vanishSave / 5, "vanish", v(n.vanishSave), "save")
  elseif class == "HUNTER" then
    local fams, latest = {}, nil
    for _, b in ipairs(o.beasts) do if b.family then fams[b.family] = true; latest = b.family end end
    local kn = U.Count(fams)
    if latest then
      add(n.tames / 2, "tames", { n = count(n.tames), kindsN = kn >= 2 and count(kn) or nil, latest = article(latest:lower()) })
    end
    add(n.feignSave / 5, "feign", v(n.feignSave), "save")
  elseif class == "MAGE" then
    if n.portalOthers >= 10 then add(n.portals / 10, "portals_others", { n = count(n.portals), others = count(n.portalOthers) }, "portal")
    else add(n.portals / 10, "portals", v(n.portals), "portal") end
    add(n.feeds / 20, "feeds", v(n.feeds)); add(n.polymorph / 25, "polymorph", v(n.polymorph))
  elseif class == "WARLOCK" then
    add(n.rituals / 5, "rituals", v(n.rituals), "ritual"); add(n.soulstone / 3, "soulstones", v(n.soulstone), "soulstone")
    add(n.healthstones / 10, "healthstones", { n = count(n.healthstones), given = n.stonesGiven >= 5 and count(n.stonesGiven) or nil })
  elseif class == "PRIEST" then
    local r, s = raisedTotal(n), raisedStrangers(n)
    if s >= 3 then add(r / 10, "raised_strangers", { n = count(r), strangers = count(s) }, "raised")
    else add(r / 10, "raised", v(r), "raised") end
    add(n.pws / 100, "shields", v(n.pws)); add(n.mindcontrol / 10, "mindcontrol", v(n.mindcontrol))
  elseif class == "SHAMAN" then
    add(n.totems / 200, "totems", v(n.totems)); add(n.reincarnation / 2, "reincarnation", v(n.reincarnation), "reincarnation")
    add(n.ancestral / 10, "raised", v(n.ancestral), "raised")
  elseif class == "PALADIN" then
    add(n.blessing / 200, "blessings", v(n.blessing)); add(n.redemption / 10, "raised", v(n.redemption), "raised")
    if n.intervention >= 1 then add(1.5, "intervention", v(n.intervention), "intervention") end
  elseif class == "DRUID" then
    add(n.rebirth / 3, "rebirth", v(n.rebirth), "raised"); add(n.innervate / 10, "innervate", v(n.innervate), "innervate")
    formHours(20 * 3600)
  elseif class == "DEATHKNIGHT" then
    add(n.grip / 50, "grip", v(n.grip)); formHours(20 * 3600)
  end
  table.sort(cands, function(a, b) if a.strength ~= b.strength then return a.strength > b.strength end return a.key < b.key end)
  local out = {}
  for i = 1, math.min(2, #cands) do out[i] = cands[i].text end
  return out
end

-- Lately: a recent act of the calling, as { t, prio, g = { TI, TX, IC } }.
function C.Lately(c)
  local o, world = c and c.calling, c and c.world or {}
  if not o then return {} end
  local LA = W.CALLING.LATELY
  local out = {}
  local function add(t, prio, key, vars, entry)
    local spec = LA[entry or key]
    local text = spec and fill(spec[3], vars or {}, "lately:" .. key, t)
    if text then out[#out + 1] = { t = t, prio = prio, g = { TI = spec[1], IC = spec[2], TX = U.Pron(text) } } end
  end
  local last, hourRaised = {}, 0
  for _, e in ipairs(o.log) do
    if ours(e, world.class) then
      last[e.k] = e
      if e.k == "raised" and within(e.t, 3600) then hourRaised = hourRaised + 1 end
    end
  end
  local e = last.tame
  if e and within(e.t, 2 * 86400) and e.zone then
    add(e.t, 2, "tame", { beast = e.family and article(e.family:lower()) or "a wild beast", zone = U.Mid(e.zone) })
  end
  e = last.portal
  if e and within(e.t, 3600) and (e.others or 0) > 0 then add(e.t, 1, "portal", { dest = e.what }) end
  if last.ritual and within(last.ritual.t, 3600) then add(last.ritual.t, 1, "ritual") end
  if last.soulstone and within(last.soulstone.t, 3600) then add(last.soulstone.t, 1, "soulstone") end
  if hourRaised >= 2 then add(last.raised.t, 1, "raised", { n = count(hourRaised) })
  elseif hourRaised == 1 then add(last.raised.t, 1, "raised_one") end
  if last.intervention and within(last.intervention.t, 86400) then add(last.intervention.t, 2, "sacrifice") end
  if last.layonhands and within(last.layonhands.t, 86400) then add(last.layonhands.t, 2, "layonhands") end
  if last.reincarnation and within(last.reincarnation.t, 3 * 3600) then add(last.reincarnation.t, 2, "reincarnation") end
  e = last.save
  if e and within(e.t, 1800) and W.CALLING.ESCAPE[e.what] then add(e.t, 2, "escape", { escape = W.CALLING.ESCAPE[e.what] }) end
  local fr = o.runs.feeds
  if fr and within(fr.last, 1800) and (fr.n or 0) >= 5 then add(fr.last, 0, "feeds", { n = count(fr.n) }) end
  return out
end

-- Marks: what the work has just left on them, as { prio, title, text, icon }.
function C.Marks(c)
  local o, world = c and c.calling, c and c.world or {}
  if not o or world.combat or world.dead then return {} end
  local M = W.CALLING.MARK
  local out = {}
  local function add(prio, key, t)
    local spec = M[key]
    local text = spec and fill(spec[3], {}, "mark:" .. key, t)
    if text then out[#out + 1] = { prio = prio, title = spec[1], text = U.Pron(text), icon = spec[2] } end
  end
  local r = o.runs
  local class = world.class
  if class ~= "ROGUE" then r = { raised = r.raised, conjure = class == "MAGE" and r.conjure or nil, ritual = class == "WARLOCK" and r.ritual or nil } end
  if not KIND_CLASS.raised[class or ""] then r.raised = nil end
  if r.poison and within(r.poison.last, 600) then add(4.5, "poison", r.poison.start) end
  if r.pockets and within(r.pockets.last, 900) and r.pockets.n >= 3 then add(4.5, "pockets", r.pockets.start) end
  if r.conjure and within(r.conjure.last, 600) and r.conjure.n >= 2 then add(4.3, "conjure", r.conjure.start) end
  if r.ritual and within(r.ritual.last, 600) then add(4.4, "ritual", r.ritual.start) end
  if r.raised and within(r.raised.last, 1800) and r.raised.n >= 3 then add(4.4, "raised", r.raised.start) end
  local save
  for i = #o.log, 1, -1 do if o.log[i].k == "save" then save = o.log[i]; break end end
  if save and class == "WARRIOR" and (save.what == "shieldwall" or save.what == "laststand") and within(save.t, 600) then
    add(5.8, "stand", save.t)
  end
  return out
end

---------------------------------------------------------------------------
-- Statistics: four entries whose content is the class's own. Nil where a class has none.
---------------------------------------------------------------------------
C.STATS = {
  { key = "calling", label = "Calling", icon = "INV_Misc_Book_07" },
  { key = "escapes", label = "Narrow escapes", icon = "Ability_Vanish" },
  { key = "given", label = "Given to others", icon = "Spell_Holy_Resurrection" },
  { key = "forms", label = "Stances and forms", icon = "Ability_Warrior_DefensiveStance" },
}
local SPEC = {
  WARRIOR = { calling = { "charge", "intercept", "taunt" }, escapes = { "shieldwall", "laststand" }, forms = true },
  ROGUE = { calling = { "pockets", "locks", "poisons", "sap" }, escapes = { "vanish" } },
  HUNTER = { calling = { "tames", "traps" }, escapes = { "feign" } },
  MAGE = { calling = { "portals", "teleports", "polymorph" }, escapes = { "blink" }, given = { "portalOthers", "feeds", "intellect" } },
  WARLOCK = { calling = { "rituals", "healthstones", "demons" }, escapes = { "deathcoil" }, given = { "soulstone", "stonesGiven" } },
  PRIEST = { calling = { "mindcontrol" }, escapes = { "fade" }, given = { "rez", "pws", "fort" }, forms = true },
  SHAMAN = { calling = { "totems" }, escapes = { "reincarnation" }, given = { "ancestral" }, forms = true },
  PALADIN = { calling = { "layonhands", "intervention" }, escapes = { "bubble" }, given = { "redemption", "blessing", "lohOthers" } },
  DRUID = { escapes = { "barkskin" }, given = { "rebirth", "innervate", "thorns", "mark" }, forms = true },
  DEATHKNIGHT = { calling = { "grip", "raisedead", "deathgate" }, escapes = { "icebound" }, given = { "raiseally" }, forms = true },
}
C.SPEC = SPEC
local ESCAPE_STAT = { vanish = "by Vanish", feign = "by Feign Death", shieldwall = "behind Shield Wall", laststand = "on Last Stand",
  blink = "by Blink", bubble = "behind Divine Shield", barkskin = "in Barkskin", fade = "by Fade", deathcoil = "by Death Coil",
  icebound = "in Icebound Fortitude", reincarnation = "by Reincarnation" }

function C.Stats(c)
  local o, world = c and c.calling, c and c.world or {}
  local spec = SPEC[world.class or ""]
  if not o or not spec then return {} end
  local n = o.n
  local NOUN = W.CALLING.NOUN
  local function figure(x) return x >= 100 and U.Number(x) or tostring(x) end
  local function item(key, x)
    local w = NOUN[key]
    return figure(x) .. " " .. (x == 1 and w[1] or w[2])
  end
  local out = {}
  if spec.calling then
    local parts = {}
    for _, k in ipairs(spec.calling) do
      local x = n[k]
      if x > 0 then
        local s = item(k, x)
        if k == "pockets" and n.pocketCoin >= 10000 then s = s .. " for " .. figure(math.floor(n.pocketCoin / 10000)) .. " gold"
        elseif k == "tames" then
          local b = o.beasts[#o.beasts]
          if b and b.family then s = s .. ", the latest " .. article(b.family:lower()) end
        elseif k == "demons" and o.demons[1] then s = s .. ", most often the " .. o.demons[1].name
        elseif k == "totems" then
          local by = {}
          for _, t in ipairs(o.totems) do by[#by + 1] = figure(t.n) .. " " .. t.name end
          if #by > 1 then s = s .. " (" .. table.concat(by, ", ") .. ")" end
        end
        parts[#parts + 1] = s
      end
    end
    out.calling = #parts > 0 and table.concat(parts, "; ") or "None yet"
  end
  if spec.escapes then
    local parts = {}
    for _, k in ipairs(spec.escapes) do
      local x = k == "reincarnation" and n.reincarnation or n[k .. "Save"]
      if x > 0 then parts[#parts + 1] = figure(x) .. " " .. ESCAPE_STAT[k] end
    end
    out.escapes = #parts > 0 and table.concat(parts, ", ") or "None yet"
  end
  if spec.given then
    local parts = {}
    for _, k in ipairs(spec.given) do
      local x = n[k]
      if x > 0 then
        local s = item(k, x)
        local st = n[k .. "Strangers"]
        if st > 0 and st < x then s = s .. ", " .. figure(st) .. " of them strangers"
        elseif st > 0 and st == x then s = s .. ", all of them strangers" end
        parts[#parts + 1] = s
      end
    end
    out.given = #parts > 0 and table.concat(parts, "; ") or "None yet"
  end
  if spec.forms then
    local parts = {}
    for i = 1, math.min(3, #o.forms) do
      local f = o.forms[i]
      if f.n >= 60 then
        local h = math.floor(f.n / 3600)
        local m = math.floor(f.n / 60)
        parts[#parts + 1] = f.name .. " " .. (h >= 1 and (figure(h) .. " " .. U.Plural(h, "hour")) or (figure(m) .. " " .. U.Plural(m, "minute")))
      end
    end
    out.forms = #parts > 0 and table.concat(parts, ", ") or "None yet"
  end
  return out
end
