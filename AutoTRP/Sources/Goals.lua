-- What the character is working toward, from the game itself: the quest log (the job on
-- hand, chains part-done, dungeon work waiting, jobs nearly done or beyond them), and the
-- state of things (coin for a mount, a craft at the edge of its rank, a reputation close to
-- the next standing, the next level and rank, a class trial at their level).
-- Nothing here needs RPG Dialogue, Social Diary or Chronicle; their goals and threads are
-- added by Compose as extras. Reading is lazy: the quest log, skills and reputations are
-- read again only after the game says they changed, and never during combat.
local _, ns = ...

local U = ns.U
local W = ns.Words
local G = {}
ns.Sources = ns.Sources or {}
ns.Sources.Goals = G
ns.Goals = G

local function inCombat()
  return U.Call(InCombatLockdown) or U.Call(UnitAffectingCombat, "player")
end

---------------------------------------------------------------------------
-- The quest log
---------------------------------------------------------------------------
local log, logDirty = nil, true
local skills, skillsDirty = nil, true
local reps, repsDirty = nil, true

-- "Defias Pillager slain: 7/15" -> 7, 15
local function counts(text)
  if type(text) ~= "string" then return nil end
  local have, need = text:match("(%d+)%s*/%s*(%d+)")
  return tonumber(have), tonumber(need)
end

-- The quest's kind from the game's tag: "dungeon", "raid", "elite" or "group".
local TAG_IDS = { [81] = "dungeon", [62] = "raid", [88] = "raid", [89] = "raid", [1] = "group" }
local function tagOf(third, questID)
  local kind
  if type(third) == "string" then kind = third:lower()
  elseif type(third) == "number" and third > 1 then kind = "group" end
  local fn = _G.GetQuestTagInfo or (C_QuestLog and C_QuestLog.GetQuestTagInfo)
  if questID and type(fn) == "function" then
    local id, name = U.Call(fn, questID)
    if type(id) == "table" then id, name = id.tagID, id.tagName end
    if type(name) == "string" and name ~= "" then kind = name:lower()
    elseif TAG_IDS[id] then kind = TAG_IDS[id] end
  end
  if not kind then return nil end
  for _, k in ipairs({ "dungeon", "raid", "elite", "group" }) do
    if kind:find(k) then return k end
  end
  return nil
end

-- One read of the whole log: { n, quests = { { title, level, header, tag, complete, failed,
-- done, need, finished, objectives, id, index, watched } } }.
function G.ReadLog()
  local out = { n = 0, quests = {} }
  local entries = U.Call(GetNumQuestLogEntries)
  if type(entries) ~= "number" then return out end
  local header
  for i = 1, math.min(entries, 60) do
    local title, level, third, isHeader, _, isComplete, _, questID = U.Call(GetQuestLogTitle, i)
    title = U.Plain(title)
    if title and isHeader then
      header = title
    elseif title then
      local q = { title = title, level = tonumber(level), header = header, index = i,
        id = tonumber(questID), complete = isComplete == 1 or isComplete == true, failed = isComplete == -1 }
      q.tag = tagOf(third, q.id)
      local nb = tonumber(U.Call(GetNumQuestLeaderBoards, i)) or 0
      local have, need, finished = 0, 0, 0
      for j = 1, math.min(nb, 8) do
        local text, _, done = U.Call(GetQuestLogLeaderBoard, j, i)
        local h, n = counts(U.Plain(text))
        if done then finished = finished + 1 end
        if h and n and n > 0 then have, need = have + math.min(h, n), need + n
        else have, need = have + (done and 1 or 0), need + 1 end
      end
      q.objectives, q.finished, q.have, q.need = nb, finished, have, need
      q.progress = need > 0 and have / need or nil
      q.watched = U.Call(IsQuestWatched, i) and true or false
      out.quests[#out.quests + 1] = q
      out.n = out.n + 1
    end
  end
  return out
end

-- The log as last read; read again only after it changed, and not during a fight.
function G.Log()
  if (logDirty or not log) and not inCombat() then
    log = G.ReadLog()
    logDirty = false
  end
  return log or { n = 0, quests = {} }
end

---------------------------------------------------------------------------
-- Skills (with their caps) and reputations (with how far along the bar)
---------------------------------------------------------------------------
function G.Skills()
  if (skillsDirty or not skills) and not inCombat() then
    local out = { list = {}, names = {} }
    local n = tonumber(U.Call(GetNumSkillLines)) or 0
    for i = 1, math.min(n, 80) do
      local name, header, _, rank, _, _, maxRank = U.Call(GetSkillLineInfo, i)
      name = U.Plain(name)
      if name and not header then
        out.names[name] = tonumber(rank) or 0
        if name:find("Riding") then out.riding = math.max(out.riding or 0, tonumber(rank) or 0) end
        if W.GOAL_PROFS[name] and type(rank) == "number" and rank > 0 then
          out.list[#out.list + 1] = { name = name, rank = rank, max = tonumber(maxRank) }
        end
      end
    end
    skills, skillsDirty = out, false
  end
  return skills or { list = {}, names = {} }
end

function G.Reputations()
  if (repsDirty or not reps) and not inCombat() then
    local out = {}
    local function add(name, standing, low, high, value, isHeader, hasRep)
      name = U.Plain(name)
      if not name or (isHeader and not hasRep) then return end
      if type(standing) ~= "number" or type(low) ~= "number" or type(high) ~= "number" or type(value) ~= "number" then return end
      if high <= low then return end
      out[#out + 1] = { name = name, standing = standing, frac = (value - low) / (high - low) }
    end
    if C_Reputation and C_Reputation.GetNumFactions and C_Reputation.GetFactionDataByIndex then
      local n = tonumber(U.Call(C_Reputation.GetNumFactions)) or 0
      for i = 1, math.min(n, 120) do
        local d = U.Call(C_Reputation.GetFactionDataByIndex, i)
        if type(d) == "table" then
          add(U.Unsecret(d.name), d.reaction, d.currentReactionThreshold, d.nextReactionThreshold, d.currentStanding,
            d.isHeader, d.isHeaderWithRep)
        end
      end
    elseif _G.GetNumFactions and _G.GetFactionInfo then
      local n = tonumber(U.Call(GetNumFactions)) or 0
      for i = 1, math.min(n, 120) do
        local name, _, standing, low, high, value, _, _, isHeader, _, hasRep = U.Call(GetFactionInfo, i)
        add(name, standing, low, high, value, isHeader, hasRep)
      end
    end
    reps, repsDirty = out, false
  end
  return reps or {}
end

function G.Invalidate() logDirty, skillsDirty, repsDirty = true, true, true end

---------------------------------------------------------------------------
-- When each open quest was taken on (to know which job is the one on hand)
---------------------------------------------------------------------------
local function taken()
  if not ns.char then return {} end
  if type(ns.char.questsTaken) ~= "table" then ns.char.questsTaken = {} end
  return ns.char.questsTaken
end

function G.Taken(title, t)
  title = U.Plain(title)
  if not title then return end
  local list = taken()
  list[title] = t or U.Now()
  -- Only the open ones matter: forget the rest once there are many.
  local n = U.Count(list)
  if n > 40 and log then
    local open = {}
    for _, q in ipairs(log.quests) do open[q.title] = true end
    for k in pairs(list) do if not open[k] and k ~= title then list[k] = nil end end
  end
end

ns.On("QUEST_ACCEPTED", function(_, a, b)
  local title
  -- Classic sends (log index, quest id); later clients the quest id alone.
  local QL = _G.C_QuestLog
  local id = b or a
  if QL and QL.GetTitleForQuestID and id then title = U.Plain(U.Call(QL.GetTitleForQuestID, id)) end
  if not title and type(a) == "number" and b then title = U.Plain((U.Call(GetQuestLogTitle, a))) end
  logDirty = true
  if title then G.Taken(title) end
  if ns.UI and ns.UI.Poke then ns.UI.Poke(true) end
end)
for _, e in ipairs({ "QUEST_LOG_UPDATE", "UNIT_QUEST_LOG_CHANGED", "QUEST_WATCH_UPDATE" }) do
  ns.On(e, function() logDirty = true end)
end
ns.On("QUEST_REMOVED", function()
  logDirty = true
  if ns.UI and ns.UI.Poke then ns.UI.Poke(true) end
end)
ns.On("QUEST_TURNED_IN", function() logDirty = true end)
ns.On("SKILL_LINES_CHANGED", function() skillsDirty = true end)
ns.On("UPDATE_FACTION", function() repsDirty = true end)

---------------------------------------------------------------------------
-- The ambitions, ranked. Each: { kind, score, key, vars, icon }. Higher scores first:
-- a chain part-done and work waiting in a dungeon outrank a job nearly finished, which
-- outranks coin for a mount, a craft's next rank, a reputation, the next level.
---------------------------------------------------------------------------
G.SCORE = {
  chain = 80, raid = 82, dungeon = 76, ready = 74, ready_many = 72, nearly = 70, classquest = 72, mount_ready = 73, mount = 69,
  mount_far = 52, swift_ready = 71, swift = 64, rankup = 66, prof_cap = 62, prof_near = 58, prof_wait = 50,
  rep = 56, elite = 60, above = 54, current = 48, many = 44, level = 40, level_rested = 42, nextrank = 30,
}
G.HERE = 6   -- bonus for a job in the land they're in now

local function chainOf(title)
  if W.EARNED_QUEST[title] then return title end
  return W.CHAIN_STEPS[title]
end

-- The first class trial at their level they haven't done: { key, level, what, icon } or nil.
function G.ClassQuest(world)
  local level = world.level or 1
  local count = (C_Item and C_Item.GetItemCount) or _G.GetItemCount
  local has = _G.IsPlayerSpell or _G.IsSpellKnown
  local sk = G.Skills()
  for _, g in ipairs(W.GOAL_CLASS[world.class or ""] or {}) do
    if level >= g.level then
      local missing
      if g.spell and type(has) == "function" then
        local ok, known = pcall(has, g.spell)
        if ok and U.Unsecret(known) == false then missing = true end
      elseif g.item and type(count) == "function" then
        local n = U.Call(count, g.item)
        if n == 0 then missing = true end
      elseif g.skill and U.Count(sk.names) > 0 then
        if not sk.names[g.skill] then missing = true end
      end
      if missing then return g end
    end
  end
  return nil
end

function G.Gather(world, c)
  world = world or {}
  local out = {}
  local level = world.level or 1
  local here = world.zone
  local function add(kind, key, vars, extra, icon)
    out[#out + 1] = { kind = kind, key = key, vars = vars or {}, score = (G.SCORE[kind] or 0) + (extra or 0), icon = icon }
  end
  local finished = ns.Compose and ns.Compose.Finished(c) or {}

  -- The quest log
  local ql = G.Log()
  local seenChain, ready = {}, {}
  local whenTaken = taken()
  local latest, latestT
  for _, q in ipairs(ql.quests) do
    local near = (here and q.header == here) and G.HERE or 0
    local chain = chainOf(q.title)
    local def = chain and W.EARNED_QUEST[chain]
    if def and not finished[chain] and not seenChain[chain] and (not def.class or def.class == world.class) then
      seenChain[chain] = true
      add("chain", chain, { chain = W.CHAIN_GOAL[chain] or ("\"" .. chain .. "\""), q = q.title }, (def.tier or 1) * 4 + near, def.icon)
    end
    local place = q.header and W.GOAL_DUNGEONS[q.header]
    if q.complete then
      ready[#ready + 1] = q
    elseif not q.failed then
      if place or q.tag == "dungeon" or q.tag == "raid" then
        local raid = (place and place.raid) or q.tag == "raid"
        add(raid and "raid" or "dungeon", q.title, { q = q.title, place = place and U.Mid(q.header) or nil }, near)
      elseif q.tag == "elite" or q.tag == "group" then
        add("elite", q.title, { q = q.title, zone = q.header and U.Mid(q.header) or nil }, near)
      end
      if q.progress and q.progress >= 0.75 and q.need >= 2 then
        add("nearly", q.title, { q = q.title, left = U.Number(q.need - q.have) }, math.floor(q.progress * 4) + near)
      end
      if q.level and q.level >= level + 5 and not place then
        add("above", q.title, { q = q.title, zone = q.header and U.Mid(q.header) or nil }, math.min(q.level - level, 10))
      end
    end
    local t = whenTaken[q.title]
    if not q.complete and not q.failed and t and (not latestT or t > latestT) then latest, latestT = q, t end
  end
  if #ready == 1 then
    add("ready", ready[1].title, { q = ready[1].title })
  elseif #ready > 1 then
    add("ready_many", "ready", { n = U.Number(#ready), q = ready[1].title }, math.min(#ready, 5))
  end
  if not latest then
    for _, q in ipairs(ql.quests) do
      if not q.complete and not q.failed and (q.watched or (here and q.header == here)) then latest = q; break end
    end
  end
  if latest then add("current", latest.title, { q = latest.title, zone = latest.header and U.Mid(latest.header) or nil }) end
  if ql.n >= 12 then add("many", "many", { n = U.Number(ql.n) }, math.min(ql.n - 12, 8)) end

  -- A mount: the level for it, and coin against the cost.
  if world.mounted and level >= 40 and ns.char then ns.char.hasRidden = true end
  local sk = G.Skills()
  local money = type(world.money) == "number" and world.money or nil
  local nouns = W.GOAL_MOUNT[world.race or ""] or W.GOAL_MOUNT.default
  local classMount = world.class == "PALADIN" or world.class == "WARLOCK"
  local riding = sk.riding or ((ns.char and ns.char.hasRidden) and 75 or nil)
  if money and not classMount then
    local first, swift = W.MOUNT_COST.first, W.MOUNT_COST.swift
    if level >= first.level and not riding then
      local gold = money / 10000
      local kind = gold >= first.gold and "mount_ready" or gold >= first.gold / 4 and "mount" or "mount_far"
      add(kind, "mount", { mount = nouns[1], gold = U.Number(math.floor(gold)), cost = U.Number(first.gold) },
        kind == "mount" and math.floor(gold / first.gold * 4) or 0)
    elseif level >= swift.level and riding and riding < 150 then
      local gold = money / 10000
      if gold >= swift.gold then add("swift_ready", "swift", { mount = nouns[2], cost = tostring(swift.gold) })
      elseif gold >= swift.gold / 4 then
        add("swift", "swift", { mount = nouns[2], gold = U.Number(math.floor(gold)), cost = U.Number(swift.gold) },
          math.floor(gold / swift.gold * 4))
      end
    end
  end

  -- A class trial at their level
  local cq = G.ClassQuest(world)
  if cq then add("classquest", cq.key, { what = cq.what }, 0, cq.icon) end

  -- A craft at the edge of its rank
  local best
  for _, p in ipairs(sk.list) do
    for _, tier in ipairs(W.GOAL_PROF_TIER) do
      local cap = p.max or tier.max
      if cap == tier.max and p.rank >= tier.max - 10 and p.rank <= tier.max then
        local kind = (p.rank >= tier.max - 2) and (level >= tier.level and "prof_cap" or "prof_wait") or "prof_near"
        local cand = { kind = kind, p = p, tier = tier }
        if not best or G.SCORE[kind] > G.SCORE[best.kind] or (kind == best.kind and p.rank > best.p.rank) then best = cand end
        break
      end
    end
  end
  if best then
    local noun = W.PROF_NOUN and W.PROF_NOUN[best.p.name:lower()]
    add(best.kind, best.p.name, { prof = best.p.name:lower(), crafter = noun, next = best.tier.next,
      nextlevel = U.Number(best.tier.level), rank = best.tier.word }, 0, W.GOAL_PROFS[best.p.name])
  end

  -- A reputation close to the next standing
  local closest
  for _, r in ipairs(G.Reputations()) do
    if r.standing >= 4 and r.standing <= 7 and r.frac >= 0.8 and (not closest or r.standing > closest.standing
      or (r.standing == closest.standing and r.frac > closest.frac)) then
      closest = r
    end
  end
  if closest then
    add("rep", closest.name, { faction = W.FactionName(closest.name), standing = W.GOAL_STANDING[closest.standing + 1] },
      closest.standing - 4)
  end

  -- The next level, and the next rank when it comes with it
  local ranks = ns.Compose and ns.Compose.Ranks(world) or {}
  local function band(l) if l >= 60 then return 7 end return math.floor(l / 10) + 1 end
  local nowRank, nextRank = ranks[band(level)], ranks[band(level) + 1]
  local xp = type(world.xp) == "number" and world.xp or 0
  local rested = type(world.rested) == "number" and world.rested > 0
  if level < 60 and nextRank and nextRank ~= nowRank then
    if (level + 1) % 10 == 0 and xp >= 0.5 then
      add("rankup", "rank", { rank = nextRank }, math.floor(xp * 4))
    else
      add("nextrank", "rank", { rank = nextRank })
    end
  end
  if level < 60 and xp >= 0.8 then
    add(rested and "level_rested" or "level", "level", { level = U.Number(level + 1) })
  end

  table.sort(out, function(a, b) if a.score ~= b.score then return a.score > b.score end return tostring(a.key) < tostring(b.key) end)
  return out
end
