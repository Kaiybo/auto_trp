-- Auto TRP's record of the rest of a life on the road: what the character fishes, makes and
-- gathers, their duels and battles, their money, the inns they rest at, the flight masters
-- they find and the mounts they ride, their levels, the emotes they use, the company they
-- keep (counted, never named), close calls and hard knocks, the hardest hits, the first fine
-- gear they put on, and the books and letters they read. Kept per character in
-- AutoTRPCharDB.life and read into ns.cache.life. Only game events and game APIs: no other
-- addon is needed.
--
-- Light by design: the combat log handler looks up its sub-event in a small table and bails
-- out on anything else; nothing is scanned while a fight is on (the group roster waits for
-- the fight to end); every list is capped.
local _, ns = ...

local U = ns.U
local L = {}
ns.Sources = ns.Sources or {}
ns.Sources.Life = L

L.CAP = 60          -- named things kept per list (fish, crafts, emotes...); the least counted go first
L.CAP_PEOPLE = 2000 -- people grouped with, kept only as a hash of the name, for counts
L.SETTLE = 3600     -- what's seen in the record's first hour was there before it (not news)

local function store()
  if not ns.char then return nil end
  local d = ns.char.life
  if type(d) ~= "table" then d = {}; ns.char.life = d end
  d.since = tonumber(d.since) or U.Now()
  for _, k in ipairs({ "fish", "made", "gather", "duels", "pvp", "money", "inns", "paths", "mounts", "levels",
    "emotes", "company", "close", "hits", "gear", "books", "letters", "env", "rez" }) do
    if type(d[k]) ~= "table" then d[k] = {} end
  end
  return d
end
L.Store = store

local function zone() return U.Plain(U.Call(GetRealZoneText)) end
local function settled(d) return U.Now() - (d.since or 0) > L.SETTLE end

-- t[key] += n, keeping at most cap keys: a new key pushes out the least counted one.
local function bump(t, key, n, cap)
  n = n or 1
  if t[key] then t[key] = t[key] + n; return end
  if cap then
    local count, lo, lk = 0, nil, nil
    for k, v in pairs(t) do
      count = count + 1
      if not lo or v < lo then lo, lk = v, k end
    end
    if count >= cap then
      if lo and lo <= n then t[lk] = nil else return end
    end
  end
  t[key] = n
end
L.Bump = bump

local function top(t)
  local best, bn
  for k, v in pairs(type(t) == "table" and t or {}) do
    if type(v) == "number" and (not bn or v > bn or (v == bn and tostring(k) < tostring(best))) then best, bn = k, v end
  end
  return best, bn or 0
end
L.Top = top

-- A run of the same work (fishing, a craft, gathering): how many, and since when.
local function run(r, kind, n)
  local now = U.Now()
  if r.kind ~= kind or now - (r.last or 0) > 900 then r.kind, r.n, r.start = kind, 0, now end
  r.n, r.last, r.zone = (r.n or 0) + (n or 1), now, zone()
  return r
end

---------------------------------------------------------------------------
-- Recording
---------------------------------------------------------------------------
-- A fish (or anything else) caught. name: the item as the game names it.
function L.Fish(name, n, quality)
  local d = store()
  name = U.Plain(name)
  if not d or not name or quality == 0 then return false end
  n = n or 1
  local f = d.fish
  f.n = (f.n or 0) + n
  f.byName = f.byName or {}
  local isNew = not f.byName[name]
  bump(f.byName, name, n, L.CAP)
  f.zones = f.zones or {}
  local z = zone()
  if z then bump(f.zones, z, n, 40) end
  f.last = { name = name, zone = z, t = U.Now() }
  if isNew and settled(d) then f.new = { name = name, zone = z, t = U.Now() } end
  f.run = run(f.run or {}, "fish", n)
  return true
end

-- Something made at a trade: "You create: [Linen Bandage]".
function L.Make(item, n, prof)
  local d = store()
  item = U.Plain(item)
  if not d or not item then return false end
  n = n or 1
  local m = d.made
  m.n = (m.n or 0) + n
  m.byItem, m.byProf = m.byItem or {}, m.byProf or {}
  bump(m.byItem, item, n, L.CAP)
  bump(m.byProf, prof or "other", n, 20)
  m.run = run(m.run or {}, prof or "other", n)
  m.run.item = item
  return true
end

-- Herbs, ore and hides gathered. kind: "herbs", "mining" or "skinning".
local GATHER = { herbs = "herbs", mining = "ore", skinning = "hides" }
function L.Gather(kind, item, n)
  local d = store()
  local key = GATHER[kind or ""]
  if not d or not key then return false end
  local g = d.gather
  g[key] = (g[key] or 0) + (n or 1)
  g.run = run(g.run or {}, kind, n)
  return true
end

-- A duel ended. Who it was against is never kept.
function L.Duel(won)
  local d = store()
  if not d then return end
  local du = d.duels
  if won then du.won = (du.won or 0) + 1 else du.lost = (du.lost or 0) + 1 end
  du.log = du.log or {}
  table.insert(du.log, { t = U.Now(), won = won and true or false, zone = zone() })
  while #du.log > 10 do table.remove(du.log, 1) end
end

-- A battleground ended. name: the battleground.
function L.Battle(name, won)
  local d = store()
  name = U.Plain(name)
  if not d or not name then return end
  local p = d.pvp
  p.fought, p.won = (p.fought or 0) + 1, (p.won or 0) + (won and 1 or 0)
  p.byName, p.wonBy = p.byName or {}, p.wonBy or {}
  bump(p.byName, name, 1, 20)
  if won and p.byName[name] then p.wonBy[name] = (p.wonBy[name] or 0) + 1 end
  p.last = { name = name, won = won and true or false, t = U.Now() }
end

function L.KillingBlow()
  local d = store()
  if d then d.pvp.kb = (d.pvp.kb or 0) + 1 end
end

-- Money, by where it came from or went: "looted", "quests", "vendor", "sold", "repairs",
-- "training", "flights", "auctions" (sales counted, not coin). copper >= 0.
function L.Money(kind, copper)
  local d = store()
  copper = tonumber(copper)
  if not d or not copper or copper <= 0 then return end
  d.money[kind] = (d.money[kind] or 0) + math.floor(copper)
end
function L.Held(copper)
  local d = store()
  copper = tonumber(copper)
  if d and copper and copper > (d.money.most or 0) then d.money.most = copper; d.money.mostT = U.Now() end
end

-- Resting at an inn. A stay counts again after an hour away.
function L.Inn(name)
  local d = store()
  name = U.Plain(name)
  if not d or not name then return false end
  local i = d.inns[name]
  local now = U.Now()
  if i then
    if now - (i.last or 0) > 3600 then i.n = (i.n or 1) + 1 end
    i.last = now
    return false
  end
  if U.Count(d.inns) >= 40 then
    local lo, lk
    for k, v in pairs(d.inns) do if not lo or (v.n or 1) < lo then lo, lk = v.n or 1, k end end
    d.inns[lk] = nil
  end
  d.inns[name] = { t = now, last = now, n = 1, zone = zone(), before = not settled(d) or nil }
  return true
end

function L.Hearth()
  local d = store()
  if d then d.hearths = (tonumber(d.hearths) or 0) + 1 end
end

-- The flight masters known, from the flight map: the first look takes in what's known
-- already; after that, a new one is news.
function L.Paths(names)
  local d = store()
  if not d or type(names) ~= "table" then return 0 end
  local p = d.paths
  p.known = p.known or {}
  local first, added = not p.seeded, 0
  for _, n in ipairs(names) do
    n = U.Plain(n)
    if n and not p.known[n] then
      p.known[n] = first and 1 or U.Now()
      if not first then added = added + 1 end
    end
  end
  p.seeded = true
  return added
end

-- A mount ridden: the first time each one is seen.
function L.Mount(name)
  local d = store()
  name = U.Plain(name)
  if not d or not name then return false end
  local m = d.mounts
  m.seen = m.seen or {}
  if m.seen[name] then return false end
  if U.Count(m.seen) >= 30 then return false end
  m.seen[name] = { t = U.Now(), zone = zone(), before = not settled(d) or nil }
  return true
end

-- A level reached: when, where, and how long the level before it took in play time (when
-- the game has said, through /played or another add-on asking).
function L.Level(level)
  local d = store()
  level = tonumber(level)
  if not d or not level then return end
  local e = { t = U.Now(), zone = zone() }
  local pl = d.played
  if pl and pl.lvl == level - 1 and tonumber(pl.level) then e.played = pl.level + (U.Now() - (pl.t or U.Now())) end
  d.levels[level] = e
end
function L.Played(total, thisLevel)
  local d = store()
  if not d or not tonumber(total) then return end
  d.played = { total = tonumber(total), level = tonumber(thisLevel), t = U.Now(), lvl = U.Call(UnitLevel, "player") }
end

-- An emote the character used, by its verb ("wave", "bow").
function L.Emote(verb)
  local d = store()
  if not d or type(verb) ~= "string" or verb == "" then return end
  bump(d.emotes, verb:lower(), 1, 40)
end

-- The people in a group, by name: each counted once per group, kept only as a number.
local inGroup = {}
function L.Group(names)
  local d = store()
  if not d then return end
  local co = d.company
  co.people = co.people or {}
  if #names == 0 then inGroup = {}; return end
  if next(inGroup) == nil then co.groups = (co.groups or 0) + 1 end
  for _, n in ipairs(names) do
    local h = U.Hash(n)
    if not inGroup[h] then
      inGroup[h] = true
      if co.people[h] then co.people[h] = co.people[h] + 1
      elseif (co.n or 0) < L.CAP_PEOPLE then co.people[h] = 1; co.n = (co.n or 0) + 1
      else co.more = (co.more or 0) + 1 end
    end
  end
end
-- How many times grouped with someone, by name (only asked for Social Diary friends).
function L.TimesWith(name)
  local d = store()
  return d and type(name) == "string" and d.company.people and d.company.people[U.Hash(name)] or 0
end

function L.Rezzed(kind)
  local d = store()
  if d then d.rez[kind] = (d.rez[kind] or 0) + 1 end
end

-- Hurt by the world: "Falling", "Drowning", "Lava", "Fire", "Slime", "Fatigue".
local lastEnv
function L.Env(kind, amount)
  local d = store()
  if not d or type(kind) ~= "string" then return end
  local e = d.env[kind]
  if type(e) ~= "table" then e = { n = 0 }; d.env[kind] = e end
  e.n, e.t = e.n + 1, U.Now()
  lastEnv = { kind = kind, t = U.Now() }
end

function L.CloseCall(foe, named)
  local d = store()
  if not d then return end
  d.close.n = (d.close.n or 0) + 1
  d.close.last = { t = U.Now(), zone = zone(), foe = U.Plain(foe), named = named and true or nil }
end

-- Fine gear put on: the first rare and first epic piece (q 3, 4). before: it was already
-- worn when the record began.
function L.Equip(name, quality, slot, before)
  local d = store()
  name = U.Plain(name)
  quality = tonumber(quality)
  if not d or not name or not quality or quality < 3 then return false end
  local key = quality >= 4 and "epic" or "rare"
  if d.gear[key] then return false end
  d.gear[key] = { name = name, q = quality, slot = slot, t = before and 1 or U.Now(), zone = zone(), before = before or nil }
  return true
end

-- A book (or any page) read, by its title; a letter has a writer and isn't kept by name.
function L.Page(title, letter)
  local d = store()
  if not d then return false end
  if letter then d.letters.n = (d.letters.n or 0) + 1; d.letters.t = U.Now(); return true end
  title = U.Plain(title)
  if not title or d.books[title] then return false end
  if U.Count(d.books) >= 80 then return false end
  d.books[title] = { t = U.Now(), zone = zone() }
  return true
end
function L.Letters(n)
  local d = store()
  if d and n and n > 0 then d.letters.n = (d.letters.n or 0) + n; d.letters.t = U.Now() end
end

-- What the profile tells from (the glances, History, the statistics) is read again on the
-- next update after any of these. Only a flag is set, so it costs nothing in a fight.
for _, name in ipairs({ "Fish", "Make", "Gather", "Duel", "Battle", "KillingBlow", "Inn", "Paths", "Mount", "Level",
  "Rezzed", "Env", "CloseCall", "Equip", "Page", "Letters" }) do
  local fn = L[name]
  L[name] = function(...)
    local a, b = fn(...)
    if ns.Compose then ns.Compose.SourcesChanged() end
    return a, b
  end
end

---------------------------------------------------------------------------
-- Reading it back: a fresh table each time.
---------------------------------------------------------------------------
local function sortedBy(t, field)
  local out = {}
  for k, v in pairs(t or {}) do if type(v) == "table" then local e = { name = k }; for a, b in pairs(v) do e[a] = b end; out[#out + 1] = e end end
  table.sort(out, function(a, b) if (a[field] or 0) ~= (b[field] or 0) then return (a[field] or 0) > (b[field] or 0) end return a.name < b.name end)
  return out
end

function L.Read()
  local d = store()
  if not d then return nil end
  local o = { since = d.since }
  local f = d.fish
  o.fish = f.n or 0
  o.fishTop, o.fishTopN = top(f.byName)
  o.fishKinds, o.fishZones = U.Count(f.byName), U.Count(f.zones)
  o.fishLast, o.fishNew, o.fishRun = f.last, f.new, f.run
  local m = d.made
  o.made = m.n or 0
  o.madeTop, o.madeTopN = top(m.byItem)
  o.madeByProf, o.madeRun = m.byProf or {}, m.run
  local g = d.gather
  o.herbs, o.ore, o.hides, o.gatherRun = g.herbs or 0, g.ore or 0, g.hides or 0, g.run
  o.duelsWon, o.duelsLost, o.duelLog = d.duels.won or 0, d.duels.lost or 0, d.duels.log or {}
  local p = d.pvp
  o.battles, o.battlesWon, o.battleLast, o.killingBlows = p.fought or 0, p.won or 0, p.last, p.kb or 0
  o.battleTop, o.battleKinds = top(p.byName), U.Count(p.byName)
  -- Each battleground's own count, and how many of those were won (Sources/War.lua tells more).
  o.battleBy = {}
  for name, n in pairs(p.byName or {}) do o.battleBy[name] = { n = n, won = math.min(n, (p.wonBy or {})[name] or 0) } end
  o.money = {}
  for k, v in pairs(d.money) do o.money[k] = v end
  o.inns = sortedBy(d.inns, "n")
  local newest
  for _, i in ipairs(o.inns) do if not i.before and (not newest or i.t > newest.t) then newest = i end end
  o.innNew = newest
  o.hearths = tonumber(d.hearths) or 0
  o.paths, o.pathsNew = 0, {}
  for name, t in pairs(d.paths.known or {}) do
    o.paths = o.paths + 1
    if t > 1 then o.pathsNew[#o.pathsNew + 1] = { name = name, t = t } end
  end
  table.sort(o.pathsNew, function(a, b) if a.t ~= b.t then return a.t > b.t end return a.name < b.name end)
  o.mounts = sortedBy(d.mounts.seen, "t")
  o.levels = d.levels
  o.played = d.played
  o.emoteTop, o.emoteTopN = top(d.emotes)
  local co = d.company
  o.people, o.groups = (co.n or 0) + (co.more or 0), co.groups or 0
  o.rezzed, o.spirit = d.rez.other or 0, d.rez.spirit or 0
  o.env = {}
  for k, v in pairs(d.env) do if type(v) == "table" then o.env[k] = { n = v.n or 0, t = v.t or 0, deaths = v.deaths or 0 } end end
  o.falls = o.env.Falling and o.env.Falling.n or 0
  o.closeCalls, o.closeLast = d.close.n or 0, d.close.last
  o.hitDealt, o.hitTaken = d.hits.dealt, d.hits.taken
  o.rare, o.epic = d.gear.rare, d.gear.epic
  o.books = sortedBy(d.books, "t")
  o.letters = d.letters.n or 0
  return o
end

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------
local me   -- the player's GUID, read once
local function myGUID()
  if not me then me = U.Call(UnitGUID, "player") end
  return me
end
local function isPlayerGUID(g) return type(g) == "string" and g:find("^Player%-") ~= nil end

-- Loot: fishing, gathering and crafting. What kind of loot window it was is noted when it
-- opens; the chat lines that follow are counted against it.
local lootKind, lootAt
ns.On("LOOT_OPENED", function()
  lootKind, lootAt = nil, U.Now()
  if U.Call(_G.IsFishingLoot) then lootKind = "fish"; return end
  local ctx = ns.World and ns.World.Context()
  if ctx and U.Now() - ctx.t <= 15 and GATHER[ctx.kind] then lootKind = ctx.kind; return end
  if ctx and ctx.kind == "fishing" and U.Now() - ctx.t <= 40 then lootKind = "fish" end
end)
local QUALITY_HEX = { ["9d9d9d"] = 0, ffffff = 1, ["1eff00"] = 2, ["0070dd"] = 3, a335ee = 4, ff8000 = 5 }
local function quality(msg)
  local q = tonumber(msg:match("|cnIQ(%d+):"))
  if q then return q end
  local hex = msg:match("|cff(%x%x%x%x%x%x)")
  return hex and QUALITY_HEX[hex:lower()] or nil
end
function L.OnLoot(msg)
  msg = ns.World and ns.World.Safe(msg) or msg
  if type(msg) ~= "string" then return end
  local item = msg:match("%[(.-)%]")
  if not item then return end
  local n = tonumber(msg:match("%]|h|rx(%d+)") or msg:match("%]x(%d+)") or msg:match("x(%d+)%.?$")) or 1
  if msg:find("^You create") then
    local ctx = ns.World and ns.World.Context()
    L.Make(item, n, ctx and ctx.kind == "craft" and ctx.detail or nil)
    return
  end
  if not msg:find("^You receive loot") and not msg:find("^You loot") then return end
  if not lootKind or U.Now() - (lootAt or 0) > 10 then return end
  if lootKind == "fish" then L.Fish(item, n, quality(msg)) else L.Gather(lootKind, item, n) end
end
ns.On("CHAT_MSG_LOOT", function(_, msg) L.OnLoot(msg) end)

-- Coin looted: "You loot 2 Silver, 31 Copper", "Your share of the loot is ...".
function L.ParseMoney(msg)
  if type(msg) ~= "string" then return 0 end
  local g = tonumber(msg:match("(%d+) [Gg]old")) or 0
  local s = tonumber(msg:match("(%d+) [Ss]ilver")) or 0
  local c = tonumber(msg:match("(%d+) [Cc]opper")) or 0
  return g * 10000 + s * 100 + c
end
ns.On("CHAT_MSG_MONEY", function(_, msg)
  msg = ns.World and ns.World.Safe(msg) or msg
  L.Money("looted", L.ParseMoney(msg))
end)
ns.On("QUEST_TURNED_IN", function(_, _, _, money) L.Money("quests", tonumber(money)) end)

-- Coin spent and earned at a vendor (and on repairs), a trainer or a flight master, from
-- the purse's changes while that window is open.
local shop, repairCost, lastMoney
local function readRepair() repairCost = tonumber((U.Call(_G.GetRepairAllCost))) end
ns.On("MERCHANT_SHOW", function() shop = "vendor"; readRepair() end)
ns.On("MERCHANT_CLOSED", function() shop = nil end)
ns.On("TRAINER_SHOW", function() shop = "training" end)
ns.On("TRAINER_CLOSED", function() shop = nil end)
ns.On("TAXIMAP_OPENED", function() shop = "flights" end)
ns.On("TAXIMAP_CLOSED", function() if shop == "flights" then shop = nil end end)
function L.OnMoney()
  local m = U.Call(GetMoney)
  if type(m) ~= "number" then return end
  L.Held(m)
  if lastMoney and shop then
    local delta = m - lastMoney
    if delta < 0 then
      if shop == "vendor" and repairCost and repairCost > 0 and -delta == repairCost then L.Money("repairs", -delta)
      else L.Money(shop, -delta) end
    elseif delta > 0 and shop == "vendor" then
      L.Money("sold", delta)
    end
    if shop == "vendor" then readRepair() end
  end
  lastMoney = m
end
ns.On("PLAYER_MONEY", L.OnMoney)

-- System lines: duels and auctions.
local SOLD = type(_G.ERR_AUCTION_SOLD_S) == "string" and ("^" .. _G.ERR_AUCTION_SOLD_S:gsub("%%s", "(.+)"):gsub("%.$", "")) or nil
function L.OnSystem(msg)
  msg = ns.World and ns.World.Safe(msg) or msg
  if type(msg) ~= "string" then return end
  local who = U.Call(UnitName, "player")
  who = type(who) == "string" and who:match("^([^%-]+)") or who
  local winner, loser = msg:match("^(.-) has defeated (.-) in a duel")
  if not winner then
    local fled, other = msg:match("^(.-) has fled from (.-) in a duel")
    if fled then winner, loser = other, fled end
  end
  if winner and who then
    winner, loser = winner:match("^([^%-%s]+)") or winner, loser:match("^([^%-%s]+)") or loser
    if winner == who then L.Duel(true) elseif loser == who then L.Duel(false) end
    return
  end
  if msg:find("^A buyer has been found for your auction of") or (SOLD and msg:find(SOLD)) then
    local d = store()
    if d then d.money.auctions = (d.money.auctions or 0) + 1 end
  end
end
ns.On("CHAT_MSG_SYSTEM", function(_, msg) L.OnSystem(msg) end)

-- Battlegrounds: a result is counted once per battleground entered.
local battleDone
function L.OnBattlefield()
  local winner = U.Call(_G.GetBattlefieldWinner)
  if winner == nil then return end
  if battleDone then return end
  local inside, kind = U.Call(IsInInstance)
  if not inside or kind ~= "pvp" then return end
  battleDone = true
  local faction = U.Call(UnitFactionGroup, "player")
  local won = (winner == 1 and faction == "Alliance") or (winner == 0 and faction == "Horde")
  L.Battle((U.Call(GetInstanceInfo)) or U.Call(GetRealZoneText), won)
end
ns.On("UPDATE_BATTLEFIELD_STATUS", L.OnBattlefield)
ns.On("PLAYER_ENTERING_WORLD", function() battleDone = nil; me = nil end)

-- Inns: resting where the subzone is an inn.
local function checkInn()
  if not U.Call(IsResting) then return end
  local sub = U.Plain(U.Call(GetSubZoneText))
  if sub and ns.World and ns.World.IsInn(sub) then L.Inn(sub) end
end
ns.On("PLAYER_UPDATE_RESTING", checkInn)
ns.On("ZONE_CHANGED", checkInn)
ns.On("ZONE_CHANGED_INDOORS", checkInn)

-- The hearthstone (and Astral Recall).
ns.OnUnit("UNIT_SPELLCAST_SUCCEEDED", "player", function(_, _, _, spellID)
  if spellID == 8690 or spellID == 556 then L.Hearth() end
end)

-- The flight map: every flight master known.
ns.On("TAXIMAP_OPENED", function()
  local n = tonumber((U.Call(_G.NumTaxiNodes))) or 0
  local names = {}
  for i = 1, math.min(n, 200) do
    local kind = U.Call(_G.TaxiNodeGetType, i)
    if kind == "REACHABLE" or kind == "CURRENT" then names[#names + 1] = U.Call(_G.TaxiNodeName, i) end
  end
  if #names > 0 then L.Paths(names) end
end)

-- Mounts: looked at every ten seconds out of a fight, and when the game says it changed.
local wasMounted = false
function L.CheckMount()
  if U.Call(InCombatLockdown) then return end
  local mounted = U.Call(IsMounted) and true or false
  if mounted and not wasMounted and ns.World then
    local auras = ns.World.Auras()
    for name in pairs(auras.names) do
      for _, m in ipairs(ns.Words.MOUNTS) do
        if name:find(m[1]) then L.Mount((name:gsub("^Summon ", ""))); break end
      end
    end
  end
  wasMounted = mounted
end
ns.On("PLAYER_MOUNT_DISPLAY_CHANGED", L.CheckMount)

ns.On("PLAYER_LEVEL_UP", function(_, level) L.Level(level) end)
-- /played, when the player (or another add-on) asks: Auto TRP never asks itself, since
-- asking prints to chat.
ns.On("TIME_PLAYED_MSG", function(_, total, thisLevel) L.Played(total, thisLevel) end)

ns.On("CHAT_MSG_TEXT_EMOTE", function(_, msg)
  msg = ns.World and ns.World.Safe(msg) or msg
  if type(msg) ~= "string" then return end
  local verb = msg:match("^You (%a+)")
  if verb then L.Emote(verb == "burst" and "dance" or verb) end
end)

-- The group: names hashed and counted, never kept. In a fight it waits until the end.
local rosterDirty = false
function L.ScanGroup()
  rosterDirty = false
  local names = {}
  if U.Call(IsInRaid) then
    for i = 1, 40 do local n = U.Call(UnitName, "raid" .. i); if type(n) == "string" then names[#names + 1] = n end end
  elseif U.Call(IsInGroup) then
    for i = 1, 4 do local n = U.Call(UnitName, "party" .. i); if type(n) == "string" then names[#names + 1] = n end end
  end
  local mine = U.Call(UnitName, "player")
  for i = #names, 1, -1 do if names[i] == mine then table.remove(names, i) end end
  L.Group(names)
end
ns.On("GROUP_ROSTER_UPDATE", function()
  if U.Call(InCombatLockdown) then rosterDirty = true else L.ScanGroup() end
end)

-- Coming back: someone else's resurrection, or the spirit healer's.
local rezAsked, spiritAsked
ns.On("RESURRECT_REQUEST", function() rezAsked = U.Now() end)
ns.On("CONFIRM_XP_LOSS", function() spiritAsked = U.Now() end)
local function cameBack()
  if U.Call(UnitIsDeadOrGhost, "player") then return end
  local now = U.Now()
  if rezAsked and now - rezAsked < 120 then L.Rezzed("other")
  elseif spiritAsked and now - spiritAsked < 120 then L.Rezzed("spirit") end
  rezAsked, spiritAsked = nil, nil
end
ns.On("PLAYER_ALIVE", cameBack)
ns.On("PLAYER_UNGHOST", cameBack)

-- A death the world did (a fall, the water): noted on the record's death.
ns.On("PLAYER_DEAD", function()
  if not lastEnv or U.Now() - lastEnv.t > 3 then return end
  local d = store()
  local e = d and d.env[lastEnv.kind]
  if e then e.deaths = (e.deaths or 0) + 1 end
  local deeds = ns.char and ns.char.deeds
  local last = deeds and deeds.deaths and deeds.deaths[#deeds.deaths]
  if last and U.Now() - (last.t or 0) <= 3 then last.cause, last.killer = lastEnv.kind, nil end
  lastEnv = nil
end)

-- Close calls: health under a tenth in a fight, and still standing at the end.
local fighting, lowest, fightFoe, fightNamed = false, 1, nil, false
ns.On("PLAYER_REGEN_DISABLED", function()
  fighting, lowest, fightFoe, fightNamed = true, 1, nil, false
  if U.Call(UnitExists, "target") and U.Call(UnitCanAttack, "player", "target") and not U.PlayerOwned("target") then
    fightFoe = U.Call(UnitName, "target")
    local kind = U.Call(UnitClassification, "target")
    fightNamed = kind ~= nil and kind ~= "normal" and kind ~= "minus" and kind ~= "trivial"
  end
end)
ns.OnUnit("UNIT_HEALTH", "player", function()
  if not fighting then return end
  local hp, max = U.Call(UnitHealth, "player"), U.Call(UnitHealthMax, "player")
  if type(hp) == "number" and type(max) == "number" and max > 0 and hp > 0 and hp / max < lowest then lowest = hp / max end
end)
ns.On("PLAYER_REGEN_ENABLED", function()
  if fighting and lowest < 0.1 and not U.Call(UnitIsDeadOrGhost, "player") then L.CloseCall(fightFoe, fightNamed) end
  fighting, lowest, fightFoe = false, 1, nil
  if rosterDirty then L.ScanGroup() end
end)

-- The combat log: one lookup, and out unless it's one of these. Only the player's own hits
-- and what hits the player; a player's name is never kept.
local WATCH = { SWING_DAMAGE = 1, SPELL_DAMAGE = 2, RANGE_DAMAGE = 2, ENVIRONMENTAL_DAMAGE = 3, PARTY_KILL = 4 }
function L.OnCombatLog(...)
  local _, sub, _, src, srcName, srcFlags, _, dst, _, _, _, a12, a13, _, a15 = ...
  local k = WATCH[sub]
  if not k then return end
  local guid = me or myGUID()
  if k == 4 then
    if src == guid and isPlayerGUID(dst) then L.KillingBlow() end
    return
  end
  if k == 3 then
    if dst == guid then L.Env(a12, a13) end
    return
  end
  local amount = k == 1 and a12 or a15
  if type(amount) ~= "number" then return end
  local hits = ns.char and ns.char.life and ns.char.life.hits
  if not hits then return end
  if src == guid then
    if not hits.dealt or amount > hits.dealt.n then hits.dealt = { n = amount, spell = k == 2 and a13 or nil, t = U.Now() } end
  elseif dst == guid then
    if not hits.taken or amount > hits.taken.n then
      hits.taken = { n = amount, from = not isPlayerGUID(src) and not (type(srcFlags) == "number" and math.floor(srcFlags / 0x100) % 2 == 1) and srcName or nil, t = U.Now() }
    end
  end
end
ns.On("COMBAT_LOG_EVENT_UNFILTERED", function()
  local fn = _G.CombatLogGetCurrentEventInfo
  if type(fn) == "function" then L.OnCombatLog(fn()) end
end)

-- Gear: the first rare and epic piece put on.
local GEAR_SLOTS = { 1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18 }
local function slotItem(slot)
  local link = U.Call(GetInventoryItemLink, "player", slot)
  if not link then return nil end
  local fn = (_G.C_Item and _G.C_Item.GetItemInfo) or _G.GetItemInfo
  local name, _, q = U.Call(fn, link)
  return name, q
end
ns.On("PLAYER_EQUIPMENT_CHANGED", function(_, slot)
  slot = tonumber(slot)
  if not slot then return end
  local name, q = slotItem(slot)
  if name then L.Equip(name, q, slot, false) end
end)

-- Books and letters: a page with a writer is a letter, and its writer isn't kept.
ns.On("ITEM_TEXT_BEGIN", function()
  local title = U.Call(_G.ItemTextGetItem)
  local creator = U.Call(_G.ItemTextGetCreator)
  L.Page(title, type(creator) == "string" and creator ~= "")
end)
-- Letters opened at the mailbox: the count of read letters going up while it's open.
local readBefore
local function readCount()
  local fn = _G.GetInboxHeaderInfo
  local n = tonumber((U.Call(_G.GetInboxNumItems))) or 0
  local read = 0
  for i = 1, math.min(n, 100) do
    local r = { pcall(fn, i) }   -- wasRead is the ninth return
    if r[1] and U.Unsecret(r[10]) == true then read = read + 1 end
  end
  return read
end
ns.On("MAIL_SHOW", function() readBefore = nil end)
ns.On("MAIL_INBOX_UPDATE", function()
  if type(_G.GetInboxHeaderInfo) ~= "function" then return end
  local now = readCount()
  if readBefore and now > readBefore then L.Letters(now - readBefore) end
  readBefore = now
end)

ns.Listen("LOGIN", function()
  if not store() then return end
  L.Held(U.Call(GetMoney))
  lastMoney = U.Call(GetMoney)
  local d = store()
  local lvl = tonumber((U.Call(UnitLevel, "player")))
  if lvl and not d.levels[lvl] then d.levels[lvl] = { t = U.Now(), zone = zone(), start = true } end
  -- Fine gear already worn when the record began isn't news.
  for _, slot in ipairs(GEAR_SLOTS) do
    local name, q = slotItem(slot)
    if name then L.Equip(name, q, slot, true) end
  end
  checkInn()
  ns.Ticker(10, L.CheckMount)
end)
