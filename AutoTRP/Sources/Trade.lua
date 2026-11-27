-- Auto TRP's record of the character's trades in depth, beside Life.lua's counts (things
-- made, herbs, ore, hides, fish): how many recipes each trade knows (read when its window
-- opens), the recipes learned over time, the finest thing ever made and the first of each
-- notable piece, a specialisation (weaponsmith or armorsmith, gnomish or goblin engineer,
-- dragonscale, elemental or tribal leatherworker, transmutes known), bandages put on other
-- people, enchantments and locks opened for others through the trade window, meals cooked
-- in company, where the herbs, ore and hides come from, and the tools in the bags.
-- Kept per character in AutoTRPCharDB.trade and read into ns.cache.trade. Only game events
-- and game APIs: no other addon is needed.
--
-- Light by design: the recipe lists are read only when a trade window opens and never in a
-- fight; the combat log handler looks at one sub-event and bails out on anything else;
-- other people are only ever counted, never named; every list is capped.
local _, ns = ...

local U = ns.U
local W = ns.Words
local T = {}
ns.Sources = ns.Sources or {}
ns.Sources.Trade = T

T.CAP_FIRSTS = 30    -- notable pieces remembered by their first making
T.CAP_LEARNED = 20   -- recipes learned, the newest kept
T.CAP_ZONES = 20     -- lands per kind of gathering
T.MAX_LINES = 800    -- recipe lines read at most from one window

-- The trades whose windows are read (Beast Training uses the same window and isn't one).
T.PROFS = {
  Alchemy = true, Blacksmithing = true, Enchanting = true, Engineering = true, Leatherworking = true,
  Tailoring = true, Cooking = true, ["First Aid"] = true, Jewelcrafting = true, Mining = true, Poisons = true,
  Inscription = true,
}

local function inCombat()
  return U.Call(InCombatLockdown) or U.Call(UnitAffectingCombat, "player")
end

local function store()
  if not ns.char then return nil end
  local d = ns.char.trade
  if type(d) ~= "table" then d = {}; ns.char.trade = d end
  d.since = tonumber(d.since) or U.Now()
  for _, k in ipairs({ "known", "learned", "firsts", "gather", "service" }) do
    if type(d[k]) ~= "table" then d[k] = {} end
  end
  return d
end
T.Store = store

local function zone() return U.Plain(U.Call(GetRealZoneText)) end
local function changed() if ns.Compose then ns.Compose.SourcesChanged() end end

-- Keep at most `cap` keys in t (a table of counts or of { n = }): the least go first.
local function trim(t, cap)
  local n = 0
  for _ in pairs(t) do n = n + 1 end
  while n > cap do
    local lo, lk
    for k, v in pairs(t) do
      local c = type(v) == "table" and (v.n or v.t or 0) or v
      if not lo or c < lo then lo, lk = c, k end
    end
    t[lk] = nil
    n = n - 1
  end
end

---------------------------------------------------------------------------
-- Recording
---------------------------------------------------------------------------
-- What a trade window shows: the trade's name and its recipe names. The count is the most
-- ever seen (a collapsed header hides lines, and a recipe is never forgotten).
function T.Known(prof, names)
  local d = store()
  prof = U.Plain(prof)
  if not d or not prof or not T.PROFS[prof] or type(names) ~= "table" then return false end
  local n, transmutes = 0, 0
  for _, name in ipairs(names) do
    n = n + 1
    if type(name) == "string" and name:find("^Transmute") then transmutes = transmutes + 1 end
  end
  if n == 0 then return false end
  local k = d.known[prof]
  if type(k) ~= "table" then k = { n = 0 }; d.known[prof] = k end
  local grew = n > (k.n or 0)
  k.n, k.t = math.max(k.n or 0, n), U.Now()
  if prof == "Alchemy" then k.transmutes = math.max(k.transmutes or 0, transmutes) end
  trim(d.known, 16)
  if grew then changed() end
  return grew
end

-- A recipe learned ("You have learned how to create a new item: Bolt of Linen Cloth.").
local lastLearned
function T.Learned(name, prof)
  local d = store()
  name = U.Plain(name)
  if not d or not name then return false end
  if lastLearned and lastLearned.name == name and U.Now() - lastLearned.t < 10 then return false end
  lastLearned = { name = name, t = U.Now() }
  local l = d.learned
  l.n = (l.n or 0) + 1
  l.log = l.log or {}
  table.insert(l.log, { name = name, prof = U.Plain(prof), t = U.Now(), zone = zone() })
  while #l.log > T.CAP_LEARNED do table.remove(l.log, 1) end
  changed()
  return true
end

-- Something made: its name, quality (from the link) and trade. The finest piece ever made
-- is kept, and the first making of anything notable (rare or better, or on the list).
function T.Made(item, quality, prof, n)
  local d = store()
  item = U.Plain(item)
  quality = tonumber(quality) or 1
  -- Only what a trade window made: "You create" also follows conjured water and healthstones.
  if not d or not item or not prof then return false end
  local now, z = U.Now(), zone()
  local news = false
  local f = d.finest
  if not f or quality > (f.q or 0) then
    d.finest = { name = item, q = quality, prof = U.Plain(prof), t = now, zone = z }
    news = quality >= 2
  end
  if (quality >= 3 or W.TRADE.NOTABLE[item]) and not d.firsts[item] then
    d.firsts[item] = { t = now, q = quality, prof = U.Plain(prof), zone = z }
    trim(d.firsts, T.CAP_FIRSTS)
    news = true
  end
  if prof == "Cooking" and (U.Call(IsInGroup) or U.Call(IsInRaid)) then
    d.service.meals = (d.service.meals or 0) + (n or 1)
  end
  if news then changed() end
  return news
end

-- Done for someone else: "bandage", "enchant" or "lock". Who it was is never kept.
function T.Served(kind, what)
  local d = store()
  if not d or (kind ~= "bandage" and kind ~= "enchant" and kind ~= "lock") then return false end
  local s = d.service[kind]
  if type(s) ~= "table" then s = { n = 0 }; d.service[kind] = s end
  s.n, s.t = (s.n or 0) + 1, U.Now()
  if kind == "enchant" then s.last = U.Plain(what) end
  return true
end

-- Gathered: where, by kind ("herbs", "mining", "skinning"), and the item gathered most there.
function T.Gathered(kind, item, n)
  local d = store()
  local z = zone()
  if not d or not z or (kind ~= "herbs" and kind ~= "mining" and kind ~= "skinning") then return end
  local g = d.gather[kind]
  if type(g) ~= "table" then g = { n = 0, zones = {} }; d.gather[kind] = g end
  g.n = (g.n or 0) + (n or 1)
  g.zones[z] = (g.zones[z] or 0) + (n or 1)
  trim(g.zones, T.CAP_ZONES)
end

---------------------------------------------------------------------------
-- Reading the game
---------------------------------------------------------------------------
-- A trade window: the recipe lines (headers left out), only out of a fight.
local lastRead = {}
function T.ReadWindow(kind)
  if inCombat() then return false end
  local prof, n, info
  if kind == "craft" then
    prof = U.Plain((U.Call(_G.GetCraftDisplaySkillLine))) or U.Plain((U.Call(_G.GetCraftName)))
    n, info = U.Call(_G.GetNumCrafts), _G.GetCraftInfo
  else
    prof = U.Plain((U.Call(_G.GetTradeSkillLine)))
    n, info = U.Call(_G.GetNumTradeSkills), _G.GetTradeSkillInfo
  end
  if not prof or not T.PROFS[prof] or type(n) ~= "number" or n < 1 then return false end
  -- The window updates after every craft: the same list again soon after isn't read twice.
  local last = lastRead[prof]
  if last and last.n == n and U.Now() - last.t < 5 then return false end
  lastRead[prof] = { n = n, t = U.Now() }
  local names = {}
  for i = 1, math.min(n, T.MAX_LINES) do
    local name, a, b = U.Call(info, i)
    local kindOf = kind == "craft" and b or a
    if type(name) == "string" and kindOf ~= "header" and kindOf ~= "subheader" then names[#names + 1] = name end
  end
  return T.Known(prof, names)
end
ns.On("TRADE_SKILL_SHOW", function() T.ReadWindow("trade") end)
ns.On("TRADE_SKILL_UPDATE", function() T.ReadWindow("trade") end)
ns.On("CRAFT_SHOW", function() T.ReadWindow("craft") end)
ns.On("CRAFT_UPDATE", function() T.ReadWindow("craft") end)

-- Recipes learned, from the system line and (where the client has it) NEW_RECIPE_LEARNED.
local function pattern(fmt, fallback)
  fmt = type(fmt) == "string" and fmt or fallback
  return "^" .. fmt:gsub("([%(%)%.%+%-%*%?%[%]%^%$])", "%%%1"):gsub("%%s", "(.+)"):gsub("%%%.$", "")
end
local LEARN_RECIPE = pattern(_G.ERR_LEARN_RECIPE_S, "You have learned how to create a new item: %s.")
local LEARN_SPELL = pattern(_G.ERR_LEARN_SPELL_S, "You have learned a new spell: %s.")
local function craftProf()
  local ctx = ns.World and ns.World.Context()
  return ctx and ctx.kind == "craft" and ctx.detail or nil
end
function T.OnSystem(msg)
  msg = ns.World and ns.World.Safe(msg) or msg
  if type(msg) ~= "string" then return end
  local name = msg:match(LEARN_RECIPE)
  if not name then
    -- Enchantments, transmutes and smelting are learned as spells.
    local spell = msg:match(LEARN_SPELL)
    if spell and (spell:find("^Enchant ") or spell:find("^Transmute") or spell:find("^Smelt ")) then name = spell end
  end
  if name then T.Learned((name:gsub("%.$", "")), craftProf()) end
end
ns.On("CHAT_MSG_SYSTEM", function(_, msg) T.OnSystem(msg) end)
ns.On("NEW_RECIPE_LEARNED", function(_, recipeID)
  local id = tonumber(recipeID)
  if not id then return end
  local name = (_G.C_Spell and U.Call(_G.C_Spell.GetSpellName, id)) or U.Call(_G.GetSpellInfo, id)
  if name then T.Learned(name, craftProf()) end
end)

-- "You create: [Robes of Arcana]": the quality from the link's colour.
local QUALITY_HEX = { ["9d9d9d"] = 0, ffffff = 1, ["1eff00"] = 2, ["0070dd"] = 3, a335ee = 4, ff8000 = 5 }
function T.Quality(msg)
  local q = tonumber(msg:match("|cnIQ(%d+):"))
  if q then return q end
  local hex = msg:match("|cff(%x%x%x%x%x%x)")
  return hex and QUALITY_HEX[hex:lower()] or nil
end
function T.OnLoot(msg)
  msg = ns.World and ns.World.Safe(msg) or msg
  if type(msg) ~= "string" or not msg:find("^You create") then return end
  local item = msg:match("%[(.-)%]")
  if not item then return end
  local n = tonumber(msg:match("%]|h|rx(%d+)") or msg:match("%]x(%d+)") or msg:match("x(%d+)%.?$")) or 1
  T.Made(item, T.Quality(msg) or 1, craftProf(), n)
end
ns.On("CHAT_MSG_LOOT", function(_, msg) T.OnLoot(msg) end)

-- Gathering, by land: Life.lua decides what loot was gathered; this notes where.
do
  local Life = ns.Sources.Life
  local base = Life and Life.Gather
  if base then
    Life.Gather = function(kind, item, n)
      local ok = base(kind, item, n)
      if ok ~= false then T.Gathered(kind, item, n) end
      return ok
    end
  end
end

-- Bandages put on someone else: the aura going on, counted once per bandage. The combat
-- log handler looks at one sub-event and bails out on anything else.
local me
ns.On("PLAYER_ENTERING_WORLD", function() me = nil end)
function T.OnCombatLog(...)
  local _, sub, _, src, _, _, _, dst, _, _, _, spellID, spellName = ...
  if sub ~= "SPELL_AURA_APPLIED" then return end
  if not (W.TRADE.BANDAGE_IDS[spellID or 0] or spellName == "First Aid") then return end
  if not me then me = U.Call(UnitGUID, "player") end
  if src == me and dst and dst ~= me then T.Served("bandage") end
end
ns.On("COMBAT_LOG_EVENT_UNFILTERED", function()
  local fn = _G.CombatLogGetCurrentEventInfo
  if type(fn) == "function" then T.OnCombatLog(fn()) end
end)

-- The trade window: an enchantment cast, or a lock picked, while it's open counts once
-- both sides accept. Who it was with is never kept.
local tradeAt, pending = nil, nil
ns.On("TRADE_SHOW", function() tradeAt, pending = U.Now(), nil end)
ns.On("TRADE_CLOSED", function() tradeAt, pending = nil, nil end)
-- A trade window is open (a missed close doesn't leave it open for good).
local function trading() return tradeAt and U.Now() - tradeAt < 600 end
local PICK_LOCK = { [1804] = true }
function T.OnCast(spellID)
  if not trading() then return end
  local name = (_G.C_Spell and U.Call(_G.C_Spell.GetSpellName, spellID)) or U.Call(_G.GetSpellInfo, spellID)
  if PICK_LOCK[spellID or 0] or name == "Pick Lock" then pending = { kind = "lock" }
  elseif type(name) == "string" and name:find("^Enchant ") then pending = { kind = "enchant", what = name } end
end
ns.OnUnit("UNIT_SPELLCAST_SUCCEEDED", "player", function(_, _, _, spellID) T.OnCast(spellID) end)
ns.On("TRADE_ACCEPT_UPDATE", function(_, player, target)
  if player ~= 1 or target ~= 1 or not pending or not trading() then return end
  T.Served(pending.kind, pending.what)
  pending = nil
  changed()
end)

-- A specialisation, by the spells the game says are known. Read again after the spellbook
-- changes, never in a fight.
local specDirty, spec = true, nil
ns.On("SPELLS_CHANGED", function() specDirty = true end)
ns.On("LEARNED_SPELL_IN_TAB", function() specDirty = true end)
local function known(id)
  local fn = _G.IsPlayerSpell or _G.IsSpellKnown
  return U.Call(fn, id) and true or false
end
function T.Spec()
  if specDirty and not inCombat() then
    spec = nil
    for _, s in ipairs(W.TRADE.SPECS) do
      if known(s.id) then spec = s; break end
    end
    specDirty = false
  end
  return spec
end

-- Tools of a trade in the bags, out of a fight, after the bags change.
local toolsDirty, tools = true, {}
ns.On("BAG_UPDATE_DELAYED", function() toolsDirty = true end)
function T.Tools()
  if toolsDirty and not inCombat() then
    tools = {}
    local count = (_G.C_Item and _G.C_Item.GetItemCount) or _G.GetItemCount
    local had = {}
    for _, tool in ipairs(W.TRADE.TOOLS) do
      if not (tool.group and had[tool.group]) then
        local n = U.Call(count, tool.id)
        if type(n) == "number" and n > 0 then
          tools[#tools + 1] = tool
          if tool.group then had[tool.group] = true end
        end
      end
    end
    toolsDirty = false
  end
  return tools
end

---------------------------------------------------------------------------
-- Reading it back: a fresh table each time.
---------------------------------------------------------------------------
function T.Read()
  local d = store()
  if not d then return nil end
  local o = { since = d.since }
  o.known, o.knownTotal = {}, 0
  for prof, k in pairs(d.known) do
    if type(k) == "table" and (k.n or 0) > 0 then
      o.known[#o.known + 1] = { prof = prof, n = k.n }
      o.knownTotal = o.knownTotal + k.n
      if prof == "Alchemy" then o.transmutes = k.transmutes or 0 end
    end
  end
  table.sort(o.known, function(a, b) if a.n ~= b.n then return a.n > b.n end return a.prof < b.prof end)
  o.learnedN = d.learned.n or 0
  o.learned = {}
  for i = #(d.learned.log or {}), 1, -1 do o.learned[#o.learned + 1] = d.learned.log[i] end
  o.finest = d.finest
  o.firsts = {}
  for name, f in pairs(d.firsts) do
    if type(f) == "table" then o.firsts[#o.firsts + 1] = { name = name, t = f.t or 0, q = f.q or 1, prof = f.prof, zone = f.zone } end
  end
  table.sort(o.firsts, function(a, b) if a.t ~= b.t then return a.t > b.t end return a.name < b.name end)
  local s = d.service
  o.bandaged, o.enchanted, o.locks, o.meals = s.bandage or { n = 0 }, s.enchant or { n = 0 }, s.lock or { n = 0 }, s.meals or 0
  o.gather = {}
  for kind, g in pairs(d.gather) do
    if type(g) == "table" then
      local best, bn = nil, 0
      for z, n in pairs(g.zones or {}) do if n > bn or (n == bn and best and z < best) then best, bn = z, n end end
      o.gather[kind] = { n = g.n or 0, zone = best, zoneN = bn, lands = U.Count(g.zones or {}) }
    end
  end
  o.spec = T.Spec()
  o.tools = T.Tools()
  return o
end

---------------------------------------------------------------------------
-- Writing: what Compose puts in History, Personality, the glances and the statistics.
-- Lines come from W.TRADE (Data/Words.lua); pronoun tags are left for U.Pron.
---------------------------------------------------------------------------
local function seed(key) return (ns.char and ns.char.seedName or "") .. ":trade:" .. key end
local function say(key, vars, which)
  local pool = W.TRADE.SAY[key]
  if type(pool) ~= "table" or #pool == 0 then return nil end
  local line = U.Pick(pool, seed(key .. ":" .. tostring(which or "")))
  return (line:gsub("{(%a+)}", function(k) if vars and vars[k] ~= nil then return vars[k] end end))
end
T.Say = say
local function plain(name) return name end
local function article(word) return (word:lower():match("^[aeiou]") and "an " or "a ") .. word end
local function within(t, seconds) return type(t) == "number" and t > 0 and U.Now() - t <= seconds end

-- "112 tailoring patterns and 40 cooking recipes"
local function knownWords(tr, k)
  local parts = {}
  for i = 1, math.min(k or 2, #tr.known) do
    local e = tr.known[i]
    local noun = W.TRADE.RECIPE[e.prof]
    if noun and e.n >= (i == 1 and 20 or 15) then parts[#parts + 1] = U.Number(e.n) .. " " .. noun end
  end
  return #parts > 0 and U.Join(parts) or nil
end

-- A thing worth naming as their work: the finest piece, if it's uncommon or better.
local function finestWork(tr)
  local f = tr.finest
  if f and (f.q or 0) >= 2 then return f end
end

-- History's craft passage ("Knows 112 tailoring patterns and has made Robes of Arcana; is a
-- gnomish engineer, for better or worse."): facts only, up to three sentences.
-- itemName(name, quality) colours an item; told: what History's news already said.
function T.Passage(tr, itemName, told)
  if not tr then return {} end
  itemName = itemName or plain
  told = told or {}
  local out = {}
  local known = knownWords(tr, 2)
  local f = finestWork(tr)
  local item = f and not told.tradefirst and itemName(f.name, f.q) or nil
  local first
  if known and item then first = say("know_made", { known = known, item = item }, f.name)
  elseif known then first = say("know", { known = known }, known)
  elseif item then first = say("made", { item = item }, f.name) end
  local sp = tr.spec
  if sp then
    local vars = { aspec = article(sp.noun), spec = sp.noun }
    local tail = W.TRADE.SPEC_TAIL[sp.key] and U.Pick(W.TRADE.SPEC_TAIL[sp.key], seed("spectail")) or ""
    if first then first = first .. "; " .. say("spec_after", vars, sp.key) .. tail
    else first = say("spec", vars, sp.key) .. tail end
  end
  if (tr.transmutes or 0) >= 2 then
    local t = say("transmutes", { n = U.Number(tr.transmutes) }, tr.transmutes)
    first = first and (first .. ", and " .. t) or U.Cap(t)
  end
  if first then out[#out + 1] = first end
  -- What they've done for other people (counted, never who).
  local served = {}
  if tr.bandaged.n >= 5 then served[#served + 1] = say("ev_bandage", { times = U.Times(tr.bandaged.n) }, tr.bandaged.n) end
  if tr.enchanted.n >= 3 then served[#served + 1] = say("ev_enchant", { times = U.Times(tr.enchanted.n) }, tr.enchanted.n) end
  if tr.locks.n >= 3 then served[#served + 1] = say("ev_lock", { n = U.Number(tr.locks.n) }, tr.locks.n) end
  if tr.meals >= 10 then served[#served + 1] = say("ev_meals", { n = U.Roughly(tr.meals) }, tr.meals) end
  if #served > 0 then out[#out + 1] = say("served", { list = U.Join(served) }, served[1]) end
  -- Where the gathering is done: the land that has given most, when it's most of it.
  local bestKind, best
  for _, kind in ipairs({ "herbs", "mining", "skinning" }) do
    local g = tr.gather[kind]
    if g and g.zone and g.n >= 25 and g.zoneN >= g.n * 0.4 and (not best or g.n > best.n) then bestKind, best = kind, g end
  end
  if best then out[#out + 1] = say("gather_" .. bestKind, { zone = U.Mid(best.zone) }, best.zone) end
  return out
end

-- One line for Personality, when the counts back it: what they do for others first.
function T.Habit(tr)
  if not tr then return nil end
  local cands = {}
  if tr.bandaged.n >= 10 then cands[#cands + 1] = { tr.bandaged.n / 10, "habit_bandage" } end
  if tr.enchanted.n >= 5 then cands[#cands + 1] = { tr.enchanted.n / 5, "habit_enchant" } end
  if tr.locks.n >= 5 then cands[#cands + 1] = { tr.locks.n / 5, "habit_lock" } end
  if tr.meals >= 20 then cands[#cands + 1] = { tr.meals / 20, "habit_meals" } end
  if (tr.known[1] and tr.known[1].n or 0) >= 100 and W.TRADE.TRADE_WORD[tr.known[1].prof] then
    cands[#cands + 1] = { 0.9, "habit_learned" }
  end
  if tr.learnedN >= 25 then cands[#cands + 1] = { 0.8, "habit_learning" } end
  table.sort(cands, function(a, b) if a[1] ~= b[1] then return a[1] > b[1] end return a[2] < b[2] end)
  local c = cands[1]
  if not c then return nil end
  return say(c[2], { trade = tr.known[1] and W.TRADE.TRADE_WORD[tr.known[1].prof] or "trade" }, c[2])
end

-- A recipe's name in a sentence: "Enchant Bracer - Minor Health" is learned, not made.
local function isSpell(name) return name:find("^Enchant ") or name:find("^Transmute") or name:find("^Smelt ") end

-- History's news (the last three weeks): { t, rank, text, key }.
function T.Events(tr, recent, itemName)
  local out = {}
  if not tr then return out end
  itemName = itemName or plain
  local fresh = {}
  for _, l in ipairs(tr.learned) do if recent(l.t) then fresh[#fresh + 1] = l end end
  if #fresh >= 3 then
    out[#out + 1] = { t = fresh[1].t, rank = 7, key = "learned",
      text = say("ev_learned_many", { n = U.Number(#fresh), item = fresh[1].name }, fresh[1].t) }
  elseif #fresh > 0 then
    local names = {}
    for k, l in ipairs(fresh) do names[k] = l.name end
    out[#out + 1] = { t = fresh[1].t, rank = 7, key = "learned",
      text = say(isSpell(fresh[1].name) and "ev_learned_spell" or "ev_learned", { item = U.Join(names) }, fresh[1].t) }
  end
  local f = tr.firsts[1]
  if f and recent(f.t) then
    out[#out + 1] = { t = f.t, rank = 5, key = "tradefirst", text = say("ev_first", { item = itemName(f.name, f.q) }, f.name) }
  end
  return out
end

-- The Lately glance: { t, prio, g = { TI, IC, TX } }.
function T.Lately(tr, world)
  local out = {}
  if not tr then return out end
  local l = tr.learned[1]
  if l and within(l.t, 86400) then
    local n = 0
    for _, x in ipairs(tr.learned) do if within(x.t, 86400) then n = n + 1 end end
    local tx = n >= 3 and say("lately_learned_many", { n = U.Number(n), item = l.name }, l.t)
      or say(isSpell(l.name) and "lately_learned_spell" or "lately_learned", { item = l.name }, l.t)
    out[#out + 1] = { t = l.t, prio = 0, g = { TI = "A New Recipe", IC = "INV_Scroll_03", TX = U.Pron(tx) } }
  end
  local f = tr.firsts[1]
  if f and within(f.t, 2 * 86400) then
    local finest = tr.finest and tr.finest.name == f.name and (f.q or 0) >= 3
    out[#out + 1] = { t = f.t, prio = finest and 1 or 0, g = { TI = finest and "Finest Work Yet" or "First of Its Kind",
      IC = W.TRADE.ICON[f.prof or ""] or "Trade_Engineering",
      TX = U.Pron(say(finest and "lately_finest" or "lately_first", { item = f.name }, f.t)) } }
  end
  local e = tr.enchanted
  if e.t and within(e.t, 3600) then
    out[#out + 1] = { t = e.t, prio = 0, g = { TI = "Enchanting for Others", IC = "Trade_Engraving",
      TX = U.Pron(say("lately_enchant", nil, e.t)) } }
  end
  local lk = tr.locks
  if lk.t and within(lk.t, 3600) then
    out[#out + 1] = { t = lk.t, prio = 0, g = { TI = "A Lock Opened", IC = "INV_Misc_Key_03", TX = U.Pron(say("lately_lock", nil, lk.t)) } }
  end
  local b = tr.bandaged
  if b.t and within(b.t, 900) and not (world and world.combat) then
    out[#out + 1] = { t = b.t, prio = 0, g = { TI = "Field Dressing", IC = "INV_Misc_Bandage_15", TX = U.Pron(say("lately_bandage", nil, b.t)) } }
  end
  return out
end

-- The Marks glance: { prio, title, text, icon }. A trade's smell after a stretch at it
-- (Life.lua's own marks cover cooking, fishing and gathering), and the tools carried.
function T.Marks(tr, life)
  local out = {}
  if not tr then return out end
  local mr = life and life.madeRun
  local m = mr and W.TRADE.MARK[mr.kind or ""]
  if m and within(mr.last, 1800) and (mr.n or 0) >= 3 then
    out[#out + 1] = { prio = 4.4, title = m.title, text = U.Pron(U.Pick(m.text, seed("mark:" .. mr.kind .. tostring(mr.start)))), icon = m.icon }
  end
  if #tr.tools >= 1 then
    local names = {}
    for k = 1, math.min(3, #tr.tools) do names[k] = tr.tools[k].phrase end
    out[#out + 1] = { prio = 3.2, title = "Tools of the Trade", text = U.Pron(say("mark_tools", { list = U.Join(names) }, names[1])),
      icon = tr.tools[1].icon or "INV_Pick_02" }
  end
  return out
end

-- The statistics: "Recipes known" ("112: 72 tailoring, 40 cooking") and "Finest work"
-- ("Robes of Arcana, rare, tailoring").
local QUALITY_WORD = { [0] = "poor", [1] = "common", [2] = "uncommon", [3] = "rare", [4] = "epic", [5] = "legendary" }
function T.Stats(tr)
  if not tr then return {} end
  local function figure(n) return n >= 100 and U.Number(n) or tostring(n) end
  local out = {}
  if tr.knownTotal > 0 then
    local parts = {}
    for i = 1, math.min(3, #tr.known) do parts[i] = figure(tr.known[i].n) .. " " .. tr.known[i].prof:lower() end
    out.recipes = #tr.known == 1 and parts[1] or (figure(tr.knownTotal) .. ": " .. table.concat(parts, ", "))
  end
  local f = tr.finest
  if f then
    out.finest = f.name .. ", " .. (QUALITY_WORD[f.q or 1] or "common") .. (f.prof and (", " .. f.prof:lower()) or "")
  end
  return out
end
