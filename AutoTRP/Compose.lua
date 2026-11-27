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
    c.trade = S.Trade and S.Trade.Read() or nil
    c.work = S.Work and S.Work.Read() or nil
    c.bestiary = S.Bestiary and S.Bestiary.Read() or nil
    c.kin = S.Kin and S.Kin.Read() or nil
    c.road = S.Road and S.Road.Read() or nil
    c.calling = S.Calling and S.Calling.Read() or nil   -- the class's signature work (Sources/Calling.lua)
    c.delves = S.Delves and S.Delves.Read() or nil
    c.seasons = S.Seasons and S.Seasons.Read(c) or nil
    c.pack = S.Pack and S.Pack.Read() or nil
    c.style = S.Style and S.Style.Read() or nil
    c.renown = S.Renown and S.Renown.Read() or nil
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
  s = U.Cap(U.Pron(s))
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
    for x in (text or ""):lower():gmatch("%a+") do if #x >= 4 then w[x] = true end end
    return w
  end
  local function clash(a, b)
    local wa = words(a)
    for x in pairs(words(b)) do if wa[x] then return true end end
    return false
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
  local function build(withAlso, extras, withTod, withAside)
    local text = adj
    -- "Weary and uneasy", but "In no hurry, hale and hearty" rather than a run of ands.
    if withAlso and also then
      text = text .. ((text:find(" and ") or also:find(" and ")) and ", " or " and ") .. also
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
  return { TI = mood.title, TX = mood.tell, IC = mood.icon }
end


-- "The broken Span" reads "the broken Span" mid-sentence; "Westfall, left to fend for
-- itself" keeps its capital, because Westfall is a name.
local LOWER_OK = { The = true, A = true, An = true, Who = true, Something = true, Two = true, Bread = true, Behind = true }
local function lowerFirst(s)
  local w = s:match("^(%a+)")
  if w and LOWER_OK[w] then return (s:gsub("^%u", string.lower)) end
  return s
end

-- The shape of their time (Sources/Seasons.lua), in W.SEASONS' words: {name} and the vars
-- filled, pronoun tags left for U.Pron.
local function timeSay(key, vars, which)
  local list = W.SEASONS[key]
  if type(list) ~= "table" or #list == 0 then return nil end
  local line = U.Pick(list, seed("time:" .. key .. ":" .. tostring(which or "")))
  line = line:gsub("{(%a+)}", function(k) if vars and vars[k] ~= nil then return vars[k] end end)
  return U.Cap(line)
end
Compose.TimeSay = timeSay

local function timeOn() return not ns.db or ns.db.timeNotes ~= false end

-- For History: lines on the shape of their time. road: what they keep to (an anniversary,
-- the hours and days they keep, the longest stretch, a long absence once); now: how things
-- stand (a return, a festival kept, a run of days, the season or month just past). At most
-- two of each, the weightiest first.
function Compose.TimeLines(c)
  c = c or ns.cache
  local se = c and c.seasons
  local out = { road = {}, now = {} }
  if not se or not timeOn() then return out end
  local S = ns.Sources.Seasons
  local name = firstName()
  local now = U.Now()
  local function road(t) if t and #out.road < 2 then out.road[#out.road + 1] = t end end
  local function told(t) if t and #out.now < 2 then out.now[#out.now + 1] = t end end
  local a = se.anniv
  if a then
    local vars = { name = name, span = a.span, when = a.today and "today" or "this week", rank = a.rank }
    if a.kind == "setout" then road(timeSay("anniv", vars, a.id))
    elseif a.rank then road(timeSay("anniv_rank", vars, a.id)) end
  end
  if se.hours then road(timeSay(se.hours, {}, se.hours)) end
  if se.weekdays == "weekend" then road(timeSay("weekend", {}, "weekend"))
  elseif se.weekdays then road(timeSay("weekday", { day = se.weekdays }, se.weekdays)) end
  local back = se.back
  local fresh = back and now - back.t <= 7 * 86400
  if fresh then told(timeSay("back", { span = S.Span(back.n) }, back.t)) end
  -- A festival kept lately (where), else the season just past, else the festivals kept.
  local f = se.fests[1]
  if f and f.where and now - f.t <= 45 * 86400 then
    told(timeSay("fest", { fest = f.name, zone = U.Mid(f.where) }, f.key .. f.year))
  end
  local tone = se.tone
  if tone and tone.season then told(timeSay("season_" .. tone.tone, { season = tone.season }, tone.season))
  elseif tone and tone.month then told(timeSay("month_" .. tone.tone, { month = tone.month }, tone.month)) end
  if f and now - f.t > 45 * 86400 then
    if #se.festKinds >= 2 then
      local list = {}
      for i = 1, math.min(3, #se.festKinds) do list[i] = se.festKinds[i] end
      told(timeSay("fest_list", { list = U.Join(list) }, list[1]))
    elseif f.where then
      told(timeSay("fest", { fest = f.name, zone = U.Mid(f.where) }, f.key .. f.year))
    end
  end
  if (se.streak or 0) >= 7 then told(timeSay("streak", { n = U.Number(se.streak) }, se.streak)) end
  if se.faire and se.faire.n >= 2 then told(timeSay("faire", { times = U.Times(se.faire.n) }, se.faire.n)) end
  if se.longest and se.longest.n >= 5 * 3600 then road(timeSay("longest", { name = name, span = S.Hours(se.longest.n) }, se.longest.s)) end
  if se.gap and se.gap.n >= 30 * 86400 and not fresh then road(timeSay("gap", { span = S.Span(se.gap.n) }, se.gap.from)) end
  return out
end

-- For the Lately glance: an anniversary this week, a festival kept today, a return. Each
-- { t, prio, g } like Lately's own candidates.
function Compose.TimeLately(c)
  c = c or ns.cache
  local se = c and c.seasons
  local out = {}
  if not se or not timeOn() then return out end
  local S = ns.Sources.Seasons
  local name, now = firstName(), U.Now()
  local a = se.anniv
  if a and (a.kind == "setout" or a.rank) then
    local vars = { name = name, span = a.span, when = a.today and "today" or "this week", rank = a.rank }
    local tx = timeSay(a.kind == "setout" and "lately_anniv" or "lately_rank", vars, a.id)
    -- Older than anything just now: an anniversary is the week's news, not the hour's.
    out[#out + 1] = { t = math.min(a.target, now) - 6 * 3600, prio = 1,
      g = { TI = W.SEASONS.titles[a.spanId] or "An Anniversary", IC = "INV_Misc_PocketWatch_01", TX = U.Pron(tx) } }
  end
  local f = se.fests[1]
  if f and f.where and now - f.t <= 86400 then
    out[#out + 1] = { t = f.t, prio = 1, g = { TI = U.Cap(f.name), IC = "INV_Holiday_Christmas_Present_01",
      TX = U.Pron(timeSay("lately_fest", { fest = f.name, zone = U.Mid(f.where) }, f.key .. f.year)) } }
  end
  local fa = se.faire
  if fa and fa.zone and now - fa.t <= 86400 then
    out[#out + 1] = { t = fa.t, prio = 1, g = { TI = "The Darkmoon Faire", IC = "INV_Misc_Ticket_Tarot_Madness",
      TX = timeSay("lately_faire", { zone = U.Mid(fa.zone) }, fa.t) } }
  end
  local back = se.back
  if back and now - back.t <= 86400 then
    out[#out + 1] = { t = back.t, prio = 1, g = { TI = "Back on the Road", IC = "Ability_Mount_RidingHorse",
      TX = timeSay("lately_back", { span = S.Span(back.n) }, back.t) } }
  end
  return out
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
    local tx = "Was badly hurt" .. (death.killer and (" by " .. death.killer) or "") .. (death.zone and (" in " .. death.zone) or "")
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
    add(cleared.t, 2, { TI = "Back From the Depths", IC = "INV_Misc_Key_14",
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
      add(bl.t, 2, { TI = "Back From Battle", IC = "INV_BannerPVP_02",
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
  -- Trades in depth (Sources/Trade.lua): a recipe learned, a first or finest piece, work for others.
  if c.trade and ns.Sources.Trade then
    for _, e in ipairs(ns.Sources.Trade.Lately(c.trade, world)) do add(e.t, e.prio, e.g) end
  end
  -- Their people (Sources/Kin.lua): a homecoming, a place of their people, a gift that mattered.
  for _, k in ipairs(ns.Sources.Kin and ns.Sources.Kin.Lately(c) or {}) do add(k.t, k.prio, k.g) end
  -- What's in the bags: something new, something long kept let go (Keepsakes.lua).
  for _, k in ipairs(Compose.KeepsakeLately and Compose.KeepsakeLately() or {}) do add(k.t, k.prio, k.g) end

  -- The road: back in a land after a long while, moving on after a long stay.
  for _, r in ipairs(Compose.RoadLately and Compose.RoadLately() or {}) do add(r.t, r.prio, r.g) end
  -- A dungeon or raid run just over (Runs.lua).
  local run = ns.Runs and ns.Runs.Lately(c)
  if run then add(run.t, run.prio, run.g) end
  -- The shape of their time: an anniversary this week, a festival, a return (Seasons.lua).
  for _, cd in ipairs(Compose.TimeLately(c)) do add(cd.t, cd.prio, cd.g) end

  -- The calling: a beast tamed, a portal opened, a narrow escape (Sources/Calling.lua).
  for _, e in ipairs(ns.Sources.Calling and ns.Sources.Calling.Lately(c) or {}) do add(e.t, e.prio, e.g) end
  -- The kind of work they take on (Sources/Work.lua): an escort seen through or lost, a run of jobs.
  for _, cd in ipairs(ns.Sources.Work and ns.Sources.Work.Lately(c.work) or {}) do add(cd.t, cd.prio, cd.g) end

  -- The bestiary: a rare let be, a world boss seen, the greatest kill, a first, a leader met.
  for _, b in ipairs(Compose.BestiaryLately()) do add(b.t, b.prio, b.g) end

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
    -- The part they play in it: "the group's healer" (Sources/Style.lua).
    local role = ns.Sources.Style and ns.Sources.Style.PartyClause(c.style)
    if role then clause = clause and (clause .. ", " .. role) or role end
    if g.raid and n > 5 then
      local s1 = cw(g.lead and "host_lead" or "host", { n = U.Number(n) }, n)
      return { TI = g.lead and "Leading a Host" or "Part of a Host", IC = "INV_BannerPVP_02",
        TX = join(s1 .. (clause and (", " .. clause) or ""), groupTail(g)) }
    end
    local party = Compose.PartyWords(g) or (n == 2 and "a companion" or ("a band of " .. U.Number(n)))
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

-- Marks: the most striking thing about them right now (a wound, drink, a spell on them, a
-- shape), else the most striking thing they wear or carry, else their kit and bearing.
-- Compose.NowMarks and Compose.GearParts are below, with About: Physical.
function Compose.MarksGlance()
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
    if du and within(du.t, 600) then mark(4.6, "Fresh From a Duel", say("mark_duel", nil, du.t), "Ability_Warrior_Challange") end
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
    -- A trade's smell after a stretch at it, and the tools carried (Sources/Trade.lua).
    for _, m in ipairs(ns.Sources.Trade and ns.Sources.Trade.Marks(c.trade, life) or {}) do mark(m.prio, m.title, m.text, m.icon) end
  end
  for _, m in ipairs(ns.Sources.Kin and ns.Sources.Kin.Marks(c) or {}) do mark(m.prio, m.title, m.text, m.icon) end
  for _, m in ipairs(ns.Sources.Calling and ns.Sources.Calling.Marks(c) or {}) do mark(m.prio, m.title, m.text, m.icon) end
  -- Just out of a hard dungeon or raid run (Runs.lua).
  local rm = ns.Runs and ns.Runs.Mark(c)
  if rm then mark(rm.prio, rm.title, rm.text, rm.icon) end
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
  for _, k in ipairs(Compose.KeepsakeMarks and Compose.KeepsakeMarks() or {}) do mark(k.prio, k.title, k.text, k.icon) end
  table.sort(marks, function(a, b) if a.prio ~= b.prio then return a.prio > b.prio end return a.title < b.title end)
  if marks[1] then
    local m = marks[1]
    return { TI = m.title, TX = sentence(m.text), IC = m.icon }
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
Compose.Quote = quote
local function itemName(name, quality) return colour(name, ITEM_COLOUR[quality or 0]) end

-- Pronouns filled in, and every sentence starts with a capital.
local function prose(s)
  s = U.Cap(U.Pron(s))
  return (s:gsub("([%.!%?]\"? +)(%l)", function(gap, l) return gap .. l:upper() end))
end

-- A third-person verb as pronoun tags that agree with whoever {they} are: "holds" ->
-- "hold{s}" ("she holds", "they hold"), "is" -> "{are}", "carries" -> "carr{ies}". A past
-- tense needs nothing. Nil for a word this can't turn.
local PAST = { saw = true, stood = true, found = true, took = true, came = true, went = true, fought = true, won = true,
  lost = true, brought = true, made = true, rose = true, got = true, caught = true, left = true, held = true, kept = true,
  spent = true, sold = true, could = true, would = true }
local NOT_VERB = { this = true, its = true, thus = true, perhaps = true, always = true, towns = true, days = true,
  less = true, unless = true, us = true, yes = true, his = true, hers = true, theirs = true, as = true, was = true }
local function tagVerb(w)
  local l = w:lower()
  if l == "is" then return "{are}" elseif l == "isn't" then return "{are}n't" end
  if l == "has" then return "{have}" elseif l == "hasn't" then return "{have}n't" end
  if l == "does" then return "{does}" elseif l == "doesn't" then return "{does}n't" end
  if PAST[l] or l:find("%led$") then return l end
  if NOT_VERB[l] or not l:find("^%l+s$") or l:find("ss$") or l:find("us$") then return nil end
  if #l > 4 and l:find("ies$") then return l:sub(1, -4) .. "{ies}" end
  if l:find("[sxz]es$") or l:find("[cs]hes$") or l:find("oes$") then return l:sub(1, -3) .. "{es}" end
  return l:sub(1, -2) .. "{s}"
end
Compose.TagVerb = tagVerb

-- Verbs that can follow "and" in a sentence whose subject was left out ("Belongs to the
-- Silver Lanterns and holds the rank..."): once a pronoun goes in front, they agree too.
local COORD = { has = true, is = true, holds = true, keeps = true, wears = true, travels = true, answers = true,
  belongs = true, carries = true, counts = true, calls = true, knows = true, goes = true, means = true, seems = true,
  gets = true, walks = true, believes = true, thinks = true, hopes = true, aims = true, prefers = true, speaks = true,
  stands = true, moves = true, ["isn't"] = true, ["doesn't"] = true }

-- "Holds the rank of lamplighter", after another "Holds...", becomes "She holds the rank of
-- lamplighter" ("They hold..."): the subject back in, and the verbs agreeing with it.
local function withSubject(s, name)
  local w, rest = s:match("^(%a[%a']*)(.*)$")
  if not w then return nil end
  if name and w == name then
    local v, rest2 = rest:match("^ (%a[%a']*)(.*)$")
    if not v then return nil end
    w, rest = v, rest2
  end
  local t = tagVerb(w)
  if not t then return nil end
  rest = rest:gsub("( and )(%l[%a']*)", function(a, v) if COORD[v] then return a .. tagVerb(v) end end)
  return "{they} " .. t .. rest
end

-- A paragraph from sentences; empty ones are skipped. Two sentences in a row that open on
-- the same word read like a list, so the second gets its subject back ("Has risen to
-- Templar. He has done good work for Stormwind.").
local function paragraph(list)
  local out = {}
  local last
  local name = firstName()
  for _, s in ipairs(list) do
    if s and s ~= "" then
      local w = s:match("^(%a[%a']*)")
      if w and w == last then
        local fixed = withSubject(s, name)
        if fixed then s = fixed; w = "{they}" end
      end
      last = w
      out[#out + 1] = sentence(s)
    end
  end
  if #out == 0 then return nil end
  return prose(table.concat(out, " "))
end

-- How many sentences a list for paragraph() holds.
local function count(list)
  local n = 0
  for _, s in ipairs(list or {}) do if s and s ~= "" then n = n + 1 end end
  return n
end

-- Lists for paragraph(), each short one (a single sentence) folded into the one before
-- while the two together stay within `most` sentences: a one-line paragraph reads like an
-- afterthought. Returns the paragraphs written.
local function folded(lists, most)
  local out = {}
  for i = 1, table.maxn(lists) do
    local l = lists[i]
    if type(l) == "table" and count(l) > 0 then
      local prev = out[#out]
      local copy = {}
      for _, x in ipairs(l) do if x ~= "" then copy[#copy + 1] = x end end
      if prev and #copy == 1 and #prev + 1 <= most then prev[#prev + 1] = copy[1]
      else out[#out + 1] = copy end
    end
  end
  for i, l in ipairs(out) do out[i] = paragraph(l) end
  return out
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

-- How they fight (Sources/Style.lua): Personality's lines, strongest first.
function Compose.FightLines(k)
  local Style = ns.Sources.Style
  return Style and Style.TemperLines(ns.cache.style, k) or {}
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
  local world = c.world or {}
  local life = c.life or { fish = 0, fishZones = 0, madeByProf = {}, herbs = 0, ore = 0, duelsWon = 0, duelsLost = 0,
    battles = 0, inns = {}, falls = 0, closeCalls = 0 }
  local cands = {}
  local function add(score, key, list)
    local pool = list or W.LIFE.HABIT[key]
    if pool and #pool > 0 then cands[#cands + 1] = { score = score, key = key, text = U.Pick(pool, seed("habit:" .. key)) } end
  end
  -- The kind of work they take on (Sources/Work.lua): couriers, bounty boards, coin over kit.
  for _, h in ipairs(ns.Sources.Work and ns.Sources.Work.Habits(c.work) or {}) do add(h.score, h.key, h.pool) end
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
  -- How they practise their calling (Sources/Calling.lua).
  for _, h in ipairs(ns.Sources.Calling and ns.Sources.Calling.Habits(c) or {}) do cands[#cands + 1] = h end
  for _, h in ipairs(Compose.KeepsakeHabits and Compose.KeepsakeHabits() or {}) do add(h.score, h.key, h.list) end
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

-- Their bond to their people, the gifts they use and the old enemies they cut down
-- (Sources/Kin.lua): at most two lines, only what the record backs.
function Compose.KinLines()
  local K = ns.Sources.Kin
  return K and K.Bearing(ns.cache, 2) or {}
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

  -- How they fight (Sources/Style.lua), its own short paragraph.
  local fighting = Compose.FightLines(2)

  -- Nothing to read a character from: only the habit the game itself records.
  if not rpgd then
    local after = { habit }
    for _, h in ipairs(Compose.Habits(2)) do after[#after + 1] = h end
    after[#after + 1] = ns.Sources.Trade and ns.Sources.Trade.Habit(c.trade) or nil
    for _, h in ipairs(Compose.BestiaryTraits(2)) do after[#after + 1] = h end
    for _, h in ipairs(Compose.KinLines()) do after[#after + 1] = h end
    after[#after + 1] = Compose.BooksLine()
    after[#after + 1] = Compose.WeekTone()
    return pages(folded({ temperLines(), fighting, after }, 6))
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
  if #ops > 0 then
    -- After a paragraph that opened on the name, the views open on the pronoun, the verbs
    -- agreeing with it ("He keeps faith in the Light", "They keep faith...").
    if #first > 0 then
      for i, o in ipairs(ops) do
        local w, rest = o:match("^(%S+)(.*)$")
        local t = w and tagVerb(w)
        if t then ops[i] = t .. rest end
      end
      views[#views + 1] = "{they} " .. U.Join(ops)
    else
      views[#views + 1] = name .. " " .. U.Join(ops)
    end
  end
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
  more[#more + 1] = ns.Sources.Trade and ns.Sources.Trade.Habit(c.trade) or nil
  for _, h in ipairs(Compose.BestiaryTraits(2)) do more[#more + 1] = h end
  for _, h in ipairs(Compose.KinLines()) do more[#more + 1] = h end
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

  -- Beliefs and the rest of the inner life share a paragraph while it stays short, then how
  -- they fight; a lone line joins the one before. The stories close it, on their own.
  local lists = { first, views, fighting, more }
  if count(views) + count(more) <= 5 then
    for _, m in ipairs(more) do views[#views + 1] = m end
    lists[4] = nil
  end
  local paras = folded(lists, 5)
  paras[#paras + 1] = stories
  return pages(paras)
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
  -- "Has a rogue's first lessons ahead. Is nearly at level forty-six." reads as a list: the
  -- last two share a sentence when both leave the subject out.
  local a, b = lines[2], lines[3]
  local function bare(l) local w = l and l:match("^(%u[%a']*) ") return w and tagVerb(w) end
  if bare(a) and bare(b) then
    lines[2] = a:gsub("%.$", "") .. ", and " .. b:gsub("^%u", string.lower)
    lines[3] = nil
  end
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

-- A run of things done, joined; once one of them has its own "and" ("got caught up in A and
-- B"), the last is set off with a comma so the run doesn't read as one long list.
local function joinRun(list)
  local n = #list
  if n < 2 then return U.Join(list) end
  for _, x in ipairs(list) do
    if x:find(" and ", 1, true) then return table.concat(list, ", ", 1, n - 1) .. ", and " .. list[n] end
  end
  return U.Join(list)
end

---------------------------------------------------------------------------
-- The road, land by land (Sources/Road.lua): History's road paragraph, two Lately items
-- and the "Longest stay" statistic. Wording in W.ROAD and W.SAY.lately_back/_moved.
---------------------------------------------------------------------------
local function roadFill(line, vars)
  return (line:gsub("{([%a']+)}", function(k) if vars[k] ~= nil then return vars[k] end end))
end
local ROAD_COMMON = { from = true, level = true, there = true, with = true, that = true, into = true, down = true,
  them = true, they = true, their = true, where = true }
-- The words a line brings of its own (not its tags), to keep from saying "most" thrice.
local function ownWords(line)
  local out = {}
  for w in line:gsub("{[%a']+}", ""):lower():gmatch("%a+") do if #w >= 4 and not ROAD_COMMON[w] then out[#out + 1] = w end end
  return out
end
local function saysAny(text, words)
  local low = " " .. text:lower():gsub("[^%a]+", " ") .. " "
  for _, w in ipairs(words) do if low:find(" " .. w .. " ", 1, true) then return true end end
  return false
end
-- One of a list, seeded per land, that repeats none of the words already said (else the
-- seeded one).
local function fresh(list, which, said)
  if type(list) ~= "table" or #list == 0 then return list end
  local start = U.Hash(seed("road:" .. which)) % #list
  for k = 0, #list - 1 do
    local l = list[(start + k) % #list + 1]
    if not saysAny(said or "", ownWords(l)) then return l end
  end
  return list[start + 1]
end
local function bucket(list, v, which, said)
  for _, b in ipairs(list) do
    if v < b.max then return type(b.words) == "table" and fresh(b.words, "b:" .. tostring(which), said) or b.words end
  end
end
-- How long a stay was: by the days it lasted when it ran over days, else by the hours.
function Compose.StayWords(e, said)
  if (e.wall or 0) >= 1.5 * 86400 and (e.secs or 0) >= 7200 then return bucket(W.ROAD.days, e.wall / 86400, e.name, said) end
  return bucket(W.ROAD.hours, (e.secs or 0) / 3600, e.name, said)
end
function Compose.AwayWords(seconds) return bucket(W.ROAD.away, (seconds or 0) / 86400) end
local function isCapital(name) return W.CAPITAL_ZONES and W.CAPITAL_ZONES[name] or false end
local ROAD_THE = { Wetlands = true, Badlands = true }
local function roadPlace(n) return ROAD_THE[n] and ("the " .. n) or placeName(n) end
Compose.RoadPlace = roadPlace

-- One land's sentence: the stay, the level, the work, and what else happened there.
-- said: the paragraph so far, so the words don't repeat.
local function roadLine(e, family, used, name, withKind, said)
  local pool = W.ROAD[family]
  local start = U.Hash(seed("road:" .. family .. ":" .. e.name)) % #pool
  local line
  for k = 0, #pool - 1 do
    local l = pool[(start + k) % #pool + 1]
    if not used[l] and not saysAny(said, ownWords(l)) then line = l; break end
  end
  if not line then
    for k = 0, #pool - 1 do
      local l = pool[(start + k) % #pool + 1]
      if not used[l] then line = l; break end
    end
  end
  line = line or pool[start + 1]
  used[line] = true
  local ctx = said .. " " .. line
  local function pick(key)
    local l = fresh(W.ROAD[key], key .. ":" .. e.name, ctx)
    ctx = ctx .. " " .. l
    return l
  end
  local stay = Compose.StayWords(e, ctx)
  ctx = ctx .. " " .. stay
  local clauses = {}
  if not isCapital(e.name) then
    local span = e.upLo and e.upHi and (e.upHi - e.upLo + 1) or 0
    if (e.ups or 0) >= 2 and e.ups >= span * 0.6 then
      clauses[#clauses + 1] = roadFill(pick("climb"), { a = U.Number(e.upLo - 1), b = U.Number(e.upHi) })
    elseif e.lvlIn then
      clauses[#clauses + 1] = roadFill(pick("level"), { a = U.Number(e.lvlIn) })
    end
  end
  local work
  if e.story and e.story.n >= 2 then
    local story = e.story.title
    for _, z in ipairs({ e.name, U.Mid(e.name) }) do
      local cut = " in " .. z
      if story:sub(-#cut) == cut then story = story:sub(1, -#cut - 1) end
    end
    work = roadFill(pick("story"), { story = story })
  elseif (e.quests or 0) >= 3 then
    work = roadFill(pick("jobs"), { n = U.Number(e.quests) })
  elseif e.town and not e.town:find(e.name, 1, true) then
    work = roadFill(pick("town"), { town = U.Mid(e.town) })
  elseif e.inn then
    work = roadFill(pick("inn"), { inn = placeName(e.inn) })
  end
  if work then clauses[#clauses + 1] = work end
  local zone = roadPlace(e.name)
  local kind = W.ZONE_KIND and W.ZONE_KIND[e.name]
  local kinded = false
  if withKind and kind and #clauses <= 1 and (line:find("{zone}{rest}", 1, true) or line:find("{zone}:", 1, true)) then
    zone = zone .. ", " .. U.Pick(kind, seed("road:kind:" .. e.name))
    kinded = true
  end
  local text = roadFill(line, { zone = zone, stay = stay, rest = table.concat(clauses) })
  -- What else happened there: a death or two outranks the dungeon next door.
  local tail
  local after
  if (e.deaths or 0) >= 1 then
    tail = roadFill(pick("deaths"), { name = name, times = U.Times(e.deaths) })
    if e.dungeons[1] then
      after = roadFill(pick(e.bosses[1] and "boss" or "dungeon"), { dungeon = U.Mid(e.dungeons[1].name), boss = e.bosses[1] and e.bosses[#e.bosses].name })
    end
  elseif e.bosses[1] and e.dungeons[1] then
    tail = roadFill(pick("boss"), { dungeon = U.Mid(e.dungeons[1].name), boss = e.bosses[#e.bosses].name })
  elseif e.dungeons[1] then
    tail = roadFill(pick("dungeon"), { dungeon = U.Mid(e.dungeons[1].name) })
  elseif (e.close or 0) >= 2 then
    tail = roadFill(pick("close"), { name = name, times = U.Times(e.close) })
  end
  if tail then text = text .. "; " .. tail end
  if after then text = text .. ". " .. U.Cap(after) end
  return text, kinded
end

-- The road told: the three or four lands that mattered most, in the order reached, then the
-- one left quickly, the one they keep coming back to, and where they've been lately. Nil
-- until two lands have real time on them. Every fact is from the record.
function Compose.RoadStory(name)
  local road = ns.cache.road
  if not road then return nil end
  name = name or firstName()
  local now = U.Now()
  local cands = {}
  for _, e in ipairs(road.zones) do
    if e.secs >= 1800 and not isCapital(e.name) then
      e.score = e.secs / 3600 + (e.quests or 0) * 0.4 + (e.deaths or 0) + #e.dungeons * 1.5 + #e.bosses + (e.ups or 0)
      cands[#cands + 1] = e
    end
  end
  if #cands < 2 then return nil end
  table.sort(cands, function(a, b) if a.score ~= b.score then return a.score > b.score end return a.name < b.name end)
  local picked = {}
  for k = 1, math.min(4, #cands) do picked[k] = cands[k] end
  table.sort(picked, function(a, b) if a.first ~= b.first then return a.first < b.first end return a.name < b.name end)
  local longest = picked[1]
  for _, e in ipairs(picked) do if e.secs > longest.secs then longest = e end end
  local told, used, list, kinds = {}, {}, {}, 0
  for k, e in ipairs(picked) do
    local family = k == 1 and "first" or (e == longest and "longest" or "next")
    local text, kinded = roadLine(e, family, used, name, kinds < 2 and k % 2 == 1, table.concat(list, " "))
    if kinded then kinds = kinds + 1 end
    list[#list + 1] = text
    told[e.name] = true
  end
  -- Then at most three more (two after four lands): where they've been lately counts most,
  -- the land left at once least; told in the order quick, returning, lately.
  local extra = {}
  local function more(key, vars, which, order)
    extra[#extra + 1] = { key = key, vars = vars, which = which, order = order }
  end
  -- The land left almost at once.
  local quick
  for _, e in ipairs(road.zones) do
    if e.visits == 1 and not e.before and not e.here and e.secs > 0 and e.secs < 1800 and (e.quests or 0) == 0
      and now - e.last > 86400 and not isCapital(e.name) and not told[e.name] and (not quick or e.last > quick.last) then
      quick = e
    end
  end
  if quick then more("quick", { zone = roadPlace(quick.name) }, quick.name, 1) end
  -- Back where they were a long while ago, else where they've been this past week; and the
  -- land they keep coming back to.
  local lately, back = road.lately, road.back
  local latelyName
  if back and back.zone == road.cur and now - back.t <= 7 * 86400 then
    more("lately_back", { zone = roadPlace(back.zone), away = Compose.AwayWords(back.away) }, back.zone, 3)
    latelyName = back.zone
  elseif lately and lately.recent >= 3600 then
    local sub = ""
    if lately.sub and (lately.subN or 0) >= 3 and not ns.World.IsInn(lately.sub) then sub = ", around " .. U.Mid(lately.sub) end
    more("lately", { zone = roadPlace(lately.name), sub = sub }, lately.name, 3)
    latelyName = lately.name
  end
  local mv = road.mostVisited
  if mv and mv.visits >= 4 and mv.name ~= latelyName then
    more("returns", { zone = roadPlace(mv.name), n = U.Times(mv.visits - 1) }, mv.name, 2)
  end
  local room = #picked >= 4 and 2 or 3
  while #extra > room do
    local lo = 1
    for k, x in ipairs(extra) do if x.order < extra[lo].order then lo = k end end
    table.remove(extra, lo)
  end
  table.sort(extra, function(a, b) return a.order < b.order end)
  for _, x in ipairs(extra) do
    list[#list + 1] = roadFill(fresh(W.ROAD[x.key], x.key .. ":" .. x.which, table.concat(list, " ")), x.vars)
  end
  return paragraph(list)
end

-- Lately: back in a land after a long while, or moving on after a long stay.
function Compose.RoadLately()
  local road = ns.cache.road
  local out = {}
  if not road or not road.cur then return out end
  local b = road.back
  if b and b.zone == road.cur and within(b.t, 2 * 86400) then
    out[#out + 1] = { t = b.t, prio = 1, g = { TI = "Back Again", IC = "INV_Misc_Map_01",
      TX = U.Pron(say("lately_back", { zone = roadPlace(b.zone), away = Compose.AwayWords(b.away) }, b.t)) } }
  end
  local l = road.left
  local here = road.byName[road.cur]
  if l and l.zone ~= road.cur and within(l.t, 86400) and here and here.visits == 1 and not here.before
    and ((l.stay or 0) >= 2 * 86400 or (l.secs or 0) >= 3 * 3600) then
    local from = road.byName[l.zone]
    out[#out + 1] = { t = l.t, prio = 0, g = { TI = "Moving On", IC = "Ability_Hunter_Pathfinding",
      TX = U.Pron(say("lately_moved", { zone = roadPlace(road.cur), from = roadPlace(l.zone),
        stay = Compose.StayWords({ name = l.zone, wall = from and from.wall or l.stay, secs = from and from.secs or l.secs }) }, l.t)) } }
  end
  return out
end

-- "Westfall, 14 hours over 3 visits"
function Compose.LongestStay()
  local lg = ns.cache.road and ns.cache.road.longest
  if not lg then return nil end
  local h = math.floor(lg.secs / 3600)
  local m = math.max(1, math.floor(lg.secs / 60))
  local span = lg.secs < 3600 and (m .. " " .. U.Plural(m, "minute")) or (h .. " " .. U.Plural(h, "hour"))
  return lg.name .. ", " .. span .. (lg.visits > 1 and (" over " .. lg.visits .. " visits") or "")
end

-- Reputation as people would see it (Sources/Renown.lua). Rumours: "What's said of them",
-- at most k lines of hearsay (3 by default), each built from one stored record.
function Compose.Rumours(k)
  local R = ns.Sources.Renown
  local out = {}
  for i, r in ipairs(R and R.Rumours(ns.cache, k) or {}) do out[i] = r.text end
  return out
end
-- Standing changes for History's news: { t, text, key }.
function Compose.StandingNews()
  local R = ns.Sources.Renown
  return R and R.News(ns.cache, RECENT) or {}
end

-- History, in five paragraphs. The first and the last two hold what lasts: where they
-- came from and the road, the people, how things stand. The second is the news (the last
-- three weeks, newest first, and what has changed). The third is the longer record: the
-- deed behind their name, then everything older, told briefly.
---------------------------------------------------------------------------
-- The bestiary (Sources/Bestiary.lua): what they've fought and seen, for History's older
-- record, Personality, the Lately glance and the statistics. Only what the counts back.
---------------------------------------------------------------------------
local function kindWord(kind, key)
  local pool = W.BESTIARY.TYPE[kind or ""]
  return pool and U.Pick(pool, seed("bst:" .. key .. ":" .. kind)) or (kind and kind:lower()) or "creatures"
end
local function familyWord(family, key)
  local pool = W.BESTIARY.FAMILY[family or ""]
  return pool and U.Pick(pool, seed("bstf:" .. key .. ":" .. family)) or Compose.Plural(family:lower())
end
-- A creature by name, as prose says it: a rare, a world boss or a notable one by its own
-- name, anything else with an article ("an elite Mosshide Mistweaver").
local function proper(class, name)
  return class == "rare" or class == "rareelite" or class == "worldboss" or (W.BESTIARY.NOTABLE[name] and true) or false
end
local function creature(name, class)
  if proper(class, name) then return name end
  return article(((class == "elite") and "elite " or "") .. name)
end
-- How far above them it stood when they brought it down.
local function gapWords(g)
  local diff = tonumber(g.diff) or 0
  if diff >= 10 then return ", far beyond {them} at the time" end
  if g.level and g.mine and g.mine >= 5 and g.level >= 2 * g.mine then return ", twice {their} level at the time" end
  if diff >= 5 then return ", well above {them} at the time" end
  if diff >= 2 then return ", a good deal stronger than {them} at the time" end
  return ""
end

-- The kinds fought (non-critters with prose words), most killed first.
local function foughtKinds(be)
  local list = {}
  for _, t in ipairs(be.types) do
    if t.kills > 0 and t.type ~= "Critter" and W.BESTIARY.TYPE[t.type] then list[#list + 1] = t end
  end
  return list
end

-- The kind that has had them lately, when it isn't the one they've always fought.
local function latelyKind(kinds)
  local top = kinds[1]
  local best
  for k = 2, #kinds do
    local t = kinds[k]
    if t.recent >= 10 and t.recent * 2 >= t.kills and t.recentZone and (not top or t.recent > (top.recent or 0))
      and (not best or t.recent > best.recent) then best = t end
  end
  return best
end

-- "Has fought mostly beasts, wolves above all, and humanoids so far, and the undead in
-- Duskwood since. The greatest thing they've brought down is Mor'Ladim, a rare elite undead
-- creature, well above them at the time." At most three sentences.
function Compose.FoughtLines(c)
  c = c or ns.cache
  local be = c.bestiary
  local B = W.BESTIARY
  local out = {}
  if not be or (be.kills or 0) < 10 then return out end
  local kinds = foughtKinds(be)
  local top = kinds[1]
  local byName = c.deeds and c.deeds.killsByName or {}
  local lately = latelyKind(kinds)
  if top and top.kills >= 5 then
    local second = kinds[2] ~= lately and kinds[2] or kinds[3]
    if second and (second.kills < 5 or second.kills * 4 < top.kills) then second = nil end
    local list = kindWord(top.type, "lead")
    for _, f in ipairs(be.families) do
      if f.type == top.type then
        if B.FAMILY[f.family] and f.kills >= 5 and f.kills * 10 >= top.kills * 3 then
          list = list .. ", " .. say("bst_family", { family = familyWord(f.family, "lead") }, f.family)
          if second then list = list .. "," end
        end
        break
      end
    end
    if second then list = list .. " and " .. kindWord(second.type, "second") end
    local line = say("bst_lead", { list = list }, top.type)
    if lately then
      line = line .. (second and "; " or ", and ") .. say("bst_lately", { kind = kindWord(lately.type, "lately"), zone = U.Mid(lately.recentZone) }, lately.type)
    end
    out[#out + 1] = line
  end
  local g = be.greatest
  if g and g.name and ((tonumber(g.w) or 0) >= 5 or B.CLASS[g.class or ""]) then
    local how = ""
    if proper(g.class, g.name) and B.CLASS[g.class or ""] and g.class ~= "worldboss" then
      how = ", " .. article(B.CLASS[g.class] .. " " .. (B.ONE[g.type or ""] or "creature"))
    end
    how = how .. gapWords(g)
    local times = math.max(tonumber(byName[g.name]) or 0, tonumber(g.kills) or 1)
    if times >= 2 then how = how .. say("bst_again", { times = U.Times(times) }, g.name) end
    out[#out + 1] = say("bst_greatest", { who = creature(g.name, g.class), how = how }, g.name)
  end
  -- The first of a kind worth telling (only when the record goes back to the start).
  if be.fromStart and #out < 3 then
    for _, kind in ipairs({ "Dragonkin", "Demon", "Giant", "Undead", "Elemental" }) do
      local t
      for _, ty in ipairs(be.types) do if ty.type == kind then t = ty end end
      if t and t ~= top and t ~= lately and t.firstName and t.firstZone and not (g and g.name == t.firstName) then
        local s = be.seenBy[t.firstName]
        out[#out + 1] = say("bst_first", { one = B.ONE[kind], who = creature(t.firstName, s and s.class), zone = U.Mid(t.firstZone) }, kind)
        break
      end
    end
  end
  -- Named creatures brought down, leaders met, world bosses seen.
  local named, leaders = {}, {}
  for _, m in ipairs(be.notable) do
    if m.kind == "foe" and (tonumber(byName[m.name]) or 0) > 0 and not (g and g.name == m.name) and #named < 2 then named[#named + 1] = m.name
    elseif m.kind == "leader" and #leaders < 3 then leaders[#leaders + 1] = m.name end
  end
  if #named > 0 and #out < 3 then out[#out + 1] = say("bst_named", { list = U.Join(named) }, named[1]) end
  local bosses = {}
  for _, w in ipairs(be.worldBosses) do if #bosses < 2 then bosses[#bosses + 1] = w.name end end
  if #leaders > 0 and #out < 4 then out[#out + 1] = say("bst_leaders", { list = U.Join(leaders) }, leaders[1]) end
  if #bosses > 0 and #out < 4 then out[#out + 1] = say("bst_worldboss", { list = U.Join(bosses) }, bosses[1]) end
  return out
end

-- Personality lines the bestiary backs, strongest first: at most `k`.
function Compose.BestiaryTraits(k)
  local be = ns.cache.bestiary
  local B = W.BESTIARY
  if not be then return {} end
  local cands = {}
  local function add(score, key, pool, vars)
    if type(pool) == "table" and #pool > 0 then
      local line = U.Pick(pool, seed("bsttrait:" .. key))
      line = line:gsub("{(%a+)}", function(v) if vars and vars[v] then return vars[v] end end)
      cands[#cands + 1] = { score = score, key = key, text = line }
    end
  end
  local kinds = foughtKinds(be)
  local total = 0
  for _, t in ipairs(kinds) do total = total + t.kills end
  local top = kinds[1]
  if top then
    local common = top.type == "Beast" or top.type == "Humanoid"
    local need, share = common and 300 or 150, common and 0.6 or 0.4
    if top.kills >= need and top.kills >= total * share then add(2.4, "foe:" .. top.type, B.FOE[top.type]) end
  end
  -- A kind that has killed them again and again.
  local worst
  for _, t in ipairs(be.types) do if B.WARY[t.type] and (t.deaths or 0) >= 3 and (not worst or t.deaths > worst.deaths) then worst = t end end
  if worst and worst.deaths * 2 >= (be.deaths or 0) then
    add(2.6, "wary:" .. worst.type, B.WARY[worst.type], { times = U.Times(worst.deaths) })
  end
  local left, hunted = 0, 0
  for _, s in ipairs(be.seen) do
    if s.class == "rare" or s.class == "rareelite" then
      if s.killed > 0 then hunted = hunted + 1 elseif not s.fought then left = left + 1 end
    end
  end
  if hunted >= 5 and hunted >= left then add(1.6, "hunts", W.SAY.bst_hunts)
  elseif left >= 4 then add(1.5, "left", W.SAY.bst_left) end
  if (be.strongKills or 0) >= 25 then add(1.4, "bigger", W.SAY.bst_bigger) end
  table.sort(cands, function(a, b) if a.score ~= b.score then return a.score > b.score end return a.key < b.key end)
  local out = {}
  for i = 1, math.min(k or 2, #cands) do out[i] = cands[i].text end
  return out
end

-- The Lately glance's candidates from the bestiary: { t, prio, g }.
function Compose.BestiaryLately()
  local be = ns.cache.bestiary
  local B = W.BESTIARY
  local out = {}
  if not be then return out end
  local now = U.Now()
  local function add(t, prio, ti, ic, key, vars)
    out[#out + 1] = { t = t, prio = prio, g = { TI = ti, IC = ic, TX = say(key, vars, t) } }
  end
  -- A rare seen, a little while ago, and never fought.
  for _, s in ipairs(be.seen) do
    if (s.class == "rare" or s.class == "rareelite") and not s.fought and within(s.last, 7200) and now - s.last >= 120 and s.zone then
      local what = s.family and s.family:lower() or B.ONE[s.type or ""] or "creature"
      add(s.last, 1, "Left Be", "Ability_Hunter_BeastCall", "lately_rare_left", { what = what, zone = U.Mid(s.zone) })
      break
    end
  end
  local wb = be.worldBosses[#be.worldBosses]
  if wb and within(wb.t, 7200) and wb.zone then
    add(wb.t, 2, "A Sight to See", "INV_Misc_Head_Dragon_01", "lately_worldboss", { who = wb.name, zone = U.Mid(wb.zone) })
  end
  local g = be.greatest
  if g and g.zone and within(g.t, 86400) and ((tonumber(g.w) or 0) >= 5 or B.CLASS[g.class or ""]) then
    add(g.t, 2, "Greatest Kill", "INV_Misc_Bone_HumanSkull_01", "lately_greatest", { who = creature(g.name, g.class), zone = U.Mid(g.zone) })
  end
  local ft = be.freshType
  if be.fromStart and ft and B.FIRST_TOLD[ft.type] and ft.zone and within(ft.t, 86400) then
    local s = be.seenBy[ft.name]
    add(ft.t, 1, "A First", "Ability_DualWield", "lately_first",
      { one = B.ONE[ft.type], aone = article(B.ONE[ft.type]), who = creature(ft.name, s and s.class), zone = U.Mid(ft.zone) })
  end
  local ds = be.dragonSeen
  if be.fromStart and ds and ds.zone and within(ds.t, 86400) and not (wb and wb.name == ds.name) then
    add(ds.t, 1, "A Dragon", "INV_Misc_Head_Dragon_Black", "lately_dragon", { zone = U.Mid(ds.zone) })
  end
  for _, m in ipairs(be.notable) do
    if m.kind == "leader" and m.zone and within(m.t, 86400) then
      add(m.t, 1, "Met in Person", "INV_Misc_Book_11", "lately_leader", { who = m.name, zone = U.Mid(m.zone) })
    end
  end
  return out
end

-- The statistic: "Mor'Ladim, rare elite, level 35 (slain at 31)".
function Compose.GreatestStat(g)
  if not g or not g.name then return nil end
  local parts = { g.name }
  local class = W.BESTIARY.CLASS[g.class or ""]
  if class then parts[#parts + 1] = class end
  if g.level and g.mine then parts[#parts + 1] = "level " .. g.level .. " (slain at " .. g.mine .. ")"
  elseif g.mine then parts[#parts + 1] = "far above (slain at level " .. g.mine .. ")" end
  return table.concat(parts, ", ")
end

function Compose.History()
  local c = ns.cache
  local rpgd, chron, sd, world = Compose.Persona(c), c.chronicle, c.sd, c.world
  local name = firstName()
  local now = U.Now()
  local race = W.RACE_NOUN[world.race or ""]
  local noun = W.CLASS_NOUN[world.class or ""]
  local what = race and noun and (article(race) .. " " .. noun) or nil
  local function recent(t) return type(t) == "number" and t > 0 and now - t <= RECENT end
  local changes = Compose.NoticeChanges(world)

  -- 1. Where it began, and the road since
  local roots = {}
  local saidPlace = {}   -- places the roots have named, to say "there" after
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
      if home then saidPlace[home] = true end
    end
  end
  -- The trainer it began with (Auto TRP saw it), or the one gone back to.
  local start = rpgd and rpgd.start
  if start and start.trainer and start.zone and not (rpgd.origin and rpgd.origin.name) then
    local place = placeName(start.zone)
    local line = say(start.first and "trainer_first" or "trainer_usual", { who = start.trainer, place = place }, start.trainer)
    -- "...who started out in Elwynn Forest. Had his first lessons from Priestess Josetta there."
    if saidPlace[place] then line = line:gsub(" in " .. (place:gsub("%p", "%%%0")) .. "$", " there") end
    saidPlace[place] = true
    roots[#roots + 1] = line
  end
  local zones = (rpgd and #rpgd.zones > 0 and rpgd.zones) or (c.deeds and c.deeds.zones) or {}
  local zoneCount = math.max(#zones, chron and chron.zones or 0)
  if zoneCount >= 3 and zones[1] then
    local since = math.min(zones[1].t or math.huge, chron and chron.created or math.huge)
    local weeks = since < math.huge and math.floor((now - since) / 604800) or 0
    local span = weeks >= 9 and (U.Number(math.floor(weeks / 4.3)) .. " months")
      or weeks >= 2 and (U.Number(weeks) .. " weeks") or nil
    local dungeons = math.max(chron and chron.dungeons or 0, c.deeds and c.deeds.dungeons or 0)
    local from = placeName(zones[1].name)
    roots[#roots + 1] = (span and ("Over the last " .. span .. ", ") or "")
      .. "{their} road has led " .. (saidPlace[from] and "" or ("from " .. from .. " ")) .. "through " .. U.Number(zoneCount) .. " lands"
      .. (dungeons >= 2 and (" and down into " .. U.Number(dungeons) .. " dungeons") or "")
  elseif (world.level or 1) < 10 then
    roots[#roots + 1] = say("setout", { name = name })
  end
  if rpgd and rpgd.homeInn and not (rpgd.homePrev and rpgd.homePrev ~= rpgd.homeInn and recent(rpgd.homeSince)) then
    roots[#roots + 1] = say("home", { inn = placeName(rpgd.homeInn) }, rpgd.homeInn)
  end
  -- Little recorded yet: say what can be seen of them now (rank, where they are, how
  -- seasoned they look) so History is never just one line.
  local roadStory = Compose.RoadStory(name)
  if #roots < 3 then
    local title = Compose.Title()
    -- Not when the news below tells of rising to it.
    local lastRise = ns.char and ns.char.milestones and ns.char.milestones[#ns.char.milestones]
    local risen = lastRise and recent(lastRise.t)
    if title and (world.level or 1) >= 10 and not risen then roots[#roots + 1] = say("rankso", { rank = title }) end
    if world.zone and not roadStory then roots[#roots + 1] = say("keepsto", { zone = placeName(world.zone) }, world.zone) end
  end
  -- The shape of their time: an anniversary this week, the hours and days they keep.
  local time = Compose.TimeLines(c)
  for _, l in ipairs(time.road) do roots[#roots + 1] = l end
  -- 1b. The road, land by land (Sources/Road.lua), once there's enough of it: told after
  -- the roots (see the end).

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
  -- Dungeon and raid runs as stories (Runs.lua): what the story tells isn't news twice.
  local tales, taleTold = nil, { bosses = {}, items = {} }
  if ns.Runs then
    local t, told = ns.Runs.Tales(c, name)
    tales, taleTold = t, told or taleTold
  end
  local bosses = Compose.Bosses(c)
  local nb = 0
  for _, b in ipairs(bosses) do
    if nb < 2 and recent(b.t) and earnedKey ~= "boss:" .. b.name and not taleTold.bosses[b.name] then
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
  -- Standing lost or worked hard for (Sources/Renown.lua).
  -- A step down in standing is real news; a slow drift or steady work, less so.
  for _, e in ipairs(Compose.StandingNews()) do event(e.t, e.rank or 5, e.text, e.key) end
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
  if f and not taleTold.items[f.item] then event(f.t, 7, "came by " .. itemName(f.item, f.quality) .. (f.zone and (" in " .. U.Mid(f.zone)) or ""), "find") end
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
  if c.trade and ns.Sources.Trade then
    for _, e in ipairs(ns.Sources.Trade.Events(c.trade, recent, itemName)) do event(e.t, e.rank, e.text, e.key) end
  end
  -- Their people (Sources/Kin.lua): a homecoming, a place of their people, a gift that mattered.
  for _, e in ipairs(ns.Sources.Kin and ns.Sources.Kin.Events(c) or {}) do event(e.t, e.rank, e.text, e.key) end
  -- The calling's news: a beast tamed, a portal opened, the fallen raised (Sources/Calling.lua).
  for _, e in ipairs(ns.Sources.Calling and ns.Sources.Calling.Events(c, recent) or {}) do event(e.t, e.rank, e.text, e.key) end

  -- The kind of work they take on (Sources/Work.lua): an escort seen through or lost.
  for _, e in ipairs(ns.Sources.Work and ns.Sources.Work.News(c.work, recent) or {}) do event(e.t, e.rank, e.text, e.key) end

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
    lately[#lately + 1] = say("when_" .. order[i], nil, g[1].key) .. ", " .. subject .. " " .. joinRun(preds)
    if #more > 0 then lately[#lately + 1] = "{they} also " .. joinRun(more) end
    subject = "{they}"
  end

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
  for _, s in ipairs(ns.Sources.Calling and ns.Sources.Calling.Older(c, toldRecent) or {}) do older[#older + 1] = s end
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
  -- Their people (Sources/Kin.lua): homecomings, places of their people, old enemies.
  for _, s in ipairs(ns.Sources.Kin and ns.Sources.Kin.Older(c, toldRecent) or {}) do older[#older + 1] = s end
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
    -- Not when what they hold now is most of it: how well off they are is told at the end.
    local holding = type(world.money) == "number" and world.money / 10000 or 0
    if most >= 100 and holding < most * 0.8 then older[#older + 1] = "had as much as " .. U.Number(most) .. " gold to {their} name at once" end
    local paid = math.floor((life.money.quests or 0) / 10000)
    if paid >= 50 then older[#older + 1] = "been paid " .. U.Number(paid) .. " gold for {their} jobs" end
    local mend = math.floor((life.money.repairs or 0) / 10000)
    if mend >= 20 then older[#older + 1] = "spent " .. U.Number(mend) .. " gold having {their} gear mended" end
    if (life.money.auctions or 0) >= 5 then older[#older + 1] = "sold " .. U.Roughly(life.money.auctions) .. " things at auction" end
  end
  -- How they fight: the role they take, the spells they cut off, what they fight most.
  if ns.Sources.Style then
    for _, s in ipairs(ns.Sources.Style.HistoryClauses(c.style, world.level)) do older[#older + 1] = s end
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
    local lead = say("alongtheway", nil, older[1])
    -- Three at most to a sentence; the rest start another.
    local a, b = {}, {}
    for k, s in ipairs(older) do if k <= 3 then a[#a + 1] = s elseif k <= 6 then b[#b + 1] = s end end
    record[#record + 1] = lead .. " {they've} " .. joinRun(a)
    if #b > 0 then record[#record + 1] = "{they've} also " .. joinRun(b) end
  end
  -- What most of the work has been, and the escorts (Sources/Work.lua).
  for _, s in ipairs(ns.Sources.Work and ns.Sources.Work.Record(c.work, toldRecent) or {}) do record[#record + 1] = s end
  -- What they've fought (Sources/Bestiary.lua): the kinds, the greatest, the notable.
  for _, s in ipairs(Compose.FoughtLines(c)) do record[#record + 1] = s end
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
  -- The trades in depth: what they know, their finest work, a specialisation, work for others.
  if c.trade and ns.Sources.Trade then
    for _, line in ipairs(ns.Sources.Trade.Passage(c.trade, itemName, toldRecent)) do record[#record + 1] = line end
  end
  local oldFinds = {}
  for k = #finds, 1, -1 do
    local fd = finds[k]
    if #oldFinds < 2 and not (k == #finds and toldRecent.find) and not taleTold.items[fd.item] then
      oldFinds[#oldFinds + 1] = itemName(fd.item, fd.quality) .. (fd.zone and (" from " .. U.Mid(fd.zone)) or "")
    end
  end
  if #oldFinds > 0 then record[#record + 1] = say("finds", { list = U.Join(oldFinds) }, finds[1].item) end
  record[#record + 1] = Compose.KeepsakeHistory and Compose.KeepsakeHistory(itemName) or nil   -- Keepsakes.lua

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
  -- The one they don't get on with, beside the ones they do.
  if rpgd and rpgd.rivals[1] then
    people[#people + 1] = say("rival", { who = rpgd.rivals[1].name }, rpgd.rivals[1].name)
  end
  -- The one they work for most (Sources/Work.lua), unless already named among their friends.
  do
    local named = {}
    for _, f in ipairs(friends) do named[f] = true end
    people[#people + 1] = ns.Sources.Work and ns.Sources.Work.GiverLine(c.work, named) or nil
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
  local standing = {}
  if rpgd then
    local good, bad = {}, nil
    for _, t in ipairs(rpgd.towns) do
      if t.value >= 10 and #good < 2 then good[#good + 1] = (ns.Sources.RPGD.Tier(t.value).phrase:gsub("{town}", t.name)) end
    end
    local worst = rpgd.towns[#rpgd.towns]
    if worst and worst.value <= -20 then bad = (ns.Sources.RPGD.Tier(worst.value).phrase:gsub("{town}", worst.name)) end
    if #good > 0 then
      standing[#standing + 1] = U.Cap(U.Join(good)) .. (bad and (", but " .. bad) or "")
    elseif bad then
      standing[#standing + 1] = U.Cap(bad)
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
  local serve = #served > 0 and ("Has done good work for " .. U.Join(served)) or nil
  -- The factions served go with a short line about the towns ("Is liked in Goldshire, and
  -- has done good work for Stormwind"), else with the guild, else on their own.
  local town = standing[1]
  if town and serve and not town:find(" and ", 1, true) and not town:find(", but ", 1, true) then
    standing[1], serve = town .. ", and " .. serve:gsub("^%u", string.lower), nil
  end
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
    -- The factions served join a short guild line; after "...and holds the rank of X
    -- there" they start a sentence of their own.
    if line and serve and not line:find(" and ", 1, true) then
      line, serve = line .. ", and " .. serve:gsub("^%u", string.lower), nil
    end
    standing[#standing + 1] = line
  end
  standing[#standing + 1] = serve
  if world.pvpRank then
    standing[#standing + 1] = "Holds the rank of " .. world.pvpRank .. " in the " .. (world.faction or "faction") .. "'s army"
  end
  -- What's said of them: hearsay, each line from a stored record (Sources/Renown.lua).
  for _, r in ipairs(Compose.Rumours()) do people[#people + 1] = r end
  if sd and #sd.foes > 0 then
    people[#people + 1] = say("foes", { what = #sd.foes == 1 and "an enemy" or (U.Number(#sd.foes) .. " enemies") }, #sd.foes)
  end

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
  for _, l in ipairs(time.now) do nowLines[#nowLines + 1] = l end
  if #bits >= 2 then nowLines[#nowLines + 1] = "Felt " .. U.Join(bits) end
  local wb = Compose.WealthBand(world)
  if wb and not toldRecent.wealth then nowLines[#nowLines + 1] = wb.flair end
  if rpgd and ns.db.diaryExcerpt and rpgd.lastEntry and rpgd.lastEntry.text then
    nowLines[#nowLines + 1] = say("diary", { q = quote(U.Truncate(rpgd.lastEntry.text, 280)) }, rpgd.lastEntry.text)
  elseif ns.Journal then
    nowLines[#nowLines + 1] = ns.Journal.LatestLine(quote)   -- Auto TRP's own journal (Journal.lua)
  end

  -- One life, in order: where it began, and the road land by land; the longer record; the
  -- news, and the runs told as stories; the people, and where they stand; how things are
  -- now, and what drives them. A lone line joins the paragraph before it; the people and
  -- their standing share one while it stays short.
  if count(people) + count(standing) <= 5 then
    for _, l in ipairs(standing) do people[#people + 1] = l end
    standing = {}
  end
  local paras = {}
  local function put(list) for _, l in ipairs(list) do paras[#paras + 1] = l end end
  if roadStory then
    put(folded({ roots }, 6)); paras[#paras + 1] = roadStory; put(folded({ record }, 6))
  else
    put(folded({ roots, record }, 6))
  end
  put(folded({ lately }, 6))
  if tales then put(folded({ tales }, 6)) end
  put(folded({ people, standing }, 6))
  -- What drives them closes it, after how things stand, in one paragraph when that is short.
  local drives = Compose.Drives()
  local nowPara = paragraph(nowLines)
  if nowPara and drives and count(nowLines) <= 2 then
    paras[#paras + 1] = nowPara .. " " .. drives
  else
    paras[#paras + 1] = nowPara
    paras[#paras + 1] = drives
  end
  return pages(paras)
end

---------------------------------------------------------------------------
-- About: Physical, from the live game first (gear, auras, stats, health), with Chronicle's
-- snapshot only to fill a gap. Three paragraphs: the body, what they wear and carry, and
-- how they are right now. Nothing is named that the game doesn't show.
---------------------------------------------------------------------------
-- The longer words of a line, to keep two sentences side by side from saying the same thing
-- ("calm-faced and unhurried. Has the deep, settled calm of long devotion").
local function keyWords(text)
  local out = {}
  for w in (text or ""):lower():gmatch("%a+") do if #w >= 4 then out[w] = true end end
  return out
end

local function physique(c, beside)
  local stats = c.world.stats
  if type(stats) ~= "table" or next(stats) == nil then
    stats = (c.chronicle and c.chronicle.appearance and c.chronicle.appearance.stats) or {}
  end
  local best, bestV
  for name, v in pairs(stats) do
    if type(v) == "number" and W.PHYSIQUE[name] and (not bestV or v > bestV or (v == bestV and name < best)) then best, bestV = name, v end
  end
  if not best then return nil end
  local pool, near = W.PHYSIQUE[best], keyWords(beside)
  local fresh = {}
  for _, l in ipairs(pool) do
    local clash = false
    for w in pairs(keyWords(l)) do if near[w] or near[w:gsub("s$", "")] then clash = true end end
    if not clash then fresh[#fresh + 1] = l end
  end
  return U.Pron(U.Pick(#fresh > 0 and fresh or pool, seed("phys" .. best)))
end

-- Pronoun and verb tags are left for U.Pron; any other {tag} must be filled.
local PRON_TAGS = { they = true, them = true, their = true, themselves = true, ["they've"] = true, ["they're"] = true,
  ["they'd"] = true, s = true, es = true, ies = true, are = true, have = true, does = true }

-- One line of a list, picked per character and key, with only the lines whose tags are known.
local function fillPick(list, vars, key)
  local ok = {}
  for _, t in ipairs(type(list) == "table" and list or {}) do
    local whole = true
    for k in t:gmatch("{([%w']+)}") do
      if not PRON_TAGS[k] and (not vars or vars[k] == nil) then whole = false end
    end
    if whole then ok[#ok + 1] = t end
  end
  if #ok == 0 then return nil end
  local line = U.Pick(ok, seed("phys:" .. key))
  return (line:gsub("{([%w']+)}", function(k) if not PRON_TAGS[k] then return vars[k] end end))
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
        -- "It" only when the weapon was the last thing named, not a shield or a second blade.
        local alone = key == "twohand" or key == "staff" or key == "one"
        out.enchantIt = out.named[16] and alone and fillPick(E.it, nil, "enchit") or out.enchantWeapon
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
  local stances = W.PHYS_STANCE[world.class or ""]
  local stance = stances and fillPick(stances[stage(world.level)], nil, "stance")
  if not stance then
    local cl = U.BackedList(noGear(W.CLASS_LOOK[world.class or ""]), world)
    if #cl > 0 then stance = U.Pick(cl, seed("classlook")) end
  end
  local build = physique(c, stance)
  body[#body + 1] = article(seasoned(world.level, "seasoned")) .. " " .. noun .. (build and (", " .. build) or "")
  body[#body + 1] = stance
  body[#body + 1] = fillPick(W.RACE_BEARING[world.race or ""], nil, "bearing")
  local Kin = ns.Sources.Kin
  body[#body + 1] = Kin and Kin.Voice(c) or nil   -- the tongue they speak aloud, when it means something
  -- How they carry themselves in a fight (Sources/Style.lua).
  body[#body + 1] = ns.Sources.Style and ns.Sources.Style.Bearing(c.style) or nil

  -- What they wear and carry, by name, and what their class keeps in the bags
  local p = Compose.GearParts(world, itemName)
  local dress = {}
  local function add(line) if line then dress[#dress + 1] = line end end
  -- What they wear, then what they carry: two paragraphs when there is a lot of both.
  for _, k in ipairs({ "armour", "quality", "outfit", "layers", "set", "light", "fit" }) do add(p[k]) end
  local worn = #dress
  for _, k in ipairs({ "arms", "enchantIt", "ranged", "enchant", "jewel", "finest" }) do add(p[k]) end
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
    if k then table.insert(dress, 1, k); worn = worn + 1 end
  end

  -- How they are right now: up to four things, the most striking first
  local now = {}
  for _, m in ipairs(Compose.NowMarks(c)) do
    if #now < 4 then now[#now + 1] = m.text end
  end
  -- How being here sits with one of their people (home soil, an old enemy's land, a long road).
  local here = Kin and not world.combat and not world.dead and Kin.Here(c)
  if here and #now < 4 then now[#now + 1] = here end
  local lvl = world.level or 1
  if #now < 2 and lvl < 60 and not world.dead then
    if type(world.rested) == "number" and world.rested > 0 then now[#now + 1] = fillPick(W.PHYS_RESTED, nil, "rested")
    elseif world.rested == nil and world.restKnown and not world.resting and lvl >= 10 then now[#now + 1] = fillPick(W.PHYS_UNRESTED, nil, "unrested") end
  end
  if #now == 0 and not world.dead and (world.health or 1) >= 0.8 then now[1] = fillPick(W.PHYS_UNHURT, nil, "unhurt") end

  local carried = {}
  if #dress > 6 and worn >= 2 and #dress - worn >= 2 then
    for i = worn + 1, #dress do carried[#carried + 1] = dress[i]; dress[i] = nil end
  end
  -- What they carry in the bags (Keepsakes.lua)
  local bags = Compose.Keepsakes and Compose.Keepsakes(itemName) or {}
  -- A lone line about their kit joins the paragraph before; how they are now stays apart.
  local paras = folded({ body, dress, carried, bags }, 6)
  paras[#paras + 1] = paragraph(now)
  return pages(paras)
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
  -- From Auto TRP's record of the road, land by land (Sources/Road.lua).
  { key = "longest", label = "Longest stay", icon = "Ability_Hunter_Pathfinding" },
  -- From Auto TRP's record of the work they take on (Sources/Work.lua).
  { key = "work", label = "Work by kind", icon = "INV_Misc_Note_01" },
  -- From Auto TRP's record of dungeon and raid runs (Sources/Delves.lua, Runs.lua).
  { key = "deepest", label = "Deepest run", icon = "INV_Misc_Key_13" },
  { key = "wipes", label = "Wipes", icon = "Spell_Shadow_DeathScream" },
  -- From Auto TRP's record of their time (Sources/Seasons.lua).
  { key = "since", label = "On the road since", icon = "INV_Misc_PocketWatch_02" },
  { key = "festivals", label = "Festivals kept", icon = "INV_Holiday_Christmas_Present_01" },
  -- How every faction sees them (Sources/Renown.lua): "Exalted with 1, Revered with 3".
  { key = "renown", label = "Standing", icon = "INV_Misc_Token_ArgentDawn" },
  { key = "letters", label = "Letters received", icon = "INV_Letter_15", retired = true },
  -- From Auto TRP's record of the trades in depth (Sources/Trade.lua).
  { key = "recipes", label = "Recipes known", icon = "INV_Scroll_03" },
  { key = "finest", label = "Finest work", icon = "INV_Misc_Gem_Pearl_04" },
  -- From the bestiary (Sources/Bestiary.lua).
  { key = "kinds", label = "Foes by kind", icon = "Ability_Hunter_BeastTaming" },
  { key = "greatest", label = "Greatest kill", icon = "INV_Misc_Bone_HumanSkull_01" },
  -- From Auto TRP's record of their people (Sources/Kin.lua).
  { key = "kinhome", label = "Time at home / abroad", icon = "INV_Misc_Rune_01" },
  { key = "racial", label = "Racial ability most used", icon = "Spell_Nature_Strength" },
  { key = "kinfoes", label = "Old enemies slain", icon = "INV_Sword_04" },
  -- From the bags (Sources/Pack.lua): the thing carried longest.
  { key = "keepsake", label = "Treasured keepsake", icon = "INV_Misc_Bag_11" },
}
-- The class's own work (Sources/Calling.lua): what a class has none of is left off.
for _, st in ipairs(ns.Sources.Calling and ns.Sources.Calling.STATS or {}) do Compose.STATS[#Compose.STATS + 1] = st end

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
    out.deaths = figure(deaths) .. (first and first.killer and (", the first to " .. first.killer) or "")
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
  out.work = ns.Sources.Work and ns.Sources.Work.Stat(c.work, figure) or nil
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
  out.renown = ns.Sources.Renown and ns.Sources.Renown.Stat(world, c.renown) or nil
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
  -- The trades in depth: recipes known, the finest thing made.
  if c.trade and ns.Sources.Trade then
    local tr = ns.Sources.Trade.Stats(c.trade)
    out.recipes, out.finest = tr.recipes, tr.finest
  end
  -- The road, land by land (Sources/Road.lua): the land they've spent longest in.
  out.longest = Compose.LongestStay()
  for k, v in pairs(ns.Sources.Calling and ns.Sources.Calling.Stats(c) or {}) do out[k] = v end
  -- Their time: the first day on record, and the festivals kept (Seasons.lua).
  local se = c.seasons
  if se and se.first then
    local S = ns.Sources.Seasons
    out.since = U.Cap(S.DateWords(se.first, true))
    local parts = {}
    if #se.fests > 0 then
      local list = {}
      for i = 1, math.min(3, #se.festKinds) do list[i] = se.festKinds[i] end
      parts[1] = figure(#se.fests) .. ": " .. U.Join(list) .. (#se.festKinds > 3 and " and more" or "")
    end
    if se.faire then parts[#parts + 1] = (#parts == 0 and "The" or "the") .. " Darkmoon Faire " .. U.Times(se.faire.n) end
    if #parts > 0 then out.festivals = table.concat(parts, "; ") end
  end
  -- The bestiary: the kinds fought most, and the greatest thing brought down.
  local be = c.bestiary
  if be then
    local kinds = {}
    for _, t in ipairs(be.types) do
      if t.kills > 0 and #kinds < 3 then kinds[#kinds + 1] = figure(t.kills) .. " " .. (W.BESTIARY.PLAIN[t.type] or t.type:lower()) end
    end
    if #kinds > 0 then out.kinds = table.concat(kinds, ", ") end
    out.greatest = Compose.GreatestStat(be.greatest)
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
  if ns.Runs then ns.Runs.Stats(c, out) end
  out.keepsake = Compose.KeepsakeStat and Compose.KeepsakeStat() or nil
  -- Nothing counted yet still says so, so no statistic is left blank.
  if not out.road and days == 0 then out.road = "Less than a day" end
  if not out.lands and world.zone then out.lands = "1" end
  for k, v in pairs(ns.Sources.Kin and ns.Sources.Kin.Stats(c) or {}) do out[k] = v end
  for _, k in ipairs({ "deaths", "lands", "road", "dungeons", "foes", "rares", "slain", "jobs", "crafts", "standing", "books", "names", "spell",
    "fish", "made", "gathered", "duels", "battles", "gold", "inns", "hit", "kinds", "greatest", "longest", "festivals", "renown", "keepsake", "deepest", "wipes",
    "kinhome", "racial", "kinfoes", "recipes", "finest" }) do
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
  -- No town to name: a faction they're Revered or Exalted with (Sources/Renown.lua).
  local friend = ns.Sources.Renown and ns.Sources.Renown.Title(world)
  if align then return friend and (align .. ", " .. friend) or (align .. " " .. noun) end
  if friend then return friend end
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
function Compose.Sheet(fresh, mood, only)
  if not fresh then Compose.Refresh() end
  mood = mood or ns.Mood.Current(ns.cache.world)
  local story = not only
  if only then for _, k in ipairs(STORY) do if only[k] then story = true end end end
  if not story then
    return {
      mood = mood, currently = Compose.Currently(mood), walkup = Compose.Walkup(mood),
      glances = { mood = Compose.MoodGlance(mood), lately = Compose.LatelyGlance(), company = Compose.CompanyGlance(),
        marks = Compose.MarksGlance() },
    }
  end
  return {
    mood = mood,
    currently = Compose.Currently(mood),
    glances = {
      mood = Compose.MoodGlance(mood),
      lately = Compose.LatelyGlance(),
      company = Compose.CompanyGlance(),
      ambition = Compose.AmbitionGlance(),
      marks = Compose.MarksGlance(),
    },
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
