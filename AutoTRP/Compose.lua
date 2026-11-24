-- Turns everything the sources know into the words for each profile field.
-- Rule of thumb: say a little, say it in-world, and leave out what isn't known rather than
-- padding. The character's name is the subject of sentences; pronouns only ever appear as
-- {their}/{them} and come from Total RP 3's pronoun field (they/them otherwise).
local _, ns = ...

local U = ns.U
local W = ns.Words
local Compose = {}
ns.Compose = Compose

ns.cache = {}

function Compose.Refresh()
  local S = ns.Sources
  local c = ns.cache
  c.world = ns.World.Snapshot()
  c.rpgd = S.RPGD.Read()
  c.sd = S.SocialDiary.Read()
  c.chronicle = S.Chronicle.Read()
  return c
end

local function seed(key)
  return (ns.char and ns.char.seedName or "") .. ":" .. key
end

local function firstName()
  return (ns.TRP and ns.TRP.FirstName and ns.TRP.FirstName()) or U.Call(UnitName, "player") or "This one"
end

local function within(t, seconds)
  return type(t) == "number" and t > 0 and U.Now() - t <= seconds
end

---------------------------------------------------------------------------
-- Currently
---------------------------------------------------------------------------
function Compose.Currently(mood)
  local world = ns.cache.world
  local text = mood.adj
  if mood.also then text = text .. " and " .. mood.also end
  text = text .. ", " .. ns.World.Activity(world, seed("act:" .. (world.zone or "") .. (world.subzone or "")))
  local tod = ns.World.TimeOfDay(world)
  if tod then text = text .. " " .. tod end
  return text .. "."
end

---------------------------------------------------------------------------
-- At first glance
---------------------------------------------------------------------------
function Compose.MoodGlance(mood)
  return { TI = mood.title, TX = mood.tell, IC = mood.icon }
end

local THREAD_PHRASE = {
  stirring = { "Has been asking around about %s.", "Has caught wind of %s." },
  unfolding = { "Is caught up in %s.", "Can't leave %s alone." },
  resolved = { "Saw %s through to the end.", "Had a hand in settling %s." },
  soured = { "Watched %s go badly wrong.", "Was there when %s went sour." },
}

function Compose.LatelyGlance()
  local c = ns.cache
  local rpgd, chron = c.rpgd, c.chronicle
  local cands = {}
  local function add(t, prio, g) cands[#cands + 1] = { t = t or 0, prio = prio, g = g } end

  -- A recent death
  local death = rpgd and rpgd.deaths[#rpgd.deaths]
  local cdeath = chron and chron.deaths[1]
  if cdeath and (not death or cdeath.t > death.t) then death = cdeath end
  if death and within(death.t, 2 * 86400) then
    local tx = "Came back from the brink" .. (death.zone and (" in " .. death.zone) or "") .. " not long ago"
    if death.killer then tx = tx .. ", and doesn't talk about " .. death.killer end
    add(death.t, 3, { TI = "Fresh Scars", TX = tx .. ".", IC = "Spell_Holy_Resurrection" })
  end
  -- A great foe brought down
  local boss = chron and chron.bosses[1]
  if boss and within(boss.t, 2 * 86400) then
    add(boss.t, 2, { TI = "Fresh Victory", IC = "INV_Misc_Head_Dragon_01",
      TX = "Was there when " .. boss.name .. " fell" .. (boss.where and (" in " .. U.Mid(boss.where)) or "") .. "." })
  end
  -- A place cleared
  local cleared = rpgd and rpgd.cleared[1]
  if cleared and within(cleared.t, 3 * 86400) then
    add(cleared.t, 2, { TI = "Back From the Depths", IC = "INV_Misc_Key_14",
      TX = "Only lately came back up out of " .. U.Mid(cleared.name) .. ", and has stories to prove it." })
  end
  -- A story moving
  local thread = rpgd and rpgd.threads[1]
  if thread and within(thread.t, 3 * 86400) and THREAD_PHRASE[thread.state] then
    local title = thread.title:gsub("^%u", string.lower)
    add(thread.t, 1, { TI = thread.state == "resolved" and "Loose Ends Tied" or "Caught Up in Something",
      IC = "INV_Misc_Note_02", TX = U.Pick(THREAD_PHRASE[thread.state], seed(thread.id)):format(title) })
  end
  -- A new land
  local zone = rpgd and rpgd.zones[#rpgd.zones]
  if zone and within(zone.t, 86400) and #rpgd.zones > 2 then
    add(zone.t, 0, { TI = "New in Town", IC = "INV_Misc_Map_01",
      TX = "Only recently arrived in " .. zone.name .. ", and still finding the way around." })
  end

  table.sort(cands, function(a, b)
    -- A fresh death trumps everything for a day; otherwise newest first.
    if a.prio == 3 and within(a.t, 86400) then return true end
    if b.prio == 3 and within(b.t, 86400) then return false end
    if a.t ~= b.t then return a.t > b.t end
    return a.prio > b.prio
  end)
  if cands[1] then return cands[1].g end

  -- Nothing fresh: an ambition, if Chronicle has one.
  if chron and ns.db.chronicleGoals and chron.goals[1] then
    return { TI = "Ambition", IC = "INV_Misc_Book_11",
      TX = "Talks often of one thing above all: " .. U.Truncate(chron.goals[1].text, 120) .. "." }
  end
  return nil
end

function Compose.CompanyGlance()
  local c = ns.cache
  local world, sd, rpgd = c.world, c.sd, c.rpgd
  local n = U.Call(GetNumGroupMembers) or 0
  if world.grouped and n > 1 then
    return { TI = "In Company", IC = "Spell_Holy_PrayerOfSpirit",
      TX = "Travelling with " .. (n == 2 and "a companion" or ("a band of " .. U.Number(n))) .. ", and easier for it." }
  end
  if sd and ns.db.nameFriends and sd.friends[1] then
    local f = sd.friends[1]
    local tx
    if f.relationship then
      tx = "Often seen with " .. f.name .. ", " .. U.Pron("{their} ") .. f.relationship:lower() .. "."
    else
      local names = {}
      for i = 1, math.min(2, #sd.friends) do names[i] = sd.friends[i].name end
      tx = "Often seen in the company of " .. U.Join(names) .. "."
    end
    return { TI = "Keeps Company", IC = "Spell_Holy_PrayerOfSpirit", TX = tx }
  end
  local town = rpgd and rpgd.towns[1]
  local friend = rpgd and rpgd.friends[1]
  if town and town.value >= 10 then
    local tier = ns.Sources.RPGD.Tier(town.value)
    local tx = U.Cap(tier.phrase:gsub("{town}", town.name))
    if friend then tx = tx .. ", and on good terms with " .. friend.name end
    return { TI = "A Known Face", IC = "INV_Misc_Bag_11", TX = tx .. "." }
  end
  if friend then
    return { TI = "A Known Face", IC = "INV_Misc_Bag_11", TX = "On good terms with " .. friend.name .. "." }
  end
  return nil
end

---------------------------------------------------------------------------
-- Personality bars (TRP3 psycho traits; V2 runs 0..20, 20 = all the left word)
---------------------------------------------------------------------------
function Compose.Traits()
  local rpgd = ns.cache.rpgd
  if not rpgd then return nil end
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
  if #out == 0 then return nil end
  return out
end

---------------------------------------------------------------------------
-- About: Personality ("bearing")
---------------------------------------------------------------------------
local function seasoned(level, key)
  for _, band in ipairs(W.SEASONED) do
    if (level or 1) <= band.max then return U.Pick(band.words, seed(key)) end
  end
end

local function opinions(rpgd, max)
  local out = {}
  for _, o in ipairs(rpgd.opinions) do
    local phrase
    if o.topic == "peace" then
      phrase = W.PEACE[o.stance]
    else
      local verb = W.STANCES[o.stance]
      local topic = W.TOPICS[o.topic] or (ns.RPGDNames.towns[o.topic]) or U.Humanize(o.topic)
      if verb and topic then phrase = verb:gsub("{t}", topic) end
    end
    if phrase then out[#out + 1] = phrase end
    if #out >= max then break end
  end
  return out
end

function Compose.Bearing()
  local c = ns.cache
  local rpgd, world = c.rpgd, c.world
  if not rpgd then return nil end
  local name = firstName()
  local paras = {}

  local adjs = {}
  for _, t in ipairs(rpgd.dominant) do adjs[#adjs + 1] = W.TRAIT_ADJ[t] end
  local noun = W.CLASS_NOUN[world.class or ""] or "wanderer"
  local season = seasoned(world.level, "seasoned")
  local article = season:match("^[aeiou]") and "an " or "a "
  local first = name .. " is " .. (#adjs > 0 and (U.Join(adjs) .. ", ") or "") .. article .. season .. " " .. noun
  local leans = {}
  for _, b in ipairs(W.AXIS_BARS) do
    local v = rpgd.align[b.axis] or 0
    if math.abs(v) >= 25 then leans[#leans + 1] = { v = math.abs(v), text = W.AXIS_PROSE[b.axis][v > 0 and 1 or -1] } end
  end
  table.sort(leans, function(a, b) return a.v > b.v end)
  if leans[1] then
    first = first .. " who " .. leans[1].text
    if leans[2] then first = first .. " and " .. leans[2].text end
  end
  paras[#paras + 1] = U.Pron(first .. ".")

  local ops = opinions(rpgd, 3)
  if #ops > 0 then paras[#paras + 1] = U.Pron(U.Cap(name .. " " .. U.Join(ops) .. ".")) end

  if (rpgd.align.taint or 0) >= 30 then
    paras[#paras + 1] = U.Pron("There is something faintly wrong about " .. name .. ", a taint that priests and dogs both seem to notice.")
  end
  if (rpgd.insanity or 0) >= 40 then
    paras[#paras + 1] = U.Pron("Lately " .. name .. " talks to empty corners, and sometimes the corners seem to answer.")
  end
  return table.concat(paras, "\n\n")
end

---------------------------------------------------------------------------
-- About: History
---------------------------------------------------------------------------
local function rankWord(rank)
  if rank >= 225 then return "a master" elseif rank >= 150 then return "an expert" elseif rank >= 75 then return "a journeyman" end
  return "an apprentice"
end

function Compose.History()
  local c = ns.cache
  local rpgd, chron, sd, world = c.rpgd, c.chronicle, c.sd, c.world
  if not rpgd and not chron then return nil end
  local name = firstName()
  local paras = {}

  -- Where it began
  if rpgd and rpgd.origin and rpgd.origin.name then
    local p = rpgd.origin.name .. "."
    if rpgd.origin.blurb then p = p .. " In " .. U.Pron("{their}") .. " own words: \"" .. rpgd.origin.blurb .. "\"" end
    paras[#paras + 1] = p
  end

  -- The road
  local zones = rpgd and rpgd.zones or {}
  local zoneCount = math.max(#zones, chron and chron.zones or 0)
  if zoneCount >= 3 and zones[1] then
    local p = "Since setting out from " .. zones[1].name .. ", " .. name .. " has walked " .. U.Number(zoneCount) .. " lands"
    local last = zones[#zones]
    if last and last.name ~= zones[1].name then p = p .. ", most lately " .. last.name end
    paras[#paras + 1] = p .. "."
  end

  -- People and places
  if rpgd then
    local friends = {}
    for i = 1, math.min(2, #rpgd.friends) do friends[i] = rpgd.friends[i].name end
    local rival = rpgd.rivals[1] and rpgd.rivals[1].name
    if #friends > 0 then
      local p = name .. " counts " .. U.Join(friends) .. " among " .. U.Pron("{their}") .. " friends"
      if rival then p = p .. ", and has made no friend of " .. rival end
      paras[#paras + 1] = p .. "."
    elseif rival then
      paras[#paras + 1] = name .. " has made no friend of " .. rival .. "."
    end
    local good, bad = {}, nil
    for _, t in ipairs(rpgd.towns) do
      if t.value >= 10 and #good < 2 then good[#good + 1] = (ns.Sources.RPGD.Tier(t.value).phrase:gsub("{town}", t.name)) end
    end
    local worst = rpgd.towns[#rpgd.towns]
    if worst and worst.value <= -20 then bad = (ns.Sources.RPGD.Tier(worst.value).phrase:gsub("{town}", worst.name)) end
    if #good > 0 then
      paras[#paras + 1] = U.Cap(U.Join(good)) .. (bad and (", though " .. bad) or "") .. "."
    elseif bad then
      paras[#paras + 1] = U.Cap(bad) .. "."
    end
  end
  if sd and ns.db.nameFriends and #sd.friends > 0 then
    local f = sd.friends[1]
    if f.relationship then
      local p = "Rides with " .. f.name .. ", " .. U.Pron("{their}") .. " " .. f.relationship:lower()
      if sd.friends[2] then p = p .. ", and with " .. sd.friends[2].name end
      paras[#paras + 1] = p .. "."
    else
      local names = {}
      for i = 1, math.min(3, #sd.friends) do names[i] = sd.friends[i].name end
      paras[#paras + 1] = "Has fallen in with " .. U.Join(names) .. "."
    end
  end

  -- Deeds
  local deeds = {}
  if rpgd then
    for _, t in ipairs(rpgd.threads) do
      if t.state == "resolved" then deeds[#deeds + 1] = "saw " .. t.title:gsub("^%u", string.lower) .. " through to the end"
      elseif t.state == "soured" then deeds[#deeds + 1] = "watched " .. t.title:gsub("^%u", string.lower) .. " go sour" end
      if #deeds >= 2 then break end
    end
    local places = {}
    for i = 1, math.min(3, #rpgd.cleared) do places[i] = U.Mid(rpgd.cleared[i].name) end
    if #places > 0 then deeds[#deeds + 1] = "came back alive out of " .. U.Join(places) end
  end
  if chron then
    if #chron.bosses >= 3 then deeds[#deeds + 1] = "helped bring down " .. U.Number(#chron.bosses) .. " foes the bards would know by name"
    elseif chron.bosses[1] then deeds[#deeds + 1] = "was there when " .. chron.bosses[1].name .. " fell" end
    local prof = chron.professions[1]
    if prof and prof.rank >= 50 then deeds[#deeds + 1] = "works " .. prof.name:lower() .. " with the hands of " .. rankWord(prof.rank) end
  end
  if #deeds > 0 then paras[#paras + 1] = U.Pron(U.Cap(name .. " " .. U.Join(deeds) .. ".")) end

  -- Close calls
  local deathCount = math.max(rpgd and rpgd.deathCount or 0, chron and chron.deathCount or 0)
  if deathCount > 0 then
    local firstDeath = rpgd and rpgd.deaths[1] or (chron and chron.deaths[#chron.deaths])
    local p = U.Cap(name .. " has died " .. U.Times(deathCount) .. " and come back each time")
    if firstDeath and firstDeath.killer then
      p = p .. "; the first time to " .. firstDeath.killer .. (firstDeath.zone and (" in " .. firstDeath.zone) or "")
    end
    paras[#paras + 1] = p .. "."
  end

  -- A page from the diary
  if rpgd and ns.db.diaryExcerpt and rpgd.lastEntry and rpgd.lastEntry.text then
    paras[#paras + 1] = "From " .. U.Pron("{their}") .. " journal: \"" .. U.Truncate(rpgd.lastEntry.text, 280) .. "\""
  end

  if #paras == 0 then return nil end
  return table.concat(paras, "\n\n")
end

---------------------------------------------------------------------------
-- About: Physical (off by default)
---------------------------------------------------------------------------
function Compose.Physical(mood)
  local c = ns.cache
  local world = c.world
  local race = U.Call(UnitRace, "player") or "traveller"
  local noun = W.CLASS_NOUN[world.class or ""] or "wanderer"
  local level = world.level or 1
  local article = seasoned(level, "seasoned")
  local p = U.Cap(((article:match("^[aeiou]") and "an " or "a ") .. article .. " " .. race:lower() .. " " .. noun) .. ".")
  local deaths = math.max(c.rpgd and c.rpgd.deathCount or 0, c.chronicle and c.chronicle.deathCount or 0)
  if deaths >= 5 then p = p .. " Carries more scars than " .. U.Pron("{they've}") .. " years to explain." end
  if mood and mood.tell then p = p .. "\n\n" .. mood.tell end
  return p
end

---------------------------------------------------------------------------
-- Name fields
---------------------------------------------------------------------------
function Compose.Title()
  local rpgd = ns.cache.rpgd
  return rpgd and ns.Sources.RPGD.AlignTitle(rpgd.align, ns.cache.world.faction) or nil
end

function Compose.FullTitle()
  local rpgd = ns.cache.rpgd
  local best = rpgd and rpgd.towns[1]
  if not best then return nil end
  local tier = ns.Sources.RPGD.Tier(best.value)
  local tpl = W.FULLTITLE_TIER[tier.name]
  return tpl and (tpl:gsub("{town}", best.name)) or nil
end

function Compose.Residence()
  local rpgd = ns.cache.rpgd
  return (rpgd and rpgd.homeInn) or ns.cache.world.bind
end

function Compose.Birthplace()
  return W.RACE_HOME[ns.cache.world.race or ""]
end

function Compose.Motto()
  local rpgd = ns.cache.rpgd
  local key = rpgd and rpgd.dominant[1] or "default"
  return U.Pick(W.MOTTOS[key] or W.MOTTOS.default, seed("motto:" .. key))
end

-- An epithet, earned by doing something a lot. The most remarkable one wins.
function Compose.Nickname()
  local c = ns.cache
  local rpgd, chron = c.rpgd, c.chronicle
  local cands = {
    { "Delver of the Deep", math.max(rpgd and #rpgd.cleared or 0, chron and #chron.bosses / 2 or 0) / 5 },
    { "Grave-Cheater", math.max(rpgd and rpgd.deathCount or 0, chron and chron.deathCount or 0) / 25 },
    { "the Far-Walker", math.max(rpgd and #rpgd.zones or 0, chron and chron.zones or 0) / 20 },
    { "the Relentless", (rpgd and rpgd.kills or 0) / 2500 },
    { "Friend of Many Towns", (rpgd and rpgd.met or 0) / 60 },
    { "the Unquiet", (rpgd and rpgd.insanity or 0) / 50 },
  }
  table.sort(cands, function(a, b) return a[2] > b[2] end)
  if cands[1][2] >= 1 then return cands[1][1] end
  return nil
end

---------------------------------------------------------------------------
-- Everything at once
---------------------------------------------------------------------------
function Compose.Sheet()
  Compose.Refresh()
  local mood = ns.Mood.Current(ns.cache.world)
  return {
    mood = mood,
    currently = Compose.Currently(mood),
    glances = {
      mood = Compose.MoodGlance(mood),
      lately = Compose.LatelyGlance(),
      company = Compose.CompanyGlance(),
    },
    traits = Compose.Traits(),
    bearing = Compose.Bearing(),
    history = Compose.History(),
    physical = Compose.Physical(mood),
    title = Compose.Title(),
    fulltitle = Compose.FullTitle(),
    residence = Compose.Residence(),
    birthplace = Compose.Birthplace(),
    motto = Compose.Motto(),
    nickname = Compose.Nickname(),
  }
end
