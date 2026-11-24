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

function Compose.Refresh()
  local S = ns.Sources
  local c = ns.cache
  local now = U.Now()
  c.world = ns.World.Snapshot()
  if now - sourcesAt >= 60 or not c.read then
    c.rpgd = S.RPGD.Read()
    c.sd = S.SocialDiary.Read()
    c.chronicle = S.Chronicle.Read()
    sourcesAt, c.read = now, true
  end
  c.t = now
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
  local tod = ns.World.TimeOfDay(world)
  local function build(withAlso, terse, withTod)
    local text = mood.adj
    if withAlso and mood.also then text = text .. " and " .. mood.also end
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

local THREAD_PHRASE = {
  stirring = { "Has been asking around about %s.", "Has caught wind of %s." },
  unfolding = { "Is caught up in %s.", "Can't leave %s alone." },
  resolved = { "Saw %s through to the end.", "Had a hand in settling %s." },
  soured = { "Watched %s go badly wrong.", "Was there when %s went sour." },
}

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
    local tx = "Died" .. (death.killer and (" at the hands of " .. death.killer) or "") .. (death.zone and (" in " .. death.zone) or "")
      .. " a short while ago, and is still pale from it"
    add(death.t, 3, { TI = "Fresh Scars", TX = tx .. ".", IC = "Spell_Holy_Resurrection" })
  end
  local boss = chron and chron.bosses[1]
  if boss and within(boss.t, 2 * 86400) then
    add(boss.t, 2, { TI = "Fresh Victory", IC = "INV_Misc_Head_Dragon_01",
      TX = "Was there when " .. boss.name .. " fell" .. (boss.where and (" in " .. U.Mid(boss.where)) or "") .. "." })
  end
  local cleared = rpgd and rpgd.cleared[1]
  if cleared and within(cleared.t, 3 * 86400) then
    add(cleared.t, 2, { TI = "Back From the Depths", IC = "INV_Misc_Key_14",
      TX = "Only lately came back up out of " .. U.Mid(cleared.name) .. ", still smelling of the place." })
  end
  local thread = rpgd and rpgd.threads[1]
  if thread and within(thread.t, 3 * 86400) and THREAD_PHRASE[thread.state] then
    add(thread.t, 1, { TI = thread.state == "resolved" and "Loose Ends Tied" or "Caught Up in Something",
      IC = "INV_Misc_Note_02", TX = U.Pick(THREAD_PHRASE[thread.state], seed(thread.id)):format(lowerFirst(thread.title)) })
  end
  -- A fight just now
  local fight = ns.char and ns.char.lastFight
  if fight and type(fight.foe) == "table" and within(fight.t, 300) then
    local who = fight.foe.named and fight.foe.name or article(fight.foe.name)
    local tx = fight.close and ("Barely survived a fight with " .. who)
      or fight.long and ("Fresh from a long, hard fight with " .. who)
      or ("Fresh from a fight with " .. who)
    add(fight.t, fight.close and 2 or 0, { TI = fight.close and "Close Call" or "Blood Up", IC = "Ability_DualWield", TX = tx .. "." })
  end
  -- A job just finished (Chronicle keeps the quest's name)
  local q = chron and chron.lastQuest
  if q and within(q.t, 1800) then
    add(q.t, 0, { TI = "A Job Done", IC = "INV_Misc_Note_06",
      TX = "Just saw a job through: \"" .. q.title .. "\"" .. (q.zone and (", in " .. U.Mid(q.zone)) or "") .. "." })
  end

  -- A conversation just now in RPG Dialogue
  local talk = rpgd and rpgd.lastTalk
  if talk and within(talk.last, 1800) then
    local how = talk.affinity >= 3 and "warmly" or talk.affinity <= -3 and "coldly" or nil
    add(talk.last, 1, { TI = "Lately", IC = "INV_Letter_15",
      TX = "Was just " .. (how and ("talking " .. how .. " with ") or "talking with ") .. talk.name
        .. (talk.zone and (" in " .. U.Mid(talk.zone)) or "") .. "." })
  end
  local finds = ns.char and ns.char.finds
  local find = finds and finds[#finds]
  if find and within(find.t, 86400) then
    add(find.t, 2, { TI = "A New Prize", IC = "INV_Misc_Gem_Pearl_04",
      TX = U.Pron("Recently came by " .. find.item .. (find.zone and (" in " .. U.Mid(find.zone)) or "") .. ", and keeps turning it over in {their} hands.") })
  end
  local zone = rpgd and rpgd.zones[#rpgd.zones]
  if zone and within(zone.t, 86400) and #rpgd.zones > 2 then
    add(zone.t, 0, { TI = "New in Town", IC = "INV_Misc_Map_01",
      TX = "Arrived in " .. U.Mid(zone.name) .. " recently and is still learning the roads." })
  end

  table.sort(cands, function(a, b)
    if a.prio == 3 and within(a.t, 86400) then return true end
    if b.prio == 3 and within(b.t, 86400) then return false end
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
      return { TI = "Lately", IC = "INV_Letter_15", TX = "Was last seen in conversation with " .. last.name .. "." }
    end
  end
  local where = world.zone and U.Mid(world.zone) or "these parts"
  local list = { "Keeping busy around " .. where .. ".", "Has been working " .. where .. " for a while now." }
  local ca = W.CLASS_ACTIVITY[world.class or ""]
  if ca then
    for _, a in ipairs(ca) do list[#list + 1] = "Has been " .. a:gsub("{place}", function() return where end) .. "." end
  end
  return { TI = "Lately", IC = "INV_Misc_Map_01", TX = U.Pick(list, seed("lately" .. where)) }
end

function Compose.CompanyGlance()
  local c = ns.cache
  local world, sd, rpgd = c.world, c.sd, c.rpgd
  local n = world.groupSize or 0
  if world.grouped and world.raid and n > 5 then
    return { TI = "Part of a Host", IC = "INV_BannerPVP_02",
      TX = "Marching with a host of " .. U.Number(n) .. ", banners and all." }
  end
  if world.grouped and n > 1 then
    local party = Compose.PartyWords()
    return { TI = "In Company", IC = "Spell_Holy_PrayerOfSpirit",
      TX = "Travelling with " .. (party or (n == 2 and "a companion" or ("a band of " .. U.Number(n)))) .. "." }
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
    if friend then tx = tx .. ", and on good terms with " .. friend.name end
    return { TI = "A Known Face", IC = "INV_Misc_Bag_11", TX = tx .. "." }
  end
  if friend then
    return { TI = "A Known Face", IC = "INV_Misc_Bag_11", TX = "On good terms with " .. friend.name .. "." }
  end
  if world.pet and (world.class == "HUNTER" or world.class == "WARLOCK") then
    local mood = world.petHappy and W.PET_HAPPY[world.petHappy]
    return { TI = "Travels Light", IC = "Ability_Hunter_BeastCall",
      TX = "Travels with no one but " .. world.pet .. (world.petKind and (" the " .. world.petKind:lower()) or "") .. (mood and (", " .. mood) or "") .. "." }
  end
  local reserved = rpgd and ((rpgd.traits.reserved or 0) >= 3)
  return { TI = "Travels Alone", IC = "Spell_Shadow_Teleport",
    TX = reserved and "Travels alone by choice, and keeps conversations short." or "Travels alone these days, and would welcome company." }
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
    return { TI = "Ambition", IC = "INV_Misc_Book_11",
      TX = U.Cap(U.Truncate(chron.goals[1].text, 120)) .. ". It comes up in most conversations." }
  end
  for _, t in ipairs(rpgd and rpgd.threads or {}) do
    if t.state == "unfolding" or t.state == "stirring" then
      return { TI = "Unfinished Business", IC = "INV_Misc_Note_02",
        TX = "Wants to get to the bottom of " .. lowerFirst(t.title) .. "." }
    end
  end
  local list = {}
  local level = world.level or 1
  if level < 10 then
    for _, a in ipairs(W.AMBITIONS_NEW) do list[#list + 1] = a end
  elseif level >= 60 then
    for _, a in ipairs(W.AMBITIONS_60) do list[#list + 1] = a end
  end
  for _, a in ipairs(W.AMBITIONS[world.class or ""] or W.AMBITIONS.default) do list[#list + 1] = a end
  for _, a in ipairs(W.RACE_AMBITIONS[world.race or ""] or {}) do list[#list + 1] = a end
  return { TI = "Ambition", IC = "INV_Misc_Book_11", TX = U.Pron(U.Pick(list, seed("ambition"))) }
end

-- What's visible on them: the most telling marks, else what they wear and carry.
local function kit(world, short)
  local g = world.gear or {}
  local parts = {}
  local dress = g.armor and ((W.WEAR_QUALITY[g.quality or 1] or "serviceable") .. " " .. g.armor)
  if dress then parts[#parts + 1] = "Wears " .. dress .. (g.tabard and (" under the " .. g.tabard) or "") end
  local arms = {}
  if g.main then arms[#arms + 1] = g.main end
  if g.off and g.off ~= g.main then arms[#arms + 1] = g.off end
  if g.ranged and not short then arms[#arms + 1] = g.ranged end
  if #arms > 0 then parts[#parts + 1] = (#parts > 0 and "keeps " or "Keeps ") .. U.Join(arms) .. " close" end
  if #parts == 0 then return nil end
  return table.concat(parts, " and ") .. "."
end

function Compose.MarksGlance()
  local c = ns.cache
  local world, rpgd = c.world, c.rpgd
  local marks = {}
  local function mark(prio, title, text, icon) marks[#marks + 1] = { prio = prio, TI = title, TX = U.Pron(text), IC = icon } end
  if world.health and world.health < 0.5 and not world.combat and not world.dead then
    mark(9, "Bloodied", "Fresh bandages, and a limp {they} {are} trying to hide.", "Ability_Rogue_FeignDeath")
  end
  if rpgd and (rpgd.drunk or 0) > 0 and U.Now() - (rpgd.drunkAt or 0) < 1800 then
    mark(8, "Smells of Ale", "Unsteady on {their} feet, and smelling strongly of the tavern.", "INV_Drink_05")
  end
  if rpgd and (rpgd.insanity or 0) >= 30 then
    mark(7, "Haunted Eyes", "Eyes that never settle, as if following something no one else can see.", "Spell_Shadow_Possession")
  end
  if rpgd and (rpgd.align.taint or 0) >= 30 then
    mark(6, "Something Wrong", "A faint wrongness hangs about {them}, like smoke that won't clear.", "Spell_Shadow_ShadowWordPain")
  end
  local g = world.gear or {}
  if g.durability and g.durability < 0.25 then
    mark(5, "Battered Kit", "Armour dented and split at the seams, held together with twine.", "INV_Hammer_20")
  end
  local finest = g.finest or (c.chronicle and c.chronicle.appearance and c.chronicle.appearance.finest)
  if finest and finest.name and finest.quality >= 4 then
    mark(4, "Remarkable Gear", "People tend to notice {their} " .. finest.name .. " first.", "INV_Misc_Gem_Pearl_04")
  end
  local deaths = deathCount(c)
  if deaths >= 10 then
    mark(3, "Old Scars", "Scarred all over, the old marks crossed by newer ones.", "Ability_Warrior_BloodFrenzy")
  end
  table.sort(marks, function(a, b) return a.prio > b.prio end)
  if marks[1] then
    local m = marks[1]
    return { TI = m.TI, TX = m.TX, IC = m.IC }
  end
  local k = kit(world, true)
  local cl = W.CLASS_LOOK[world.class or ""]
  local classMark = cl and U.Pron(U.Pick(cl, seed("classmark")))
  if k and classMark then return { TI = "Kit", IC = "INV_Chest_Chain_05", TX = k .. " " .. classMark } end
  if k then return { TI = "Kit", IC = "INV_Chest_Chain_05", TX = k } end
  if classMark then return { TI = "At a Glance", IC = "INV_Chest_Chain_05", TX = classMark } end
  return { TI = "Plainly Dressed", IC = "INV_Shirt_05", TX = U.Pron("Plain clothes that give nothing away about {them}.") }
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

-- Where they are on the road: new, finding their feet, established, veteran.
local function stage(level)
  level = level or 1
  if level < 15 then return "new" elseif level < 35 then return "finding" elseif level < 55 then return "established" end
  return "veteran"
end

-- A line from a table keyed by temperament: the first dominant trait that has one, else default.
local function byTemper(t, rpgd, key)
  if type(t) ~= "table" then return nil end
  for _, trait in ipairs(rpgd and rpgd.dominant or {}) do
    if t[trait] then return type(t[trait]) == "table" and U.Pick(t[trait], seed(key .. trait)) or t[trait] end
  end
  local d = t.default
  return type(d) == "table" and U.Pick(d, seed(key)) or d
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

function Compose.Bearing()
  local c = ns.cache
  local rpgd, world = c.rpgd, c.world
  local name = firstName()
  local noun = W.CLASS_NOUN[world.class or ""] or "wanderer"

  if not rpgd then
    return paragraph({ name .. " is still working out what sort of " .. noun .. " to be",
      byTemper(W.ARC_STAGE[stage(world.level)], nil, "arc") })
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
  local plain = Compose.PlainAlignment(rpgd.align)
  if #plain > 0 then
    first[#first + 1] = "Most who know {them} would call {them} " .. U.Join(plain)
  else
    first[#first + 1] = "People who know {them} still argue about whether {they're} a good sort or not"
  end

  -- Beliefs, and where they have shifted
  local views = {}
  local ops = opinions(rpgd, 3)
  if #ops > 0 then views[#views + 1] = U.Join(ops) end
  for _, o in ipairs(rpgd.opinions) do
    local topic = o.topic ~= "peace" and topicName(o.topic)
    if o.changed and topic then
      views[#views + 1] = "Used to feel differently about " .. topic .. ", and doesn't always say why {they} changed"
      break
    end
  end

  -- The rest of the inner life: the strange, the bookish, the indiscreet
  local more = {}
  if (rpgd.align.taint or 0) >= 30 then
    more[#more + 1] = "There is a taint on {them} now. Animals shy away, and the devout stand a step further off"
  end
  if (rpgd.insanity or 0) >= 40 then
    more[#more + 1] = "Lately {they} talk to empty corners, and sometimes stop as if the corners had answered"
  end
  if (rpgd.liesExposed or 0) > 0 then
    more[#more + 1] = "Has been caught in " .. (rpgd.liesExposed == 1 and "a lie" or "more than one lie")
      .. ", and some people still bring it up"
  end
  if #rpgd.books >= 2 then
    local titles = {}
    for i = 1, math.min(2, #rpgd.books) do titles[i] = quote(rpgd.books[i].title) end
    local extra = #rpgd.books - 2
    more[#more + 1] = "Reads whenever there's light to read by: " .. U.Join(titles)
      .. (extra > 0 and (", and " .. U.Number(extra) .. " " .. U.Plural(extra, "other") .. " besides") or "")
  end
  if rpgd.topics >= 15 then
    more[#more + 1] = "Listens to every rumour going and remembers most of them"
  end
  local hooks = Compose.Hooks()
  local stories = #hooks > 0 and paragraph({ "Has stories about " .. U.Join(hooks) }) or nil

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
  if chron and chron.bosses[1] then add("the day " .. chron.bosses[1].name .. " fell") end
  if rpgd and rpgd.friends[1] then add(rpgd.friends[1].name) end
  if rpgd and rpgd.origin and rpgd.origin.name then add("where {they} grew up") end
  local prof = (chron and chron.professions[1]) or (world.professions and world.professions[1])
  if prof and prof.rank >= 75 then add(prof.name:lower()) end
  return hooks
end

---------------------------------------------------------------------------
-- About: History. Six movements: where they came from, the road so far and what it has
-- made of them, what it has cost, the people, the work and the deeds, and how things
-- stand now.
---------------------------------------------------------------------------
local function profWord(rank)
  for _, r in ipairs(W.PROF_RANK) do if rank >= r.min then return r.word end end
  return "an apprentice"
end

local function placeWithInn(n)
  if n:find("^The ") then return "at " .. U.Mid(n) end
  if ns.World.IsInn(n) then return "at the " .. n end
  return "in " .. n
end

function Compose.History()
  local c = ns.cache
  local rpgd, chron, sd, world = c.rpgd, c.chronicle, c.sd, c.world
  local name = firstName()
  local paras = {}

  -- 1. Where it began
  local roots = {}
  if rpgd and rpgd.origin and rpgd.origin.name then
    roots[#roots + 1] = rpgd.origin.name
    if rpgd.origin.blurb then roots[#roots + 1] = quote(rpgd.origin.blurb) end
  else
    local bg = W.RACE_BACKGROUND[world.race or ""]
    local cbg = W.CLASS_BACKGROUND[world.class or ""]
    if bg then roots[#roots + 1] = (U.Pick(bg, seed("bg")):gsub("{name}", function() return name end)) end
    if cbg then roots[#roots + 1] = U.Pick(cbg, seed("cbg")) end
  end
  paras[#paras + 1] = paragraph(roots)

  -- 2. The road so far, and what it has made of them
  local road = {}
  local zones = rpgd and rpgd.zones or {}
  local zoneCount = math.max(#zones, chron and chron.zones or 0)
  if zoneCount >= 3 and zones[1] then
    local since = math.min(zones[1].t or math.huge, chron and chron.created or math.huge)
    local weeks = since < math.huge and math.floor((U.Now() - since) / 604800) or 0
    local ago = weeks >= 9 and (U.Number(math.floor(weeks / 4.3)) .. " months ago")
      or weeks >= 2 and (U.Number(weeks) .. " weeks ago") or nil
    local dungeons = chron and chron.dungeons or 0
    road[#road + 1] = name .. " left " .. zones[1].name .. (ago and (" " .. ago) or "") .. " and has seen "
      .. U.Number(zoneCount) .. " lands since" .. (dungeons >= 2 and (", and the inside of " .. U.Number(dungeons) .. " dungeons") or "")
    local last = zones[#zones]
    if last and last.name ~= zones[1].name then road[#road + 1] = "The road has lately led through " .. U.Mid(last.name) end
  elseif (world.level or 1) < 10 then
    road[#road + 1] = name .. " has only just set out, and hasn't been far from home yet"
  end
  if rpgd and rpgd.homeInn then
    local s = "Keeps a room " .. placeWithInn(rpgd.homeInn)
    if rpgd.homePrev and rpgd.homePrev ~= rpgd.homeInn and within(rpgd.homeSince, 14 * 86400) then
      s = s .. " now, having given up the one " .. placeWithInn(rpgd.homePrev)
    end
    road[#road + 1] = s
  end
  local ms = ns.char and ns.char.milestones or {}
  if #ms > 0 then
    local steps = {}
    for i = math.max(1, #ms - 1), #ms do
      local m = ms[i]
      steps[#steps + 1] = m.rank .. (m.zone and (" in " .. U.Mid(m.zone)) or "")
    end
    road[#road + 1] = "Was made " .. U.Join(steps)
  end
  -- A turning point: the hardest place they've come back from, and what it changed.
  local turned = rpgd and rpgd.cleared[1] and U.Mid(rpgd.cleared[1].name)
    or chron and chron.bosses[1] and chron.bosses[1].where and U.Mid(chron.bosses[1].where)
  if turned then
    road[#road + 1] = "Something changed in {them} after " .. turned .. ". " .. byTemper(W.TURNING, rpgd, "turning")
  end
  road[#road + 1] = byTemper(W.ARC_STAGE[stage(world.level)], rpgd, "arc")
  paras[#paras + 1] = paragraph(road)

  -- 3. What it has cost
  local cost = {}
  local deaths = deathCount(c)
  if deaths > 0 then
    local firstDeath = rpgd and rpgd.deaths[1] or (chron and chron.deaths[#chron.deaths])
    local who = firstDeath and firstDeath.killer
    local where = firstDeath and firstDeath.zone and (" in " .. firstDeath.zone) or ""
    if deaths == 1 then
      cost[#cost + 1] = "Has died once" .. (who and (", to " .. who .. where) or "")
    else
      cost[#cost + 1] = "Has died " .. U.Times(deaths) .. " and come back each time"
        .. (who and (". The first time it was " .. who .. where) or "")
    end
    cost[#cost + 1] = byTemper(W.DEATH_LESSON[deaths >= 10 and "many" or "few"], rpgd, "death")
  end
  if rpgd and rpgd.rivals[1] then
    cost[#cost + 1] = "There is no love lost between {them} and " .. rpgd.rivals[1].name
  end
  if sd and #sd.foes > 0 then
    cost[#cost + 1] = "Has made " .. (#sd.foes == 1 and "an enemy" or "a few enemies") .. " on the road who would be glad to see {them} fall"
  end
  paras[#paras + 1] = paragraph(cost)

  -- 4. The people
  local people = {}
  if rpgd then
    local friends = {}
    for i = 1, math.min(2, #rpgd.friends) do friends[i] = rpgd.friends[i].name end
    if #friends > 0 then
      people[#people + 1] = name .. " counts " .. U.Join(friends) .. " among {their} friends"
    end
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
  if sd and ns.db.nameFriends and #sd.friends > 0 then
    local f = sd.friends[1]
    if f.relationship then
      people[#people + 1] = "Rides with " .. f.name .. ", {their} " .. f.relationship:lower()
        .. (sd.friends[2] and (", and with " .. sd.friends[2].name) or "")
    else
      local names = {}
      for i = 1, math.min(3, #sd.friends) do names[i] = sd.friends[i].name end
      people[#people + 1] = "Has fallen in with " .. U.Join(names)
    end
  end
  if sd and sd.recentPeople >= 4 then
    people[#people + 1] = "Has fought beside " .. U.Number(sd.recentPeople) .. " others this past week"
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
  local reps = {}
  local REP = { Exalted = "exalted", Revered = "revered", Honored = "honoured" }
  for _, w in ipairs({ "Exalted", "Revered", "Honored" }) do
    if byWord[w] then reps[#reps + 1] = REP[w] .. " by " .. U.Join(byWord[w]) end
    if #reps >= 2 then break end
  end
  if #reps > 0 then people[#people + 1] = U.Cap(U.Join(reps)) end
  local hon = ns.char and ns.char.honours or {}
  local h = hon[#hon]
  if h and within(h.t, 14 * 86400) then
    people[#people + 1] = "Only recently earned " .. h.standing:lower() .. " standing with " .. W.FactionName(h.faction)
  end
  paras[#paras + 1] = paragraph(people)

  -- 5. Work and deeds
  local deeds = {}
  if rpgd then
    for _, t in ipairs(rpgd.threads) do
      if t.state == "resolved" then deeds[#deeds + 1] = "Saw " .. lowerFirst(t.title) .. " through to the end"
      elseif t.state == "soured" then deeds[#deeds + 1] = "Watched " .. lowerFirst(t.title) .. " go sour, and still thinks about it" end
      if #deeds >= 2 then break end
    end
    local places = {}
    for i = 1, math.min(3, #rpgd.cleared) do places[i] = U.Mid(rpgd.cleared[i].name) end
    if #places > 0 then deeds[#deeds + 1] = "Has gone down into " .. U.Join(places) .. " and come back up" end
  end
  if chron then
    if #chron.bosses >= 3 then deeds[#deeds + 1] = "Has helped bring down " .. U.Number(#chron.bosses) .. " of the worst things lurking in the dark places of the world"
    elseif chron.bosses[1] then deeds[#deeds + 1] = "Was there when " .. chron.bosses[1].name .. " fell" end
    if chron.rares >= 5 then deeds[#deeds + 1] = "Has tracked down " .. U.Number(chron.rares) .. " rare beasts that most hunters only hear about" end
    if chron.questsDone >= 25 then deeds[#deeds + 1] = "Has taken " .. U.Roughly(chron.questsDone) .. " jobs from people who needed help and couldn't do it themselves" end
  end
  local kills = rpgd and rpgd.kills or 0
  local grudge = rpgd and rpgd.grudge and rpgd.grudge.n >= 40 and rpgd.grudge
  if kills >= 500 then
    deeds[#deeds + 1] = "Has killed " .. U.Roughly(kills) .. " creatures"
      .. (grudge and (", " .. U.Number(grudge.n) .. " of them " .. Compose.Plural(grudge.name)) or "")
  elseif grudge then
    deeds[#deeds + 1] = "Has killed " .. U.Number(grudge.n) .. " " .. Compose.Plural(grudge.name) .. " and is not done yet"
  end
  local profs = (chron and #chron.professions > 0 and chron.professions) or world.professions or {}
  local crafts = {}
  for i = 1, math.min(2, #profs) do
    local p = profs[i]
    local noun = W.PROF_NOUN[p.name:lower()]
    if p.rank >= 50 and noun then crafts[#crafts + 1] = profWord(p.rank) .. " " .. noun end
  end
  if #crafts > 0 then deeds[#deeds + 1] = "Makes a living on the side as " .. U.Join(crafts) end
  local finds = ns.char and ns.char.finds or {}
  if #finds > 0 then
    local items = {}
    for i = #finds, math.max(1, #finds - 1), -1 do
      local f = finds[i]
      items[#items + 1] = itemName(f.item, f.quality) .. (f.zone and (" from " .. U.Mid(f.zone)) or "")
    end
    deeds[#deeds + 1] = "Treasures " .. U.Join(items) .. " above anything else {they} own"
  end
  paras[#paras + 1] = paragraph(deeds)

  -- 6. How things stand now
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

  -- The body
  local body = {}
  local rl = W.RACE_LOOK[world.race or ""]
  if rl then body[#body + 1] = U.Pick(rl, seed("racelook")) end
  local build = physique(c)
  body[#body + 1] = article(seasoned(world.level, "seasoned")) .. " " .. noun .. (build and (", " .. build) or "")

  -- What they wear and carry
  local dress = {}
  local cl = W.CLASS_LOOK[world.class or ""]
  if cl then dress[#dress + 1] = U.Pick(cl, seed("classlook")) end
  dress[#dress + 1] = kit(world, false)
  local app = c.chronicle and c.chronicle.appearance
  local finest = (world.gear and world.gear.finest) or (app and app.finest)
  if finest and finest.name then
    dress[#dress + 1] = U.Pick({ "People tend to notice {their} %s first", "It's {their} %s that people remember" }, seed("finest"))
      :format(itemName(finest.name, finest.quality))
  end
  if c.rpgd and (c.rpgd.lettersArrived or 0) >= 3 then
    dress[#dress + 1] = "Carries a bundle of letters in an inside pocket, worn soft from rereading"
  end

  -- What life has left on them
  local marks = {}
  local deaths = deathCount(c)
  if deaths >= 10 then marks[#marks + 1] = "Scarred all over, the old marks crossed by newer ones"
  elseif deaths >= 3 then marks[#marks + 1] = "Has a few scars, and a story for each" end
  if c.rpgd and (c.rpgd.insanity or 0) >= 30 then marks[#marks + 1] = "{their} eyes never settle anywhere for long" end
  if c.rpgd and (c.rpgd.align.taint or 0) >= 30 then marks[#marks + 1] = "Dogs growl when {they} pass" end
  if world.gear and world.gear.durability and world.gear.durability < 0.25 then marks[#marks + 1] = "{their} armour badly needs a smith" end

  return pages({ paragraph(body), paragraph(dress), paragraph(marks) })
end

---------------------------------------------------------------------------
-- Name fields
---------------------------------------------------------------------------
-- The short title: a rank by experience ("Initiate" at the start).
function Compose.Title()
  local world = ns.cache.world
  local class = world.class or ""
  local ranks = (W.RANKS_RACE[world.race or ""] or {})[class]
    or (W.RANKS_FACTION[world.faction or ""] or {})[class]
    or W.RANKS[class] or W.RANKS.default
  return ranks[band(world.level)]
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
  if top and top.standing >= 8 then return "Champion of " .. W.FactionName(top.name) end
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

function Compose.Motto()
  local rpgd = ns.cache.rpgd
  local key = rpgd and rpgd.dominant[1] or "default"
  local list = {}
  if key ~= "default" then for _, m in ipairs(W.MOTTOS[key] or {}) do list[#list + 1] = m end end
  for _, m in ipairs(W.RACE_MOTTOS[ns.cache.world.race or ""] or {}) do list[#list + 1] = m end
  if #list == 0 then list = W.MOTTOS.default end
  return U.Pick(list, seed("motto:" .. key))
end

-- An epithet, earned by doing something a lot. The most remarkable one wins.
function Compose.Nickname()
  local c = ns.cache
  local rpgd, chron = c.rpgd, c.chronicle
  local cands = {
    { "Delver of the Deep", math.max(rpgd and #rpgd.cleared or 0, chron and #chron.bosses / 2 or 0) / 5 },
    { "Grave-Cheater", deathCount(c) / 25 },
    { "the Far-Walker", math.max(rpgd and #rpgd.zones or 0, chron and chron.zones or 0) / 20 },
    { "the Relentless", (rpgd and rpgd.kills or 0) / 2500 },
    { "Friend of Many Towns", (rpgd and rpgd.met or 0) / 60 },
    { "the Unquiet", (rpgd and rpgd.insanity or 0) / 50 },
    { "the Bookish", (rpgd and #rpgd.books or 0) / 8 },
    { "Rare-Hunter", (chron and chron.rares or 0) / 15 },
  }
  table.sort(cands, function(a, b) return a[2] > b[2] end)
  if cands[1][2] >= 1 then return cands[1][1] end
  return nil
end

---------------------------------------------------------------------------
-- Everything at once
---------------------------------------------------------------------------
-- fresh: the cache was just refreshed by the caller; don't read everything twice.
-- mood: already worked out by the caller. only: the fields wanted (the story fields are
-- skipped when none of them is).
local STORY = { "traits", "bearing", "history", "physical", "title", "fulltitle", "residence", "birthplace",
  "motto", "nickname", "relationship", "ooc", "glance_ambition" }
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
  }
end
