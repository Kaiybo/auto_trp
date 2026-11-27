-- Turns everything the sources know into the words for each profile field.
-- Say it in-world, say it plainly, and leave out what isn't known rather than padding. The
-- character's name is the subject of sentences; pronouns only ever appear as {their}/{them}
-- and come from Total RP 3's pronoun field (they/them otherwise).
local _, ns = ...

local U = ns.U
local W = ns.Words
local Compose = {}
ns.Compose = Compose

ns.cache = {}

-- The other addons' data is read again only when it has changed (the pulse in UI.lua
-- notices) or once a minute; the game's own state is cheap and read every time.
local sourcesAt = 0
function Compose.SourcesChanged() sourcesAt = 0 end

-- Quests seen through and masters brought down, from Chronicle and from Auto TRP's own
-- record (Sources/Deeds.lua) together: whichever saw it first has the time.
local merged = {}
local function mergedFor(c)
  if merged.chron == c.chronicle and merged.deeds == c.deeds and merged.finished then return merged end
  local finished, byName = {}, {}
  local sources = { c.chronicle or false, c.deeds or false }   -- either can be missing
  for _, src in ipairs(sources) do
    for title, q in pairs(src and src.finished or {}) do
      local have = finished[title]
      if not have or (q.t or 0) < (have.t or 0) then finished[title] = { t = q.t or 0, zone = q.zone or (have and have.zone) } end
    end
    for _, b in ipairs(src and src.bosses or {}) do
      local have = byName[b.name]
      local first = b.first or b.t or 0
      if not have then
        byName[b.name] = { name = b.name, first = first, t = b.t or 0, where = b.where }
      else
        if first > 0 and (have.first == 0 or first < have.first) then have.first = first end
        if (b.t or 0) > have.t then have.t = b.t end
        have.where = have.where or b.where
      end
    end
  end
  local bosses = {}
  for _, b in pairs(byName) do bosses[#bosses + 1] = b end
  table.sort(bosses, function(a, b) if a.t ~= b.t then return a.t > b.t end return a.name < b.name end)
  local count = 0
  for _ in pairs(finished) do count = count + 1 end
  local lastQuest = c.chronicle and c.chronicle.lastQuest
  local own = c.deeds and c.deeds.lastQuest
  if own and (not lastQuest or (own.t or 0) > (lastQuest.t or 0)) then lastQuest = own end
  merged = { chron = c.chronicle, deeds = c.deeds, finished = finished, bosses = bosses, lastQuest = lastQuest,
    questsDone = math.max(c.chronicle and c.chronicle.questsDone or 0, count) }
  return merged
end
-- Every quest finished: title -> { t, zone }.
function Compose.Finished(c) return mergedFor(c or ns.cache).finished end
-- Every master brought down, the latest first: { name, first, t (latest), where }.
function Compose.Bosses(c) return mergedFor(c or ns.cache).bosses end
function Compose.QuestsDone(c) return mergedFor(c or ns.cache).questsDone end
-- The latest quest turned in, from either record: { title, t, zone } or nil.
function Compose.LastQuest(c) return mergedFor(c or ns.cache).lastQuest end

function Compose.Refresh()
  local S = ns.Sources
  local c = ns.cache
  local now = U.Now()
  c.world = ns.World.Snapshot()
  if now - sourcesAt >= 60 or not c.read then
    c.rpgd = S.RPGD.Read()
    c.sd = S.SocialDiary.Read()
    c.chronicle = S.Chronicle.Read()
    c.deeds = S.Deeds.Read()
    c.self = S.Self and S.Self.Read(c) or nil
    c.life = S.Life and S.Life.Read() or nil
    sourcesAt, c.read = now, true
  end
  -- The company is the game's own (cheap: a party is five units, a raid forty); Social
  -- Diary friends are only matched by name in memory, and only when naming them is allowed.
  local friendNames
  if c.sd and ns.db.nameFriends then
    friendNames = {}
    for _, f in ipairs(c.sd.friends or {}) do friendNames[f.name] = true end
  end
  c.company = S.Company and S.Company.Read(c.world, friendNames) or nil
  c.t = now
  return c
end

-- The character as a person: RPG Dialogue's reading (choices, stories, standing, people)
-- where it has one, Auto TRP's own reading of what the player does (Sources/Self.lua)
-- wherever it hasn't. Same shape either way; `own` is true when there's no RPG Dialogue.
-- A choice made in RPG Dialogue outranks a habit, so each part is filled, never mixed.
local persona = {}
function Compose.Persona(c)
  c = c or ns.cache
  local r, s = c.rpgd, c.self
  if not s or not r then return r or s end
  if persona.r == r and persona.s == s then return persona.p end
  local p = setmetatable({}, { __index = r })
  local function empty(t) return type(t) ~= "table" or next(t) == nil end
  local a = r.align or {}
  if (a.light or 0) == 0 and (a.order or 0) == 0 and (a.honor or 0) == 0 then
    p.align = { light = s.align.light, order = s.align.order, honor = s.align.honor, taint = a.taint or 0 }
  end
  local any = false
  for _, v in pairs(r.traits or {}) do if v ~= 0 then any = true end end
  if not any then p.traits, p.dominant = s.traits, s.dominant end
  for _, k in ipairs({ "towns", "friends", "threads", "cleared", "books", "zones", "deaths" }) do
    if empty(r[k]) then p[k] = s[k] end
  end
  if not r.lastTalk then p.lastTalk = s.lastTalk end
  if (s.drunkAt or 0) > (r.drunkAt or 0) then p.drunk, p.drunkAt = s.drunk, s.drunkAt end
  p.start = s.start
  persona = { r = r, s = s, p = p }
  return p
end

local function seed(key)
  return (ns.char and ns.char.seedName or "") .. ":" .. key
end

-- A way of saying something, from W.SAY: picked per character and per `which` (an event's
-- time, say), with {placeholders} filled from vars. Pronoun tags are left for U.Pron.
local function say(key, vars, which)
  local line = U.Pick(W.SAY[key], seed("say:" .. key .. ":" .. tostring(which or "")))
  return (line:gsub("{(%a+)}", function(k) if vars and vars[k] ~= nil then return vars[k] end end))
end

local function firstName()
  return (ns.TRP and ns.TRP.FirstName and ns.TRP.FirstName()) or U.Call(UnitName, "player") or "This one"
end

local function within(t, seconds)
  return type(t) == "number" and t > 0 and U.Now() - t <= seconds
end

local function article(word)
  return (word:lower():match("^[aeiou]") and "an " or "a ") .. word
end

local function band(level)
  level = level or 1
  if level >= 60 then return 7 end
  return math.floor(level / 10) + 1
end

local function seasoned(level, key)
  for _, b in ipairs(W.SEASONED) do
    if (level or 1) <= b.max then return U.Pick(b.words, seed(key)) end
  end
end

local function deathCount(c)
  return math.max(c.rpgd and c.rpgd.deathCount or 0, c.chronicle and c.chronicle.deathCount or 0, c.deeds and c.deeds.deathCount or 0)
end

local function sentence(s)
  s = U.Cap(U.Pron(s))   -- after the pronouns: "{their} Crown" opens a sentence as "His Crown"
  local tail = s:gsub("{/col}$", "")
  if not (tail:find("[%.!%?]$") or tail:find("[%.!%?]\"$")) then s = s .. "." end
  return s
end

---------------------------------------------------------------------------
-- Currently
---------------------------------------------------------------------------
function Compose.Intent()
  local it = ns.char and ns.char.intent
  if type(it) == "table" and it.text and (not it.untilT or U.Now() < it.untilT) then return it.text end
  return nil
end

-- Total RP 3 shows Currently in tooltips: keep it to a couple of lines. One sentence: the
-- mood, what they're doing and where, the hour, and at most two things that go with it
-- (a shape, company, a pet, a fishing pole); then, when something lingers (resurrection
-- sickness, a queue, a sign hung out, a festival in town), a short second sentence. When it
-- runs long, the hour goes first, then the second extra, the aside, the first, the second mood.
Compose.CURRENTLY_MAX = 200

function Compose.Currently(mood)
  local world = ns.cache.world
  local s = seed("act:" .. (world.zone or "") .. (world.subzone or ""))
  local intent = Compose.Intent()
  local m = ns.World.Moment(world, s)
  local tod = not m.timed and ns.World.TimeOfDay(world, s) or nil
  local ex = m.extras
  -- Never the same word twice in one line ("Taking it all in ..., taking a room at the inn"):
  -- another way to say the mood when the place line has the adjective's word, and no second
  -- feeling that repeats one.
  local function words(text)
    local w = {}
    for x in (text or ""):lower():gmatch("%a+") do if #x >= 4 then w[(#x > 4 and x:gsub("s$", "")) or x] = true end end
    return w
  end
  -- A shared word, or one phrase ending on the word the next begins with ("Shaken up, up on Elder Rise").
  local function clash(a, b)
    local wa = words(a)
    for x in pairs(words(b)) do if wa[x] then return true end end
    local last, first = (a or ""):lower():match("(%a+)%A*$"), (b or ""):lower():match("^%A*(%a+)")
    return last ~= nil and last == first
  end
  local adj, also = mood.adj, mood.also
  if adj and clash(adj, m.main) then
    local def = W.MOODS[mood.key] or (mood.key and W.CALM[mood.key:gsub("^calm:", "")])
    for _, a in ipairs(U.BackedList(def and def.adj, world)) do
      a = U.Pron(a)
      if not clash(a, m.main) and not (also and clash(a, also)) then adj = a; break end
    end
  end
  if also and clash(also, m.main) then also = nil end
  -- Two feelings read best as a pair, "Weary and uneasy": so with a second one, each without
  -- an "and" of its own where its mood has another way ("Full and content, friendly" no).
  local function single(key, cur, other, lowerIt)
    if not (cur and cur:find(" and ")) then return cur end
    local def = W.MOODS[key or ""]
    for _, a in ipairs(U.BackedList(def and def.adj, world)) do
      a = U.Pron(a)
      if lowerIt then a = a:lower() end
      if not a:find(" and ") and not clash(a, m.main) and not clash(a, other) and not clash(other, a) then
        if cur:find("^Still ") and not a:find("^Still") and not a:find("^Not") then a = "Still " .. a:gsub("^%u", string.lower) end
        return a
      end
    end
    return cur
  end
  if also and adj then
    also = single(mood.alsoKey, also, adj, true)
    adj = single(mood.key, adj, also)
  end
  -- Feelings that pull opposite ways are joined with "but": "Sickly but in high spirits".
  local va, vb = W.VALENCE[mood.key or ""], W.VALENCE[mood.alsoKey or ""]
  local contrast = va and vb and va * vb < 0
  local function build(withAlso, extras, withTod, withAside)
    local text = adj
    -- "Weary and uneasy", but "In no hurry, hale and hearty" rather than a run of ands.
    if withAlso and also then
      local paired = text:find(" and ") or also:find(" and ")
      if contrast then text = text .. (paired and ", but " or " but ") .. also
      else text = text .. (paired and ", " or " and ") .. also end
    end
    text = text .. ", " .. m.main
    if withTod and tod then text = text .. " " .. tod end
    if extras >= 1 and ex[1] then
      text = text .. ", " .. ex[1]
      -- A second only when it's "with ..." after something that isn't: never a list.
      if extras >= 2 and ex[2] and ex[2]:find("^with ") and not ex[1]:find("^with ") then text = text .. ", " .. ex[2] end
    end
    text = text .. "."
    if withAside and m.asides[1] then text = text .. " " .. sentence(m.asides[1]) end
    if intent then text = text .. " " .. sentence(intent) end
    return text
  end
  for _, v in ipairs({ { true, 2, true, true }, { true, 2, false, true }, { true, 1, false, true }, { true, 1, false, false },
    { true, 0, false, false }, { false, 0, false, false } }) do
    local text = build(v[1], v[2], v[3], v[4])
    if #text <= Compose.CURRENTLY_MAX then return text end
  end
  return build(false, 0, false, false)
end

---------------------------------------------------------------------------
-- At first glance: five slots, always something in each.
---------------------------------------------------------------------------
function Compose.MoodGlance(mood)
  return { TI = mood.title, TX = U.Cap(mood.tell), IC = mood.icon }
end


-- "The broken Span" reads "the broken Span" mid-sentence; "Westfall, left to fend for
-- itself" keeps its capital, because Westfall is a name.
local LOWER_OK = { The = true, A = true, An = true, Who = true, Something = true, Two = true, Bread = true, Behind = true }
local function lowerFirst(s)
  local w = s:match("^(%a+)")
  if w and LOWER_OK[w] then return (s:gsub("^%u", string.lower)) end
  return s
end

function Compose.LatelyGlance()
  local c = ns.cache
  local rpgd, chron, world = Compose.Persona(c), c.chronicle, c.world
  local cands = {}
  local function add(t, prio, g) cands[#cands + 1] = { t = t or 0, prio = prio, g = g } end

  local death = rpgd and rpgd.deaths[#rpgd.deaths]
  local cdeath = chron and chron.deaths[1]
  if cdeath and (not death or cdeath.t > death.t) then death = cdeath end
  if death and within(death.t, 2 * 86400) then
    local killer = death.killer and (death.common and article(death.killer) or death.killer)
    local tx = "Was badly hurt" .. (killer and (" by " .. killer) or "") .. (death.zone and (" in " .. U.Mid(death.zone)) or "")
      .. (within(death.t, 3 * 3600) and ", within the last few hours" or ", a day or two ago")
    add(death.t, 3, { TI = "Hurt", TX = tx .. ".", IC = "Spell_Holy_Resurrection" })
  end
  local boss = Compose.Bosses(c)[1]
  if boss and within(boss.t, 2 * 86400) then
    add(boss.t, 2, { TI = "Fresh Victory", IC = "INV_Misc_Head_Dragon_01",
      TX = say("boss", { who = boss.name, where = boss.where and (" in " .. U.Mid(boss.where)) or "" }, boss.t) })
  end
  local cleared = rpgd and rpgd.cleared[1]
  if cleared and within(cleared.t, 3 * 86400) then
    add(cleared.t, 2, { TI = "Back from the Depths", IC = "INV_Misc_Key_14",
      TX = say("cleared", { place = U.Mid(cleared.name) }, cleared.t) })
  end
  local thread = rpgd and rpgd.threads[1]
  if thread and within(thread.t, 3 * 86400) and W.SAY["thread_" .. tostring(thread.state)] then
    add(thread.t, 1, { TI = thread.state == "resolved" and "Loose Ends Tied" or "Caught Up in Something",
      IC = "INV_Misc_Note_02", TX = say("thread_" .. thread.state, { t = lowerFirst(thread.title) }, thread.id) })
  end
  -- A name earned lately
  local fresh, freshT = Compose.NewName()
  if fresh then
    add(freshT, 2, { TI = "A Name Earned", IC = fresh.icon or "INV_Misc_Note_04",
      TX = U.Pron(say("newname", { nick = "\"" .. fresh.nick .. "\"" }, fresh.key)) })
  end
  -- A fight just now
  local fight = ns.char and ns.char.lastFight
  if fight and type(fight.foe) == "table" and within(fight.t, 300) then
    local who = fight.foe.named and fight.foe.name or article(fight.foe.name)
    local tx = say(fight.close and "fight_close" or fight.long and "fight_long" or "fight", { who = who }, fight.t)
    add(fight.t, fight.close and 2 or 0, { TI = fight.close and "Close Call" or "Blood Up", IC = "Ability_DualWield", TX = tx })
  end
  -- A job just finished (Auto TRP's own record or Chronicle's, whichever is newer)
  local q = Compose.LastQuest(c)
  if q and within(q.t, 1800) then
    add(q.t, 0, { TI = "A Job Done", IC = "INV_Misc_Note_06",
      TX = say("job", { q = "\"" .. q.title .. "\"", where = q.zone and (", in " .. U.Mid(q.zone)) or "" }, q.t) })
  end

  -- A conversation just now in RPG Dialogue
  local talk = rpgd and rpgd.lastTalk
  if talk and within(talk.last, 1800) then
    local how = talk.affinity >= 3 and "warmly" or talk.affinity <= -3 and "coldly" or nil
    add(talk.last, 1, { TI = "Lately", IC = "INV_Letter_15",
      TX = say("talk", { how = how and (how .. " ") or "", who = talk.name,
        where = talk.zone and (" in " .. U.Mid(talk.zone)) or "" }, talk.last) })
  end
  local finds = ns.char and ns.char.finds
  local find = finds and finds[#finds]
  if find and within(find.t, 86400) then
    add(find.t, 2, { TI = "A New Prize", IC = "INV_Misc_Gem_Pearl_04",
      TX = say("find", { item = find.item, where = find.zone and (" in " .. U.Mid(find.zone)) or "" }, find.t) })
  end
  local zone = rpgd and rpgd.zones[#rpgd.zones]
  if zone and within(zone.t, 86400) and #rpgd.zones > 2 then
    add(zone.t, 0, { TI = "New in Town", IC = "INV_Misc_Map_01",
      TX = say("newzone", { zone = U.Mid(zone.name) }, zone.t) })
  end

  -- Auto TRP's own record of the rest of life: a catch, a duel, a battle, a new mount or
  -- piece of gear, a book, a long stretch at a trade, a new inn.
  local life = c.life
  if life then
    local function here(z) return U.Mid(z or world.zone or "these parts") end
    local fr = life.fishRun
    local nf = life.fishNew
    local fish = nf and Compose.FishName(nf.name)
    if fish and nf.zone and within(nf.t, 3600) then
      add(nf.t, 1, { TI = "A Fresh Catch", IC = "INV_Misc_Fish_02", TX = say("lately_fish", { item = article(fish), zone = here(nf.zone) }, nf.t) })
    elseif fr and within(fr.last, 1800) and (fr.n or 0) >= 3 then
      add(fr.last, 0, { TI = "Fishing", IC = "Trade_Fishing", TX = say("lately_fishing", { zone = here(fr.zone), n = U.Number(fr.n) }, fr.start) })
    end
    local du = life.duelLog[#life.duelLog]
    if du and within(du.t, 1800) then
      add(du.t, 1, { TI = du.won and "Duel Won" or "Duel Lost", IC = "Ability_Warrior_Challange",
        TX = say(du.won and "lately_duel_won" or "lately_duel_lost", { zone = here(du.zone) }, du.t) })
    end
    local bl = life.battleLast
    if bl and within(bl.t, 7200) then
      add(bl.t, 2, { TI = "Back from Battle", IC = "INV_BannerPVP_02",
        TX = say(bl.won and "lately_battle_won" or "lately_battle_lost", { place = U.Mid(bl.name) }, bl.t) })
    end
    local mount = life.mounts[1]
    if mount and not mount.before and within(mount.t, 2 * 86400) then
      add(mount.t, 1, { TI = "A New Mount", IC = "Ability_Mount_RidingHorse", TX = say("lately_mount", { item = article(mount.name) }, mount.t) })
    end
    local fine = (life.epic and not life.epic.before and life.epic) or (life.rare and not life.rare.before and life.rare) or nil
    if fine and within(fine.t, 2 * 86400) then
      add(fine.t, 1, { TI = "Fresh Kit", IC = "INV_Chest_Chain_05", TX = say("lately_wear", { item = fine.name }, fine.t) })
    end
    local book = life.books[1]
    if book and within(book.t, 3600) then
      add(book.t, 0, { TI = "Reading", IC = "INV_Misc_Book_09", TX = say("lately_book", { item = '"' .. book.name .. '"' }, book.t) })
    end
    local mr = life.madeRun
    if mr and mr.kind ~= "other" and within(mr.last, 1800) and (mr.n or 0) >= 5 then
      add(mr.last, 0, { TI = "At Work", IC = "Trade_Engineering",
        TX = say("lately_made", { what = mr.kind:lower(), zone = here(mr.zone) }, mr.start) })
    end
    local inn = life.innNew
    if inn and within(inn.t, 86400) then
      local innName = inn.name:find("^The ") and U.Mid(inn.name) or ("the " .. inn.name)
      add(inn.t, 0, { TI = "A New Inn", IC = "INV_Drink_05", TX = say("lately_inn", { inn = innName }, inn.t) })
    end
  end

  -- A day-old hurt outranks everything; otherwise the newest, then the weightiest. (A strict
  -- order: table.sort may compare an entry with itself.)
  for _, cd in ipairs(cands) do cd.urgent = (cd.prio == 3 and within(cd.t, 86400)) and 1 or 0 end
  table.sort(cands, function(a, b)
    if a.urgent ~= b.urgent then return a.urgent > b.urgent end
    if a.t ~= b.t then return a.t > b.t end
    return a.prio > b.prio
  end)
  if cands[1] then return cands[1].g end

  -- Nothing dramatic: who they were last seen with, or simply where.
  if rpgd then
    local last
    for _, list in ipairs({ rpgd.friends, rpgd.rivals, rpgd.recent or {} }) do
      for _, p in ipairs(list) do if not last or p.last > last.last then last = p end end
    end
    if last and within(last.last, 86400) then
      return { TI = "Lately", IC = "INV_Letter_15", TX = say("lastseen", { who = last.name }, last.last) }
    end
  end
  local journal = ns.Journal and ns.Journal.LatelyGlance()   -- the latest journal entry (Journal.lua)
  if journal then return journal end
  local where = world.zone and U.Mid(world.zone) or "these parts"
  return { TI = "Lately", IC = "INV_Misc_Map_01", TX = say("around", { where = where }, world.zone) }
end

-- Company: the game's own record of who is about them (Sources/Company.lua). Other players
-- are only ever counted (their classes, races, guild and how often they've been seen
-- before), never named; a Social Diary friend in the group is named when that's allowed.
local function cw(key, vars, which)
  local line = U.Pick(W.COMPANY[key], seed("co:" .. key .. ":" .. tostring(which or "")))
  return (line:gsub("{([%a']+)}", function(k) if vars and vars[k] ~= nil then return vars[k] end end))
end
Compose.CompanyWords = cw

local function ofGuild(g) return g and (g:find("^The ") and U.Mid(g) or g) or nil end

-- How they usually travel, from the share of time spent grouped (nil until there's enough).
function Compose.CompanyHabit(sol)
  local share = sol and sol.share
  if not share then return nil end
  if share < 0.1 then return "loner" elseif share < 0.35 then return "mostly_alone"
  elseif share < 0.65 then return "mixed" end
  return "social"
end

local function petKind(p)
  local kind = p.kind and p.kind:lower() or nil
  return kind, kind and article(kind) or nil
end

local function guildCount(n)
  for _, b in ipairs(W.GUILD_ONLINE) do if n <= b.max then return b.words end end
end

-- What the rest of the group are to them: guildmates, familiar faces, all of one race.
local function groupClause(g, guild)
  local single = g.others == 1 and #g.friends == 0
  local others = g.others - #g.friends
  if others < 1 then return nil end
  local which = g.others .. ":" .. g.guildmates
  if guild and g.guildmates >= others then
    return cw(single and "guild_single" or "guild_all", { guild = guild }, which)
  elseif guild and g.guildmates >= 2 then
    return cw("guild_some", { guild = guild, n = U.Number(g.guildmates) }, which)
  elseif guild and g.guildmates == 1 then
    return cw("guild_one", { guild = guild }, which)
  end
  if g.familiar >= 1 then
    if single then return cw("familiar_single", nil, which) end
    if g.familiar >= others then return cw("familiar_all", nil, which) end
    if g.familiar == 1 then return cw("familiar_one", nil, which) end
    return cw("familiar_many", { n = U.Number(g.familiar) }, which)
  end
  if g.others >= 2 then
    local top, topN = nil, 0
    for _, r in ipairs(g.raceOrder) do if g.races[r] > topN then top, topN = r, g.races[r] end end
    local plural = top and W.RACE_PLURAL[top]
    if plural and topN == g.others then return cw("races_all", { races = plural }, which .. top) end
    if plural and g.raid and topN > g.others / 2 then return cw("races_most", { races = plural }, which .. top) end
  end
  if guild then return cw(single and "guild_none_single" or "guild_none", { guild = guild }, which) end
  return nil
end

-- "Together for an hour or so now, and the greenest of the lot."
local function groupTail(g)
  local together = g.forSeconds and g.forSeconds >= 900 and ns.Sources.Company.Span(g.forSeconds)
  local standing = g.standing and cw(g.standing, nil, g.size)
  if together then
    local t = cw("together", { span = together }, g.size)
    return U.Cap(t) .. (standing and (", " .. standing) or "") .. "."
  end
  if standing and g.standing ~= "even" then return U.Cap(standing) .. "." end
  return nil
end

function Compose.CompanyGlance()
  local c = ns.cache
  local world, sd, rpgd = c.world, c.sd, Compose.Persona(c)
  local co = c.company or {}
  local g = co.group
  local guild = ofGuild(world.guild)
  local function join(s1, s2) return U.Pron(s1 .. "." .. (s2 and (" " .. s2) or "")) end
  if g and (g.others >= 1 or (g.size or 0) > 1) then
    local n = math.max(g.size or 0, world.groupSize or 0)
    if g.battleground then
      return { TI = "On the Battlefield", IC = "INV_BannerPVP_02",
        TX = join(cw("battle", { n = U.Number(n), faction = world.faction or "cause" }, n)) }
    end
    local clause = groupClause(g, guild)
    if g.raid and n > 5 then
      local s1 = cw(g.lead and "host_lead" or "host", { n = U.Number(n) }, n)
      return { TI = g.lead and "Leading a Host" or "Part of a Host", IC = "INV_BannerPVP_02",
        TX = join(s1 .. (clause and (", " .. clause) or ""), groupTail(g)) }
    end
    -- n counts them too: a party of three is them and two others.
    local party = Compose.PartyWords(g) or (n == 2 and "a companion" or (U.Number(n - 1) .. " others"))
    local s1 = cw(g.lead and "party_lead" or "party", { party = party }, party)
    return { TI = g.lead and "Leading the Way" or "In Company", IC = "Spell_Holy_PrayerOfSpirit",
      TX = join(s1 .. (clause and (", " .. clause) or ""), groupTail(g)) }
  end
  local sol = co.solitude or {}
  local habit = Compose.CompanyHabit(sol)
  local habitLine = habit and (U.Cap(cw(habit, nil, world.zone)) .. ".") or nil
  if sd and ns.db.nameFriends and sd.friends[1] then
    local f = sd.friends[1]
    local tx
    if f.relationship then
      tx = U.Pron(say("seenwith_rel", { who = f.name, rel = f.relationship:lower() }, f.name))
    else
      local names = {}
      for i = 1, math.min(2, #sd.friends) do names[i] = sd.friends[i].name end
      tx = say("seenwith", { list = U.Join(names) }, names[1])
    end
    return { TI = "Keeps Company", IC = "Spell_Holy_PrayerOfSpirit", TX = tx }
  end
  local pet = co.pet
  if pet and (world.class == "HUNTER" or world.class == "WARLOCK") then
    local kind, akind = petKind(pet)
    kind, akind = kind or (world.class == "WARLOCK" and "demon" or "beast"), akind or (world.class == "WARLOCK" and "a demon" or "a beast")
    local mood = world.class == "HUNTER" and pet.happy and W.PET_HAPPY[pet.happy]
    local vars = { pet = pet.name, kind = kind, akind = akind, mood = mood and (", " .. mood) or "" }
    local s1 = cw(world.class == "HUNTER" and "pet_hunter" or "pet_warlock", vars, pet.name)
    local s2
    local held = pet.first and (U.Now() - pet.first) or 0
    local tracked = U.Now() - ((ns.char.company and ns.char.company.since) or U.Now())
    if held >= 86400 then
      vars.span = ns.Sources.Company.Span(held)
      s2 = cw("pet_since", vars, pet.name)
      if (pet.deaths or 0) > 0 then
        vars.times = U.Times(pet.deaths)
        s2 = s2 .. cw("pet_fallen", vars, pet.name)
      end
    elseif pet.first and tracked > 3 * 86400 then
      s2 = cw("pet_new", vars, pet.name)
    end
    s2 = s2 and (U.Cap(s2) .. ".") or habitLine
    return { TI = "Travels Light", IC = "Ability_Hunter_BeastCall", TX = join(s1, s2 and U.Pron(s2)) }
  end
  local gi = co.guild
  if guild and gi and gi.online and gi.online >= 2 then
    local s1 = cw("guild_about", { guild = guild, n = guildCount(gi.online) }, guild)
    return { TI = "Guild Colours", IC = "INV_Shirt_GuildTabard_01", TX = join(s1, habitLine) }
  end
  local town = rpgd and rpgd.towns[1]
  local friend = rpgd and rpgd.friends[1]
  if town and town.value >= 10 then
    local tx = U.Cap((ns.Sources.RPGD.Tier(town.value).phrase:gsub("{town}", town.name)))
    if friend then tx = tx .. ", and " .. say("getson", { who = friend.name }, friend.name) end
    return { TI = "Local Ties", IC = "INV_Misc_Bag_11", TX = tx .. "." }
  end
  if friend then
    return { TI = "Local Ties", IC = "INV_Misc_Bag_11", TX = U.Cap(say("getson", { who = friend.name }, friend.name)) .. "." }
  end
  if guild then
    return { TI = "Guild Colours", IC = "INV_Shirt_GuildTabard_01",
      TX = join(cw("guild_quiet", { guild = guild }, guild), habitLine) }
  end
  local reserved = rpgd and ((rpgd.traits.reserved or 0) >= 3)
  local s1
  if sol.aloneFor and sol.aloneFor >= 3600 and not (sol.neverGrouped and sol.aloneFor < 86400) then
    local span = ns.Sources.Company.Span(sol.aloneFor)
    s1 = cw("alone_for", { span = span }, span)
  else
    s1 = cw(reserved and "alone_reserved" or "alone", nil, world.zone)
  end
  return { TI = habit == "social" and "Between Companies" or "Travels Alone", IC = "Spell_Shadow_Teleport",
    TX = join(U.Cap(s1), habitLine) }
end

-- "Mirelle, a priest, a mage and two warriors": Social Diary friends by name (when allowed),
-- everyone else by class. g: a group from Sources/Company.lua (read now if not given).
function Compose.PartyWords(g)
  g = g or (ns.Sources.Company and ns.Sources.Company.Group())
  if not g then return nil end
  local parts = {}
  for _, name in ipairs(g.friends or {}) do parts[#parts + 1] = name end
  for _, class in ipairs(g.classOrder or {}) do
    local n, words = g.classes[class], W.CLASS_PLURAL[class]
    if words then parts[#parts + 1] = n == 1 and article(words[1]) or (U.Number(n) .. " " .. words[2]) end
  end
  if #parts == 0 then return nil end
  return U.Join(parts)
end

-- Ambitions, ranked (Sources/Goals.lua): the quest log and the game's own state come first
-- and need no other addon; a Chronicle goal and an unfinished RPG Dialogue story join them
-- when those addons are there. Each: { kind, key, score, vars, icon }.
Compose.GOAL_SCORE = 78     -- a goal the player wrote in Chronicle
Compose.THREAD_SCORE = 66   -- a story still unfolding in RPG Dialogue
function Compose.Ambitions()
  local c = ns.cache
  local list = ns.Goals and ns.Goals.Gather(c.world or {}, c) or {}
  local chron, rpgd = c.chronicle, c.rpgd
  if chron and ns.db.chronicleGoals and chron.goals and chron.goals[1] and chron.goals[1].text then
    list[#list + 1] = { kind = "goal", key = "goal", score = Compose.GOAL_SCORE, vars = { goal = chron.goals[1].text } }
  end
  for _, t in ipairs(rpgd and rpgd.threads or {}) do
    if t.state == "unfolding" or t.state == "stirring" then
      list[#list + 1] = { kind = "thread", key = "thread:" .. tostring(t.id), id = t.id, score = Compose.THREAD_SCORE,
        vars = { t = lowerFirst(t.title) } }
      break
    end
  end
  table.sort(list, function(a, b) if a.score ~= b.score then return a.score > b.score end return tostring(a.key) < tostring(b.key) end)
  return list
end

-- One of a goal's lines with its {tags} filled; lines that need a tag the goal hasn't got
-- are passed over. Pronoun tags are left for U.Pron.
local PRON_TAGS = { they = true, them = true, their = true, themselves = true, ["they've"] = true, ["they're"] = true,
  are = true, have = true, s = true, es = true, ies = true }
local function goalLine(list, vars, key)
  local usable = {}
  for _, line in ipairs(list or {}) do
    local missing = false
    local out = line:gsub("{([%a']+)}", function(k)
      if PRON_TAGS[k] then return nil end
      local v = vars[k]
      if v == nil then missing = true; return "" end
      return tostring(v)
    end)
    if not missing then usable[#usable + 1] = out end
  end
  if #usable == 0 then return nil end
  return U.Pron(U.Pick(usable, seed("goal:" .. key)))
end
Compose.GoalLine = goalLine
local function goalVars(vars, quoteFn)
  local out = {}
  for k, v in pairs(vars or {}) do out[k] = v end
  if out.q then out.q = quoteFn(out.q) end
  return out
end

function Compose.AmbitionGlance()
  local world = ns.cache.world or {}
  for _, a in ipairs(Compose.Ambitions()) do
    local g = W.GOAL_GLANCE[a.kind] or W.GOAL_GLANCE.nextrank
    local text
    if a.kind == "goal" then
      -- The goal as the player wrote it: a full stop only where it has no ending of its own.
      text = U.Cap(U.Truncate(a.vars.goal, 120))
      if not text:find("[%.!%?]\"?$") then text = text .. "." end
    elseif a.kind == "thread" then
      text = say("unfinished", { t = a.vars.t }, a.id)
    else
      text = goalLine(a.kind == "nextrank" and W.SAY.nextrank or W.GOALS[a.kind], goalVars(a.vars, function(q) return "\"" .. q .. "\"" end), a.kind .. ":" .. tostring(a.key))
    end
    if text then return { TI = g[1], IC = a.icon or g[2], TX = text } end
  end
  local list = W.AMBITIONS[world.class or ""] or W.AMBITIONS.default
  return { TI = "Ambition", IC = "INV_Misc_Book_11", TX = U.Pron(U.Pick(list, seed("ambition"))) }
end

-- How kept their gear is, from the game's durability: { band, text } naming the worst piece.
function Compose.Wear(world)
  local g = world.gear or {}
  if type(g.durability) ~= "number" then return nil end
  for _, b in ipairs(W.DURABILITY) do
    if g.durability < b.max then
      if not b.text then return nil end
      if b.text:find("{item}") and not g.worstName then return nil end
      local item = g.worstName and ("{their} " .. g.worstName)
      return { band = b, text = U.Pron((b.text:gsub("{item}", function() return item end))) }
    end
  end
end

-- Lines that don't name gear (for beside the kit line, which names it all already).
local function noGear(list)
  local out = {}
  for _, t in ipairs(list or {}) do
    if not (t:find("{head}") or t:find("{shoulders}") or t:find("{chest}") or t:find("{cloak}") or t:find("{tabard}")
      or t:find("{mainhand}") or t:find("{offhand}") or t:find("{ranged}") or t:find("{shield}")) then out[#out + 1] = t end
  end
  return out
end

-- What they wear and carry, by the items' own names: nothing that isn't equipped.
-- fmt colours a name (the About page); short is for a glance.
local function kit(world, short, fmt)
  local g = world.gear or {}
  local n, q = g.names or {}, g.q or {}
  local function it(slot) return n[slot] and (fmt and fmt(n[slot], q[slot]) or n[slot]) end
  local wear = {}
  for _, slot in ipairs(short and { 5 } or { 1, 3, 5, 15 }) do wear[#wear + 1] = it(slot) end
  local arms = {}
  arms[#arms + 1] = it(16)
  if n[17] and n[17] ~= n[16] then arms[#arms + 1] = it(17) end
  if not short then arms[#arms + 1] = it(18) end
  local parts = {}
  if #wear > 0 then
    parts[#parts + 1] = "Wears " .. U.Join(wear) .. ((not short and n[19]) and (", with " .. it(19) .. " over the top") or "")
  elseif not short and n[19] then
    parts[#parts + 1] = "Wears " .. it(19)
  end
  if #arms > 0 then parts[#parts + 1] = "Carries " .. U.Join(arms) end
  if #parts == 0 then return nil end
  return table.concat(parts, ". ") .. "."
end

-- The ideas a glance carries, so that two glances never say the same thing at once
-- (Mood "Keeps touching an old wound" beside Marks "Bloodied"; Lately "Won a duel" beside
-- Marks "Fresh from a duel"). Lua patterns, matched against the lowered text.
Compose.IDEAS = {
  hurt = { "%f[%a]wound", "%f[%a]hurt", "%f[%a]bloodied", "%f[%a]bleed", "%f[%a]limp", "%f[%a]injur", "%f[%a]favouring" },
  death = { "%f[%a]death", "%f[%a]dead%f[%A]", "%f[%a]died", "%f[%a]dying", "%f[%a]killed", "the other side" },
  duel = { "%f[%a]duel" },
  fish = { "%f[%a]fish" },
  fight = { "%f[%a]fight", "%f[%a]battle%f[%A]" },
  closecall = { "close call", "%f[%a]barely survived", "%f[%a]narrowest" },
  breath = { "%f[%a]breath" },
  drink = { "%f[%a]drink", "%f[%a]drunk", "%f[%a]ale%f[%A]", "%f[%a]tipsy", "%f[%a]cups%f[%A]" },
  prayer = { "%f[%a]pray" },
  sick = { "%f[%a]fever", "%f[%a]sick", "%f[%a]cough", "%f[%a]ailing" },
  meal = { "%f[%a]meal", "%f[%a]ate well", "%f[%a]eating", "%f[%a]stomach" },
  smell = { "%f[%a]smell" },
  tired = { "%f[%a]tired", "%f[%a]weary", "%f[%a]sleep", "%f[%a]yawn" },
  coin = { "%f[%a]coin", "%f[%a]gold%f[%A]", "%f[%a]purse", "%f[%a]pouch" },
  reading = { "%f[%a]reading", "%f[%a]book" },
}
function Compose.Ideas(text, world)
  local out = {}
  local low = (text or ""):lower()
  for idea, pats in pairs(Compose.IDEAS) do
    for _, p in ipairs(pats) do if low:find(p) then out[idea] = true; break end end
  end
  -- A piece of gear named twice ("Carries his Staff of Westfall like a trophy" beside it as a mark).
  local g = world and world.gear
  for _, name in pairs(g and g.names or {}) do
    if type(name) == "string" and #name > 3 and (text or ""):find(name, 1, true) then out["item:" .. name] = true end
  end
  return out
end
function Compose.SharesIdea(text, ideas, world)
  for k in pairs(Compose.Ideas(text, world)) do if ideas[k] then return true end end
  return false
end

-- Marks: the most striking thing about them right now (a wound, drink, a spell on them, a
-- shape), else the most striking thing they wear or carry, else their kit and bearing.
-- Compose.NowMarks and Compose.GearParts are below, with About: Physical.
function Compose.MarksGlance(avoid)
  local c = ns.cache
  local world = c.world
  local marks = {}
  for _, m in ipairs(Compose.NowMarks(c)) do
    if m.title then marks[#marks + 1] = m end
  end
  local g = world.gear or {}
  local parts = Compose.GearParts(world)
  local function mark(prio, title, text, icon) if text then marks[#marks + 1] = { prio = prio, title = title, text = text, icon = icon } end end
  local wear = Compose.Wear(world)
  if wear and wear.band.glance then mark(5, wear.band.glance, U.Cap(wear.text) .. ".", "INV_Hammer_20") end
  -- What the last while has left on them, from Auto TRP's own record.
  local life = c.life
  if life and not world.combat and not world.dead then
    local fall = life.env.Falling
    if fall and within(fall.t, 600) then mark(6, "Sore", say("mark_fall", nil, fall.t), "Spell_Magic_FeatherFall") end
    if world.swimming then mark(5.5, "Soaked", say("mark_swim", nil, world.zone), "Spell_Frost_SummonWaterElemental") end
    local du = life.duelLog[#life.duelLog]
    if du and within(du.t, 600) then mark(4.6, "Fresh from a Duel", say("mark_duel", nil, du.t), "Ability_Warrior_Challange") end
    local fr = life.fishRun
    if fr and within(fr.last, 1800) and (fr.n or 0) >= 5 then mark(4.5, "Smells of Fish", say("mark_fish", nil, fr.start), "INV_Misc_Fish_02") end
    local mr = life.madeRun
    if mr and mr.kind == "Cooking" and within(mr.last, 1800) and (mr.n or 0) >= 3 then
      mark(4.4, "Cooking Smoke", say("mark_cook", nil, mr.start), "INV_Misc_Food_15")
    end
    local gr = life.gatherRun
    local GATHER_MARK = { herbs = { "Smells of Herbs", "Trade_Herbalism" }, mining = { "Rock Dust", "Trade_Mining" },
      skinning = { "Smells of Hides", "INV_Misc_Pelt_Wolf_01" } }
    if gr and GATHER_MARK[gr.kind] and within(gr.last, 1800) and (gr.n or 0) >= 3 then
      mark(4.4, GATHER_MARK[gr.kind][1], say("mark_" .. gr.kind, nil, gr.start), GATHER_MARK[gr.kind][2])
    end
  end
  local finest = g.finest or (c.chronicle and c.chronicle.appearance and c.chronicle.appearance.finest)
  if finest and finest.name and finest.quality >= 4 then
    mark(4, "Remarkable Gear", say("remarkable", { item = finest.name }, finest.name), "INV_Misc_Gem_Pearl_04")
  end
  local M = W.PHYS_MARK
  if parts.setN and parts.setN >= 3 then mark(3.8, M.set[1], parts.set, M.set[2]) end
  if parts.enchantWeapon then mark(3.2, M.enchanted[1], parts.enchantWeapon, M.enchanted[2]) end
  if parts.jewelEpic then mark(3, M.jewel[1], parts.jewel, M.jewel[2]) end
  if parts.armsKey == "twohand" then mark(2.4, M.twohand[1], parts.arms, M.twohand[2])
  elseif parts.armsKey == "dual" then mark(2.3, M.dual[1], parts.arms, M.dual[2]) end
  if parts.armourType == "Plate" and not parts.mixed then mark(2, M.plate[1], parts.armour, M.plate[2]) end
  table.sort(marks, function(a, b) if a.prio ~= b.prio then return a.prio > b.prio end return a.title < b.title end)
  -- The strongest mark that doesn't say what another glance already says (avoid: ideas).
  for _, m in ipairs(marks) do
    local text = sentence(m.text)
    if not (avoid and Compose.SharesIdea(m.title .. " " .. text, avoid, world)) then
      return { TI = m.title, TX = text, IC = m.icon }
    end
  end
  local k = kit(world, true)
  local cl = U.BackedList(noGear(W.CLASS_LOOK[world.class or ""]), world)
  local classMark = #cl > 0 and U.Pron(U.Pick(cl, seed("classmark"))) or nil
  if k and classMark then return { TI = "Kit", IC = "INV_Chest_Chain_05", TX = k .. " " .. classMark } end
  if k then return { TI = "Kit", IC = "INV_Chest_Chain_05", TX = k } end
  if classMark then return { TI = "At a Glance", IC = "INV_Chest_Chain_05", TX = classMark } end
  return { TI = "At a Glance", IC = "INV_Shirt_05", TX = U.Pron(say("plain", nil, world.zone)) }
end

---------------------------------------------------------------------------
-- Personality bars (TRP3 psycho traits; V2 runs 0..20, 20 = all the left word)
---------------------------------------------------------------------------
-- With no choices recorded, the class's mild leans fill the bars.
local function classTraits()
  local world = ns.cache.world or {}
  local leans = {}
  for k, v in pairs(W.CLASS_LEANS[world.class or ""] or {}) do leans[k] = v end
  -- Race adds to the class's lean; where the two cancel out, the class's stands.
  for k, v in pairs(W.RACE_LEANS[world.race or ""] or {}) do
    local sum = (leans[k] or 0) + v
    leans[k] = sum ~= 0 and sum or leans[k]
  end
  local out = {}
  local function bar(left, right, li, ri)
    local v = leans[left]
    if v and v ~= 0 and #out < 6 then out[#out + 1] = { LT = left, RT = right, LI = li, RI = ri, V2 = U.Clamp(10 + v, 3, 17) } end
  end
  for _, b in ipairs(W.AXIS_BARS) do bar(b.left, b.right, b.li, b.ri) end
  for _, b in ipairs(W.TRAIT_BARS) do bar(b[1], b[2], b[5], b[6]) end
  return #out > 0 and out or nil
end

function Compose.Traits()
  local rpgd = Compose.Persona()
  if not rpgd then return classTraits() end
  local out = {}
  for _, b in ipairs(W.AXIS_BARS) do
    local v = rpgd.align[b.axis] or 0
    if math.abs(v) >= 10 then
      out[#out + 1] = { LT = b.left, RT = b.right, LI = b.li, RI = b.ri, V2 = U.Clamp(math.floor(10 + v / 10 + 0.5), 1, 19) }
    end
  end
  for _, b in ipairs(W.TRAIT_BARS) do
    local l, r = rpgd.traits[b[3]] or 0, rpgd.traits[b[4]] or 0
    if math.max(l, r) >= 2 and #out < 6 then
      out[#out + 1] = { LT = b[1], RT = b[2], LI = b[5], RI = b[6], V2 = U.Clamp(math.floor(10 + (l - r) * 1.5 + 0.5), 1, 19) }
    end
  end
  -- Auto TRP's own reading: what the player has shown fills its bars, the class and race
  -- lean the rest.
  if rpgd.own then
    local have = {}
    for _, b in ipairs(out) do have[b.LT] = true end
    for _, b in ipairs(classTraits() or {}) do
      if not have[b.LT] and #out < 6 then out[#out + 1] = b end
    end
  end
  if #out == 0 then return classTraits() end
  return out
end

---------------------------------------------------------------------------
-- About: shared helpers. The About page is where the character is told as a person, so
-- it is written as prose in paragraphs: each paragraph one part of a life, each fact
-- followed by what it did to them where the sources can say. Total RP 3 renders About
-- text with its own markup ({col:rrggbb}...{/col}), so quotes and item names stand apart
-- from the gold body text (the "richText" setting turns that off).
---------------------------------------------------------------------------
local QUOTE_COLOUR = "f2e8d0"
local ITEM_COLOUR = { [2] = "1eff00", [3] = "0070dd", [4] = "a335ee", [5] = "ff8000" }

local function colour(text, hex)
  if not hex or (ns.db and ns.db.richText == false) then return text end
  return "{col:" .. hex .. "}" .. text .. "{/col}"
end
Compose.Colour = colour

local function quote(text) return colour("\"" .. text .. "\"", QUOTE_COLOUR) end
local function itemName(name, quality) return colour(name, ITEM_COLOUR[quality or 0]) end

-- Pronouns filled in, and every sentence starts with a capital.
local function prose(s)
  s = U.Cap(U.Pron(s))
  return (s:gsub("([%.!%?]\"? +)(%l)", function(gap, l) return gap .. l:upper() end))
end

-- A paragraph from sentences; empty ones are skipped.
-- Two sentences in a row that open on a bare "Has" (or "Is") read like a list; the second
-- gets its pronoun back ("Has risen to Templar. He has done good work for Stormwind.").
local function paragraph(list)
  local out = {}
  local last
  for _, s in ipairs(list) do
    if s and s ~= "" then
      local w = s:match("^(%a+) ")
      if w == last and w == "Has" then s = "{they} {have} " .. s:sub(5); w = nil
      elseif w == last and w == "Is" then s = "{they} {are} " .. s:sub(4); w = nil end
      last = w
      out[#out + 1] = sentence(s)
    end
  end
  if #out == 0 then return nil end
  return prose(table.concat(out, " "))
end

local function pages(paras)
  local out = {}
  for i = 1, table.maxn(paras) do if paras[i] then out[#out + 1] = paras[i] end end
  if #out == 0 then return nil end
  return table.concat(out, "\n\n")
end

local function topicName(id)
  local t = W.TOPICS[id] or ns.RPGDNames.towns[id]
  if t then return t end
  t = U.Humanize(id)
  local last = t and t:match("(%a+)$")
  if last and W.GROUP_WORDS[last:lower()] then t = "the " .. t end
  return t
end

---------------------------------------------------------------------------
-- About: Personality ("bearing")
---------------------------------------------------------------------------
local function opinions(rpgd, max)
  local out = {}
  for _, o in ipairs(rpgd.opinions) do
    local phrase
    if o.topic == "peace" then
      phrase = W.PEACE[o.stance]
    else
      local verb = W.STANCES[o.stance]
      local topic = topicName(o.topic)
      if verb and topic then phrase = (verb:gsub("{t}", topic)) end
    end
    if phrase then out[#out + 1] = phrase end
    if #out >= max then break end
  end
  return out
end

-- "distrusts the night elves" -> "Used to distrust the night elves".
function Compose.UsedTo(phrase)
  local verb, rest = phrase:match("^(%S+)(.*)$")
  if not verb or verb == "would" then return nil end
  local base = verb == "is" and "be" or verb == "has" and "have" or verb:gsub("ies$", "y"):gsub("s$", "")
  return "Used to " .. base .. rest
end

-- "good, lawful and honest", in the plainest words.
local PLAIN = {
  light = { "good", "evil" }, order = { "lawful", "chaotic" }, honor = { "honest", "deceitful" },
}
function Compose.PlainAlignment(align)
  local words = {}
  for _, axis in ipairs({ "light", "order", "honor" }) do
    local v = align[axis] or 0
    if v >= 25 then words[#words + 1] = PLAIN[axis][1] elseif v <= -25 then words[#words + 1] = PLAIN[axis][2] end
  end
  return words
end

-- The spells and abilities cast most, by count: { { name, n }, ... } most first.
function Compose.TopSpells(k)
  local casts = ns.char and ns.char.casts
  local list = {}
  for name, n in pairs(casts and casts.n or {}) do
    if type(n) == "number" and not W.CAST_IGNORE[name] then list[#list + 1] = { name = name, n = n } end
  end
  table.sort(list, function(a, b) if a.n ~= b.n then return a.n > b.n end return a.name < b.name end)
  for i = #list, (k or #list) + 1, -1 do list[i] = nil end
  return list
end

-- The most cast spell, said plainly, once it has been cast often enough to mean something.
function Compose.FavouriteSpell()
  local top = Compose.TopSpells(1)[1]
  if not top or top.n < 50 then return nil end
  local noun = W.CAST_NOUN[ns.cache.world and ns.cache.world.class or ""] or "spell"
  return say("favspell", { spell = top.name, noun = noun }, top.name)
end

---------------------------------------------------------------------------
-- Life on the road (Sources/Life.lua): small helpers shared by the fields below.
---------------------------------------------------------------------------
-- "Raw Brilliant Smallfish" -> "Brilliant Smallfish"; nil for what isn't a fish (a crate, a clam).
function Compose.FishName(name)
  if type(name) ~= "string" then return nil end
  if name:find("^Raw ") then return (name:gsub("^Raw ", "")) end
  if name:find("^Large Raw ") then return (name:gsub("^Large Raw ", "Large ")) end
  if W.LIFE.FISH[name] then return name end
  return nil
end

-- How many days, said plainly: "a day", "nine days", "three weeks".
local function daysWords(seconds)
  local d = math.max(1, math.floor(seconds / 86400 + 0.5))
  if d == 1 then return "a day" end
  if d >= 21 then return U.Number(math.floor(d / 7)) .. " weeks" end
  return U.Number(d) .. " days"
end

-- Every book read, newest first: RPG Dialogue's, then Auto TRP's own (ITEM_TEXT_BEGIN).
function Compose.Books()
  local c = ns.cache
  local out, seen = {}, {}
  for _, b in ipairs(c.rpgd and c.rpgd.books or {}) do
    if b.title and not seen[b.title] then seen[b.title] = true; out[#out + 1] = { title = b.title, t = b.t or 0 } end
  end
  for _, b in ipairs(c.life and c.life.books or {}) do
    if not seen[b.name] then seen[b.name] = true; out[#out + 1] = { title = b.name, t = b.t or 0 } end
  end
  return out
end
function Compose.BooksLine()
  local books = Compose.Books()
  if #books == 0 then return nil end
  local titles = {}
  for i = 1, math.min(2, #books) do titles[i] = quote(books[i].title) end
  local extra = #books - #titles
  return "Has read " .. U.Join(titles)
    .. (extra > 0 and (", and " .. U.Number(extra) .. " " .. U.Plural(extra, "other book") .. " besides") or "")
end

-- Habits the counts back up, strongest first: at most `k` lines for Personality.
function Compose.Habits(k)
  local c = ns.cache
  local life, world = c.life, c.world or {}
  if not life then return {} end
  local cands = {}
  local function add(score, key, list)
    local pool = list or W.LIFE.HABIT[key]
    if pool and #pool > 0 then cands[#cands + 1] = { score = score, key = key, text = U.Pick(pool, seed("habit:" .. key)) } end
  end
  if life.fish >= 100 and life.fishZones >= 3 then add(3, "fish_many") elseif life.fish >= 30 then add(2, "fish_some") end
  local cooked = life.madeByProf.Cooking or 0
  if cooked >= 50 then add(2, "cook") end
  local craftTop, craftN = nil, 0
  for prof, n in pairs(life.madeByProf) do
    if prof ~= "Cooking" and prof ~= "First Aid" and prof ~= "other" and n > craftN then craftTop, craftN = prof, n end
  end
  if craftN >= 100 then add(1.5, "craft") end
  if life.herbs + life.ore >= 200 then add(2, "gather") end
  local duels = life.duelsWon + life.duelsLost
  if duels >= 10 then
    if life.duelsWon >= 2 * life.duelsLost then add(2.2, "duel_wins")
    elseif life.duelsLost > life.duelsWon then add(2.2, "duel_losses")
    else add(1.8, "duel_some") end
  end
  if life.battles >= 20 then add(2, "battles") end
  if life.emoteTop and life.emoteTopN >= 30 and W.LIFE.EMOTE[life.emoteTop] then add(2.5, "emote:" .. life.emoteTop, W.LIFE.EMOTE[life.emoteTop]) end
  if #life.inns >= 10 then add(1, "inns") end
  if life.falls >= 10 then add(1.2, "falls") end
  if life.closeCalls >= 10 then add(1.1, "close") end
  table.sort(cands, function(a, b) if a.score ~= b.score then return a.score > b.score end return a.key < b.key end)
  local out = {}
  for i = 1, math.min(k or 2, #cands) do out[i] = cands[i].text end
  return out
end

-- The first word of a line, to keep a paragraph from starting every sentence the same way.
local function opener(line)
  return (type(line) == "string" and line:match("^%s*([%w{}']+)") or ""):lower()
end

-- A line from the pool (picked by seed) that isn't already said and doesn't open with a
-- word already used; the word is then marked used. Any unused line if none opens freshly.
local function freshLine(pool, s, used)
  if type(pool) ~= "table" or #pool == 0 then return nil end
  local start = U.Hash(s)
  local fallback
  for k = 0, #pool - 1 do
    local line = pool[(start + k) % #pool + 1]
    if not used[line] then
      if not used[opener(line)] then
        used[line], used[opener(line)] = true, true
        return line
      end
      fallback = fallback or line
    end
  end
  if fallback then used[fallback] = true end
  return fallback
end

-- How this race and class carry themselves together (nil for a pair the lore doesn't have).
function Compose.RaceClassTemper(world)
  local byRace = W.RACE_CLASS_TEMPER and W.RACE_CLASS_TEMPER[world.race or ""]
  return byRace and byRace[world.class or ""] or nil
end

function Compose.Bearing()
  local c = ns.cache
  local rpgd, world = Compose.Persona(c), c.world
  local name = firstName()
  local habit = Compose.FavouriteSpell()

  local classPool = W.CLASS_TEMPER[world.class or ""]
  local racePool = W.RACE_TEMPER[world.race or ""]
  local pairPool = Compose.RaceClassTemper(world)
  -- What this race and class are like together, then the class, the race and the class
  -- again: four different dispositions, no two starting with the same word.
  local function temperLines()
    local used = {}
    local lines = {}
    for _, p in ipairs({ { pairPool, "rctemper" }, { classPool, "temper" }, { racePool, "racetemper" }, { classPool, "temper2" } }) do
      lines[#lines + 1] = freshLine(p[1], seed(p[2]), used)
    end
    return lines
  end

  -- Nothing to read a character from: only the habit the game itself records.
  if not rpgd then
    local after = { habit }
    for _, h in ipairs(Compose.Habits(2)) do after[#after + 1] = h end
    after[#after + 1] = Compose.BooksLine()
    after[#after + 1] = Compose.WeekTone()
    return pages({ paragraph(temperLines()), paragraph(after) })
  end

  -- Temperament and conscience
  local adjs = {}
  for _, t in ipairs(rpgd.dominant) do adjs[#adjs + 1] = W.TRAIT_ADJ[t] end
  local leans = {}
  for _, b in ipairs(W.AXIS_BARS) do
    local v = rpgd.align[b.axis] or 0
    if math.abs(v) >= 25 then leans[#leans + 1] = { v = math.abs(v), text = W.AXIS_PROSE[b.axis][v > 0 and 1 or -1] } end
  end
  table.sort(leans, function(a, b) return a.v > b.v end)
  local first = {}
  if #adjs > 0 then
    first[#first + 1] = name .. " is " .. U.Join(adjs) .. (leans[1] and (", and " .. leans[1].text) or "")
  elseif leans[1] then
    first[#first + 1] = name .. " " .. leans[1].text
  end
  if leans[2] then first[#first + 1] = U.Cap(leans[2].text) end

  -- Beliefs, and where they have shifted
  local views = {}
  local ops = opinions(rpgd, 3)
  if #ops > 0 then views[#views + 1] = U.Join(ops) end
  for _, o in ipairs(rpgd.opinions) do
    local topic = o.topic ~= "peace" and topicName(o.topic)
    if o.changed and topic then
      local was = o.was and W.STANCES[o.was] and Compose.UsedTo(W.STANCES[o.was]:gsub("{t}", topic))
      views[#views + 1] = was and (was .. ", and has since changed {their} mind")
        or ("Has changed {their} mind about " .. topic)
      break
    end
  end

  -- What else the sources record about the inner life
  local more = {}
  if (rpgd.align.taint or 0) >= 30 then more[#more + 1] = "There is a taint on {them} now" end
  if (rpgd.insanity or 0) >= 40 then more[#more + 1] = "{their} hold on {their} own mind has been slipping" end
  if (rpgd.liesExposed or 0) > 0 then
    more[#more + 1] = "Has been caught in " .. (rpgd.liesExposed == 1 and "a lie" or U.Number(rpgd.liesExposed) .. " lies")
  end
  more[#more + 1] = Compose.BooksLine()
  if habit then more[#more + 1] = habit end
  for _, h in ipairs(Compose.Habits(2)) do more[#more + 1] = h end
  -- Little recorded about the inner life yet: how this race and class carry themselves.
  local said = #first + #views + #more
  if said < 5 then
    local used = {}
    for _, l in ipairs(first) do used[opener(l)] = true end
    first[#first + 1] = freshLine(pairPool or classPool, seed("rctemper"), used)
    if said < 3 then first[#first + 1] = freshLine(racePool, seed("racetemper"), used) end
  end
  local hooks = Compose.Hooks()
  local stories = #hooks > 0 and paragraph({ say("stories", { list = U.Join(hooks) }) }) or nil

  -- Auto TRP's own reading (no RPG Dialogue): what the player has shown leads; the class
  -- and race fill in above, and how the week has gone closes it.
  if rpgd.own then more[#more + 1] = Compose.WeekTone() end

  return pages({ paragraph(first), #views > 0 and paragraph({ name .. " " .. views[1], views[2] }) or nil, paragraph(more), stories })
end

-- "Kobold Miner" -> "Kobold Miners", "Wolf" -> "Wolves", "Harpy" -> "Harpies"
function Compose.Plural(name)
  local last = name:match("(%S+)$") or name
  local head = name:sub(1, #name - #last)
  local p
  local same = { vermin = true, sheep = true, deer = true, fish = true, folk = true, kin = true, swine = true }
  if same[last:lower()] then p = last
  elseif last:find("[^aeiou]y$") then p = last:sub(1, -2) .. "ies"
  elseif last:find("f$") and not last:find("ff$") then p = last:sub(1, -2) .. "ves"
  elseif last:find("[sxz]$") or last:find("[cs]h$") then p = last .. "es"
  elseif last:find("man$") then p = last:sub(1, -4) .. "men"
  else p = last .. "s" end
  return head .. p
end

-- How the week has felt, from the mood journal: mostly good or mostly hard days.
function Compose.WeekTone()
  local days = ns.Mood.RecentDays(7)
  if #days < 3 then return nil end
  local good, bad = 0, 0
  for _, d in ipairs(days) do
    local v = d.mood and W.VALENCE[d.mood] or 0
    if v > 0 then good = good + 1 elseif v < 0 then bad = bad + 1 end
  end
  if bad >= 3 and bad > good * 2 then return U.Pick(W.WEEK_TONE.hard, seed("week")) end
  if good >= 3 and good > bad * 2 then return U.Pick(W.WEEK_TONE.good, seed("week")) end
  return nil
end

-- Things this character has a story about, for other players to ask after.
function Compose.Hooks()
  local c = ns.cache
  local rpgd, chron, world = Compose.Persona(c), c.chronicle, c.world
  local hooks, seen = {}, {}
  local function add(text)
    if text and not seen[text] and #hooks < 4 then seen[text] = true; hooks[#hooks + 1] = text end
  end
  for _, t in ipairs(rpgd and rpgd.threads or {}) do add(lowerFirst(t.title)) end
  if rpgd and rpgd.cleared[1] then add("what's down in " .. U.Mid(rpgd.cleared[1].name)) end
  local lastBoss = Compose.Bosses(c)[1]
  if lastBoss then add("the day " .. lastBoss.name .. " fell") end
  if rpgd and rpgd.friends[1] then add(rpgd.friends[1].name) end
  if rpgd and rpgd.origin and rpgd.origin.name then add("where {they} grew up") end
  local prof = (chron and chron.professions[1]) or (world.professions and world.professions[1])
  if prof and prof.rank >= 75 then add(prof.name:lower()) end
  return hooks
end

-- What drives them: the top three ambitions of different kinds (a mount and the coin for
-- it are one kind), told as part of a life, for the end of History. Nil with nothing to say.
local function goalFamily(kind) return (kind:gsub("_.*$", "")) end
function Compose.Drives()
  local lines, told = {}, {}
  for _, a in ipairs(Compose.Ambitions()) do
    if #lines >= 3 then break end
    local family = goalFamily(a.kind)
    if not told[family] then
      local vars = goalVars(a.vars, quote)
      if vars.goal then vars.goal = quote(U.Truncate(vars.goal, 120)) end
      local line = goalLine(W.DRIVES[a.kind], vars, "drive:" .. a.kind .. ":" .. tostring(a.key))
      if line then told[family] = true; lines[#lines + 1] = line end
    end
  end
  if #lines == 0 then return nil end
  lines[1] = firstName() .. " " .. (lines[1]:gsub("^%u", string.lower))
  return paragraph(lines)
end

---------------------------------------------------------------------------
-- About: History. What happened lately comes first and is told most fully; what lasts
-- (roots, the earned name, the people) always stays; the rest is told briefly.
---------------------------------------------------------------------------
local function profWord(rank)
  for _, r in ipairs(W.PROF_RANK) do if rank >= r.min then return r.word end end
  return "an apprentice"
end

-- "the Scarlet Raven Tavern", "Stormwind City", "the Barrens".
local function placeName(n)
  if n:find("^The ") then return U.Mid(n) end
  if ns.World.IsInn(n) then return "the " .. n end
  return n
end

-- How long ago, in the words History uses to open a run of recent events. Events within
-- RECENT are news; older ones join the longer record, told more briefly.
local RECENT = 21 * 86400
local function whenWords(t)
  local age = U.Now() - t
  if age < 2 * 86400 then return "near", 1 end
  if age < 7 * 86400 then return "week", 2 end
  if age < 14 * 86400 then return "lastweek", 3 end
  return "fortnight", 4
end

-- What has changed since Auto TRP last looked: the guild, the rank in it, and how well off
-- they are. The first look is only remembered. Each change: { kind, from, to, t }.
function Compose.NoticeChanges(world)
  if not ns.char or not world then return {} end
  local seen = ns.char.watched
  local changes = ns.char.changes or {}
  ns.char.changes = changes
  local now = U.Now()
  local function note(kind, from, to)
    changes[#changes + 1] = { kind = kind, from = from, to = to, t = now }
    while #changes > 8 do table.remove(changes, 1) end
  end
  -- Wealth moves a band only when it's clearly past the edge, so a purse that hovers on a
  -- boundary isn't news every day.
  local band
  if type(world.money) == "number" and world.level then
    local r = world.money / math.max(1, world.level ^ 2)
    for i, b in ipairs(W.WEALTH) do if r < b.max then band = i; break end end
    local was = seen and seen.wealth
    if was and band ~= was then
      local lo = W.WEALTH[was - 1] and W.WEALTH[was - 1].max or 0
      local hi = W.WEALTH[was].max
      if r < hi * 1.15 and r >= lo * 0.85 then band = was end
    end
  end
  if seen then
    if band and seen.wealth and band ~= seen.wealth then note("wealth", seen.wealth, band) end
    if world.guild ~= seen.guild then
      if world.guild and seen.guild then note("guildmove", seen.guild, world.guild)
      elseif world.guild then note("joined", nil, world.guild)
      elseif seen.guild then note("left", seen.guild, nil) end
    elseif world.guild and world.guildRank and seen.guildRank and world.guildRank ~= seen.guildRank then
      note("guildrank", seen.guildRank, world.guildRank)
    end
  end
  ns.char.watched = { wealth = band or (seen and seen.wealth), guild = world.guild,
    guildRank = world.guildRank or (seen and world.guild == seen.guild and seen.guildRank) or nil }
  for i = #changes, 1, -1 do
    if now - (changes[i].t or 0) > 45 * 86400 then table.remove(changes, i) end
  end
  return changes
end

local function guildName(g) return g:find("^The ") and U.Mid(g) or g end

-- History, in five paragraphs. The first and the last two hold what lasts: where they
-- came from and the road, the people, how things stand. The second is the news (the last
-- three weeks, newest first, and what has changed). The third is the longer record: the
-- deed behind their name, then everything older, told briefly.
function Compose.History()
  local c = ns.cache
  local rpgd, chron, sd, world = Compose.Persona(c), c.chronicle, c.sd, c.world
  local name = firstName()
  local now = U.Now()
  local paras = {}
  local race = W.RACE_NOUN[world.race or ""]
  local noun = W.CLASS_NOUN[world.class or ""]
  local what = race and noun and (article(race) .. " " .. noun) or nil
  local function recent(t) return type(t) == "number" and t > 0 and now - t <= RECENT end
  local changes = Compose.NoticeChanges(world)

  -- 1. Where it began, and the road since
  local roots = {}
  if rpgd and rpgd.origin and rpgd.origin.name then
    local o = rpgd.origin.name
    local first = o:match("^(%a+)")
    -- "Farmhand from the Westbrook fields" -> "started out as a farmhand from the Westbrook fields"
    local as = (first and not LOWER_OK[first] and not o:find("^%u%l+%s+%u")) and article(o:gsub("^%u", string.lower)) or lowerFirst(o)
    roots[#roots + 1] = name .. (what and (", " .. what .. ",") or "") .. " started out as " .. as
    if rpgd.origin.blurb then roots[#roots + 1] = quote(rpgd.origin.blurb) end
  else
    local home = W.RACE_HOME[world.race or ""]
    if what then
      roots[#roots + 1] = name .. " is " .. what .. (home and (" who started out in " .. home) or "")
    end
  end
  -- The trainer it began with (Auto TRP saw it), or the one gone back to.
  local start = rpgd and rpgd.start
  if start and start.trainer and start.zone and not (rpgd.origin and rpgd.origin.name) then
    roots[#roots + 1] = say(start.first and "trainer_first" or "trainer_usual", { who = start.trainer, place = placeName(start.zone) }, start.trainer)
  end
  local zones = (rpgd and #rpgd.zones > 0 and rpgd.zones) or (c.deeds and c.deeds.zones) or {}
  local zoneCount = math.max(#zones, chron and chron.zones or 0)
  if zoneCount >= 3 and zones[1] then
    local since = math.min(zones[1].t or math.huge, chron and chron.created or math.huge)
    local weeks = since < math.huge and math.floor((now - since) / 604800) or 0
    local ago = weeks >= 9 and (U.Number(math.floor(weeks / 4.3)) .. " months ago")
      or weeks >= 2 and (U.Number(weeks) .. " weeks ago") or nil
    local dungeons = math.max(chron and chron.dungeons or 0, c.deeds and c.deeds.dungeons or 0)
    roots[#roots + 1] = "From " .. placeName(zones[1].name) .. (ago and (", " .. ago .. ",") or "")
      .. " {their} road has led through " .. U.Number(zoneCount) .. " lands"
      .. (dungeons >= 2 and (" and down into " .. U.Number(dungeons) .. " dungeons") or "")
  elseif (world.level or 1) < 10 then
    roots[#roots + 1] = say("setout", { name = name })
  end
  if rpgd and rpgd.homeInn and not (rpgd.homePrev and rpgd.homePrev ~= rpgd.homeInn and recent(rpgd.homeSince)) then
    roots[#roots + 1] = say("home", { inn = placeName(rpgd.homeInn) }, rpgd.homeInn)
  end
  -- Little recorded yet: say what can be seen of them now (rank, where they are, how
  -- seasoned they look) so History is never just one line.
  if #roots < 3 then
    local title = Compose.Title()
    -- Not when the news below tells of rising to it.
    local lastRise = ns.char and ns.char.milestones and ns.char.milestones[#ns.char.milestones]
    local risen = lastRise and recent(lastRise.t)
    if title and (world.level or 1) >= 10 and not risen then roots[#roots + 1] = say("rankso", { rank = title }) end
    if world.zone then roots[#roots + 1] = say("keepsto", { zone = placeName(world.zone) }, world.zone) end
  end
  paras[#paras + 1] = paragraph(roots)

  -- 2. Lately: what happened in the last three weeks, and what changed. Each event is a
  -- past-tense predicate ("reached Duskwood for the first time"), grouped by how long ago
  -- and joined into one sentence per group, so the news reads as a run, not a list.
  local events = {}
  local toldRecent = {}
  local function event(t, rank, text, key)
    if recent(t) and text then events[#events + 1] = { t = t, rank = rank, text = text, key = key } end
  end
  local known = ns.char and ns.char.names or {}
  local earned, earnedKey = Compose.EarnedStory(name, function(key) return recent(known[key]) end)
  for _, e in ipairs(Compose.EarnedAll()) do
    if e.key ~= earnedKey and recent(known[e.key]) then
      event(known[e.key], 1, "came to be called " .. quote(e.nick) .. " by some", "name:" .. e.key)
    end
  end
  local ms = ns.char and ns.char.milestones or {}
  local ladder = Compose.Ranks(world)
  local function rankOf(m) return (tonumber(m.level) and ladder[band(m.level)]) or m.rank end
  local lastMs = ms[#ms]
  if lastMs and rankOf(lastMs) then
    -- How long the climb took, from the rank before (or Auto TRP's own record of levels).
    local prevT = ms[#ms - 1] and ms[#ms - 1].t
    local lv = c.life and c.life.levels and tonumber(lastMs.level) and c.life.levels[lastMs.level - 10]
    if lv and not lv.start and tonumber(lv.t) then prevT = lv.t end
    local pace = prevT and lastMs.t > prevT and lastMs.t - prevT <= 30 * 86400
      and say("rankpace", { n = daysWords(lastMs.t - prevT) }, lastMs.t) or ""
    event(lastMs.t, 2, "rose to " .. rankOf(lastMs) .. (lastMs.zone and (" in " .. U.Mid(lastMs.zone)) or "") .. pace, "rank")
  end
  -- Stories still going are told together ("got caught up in A and B"), the two newest.
  local caught = {}
  for _, t in ipairs(rpgd and rpgd.threads or {}) do
    if earnedKey ~= "thread:" .. t.id then
      if t.state == "unfolding" or t.state == "stirring" then
        if recent(t.t) and #caught < 2 then caught[#caught + 1] = t end
      else
        local v = t.state == "resolved" and "saw " .. lowerFirst(t.title) .. " through to the end"
          or t.state == "soured" and "watched " .. lowerFirst(t.title) .. " go sour"
        event(t.t, 3, v, "thread:" .. t.id)
      end
    end
  end
  if caught[1] then
    local titles = {}
    for k, t in ipairs(caught) do titles[k] = lowerFirst(t.title) end
    event(caught[1].t, 3, "got caught up in " .. U.Join(titles), "thread:" .. caught[1].id)
  end
  local bosses = Compose.Bosses(c)
  local nb = 0
  for _, b in ipairs(bosses) do
    if nb < 2 and recent(b.t) and earnedKey ~= "boss:" .. b.name then
      nb = nb + 1
      local again = b.first and b.first > 0 and not recent(b.first)
      event(b.t, 3, (again and "brought down " .. b.name .. " again" or "helped bring down " .. b.name), "boss:" .. b.name)
    end
  end
  for k = 1, math.min(2, rpgd and #rpgd.cleared or 0) do
    local d = rpgd.cleared[k]
    event(d.t, 4, "came back up out of " .. U.Mid(d.name), "cleared:" .. d.name)
  end
  do
    local fresh = {}
    for k = 2, #zones do if recent(zones[k].t) then fresh[#fresh + 1] = zones[k] end end
    if #fresh > 0 then
      local names = {}
      for k = #fresh, math.max(1, #fresh - 2), -1 do names[#names + 1] = placeName(fresh[k].name) end
      event(fresh[#fresh].t, 5, (#names == 1 and "reached " or "saw ") .. U.Join(names) .. " for the first time", "zones")
    end
  end
  local hon = ns.char and ns.char.honours or {}
  local h = hon[#hon]
  if h then event(h.t, 5, "earned " .. h.standing:lower() .. " standing with " .. W.FactionName(h.faction), "honour") end
  if rpgd and rpgd.homeInn and rpgd.homePrev and rpgd.homePrev ~= rpgd.homeInn then
    event(rpgd.homeSince, 5, "moved from " .. placeName(rpgd.homePrev) .. " to " .. placeName(rpgd.homeInn), "home")
  end
  local lastOf = {}
  for _, ch in ipairs(changes) do lastOf[ch.kind == "guildrank" and "guildrank" or ch.kind == "wealth" and "wealth" or "guild"] = ch end
  if lastOf.guild then
    local ch = lastOf.guild
    event(ch.t, 5, ch.kind == "joined" and "took up the colours of " .. guildName(ch.to)
      or ch.kind == "left" and "left " .. guildName(ch.from)
      or "left " .. guildName(ch.from) .. " for " .. guildName(ch.to), "guild")
  end
  if lastOf.guildrank and not (lastOf.guild and lastOf.guild.t >= lastOf.guildrank.t) then
    local ch = lastOf.guildrank
    event(ch.t, 6, "went from " .. ch.from:lower() .. " to " .. ch.to:lower() .. " in " .. guildName(world.guild or ""), "guildrank")
  end
  if lastOf.wealth then
    local ch = lastOf.wealth
    local from, to = W.WEALTH[ch.from], W.WEALTH[ch.to]
    if from and to then
      event(ch.t, 6, (ch.to > ch.from and "went from " or "came down from ") .. from.word:lower() .. " to " .. to.word:lower(), "wealth")
    end
  end
  local finds = ns.char and ns.char.finds or {}
  local f = finds[#finds]
  if f then event(f.t, 7, "came by " .. itemName(f.item, f.quality) .. (f.zone and (" in " .. U.Mid(f.zone)) or ""), "find") end
  -- Auto TRP's own record of the rest of life on the road.
  local life = c.life
  if life then
    local nf = life.fishNew
    local fish = nf and Compose.FishName(nf.name)
    if fish and nf.zone then event(nf.t, 6, say("ev_fish", { item = article(fish), zone = U.Mid(nf.zone) }, nf.t), "fish") end
    -- Duels: one told plainly, several as a count.
    local recentDuels, won, lastDuel = 0, 0, nil
    for _, du in ipairs(life.duelLog) do
      if recent(du.t) then recentDuels = recentDuels + 1; won = won + (du.won and 1 or 0); lastDuel = du end
    end
    if recentDuels >= 3 then
      event(lastDuel.t, 7, say("ev_duels", { n = U.Number(recentDuels), what = won == recentDuels and "all of them"
        or won == 0 and "none" or U.Number(won) }, lastDuel.t), "duels")
    elseif lastDuel and lastDuel.zone then
      event(lastDuel.t, 7, say(lastDuel.won and "ev_duel_won" or "ev_duel_lost", { zone = U.Mid(lastDuel.zone) }, lastDuel.t), "duels")
    end
    local bl = life.battleLast
    if bl then event(bl.t, 5, say(bl.won and "ev_battle_won" or "ev_battle_lost", { place = U.Mid(bl.name) }, bl.t), "battle") end
    local inn = life.innNew
    if inn and not (rpgd and rpgd.homeInn == inn.name) then
      event(inn.t, 7, say("ev_inn", { inn = placeName(inn.name) }, inn.t), "inn")
    end
    local paths = {}
    for _, pth in ipairs(life.pathsNew) do
      if recent(pth.t) and #paths < 3 then paths[#paths + 1] = pth end
    end
    if #paths == 1 then
      event(paths[1].t, 8, say("ev_path", { place = paths[1].name:match("^([^,]+)") }, paths[1].t), "paths")
    elseif #paths > 1 then
      local names = {}
      for k, pth in ipairs(paths) do names[k] = pth.name:match("^([^,]+)") end
      event(paths[1].t, 8, say("ev_paths", { list = U.Join(names) }, paths[1].t), "paths")
    end
    local mount = life.mounts[1]
    if mount and not mount.before then event(mount.t, 4, say("ev_mount", { item = article(mount.name) }, mount.t), "mount") end
    for _, key in ipairs({ "epic", "rare" }) do
      local gear = life[key]
      if gear and not gear.before and not (key == "rare" and life.epic and not life.epic.before and recent(life.epic.t)) then
        local wield = gear.slot == 16 or gear.slot == 17 or gear.slot == 18
        event(gear.t, 5, say(wield and "ev_wield" or "ev_wear", { item = itemName(gear.name, gear.q) }, gear.name), "gear")
        break
      end
    end
    local readNow = {}
    for _, b in ipairs(life.books) do if recent(b.t) and #readNow < 2 then readNow[#readNow + 1] = b end end
    if #readNow > 0 then
      local titles = {}
      for k, b in ipairs(readNow) do titles[k] = quote(b.name) end
      event(readNow[1].t, 8, say("ev_book", { list = U.Join(titles) }, readNow[1].name), "books")
    end
    local cl = life.closeLast
    if cl and cl.zone then
      event(cl.t, 6, say("ev_close", { who = cl.foe and (" with " .. (cl.named and cl.foe or article(cl.foe))) or "", zone = U.Mid(cl.zone) }, cl.t), "close")
    end
  end

  local groups, order = {}, {}
  for _, e in ipairs(events) do
    local g = whenWords(e.t)
    if not groups[g] then groups[g] = { at = e.t }; order[#order + 1] = g end
    table.insert(groups[g], e)
    if e.t > groups[g].at then groups[g].at = e.t end
  end
  table.sort(order, function(a, b) return groups[a].at > groups[b].at end)
  local lately = {}
  local subject = name
  for i = 1, math.min(2, #order) do
    local g = groups[order[i]]
    table.sort(g, function(a, b) if a.rank ~= b.rank then return a.rank < b.rank end return a.t > b.t end)
    -- Three to a sentence, and two more at most in a second one.
    local preds, more = {}, {}
    for k = 1, math.min(5, #g) do
      table.insert(k <= 3 and preds or more, g[k].text); toldRecent[g[k].key] = true
    end
    -- "caught a fish in Elwynn Forest and came through a fight in Elwynn Forest": the
    -- place once, on the first that says it.
    for _, list in ipairs({ preds, more }) do
      local said = {}
      for k, text in ipairs(list) do
        local head, place = text:match("^(.*) in ([^,]-)$")
        if place and said[place] then list[k] = head elseif place then said[place] = true end
      end
    end
    lately[#lately + 1] = say("when_" .. order[i], nil, g[1].key) .. ", " .. subject .. " " .. U.Join(preds)
    if #more > 0 then lately[#lately + 1] = "{they} also " .. U.Join(more) end
    subject = "{they}"
  end
  paras[#paras + 1] = paragraph(lately)

  -- 3. The longer record: the name and the deed behind it (these stay), then what came
  -- before the news, briefly.
  local record = {}
  for _, s in ipairs(earned or {}) do record[#record + 1] = s end
  local older = {}
  local told = 0
  for _, t in ipairs(rpgd and rpgd.threads or {}) do
    if earnedKey ~= "thread:" .. t.id and not toldRecent["thread:" .. t.id] and told < 2 then
      if t.state == "resolved" then older[#older + 1] = "seen " .. lowerFirst(t.title) .. " through"; told = told + 1
      elseif t.state == "soured" then older[#older + 1] = "watched " .. lowerFirst(t.title) .. " go sour"; told = told + 1 end
    end
  end
  local places = {}
  for _, d in ipairs(rpgd and rpgd.cleared or {}) do
    if #places < 3 and not toldRecent["cleared:" .. d.name] then places[#places + 1] = U.Mid(d.name) end
  end
  if #places > 0 then older[#older + 1] = "been down into " .. U.Join(places) end
  local oldBosses = {}
  for _, b in ipairs(bosses) do
    if not toldRecent["boss:" .. b.name] and earnedKey ~= "boss:" .. b.name then oldBosses[#oldBosses + 1] = b end
  end
  if #bosses >= 3 then
    older[#older + 1] = "helped bring down " .. U.Number(#bosses) .. " named foes"
      .. (oldBosses[1] and (", " .. oldBosses[1].name .. " among them") or "")
  elseif oldBosses[1] then
    older[#older + 1] = "helped bring down " .. oldBosses[1].name
  end
  if chron and chron.rares >= 5 then older[#older + 1] = "tracked down " .. U.Number(chron.rares) .. " rare beasts" end
  local questsDone = Compose.QuestsDone(c)
  if questsDone >= 25 then older[#older + 1] = "seen " .. U.Roughly(questsDone) .. " jobs through" end
  local own = c.deeds or {}
  if (own.flights or 0) >= 10 then older[#older + 1] = "taken " .. U.Roughly(own.flights) .. " flights between towns" end
  if (own.honorKills or 0) >= 10 then older[#older + 1] = "won " .. U.Roughly(own.honorKills) .. " honourable kills in the war" end
  if (own.kills or 0) >= 100 and not (rpgd and rpgd.kills and rpgd.kills > 0) then
    local top, tn = nil, 0
    for n, k in pairs(own.killsByName or {}) do if k > tn then top, tn = n, k end end
    if top and tn >= 20 then older[#older + 1] = "killed more " .. Compose.Plural(top) .. " than any other creature" end
  end
  -- Auto TRP's own record: battles, duels, inns, flight masters and coin.
  if life then
    if life.battles >= 3 then
      local where = life.battleTop and (" in " .. U.Mid(life.battleTop) .. ((life.battleKinds or 0) > 1 and " and elsewhere" or "")) or ""
      older[#older + 1] = "fought " .. U.Number(life.battles) .. " battles" .. where .. ", winning "
        .. (life.battlesWon == life.battles and "every one" or life.battlesWon == 0 and "none" or U.Number(life.battlesWon))
    end
    if life.killingBlows >= 10 then older[#older + 1] = "struck the killing blow on " .. U.Roughly(life.killingBlows) .. " enemy fighters" end
    local duels = life.duelsWon + life.duelsLost
    if duels >= 5 and not toldRecent.duels then
      older[#older + 1] = life.duelsWon == 0 and ("lost all " .. U.Number(duels) .. " of {their} duels")
        or ("won " .. U.Number(life.duelsWon) .. " of " .. U.Number(duels) .. " duels")
    end
    if #life.inns >= 5 then older[#older + 1] = "rested at " .. U.Number(#life.inns) .. " different inns" end
    if life.paths >= 10 then older[#older + 1] = "found the flight masters in " .. U.Number(life.paths) .. " places" end
    local most = math.floor(math.max(life.money.most or 0, type(world.money) == "number" and world.money or 0) / 10000)
    if most >= 100 then older[#older + 1] = "had as much as " .. U.Number(most) .. " gold to {their} name at once" end
    local paid = math.floor((life.money.quests or 0) / 10000)
    if paid >= 50 then older[#older + 1] = "been paid " .. U.Number(paid) .. " gold for {their} jobs" end
    local mend = math.floor((life.money.repairs or 0) / 10000)
    if mend >= 20 then older[#older + 1] = "spent " .. U.Number(mend) .. " gold having {their} gear mended" end
    if (life.money.auctions or 0) >= 5 then older[#older + 1] = "sold " .. U.Roughly(life.money.auctions) .. " things at auction" end
  end
  if lastMs and rankOf(lastMs) and not toldRecent.rank then
    local steps = {}
    for k = math.max(1, #ms - 1), #ms do
      local rank = rankOf(ms[k])
      if rank then steps[#steps + 1] = rank .. (ms[k].zone and (" in " .. U.Mid(ms[k].zone)) or "") end
    end
    older[#older + 1] = "risen to " .. U.Join(steps)
  end
  if #older > 0 then
    local lead = #lately > 0 and say("before", nil, older[1]) or say("alongtheway", nil, older[1])
    -- Three at most to a sentence; the rest start another.
    local a, b = {}, {}
    for k, s in ipairs(older) do if k <= 3 then a[#a + 1] = s elseif k <= 6 then b[#b + 1] = s end end
    record[#record + 1] = lead .. " {they've} " .. U.Join(a)
    if #b > 0 then record[#record + 1] = "{they've} also " .. U.Join(b) end
  end
  local profs = (chron and #chron.professions > 0 and chron.professions) or world.professions or {}
  local crafts = {}
  for k = 1, math.min(2, #profs) do
    local pr = profs[k]
    local pn = W.PROF_NOUN[pr.name:lower()]
    if pr.rank >= 50 and pn then crafts[#crafts + 1] = profWord(pr.rank) .. " " .. pn end
  end
  -- What fills the gaps between roads, from Auto TRP's own record: fish, things made, herbs and ore.
  local pastimes = {}
  if life then
    if life.fish >= 25 then
      pastimes[#pastimes + 1] = "caught " .. U.Roughly(life.fish) .. " fish"
        .. (life.fishZones >= 4 and (" in " .. U.Number(life.fishZones) .. " different lands") or "")
    end
    local profsMade = {}
    for prof, n in pairs(life.madeByProf) do
      if n >= 20 and W.LIFE.MADE[prof] then profsMade[#profsMade + 1] = { prof = prof, n = n } end
    end
    table.sort(profsMade, function(a, b) if a.n ~= b.n then return a.n > b.n end return a.prof < b.prof end)
    for k = 1, math.min(2, #profsMade) do
      pastimes[#pastimes + 1] = (W.LIFE.MADE[profsMade[k].prof]:gsub("{n}", U.Roughly(profsMade[k].n)))
    end
    for _, key in ipairs({ "herbs", "ore", "hides" }) do
      if (life[key] or 0) >= 25 and #pastimes < 4 then pastimes[#pastimes + 1] = (W.LIFE.GATHERED[key]:gsub("{n}", U.Roughly(life[key]))) end
    end
  end
  if #crafts > 0 then
    record[#record + 1] = say("crafts", { list = U.Join(crafts) }, crafts[1])
      .. (#pastimes > 0 and (", " .. say("life_pastimes", { list = U.Join(pastimes) }, crafts[1])) or "")
  elseif #pastimes > 0 then
    record[#record + 1] = say("life_lead", { list = U.Join(pastimes) }, pastimes[1])
  end
  local oldFinds = {}
  for k = #finds, 1, -1 do
    local fd = finds[k]
    if #oldFinds < 2 and not (k == #finds and toldRecent.find) then
      oldFinds[#oldFinds + 1] = itemName(fd.item, fd.quality) .. (fd.zone and (" from " .. U.Mid(fd.zone)) or "")
    end
  end
  if #oldFinds > 0 then record[#record + 1] = say("finds", { list = U.Join(oldFinds) }, finds[1].item) end
  paras[#paras + 1] = paragraph(record)

  -- 4. The people: friends, the company they keep, their pet, their guild, standing.
  -- Other players are only ever counted; Social Diary friends are named when allowed.
  local people = {}
  local co = c.company or {}
  local Co = ns.Sources.Company
  local friends = {}
  if rpgd then
    for k = 1, math.min(2, #rpgd.friends) do friends[k] = rpgd.friends[k].name end
  end
  local partner
  if sd and ns.db.nameFriends and #sd.friends > 0 then
    local fr = sd.friends[1]
    if fr.relationship then
      partner = fr.name .. ", {their} " .. fr.relationship:lower() .. (sd.friends[2] and (", and " .. sd.friends[2].name) or "")
    else
      local names = {}
      for k = 1, math.min(3, #sd.friends) do names[k] = sd.friends[k].name end
      partner = U.Join(names)
    end
  end
  if #friends > 0 then
    people[#people + 1] = say("friends", { name = name, list = U.Join(friends) }, friends[1])
      .. (partner and (", and travels with " .. partner) or "")
  elseif partner then
    people[#people + 1] = name .. " travels with " .. partner
  end
  -- How they go about: alone or in company, and who has shared the road (counts only).
  local sol = co.solitude or {}
  local habit = Compose.CompanyHabit(sol)
  local week = (sol.week or 0) > 0 and sol.week or (sd and sd.recentPeople or 0)
  local weekLine = week >= 2 and cw("h_week", { n = U.Number(week) }, week) or nil
  if habit then
    local line = cw("h_" .. habit, { name = name }, habit)
    if weekLine then
      if habit == "loner" then
        line = line .. ", though {they} " .. weekLine:gsub("^has ", "{have} ")
      else
        line = line .. ", and " .. weekLine
      end
    end
    people[#people + 1] = line
  elseif weekLine then
    people[#people + 1] = U.Cap(weekLine)
  end
  if (sol.recurring or 0) >= 1 then
    people[#people + 1] = sol.recurring == 1 and cw("h_recurring_one", nil, 1)
      or cw("h_recurring", { n = U.Number(sol.recurring) }, sol.recurring)
  end
  if (sol.soloDungeons or 0) >= 1 then
    people[#people + 1] = cw("h_solo", { times = U.Times(sol.soloDungeons) }, sol.soloDungeons)
  end
  -- The pet: the one at their side now (or, for a warlock, the demon called most).
  local pets = co.pets or {}
  if (world.class == "HUNTER" or world.class == "WARLOCK") and #pets > 0 then
    local cur
    if world.class == "WARLOCK" then cur = pets[1] else
      for _, pt in ipairs(pets) do if pt.name == world.pet then cur = pt end end
      if not cur then
        for _, pt in ipairs(pets) do if not cur or pt.last > cur.last then cur = pt end end
      end
    end
    local kind = cur.kind and cur.kind:lower() or (world.class == "WARLOCK" and "demon" or "beast")
    local vars = { name = name, pet = cur.name, kind = kind, akind = article(kind) }
    if world.class == "WARLOCK" then
      if #pets >= 2 then people[#people + 1] = cw("h_demon", vars, cur.name) end
    else
      local held = now - (cur.first or now)
      local line
      if held >= 86400 then
        vars.span = Co.Span(held)
        line = cw("h_pet", vars, cur.name)
        if (cur.deaths or 0) > 0 then
          vars.times = U.Times(cur.deaths)
          line = line .. cw("pet_fallen", vars, cur.name)
        end
      elseif now - ((ns.char.company and ns.char.company.since) or now) > 3 * 86400 then
        line = cw("h_pet_new", vars, cur.name)
      end
      people[#people + 1] = line
      local before = {}
      for _, pt in ipairs(pets) do
        if pt.name ~= cur.name and #before < 2 then before[#before + 1] = pt.name .. (pt.kind and (" the " .. pt.kind:lower()) or "") end
      end
      if #before > 0 then people[#people + 1] = cw("h_pets_before", { pet = cur.name, list = U.Join(before) }, cur.name) end
    end
  end
  if rpgd then
    local good, bad = {}, nil
    for _, t in ipairs(rpgd.towns) do
      if t.value >= 10 and #good < 2 then good[#good + 1] = (ns.Sources.RPGD.Tier(t.value).phrase:gsub("{town}", t.name)) end
    end
    local worst = rpgd.towns[#rpgd.towns]
    if worst and worst.value <= -20 then bad = (ns.Sources.RPGD.Tier(worst.value).phrase:gsub("{town}", worst.name)) end
    if #good > 0 then
      people[#people + 1] = U.Cap(U.Join(good)) .. (bad and (", though " .. bad) or "")
    elseif bad then
      people[#people + 1] = U.Cap(bad)
    end
  end
  local byWord = {}
  for _, fa in ipairs(world.factions or {}) do
    byWord[fa.word] = byWord[fa.word] or {}
    if #byWord[fa.word] < 2 then table.insert(byWord[fa.word], W.FactionName(fa.name)) end
  end
  local served = {}
  for _, w in ipairs({ "Exalted", "Revered", "Honored" }) do
    for _, fa in ipairs(byWord[w] or {}) do if #served < 3 then served[#served + 1] = fa end end
  end
  local serve = #served > 0 and ("has done good work for " .. U.Join(served)) or nil
  if world.guild then
    -- How long they've worn the colours: from when Auto TRP saw them join, or at least as
    -- long as it has been watching.
    local gi = co.guild or {}
    local tracked = (ns.char.company and ns.char.company.since) or now
    local since = gi.since and now - gi.since or 0
    local vars = { name = name, guild = guildName(world.guild),
      rank = world.guildRank and (" and holds the rank of " .. world.guildRank:lower() .. " there") or "" }
    local line
    if since >= 86400 then
      vars.span = Co.Span(since) .. ((gi.since or 0) <= tracked + 600 and " at least" or "")
      line = cw("h_guild", vars, world.guild)
    elseif toldRecent.guild and lastOf.guild and lastOf.guild.kind ~= "left" then
      -- The news has just told of joining: not "took up the colours of X" and then "Wears
      -- the colours of X" again. Only the rank, if there is one.
      line = world.guildRank and ("Holds the rank of " .. world.guildRank:lower() .. " in " .. vars.guild) or nil
    else
      line = cw("h_guild_now", vars, world.guild)
    end
    if line then people[#people + 1] = line .. (serve and (", and " .. serve) or "")
    elseif serve then people[#people + 1] = U.Cap(serve) end
  elseif serve then
    people[#people + 1] = U.Cap(serve)
  end
  if world.pvpRank then
    people[#people + 1] = "Holds the rank of " .. world.pvpRank .. " in the " .. (world.faction or "faction") .. "'s army"
  end
  if rpgd and rpgd.rivals[1] then
    people[#people + 1] = say("rival", { who = rpgd.rivals[1].name }, rpgd.rivals[1].name)
  end
  if sd and #sd.foes > 0 then
    people[#people + 1] = say("foes", { what = #sd.foes == 1 and "an enemy" or (U.Number(#sd.foes) .. " enemies") }, #sd.foes)
  end
  paras[#paras + 1] = paragraph(people)

  -- 5. How things stand now
  local nowLines = {}
  local days = ns.Mood.RecentDays(3)
  local bits = {}
  for _, d in ipairs(days) do
    local m = d.mood and W.MOODS[d.mood] and W.MOODS[d.mood].title:lower()
    if m and d.zone then bits[#bits + 1] = m .. " in " .. U.Mid(d.zone) .. " " .. d.label
    elseif m then bits[#bits + 1] = m .. " " .. d.label end
  end
  nowLines[#nowLines + 1] = Compose.WeekTone()
  if #bits >= 2 then nowLines[#nowLines + 1] = "Felt " .. U.Join(bits) end
  local wb = Compose.WealthBand(world)
  if wb and not toldRecent.wealth then nowLines[#nowLines + 1] = wb.flair end
  if rpgd and ns.db.diaryExcerpt and rpgd.lastEntry and rpgd.lastEntry.text then
    nowLines[#nowLines + 1] = say("diary", { q = quote(U.Truncate(rpgd.lastEntry.text, 280)) }, rpgd.lastEntry.text)
  elseif ns.Journal then
    nowLines[#nowLines + 1] = ns.Journal.LatestLine(quote)   -- Auto TRP's own journal (Journal.lua)
  end
  paras[#paras + 1] = paragraph(nowLines)
  paras[6] = Compose.Drives()   -- 6. What drives them

  return pages(paras)
end

---------------------------------------------------------------------------
-- About: Physical, from the live game first (gear, auras, stats, health), with Chronicle's
-- snapshot only to fill a gap. Three paragraphs: the body, what they wear and carry, and
-- how they are right now. Nothing is named that the game doesn't show.
---------------------------------------------------------------------------
local function physique(c)
  local stats = c.world.stats
  if type(stats) ~= "table" or next(stats) == nil then
    stats = (c.chronicle and c.chronicle.appearance and c.chronicle.appearance.stats) or {}
  end
  local best, bestV
  for name, v in pairs(stats) do
    if type(v) == "number" and W.PHYSIQUE[name] and (not bestV or v > bestV or (v == bestV and name < best)) then best, bestV = name, v end
  end
  return best and U.Pron(U.Pick(W.PHYSIQUE[best], seed("phys" .. best))) or nil
end

-- Pronoun and verb tags are left for U.Pron; any other {tag} must be filled.
local PRON_TAGS = { they = true, them = true, their = true, themselves = true, ["they've"] = true, ["they're"] = true,
  s = true, es = true, ies = true, are = true, have = true }

-- One line of a list, picked per character and key, with only the lines whose tags are known.
local function fillPick(list, vars, key)
  local ok = {}
  for _, t in ipairs(type(list) == "table" and list or {}) do
    local whole = true
    for k in t:gmatch("{([%a']+)}") do
      if not PRON_TAGS[k] and (not vars or vars[k] == nil) then whole = false end
    end
    if whole then ok[#ok + 1] = t end
  end
  if #ok == 0 then return nil end
  local line = U.Pick(ok, seed("phys:" .. key))
  return (line:gsub("{([%a']+)}", function(k) if not PRON_TAGS[k] then return vars[k] end end))
end

-- "Walks with Staff of Westfall, a staff": when the weapon's own name already says what it
-- is, the aside goes ("Walks with Staff of Westfall").
local function dropKind(text, name, kind)
  if type(text) ~= "string" or type(name) ~= "string" or type(kind) ~= "string" then return text end
  local noun = kind:match("(%a+)$")
  if not noun or not (" " .. name:lower() .. " "):find("[^%a]" .. noun .. "[^%a]") then return text end
  text = text:gsub(", an? [%a ]-" .. noun .. ",", ""):gsub(", an? [%a ]-" .. noun .. "$", "")
  text = text:gsub(", {their} " .. noun .. ",", "")
  return text
end

local function stage(level)
  level = level or 1
  if level < 20 then return "green" elseif level < 45 then return "seasoned" end
  return "veteran"
end

local ARMOUR_RANK = { Cloth = 1, Leather = 2, Mail = 3, Plate = 4 }
-- What a class can wear from level 40 (plate for warriors and paladins, mail for hunters and shamans).
local CLASS_ARMOUR = { WARRIOR = 4, PALADIN = 4, HUNTER = 3, SHAMAN = 3 }

-- How the hands are filled: twohand, staff, dual, shield, holdable, one, offonly or nil.
local function armsKey(s)
  local m, o = s[16], s[17]
  if m then
    if m.sub == "Staves" then return "staff" end
    if W.TWO_HANDED[m.sub or ""] or m.loc == "INVTYPE_2HWEAPON" then return "twohand" end
    if o then
      if o.sub == "Shields" or o.loc == "INVTYPE_SHIELD" then return "shield" end
      if W.WEAPONS[o.sub or ""] or (type(o.loc) == "string" and o.loc:find("WEAPON")) then return "dual" end
      return "holdable"
    end
    return "one"
  end
  if o then return "offonly" end
  return nil
end

-- Everything worth saying about the gear, as sentences (without full stops). fmt colours an
-- item's name (About); without it names stay plain (the glance). `named` holds the slots
-- already told, so nothing is said twice.
function Compose.GearParts(world, fmt)
  local g = world.gear or {}
  local s = g.slots or {}
  local out = { named = {} }
  local function name(id) local it = s[id]; if it and it.name then return fmt and fmt(it.name, it.q) or it.name end end
  local function told(id) out.named[id] = true; return name(id) end

  -- Armour: what most of it is, and how fine
  local counts = g.armourCount or {}
  if g.armourType and W.ARMOUR_WORD[g.armourType] then
    out.armourType, out.mixed = g.armourType, g.armourMixed
    local line
    if g.armourMixed then
      local kinds = {}
      for sub in pairs(counts) do kinds[#kinds + 1] = sub end
      table.sort(kinds, function(a, b) if counts[a] ~= counts[b] then return counts[a] > counts[b] end return a < b end)
      for i, k in ipairs(kinds) do kinds[i] = W.ARMOUR_WORD[k] end
      line = fillPick(W.PHYS_ARMOUR_MIX, { list = U.Join(kinds) }, "mix")
    else
      line = fillPick(W.PHYS_ARMOUR[g.armourType], nil, "armour" .. g.armourType)
    end
    local total, mode, modeN, finer = 0, nil, 0, 0
    for q, n in pairs(g.qualityCount or {}) do
      total = total + n
      if n > modeN or (n == modeN and q < mode) then mode, modeN = q, n end
    end
    if mode then for q, n in pairs(g.qualityCount) do if q > mode then finer = finer + n end end end
    if line and total >= 3 and W.QUALITY_WORD[mode] then
      local Q = W.PHYS_QUALITY
      local clause = fillPick(modeN == total and Q.all or Q.most, { word = W.QUALITY_WORD[mode] }, "qual")
      if finer == 1 then clause = clause .. ", " .. fillPick(Q.finer, nil, "finer")
      elseif finer > 1 then clause = clause .. ", " .. fillPick(Q.finerN, { n = U.Number(finer) }, "finer") end
      out.quality = clause
    end
    out.armour = line
    -- Lighter than the class usually goes, once heavier is open to them
    local want = CLASS_ARMOUR[world.class or ""]
    if want and (world.level or 0) >= 40 and not g.armourMixed and (ARMOUR_RANK[g.armourType] or 4) <= want - 2 then
      out.light = fillPick(W.PHYS_ARMOUR_LIGHT, nil, "light")
    end
  end

  -- The pieces that show
  local extras = {}
  for _, id in ipairs({ 1, 3 }) do
    if s[id] then extras[#extras + 1] = told(id) .. " " .. W.PHYS_ON[id] end
  end
  if s[5] then
    local outfit = told(5) .. (#extras > 0 and (", with " .. U.Join(extras)) or "")
    out.outfit = fillPick(out.armour and W.PHYS_OUTFIT.armoured or W.PHYS_OUTFIT.bare, { outfit = outfit }, "outfit")
  elseif #extras > 0 then
    out.outfit = fillPick(W.PHYS_OUTFIT.bare, { outfit = U.Join(extras) }, "outfit")
  end
  local L = W.PHYS_LAYERS
  if s[15] and s[19] then out.layers = fillPick(L.both, { cloak = told(15), tabard = told(19) }, "layers")
  elseif s[19] then out.layers = fillPick(L.tabard, { tabard = told(19) }, "tabard")
  elseif s[15] then out.layers = fillPick(L.cloak, { cloak = told(15) }, "cloak") end
  if s[4] and not s[5] then
    local shirt = fillPick(L.shirt, { shirt = told(4) }, "shirt")
    out.layers = out.layers and (out.layers .. ". " .. U.Cap(shirt)) or shirt
  end

  -- Matched pieces
  local set = g.sets and g.sets[1]
  if set and set.n >= 2 then
    local vars = { n = U.Number(set.n), set = set.name and (fmt and fmt(set.name, set.q) or set.name) }
    local S = W.PHYS_SET
    out.set = fillPick(set.n >= 5 and vars.set and S.full or vars.set and S.named or S.unnamed, vars, "set")
    out.setN = set.n
  end

  -- Weapons, by how they're carried
  local key = armsKey(s)
  if key then
    local m, o = s[16], s[17]
    local vars = { main = m and told(16), off = o and told(17), kind = m and W.WEAPONS[m.sub or ""] }
    vars.shield = key == "shield" and vars.off or nil
    out.arms = dropKind(fillPick(W.PHYS_ARMS[key], vars, "arms" .. key), m and m.name, key == "staff" and "a staff" or vars.kind)
    out.armsKey = key
  elseif not s[18] and (world.level or 1) >= 10 and not world.form then
    out.arms = fillPick(W.PHYS_ARMS.none, nil, "unarmed")
  end
  if s[18] then
    out.ranged = dropKind(fillPick(W.PHYS_RANGED[s[18].sub or ""] or W.PHYS_RANGED.default, { ranged = told(18) }, "ranged"),
      s[18].name, W.WEAPONS[s[18].sub or ""])
  end

  -- Enchantments: the weapon first, else how many
  local ench = g.enchanted or {}
  local E = W.PHYS_ENCHANT
  if #ench >= 3 then
    out.enchant = fillPick(E.many, { n = U.Number(#ench) }, "ench")
    if s[16] and s[16].enchant then out.enchantWeapon = fillPick(E.weapon, { main = name(16) }, "enchw") end
  else
    local others = {}
    for _, id in ipairs(ench) do
      if id == 16 and s[16] then
        out.enchantWeapon = fillPick(E.weapon, { main = name(16) }, "enchw")
        out.enchantIt = out.named[16] and fillPick(E.it, nil, "enchit") or out.enchantWeapon
      elseif s[id] then others[#others + 1] = id end
    end
    local parts = {}
    if #others == 1 then parts[#parts + 1] = fillPick(E.one, { item = name(others[1]) }, "ench1")
    elseif #others == 2 then parts[#parts + 1] = fillPick(E.many, { n = U.Number(2) }, "ench") end
    if #parts > 0 then out.enchant = table.concat(parts, ". ") end
  end

  -- Jewellery, only the remarkable (epic and better)
  local function epic(id) return s[id] and (s[id].q or 0) >= 4 end
  local J = W.PHYS_JEWEL
  local jewel = {}
  if epic(11) and epic(12) then jewel[#jewel + 1] = fillPick(J.rings, { item = told(11), item2 = told(12) }, "rings")
  elseif epic(11) or epic(12) then local id = epic(11) and 11 or 12; jewel[#jewel + 1] = fillPick(J.ring, { item = told(id) }, "ring") end
  if epic(2) then
    if #jewel > 0 then jewel[1] = jewel[1] .. ", " .. fillPick(J.neckAlso, { item = told(2) }, "neck")
    else jewel[#jewel + 1] = fillPick(J.neck, { item = told(2) }, "neck") end
  end
  local trinkets = {}
  for _, id in ipairs({ 13, 14 }) do if epic(id) then trinkets[#trinkets + 1] = told(id) end end
  if #trinkets > 0 then jewel[#jewel + 1] = fillPick(J.trinket, { item = U.Join(trinkets) }, "trinket") end
  if #jewel > 0 then out.jewel = table.concat(jewel, ". "); out.jewelEpic = true end

  -- The finest piece, if it hasn't been named yet
  local finest = g.finest
  if finest and finest.name and (finest.quality or 0) >= 4 and not out.named[finest.slot] then
    out.finest = fillPick(W.PHYS_FINEST, { item = fmt and fmt(finest.name, finest.quality) or finest.name }, "finest")
  end

  -- How it sits with how far along the road they are
  local level = world.level
  if g.ilvl and level and (g.ilvlN or 0) >= 4 then
    local F = W.PHYS_FIT
    if level >= 60 then
      if g.ilvl >= 70 then out.fit = fillPick(F.top, nil, "fit") end
    elseif level >= 20 and g.ilvl <= level - 7 then out.fit = fillPick(F.behind, nil, "fit")
    elseif g.ilvl >= level + 15 then out.fit = fillPick(F.ahead, nil, "fit") end
  end
  return out
end

-- What is on them right now: { prio, title (for the Marks glance, or nil), text, icon },
-- the most striking first. From the live game; RPG Dialogue adds drink and madness.
function Compose.NowMarks(c)
  c = c or ns.cache
  local world, rpgd = c.world or {}, Compose.Persona(c)
  local auras = world.auras or {}
  local names = auras.names or {}
  local list = {}
  local function add(prio, title, text, icon)
    if text then list[#list + 1] = { prio = prio, title = title, text = text, icon = icon } end
  end
  if world.ghost then add(10, "A Ghost", fillPick(W.PHYS_GHOST, nil, "ghost"), "Spell_Holy_GuardianSpirit") end
  if type(world.health) == "number" and not world.combat and not world.dead then
    for _, b in ipairs(W.PHYS_HEALTH) do
      if world.health < b.max then
        -- Freshly wounded has more ways of being said (W.SAY.mark_wounded) beside its own
        local text = fillPick(b.text, nil, "hp" .. b.max)
        if b.max == 0.5 and W.SAY.mark_wounded and U.Hash(seed("hpsay") .. tostring(world.zone)) % 2 == 0 then
          text = say("mark_wounded", nil, world.zone)
        end
        add(b.glance and (9 + (0.5 - b.max)) or 3, b.glance, text, "Ability_Rogue_FeignDeath")
        break
      end
    end
  end
  if auras.resSick then add(8.5, "Back from Death", fillPick(W.PHYS_RESSICK, nil, "ressick"), "Spell_Shadow_DeathScream") end
  -- Drink: the game's own word for it, or RPG Dialogue's count
  local drunk = world.drunk
  if not drunk and rpgd and (rpgd.drunk or 0) > 0 and U.Now() - (rpgd.drunkAt or 0) < 1800 then drunk = 2 end
  local d = drunk and W.PHYS_DRUNK[U.Clamp(drunk, 1, #W.PHYS_DRUNK)]
  if d then add(7.9 + drunk * 0.05, d.glance, fillPick(d.text, nil, "drunk" .. drunk), "INV_Drink_05") end
  for kind, a in pairs(W.PHYS_AILMENT) do
    if auras.kinds and auras.kinds[kind] then add(a.prio, a.glance, fillPick(a.text, nil, "ail" .. kind), a.icon) end
  end
  if rpgd and (rpgd.insanity or 0) >= 30 then
    add(7, "Haunted Eyes", say("mark_mad"), "Spell_Shadow_Possession")
  end
  if rpgd and rpgd.align and (rpgd.align.taint or 0) >= 30 then
    add(6, "Something Wrong", say("mark_taint"), "Spell_Shadow_ShadowWordPain")
  end
  -- A shape: druid forms, the ghost wolf, shadowform
  if world.form then
    local title, icon = "Another Shape", "Ability_Druid_CatForm"
    for aura, m in pairs(W.FORM_MARK) do if names[aura] then title, icon = m[1], m[2] end end
    add(6.5, title, fillPick(W.PHYS_FORM, { form = world.form }, "form"), icon)
  end
  -- Spells and blessings on them; only the strongest of the quiet blessings is told
  local quiet = false
  for i, e in ipairs(W.AURA_LOOK) do
    local hit
    for _, n in ipairs(e.names or {}) do if names[n] then hit = n; break end end
    if not hit and e.prefix then
      for n in pairs(names) do if n:sub(1, #e.prefix) == e.prefix then hit = n; break end end
    end
    if hit and (e.glance or not quiet) then
      if not e.glance then quiet = true end
      add(e.prio, e.glance, fillPick(e.text, { aura = hit }, "aura" .. i), e.icon)
    end
  end
  if world.stealthed and not names["Shadowmeld"] then
    add(5.4, "In the Shadows", fillPick(W.PHYS_STEALTH, nil, "stealth"), "Ability_Stealth")
  end
  if world.mounted and not world.taxi and ns.World and ns.World.Mount then
    add(2.5, "Mounted", fillPick(W.PHYS_MOUNT, { mount = ns.World.Mount(world) }, "mount"), "Ability_Mount_RidingHorse")
  end
  if auras.eating or auras.drinking then
    add(2.2, "At a Meal", fillPick(W.PHYS_MEAL[auras.eating and "eating" or "drinking"], nil, "meal"), "INV_Misc_Food_15")
  end
  if world.pet and not world.mounted and not world.taxi then
    add(1, nil, fillPick(W.PHYS_PET, { pet = world.pet, kind = (world.petKind or "companion"):lower() }, "pet"))
  end
  table.sort(list, function(a, b) if a.prio ~= b.prio then return a.prio > b.prio end return a.text < b.text end)
  return list
end

function Compose.Physical()
  local c = ns.cache
  local world = c.world
  local noun = W.CLASS_NOUN[world.class or ""] or "wanderer"

  -- The body: what every one of their race shares, their build from their stats, how their
  -- class and their years on the road have taught them to stand.
  local body = {}
  local rl = U.BackedList(W.RACE_LOOK[world.race or ""], world)
  if #rl > 0 then body[#body + 1] = U.Pick(rl, seed("racelook")) end
  local build = physique(c)
  body[#body + 1] = article(seasoned(world.level, "seasoned")) .. " " .. noun .. (build and (", " .. build) or "")
  local stances = W.PHYS_STANCE[world.class or ""]
  local stance = stances and fillPick(stances[stage(world.level)], nil, "stance")
  if not stance then
    local cl = U.BackedList(noGear(W.CLASS_LOOK[world.class or ""]), world)
    if #cl > 0 then stance = U.Pick(cl, seed("classlook")) end
  end
  body[#body + 1] = stance
  body[#body + 1] = fillPick(W.RACE_BEARING[world.race or ""], nil, "bearing")

  -- What they wear and carry, by name, and what their class keeps in the bags
  local p = Compose.GearParts(world, itemName)
  local dress = {}
  local function add(line) if line then dress[#dress + 1] = line end end
  for _, k in ipairs({ "armour", "quality", "outfit", "layers", "set", "arms", "enchantIt", "ranged", "enchant", "jewel",
    "finest", "light", "fit" }) do add(p[k]) end
  local wear = Compose.Wear(world)
  add(wear and wear.text)
  local bag = {}
  for i, r in ipairs(world.reagents or {}) do
    if i > 3 then break end
    bag[#bag + 1] = r.count > 1 and (U.Number(r.count) .. " " .. Compose.Plural(r.name)) or r.name
  end
  if #bag > 0 then add("Keeps " .. U.Join(bag) .. " in {their} bags") end
  local band = Compose.WealthBand(world)
  add(band and U.Backed(band.pouch, world))
  -- Nothing worn the game can name: the kit line, as the glance has it
  if not (p.armour or p.outfit or p.arms or p.ranged) then
    local k = kit(world, false, itemName)
    if k then table.insert(dress, 1, k) end
  end

  -- How they are right now: up to four things, the most striking first
  local now = {}
  for _, m in ipairs(Compose.NowMarks(c)) do
    if #now < 4 then now[#now + 1] = m.text end
  end
  local lvl = world.level or 1
  if #now < 2 and lvl < 60 and not world.dead then
    if type(world.rested) == "number" and world.rested > 0 then now[#now + 1] = fillPick(W.PHYS_RESTED, nil, "rested")
    elseif world.rested == nil and world.restKnown and not world.resting and lvl >= 10 then now[#now + 1] = fillPick(W.PHYS_UNRESTED, nil, "unrested") end
  end
  if #now == 0 and not world.dead and (world.health or 1) >= 0.8 then now[1] = fillPick(W.PHYS_UNHURT, nil, "unhurt") end

  return pages({ paragraph(body), paragraph(dress), paragraph(now) })
end

---------------------------------------------------------------------------
-- Statistics: plain counts for Total RP 3's Additional information, kept out of the prose.
---------------------------------------------------------------------------
-- Each one is a custom Additional information entry with its own switch (fields.stat_<key>).
Compose.STATS = {
  { key = "deaths", label = "Deaths", icon = "Ability_Rogue_FeignDeath" },
  { key = "lands", label = "Lands explored", icon = "INV_Misc_Map_01" },
  { key = "road", label = "Days on the road", icon = "INV_Misc_PocketWatch_01" },
  { key = "dungeons", label = "Dungeons", icon = "INV_Misc_Key_14" },
  { key = "foes", label = "Named foes felled", icon = "INV_Misc_Head_Dragon_01" },
  { key = "rares", label = "Rare beasts", icon = "Ability_Hunter_BeastCall" },
  { key = "slain", label = "Creatures slain", icon = "Ability_DualWield" },
  { key = "jobs", label = "Jobs done", icon = "INV_Misc_Note_06" },
  { key = "wealth", label = "Wealth", icon = "INV_Misc_Coin_02" },
  { key = "crafts", label = "Crafts", icon = "Trade_Engineering" },
  { key = "standing", label = "Best standing", icon = "INV_BannerPVP_02" },
  { key = "names", label = "Names earned", icon = "INV_Misc_Note_04" },
  { key = "spell", label = "Most cast spell", icon = "Spell_Holy_MagicalSentry" },
  -- Retired: they meant little to anyone reading the profile. Kept so that what an
  -- earlier version wrote is taken off again (they never have a value now).
  { key = "met", label = "People met", icon = "Spell_Holy_PrayerOfSpirit", retired = true },
  { key = "books", label = "Books read", icon = "INV_Misc_Book_09" },
  -- From Auto TRP's own record of life on the road (Sources/Life.lua).
  { key = "fish", label = "Fish caught", icon = "Trade_Fishing" },
  { key = "made", label = "Things made", icon = "Trade_BlackSmithing" },
  { key = "gathered", label = "Gathered", icon = "Trade_Herbalism" },
  { key = "duels", label = "Duels", icon = "Ability_Warrior_Challange" },
  { key = "battles", label = "Battles", icon = "INV_BannerPVP_01" },
  { key = "gold", label = "Most gold held", icon = "INV_Misc_Coin_01" },
  { key = "inns", label = "Inns stayed at", icon = "INV_Drink_05" },
  { key = "hit", label = "Hardest hit", icon = "Ability_Warrior_Rampage" },
  { key = "letters", label = "Letters received", icon = "INV_Letter_15", retired = true },
}

-- How well off, against what's usual at their level.
function Compose.WealthBand(world)
  if type(world.money) ~= "number" or not world.level then return nil end
  local r = world.money / math.max(1, world.level ^ 2)
  for _, b in ipairs(W.WEALTH) do if r < b.max then return b end end
end

local function money(copper)
  local g, sv = math.floor(copper / 10000), math.floor(copper / 100) % 100
  if g > 0 then return (g >= 100 and U.Number(g) or tostring(g)) .. " gold" .. (sv > 0 and (", " .. sv .. " silver") or "") end
  return sv .. " silver"
end

local function roadDays(c)
  local first = c.rpgd and c.rpgd.zones[1] and c.rpgd.zones[1].t
  local since = math.min(first or math.huge, c.chronicle and c.chronicle.created or math.huge, c.deeds and c.deeds.since or math.huge)
  if since == math.huge then return nil end
  return math.floor((U.Now() - since) / 86400)
end

-- Plain counts, as figures ("1,240", "39"), only for what the game or the addons record.
function Compose.Stats()
  local c = ns.cache
  local rpgd, chron, world = Compose.Persona(c), c.chronicle, c.world
  local function figure(n) return n >= 100 and U.Number(n) or tostring(n) end
  local out = {}
  local deaths = deathCount(c)
  if deaths > 0 then
    local first = rpgd and rpgd.deaths[1] or (chron and chron.deaths[#chron.deaths]) or (c.deeds and c.deeds.deaths[1])
    local killer = first and first.killer and (first.common and article(first.killer) or first.killer)
    out.deaths = figure(deaths) .. (killer and ((deaths == 1 and ", to " or ", the first to ") .. killer) or "")
  end
  local own = c.deeds or {}
  local lands = math.max(rpgd and #rpgd.zones or 0, chron and chron.zones or 0, own.zones and #own.zones or 0)
  if lands > 0 then out.lands = figure(lands) end
  local days = roadDays(c)
  if days and days > 0 then out.road = figure(days) end
  local dungeons = math.max(chron and chron.dungeons or 0, rpgd and #rpgd.cleared or 0, own.dungeons or 0)
  if dungeons > 0 then out.dungeons = figure(dungeons) end
  local felled = #Compose.Bosses(c)
  if felled > 0 then out.foes = figure(felled) end
  if chron and chron.rares > 0 then out.rares = figure(chron.rares) end
  local kills = math.max(rpgd and rpgd.kills or 0, own.kills or 0)
  if kills > 0 then
    out.slain = figure(kills)
    local grudge = rpgd and rpgd.grudge
    if not grudge or (own.kills or 0) > (rpgd and rpgd.kills or 0) then
      for n, k in pairs(own.killsByName or {}) do
        if not grudge or k > grudge.n then grudge = { name = n, n = k } end
      end
    end
    if grudge and grudge.n >= 10 then
      out.slain = out.slain .. ", " .. figure(grudge.n) .. " of them " .. Compose.Plural(grudge.name)
    end
  end
  local questsDone = Compose.QuestsDone(c)
  if questsDone > 0 then out.jobs = figure(questsDone) end
  local band = Compose.WealthBand(world)
  if band then out.wealth = band.word .. " (" .. money(world.money) .. ")" end
  local profs = (chron and #chron.professions > 0 and chron.professions) or world.professions or {}
  local crafts = {}
  for i = 1, math.min(3, #profs) do crafts[i] = profs[i].name .. " " .. profs[i].rank end
  if #crafts > 0 then out.crafts = table.concat(crafts, ", ") end
  local top = world.factions and world.factions[1]
  if top and top.word then out.standing = top.word .. " with " .. W.FactionName(top.name) end
  local books = #Compose.Books()
  if books > 0 then out.books = figure(books) end
  -- Auto TRP's own record of life on the road.
  local life = c.life
  if life then
    local function most(name, n, total, noun)
      return (name and n >= 10 and n < total) and (", most of them " .. noun(name)) or ""
    end
    if life.fish > 0 then
      local fishTop = Compose.FishName(life.fishTop)
      out.fish = figure(life.fish) .. most(fishTop, life.fishTopN, life.fish, Compose.Plural)
    end
    if life.made > 0 then out.made = figure(life.made) .. most(life.madeTop, life.madeTopN, life.made, Compose.Plural) end
    local got = {}
    if life.herbs > 0 then got[#got + 1] = figure(life.herbs) .. " " .. U.Plural(life.herbs, "herb") end
    if life.ore > 0 then got[#got + 1] = figure(life.ore) .. " ore" end
    if life.hides > 0 then got[#got + 1] = figure(life.hides) .. " " .. U.Plural(life.hides, "hide") end
    if #got > 0 then out.gathered = table.concat(got, ", ") end
    if life.duelsWon + life.duelsLost > 0 then out.duels = figure(life.duelsWon) .. " won, " .. figure(life.duelsLost) .. " lost" end
    if life.battles > 0 or life.killingBlows > 0 then
      local parts = {}
      if life.battles > 0 then parts[1] = figure(life.battles) .. " fought, " .. figure(life.battlesWon) .. " won" end
      if life.killingBlows > 0 then parts[#parts + 1] = figure(life.killingBlows) .. " " .. U.Plural(life.killingBlows, "killing blow") end
      out.battles = table.concat(parts, "; ")
    end
    local held = math.max(life.money.most or 0, type(world.money) == "number" and world.money or 0)
    if held > 0 then out.gold = money(held) end
    local inn = life.inns[1]
    if inn then out.inns = figure(#life.inns) .. ((#life.inns > 1 and (inn.n or 1) >= 3) and (", most often the " .. inn.name):gsub("the The ", "the ") or "") end
    local dealt, taken = life.hitDealt, life.hitTaken
    local parts = {}
    if dealt then parts[1] = figure(dealt.n) .. (dealt.spell and (" with " .. dealt.spell) or " in melee") end
    if taken then parts[#parts + 1] = figure(taken.n) .. " taken" .. (taken.from and (" from " .. taken.from) or "") end
    if #parts > 0 then out.hit = table.concat(parts, "; ") end
  end
  -- Every name earned, the one worn first ("Mine-Warden, Defias-Breaker and Hogger's Bane").
  local names, worn = {}, Compose.Earned()
  if worn then names[1] = worn.nick end
  for _, e in ipairs(Compose.EarnedAll()) do
    if e ~= worn and #names < 5 then names[#names + 1] = e.nick end
  end
  if #names > 0 then out.names = U.Join(names) end
  -- The most cast spell, with how many times ("Flash Heal, 1,240 times").
  local top = Compose.TopSpells(1)[1]
  if top and top.n >= 10 then out.spell = top.name .. ", " .. figure(top.n) .. " times"
  elseif top then out.spell = top.name .. ", " .. U.Times(top.n) end
  -- Nothing counted yet still says so, so no statistic is left blank.
  if not out.road and days == 0 then out.road = "Less than a day" end
  if not out.lands and world.zone then out.lands = "1" end
  for _, k in ipairs({ "deaths", "lands", "road", "dungeons", "foes", "rares", "slain", "jobs", "crafts", "standing", "books", "names", "spell",
    "fish", "made", "gathered", "duels", "battles", "gold", "inns", "hit" }) do
    out[k] = out[k] or "None yet"
  end
  return out
end

---------------------------------------------------------------------------
-- Name fields
---------------------------------------------------------------------------
-- The short title: a rank by experience ("Initiate" at the start).
function Compose.Ranks(world)
  local class = world.class or ""
  return (W.RANKS_RACE[world.race or ""] or {})[class]
    or (W.RANKS_FACTION[world.faction or ""] or {})[class]
    or W.RANKS[class] or W.RANKS.default or {}
end

function Compose.Title()
  local world = ns.cache.world
  return Compose.Ranks(world)[band(world.level)]
end

-- The full title: alignment and standing, else what you are and where you're from.
function Compose.FullTitle()
  local c = ns.cache
  local rpgd, world = Compose.Persona(c), c.world
  local align = rpgd and ns.Sources.RPGD.AlignTitle(rpgd.align, world.faction)
  local standing
  local best = rpgd and rpgd.towns[1]
  if best then
    local tpl = W.FULLTITLE_TIER[ns.Sources.RPGD.Tier(best.value).name]
    standing = tpl and (tpl:gsub("{town}", best.name))
  end
  if align and standing then return align .. ", " .. standing end
  if standing then return standing end
  local noun = U.Cap(W.CLASS_NOUN[world.class or ""] or "wanderer")
  if align then return align .. " " .. noun end
  local top = world.factions and world.factions[1]
  if top and top.standing >= 7 then return "Friend of " .. W.FactionName(top.name) end
  local home = W.RACE_HOME[world.race or ""]
  return U.Cap(seasoned(world.level, "seasoned")) .. " " .. noun .. (home and (" of " .. home) or "")
end

-- Total RP 3's relationship status, from a partner in Social Diary (3 married, 2 taken).
function Compose.RelationshipStatus()
  local sd = ns.cache.sd
  return sd and sd.partner and sd.partner.status or nil
end

-- Open to walk-ups when the mood is open; closed when it isn't; otherwise no change.
local WALKUP_OPEN = { sociable = true, ease = true, merry = true, company = true, elated = true, festive = true,
  smitten = true, satisfied = true, homecoming = true, proud = true, flush = true, ["calm:charming"] = true, ["calm:kind"] = true,
  grateful = true, cheerful = true, smug = true, bored = true }
local WALKUP_CLOSED = { angry = true, downcast = true, sorrowful = true, wounded = true, tense = true, shaken = true,
  ailing = true, frustrated = true, drained = true, haunted = true, ["calm:reserved"] = true, ["calm:cruel"] = true,
  bitter = true, exhausted = true }
function Compose.Walkup(mood)
  if not mood then return nil end
  if WALKUP_OPEN[mood.key] then return 2 end
  if WALKUP_CLOSED[mood.key] then return 1 end
  -- No mood that says otherwise: open to walk-ups, so the field is never left unset.
  return 2
end

function Compose.OOCNote()
  return "Parts of this profile update themselves as I play (Auto TRP)."
end

function Compose.Residence()
  local rpgd = ns.cache.rpgd
  return (rpgd and rpgd.homeInn) or ns.cache.world.bind
end

function Compose.Birthplace()
  return W.RACE_HOME[ns.cache.world.race or ""]
end

-- What the character has earned a name for. Four kinds, highest first: a story finished in
-- RPG Dialogue, a quest chain finished (Chronicle), a dungeon or raid master brought down,
-- a bounty collected. Within a kind the greatest deed wins (the hardest master, the longest
-- chain), and between equals the first one earned: a name sticks. Each comes with the
-- History sentence that says where it came from.
-- An entry: { nick, motto, icon, deed, key, rank, tier, t }; key names the story or deed.

-- "Wanted: "Hogger"", "WANTED: Murkdeep!", "Wanted - Arnak Grimtotem" -> the target and
-- the name the nickname uses, or nil when the poster is after a crowd.
function Compose.BountyTarget(title)
  local target = type(title) == "string" and title:match("^[Ww][Aa][Nn][Tt][Ee][Dd]%s*[:%-!]%s*(.-)%s*$")
  if not target then return nil end
  target = target:gsub("[!%.]+$", ""):gsub("^[\"']+", ""):gsub("[\"']+$", "")
  if target == "" or target:find("^[Tt]he ") or not target:find("^%u") then return nil end
  local short = target:match("([%a'%-]+)$")
  if not short or #short < 3 or W.BOUNTY_NOT_A_NAME[short:lower()] then return nil end
  return target, short
end

local function better(a, b)
  if a.rank ~= b.rank then return a.rank > b.rank end
  if a.tier ~= b.tier then return a.tier > b.tier end
  if a.t ~= b.t then return a.t < b.t end
  return a.key < b.key
end

local earnedCache = {}
-- Every name earned, best first, one entry per nickname.
function Compose.EarnedAll()
  local c = ns.cache
  local rpgd, chron = c.rpgd, c.chronicle
  local class = c.world and c.world.class
  if earnedCache.rpgd == rpgd and earnedCache.chron == chron and earnedCache.deeds == c.deeds and earnedCache.class == class
    and earnedCache.list then
    return earnedCache.list
  end
  local all = {}
  local function offer(e) all[#all + 1] = e end
  for _, th in ipairs(rpgd and rpgd.threads or {}) do
    local e = th.state == "resolved" and W.EARNED_STORY[th.id]
    if e then
      offer({ rank = 4, tier = 0, t = th.t or 0, nick = e.nick, motto = e.motto, icon = e.icon, key = "thread:" .. th.id,
        deed = "Saw " .. lowerFirst(th.title) .. " through to the end" })
    end
  end
  local finished = Compose.Finished(c)
  for title, q in pairs(finished) do
    local e = W.EARNED_QUEST[title]
    if e and (not e.class or e.class == class) then
      offer({ rank = 3, tier = e.tier or 1, t = q.t or 0, nick = e.nick, motto = e.motto, icon = e.icon, deed = e.deed,
        key = "quest:" .. title })
    end
  end
  do
    local felled = {}
    for _, b in ipairs(Compose.Bosses(c)) do felled[b.name] = b end
    for i, e in ipairs(W.EARNED_BOSS) do
      local b = felled[e.name]
      if b then
        offer({ rank = 2, tier = i, t = b.first or b.t or 0, nick = e.nick, motto = e.motto, icon = e.icon, key = "boss:" .. e.name,
          deed = "Was there when " .. e.name .. " fell" .. (b.where and (" in " .. U.Mid(b.where)) or "") })
      end
    end
  end
  for title, q in pairs(finished) do
    local target, short = Compose.BountyTarget(title)
    if target then
      local e = W.EARNED_BOUNTY[short] or {}
      offer({ rank = 1, tier = 0, t = q.t or 0, nick = short .. "'s Bane", motto = e.motto, icon = W.EARNED_BOUNTY_ICON,
        key = "quest:" .. title, deed = "Collected the bounty on " .. target .. (q.zone and (" in " .. U.Mid(q.zone)) or "") })
    end
  end
  table.sort(all, better)
  local list, nicks = {}, {}
  for _, e in ipairs(all) do
    if not nicks[e.nick] then nicks[e.nick] = true; list[#list + 1] = e end
  end
  earnedCache.rpgd, earnedCache.chron, earnedCache.deeds, earnedCache.class, earnedCache.list = rpgd, chron, c.deeds, class, list
  return list
end

-- The name they go by: the one chosen with /atrp name, if it's still theirs, else the best.
function Compose.Earned()
  local all = Compose.EarnedAll()
  local chosen = ns.char and ns.char.chosenName
  if chosen then
    for _, e in ipairs(all) do if e.key == chosen then return e end end
  end
  return all[1]
end

-- The saying they took from what they went through, or nothing yet.
function Compose.Motto()
  local e = Compose.Earned()
  if e and e.motto then return e.motto end
  -- Nothing earned yet: what the class teaches, until something takes its place.
  local world = ns.cache.world
  local pool = {}
  for _, m in ipairs(W.CLASS_MOTTO[world.class or ""] or {}) do pool[#pool + 1] = m end
  for _, m in ipairs(W.RACE_MOTTO[world.race or ""] or {}) do pool[#pool + 1] = m end
  return #pool > 0 and U.Pick(pool, seed("motto")) or nil
end

-- What people call them, for something they saw through.
function Compose.Nickname()
  local e = Compose.Earned()
  if e then return e.nick end
  -- Nothing earned yet: where they're from ("of Elwynn"), until a deed gives a better one.
  return W.RACE_NICK[ns.cache.world.race or ""]
end

-- The profile icon: the earned nickname's, else the class crest.
function Compose.Icon()
  local e = Compose.Earned()
  return (e and e.icon) or W.CLASS_ICON[ns.cache.world.class or ""]
end

-- The History sentences for the deed behind the name: the deed and where the name came
-- from, the saying that came with it, and the other names that stuck (two at most).
-- skip(key) leaves out other names told elsewhere. Returns a list of sentences and the key
-- of the deed told.
function Compose.EarnedStory(name, skip)
  local e = Compose.Earned()
  if not e then return nil end
  local out = { say("earned", { deed = e.deed, name = name, nick = quote(e.nick) }, e.key) }
  if e.motto then out[#out + 1] = say("saying", { motto = quote(e.motto) }, e.key) end
  local others = {}
  for _, o in ipairs(Compose.EarnedAll()) do
    if o.key ~= e.key and #others < 2 and not (skip and skip(o.key)) then others[#others + 1] = quote(o.nick) end
  end
  if #others > 0 then out[#out + 1] = say("othernames", { list = U.Join(others) }, others[1]) end
  return out, e.key
end

-- Names earned since last time (called every tick). The first time, and when a source comes
-- back with several at once or with deeds a day old, they're taken in quietly: only a name
-- earned just now is news. Returns the new entries.
function Compose.NoticeNames()
  if not ns.char or not ns.cache or not ns.cache.read then return {} end
  if not ns.cache.rpgd and not ns.cache.chronicle and not ns.cache.deeds then return {} end
  local all = Compose.EarnedAll()
  local first = ns.char.names == nil
  ns.char.names = ns.char.names or {}
  local known, fresh = ns.char.names, {}
  for _, e in ipairs(all) do
    if not known[e.key] then fresh[#fresh + 1] = e end
  end
  local now = U.Now()
  local quiet = first or #fresh > 2
  local out = {}
  for _, e in ipairs(fresh) do
    local old = e.t > 0 and now - e.t > 86400
    if quiet or old then
      known[e.key] = e.t > 0 and e.t or 1
    else
      known[e.key] = now
      out[#out + 1] = e
    end
  end
  return out
end

-- The newest name, if it was earned in the last two days: { entry, t } or nil.
function Compose.NewName()
  local known = ns.char and ns.char.names
  if not known then return nil end
  local best, bt
  for _, e in ipairs(Compose.EarnedAll()) do
    local t = known[e.key]
    if t and within(t, 2 * 86400) and (not bt or t > bt) then best, bt = e, t end
  end
  return best, bt
end

---------------------------------------------------------------------------
-- Everything at once
---------------------------------------------------------------------------
-- fresh: the cache was just refreshed by the caller; don't read everything twice.
-- mood: already worked out by the caller. only: the fields wanted (the story fields are
-- skipped when none of them is).
local STORY = { "traits", "bearing", "history", "physical", "title", "fulltitle", "residence", "birthplace",
  "motto", "nickname", "icon", "relationship", "ooc", "glance_ambition" }
for _, st in ipairs(Compose.STATS) do STORY[#STORY + 1] = "stat_" .. st.key end
-- The five glances side by side: where two say the same thing, the one with other ways to
-- say it gives way. Lately and the mood's own title stand; Marks takes its next mark; the
-- mood's line takes another of the mood's lines.
function Compose.Glances(mood, withAmbition)
  local world = ns.cache.world
  local gl = { mood = Compose.MoodGlance(mood), lately = Compose.LatelyGlance(), company = Compose.CompanyGlance(),
    ambition = withAmbition and Compose.AmbitionGlance() or nil, marks = Compose.MarksGlance() }
  local function ideasOf(g) return g and Compose.Ideas((g.TI or "") .. " " .. (g.TX or ""), world) or {} end
  local held = ideasOf(gl.lately)
  for k in pairs(Compose.Ideas(gl.mood.TI, world)) do held[k] = true end
  if gl.marks and Compose.SharesIdea(gl.marks.TI .. " " .. gl.marks.TX, held, world) then
    gl.marks = Compose.MarksGlance(held) or gl.marks
  end
  local others = {}
  for _, k in ipairs({ "lately", "company", "ambition", "marks" }) do
    for idea in pairs(ideasOf(gl[k])) do others[idea] = true end
  end
  if gl.mood.TX and Compose.SharesIdea(gl.mood.TX, others, world) and ns.Mood.Tells then
    local list = ns.Mood.Tells(mood.key, world)
    local start = U.Hash(seed("tell:" .. tostring(mood.key))) % math.max(1, #list)
    for n = 0, #list - 1 do
      local t = list[(start + n) % #list + 1]
      if not Compose.SharesIdea(t, others, world) then gl.mood = { TI = gl.mood.TI, TX = U.Cap(t), IC = gl.mood.IC }; break end
    end
  end
  return gl
end

function Compose.Sheet(fresh, mood, only)
  if not fresh then Compose.Refresh() end
  mood = mood or ns.Mood.Current(ns.cache.world)
  local story = not only
  if only then for _, k in ipairs(STORY) do if only[k] then story = true end end end
  if not story then
    return {
      mood = mood, currently = Compose.Currently(mood), walkup = Compose.Walkup(mood),
      glances = Compose.Glances(mood, false),
    }
  end
  return {
    mood = mood,
    currently = Compose.Currently(mood),
    glances = Compose.Glances(mood, true),
    traits = Compose.Traits(),
    bearing = Compose.Bearing(),
    history = Compose.History(),
    physical = Compose.Physical(),
    title = Compose.Title(),
    fulltitle = Compose.FullTitle(),
    residence = Compose.Residence(),
    relationship = Compose.RelationshipStatus(),
    walkup = Compose.Walkup(mood),
    ooc = Compose.OOCNote(),
    birthplace = Compose.Birthplace(),
    motto = Compose.Motto(),
    nickname = Compose.Nickname(),
    icon = Compose.Icon(),
    stats = Compose.Stats(),
  }
end
