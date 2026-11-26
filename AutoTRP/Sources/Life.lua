-- Auto TRP's own record of the character's everyday life, straight from the game, so the
-- profile doesn't need another addon for it: creatures slain (and the kind most often put
-- down), books read, where the hearthstone is set (and since when), drink, and the players
-- the character has travelled with. RPG Dialogue and Social Diary say more when they're
-- there; this is what the game alone can tell. Kept per character in AutoTRPCharDB.life.
local _, ns = ...

local U = ns.U
local L = {}
ns.Sources = ns.Sources or {}
ns.Sources.Life = L

L.KEEP_KINDS = 300       -- creature kinds remembered by name (the count goes on regardless)
L.KEEP_PEOPLE = 200      -- companions remembered
L.KEEP_BOOKS = 200

local function store()
  if not ns.char then return nil end
  local d = ns.char.life
  if type(d) ~= "table" then d = {}; ns.char.life = d end
  for _, k in ipairs({ "kinds", "books", "people" }) do
    if type(d[k]) ~= "table" then d[k] = {} end
  end
  d.kills = tonumber(d.kills) or 0
  return d
end

local function changed() if ns.Compose then ns.Compose.SourcesChanged() end end

-- Drops the entry with the smallest key(v) once a table holds more than max.
local function trim(t, max, key)
  local n = 0
  for _ in pairs(t) do n = n + 1 end
  while n > max do
    local low, lv
    for k, v in pairs(t) do
      local x = key(v)
      if not lv or x < lv then low, lv = k, x end
    end
    if not low then return end
    t[low] = nil
    n = n - 1
  end
end

---------------------------------------------------------------------------
-- Creatures slain
---------------------------------------------------------------------------
function L.Kill(name, t)
  local d = store()
  if not d then return end
  d.kills = d.kills + 1
  name = U.Plain(name)
  if name then
    local k = d.kinds[name]
    if type(k) ~= "table" then k = { n = 0 }; d.kinds[name] = k end
    k.n = k.n + 1; k.t = t or U.Now()
    trim(d.kinds, L.KEEP_KINDS, function(v) return v.n end)
  end
end

-- A kill from the combat log (Deeds.lua reads the log once for both). Creatures only:
-- players and their pets are not "creatures slain".
function L.PartyKill(srcGUID, dstGUID, dstName, playerGUID)
  if type(dstGUID) ~= "string" or not (dstGUID:find("^Creature") or dstGUID:find("^Vehicle")) then return end
  if srcGUID and (srcGUID == playerGUID or srcGUID == U.Call(UnitGUID, "pet")) then L.Kill(dstName) end
end

---------------------------------------------------------------------------
-- Books, plaques and letters read in the world
---------------------------------------------------------------------------
function L.Book(title, t)
  local d = store()
  title = U.Plain(title)
  if not d or not title then return end
  local b = d.books[title]
  if type(b) ~= "table" then b = { n = 0, first = t or U.Now() }; d.books[title] = b; changed() end
  b.n = b.n + 1; b.t = t or U.Now()
  trim(d.books, L.KEEP_BOOKS, function(v) return v.t or 0 end)
end
ns.On("ITEM_TEXT_BEGIN", function()
  -- Mail opened from the mailbox also shows item text; that's a letter, not a book.
  if _G.MailFrame and _G.MailFrame.IsShown and U.Call(_G.MailFrame.IsShown, _G.MailFrame) then return end
  L.Book(U.Call(ItemTextGetItem))
end)

---------------------------------------------------------------------------
-- Home: where the hearthstone is set
---------------------------------------------------------------------------
function L.Home(bind, t)
  local d = store()
  bind = U.Plain(bind)
  if not d or not bind or d.home == bind then return end
  if d.home then d.homePrev = d.home; d.homeSince = t or U.Now() else d.homeSince = t or 1 end
  d.home = bind
  changed()
end
local function checkHome() L.Home(U.Call(GetBindLocation)) end
ns.On("PLAYER_ENTERING_WORLD", checkHome)
ns.On("HEARTHSTONE_BOUND", checkHome)

---------------------------------------------------------------------------
-- Drink: the game's own "You feel tipsy" lines
---------------------------------------------------------------------------
function L.Drunk(level, t)
  local d = store()
  if not d then return end
  d.drunk = math.max(0, tonumber(level) or 0)
  d.drunkAt = t or U.Now()
  changed()
end
ns.On("CHAT_MSG_SYSTEM", function(_, msg)
  if type(msg) ~= "string" then return end
  for i = 1, 4 do
    local line = _G["DRUNK_MESSAGE_SELF" .. i]
    if type(line) == "string" and msg == line then L.Drunk(i - 1) return end
  end
end)

---------------------------------------------------------------------------
-- Companions: players grouped with, by the days they were seen together
---------------------------------------------------------------------------
local function day(t) return math.floor((t or U.Now()) / 86400) end

function L.Companion(name, class, t)
  local d = store()
  name = U.Plain(name)
  if not d or not name then return end
  t = t or U.Now()
  local p = d.people[name]
  if type(p) ~= "table" then p = { first = t, days = 0 }; d.people[name] = p end
  if day(p.last) ~= day(t) or not p.last then p.days = p.days + 1 end
  p.last = t
  p.class = U.Plain(class) or p.class
  trim(d.people, L.KEEP_PEOPLE, function(v) return (v.days or 0) * 1e10 + (v.last or 0) end)
end

local lastRoster = 0
local function roster()
  local now = U.Now()
  if now - lastRoster < 30 then return end   -- a burst of roster updates counts once
  lastRoster = now
  local raid = U.Call(IsInRaid)
  local n = raid and (U.Call(GetNumGroupMembers) or 0) or (U.Call(GetNumSubgroupMembers) or 0)
  if n == 0 then return end
  local me = U.Call(UnitName, "player")
  for i = 1, math.min(n, 40) do
    local unit = (raid and "raid" or "party") .. i
    if U.Call(UnitIsPlayer, unit) then
      local name = U.Call(UnitName, unit)
      if name and name ~= me and name ~= _G.UNKNOWNOBJECT then
        local _, class = U.Call(UnitClass, unit)
        L.Companion(name, class, now)
      end
    end
  end
end
ns.On("GROUP_ROSTER_UPDATE", roster)

---------------------------------------------------------------------------
-- Duels: the game's own "X has defeated Y in a duel" lines
---------------------------------------------------------------------------
function L.Duel(won, other, t)
  local d = store()
  if not d then return end
  d.duels = type(d.duels) == "table" and d.duels or { won = 0, lost = 0 }
  if won then d.duels.won = (d.duels.won or 0) + 1 else d.duels.lost = (d.duels.lost or 0) + 1 end
  d.duels.last = { won = won, other = U.Plain(other), t = t or U.Now() }
  changed()
end

-- A global format string ("%1$s has defeated %2$s in a duel") as a pattern capturing the
-- winner and the loser in that order.
local function duelPattern(fmt, winnerFirst)
  if type(fmt) ~= "string" then return nil end
  local order, pat = {}, fmt:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
  pat = pat:gsub("%%%%(%d)%%%$s", function(n) order[#order + 1] = tonumber(n); return "(.+)" end)
  pat = pat:gsub("%%%%s", function() order[#order + 1] = #order + 1; return "(.+)" end)
  return { pat = "^" .. pat .. "$", order = order }
end
local duelLines
ns.On("CHAT_MSG_SYSTEM", function(_, msg)
  if type(msg) ~= "string" then return end
  if not duelLines or #duelLines == 0 then
    duelLines = {}
    for _, fmt in ipairs({ _G.DUEL_WINNER_KNOCKOUT, _G.DUEL_WINNER_RETREAT }) do
      duelLines[#duelLines + 1] = duelPattern(fmt)
    end
  end
  local me = U.Call(UnitName, "player")
  for _, p in ipairs(duelLines) do
    local caps = { msg:match(p.pat) }
    if #caps == 2 then
      local winner, loser = caps[p.order[1] == 1 and 1 or 2], caps[p.order[1] == 1 and 2 or 1]
      winner, loser = winner:match("^([^%-]+)") or winner, loser:match("^([^%-]+)") or loser   -- no realm
      local won = winner == me
      if won or loser == me then
        L.Duel(won, won and loser or winner)
        if ns.Mood and ns.Mood.Duel then ns.Mood.Duel(won, won and loser or winner) end
      end
      return
    end
  end
end)

---------------------------------------------------------------------------
-- Fishing: each catch is a loot window the game marks as fishing loot
---------------------------------------------------------------------------
function L.Catch(t)
  local d = store()
  if not d then return end
  d.fish = (tonumber(d.fish) or 0) + 1
  d.fishAt = t or U.Now()
end
ns.On("LOOT_OPENED", function()
  if U.Call(IsFishingLoot) then L.Catch() end
end)

---------------------------------------------------------------------------
-- Flights: a trip on a flight path, counted once it's under way
---------------------------------------------------------------------------
function L.Flight(t)
  local d = store()
  if not d then return end
  d.flights = (tonumber(d.flights) or 0) + 1
  d.flightAt = t or U.Now()
end
local flying = false
ns.On("PLAYER_CONTROL_LOST", function()
  ns.After(1, function()
    if not flying and U.Call(UnitOnTaxi, "player") then flying = true; L.Flight() end
  end)
end)
ns.On("PLAYER_CONTROL_GAINED", function() flying = false end)

---------------------------------------------------------------------------
-- Reading
---------------------------------------------------------------------------
-- { kills, grudge = { name, n }, books = { { title, n } }, home, homePrev, homeSince,
--   drunk, drunkAt, companions = { { name, class, days, last } } (most days first),
--   recentPeople (grouped with in the last week) }
function L.Read()
  local d = store()
  if not d then return nil end
  local out = { kills = d.kills, books = {}, companions = {}, recentPeople = 0,
    home = d.home, homePrev = d.homePrev, homeSince = d.homeSince,
    drunk = tonumber(d.drunk) or 0, drunkAt = tonumber(d.drunkAt) or 0,
    fish = tonumber(d.fish) or 0, flights = tonumber(d.flights) or 0,
    duelsWon = type(d.duels) == "table" and d.duels.won or 0, duelsLost = type(d.duels) == "table" and d.duels.lost or 0,
    lastDuel = type(d.duels) == "table" and d.duels.last or nil }
  for name, k in pairs(d.kinds) do
    if type(k) == "table" and (not out.grudge or k.n > out.grudge.n or (k.n == out.grudge.n and name < out.grudge.name)) then
      out.grudge = { name = name, n = k.n }
    end
  end
  for title, b in pairs(d.books) do
    if type(b) == "table" then out.books[#out.books + 1] = { title = title, n = b.n or 1 } end
  end
  table.sort(out.books, function(x, y) if x.n ~= y.n then return x.n > y.n end return x.title < y.title end)
  local week = U.Now() - 7 * 86400
  for name, p in pairs(d.people) do
    if type(p) == "table" then
      out.companions[#out.companions + 1] = { name = name, class = p.class, days = p.days or 1, last = p.last or 0 }
      if (p.last or 0) >= week then out.recentPeople = out.recentPeople + 1 end
    end
  end
  table.sort(out.companions, function(x, y)
    if x.days ~= y.days then return x.days > y.days end
    if x.last ~= y.last then return x.last > y.last end
    return x.name < y.name
  end)
  return out
end
