-- What the character carries, and for how long: companion pets and mount items, toys and
-- novelties, fishing poles, keys, things that start a job, letters and books, recipes not
-- yet learned, grey keepsakes kept for their own sake, the biggest stacks, how full the
-- bags are and what kind of bags they are, and where the hearthstone is set. Each notable
-- thing is remembered from the first time it's seen (when and where), so things kept a long
-- time can be told; things that leave the bags (sold, given, sent, destroyed) are change
-- events. Kept per character in AutoTRPCharDB.pack and read into ns.cache.pack.
--
-- Light by design: the bags are read only after the game says they changed
-- (BAG_UPDATE_DELAYED), at most once every few seconds, and never during a fight (the read
-- waits for it to end). Every list is capped. Other players are never kept: a letter whose
-- title may carry a name is skipped.
local _, ns = ...

local U = ns.U
local W = ns.Words
local P = {}
ns.Sources = ns.Sources or {}
ns.Sources.Pack = P

P.CAP = 120          -- notable things remembered by first sight
P.CAP_EVENTS = 12    -- things gained and lost, newest kept
P.CAP_HOARD = 20     -- stacks watched for a habit
P.GAP = 5            -- seconds between bag reads
P.HEARTHSTONE = 6948
P.KEYRING = -2

local function store()
  if not ns.char then return nil end
  local d = ns.char.pack
  if type(d) ~= "table" then d = {}; ns.char.pack = d end
  d.since = tonumber(d.since) or U.Now()
  for _, k in ipairs({ "items", "events", "hoard" }) do
    if type(d[k]) ~= "table" then d[k] = {} end
  end
  return d
end
P.Store = store

local function zone() return U.Plain(U.Call(_G.GetRealZoneText)) end
local function inCombat()
  return U.Call(_G.InCombatLockdown) == true or U.Call(_G.UnitAffectingCombat, "player") == true
end

---------------------------------------------------------------------------
-- The game's bags, through whichever API this client has
---------------------------------------------------------------------------
local function CC(name) return _G.C_Container and _G.C_Container[name] or _G[name] end

local function numSlots(bag) return tonumber((U.Call(CC("GetContainerNumSlots"), bag))) or 0 end

-- { count, quality, readable, link, noValue, id, bound } or nil for an empty slot.
local function slotInfo(bag, slot)
  local C = _G.C_Container
  if C and C.GetContainerItemInfo then
    local t = U.Call(C.GetContainerItemInfo, bag, slot)
    if type(t) ~= "table" then return nil end
    return { count = t.stackCount, quality = t.quality, readable = t.isReadable, link = t.hyperlink,
      noValue = t.hasNoValue, id = t.itemID, bound = t.isBound }
  end
  local _, count, _, q, readable, _, link, _, noValue, id = U.Call(_G.GetContainerItemInfo, bag, slot)
  if not count and not link then return nil end
  link = link or U.Call(_G.GetContainerItemLink, bag, slot)
  return { count = count, quality = q, readable = readable, link = link, noValue = noValue, id = id }
end

-- Whether the thing in this slot starts a job the character hasn't taken on yet.
local function startsJob(bag, slot)
  local C = _G.C_Container
  if C and C.GetContainerItemQuestInfo then
    local t = U.Call(C.GetContainerItemQuestInfo, bag, slot)
    return type(t) == "table" and type(t.questID) == "number" and t.questID > 0 and not t.isActive
  end
  local _, questID, active = U.Call(_G.GetContainerItemQuestInfo, bag, slot)
  return type(questID) == "number" and questID > 0 and not active
end

-- name, quality, type, subType, sell price: the item's own (the template's), never a link's text.
local function itemInfo(id)
  local fn = (_G.C_Item and _G.C_Item.GetItemInfo) or _G.GetItemInfo
  if type(fn) ~= "function" or not id then return nil end
  local name, _, q, _, _, itype, sub, _, _, _, price = U.CallAll(fn, id)
  return U.Plain(U.Unsecret(name)), U.Unsecret(q), U.Unsecret(itype), U.Unsecret(sub), U.Unsecret(price)
end

-- The bag in slot 1..4 (the backpack has none): its name and kind.
local function bagItem(bag)
  local toInv = CC("ContainerIDToInventoryID")
  local inv = U.Call(toInv, bag)
  if type(inv) ~= "number" then inv = 19 + bag end   -- classic: bags sit in inventory slots 20-23
  local link = U.Call(_G.GetInventoryItemLink, "player", inv)
  local id = type(link) == "string" and tonumber(link:match("item:(%d+)")) or nil
  if not id then return nil end
  local name, q, _, sub = itemInfo(id)
  return name, q, sub
end

---------------------------------------------------------------------------
-- What a thing is
---------------------------------------------------------------------------
local function any(name, pats)
  for _, p in ipairs(pats or {}) do if name:find(p) then return true end end
  return false
end

-- Letters only when their title can't carry anyone's name.
function P.SafeTitle(name)
  if type(name) ~= "string" then return false end
  local K = W.PACK or {}
  if K.LETTERS and K.LETTERS[name] then return true end
  local me = U.Plain(U.Call(_G.UnitName, "player"))
  if me and name:find(me, 1, true) then return false end
  if name:find("%u%l+'s ") or name:find("[Ff]rom %u") or name:find(" [Tt]o %u") or name:find(" [Ff]or %u") then return false end
  return true
end

-- "pet", "mount", "toy", "pole", "key", "recipe", "letter", "book", "keepsake", "hearth" or nil.
function P.Kind(id, name, q, itype, sub, slot, price)
  local K = W.PACK or {}
  if id == P.HEARTHSTONE then return "hearth" end
  if K.TOYS and K.TOYS[name] then return "toy" end
  if (K.PETS and K.PETS[name]) or sub == "Pet" or sub == "Companion Pets" or any(name, K.PET_PATTERNS) then return "pet" end
  if sub == "Mount" or (itype ~= "Trade Goods" and itype ~= "Consumable" and any(name, K.MOUNT_PATTERNS)) then return "mount" end
  if sub == "Fishing Poles" or sub == "Fishing Pole" or name:find("Fishing Pole$") then return "pole" end
  if itype == "Key" or slot.bag == P.KEYRING or name:find(" Key$") then return "key" end
  if itype == "Recipe" or any(name, K.RECIPE_PATTERNS) then return "recipe" end
  if any(name, K.LETTER_PATTERNS) and (slot.readable or (K.LETTERS and K.LETTERS[name])) then
    return P.SafeTitle(name) and "letter" or nil
  end
  if slot.readable then return P.SafeTitle(name) and "book" or nil end
  if q == 0 and (slot.bound or slot.noValue or price == 0) then return "keepsake" end
  return nil
end

-- What a stack is, when there's enough of it to tell: { kind, min } or nil.
function P.StackKind(name, itype, sub)
  for _, s in ipairs((W.PACK or {}).STACKS or {}) do
    local hit = (s.pat and name:find(s.pat)) or (s.type and itype == s.type and (not s.sub or s.sub == sub))
      or (s.sub and not s.type and sub == s.sub)
    if hit then return s end
  end
  return nil
end

---------------------------------------------------------------------------
-- Where things go when they leave the bags: a vendor, the auction house, a trade, the
-- mail, or the bin. Windows are counted a little after they close, since the bags are
-- read a few seconds late.
---------------------------------------------------------------------------
local open, closedAt, deleteAt = {}, {}, 0
local function at(kind) return open[kind] or (U.Now() - (closedAt[kind] or 0) <= 20) end
for kind, ev in pairs({ merchant = { "MERCHANT_SHOW", "MERCHANT_CLOSED" }, bank = { "BANKFRAME_OPENED", "BANKFRAME_CLOSED" },
  mail = { "MAIL_SHOW", "MAIL_CLOSED" }, trade = { "TRADE_SHOW", "TRADE_CLOSED" },
  auction = { "AUCTION_HOUSE_SHOW", "AUCTION_HOUSE_CLOSED" } }) do
  ns.On(ev[1], function() open[kind] = true end)
  ns.On(ev[2], function() open[kind] = nil; closedAt[kind] = U.Now() end)
end
ns.On("DELETE_ITEM_CONFIRM", function() deleteAt = U.Now() end)
function P.SetWindow(kind, isOpen)   -- for tests
  open[kind] = isOpen or nil
  if not isOpen then closedAt[kind] = nil end
end

local function leftHow()
  if at("bank") then return "banked" end
  if U.Now() - deleteAt <= 20 then return "destroyed" end
  if at("merchant") then return "sold" end
  if at("auction") then return "auctioned" end
  if at("mail") then return "sent" end
  if at("trade") then return "given" end
  return "gone"
end

---------------------------------------------------------------------------
-- Reading the bags
---------------------------------------------------------------------------
local function note(d, e)
  d.events[#d.events + 1] = e
  while #d.events > P.CAP_EVENTS do table.remove(d.events, 1) end
end

-- Room for one more: the thing seen longest ago (not carried now, then any) goes.
local function makeRoom(items)
  while U.Count(items) >= P.CAP do
    local lo, lk
    for id, it in pairs(items) do
      local v = (it.here and 1e12 or 0) + (it.last or 0)
      if not lo or v < lo then lo, lk = v, id end
    end
    if not lk then return end
    items[lk] = nil
  end
end

function P.Scan()
  local d = store()
  if not d or inCombat() or numSlots(0) == 0 then return false end   -- no bags to read (yet)
  local now, here = U.Now(), zone()
  local counts, info, kinds, starts = {}, {}, {}, {}
  local slots, free, bags, special = 0, 0, {}, {}
  local incomplete = false
  local bagList = { 0, 1, 2, 3, 4 }
  if numSlots(P.KEYRING) > 0 then bagList[#bagList + 1] = P.KEYRING end
  for _, bag in ipairs(bagList) do
    local n = numSlots(bag)
    if bag ~= P.KEYRING and n > 0 then
      slots = slots + n
      if bag > 0 then
        local name, q, sub = bagItem(bag)
        if name then
          bags[#bags + 1] = { name = name, q = q, sub = sub, slots = n }
          if sub and sub ~= "Bag" and sub ~= "Container" then special[sub] = special[sub] or { name = name, q = q } end
        end
      end
    end
    for s = 1, math.min(n, 40) do
      local it = slotInfo(bag, s)
      if not it then
        if bag ~= P.KEYRING then free = free + 1 end
      else
        local id = tonumber(it.id) or (type(it.link) == "string" and tonumber(it.link:match("item:(%d+)")))
        if id then
          counts[id] = (counts[id] or 0) + (tonumber(it.count) or 1)
          if not info[id] then
            local name, q, itype, sub, price = itemInfo(id)
            if not name then incomplete = true
            else
              q = tonumber(q) or tonumber(it.quality)
              info[id] = { name = name, q = q, type = itype, sub = sub }
              it.bag = bag
              kinds[id] = P.Kind(id, name, q, itype, sub, it, price)
            end
          end
          if startsJob(bag, s) then starts[id] = true end
        end
      end
    end
  end
  d.incomplete = incomplete or nil
  -- Anything that starts a job is worth remembering, whatever else it is.
  for id in pairs(starts) do if info[id] and not kinds[id] then kinds[id] = "quest" end end
  -- Bags that read empty when they weren't a moment ago haven't loaded yet: try again later.
  if next(counts) == nil and d.snap and (d.snap.slots or 0) - (d.snap.free or 0) > 0 then return false end

  -- Notable things: first seen when and where; what's no longer carried has gone somewhere.
  local changed = false
  for id, kind in pairs(kinds) do
    local i, it = info[id], d.items[id]
    if not it then
      makeRoom(d.items)
      it = { name = i.name, q = i.q, kind = kind, first = d.ready and now or d.since, zone = d.ready and here or nil,
        before = not d.ready or nil }
      d.items[id] = it
      changed = true
      if d.ready and kind ~= "keepsake" and kind ~= "hearth" then
        note(d, { kind = "new", what = kind, name = i.name, q = i.q, t = now, zone = here, starts = starts[id] or nil })
      end
    elseif it.banked then
      it.banked, changed = nil, true
    end
    it.here, it.last, it.n, it.kind = true, now, counts[id], kind
    it.starts = starts[id] or nil
  end
  if d.ready and not incomplete then
    local how
    for id, it in pairs(d.items) do
      if it.here and not counts[id] then
        how = how or leftHow()
        it.here = nil
        changed = true
        if how == "banked" then it.banked = true
        else
          local held = now - (it.first or now)
          if held >= 86400 or it.kind == "pet" or it.kind == "mount" or it.kind == "toy" then
            note(d, { kind = how, what = it.kind, name = it.name, q = it.q, t = now, held = held, before = it.before })
          end
          d.items[id] = nil
        end
      end
    end
  end

  -- Stacks: the biggest now, and the ones kept well stocked for days (for a habit).
  local stacks = {}
  for id, n in pairs(counts) do
    local i = info[id]
    local sk = i and P.StackKind(i.name, i.type, i.sub)
    if sk and n > 1 then stacks[#stacks + 1] = { name = i.name, q = i.q, n = n, kind = sk.kind, min = sk.min, mass = sk.mass } end
  end
  table.sort(stacks, function(a, b) if a.n / a.min ~= b.n / b.min then return a.n / a.min > b.n / b.min end return a.name < b.name end)
  for _, st in ipairs(stacks) do
    local h = d.hoard[st.name]
    if st.n >= st.min then
      if not h then
        if U.Count(d.hoard) >= P.CAP_HOARD then
          local lo, lk
          for k, v in pairs(d.hoard) do if not lo or (v.last or 0) < lo then lo, lk = v.last or 0, k end end
          d.hoard[lk] = nil
        end
        h = { first = now, kind = st.kind, q = st.q, mass = st.mass }
        d.hoard[st.name] = h
      end
      h.last, h.n, h.under = now, st.n, nil
    end
  end
  for name, h in pairs(d.hoard) do
    local still = false
    for _, st in ipairs(stacks) do if st.name == name and st.n >= st.min then still = true end end
    if not still then
      h.under = h.under or now
      if now - h.under > 2 * 86400 then d.hoard[name] = nil end
    end
  end
  while #stacks > 3 do table.remove(stacks) end

  local hearth = counts[P.HEARTHSTONE] and U.Plain(U.Call(_G.GetBindLocation)) or nil
  d.snap = { t = now, slots = slots, free = free, bags = bags, special = special, stacks = stacks, hearth = hearth }
  d.ready, d.scanned = true, now
  if changed and ns.Compose then ns.Compose.SourcesChanged() end
  return true
end

-- Read soon, out of combat, at most once every P.GAP seconds.
local pending, waiting, lastScan = false, false, 0
function P.Request()
  if inCombat() then pending = true; return end
  local wait = P.GAP - (U.Now() - lastScan)
  if wait <= 0 then
    lastScan = U.Now(); pending = false
    P.Scan()
  elseif not waiting then
    waiting = true
    ns.After(wait, function() waiting = false; P.Request() end)
  end
end
ns.On("BAG_UPDATE_DELAYED", function() P.Request() end)
ns.On("PLAYER_REGEN_ENABLED", function() if pending then ns.After(2, P.Request) end end)
ns.On("GET_ITEM_INFO_RECEIVED", function()
  local d = ns.char and ns.char.pack
  if d and d.incomplete then P.Request() end
end)
ns.Listen("LOGIN", function()
  if store() then ns.After(4, P.Request) end
end)

---------------------------------------------------------------------------
-- Reading it back: a fresh table each time.
---------------------------------------------------------------------------
function P.Read()
  local d = store()
  if not d or not d.ready then return nil end
  local o = { since = d.since, scanned = d.scanned, carried = {}, byKind = {}, events = {}, hoards = {} }
  local s = d.snap or {}
  o.slots, o.free, o.bags, o.special, o.stacks, o.hearth = s.slots or 0, s.free or 0, s.bags or {}, s.special or {}, s.stacks or {}, s.hearth
  for id, it in pairs(d.items) do
    if it.here then
      local e = { id = id }
      for k, v in pairs(it) do e[k] = v end
      o.carried[#o.carried + 1] = e
    end
  end
  table.sort(o.carried, function(a, b) if (a.first or 0) ~= (b.first or 0) then return (a.first or 0) < (b.first or 0) end return a.name < b.name end)
  for _, e in ipairs(o.carried) do
    o.byKind[e.kind] = o.byKind[e.kind] or {}
    table.insert(o.byKind[e.kind], e)
    if e.starts then o.byKind.starts = o.byKind.starts or {}; table.insert(o.byKind.starts, e) end
  end
  for i = #d.events, 1, -1 do
    local e = {}
    for k, v in pairs(d.events[i]) do e[k] = v end
    o.events[#o.events + 1] = e
  end
  for name, h in pairs(d.hoard) do
    if not h.under then o.hoards[#o.hoards + 1] = { name = name, kind = h.kind, q = h.q, n = h.n or 0, first = h.first, mass = h.mass } end
  end
  table.sort(o.hoards, function(a, b) if a.first ~= b.first then return a.first < b.first end return a.name < b.name end)
  return o
end
