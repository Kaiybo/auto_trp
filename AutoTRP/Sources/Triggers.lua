-- More of the game that moves the mood or says what you're busy with. Every one of these
-- is something the game itself reports: drink taking hold, the post, the auction house,
-- a trade, a hand up from death, a summons, other people's emotes aimed at you, a whisper,
-- an invitation, breath and fatigue in deep water, honour and the end of a battleground,
-- a rare beast or a great foe in your sights, an elite brought down, a guild joined or
-- left, a repair, the stable, the innkeeper, a campfire, a flight landing, a teleport, the
-- weather of a land, going back to where you started, and coming back after a long time.
-- All of it is cheap: no combat log, only events the game sends anyway.
local _, ns = ...

local U = ns.U
local W = ns.Words
local World, Mood = ns.World, ns.Mood
local T = {}
ns.Triggers = T

local function call(name, ...) return U.Call(_G[name], ...) end
local function safe(v) return World.Safe(v) end
local function poke() if ns.UI then ns.UI.Poke(false) end end
local function context(kind, detail) World.SetContext(kind, detail); poke() end
local function push(name, amount, why)
  if not ns.char then return end
  Mood.Push(name, amount, why and U.Pron(why))
end

-- How long each new kind of moment lasts (seconds; the rest keep World's three minutes).
for k, v in pairs({ trade = 60, repair = 90, stable = 60, binder = 60, battlemaster = 60, charter = 60,
  returned = 240, summoned = 120, tipsy = 900, drunk = 900, smashed = 900, landed = 60, campfire = 240,
  teleport = 30, levitate = 60, waterwalk = 90, treasure = 45, firstaid = 30, scrying = 45, questgiver = 60 }) do
  World.CONTEXT_LENGTH[k] = v
end

-- Not more than once in a while per key (so a busy channel or a long fight can't swamp it).
local last = {}
local function every(key, seconds)
  local now = U.Now()
  if last[key] and now - last[key] < seconds then return false end
  last[key] = now
  return true
end
function T.Reset() last = {} end

---------------------------------------------------------------------------
-- The game's own messages, as patterns: "%s" and "%d" in its format strings become
-- captures, so these work in whatever language the game's strings are in.
---------------------------------------------------------------------------
local function escape(s) return (s:gsub("[%%%^%$%(%)%.%[%]%*%+%-%?]", "%%%0")) end
function T.Pattern(fmt)
  if type(fmt) ~= "string" or fmt == "" then return nil end
  local out, i = {}, 1
  while i <= #fmt do
    local a, b = fmt:find("%%%d?%$?[sd]", i)
    if not a then out[#out + 1] = escape(fmt:sub(i)); break end
    out[#out + 1] = escape(fmt:sub(i, a - 1))
    out[#out + 1] = fmt:sub(b, b) == "d" and "(%d+)" or "(.+)"
    i = b + 1
  end
  -- The end is anchored and the full stop optional, so a capture never swallows it.
  local body = table.concat(out):gsub("%(%.%+%)", "(.-)"):gsub("%%%.$", ""):gsub("%s+", "%%s+")
  return "^" .. body .. "%.?$"
end
-- The pattern for a global string, else the English one.
local function pattern(global, english) return T.Pattern(type(_G[global]) == "string" and _G[global] or english) end
local function matches(msg, global, english)
  local p = pattern(global, english)
  if not p then return nil end
  return msg:match(p)
end
local function plainItem(s) return U.Plain(type(s) == "string" and (s:gsub("[%[%]]", "")) or nil) end

---------------------------------------------------------------------------
-- System messages: drink, the auction house, recipes learned.
---------------------------------------------------------------------------
local DRINK = {
  { "DRUNK_MESSAGE_SELF2", "You feel tipsy.", "tipsy", 25, "a drink or two" },
  { "DRUNK_MESSAGE_SELF3", "You feel drunk.", "drunk", 40, "more than a drink or two" },
  { "DRUNK_MESSAGE_SELF4", "You feel completely smashed.", "smashed", 50, "far too much to drink" },
}
local AUCTIONS = {
  { "ERR_AUCTION_SOLD_S", "A buyer has been found for your auction of %s.", "flush", 22, "sold %s at auction" },
  { "ERR_AUCTION_WON_S", "You won an auction for %s", "thrilled", 20, "won %s at auction" },
  { "ERR_AUCTION_OUTBID_S", "You have been outbid on %s.", "frustrated", 10, "outbid on %s" },
  { "ERR_AUCTION_EXPIRED_S", "Your auction of %s has expired.", "frustrated", 8, "no one wanted %s" },
}

function T.System(msg)
  msg = safe(msg)
  if type(msg) ~= "string" then return end
  local lower = msg:lower()
  for _, d in ipairs(DRINK) do
    local g = type(_G[d[1]]) == "string" and _G[d[1]] or nil
    -- The game's line, or its first sentence ("You feel tipsy.  Whee!").
    local head = g and (g:match("^(.-[%.!])") or g)
    if (g and (msg == g or (head and msg:sub(1, #head) == head))) or lower:find("^" .. escape(d[2]:lower())) then
      push("merry", d[4], d[5])
      context(d[3])
      return
    end
  end
  local sober = type(_G.DRUNK_MESSAGE_SELF1) == "string" and _G.DRUNK_MESSAGE_SELF1 or "You feel sober again."
  if msg == sober or lower:find("^you feel sober") then
    local ctx = World.Context()
    if ctx and (ctx.kind == "tipsy" or ctx.kind == "drunk" or ctx.kind == "smashed") then World.SetContext("sober") end
    return
  end
  for _, a in ipairs(AUCTIONS) do
    local item = matches(msg, a[1], a[2])
    if item then
      item = plainItem(item)
      if every("auction" .. a[3] .. (item or ""), 60) then push(a[3], a[4], (a[5]:gsub("%%s", item or "something"))) end
      return
    end
  end
  local recipe = matches(msg, "ERR_LEARN_RECIPE_S", "You have learned how to create a new item: %s.")
  if recipe then push("satisfied", 14, "learned to make " .. (plainItem(recipe) or "something new")) return end
end
ns.On("CHAT_MSG_SYSTEM", function(_, msg) T.System(msg) end)

-- Errors and notices along the top of the screen: a full pack, a trade done.
local function lastString(...)
  local s
  for i = 1, select("#", ...) do local v = select(i, ...); if type(v) == "string" then s = v end end
  return s
end
local tradeOpen = false
ns.On("UI_ERROR_MESSAGE", function(_, ...)
  local msg = lastString(...)
  local full = type(_G.ERR_INV_FULL) == "string" and _G.ERR_INV_FULL or "Inventory is full."
  if msg == full and every("full", 600) then push("burdened", 14, "no room left to carry anything") end
end)
ns.On("UI_INFO_MESSAGE", function(_, ...)
  local msg = lastString(...)
  local done = type(_G.ERR_TRADE_COMPLETE) == "string" and _G.ERR_TRADE_COMPLETE or "Trade complete."
  if msg == done and every("trade", 120) then push("sociable", 12, "struck a deal") end
end)
ns.On("TRADE_SHOW", function() tradeOpen = true; context("trade") end)
ns.On("TRADE_CLOSED", function() tradeOpen = false end)

---------------------------------------------------------------------------
-- Other people: whispers, invitations, emotes aimed at you, a hand up from death.
---------------------------------------------------------------------------
local function social()
  if ns.char and ns.char.mood then ns.char.mood.lastSocial = U.Now() end
end
function T.Whisper(sender)
  social()
  if every("whisper", 900) then push("sociable", 10, "a word in private") end
end
ns.On("CHAT_MSG_WHISPER", function(_, _, sender) T.Whisper(sender) end)
ns.On("CHAT_MSG_BN_WHISPER", function(_, _, sender) T.Whisper(sender) end)
ns.On("PARTY_INVITE_REQUEST", function(_, who)
  social()
  if every("invite", 300) then push("sociable", 16, type(who) == "string" and ("asked along by " .. who) or "asked to join a group") end
end)
local wasGrouped = false
ns.On("GROUP_ROSTER_UPDATE", function()
  local now = (call("IsInGroup") or call("IsInRaid")) and true or false
  if wasGrouped and not now and every("groupleft", 300) then push("lonely", 12, "the group went separate ways") end
  wasGrouped = now
end)

-- "Mirelle waves at you." Only emotes aimed at you, at most once every few minutes per
-- person and feeling.
function T.EmoteAt(msg, sender)
  msg, sender = safe(msg), safe(sender)
  if type(msg) ~= "string" or type(sender) ~= "string" then return false end
  local me = call("UnitName", "player")
  local who = sender:match("^[^%-]+") or sender
  if who == me or msg:find("^You ") then return false end
  local lower = msg:lower()
  if not lower:find("%f[%a]you%f[%A]") then return false end
  local name = lower:match("^(%S+)")
  local rest = name and lower:sub(#name + 2) or lower
  for _, e in ipairs(W.EMOTES_AT) do
    for _, verb in ipairs(e.verbs) do
      if rest:find("^" .. verb) then
        if every("at" .. who .. e.mood, 300) then
          social()
          push(e.mood, e.amount, (e.why:gsub("{who}", who)))
        end
        return true
      end
    end
  end
  return false
end
ns.On("CHAT_MSG_TEXT_EMOTE", function(_, msg, sender) T.EmoteAt(msg, sender) end)

ns.On("RESURRECT_REQUEST", function(_, who)
  who = U.Plain(safe(who))
  push("grateful", 45, who and ("brought back by " .. who) or "brought back from death")
end)
ns.On("PLAYER_UNGHOST", function() context("returned") end)
ns.On("CONFIRM_SUMMON", function() context("summoned") end)

---------------------------------------------------------------------------
-- The world's services: a repair, the stable, the innkeeper, a battlemaster, a charter,
-- a quest-giver's reward.
---------------------------------------------------------------------------
local repairCost = 0
ns.On("MERCHANT_SHOW", function()
  if call("CanMerchantRepair") then
    repairCost = call("GetRepairAllCost") or 0
    if type(repairCost) ~= "number" then repairCost = 0 end
    if repairCost > 0 then context("repair") end
  end
end)
ns.On("MERCHANT_CLOSED", function()
  local now = call("GetRepairAllCost")
  if repairCost > 0 and type(now) == "number" and now == 0 then push("satisfied", 15, "had {their} gear mended") end
  repairCost = 0
end)
ns.On("PET_STABLE_SHOW", function() context("stable") end)
ns.On("CONFIRM_BINDER", function() context("binder") end)
ns.On("BATTLEFIELDS_SHOW", function() context("battlemaster") end)
ns.On("PETITION_SHOW", function() context("charter") end)
local function questgiver()
  local who = U.Plain(safe(call("UnitName", "npc")))
  if who then context("questgiver", who) end
end
ns.On("QUEST_COMPLETE", questgiver)
ns.On("QUEST_PROGRESS", questgiver)
ns.On("QUEST_ACCEPTED", function()
  if every("accepted", 600) then push("determined", 10, "took on a new job") end
end)
ns.On("CHARACTER_POINTS_CHANGED", function(_, change)
  if type(change) == "number" and change < 0 and every("talent", 120) then push("satisfied", 12, "honed {their} craft of war") end
end)

-- The post: new mail waiting (once in a while, not on every check).
ns.On("UPDATE_PENDING_MAIL", function()
  if call("HasNewMail") and every("mail", 1800) then push("newsy", 14, "post waiting") end
end)

-- A fishing catch: the line was worth it.
ns.On("LOOT_OPENED", function()
  if call("IsFishingLoot") then
    World.SetContext("fishing")
    if every("catch", 90) then push("satisfied", 10, "a catch") end
  end
end)

-- A campfire's warmth (the "Cozy Fire" blessing).
local warmed = false
ns.OnUnit("UNIT_AURA", "player", function()
  if call("UnitAffectingCombat", "player") then return end   -- auras churn in a fight; nothing to see
  local auras = World.Auras()
  local by = auras.names and (auras.names["Cozy Fire"] or auras.names["Warmth"]) or false
  if by and not warmed then context("campfire") end
  warmed = by and true or false
end)

-- A flight lands.
local onTaxi = false
ns.On("PLAYER_CONTROL_LOST", function()
  ns.After(1, function() onTaxi = call("UnitOnTaxi", "player") and true or false end)
end)
ns.On("PLAYER_CONTROL_GAINED", function()
  if onTaxi then onTaxi = false; context("landed") end
end)

-- Spells with a moment of their own: teleports, and the ones W.SPELLS can't key by a
-- prefix.
ns.OnUnit("UNIT_SPELLCAST_SUCCEEDED", "player", function(_, _, _, spellID)
  if type(spellID) ~= "number" then return end
  local name = (C_Spell and C_Spell.GetSpellName and U.Call(C_Spell.GetSpellName, spellID)) or call("GetSpellInfo", spellID)
  name = safe(name)
  if type(name) ~= "string" then return end
  local dest = name:match("^Teleport: (.+)$")
  if dest then context("teleport", dest) end
end)

---------------------------------------------------------------------------
-- Deep water: out of breath, or swimming out past the edge of the world.
---------------------------------------------------------------------------
ns.On("MIRROR_TIMER_START", function(_, timer)
  if timer == "BREATH" and every("breath", 300) then push("tense", 14, "held {their} breath under water")
  elseif timer == "EXHAUSTION" and every("fatigue", 300) then push("uneasy", 22, "swam out too far") end
end)

---------------------------------------------------------------------------
-- Battle: honour, a battleground won or lost, a great foe or a rare beast in your sights,
-- an elite brought down.
---------------------------------------------------------------------------
ns.On("CHAT_MSG_COMBAT_HONOR_GAIN", function()
  if ns.char then ns.char.honorKills = (ns.char.honorKills or 0) + 1 end
  if every("honor", 120) then push("fierce", 12, "an enemy of {their} people fell") end
end)
local bgDone = false
ns.On("PLAYER_ENTERING_WORLD", function() bgDone = false end)
function T.Battlefield()
  if bgDone then return end
  local winner = call("GetBattlefieldWinner")
  if type(winner) ~= "number" then return end
  bgDone = true
  local faction = call("UnitFactionGroup", "player")
  local mine = faction == "Horde" and 0 or 1
  local where = U.Plain(call("GetRealZoneText")) or "the battlefield"
  if winner == mine then push("triumphant", 50, "won the battle at " .. U.Mid(where))
  else push("frustrated", 25, "lost the battle at " .. U.Mid(where)) end
end
ns.On("UPDATE_BATTLEFIELD_SCORE", T.Battlefield)

function T.Target()
  if not call("UnitExists", "target") or call("UnitIsPlayer", "target") then return end
  if safe(call("UnitIsDead", "target")) then return end
  local name = U.Plain(safe(call("UnitName", "target")))
  local kind = safe(call("UnitClassification", "target"))
  if not name or type(kind) ~= "string" then return end
  if (kind == "rare" or kind == "rareelite") and every("rare" .. name, 1800) then
    push("thrilled", 22, "spotted " .. name)
  elseif kind == "worldboss" and every("boss" .. name, 1800) then
    push("tense", 25, "face to face with " .. name)
  end
end
ns.On("PLAYER_TARGET_CHANGED", T.Target)

function T.FightOver()
  if not call("UnitExists", "target") or call("UnitIsPlayer", "target") then return end
  if not safe(call("UnitIsDead", "target")) then return end
  local kind = safe(call("UnitClassification", "target"))
  if kind ~= "elite" and kind ~= "rareelite" and kind ~= "worldboss" then return end
  local name = U.Plain(safe(call("UnitName", "target")))
  if name and every("felled" .. name, 600) then push("proud", 18, "brought down " .. name) end
end
ns.On("PLAYER_REGEN_ENABLED", T.FightOver)

---------------------------------------------------------------------------
-- A guild joined or left (after login has settled, so a late roster isn't news).
---------------------------------------------------------------------------
local guild, guildReady = nil, false
function T.Guild()
  local name = U.Plain(safe(call("GetGuildInfo", "player")))
  if not guildReady then guild = name return end
  if name == nil and call("IsInGuild") then return end   -- still loading
  if name and name ~= guild then
    push("sociable", 30, "joined " .. name)
    push("proud", 15)
  elseif not name and guild then
    push("lonely", 18, "left " .. guild)
  end
  guild = name
end
ns.On("PLAYER_GUILD_UPDATE", T.Guild)

---------------------------------------------------------------------------
-- Time away: coming back after days off the road.
---------------------------------------------------------------------------
function T.Seen() if ns.char then ns.char.lastSeen = U.Now() end end
function T.Back()
  if not ns.char then return end
  local before, now = ns.char.lastSeen, U.Now()
  if type(before) == "number" and now - before >= 3 * 86400 then
    local days = math.floor((now - before) / 86400)
    push("determined", 25, "back on the road after " .. U.Number(days) .. " days away")
  end
  ns.char.lastSeen = now
end
ns.On("PLAYER_LOGOUT", T.Seen)
ns.Listen("LOGIN", function()
  T.Back()
  wasGrouped = (call("IsInGroup") or call("IsInRaid")) and true or false
  ns.Ticker(60, T.Seen)
  ns.After(15, function() guildReady = false; T.Guild(); guildReady = true end)
end)

---------------------------------------------------------------------------
-- Live feelings: a land's weather, going back to where you started, a campfire's warmth.
---------------------------------------------------------------------------
table.insert(Mood.Extra, function(world, add)
  local outside = not world.indoors and not world.instance and not world.resting and not world.dead
  local key = world.zoneKey
  if outside and key then
    local cold = W.CLIMATE.cold[key]
    if cold then add("chilled", cold + (world.night and 6 or 0), "the cold of " .. (world.zone or key)) end
    local hot = W.CLIMATE.hot[key]
    if hot and not world.night then add("sweltering", hot + ((world.hour or 0) >= 11 and (world.hour or 0) < 16 and 4 or 0), "the heat of " .. (world.zone or key)) end
  end
  local start = W.START_ZONE[world.race or ""]
  if key and start == key and (world.level or 0) >= 30 and not world.instance then
    add("nostalgic", 16 + math.min(10, ((world.level or 30) - 30) / 3), "back where {they} started")
  end
  local names = world.auras and world.auras.names
  if names and (names["Cozy Fire"] or names["Warmth"]) then add("ease", 15, "by a campfire") end
end)
