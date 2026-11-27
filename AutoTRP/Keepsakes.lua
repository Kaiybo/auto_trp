-- What the character carries, told from the bags (Sources/Pack.lua, read into ns.cache.pack):
-- a short paragraph in About: Physical, Marks and Lately at first glance, habits in
-- Personality from what's kept well stocked, the keepsake kept longest in History, and the
-- "Treasured keepsake" statistic. Only what is in the bags right now is named (or, for
-- something let go, what was); item names are in their quality's colour where About allows.
local _, ns = ...

local U = ns.U
local W = ns.Words
local Compose = ns.Compose
local K = {}
ns.Keepsakes = K

local function seed(key) return (ns.char and ns.char.seedName or "") .. ":pack:" .. key end

-- One line of a list with {item} {dur} {zone} {town} {n} filled; pronoun tags are left for U.Pron.
local function fill(list, vars, key)
  if type(list) ~= "table" or #list == 0 then return nil end
  local line = U.Pick(list, seed(key))
  return (line:gsub("{([%a']+)}", function(k) if vars[k] ~= nil then return vars[k] end end))
end

local function plain(name) return name end

-- "a day", "nine days", "three weeks", "two months".
function K.Days(seconds)
  local d = math.max(1, math.floor((seconds or 0) / 86400 + 0.5))
  if d == 1 then return "a day" end
  if d >= 60 then return U.Number(math.floor(d / 30)) .. " months" end
  if d >= 14 then return U.Number(math.floor(d / 7)) .. " weeks" end
  return U.Number(d) .. " days"
end

-- A thing by its name, coloured by fmt; a recipe as "a Westfall Stew recipe card".
function K.Name(it, fmt)
  fmt = fmt or plain
  local kind, rest = (it.name or ""):match("^(%a+): (.+)$")
  local noun = kind and W.PACK.RECIPE_NOUN[kind]
  if noun then
    local n = fmt(rest, it.q)
    return (rest:lower():match("^[aeiou]") and "an " or "a ") .. n .. " " .. noun
  end
  local name = (it.name or ""):gsub("^(An?) ", function(a) return a:lower() .. " " end):gsub("^The ", "the ")
  return fmt(name, it.q)
end

local function mass(name, isMass)
  if isMass then return name end
  return Compose.Plural(name)
end

local function held(it) return U.Now() - (it.first or U.Now()) end

-- The thing kept longest (not the hearthstone, not a recipe or a starter, which say so
-- themselves), at least `min` seconds.
function K.Longest(pack, min)
  for _, it in ipairs(pack and pack.carried or {}) do
    if it.kind ~= "hearth" and it.kind ~= "quest" and held(it) >= (min or 0) then return it end
  end
  return nil
end

local function longVars(it, fmt)
  return { item = K.Name(it, fmt), dur = K.Days(held(it)), zone = (not it.before and it.zone) and U.Mid(it.zone) or nil }
end

---------------------------------------------------------------------------
-- About: Physical, what they carry (a few sentences, the most telling first)
---------------------------------------------------------------------------
function K.Carry(fmt)
  fmt = fmt or plain
  local c = ns.cache
  local pack, world = c.pack, c.world or {}
  if not pack then return {} end
  local C = W.PACK.CARRY
  local cands, told = {}, {}
  local function add(score, key, list, vars, id, state)
    if id and told[id] then return end
    if type(list) == "table" and #list > 0 then
      cands[#cands + 1] = { score = score, key = key, list = list, vars = vars or {}, state = state }
      if id then told[id] = true end
    end
  end
  local by = pack.byKind
  local function first(kind) return by[kind] and by[kind][1] end
  -- Kept a long time: since a land, or for a while.
  local long = K.Longest(pack, 7 * 86400)
  if long and long.kind ~= "recipe" then
    local v = longVars(long, fmt)
    add(5, "long", v.zone and C.since or C.long, v, long.id)
  end
  local st = first("starts")
  if st then add(4.4, "starts", C.starts, { item = K.Name(st, fmt) }, st.id) end
  for _, k in ipairs({ { "pet", 4.5 }, { "toy", 4 }, { "mount", 3.4 }, { "letter", 3.3 }, { "book", 3.2 } }) do
    local it = first(k[1])
    if it then add(k[2], k[1], C[k[1]], { item = K.Name(it, fmt) }, it.id) end
  end
  local rc = first("recipe")
  if rc and held(rc) >= 3 * 86400 then add(3, "recipe", C.recipe, { item = K.Name(rc, fmt), dur = K.Days(held(rc)) }, rc.id) end
  local keys = by.key or {}
  if #keys >= 2 then
    local names = {}
    for i = 1, math.min(3, #keys) do names[i] = K.Name(keys[i], fmt) end
    add(2.8, "keys", C.keys, { item = U.Join(names) })
  elseif keys[1] then
    add(2.8, "key", C.key, { item = K.Name(keys[1], fmt) }, keys[1].id)
  end
  local pole = first("pole")
  local inHand = world.gear and world.gear.names and world.gear.names[16]
  if pole and pole.name ~= inHand then add(2.6, "pole", C.pole, { item = K.Name(pole, fmt) }, pole.id) end
  for _, sub in ipairs(W.PACK.BAGS) do
    local b = pack.special[sub]
    if b then add(2.4, "bag:" .. sub, C[sub], { item = fmt(b.name, b.q) }, nil, true); break end
  end
  -- The biggest stack, unless it's a reagent the class line already counts.
  local said = {}
  for _, r in ipairs(world.reagents or {}) do said[r.name] = true end
  local top = pack.stacks[1]
  if top and top.n >= top.min and not said[top.name] then
    add(2.2, "stack", C.stack, { n = U.Number(top.n), item = fmt(mass(top.name, top.mass), top.q) }, nil, true)
  end
  if pack.slots >= 16 and pack.free == 0 then add(2.1, "full", C.full, {}, nil, true)
  elseif pack.slots >= 30 and pack.free >= pack.slots * 0.75 then add(1.6, "light", C.light, {}, nil, true) end
  if pack.hearth then add(1.5, "hearth", C.hearth, { town = pack.hearth }, nil, true) end
  table.sort(cands, function(a, b) if a.score ~= b.score then return a.score > b.score end return a.key < b.key end)
  -- Three at most, and one of them about the bags themselves when there's one to say.
  local chosen = {}
  for i = 1, math.min(3, #cands) do chosen[i] = cands[i] end
  local hasState = false
  for _, cd in ipairs(chosen) do if cd.state then hasState = true end end
  if not hasState and #chosen == 3 then
    for i = 4, #cands do if cands[i].state then chosen[3] = cands[i]; break end end
  end
  -- Each in a way that doesn't repeat where things are kept ("in their pack") or how the
  -- sentence opens.
  local out, usedWhere, usedOpen = {}, {}, {}
  local WHERE = { "pack", "bags", "keyring", "keys", "things" }
  for _, cd in ipairs(chosen) do
    local start = U.Hash(seed("carry:" .. cd.key))
    local pick, fallback
    for k = 0, #cd.list - 1 do
      local line = cd.list[(start + k) % #cd.list + 1]
      local whole = true
      for tag in line:gmatch("{([%a']+)}") do
        if (tag == "item" or tag == "dur" or tag == "zone" or tag == "town" or tag == "n") and cd.vars[tag] == nil then whole = false end
      end
      if whole then
        local clash = usedOpen[line:match("^(%S+)") or ""]
        for _, w in ipairs(WHERE) do if usedWhere[w] and line:find("{their} " .. w, 1, true) then clash = true end end
        if not clash then pick = line; break end
        fallback = fallback or line
      end
    end
    pick = pick or fallback
    if pick then
      for _, w in ipairs(WHERE) do if pick:find("{their} " .. w, 1, true) then usedWhere[w] = true end end
      usedOpen[pick:match("^(%S+)") or ""] = true
      out[#out + 1] = (pick:gsub("{([%a']+)}", function(k) if cd.vars[k] ~= nil then return cd.vars[k] end end))
    end
  end
  return out
end

---------------------------------------------------------------------------
-- At first glance
---------------------------------------------------------------------------
-- Marks: { prio, title, text, icon }, below anything about their gear or their state.
function K.Marks()
  local c = ns.cache
  local pack, world = c.pack, c.world or {}
  if not pack or world.combat or world.dead then return {} end
  local M = W.PACK.MARK
  local out = {}
  local function add(prio, key, vars)
    local m = M[key]
    local text = m and fill(m[3], vars or {}, "mark:" .. key)
    if text and not text:find("{item}") then out[#out + 1] = { prio = prio, title = m[1], text = text, icon = m[2] } end
  end
  local by = pack.byKind
  if by.starts then add(1.8, "starts", { item = K.Name(by.starts[1]) }) end
  if pack.slots >= 16 and pack.free == 0 then add(1.7, "full") end
  if by.pet and not world.pet then add(1.5, "pet", { item = K.Name(by.pet[1]) }) end
  if by.toy then add(1.4, "toy", { item = K.Name(by.toy[1]) }) end
  local long = K.Longest(pack, 14 * 86400)
  if long then add(1.3, "keepsake", { item = K.Name(long), dur = K.Days(held(long)) }) end
  local top = pack.stacks[1]
  if top and top.n >= top.min * 2 then add(1.1, "hoard", { n = U.Number(top.n), item = mass(top.name, top.mass) }) end
  return out
end

-- Lately: { t, prio, g } candidates, as LatelyGlance ranks them (the newest first).
function K.Lately()
  local c = ns.cache
  local pack = c.pack
  if not pack then return {} end
  local L, T = W.PACK.LATELY, W.PACK.LATELY_TITLE
  local out = {}
  local function add(t, prio, key, vars, icon)
    local text = fill(L[key], vars, "lately:" .. key .. ":" .. tostring(t))
    if text and not text:find("{item}") and not text:find("{dur}") then
      out[#out + 1] = { t = t, prio = prio, g = { TI = T[key], IC = icon, TX = U.Pron(text) } }
    end
  end
  local newDone, lostDone = false, false
  for _, e in ipairs(pack.events) do
    if U.Now() - (e.t or 0) <= 86400 then
      if e.kind == "new" and not newDone then
        local key = e.starts and "new_starts" or (e.what == "pet" or e.what == "toy") and ("new_" .. e.what) or "new"
        add(e.t, 1, key, { item = K.Name(e) }, e.what == "pet" and "INV_Box_PetCarrier_01" or "INV_Misc_Bag_10")
        newDone = true
      elseif L[e.kind] and e.kind ~= "carried" and not lostDone and (e.held or 0) >= 7 * 86400 then
        add(e.t, 1, e.kind, { item = K.Name(e), dur = K.Days(e.held) }, "INV_Misc_Coin_01")
        lostDone = true
      end
    end
  end
  -- Something carried a long while, told only when nothing fresher is: an old moment.
  local long = K.Longest(pack, 14 * 86400)
  if long then
    add((pack.scanned or U.Now()) - 3 * 86400, 0, "carried", { item = K.Name(long), dur = K.Days(held(long)) }, "INV_Misc_Bag_11")
  end
  return out
end

---------------------------------------------------------------------------
-- Personality: habits the bags back up
---------------------------------------------------------------------------
-- { score, key, list } for Compose.Habits: a stack kept well stocked for three days or more,
-- or a pack full of old keepsakes.
function K.Habits()
  local pack = ns.cache.pack
  if not pack then return {} end
  local out = {}
  local H = W.PACK.HABIT
  for _, h in ipairs(pack.hoards) do
    if H[h.kind] and U.Now() - (h.first or U.Now()) >= 3 * 86400 then
      local line = fill(H[h.kind], { item = mass(h.name, h.mass) }, "habit:" .. h.kind)
      out[#out + 1] = { score = 1.6, key = "pack:" .. h.kind, list = { line } }
      break
    end
  end
  local old = 0
  for _, it in ipairs(pack.carried) do
    if it.kind == "keepsake" and held(it) >= 7 * 86400 then old = old + 1 end
  end
  if old >= 3 then out[#out + 1] = { score = 1.3, key = "pack:keepsakes", list = H.keepsakes } end
  return out
end

---------------------------------------------------------------------------
-- History: the thing kept longest, or one long kept and lately let go
---------------------------------------------------------------------------
function K.History(fmt)
  local pack = ns.cache.pack
  if not pack then return nil end
  local H = W.PACK.HISTORY
  local long = K.Longest(pack, 14 * 86400)
  if long then
    local v = longVars(long, fmt)
    return fill(v.zone and H.since or H.long, v, "history")
  end
  for _, e in ipairs(pack.events) do
    if e.kind ~= "new" and e.kind ~= "gone" and (e.held or 0) >= 14 * 86400 and U.Now() - (e.t or 0) <= 21 * 86400 then
      return fill(H.lost, { item = K.Name(e, fmt), dur = K.Days(e.held) }, "history:lost")
    end
  end
  return nil
end

---------------------------------------------------------------------------
-- The "Treasured keepsake" statistic: the thing carried longest, how long, from where.
---------------------------------------------------------------------------
function K.Stat()
  local pack = ns.cache.pack
  local long = K.Longest(pack, 86400)
  if not long then return nil end
  return long.name .. ", carried for " .. (long.before and "at least " or "") .. K.Days(held(long))
    .. ((not long.before and long.zone) and (", from " .. U.Mid(long.zone)) or "")
end

Compose.Keepsakes = K.Carry
Compose.KeepsakeMarks = K.Marks
Compose.KeepsakeLately = K.Lately
Compose.KeepsakeHabits = K.Habits
Compose.KeepsakeHistory = K.History
Compose.KeepsakeStat = K.Stat
