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
    sourcesAt, c.read = now, true
  end
  c.t = now
  return c
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
  return math.max(c.rpgd and c.rpgd.deathCount or 0, c.chronicle and c.chronicle.deathCount or 0)
end

local function sentence(s)
  s = U.Pron(U.Cap(s))
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

-- Total RP 3 shows Currently in tooltips: keep it to a couple of lines. When it runs long,
-- the time of day goes first, then the form and pet, then the second mood.
Compose.CURRENTLY_MAX = 200

function Compose.Currently(mood)
  local world = ns.cache.world
  local s = seed("act:" .. (world.zone or "") .. (world.subzone or ""))
  local intent = Compose.Intent()
  local tod = ns.World.TimeOfDay(world, s)
  local function build(withAlso, terse, withTod)
    local text = mood.adj
    -- "Weary and uneasy", but "In no hurry, hale and hearty" rather than a run of ands.
    if withAlso and mood.also then
      text = text .. ((text:find(" and ") or mood.also:find(" and ")) and ", " or " and ") .. mood.also
    end
    text = text .. ", " .. ns.World.Activity(world, s, terse)
    if withTod and tod then text = text .. " " .. tod end
    text = text .. "."
    if intent then text = text .. " " .. sentence(intent) end
    return text
  end
  for _, v in ipairs({ { true, false, true }, { true, false, false }, { true, true, false }, { false, true, false } }) do
    local text = build(v[1], v[2], v[3])
    if #text <= Compose.CURRENTLY_MAX then return text end
  end
  return build(false, true, false)
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

function Compose.LatelyGlance()
  local c = ns.cache
  local rpgd, chron, world = c.rpgd, c.chronicle, c.world
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
  local where = world.zone and U.Mid(world.zone) or "these parts"
  return { TI = "Lately", IC = "INV_Misc_Map_01", TX = say("around", { where = where }, world.zone) }
end

function Compose.CompanyGlance()
  local c = ns.cache
  local world, sd, rpgd = c.world, c.sd, c.rpgd
  local n = world.groupSize or 0
  if world.grouped and world.raid and n > 5 then
    return { TI = "Part of a Host", IC = "INV_BannerPVP_02",
      TX = say("host", { n = U.Number(n) }, n) }
  end
  if world.grouped and n > 1 then
    local party = Compose.PartyWords()
    return { TI = "In Company", IC = "Spell_Holy_PrayerOfSpirit",
      TX = say("party", { party = party or (n == 2 and "a companion" or ("a band of " .. U.Number(n))) }, party) }
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
    local tx = U.Cap((ns.Sources.RPGD.Tier(town.value).phrase:gsub("{town}", town.name)))
    if friend then tx = tx .. ", and gets on well with " .. friend.name end
    return { TI = "Local Ties", IC = "INV_Misc_Bag_11", TX = tx .. "." }
  end
  if friend then
    return { TI = "Local Ties", IC = "INV_Misc_Bag_11", TX = "Gets on well with " .. friend.name .. "." }
  end
  if world.pet and (world.class == "HUNTER" or world.class == "WARLOCK") then
    local mood = world.petHappy and W.PET_HAPPY[world.petHappy]
    return { TI = "Travels Light", IC = "Ability_Hunter_BeastCall",
      TX = U.Pron(say("pet_only", { pet = world.pet .. (world.petKind and (" the " .. world.petKind:lower()) or ""),
        mood = mood and (", " .. mood) or "" }, world.pet)) }
  end
  local reserved = rpgd and ((rpgd.traits.reserved or 0) >= 3)
  return { TI = "Travels Alone", IC = "Spell_Shadow_Teleport",
    TX = U.Pron(say(reserved and "alone_reserved" or "alone", nil, world.zone)) }
end

-- "a priest, a mage and two warriors" from the party's classes.
function Compose.PartyWords()
  local count, order = {}, {}
  for i = 1, 4 do
    local unit = "party" .. i
    if U.Call(UnitExists, unit) then
      local class = select(2, U.Call(UnitClass, unit))
      if class and W.CLASS_PLURAL[class] then
        if not count[class] then order[#order + 1] = class end
        count[class] = (count[class] or 0) + 1
      end
    end
  end
  if #order == 0 then return nil end
  local parts = {}
  for _, class in ipairs(order) do
    local n, words = count[class], W.CLASS_PLURAL[class]
    parts[#parts + 1] = n == 1 and article(words[1]) or (U.Number(n) .. " " .. words[2])
  end
  return U.Join(parts)
end

function Compose.AmbitionGlance()
  local c = ns.cache
  local rpgd, chron, world = c.rpgd, c.chronicle, c.world
  if chron and ns.db.chronicleGoals and chron.goals[1] then
    -- The goal as the player wrote it: a full stop only where it has no ending of its own.
    local goal = U.Cap(U.Truncate(chron.goals[1].text, 120))
    if not goal:find("[%.!%?]\"?$") then goal = goal .. "." end
    return { TI = "Ambition", IC = "INV_Misc_Book_11", TX = goal }
  end
  for _, t in ipairs(rpgd and rpgd.threads or {}) do
    if t.state == "unfolding" or t.state == "stirring" then
      return { TI = "Unfinished Business", IC = "INV_Misc_Note_02",
        TX = say("unfinished", { t = lowerFirst(t.title) }, t.id) }
    end
  end
  -- A job in the log that would earn them a name.
  local reach = Compose.InReach()[1]
  if reach then
    return { TI = "Unfinished Business", IC = "INV_Misc_Note_02",
      TX = U.Pron(say("inreach", { q = "\"" .. reach.quest .. "\"" }, reach.quest)) }
  end
  -- Nothing they've set out to do: the next rank on their road, which the game will give them.
  local level = world.level or 1
  local ranks = Compose.Ranks(world)
  local now, nextRank = ranks[band(level)], ranks[band(level) + 1]
  if nextRank and nextRank ~= now then
    return { TI = "Ambition", IC = "INV_Misc_Book_11", TX = U.Pron(say("nextrank", { rank = nextRank }, nextRank)) }
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

function Compose.MarksGlance()
  local c = ns.cache
  local world, rpgd = c.world, c.rpgd
  local marks = {}
  local function mark(prio, title, text, icon) marks[#marks + 1] = { prio = prio, TI = title, TX = U.Cap(U.Pron(text)), IC = icon } end
  if world.health and world.health < 0.5 and not world.combat and not world.dead then
    mark(9, "Bloodied", "Freshly wounded, and moving carefully.", "Ability_Rogue_FeignDeath")
  end
  if rpgd and (rpgd.drunk or 0) > 0 and U.Now() - (rpgd.drunkAt or 0) < 1800 then
    mark(8, "Smells of Ale", "Unsteady on {their} feet, and smelling of drink.", "INV_Drink_05")
  end
  if rpgd and (rpgd.insanity or 0) >= 30 then
    mark(7, "Haunted Eyes", "{their} eyes never settle on anything for long.", "Spell_Shadow_Possession")
  end
  if rpgd and (rpgd.align.taint or 0) >= 30 then
    mark(6, "Something Wrong", "Something about {them} is off, in a way that's hard to name.", "Spell_Shadow_ShadowWordPain")
  end
  local g = world.gear or {}
  local wear = Compose.Wear(world)
  if wear and wear.band.glance then mark(5, wear.band.glance, U.Cap(wear.text) .. ".", "INV_Hammer_20") end
  local finest = g.finest or (c.chronicle and c.chronicle.appearance and c.chronicle.appearance.finest)
  if finest and finest.name and finest.quality >= 4 then
    mark(4, "Remarkable Gear", say("remarkable", { item = finest.name }, finest.name), "INV_Misc_Gem_Pearl_04")
  end
  table.sort(marks, function(a, b) return a.prio > b.prio end)
  if marks[1] then
    local m = marks[1]
    return { TI = m.TI, TX = m.TX, IC = m.IC }
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
local function paragraph(list)
  local out = {}
  for _, s in ipairs(list) do if s and s ~= "" then out[#out + 1] = sentence(s) end end
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

function Compose.Bearing()
  local c = ns.cache
  local rpgd, world = c.rpgd, c.world
  local name = firstName()
  local habit = Compose.FavouriteSpell()

  -- Without RPG Dialogue there are no choices to read a character from: only the habit the
  -- game itself records.
  if not rpgd then return habit and paragraph({ habit }) or nil end

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
  if #rpgd.books >= 1 then
    local titles = {}
    for i = 1, math.min(2, #rpgd.books) do titles[i] = quote(rpgd.books[i].title) end
    local extra = #rpgd.books - #titles
    more[#more + 1] = "Has read " .. U.Join(titles)
      .. (extra > 0 and (", and " .. U.Number(extra) .. " " .. U.Plural(extra, "other book") .. " besides") or "")
  end
  if habit then more[#more + 1] = habit end
  local hooks = Compose.Hooks()
  local stories = #hooks > 0 and paragraph({ say("stories", { list = U.Join(hooks) }) }) or nil

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
  local rpgd, chron, world = c.rpgd, c.chronicle, c.world
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

---------------------------------------------------------------------------
-- About: History. Five movements: where they came from, the road so far and what it has
-- made of them, the people, the work and the deeds, and how things stand now.
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

-- The annals: the character's moments, kept as they happen so History builds up rather
-- than being rewritten. Taken from the records (ranks, names earned, standing, first times
-- inside a dungeon or raid, a craft's new rank, the first battleground won), each
-- once, and kept even after the record it came from has forgotten it.
Compose.KEEP_ANNALS = 60
local MONTHS = { "January", "February", "March", "April", "May", "June", "July", "August", "September",
  "October", "November", "December" }

function Compose.Annals()
  if not ns.char then return {} end
  local a = type(ns.char.annals) == "table" and ns.char.annals or {}
  ns.char.annals = a
  local have = {}
  for _, e in ipairs(a) do have[e.k] = true end
  local function add(e)
    if have[e.k] or not e.t or e.t <= 1 then return end
    have[e.k] = true; a[#a + 1] = e
  end
  for _, m in ipairs(ns.char.milestones or {}) do
    if tonumber(m.level) then add({ k = "rank:" .. m.level, t = m.t, kind = "rank", level = tonumber(m.level), rank = m.rank, zone = m.zone }) end
  end
  for _, e in ipairs(Compose.EarnedAll()) do
    add({ k = "name:" .. e.key, t = e.t, kind = "name", deed = e.deed, nick = e.nick })
  end
  for _, h in ipairs(ns.char.honours or {}) do
    add({ k = "honour:" .. tostring(h.faction) .. ":" .. tostring(h.standing), t = h.t, kind = "honour",
      faction = h.faction, standing = h.standing })
  end
  for name, v in pairs(ns.char.instances or {}) do
    add({ k = "inside:" .. name, t = v.t, kind = "inside", name = name, raid = v.kind == "raid" })
  end
  for key, v in pairs(ns.char.crafts or {}) do
    add({ k = "craft:" .. key, t = v.t, kind = "craft", skill = v.skill, rank = v.rank })
  end
  local fw = ns.char.battles and ns.char.battles.firstWin
  if fw then add({ k = "battle:first", t = fw.t, kind = "battle", zone = fw.zone }) end
  table.sort(a, function(x, y) if x.t ~= y.t then return x.t < y.t end return x.k < y.k end)
  while #a > Compose.KEEP_ANNALS do table.remove(a, 1) end
  return a
end

-- "In September, Aldric was made Footman in Westfall and was there when Edwin VanCleef fell."
-- The latest few moments that the rest of History doesn't already tell, a sentence a month.
local function annalsParagraph(name, told)
  local a = Compose.Annals()
  local ladder = Compose.Ranks(ns.cache.world)
  local picked = {}
  for k = #a, 1, -1 do
    local e = a[k]
    if not told[e.k] then
      local text
      if e.kind == "rank" then
        local rank = ladder[band(e.level)] or e.rank
        text = rank and ("was made " .. rank .. (e.zone and (" in " .. U.Mid(e.zone)) or ""))
      elseif e.kind == "name" and e.deed then
        text = e.deed:gsub("^%u", string.lower) .. ", and has been called " .. quote(e.nick) .. " since"
      elseif e.kind == "inside" and e.name then
        text = "went into " .. U.Mid(e.name) .. " for the first time"
      elseif e.kind == "craft" and e.skill and W.PROF_NOUN[e.skill:lower()] then
        text = "became " .. profWord(e.rank) .. " " .. W.PROF_NOUN[e.skill:lower()]
      elseif e.kind == "battle" then
        text = "won {their} first battleground" .. (e.zone and (", in " .. U.Mid(e.zone)) or "")
      elseif e.kind == "honour" and e.standing and e.faction then
        text = "earned " .. e.standing:lower() .. " standing with " .. W.FactionName(e.faction)
      end
      if text then table.insert(picked, 1, { t = e.t, text = text }) end
      if #picked >= 4 then break end
    end
  end
  if #picked == 0 then return nil end
  local now = U.Call(date, "*t", U.Now()) or {}
  local out, month, list = {}, nil, nil
  local function flush()
    if not list then return end
    local d = U.Call(date, "*t", month) or {}
    local when
    if d.year == now.year and d.month == now.month then when = "This month"
    elseif d.month then when = "In " .. MONTHS[d.month] .. ((d.year ~= now.year) and (" " .. d.year) or "")
    end
    if when then
      out[#out + 1] = when .. ", " .. name .. " " .. list[1]
      for k = 2, #list do out[#out + 1] = list[k] end
    end
  end
  for _, p in ipairs(picked) do
    local d = U.Call(date, "*t", p.t) or {}
    local m = month and U.Call(date, "*t", month) or {}
    if not list or d.month ~= m.month or d.year ~= m.year then flush(); month, list = p.t, {} end
    list[#list + 1] = p.text
  end
  flush()
  return paragraph(out)
end

function Compose.History()
  local c = ns.cache
  local rpgd, chron, sd, world = c.rpgd, c.chronicle, c.sd, c.world
  local name = firstName()
  local paras = {}
  local toldKeys = {}   -- what the paragraphs tell, so the annals don't tell it twice
  local race = W.RACE_NOUN[world.race or ""]
  local noun = W.CLASS_NOUN[world.class or ""]
  local what = race and noun and (article(race) .. " " .. noun) or nil

  -- 1. Where it began
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
  paras[#paras + 1] = paragraph(roots)

  -- 2. The road so far
  local road = {}
  local zones = rpgd and rpgd.zones or {}
  local zoneCount = math.max(#zones, chron and chron.zones or 0)
  if zoneCount >= 3 and zones[1] then
    local since = math.min(zones[1].t or math.huge, chron and chron.created or math.huge)
    local weeks = since < math.huge and math.floor((U.Now() - since) / 604800) or 0
    local ago = weeks >= 9 and (U.Number(math.floor(weeks / 4.3)) .. " months ago")
      or weeks >= 2 and (U.Number(weeks) .. " weeks ago") or nil
    local last = zones[#zones]
    local latest = (last and last.name ~= zones[1].name) and (", " .. placeName(last.name) .. " the latest of them") or ""
    road[#road + 1] = "From " .. placeName(zones[1].name) .. (ago and (", " .. ago .. ",") or "") .. " {their} road has led through "
      .. U.Number(zoneCount) .. " lands" .. latest
    local dungeons = chron and chron.dungeons or 0
    if dungeons >= 2 then road[#road + 1] = "Along the way {they've} been inside " .. U.Number(dungeons) .. " dungeons" end
  elseif (world.level or 1) < 10 then
    road[#road + 1] = say("setout", { name = name })
  end
  local ms = ns.char and ns.char.milestones or {}
  if #ms > 0 then
    -- The rank by the level it came at, on this character's own ladder (before 0.20.0 the
    -- plain class ladder was saved, which could disagree with the Title).
    local ladder = Compose.Ranks(world)
    local steps = {}
    for k = math.max(1, #ms - 1), #ms do
      local m = ms[k]
      local rank = (tonumber(m.level) and ladder[band(m.level)]) or m.rank
      if rank then steps[#steps + 1] = rank .. (m.zone and (" in " .. U.Mid(m.zone)) or "") end
      if rank and tonumber(m.level) then toldKeys["rank:" .. m.level] = true end
    end
    if #steps > 0 then road[#road + 1] = "Was made " .. U.Join(steps) end
  end
  if rpgd and rpgd.homeInn then
    local s = "Home these days is " .. placeName(rpgd.homeInn)
    if rpgd.homePrev and rpgd.homePrev ~= rpgd.homeInn and within(rpgd.homeSince, 14 * 86400) then
      s = s .. ", lately moved from " .. placeName(rpgd.homePrev)
    end
    road[#road + 1] = s
  end
  paras[#paras + 1] = paragraph(road)

  -- 3. What they've done, and the name it earned them. (Deaths and kills are counted in the
  -- Statistics, not told here.)
  local deeds = {}
  local earned, earnedKey = Compose.EarnedStory(name)
  if earnedKey then toldKeys["name:" .. earnedKey] = true; toldKeys[earnedKey] = true end
  local told = 0
  if rpgd then
    for _, t in ipairs(rpgd.threads) do
      if earnedKey ~= "thread:" .. t.id and told < 2 then
        if t.state == "resolved" then deeds[#deeds + 1] = "Saw " .. lowerFirst(t.title) .. " through to the end"; told = told + 1
          toldKeys["name:thread:" .. t.id] = true
        elseif t.state == "soured" then deeds[#deeds + 1] = "Watched " .. lowerFirst(t.title) .. " go sour"; told = told + 1 end
      end
    end
  end
  for _, s in ipairs(earned or {}) do deeds[#deeds + 1] = s end
  if rpgd then
    local places = {}
    for k = 1, math.min(3, #rpgd.cleared) do places[k] = U.Mid(rpgd.cleared[k].name) end
    if #places > 0 then deeds[#deeds + 1] = say("delved", { list = U.Join(places) }, places[1]) end
  end
  local bosses = Compose.Bosses(c)
  local latest = bosses[1]
  local named = earnedKey and latest and earnedKey == "boss:" .. latest.name
  if latest then toldKeys["name:boss:" .. latest.name] = true end
  if #bosses >= 3 then deeds[#deeds + 1] = say("bosses", { n = U.Number(#bosses), who = latest.name }, latest.name)
  elseif latest and not named then deeds[#deeds + 1] = say("boss", { who = latest.name, where = "" }, latest.name) end
  if chron and chron.rares >= 5 then deeds[#deeds + 1] = say("rares", { n = U.Number(chron.rares) }) end
  local questsDone = Compose.QuestsDone(c)
  if questsDone >= 25 then deeds[#deeds + 1] = say("jobs", { n = U.Roughly(questsDone) }) end
  local profs = (chron and #chron.professions > 0 and chron.professions) or world.professions or {}
  local crafts = {}
  for k = 1, math.min(2, #profs) do
    local pr = profs[k]
    local pn = W.PROF_NOUN[pr.name:lower()]
    if pr.rank >= 50 and pn then crafts[#crafts + 1] = profWord(pr.rank) .. " " .. pn end
  end
  if #crafts > 0 then deeds[#deeds + 1] = "Between roads {they're} " .. U.Join(crafts) end
  local finds = ns.char and ns.char.finds or {}
  if #finds > 0 then
    local items = {}
    for k = #finds, math.max(1, #finds - 1), -1 do
      local f = finds[k]
      items[#items + 1] = itemName(f.item, f.quality) .. (f.zone and (" from " .. U.Mid(f.zone)) or "")
    end
    deeds[#deeds + 1] = say("finds", { list = U.Join(items) }, finds[#finds].item)
  end
  paras[#paras + 1] = paragraph(deeds)

  -- 4. The people, friends and otherwise
  local people = {}
  local friends = {}
  if rpgd then
    for k = 1, math.min(2, #rpgd.friends) do friends[k] = rpgd.friends[k].name end
  end
  local partner
  if sd and ns.db.nameFriends and #sd.friends > 0 then
    local f = sd.friends[1]
    if f.relationship then
      partner = f.name .. ", {their} " .. f.relationship:lower() .. (sd.friends[2] and (", and " .. sd.friends[2].name) or "")
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
  if sd and sd.recentPeople >= 4 then
    people[#people + 1] = "Has fought beside " .. U.Number(sd.recentPeople) .. " others this past week"
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
  if world.guild then
    local g = world.guild:find("^The ") and U.Mid(world.guild) or world.guild
    people[#people + 1] = "Wears the colours of " .. g .. (world.guildRank and (" and holds the rank of " .. world.guildRank:lower() .. " there") or "")
  end
  if world.pvpRank then
    people[#people + 1] = "Holds the rank of " .. world.pvpRank .. " in the " .. (world.faction or "faction") .. "'s army"
  end
  local byWord = {}
  for _, f in ipairs(world.factions or {}) do
    byWord[f.word] = byWord[f.word] or {}
    if #byWord[f.word] < 2 then table.insert(byWord[f.word], W.FactionName(f.name)) end
  end
  local served = {}
  for _, w in ipairs({ "Exalted", "Revered", "Honored" }) do
    for _, f in ipairs(byWord[w] or {}) do if #served < 3 then served[#served + 1] = f end end
  end
  if #served > 0 then people[#people + 1] = "Has done good work for " .. U.Join(served) end
  local hon = ns.char and ns.char.honours or {}
  local h = hon[#hon]
  if h and within(h.t, 14 * 86400) then
    toldKeys["honour:" .. tostring(h.faction) .. ":" .. tostring(h.standing)] = true
    people[#people + 1] = "Only recently earned " .. h.standing:lower() .. " standing with " .. W.FactionName(h.faction)
  end
  if rpgd and rpgd.rivals[1] then
    people[#people + 1] = say("rival", { who = rpgd.rivals[1].name }, rpgd.rivals[1].name)
  end
  if sd and #sd.foes > 0 then
    people[#people + 1] = "Has made " .. (#sd.foes == 1 and "an enemy" or (U.Number(#sd.foes) .. " enemies")) .. " on the road"
  end
  paras[#paras + 1] = paragraph(people)

  -- 4b. Month by month: the moments the rest doesn't tell.
  if ns.db.annals ~= false then paras[#paras + 1] = annalsParagraph(name, toldKeys) end

  -- 5. How things stand now
  local now = {}
  local days = ns.Mood.RecentDays(3)
  local bits = {}
  for _, d in ipairs(days) do
    local m = d.mood and W.MOODS[d.mood] and W.MOODS[d.mood].title:lower()
    if m and d.zone then bits[#bits + 1] = m .. " in " .. U.Mid(d.zone) .. " " .. d.label
    elseif m then bits[#bits + 1] = m .. " " .. d.label end
  end
  now[#now + 1] = Compose.WeekTone()
  if #bits >= 2 then now[#now + 1] = "Felt " .. U.Join(bits) end
  local wb = Compose.WealthBand(world)
  if wb then now[#now + 1] = wb.flair end
  if rpgd and ns.db.diaryExcerpt and rpgd.lastEntry and rpgd.lastEntry.text then
    now[#now + 1] = "{their} latest journal entry reads " .. quote(U.Truncate(rpgd.lastEntry.text, 280))
  end
  paras[#paras + 1] = paragraph(now)

  return pages(paras)
end

---------------------------------------------------------------------------
-- About: Physical, from gear (live, or Chronicle's snapshot) and physique (stats)
---------------------------------------------------------------------------
local function physique(c)
  local stats = (c.chronicle and c.chronicle.appearance and c.chronicle.appearance.stats) or c.world.stats or {}
  local best, bestV
  for name, v in pairs(stats) do
    if type(v) == "number" and W.PHYSIQUE[name] and (not bestV or v > bestV) then best, bestV = name, v end
  end
  return best and U.Pron(U.Pick(W.PHYSIQUE[best], seed("phys" .. best))) or nil
end

function Compose.Physical()
  local c = ns.cache
  local world = c.world
  local noun = W.CLASS_NOUN[world.class or ""] or "wanderer"

  -- The body: only what every one of their race shares, and their build from their stats
  local body = {}
  local rl = U.BackedList(W.RACE_LOOK[world.race or ""], world)
  if #rl > 0 then body[#body + 1] = U.Pick(rl, seed("racelook")) end
  local build = physique(c)
  body[#body + 1] = article(seasoned(world.level, "seasoned")) .. " " .. noun .. (build and (", " .. build) or "")

  -- What they wear and carry, by name, and what their class keeps in the bags
  local dress = {}
  local cl = U.BackedList(noGear(W.CLASS_LOOK[world.class or ""]), world)
  if #cl > 0 then dress[#dress + 1] = U.Pick(cl, seed("classlook")) end
  dress[#dress + 1] = kit(world, false, itemName)
  local finest = world.gear and world.gear.finest
  if finest and finest.name and (finest.quality or 0) >= 4 then
    dress[#dress + 1] = "The finest piece is " .. itemName(finest.name, finest.quality)
  end
  local bag = {}
  for i, r in ipairs(world.reagents or {}) do
    if i > 3 then break end
    bag[#bag + 1] = r.count > 1 and (U.Number(r.count) .. " " .. Compose.Plural(r.name)) or r.name
  end
  if #bag > 0 then dress[#dress + 1] = "Keeps " .. U.Join(bag) .. " in {their} bags" end
  local band = Compose.WealthBand(world)
  local pouch = band and U.Backed(band.pouch, world)
  if pouch then dress[#dress + 1] = pouch end

  -- How they are right now
  local marks = {}
  if world.health and world.health < 0.5 and not world.dead then marks[#marks + 1] = "Freshly wounded, and moving carefully" end
  if c.rpgd and (c.rpgd.insanity or 0) >= 30 then marks[#marks + 1] = "{their} eyes never settle on anything for long" end
  if c.rpgd and (c.rpgd.align.taint or 0) >= 30 then marks[#marks + 1] = "Something about {them} is off, in a way that's hard to name" end
  local wear = Compose.Wear(world)
  if wear then marks[#marks + 1] = wear.text end

  return pages({ paragraph(body), paragraph(dress), paragraph(marks) })
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
  local since = math.min(first or math.huge, c.chronicle and c.chronicle.created or math.huge)
  if since == math.huge then return nil end
  return math.floor((U.Now() - since) / 86400)
end

-- Plain counts, as figures ("1,240", "39"), only for what the game or the addons record.
function Compose.Stats()
  local c = ns.cache
  local rpgd, chron, world = c.rpgd, c.chronicle, c.world
  local function figure(n) return n >= 100 and U.Number(n) or tostring(n) end
  local out = {}
  local deaths = deathCount(c)
  if deaths > 0 then
    local first = rpgd and rpgd.deaths[1] or (chron and chron.deaths[#chron.deaths])
    out.deaths = figure(deaths) .. (first and first.killer and (", the first to " .. first.killer) or "")
  end
  local lands = math.max(rpgd and #rpgd.zones or 0, chron and chron.zones or 0)
  if lands > 0 then out.lands = figure(lands) end
  local days = roadDays(c)
  if days and days > 0 then out.road = figure(days) end
  local dungeons = math.max(chron and chron.dungeons or 0, rpgd and #rpgd.cleared or 0)
  if dungeons > 0 then out.dungeons = figure(dungeons) end
  local felled = #Compose.Bosses(c)
  if felled > 0 then out.foes = figure(felled) end
  if chron and chron.rares > 0 then out.rares = figure(chron.rares) end
  local kills = rpgd and rpgd.kills or 0
  if kills > 0 then
    out.slain = figure(kills)
    if rpgd.grudge and rpgd.grudge.n >= 10 then
      out.slain = out.slain .. ", " .. figure(rpgd.grudge.n) .. " of them " .. Compose.Plural(rpgd.grudge.name)
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
  if rpgd and #rpgd.books > 0 then out.books = figure(#rpgd.books) end
  -- Every name earned, the one worn first ("Mine-Warden, Defias-Breaker and Hogger's Bane").
  local names, worn = {}, Compose.Earned()
  if worn then names[1] = worn.nick end
  for _, e in ipairs(Compose.EarnedAll()) do
    if e ~= worn and #names < 5 then names[#names + 1] = e.nick end
  end
  if #names > 0 then out.names = U.Join(names) end
  -- The most cast spell, with how many times ("Flash Heal, 1,240 times").
  local top = Compose.TopSpells(1)[1]
  if top and top.n >= 10 then out.spell = top.name .. ", " .. figure(top.n) .. " times" end
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
  local rpgd, world = c.rpgd, c.world
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
  smitten = true, satisfied = true, homecoming = true, proud = true, flush = true, ["calm:charming"] = true, ["calm:kind"] = true }
local WALKUP_CLOSED = { angry = true, downcast = true, sorrowful = true, wounded = true, tense = true, shaken = true,
  ailing = true, frustrated = true, drained = true, haunted = true, ["calm:reserved"] = true, ["calm:cruel"] = true }
function Compose.Walkup(mood)
  if not mood then return nil end
  if WALKUP_OPEN[mood.key] then return 2 end
  if WALKUP_CLOSED[mood.key] then return 1 end
  return nil
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

-- Names within reach: a quest in the log that would earn one not yet earned (a chain's
-- last step, or one of its parts that share its title; a bounty). Greatest first:
-- { { nick, quest, motto, rank, tier } }.
function Compose.InReach()
  local have, out, seen = {}, {}, {}
  for _, e in ipairs(Compose.EarnedAll()) do have[e.nick] = true end
  local class = ns.cache.world and ns.cache.world.class
  local log = ns.Sources.Deeds and ns.Sources.Deeds.InLog() or {}
  for i, title in ipairs(log) do
    local e, r = W.EARNED_QUEST[title], nil
    if e and (not e.class or e.class == class) then
      r = { nick = e.nick, motto = e.motto, quest = title, rank = 3, tier = e.tier or 1, i = i }
    else
      local target, short = Compose.BountyTarget(title)
      if target then
        r = { nick = short .. "'s Bane", motto = (W.EARNED_BOUNTY[short] or {}).motto, quest = title, rank = 1, tier = 0, i = i }
      end
    end
    if r and not have[r.nick] and not seen[r.nick] then seen[r.nick] = true; out[#out + 1] = r end
  end
  table.sort(out, function(a, b)
    if a.rank ~= b.rank then return a.rank > b.rank end
    if a.tier ~= b.tier then return a.tier > b.tier end
    return a.i < b.i
  end)
  return out
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
  return e and e.motto or nil
end

-- What people call them, for something they saw through.
function Compose.Nickname()
  local e = Compose.Earned()
  return e and e.nick or nil
end

-- The profile icon: the earned nickname's, else the class crest.
function Compose.Icon()
  local e = Compose.Earned()
  return (e and e.icon) or W.CLASS_ICON[ns.cache.world.class or ""]
end

-- The History sentences for the deed behind the name: the deed and where the name came
-- from, the saying that came with it, and the other names that stuck (two at most).
-- Returns a list of sentences and the key of the deed told.
function Compose.EarnedStory(name)
  local e = Compose.Earned()
  if not e then return nil end
  local out = { say("earned", { deed = e.deed, name = name, nick = quote(e.nick) }, e.key) }
  if e.motto then out[#out + 1] = say("saying", { motto = quote(e.motto) }, e.key) end
  local others = {}
  for _, o in ipairs(Compose.EarnedAll()) do
    if o.key ~= e.key and #others < 2 then others[#others + 1] = quote(o.nick) end
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
