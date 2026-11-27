-- The kind of work the character takes on, from the game's own quest windows and log.
-- Each job is sorted, when it's taken and when it's turned in, into one kind: slaying,
-- gathering, delivery, escort, investigation, rescue, bounty, dungeon, class, profession or
-- holiday. The sorting reads the quest log's objective types ("monster", "item", "object",
-- "event"), its header and tag (all languages), and the quest's English text for the rest;
-- on another language the text cues simply find nothing and the objective types decide.
--
-- Also kept: who asked (quest-givers by name: NPCs only, never a player), where, the reward
-- picked when a job offers a choice (coin or kit), jobs a companion shared (counted, never
-- named), escorts seen through and lost, and repeatable turn-ins (counted apart, so a stack
-- of Argent Dawn coins doesn't make a career). Kept per character in AutoTRPCharDB.work and
-- read into ns.cache.work. Nothing is read in combat; every list is capped.
local _, ns = ...

local U = ns.U
local W = ns.Words
local Work = {}
ns.Sources = ns.Sources or {}
ns.Sources.Work = Work

Work.KINDS = { "slaying", "gathering", "delivery", "escort", "investigation", "rescue", "bounty", "dungeon", "class",
  "profession", "holiday" }
Work.CAP_GIVERS = 30   -- quest-givers kept; the least worked for go first
Work.CAP_ZONES = 30    -- lands kept, each with its kinds
Work.CAP_OPEN = 40     -- jobs on hand (the quest log holds fewer)
Work.CAP_REPEATS = 20  -- repeatable jobs kept by title

local function store()
  if not ns.char then return nil end
  local w = ns.char.work
  if type(w) ~= "table" then w = {}; ns.char.work = w end
  w.since = tonumber(w.since) or U.Now()
  for _, k in ipairs({ "kinds", "zones", "givers", "open", "escorts", "rewards", "repeats" }) do
    if type(w[k]) ~= "table" then w[k] = {} end
  end
  w.n = tonumber(w.n) or 0
  w.shared = tonumber(w.shared) or 0
  local e = w.escorts
  e.done, e.failed = tonumber(e.done) or 0, tonumber(e.failed) or 0
  if type(e.log) ~= "table" then e.log = {} end
  local r = w.rewards
  r.coin, r.kit = tonumber(r.coin) or 0, tonumber(r.kit) or 0
  if type(r.armour) ~= "table" then r.armour = {} end
  w.repeats.n = tonumber(w.repeats.n) or 0
  if type(w.repeats.byTitle) ~= "table" then w.repeats.byTitle = {} end
  return w
end
Work.Store = store

local function inCombat()
  return U.Call(InCombatLockdown) or U.Call(UnitAffectingCombat, "player")
end
local function zone() return U.Plain(U.Call(GetRealZoneText)) end
local function changed() if ns.Compose then ns.Compose.SourcesChanged() end end

-- Drops the entries with the lowest score while a keyed table has more than `max`.
local function bound(t, max, score)
  while true do
    local count, worst, wk = 0, nil, nil
    for k, v in pairs(t) do
      count = count + 1
      local s = score(v)
      if not worst or s < worst then worst, wk = s, k end
    end
    if count <= max or not wk then return end
    t[wk] = nil
  end
end
local function byUse(v) return type(v) == "table" and ((tonumber(v.n) or 0) * 1e10 + (tonumber(v.last or v.t) or 0)) or (tonumber(v) or 0) end
local function byTime(v) return type(v) == "table" and (tonumber(v.t) or 0) or 0 end

---------------------------------------------------------------------------
-- Sorting a job into its kind
---------------------------------------------------------------------------
local function has(text, cues)
  if type(text) ~= "string" or text == "" then return false end
  for _, c in ipairs(cues or {}) do if text:find(c) then return true end end
  return false
end

-- info: { title, objective, text, header, tag, nobj, types = { monster = n, item = n, object = n, event = n } }
-- Returns a kind from Work.KINDS, or nil when nothing tells.
function Work.Classify(info)
  if type(info) ~= "table" then return nil end
  local C = W.WORK.CUES
  local header = type(info.header) == "string" and info.header:lower() or nil
  local strong = ((info.title or "") .. " \n " .. (info.objective or "")):lower()
  local all = (strong .. " \n " .. (info.text or "")):lower()
  -- What the log's header and tag say (they work in any language).
  if header and (W.WORK.HOLIDAY[header] or has(header, C.holiday)) then return "holiday" end
  if has(strong, C.holiday) then return "holiday" end
  if header then
    local class = U.Plain(U.Call(UnitClass, "player"))
    if class and header == class:lower() then return "class" end
    if W.WORK.CLASS_HEADERS[header] then return "class" end
    local skills = ns.Goals and ns.Goals.Skills and ns.Goals.Skills().names or {}
    for name in pairs(skills) do if name:lower() == header then return "profession" end end
    if W.WORK.PROF_HEADERS[header] then return "profession" end
  end
  if info.tag == "dungeon" or info.tag == "raid" then return "dungeon" end
  -- The few kinds only the words tell apart.
  if has(strong, C.escort) then return "escort" end
  if has(strong, C.rescue) then return "rescue" end
  if has(strong, C.bounty) then return "bounty" end
  -- Then the objectives themselves.
  local t = info.types or {}
  local monster, item, object, event = t.monster or 0, t.item or 0, t.object or 0, t.event or 0
  if info.nobj == 0 then
    if has(all, C.investigation) and not has(strong, C.delivery) then return "investigation" end
    return "delivery"
  end
  if event > 0 and event >= monster + item + object then
    if has(all, C.escort) then return "escort" end
    if has(all, C.rescue) then return "rescue" end
    return "investigation"
  end
  if monster > 0 and monster >= item + object then
    if has(all, C.bounty) then return "bounty" end
    return "slaying"
  end
  if item + object > 0 then
    if object > item and has(all, C.investigation) then return "investigation" end
    if has(strong, C.delivery) and not has(strong, C.gathering) then return "delivery" end
    return "gathering"
  end
  -- No log to go on (taken before Auto TRP was watching): the words alone, in order.
  for _, k in ipairs({ "escort", "rescue", "bounty", "delivery", "investigation", "slaying", "gathering" }) do
    if has(strong, C[k]) then return k end
  end
  for _, k in ipairs({ "escort", "rescue", "bounty", "investigation", "slaying", "gathering", "delivery" }) do
    if has(all, C[k]) then return k end
  end
  return nil
end

-- One quest in the log, by title or id: its header, tag and objective types.
local function fromLog(title, questID)
  local G = ns.Goals
  if not (G and G.ReadLog) then return nil end
  for _, q in ipairs(G.ReadLog().quests) do
    if (title and q.title == title) or (questID and q.id == questID) then
      local types = {}
      for j = 1, math.min(q.objectives or 0, 8) do
        local _, kind = U.Call(GetQuestLogLeaderBoard, j, q.index)
        if type(kind) == "string" then types[kind] = (types[kind] or 0) + 1 end
      end
      return { title = q.title, header = q.header, tag = q.tag, nobj = q.objectives or 0, types = types, id = q.id }
    end
  end
end

---------------------------------------------------------------------------
-- Recording
---------------------------------------------------------------------------
-- A job taken. info as for Classify, plus giver and where.
function Work.Taken(info)
  local w = store()
  local title = info and U.Plain(info.title)
  if not w or not title then return nil end
  local kind = info.kind or Work.Classify(info)
  local o = w.open[title] or {}
  o.kind = (o.kind == "escort" and o.kind) or kind or o.kind
  o.giver = info.giver or o.giver
  o.zone = info.zone or o.zone or zone()
  o.t = o.t or U.Now()
  w.open[title] = o
  bound(w.open, Work.CAP_OPEN, byTime)
  return o.kind
end

local RUN_GAP = 1800
-- A job turned in. info: { title, giver (who it was handed to), text, again (done before) }.
function Work.TurnedIn(info)
  local w = store()
  local title = info and U.Plain(info.title)
  if not w or not title then return nil end
  local o = w.open[title]
  w.open[title] = nil
  local now = U.Now()
  local giver = (o and o.giver) or info.giver
  local where = (o and o.zone) or info.zone or zone()
  if giver then
    local g = w.givers[giver] or { n = 0 }
    g.n, g.last, g.zone = (g.n or 0) + 1, now, where or g.zone
    w.givers[giver] = g
    bound(w.givers, Work.CAP_GIVERS, byUse)
  end
  -- A job done again: counted apart, by title.
  if info.again then
    local rp = w.repeats
    rp.n = rp.n + 1
    rp.byTitle[title] = (rp.byTitle[title] or 0) + 1
    bound(rp.byTitle, Work.CAP_REPEATS, byUse)
    changed()
    return nil
  end
  local kind = (o and o.kind) or Work.Classify({ title = title, text = info.text })
  if kind then
    w.n = w.n + 1
    w.kinds[kind] = (w.kinds[kind] or 0) + 1
    if where then
      local z = w.zones[where] or { n = 0 }
      z.n, z.last = (z.n or 0) + 1, now
      z[kind] = (z[kind] or 0) + 1
      w.zones[where] = z
      bound(w.zones, Work.CAP_ZONES, byUse)
    end
    local r = w.run
    if type(r) ~= "table" or r.kind ~= kind or r.zone ~= where or now - (r.last or 0) > RUN_GAP then
      r = { kind = kind, zone = where, n = 0, start = now }
      w.run = r
    end
    r.n, r.last = r.n + 1, now
    w.last = { kind = kind, t = now, zone = where, title = title }
    if kind == "escort" then
      w.escorts.done = w.escorts.done + 1
      table.insert(w.escorts.log, { t = now, zone = where, ok = true })
      while #w.escorts.log > 10 do table.remove(w.escorts.log, 1) end
      if ns.Mood then
        ns.Mood.Push("satisfied", 22, "saw an escort home safely" .. (where and (" in " .. U.Mid(where)) or ""))
        ns.Mood.Push("proud", 10)
      end
    end
  end
  changed()
  return kind
end

-- An escort lost: the job failed while the one being guarded was on the road.
local failedAt = {}
function Work.Failed(title)
  local w = store()
  title = U.Plain(title)
  if not w or not title then return false end
  local o = w.open[title]
  if not o or o.kind ~= "escort" then return false end
  local now = U.Now()
  if failedAt[title] and now - failedAt[title] < 10 then return false end
  failedAt[title] = now
  local where = zone() or o.zone
  w.escorts.failed = w.escorts.failed + 1
  table.insert(w.escorts.log, { t = now, zone = where, ok = false })
  while #w.escorts.log > 10 do table.remove(w.escorts.log, 1) end
  if ns.Mood then
    ns.Mood.Push("sorrowful", 28, "lost an escort on the road" .. (where and (" in " .. U.Mid(where)) or ""))
    ns.Mood.Push("bitter", 8)
  end
  changed()
  return true
end

-- A reward chosen from several: kit (a piece the character can use and wear) or coin (the
-- one that sells best, when it isn't something they'd wear).
function Work.Reward(choice)
  local w = store()
  choice = tonumber(choice)
  if not w or not choice or inCombat() then return nil end
  local n = tonumber(U.Call(GetNumQuestChoices)) or 0
  if n < 2 or choice < 1 or choice > n then return nil end
  local best, bestAt, mine = -1, nil, nil
  for i = 1, math.min(n, 10) do
    local _, _, _, _, usable = U.Call(GetQuestItemInfo, "choice", i)
    local link = U.Call(GetQuestItemLink, "choice", i)
    local info = { usable = usable and true or false }
    if link then
      local _, _, _, _, _, class, sub, _, equip, _, price = U.Call(GetItemInfo, link)
      info.sub, info.equip, info.price, info.class = sub, equip, tonumber(price) or 0, class
    end
    info.price = info.price or 0
    if info.price > best then best, bestAt = info.price, i end
    if i == choice then mine = info end
  end
  if not mine then return nil end
  local r = w.rewards
  local kind
  if mine.usable and type(mine.equip) == "string" and mine.equip ~= "" then
    kind = "kit"
    r.kit = r.kit + 1
    if type(mine.sub) == "string" and W.ARMOR[mine.sub] then
      r.armour[mine.sub] = (r.armour[mine.sub] or 0) + 1
    end
  elseif bestAt == choice and best > 0 then
    kind = "coin"
    r.coin = r.coin + 1
  end
  return kind
end

function Work.Shared()
  local w = store()
  if w then w.shared = w.shared + 1 end
end

---------------------------------------------------------------------------
-- Reading
---------------------------------------------------------------------------
local function sorted(t)
  local out = {}
  for k, v in pairs(t or {}) do
    if type(v) == "number" and v > 0 then out[#out + 1] = { kind = k, n = v } end
  end
  table.sort(out, function(a, b) if a.n ~= b.n then return a.n > b.n end return a.kind < b.kind end)
  return out
end

-- A fresh table each time, so what's built from it notices a change.
function Work.Read()
  local w = store()
  if not w then return nil end
  local o = { since = w.since, n = w.n, shared = w.shared, last = w.last, run = w.run }
  o.kinds = sorted(w.kinds)
  o.byKind = {}
  for k, v in pairs(w.kinds) do o.byKind[k] = v end
  -- Where each kind was done most: kind -> { zone, n }.
  o.kindZone, o.topZone = {}, nil
  for z, rec in pairs(w.zones) do
    if type(rec) == "table" then
      if not o.topZone or (rec.n or 0) > o.topZone.n or ((rec.n or 0) == o.topZone.n and z < o.topZone.zone) then
        o.topZone = { zone = z, n = rec.n or 0 }
      end
      for _, k in ipairs(Work.KINDS) do
        local n = tonumber(rec[k]) or 0
        local have = o.kindZone[k]
        if n > 0 and (not have or n > have.n or (n == have.n and z < have.zone)) then o.kindZone[k] = { zone = z, n = n } end
      end
    end
  end
  o.givers = {}
  for name, g in pairs(w.givers) do
    if type(g) == "table" then o.givers[#o.givers + 1] = { name = name, n = g.n or 0, zone = g.zone, last = g.last or 0 } end
  end
  table.sort(o.givers, function(a, b) if a.n ~= b.n then return a.n > b.n end return a.name < b.name end)
  local e = w.escorts
  o.escortsDone, o.escortsFailed = e.done, e.failed
  o.escortLog = {}
  for i, x in ipairs(e.log) do o.escortLog[i] = x end
  for i = #e.log, 1, -1 do
    local x = e.log[i]
    if x.ok and not o.escortLast then o.escortLast = x end
    if not x.ok and not o.escortLost then o.escortLost = x end
  end
  o.coin, o.kit = w.rewards.coin, w.rewards.kit
  o.armour = {}
  for k, v in pairs(w.rewards.armour) do o.armour[k] = v end
  o.repeats = w.repeats.n
  local top, tn
  for title, n in pairs(w.repeats.byTitle) do
    if type(n) == "number" and (not tn or n > tn or (n == tn and title < top)) then top, tn = title, n end
  end
  o.repeatTop, o.repeatTopN = top, tn or 0
  return o
end

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------
-- The quest window: what's being offered (read when it opens), and what's being handed in.
local detail, complete
ns.On("QUEST_DETAIL", function()
  if inCombat() then detail = nil; return end
  local S = ns.Sources.Self
  local shared = U.Call(UnitIsPlayer, "npc") and true or false
  detail = {
    title = U.Plain(U.Call(GetTitleText)), objective = U.Plain(U.Call(GetObjectiveText)), text = U.Plain(U.Call(GetQuestText)),
    giver = not shared and S and S.NPCName and S.NPCName() or nil, shared = shared, zone = zone(), t = U.Now(),
  }
end)

local function accepted(a, b)
  if inCombat() then return false end
  local QL = _G.C_QuestLog
  local id = tonumber(b or a)
  local title
  if QL and QL.GetTitleForQuestID and id then title = U.Plain(U.Call(QL.GetTitleForQuestID, id)) end
  if not title and type(a) == "number" and b then title = U.Plain((U.Call(GetQuestLogTitle, a))) end
  local d = detail
  if d and U.Now() - (d.t or 0) > 600 then d = nil end
  if not title and d then title = d.title end
  if not title then return false end
  local info = fromLog(title, id) or { title = title }
  if d and d.title == title then
    info.objective, info.text, info.giver, info.zone = d.objective, d.text, d.giver, d.zone
    if d.shared then Work.Shared() end
    detail = nil
  end
  Work.Taken(info)
  return true
end
ns.On("QUEST_ACCEPTED", function(_, a, b) accepted(a, b) end)

-- A companion starting an escort asks the group to join it: that job is an escort.
ns.On("QUEST_ACCEPT_CONFIRM", function(_, _, title)
  title = U.Plain(title)
  if not title then return end
  local w = store()
  if not w then return end
  local o = w.open[title] or { t = U.Now(), zone = zone() }
  o.kind = "escort"
  w.open[title] = o
  Work.Shared()
end)

ns.On("QUEST_COMPLETE", function()
  if inCombat() then complete = nil; return end
  local S = ns.Sources.Self
  local title = U.Plain(U.Call(GetTitleText))
  local d = ns.char and ns.char.deeds
  complete = {
    title = title, id = U.Call(GetQuestID), text = U.Plain(U.Call(GetRewardText)),
    giver = S and S.NPCName and S.NPCName() or nil, zone = zone(),
    -- Read before the turn-in lands in Auto TRP's own record of jobs done.
    again = title and d and type(d.quests) == "table" and d.quests[title] ~= nil or false,
  }
end)
ns.On("QUEST_TURNED_IN", function(_, questID)
  local c = complete
  complete = nil
  local QL = _G.C_QuestLog
  local title
  if QL and QL.GetTitleForQuestID and questID then title = U.Plain(U.Call(QL.GetTitleForQuestID, questID)) end
  if c and (not c.id or not questID or c.id == questID) then title = title or c.title else c = nil end
  if not title then return end
  local info = c or {}
  info.title = title
  Work.TurnedIn(info)
end)

-- The reward picked: the game's own call, watched (never changed).
if type(_G.hooksecurefunc) == "function" and type(_G.GetQuestReward) == "function" then
  pcall(hooksecurefunc, "GetQuestReward", function(choice) Work.Reward(choice) end)
end

-- "Escort to the Bridge failed." (the game's own message), for an escort on hand.
local P_FAILED
local function failedTitle(msg)
  if type(msg) ~= "string" then return nil end
  if not P_FAILED then
    local g = type(_G.ERR_QUEST_FAILED_S) == "string" and _G.ERR_QUEST_FAILED_S or "%s failed."
    P_FAILED = "^" .. g:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1"):gsub("%%%%s", "(.+)") .. "$"
  end
  return U.Plain(msg:match(P_FAILED))
end
Work.FailedTitle = failedTitle
ns.On("CHAT_MSG_SYSTEM", function(_, msg) local t = failedTitle(msg); if t then Work.Failed(t) end end)
ns.On("UI_INFO_MESSAGE", function(_, a, b) local t = failedTitle(type(b) == "string" and b or a); if t then Work.Failed(t) end end)

-- Jobs dropped from the log are forgotten from the jobs on hand (a little after login, and
-- never in a fight).
function Work.Tidy()
  local w = store()
  local G = ns.Goals
  if not w or not (G and G.ReadLog) or inCombat() then return end
  local log = G.ReadLog()
  if (log.n or 0) == 0 and U.Count(w.open) > 0 and type(U.Call(GetNumQuestLogEntries)) ~= "number" then return end
  local inLog = {}
  for _, q in ipairs(log.quests) do inLog[q.title] = true end
  for title in pairs(w.open) do if not inLog[title] then w.open[title] = nil end end
end
ns.Listen("LOGIN", function() if store() then ns.After(30, Work.Tidy) end end)

---------------------------------------------------------------------------
-- Words for Compose (History, Personality, Lately, the statistic). The wording itself is in
-- Data/Words.lua (W.WORK).
---------------------------------------------------------------------------
local function pick(pool, key)
  return U.Pick(pool, (ns.char and ns.char.seedName or "") .. ":work:" .. tostring(key))
end
local function fill(line, vars)
  return (line:gsub("{(%a+)}", function(k) if vars and vars[k] ~= nil then return vars[k] end end))
end
local function within(t, s) return type(t) == "number" and t > 0 and U.Now() - t <= s end

-- History's news: an escort seen through or lost lately. recent(t) says whether t is news.
-- Returns { { t, rank, text, key } }.
function Work.News(wk, recent)
  local out = {}
  if not wk then return out end
  local ok, lost = wk.escortLast, wk.escortLost
  if ok and ok.zone and recent(ok.t) then
    out[#out + 1] = { t = ok.t, rank = 5, key = "work:escort", text = fill(pick(W.WORK.EV.escort, ok.t), { zone = U.Mid(ok.zone) }) }
  end
  if lost and lost.zone and recent(lost.t) then
    out[#out + 1] = { t = lost.t, rank = 4, key = "work:escort_lost", text = fill(pick(W.WORK.EV.escort_lost, lost.t), { zone = U.Mid(lost.zone) }) }
  end
  return out
end

-- History's longer record: what most of the work has been (and the next kind, where), and
-- the escorts. told: the news keys already used.
function Work.Record(wk, told)
  local out = {}
  if not wk then return out end
  told = told or {}
  local first, second = wk.kinds[1], wk.kinds[2]
  if first and wk.n >= 12 and first.n >= 6 and first.n / wk.n >= 0.3 then
    local line = pick(W.WORK.MAIN[first.kind], "main:" .. first.kind)
    if second and second.n >= 4 then
      local at = wk.kindZone[second.kind] or wk.topZone
      local pool = W.WORK.THOUGH[second.kind]
      local clause = pool and pick(pool, "though:" .. second.kind)
      if clause and (at or not clause:find("{zone}")) then
        line = line .. ", " .. fill(clause, { zone = at and U.Mid(at.zone) or "" })
      end
    end
    out[#out + 1] = line
  end
  local done, failed = wk.escortsDone or 0, wk.escortsFailed or 0
  local newsOnly = (done + failed <= 1) and (told["work:escort"] or told["work:escort_lost"])
  if not newsOnly then
    local lostAt = wk.escortLost and wk.escortLost.zone and U.Mid(wk.escortLost.zone)
    local vars = { n = U.Number(done), lost = U.Number(failed), zone = lostAt }
    if failed > 0 and lostAt and done >= 1 then
      out[#out + 1] = fill(pick(W.WORK.ESCORTS.mixed, "esc:mixed"), vars)
    elseif failed > 0 and lostAt then
      out[#out + 1] = fill(pick(W.WORK.ESCORTS.lost, "esc:lost"), vars)
    elseif done >= 2 then
      out[#out + 1] = fill(pick(W.WORK.ESCORTS.done, "esc:done"), vars)
    end
  end
  return out
end

-- The quest-giver worked for most, when it's a real pattern and History hasn't already
-- named them among the people the character knows (Sources/Self.lua's friends). named: set of names.
function Work.GiverLine(wk, named)
  if not wk then return nil end
  named = named or {}
  for _, g in ipairs(wk.givers) do
    if g.n < 5 then return nil end
    if not named[g.name] then
      local second = wk.givers[2]
      -- A clear favourite only: not one of several worked for about as often.
      if g == wk.givers[1] and second and second.n >= g.n then return nil end
      return fill(pick(W.WORK.GIVER, "giver:" .. g.name), { who = g.name, zone = g.zone and U.Mid(g.zone) or "" })
    end
  end
  return nil
end

-- Habits for Personality: { { score, key, pool } }, as Compose.Habits takes them.
function Work.Habits(wk)
  local out = {}
  if not wk then return out end
  local H = W.WORK.HABIT
  local function add(score, key) if H[key] then out[#out + 1] = { score = score, key = "work_" .. key, pool = H[key] } end end
  local total = wk.n or 0
  local by = wk.byKind or {}
  local function share(k) return total > 0 and (by[k] or 0) / total or 0 end
  if (by.delivery or 0) >= 15 and share("delivery") >= 0.25 then add(2.4, "courier") end
  if (by.slaying or 0) >= 30 and share("slaying") >= 0.55 then add(1.6, "slaying") end
  if (by.gathering or 0) >= 25 and share("gathering") >= 0.4 then add(1.6, "gathering") end
  if (by.investigation or 0) >= 12 and share("investigation") >= 0.2 then add(1.8, "investigation") end
  if (by.bounty or 0) >= 6 then add(1.9, "bounty") end
  if (wk.escortsDone or 0) >= 5 then add(2.1, "escort") end
  if (wk.coin or 0) >= 5 and wk.coin >= 2 * (wk.kit or 0) then add(2.2, "coin")
  elseif (wk.kit or 0) >= 8 and wk.kit >= 3 * (wk.coin or 0) then add(1.4, "kit") end
  if (wk.repeats or 0) >= 10 then add(1.7, "repeat") end
  if (wk.shared or 0) >= 10 then add(1.3, "shared") end
  return out
end

-- Lately: an escort just seen through or lost, or a run of the same kind of job.
-- Returns a list of { t, prio, g } candidates, as Compose.LatelyGlance takes them.
function Work.Lately(wk)
  local out = {}
  if not wk then return out end
  local L = W.WORK.LATELY
  local ok, lost = wk.escortLast, wk.escortLost
  if ok and ok.zone and within(ok.t, 1800) then
    out[#out + 1] = { t = ok.t, prio = 2, g = { TI = "Seen Safely Through", IC = "Ability_Rogue_Sprint",
      TX = U.Pron(fill(pick(L.escort, ok.t), { zone = U.Mid(ok.zone) })) } }
  end
  if lost and lost.zone and within(lost.t, 7200) then
    out[#out + 1] = { t = lost.t, prio = 2, g = { TI = "Lost on the Road", IC = "Spell_Holy_Resurrection",
      TX = U.Pron(fill(pick(L.escort_lost, lost.t), { zone = U.Mid(lost.zone) })) } }
  end
  local r = wk.run
  if r and r.zone and (r.n or 0) >= 3 and within(r.last, 1800) and r.kind ~= "escort" then
    local pool = L["run_" .. r.kind] or L.run
    out[#out + 1] = { t = r.last, prio = 1, g = { TI = W.WORK.RUN_TITLE[r.kind] or "Odd Jobs", IC = "INV_Misc_Note_06",
      TX = U.Pron(U.Cap(fill(pick(pool, r.start), { zone = U.Mid(r.zone), n = U.Number(r.n) }))) } }
  end
  return out
end

-- The "Work by kind" statistic: "120 slaying, 64 gathering, 31 courier and 6 escort; 1 escort lost".
function Work.Stat(wk, figure)
  if not wk or #wk.kinds == 0 then return nil end
  figure = figure or tostring
  local parts = {}
  for i = 1, math.min(4, #wk.kinds) do
    local k = wk.kinds[i]
    parts[i] = figure(k.n) .. " " .. (W.WORK.STAT[k.kind] or k.kind)
  end
  local s = table.concat(parts, ", ")
  if (wk.escortsFailed or 0) > 0 then
    s = s .. "; " .. figure(wk.escortsFailed) .. " " .. (wk.escortsFailed == 1 and "escort" or "escorts") .. " lost"
  end
  return s
end
