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
  if not (s:find("[%.!%?]$") or s:find("[%.!%?]\"$")) then s = s .. "." end
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

function Compose.Currently(mood)
  local world = ns.cache.world
  local text = mood.adj
  if mood.also then text = text .. " and " .. mood.also end
  text = text .. ", " .. ns.World.Activity(world, seed("act:" .. (world.zone or "") .. (world.subzone or "")))
  local tod = ns.World.TimeOfDay(world)
  if tod then text = text .. " " .. tod end
  text = text .. "."
  local intent = Compose.Intent()
  if intent then text = text .. " " .. sentence(intent) end
  return text
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

local function lowerFirst(s) return (s:gsub("^%u", string.lower)) end

function Compose.LatelyGlance()
  local c = ns.cache
  local rpgd, chron, world = c.rpgd, c.chronicle, c.world
  local cands = {}
  local function add(t, prio, g) cands[#cands + 1] = { t = t or 0, prio = prio, g = g } end

  local death = rpgd and rpgd.deaths[#rpgd.deaths]
  local cdeath = chron and chron.deaths[1]
  if cdeath and (not death or cdeath.t > death.t) then death = cdeath end
  if death and within(death.t, 2 * 86400) then
    local tx = "Came back from the brink" .. (death.zone and (" in " .. death.zone) or "") .. " not long ago"
    if death.killer then tx = tx .. ", and doesn't talk about " .. death.killer end
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
      TX = "Only lately came back up out of " .. U.Mid(cleared.name) .. ", and has stories to prove it." })
  end
  local thread = rpgd and rpgd.threads[1]
  if thread and within(thread.t, 3 * 86400) and THREAD_PHRASE[thread.state] then
    add(thread.t, 1, { TI = thread.state == "resolved" and "Loose Ends Tied" or "Caught Up in Something",
      IC = "INV_Misc_Note_02", TX = U.Pick(THREAD_PHRASE[thread.state], seed(thread.id)):format(lowerFirst(thread.title)) })
  end
  local zone = rpgd and rpgd.zones[#rpgd.zones]
  if zone and within(zone.t, 86400) and #rpgd.zones > 2 then
    add(zone.t, 0, { TI = "New in Town", IC = "INV_Misc_Map_01",
      TX = "Only recently arrived in " .. U.Mid(zone.name) .. ", and still finding the way around." })
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
  return { TI = "Lately", IC = "INV_Misc_Map_01", TX = U.Pick({ "Keeping busy around " .. where .. ".", "Has been working " .. where .. " for a while now." }, seed("lately" .. where)) }
end

function Compose.CompanyGlance()
  local c = ns.cache
  local world, sd, rpgd = c.world, c.sd, c.rpgd
  local n = world.groupSize or 0
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
    local tx = U.Cap((ns.Sources.RPGD.Tier(town.value).phrase:gsub("{town}", town.name)))
    if friend then tx = tx .. ", and on good terms with " .. friend.name end
    return { TI = "A Known Face", IC = "INV_Misc_Bag_11", TX = tx .. "." }
  end
  if friend then
    return { TI = "A Known Face", IC = "INV_Misc_Bag_11", TX = "On good terms with " .. friend.name .. "." }
  end
  if world.pet and (world.class == "HUNTER" or world.class == "WARLOCK") then
    return { TI = "Travels Light", IC = "Ability_Hunter_BeastCall",
      TX = "Travels with no one but " .. world.pet .. (world.petKind and (" the " .. world.petKind:lower()) or "") .. "." }
  end
  local reserved = rpgd and ((rpgd.traits.reserved or 0) >= 3)
  return { TI = "Travels Alone", IC = "Spell_Shadow_Teleport",
    TX = reserved and "Travels alone, and seems to prefer it." or "Travels alone these days, though not by choice, perhaps." }
end

function Compose.AmbitionGlance()
  local c = ns.cache
  local rpgd, chron, world = c.rpgd, c.chronicle, c.world
  if chron and ns.db.chronicleGoals and chron.goals[1] then
    return { TI = "Ambition", IC = "INV_Misc_Book_11",
      TX = "Talks often of one thing above all: " .. U.Truncate(chron.goals[1].text, 120) .. "." }
  end
  for _, t in ipairs(rpgd and rpgd.threads or {}) do
    if t.state == "unfolding" or t.state == "stirring" then
      return { TI = "Unfinished Business", IC = "INV_Misc_Note_02",
        TX = "Wants to get to the bottom of " .. lowerFirst(t.title) .. "." }
    end
  end
  local list = W.AMBITIONS[world.class or ""] or W.AMBITIONS.default
  return { TI = "Ambition", IC = "INV_Misc_Book_11", TX = U.Pron(U.Pick(list, seed("ambition"))) }
end

-- What's visible on them: the most telling marks, else what they wear and carry.
local function kit(world, short)
  local g = world.gear or {}
  local parts = {}
  local dress = g.armor and ((W.WEAR_QUALITY[g.quality or 1] or "serviceable") .. " " .. g.armor)
  if dress then parts[#parts + 1] = "Dressed in " .. dress .. (g.tabard and (" under the " .. g.tabard) or "") end
  local arms = {}
  if g.main then arms[#arms + 1] = g.main end
  if g.off and g.off ~= g.main then arms[#arms + 1] = g.off end
  if g.ranged and not short then arms[#arms + 1] = g.ranged end
  if #arms > 0 then parts[#parts + 1] = (#parts > 0 and "with " or "Carries ") .. U.Join(arms) .. " at hand" end
  if #parts == 0 then return nil end
  return table.concat(parts, ", ") .. "."
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
    mark(7, "Haunted Eyes", "Eyes that never quite settle, as if following something no one else can see.", "Spell_Shadow_Possession")
  end
  if rpgd and (rpgd.align.taint or 0) >= 30 then
    mark(6, "Something Wrong", "A faint wrongness hangs about {them}, like smoke that won't clear.", "Spell_Shadow_ShadowWordPain")
  end
  local g = world.gear or {}
  if g.durability and g.durability < 0.25 then
    mark(5, "Battered Kit", "Armour dented and split at the seams, held together with twine and hope.", "INV_Hammer_20")
  end
  local finest = g.finest or (c.chronicle and c.chronicle.appearance and c.chronicle.appearance.finest)
  if finest and finest.name and finest.quality >= 4 then
    mark(4, "Remarkable Gear", "Hard to miss: " .. finest.name .. ", the sort of thing people tell stories about.", "INV_Misc_Gem_Pearl_04")
  end
  local deaths = deathCount(c)
  if deaths >= 10 then
    mark(3, "Old Scars", "Scars on top of scars. Has clearly come back from worse than this.", "Ability_Warrior_BloodFrenzy")
  end
  table.sort(marks, function(a, b) return a.prio > b.prio end)
  if marks[1] then
    local m = marks[1]
    return { TI = m.TI, TX = m.TX, IC = m.IC }
  end
  local k = kit(world, true)
  if k then return { TI = "Kit", IC = "INV_Chest_Chain_05", TX = k } end
  return { TI = "Plainly Dressed", IC = "INV_Shirt_05", TX = "Nothing about the clothes says much, which may be the point." }
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
local function opinions(rpgd, max)
  local out = {}
  for _, o in ipairs(rpgd.opinions) do
    local phrase
    if o.topic == "peace" then
      phrase = W.PEACE[o.stance]
    else
      local verb = W.STANCES[o.stance]
      local topic = W.TOPICS[o.topic] or (ns.RPGDNames.towns[o.topic]) or U.Humanize(o.topic)
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
  local paras = {}
  local noun = W.CLASS_NOUN[world.class or ""] or "wanderer"
  local season = seasoned(world.level, "seasoned")

  if not rpgd then
    return sentence(name .. " is " .. article(season) .. " " .. noun .. ", still making a name.")
  end
  local adjs = {}
  for _, t in ipairs(rpgd.dominant) do adjs[#adjs + 1] = W.TRAIT_ADJ[t] end
  local first = name .. " is " .. (#adjs > 0 and (U.Join(adjs) .. ", ") or "") .. article(season) .. " " .. noun
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
  paras[#paras + 1] = sentence(first)

  local plain = Compose.PlainAlignment(rpgd.align)
  paras[#paras + 1] = #plain > 0 and ("By most accounts: " .. U.Join(plain) .. ".") or "By most accounts: hard to read, neither saint nor villain."

  local ops = opinions(rpgd, 3)
  if #ops > 0 then paras[#paras + 1] = sentence(name .. " " .. U.Join(ops)) end

  if (rpgd.align.taint or 0) >= 30 then
    paras[#paras + 1] = sentence("There is something faintly wrong about " .. name .. ", a taint that priests and dogs both seem to notice")
  end
  if (rpgd.insanity or 0) >= 40 then
    paras[#paras + 1] = sentence("Lately " .. name .. " talks to empty corners, and sometimes the corners seem to answer")
  end
  local hooks = Compose.Hooks()
  if #hooks > 0 then paras[#paras + 1] = U.Pron("Ask {them} about " .. U.Join(hooks) .. ".") end
  return table.concat(paras, "\n\n")
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

-- Conversation starters for other players: things this character has a story about.
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
-- About: History
---------------------------------------------------------------------------
local function profWord(rank)
  for _, r in ipairs(W.PROF_RANK) do if rank >= r.min then return r.word end end
  return "an apprentice"
end

function Compose.History()
  local c = ns.cache
  local rpgd, chron, sd, world = c.rpgd, c.chronicle, c.sd, c.world
  local name = firstName()
  local paras = {}

  -- Where it began
  if rpgd and rpgd.origin and rpgd.origin.name then
    local p = rpgd.origin.name .. "."
    if rpgd.origin.blurb then p = p .. " In " .. U.Pron("{their}") .. " own words: \"" .. rpgd.origin.blurb .. "\"" end
    paras[#paras + 1] = p
  else
    local home = W.RACE_HOME[world.race or ""]
    if home then paras[#paras + 1] = sentence(name .. " comes from " .. home) end
  end
  if (world.level or 1) < 10 then
    paras[#paras + 1] = sentence(name .. " is new to the road, and the world hasn't had its say yet")
  end

  -- The road
  local zones = rpgd and rpgd.zones or {}
  local zoneCount = math.max(#zones, chron and chron.zones or 0)
  if zoneCount >= 3 and zones[1] then
    local p = "Since setting out from " .. zones[1].name .. ", " .. name .. " has walked " .. U.Number(zoneCount) .. " lands"
    local last = zones[#zones]
    if last and last.name ~= zones[1].name then p = p .. ", most lately " .. U.Mid(last.name) end
    if chron and chron.dungeons >= 2 then p = p .. ", and gone down into " .. U.Number(chron.dungeons) .. " dungeons" end
    local since = math.min(zones[1].t or math.huge, chron and chron.created or math.huge)
    local weeks = since < math.huge and math.floor((U.Now() - since) / 604800) or 0
    if weeks >= 2 then
      p = p .. ". That was " .. (weeks >= 9 and (U.Number(math.floor(weeks / 4.3)) .. " months") or (U.Number(weeks) .. " weeks")) .. " ago"
    end
    paras[#paras + 1] = sentence(p)
  end
  if rpgd and rpgd.homeInn then
    local function inn(n) return n:find("^The ") and U.Mid(n) or (ns.World.IsInn(n) and ("the " .. n) or n) end
    local p = "When there's a bed to be had, it's usually at " .. inn(rpgd.homeInn)
    if rpgd.homePrev and rpgd.homePrev ~= rpgd.homeInn and within(rpgd.homeSince, 14 * 86400) then
      p = p .. ", having lately given up a room at " .. inn(rpgd.homePrev)
    end
    paras[#paras + 1] = sentence(p)
  end

  -- People and places
  if rpgd then
    local friends = {}
    for i = 1, math.min(2, #rpgd.friends) do friends[i] = rpgd.friends[i].name end
    local rival = rpgd.rivals[1] and rpgd.rivals[1].name
    if #friends > 0 then
      local p = name .. " counts " .. U.Join(friends) .. " among {their} friends"
      if rival then p = p .. ", and has made no friend of " .. rival end
      paras[#paras + 1] = sentence(p)
    elseif rival then
      paras[#paras + 1] = sentence(name .. " has made no friend of " .. rival)
    end
    local good, bad = {}, nil
    for _, t in ipairs(rpgd.towns) do
      if t.value >= 10 and #good < 2 then good[#good + 1] = (ns.Sources.RPGD.Tier(t.value).phrase:gsub("{town}", t.name)) end
    end
    local worst = rpgd.towns[#rpgd.towns]
    if worst and worst.value <= -20 then bad = (ns.Sources.RPGD.Tier(worst.value).phrase:gsub("{town}", worst.name)) end
    if #good > 0 then
      paras[#paras + 1] = sentence(U.Join(good) .. (bad and (", though " .. bad) or ""))
    elseif bad then
      paras[#paras + 1] = sentence(bad)
    end
  end
  if sd then
    local bits = {}
    if ns.db.nameFriends and #sd.friends > 0 then
      local f = sd.friends[1]
      if f.relationship then
        bits[#bits + 1] = "rides with " .. f.name .. ", {their} " .. f.relationship:lower() .. (sd.friends[2] and (", and with " .. sd.friends[2].name) or "")
      else
        local names = {}
        for i = 1, math.min(3, #sd.friends) do names[i] = sd.friends[i].name end
        bits[#bits + 1] = "has fallen in with " .. U.Join(names)
      end
    end
    if sd.recentPeople >= 4 then bits[#bits + 1] = "has fought alongside " .. U.Number(sd.recentPeople) .. " others this past week" end
    if #sd.foes > 0 then bits[#bits + 1] = "has made " .. (#sd.foes == 1 and "an enemy" or "a few enemies") .. " on the road" end
    if #bits > 0 then paras[#paras + 1] = sentence(name .. " " .. U.Join(bits)) end
  end

  -- Banners and reputations
  local ties = {}
  if world.guild then
    local g = world.guild:find("^The ") and U.Mid(world.guild) or world.guild
    ties[#ties + 1] = "wears the colours of " .. g .. (world.guildRank and (", ranked " .. world.guildRank:lower()) or "")
  end
  if world.pvpRank then ties[#ties + 1] = "holds the rank of " .. world.pvpRank .. " in the " .. (world.faction or "faction") .. "'s army" end
  local byWord = {}
  for _, f in ipairs(world.factions or {}) do
    byWord[f.word] = byWord[f.word] or {}
    if #byWord[f.word] < 2 then table.insert(byWord[f.word], W.FactionName(f.name)) end
  end
  local reps = {}
  for _, w in ipairs({ "Exalted", "Revered", "Honored" }) do
    if byWord[w] then reps[#reps + 1] = w:lower() .. " by " .. U.Join(byWord[w]) end
    if #reps >= 2 then break end
  end
  if #reps > 0 then ties[#ties + 1] = "is " .. U.Join(reps) end
  if #ties > 0 then paras[#paras + 1] = sentence(name .. " " .. U.Join(ties)) end

  -- Deeds
  local deeds = {}
  if rpgd then
    for _, t in ipairs(rpgd.threads) do
      if t.state == "resolved" then deeds[#deeds + 1] = "saw " .. lowerFirst(t.title) .. " through to the end"
      elseif t.state == "soured" then deeds[#deeds + 1] = "watched " .. lowerFirst(t.title) .. " go sour" end
      if #deeds >= 2 then break end
    end
    local places = {}
    for i = 1, math.min(3, #rpgd.cleared) do places[i] = U.Mid(rpgd.cleared[i].name) end
    if #places > 0 then deeds[#deeds + 1] = "came back alive out of " .. U.Join(places) end
  end
  if chron then
    if #chron.bosses >= 3 then deeds[#deeds + 1] = "helped bring down " .. U.Number(#chron.bosses) .. " foes the bards would know by name"
    elseif chron.bosses[1] then deeds[#deeds + 1] = "was there when " .. chron.bosses[1].name .. " fell" end
    if chron.rares >= 5 then deeds[#deeds + 1] = "has tracked down " .. U.Number(chron.rares) .. " rare beasts" end
  end
  if #deeds > 0 then paras[#paras + 1] = sentence(name .. " " .. U.Join(deeds)) end

  local work = {}
  if chron and chron.questsDone >= 25 then work[#work + 1] = "has done honest work for more people than {they} can name" end
  local profs = (chron and #chron.professions > 0 and chron.professions) or world.professions or {}
  for i = 1, math.min(2, #profs) do
    local p = profs[i]
    if p.rank >= 50 then work[#work + 1] = "works " .. p.name:lower() .. " with the hands of " .. profWord(p.rank) end
  end
  if rpgd and rpgd.kills >= 500 then work[#work + 1] = "has put down more beasts than {they} care to count" end
  if rpgd and rpgd.grudge and rpgd.grudge.n >= 40 then
    work[#work + 1] = "has thinned the ranks of the " .. Compose.Plural(rpgd.grudge.name) .. " considerably"
  end
  if #work > 0 then paras[#paras + 1] = sentence(name .. " " .. U.Join(work)) end

  -- Learning
  if rpgd and #rpgd.books >= 2 then
    local titles = {}
    for i = 1, math.min(2, #rpgd.books) do titles[i] = "\"" .. rpgd.books[i].title .. "\"" end
    local p = "A reader, too: " .. name .. " has worked through " .. U.Join(titles)
    if #rpgd.books > 2 then p = p .. " and " .. U.Number(#rpgd.books - 2) .. " more" end
    paras[#paras + 1] = sentence(p)
  end
  if rpgd and rpgd.topics >= 15 then
    paras[#paras + 1] = sentence(name .. " has an ear for gossip and knows more about local affairs than is strictly healthy")
  end

  -- Close calls
  local deaths = deathCount(c)
  if deaths > 0 then
    local firstDeath = rpgd and rpgd.deaths[1] or (chron and chron.deaths[#chron.deaths])
    local p = name .. " has died " .. U.Times(deaths) .. " and come back each time"
    if firstDeath and firstDeath.killer then
      p = p .. "; the first time to " .. firstDeath.killer .. (firstDeath.zone and (" in " .. firstDeath.zone) or "")
    end
    paras[#paras + 1] = sentence(p)
  end

  -- These past days, from the mood journal
  local days = ns.Mood.RecentDays(3)
  local bits = {}
  for _, d in ipairs(days) do
    local m = d.mood and W.MOODS[d.mood] and W.MOODS[d.mood].title:lower()
    if m or d.zone then
      bits[#bits + 1] = (m or "about") .. (d.zone and (m and " in " or " ") .. U.Mid(d.zone) or "") .. " " .. d.label
    end
  end
  if #bits >= 2 then paras[#paras + 1] = "These past days: " .. U.Join(bits) .. "." end

  -- A page from the diary
  if rpgd and ns.db.diaryExcerpt and rpgd.lastEntry and rpgd.lastEntry.text then
    paras[#paras + 1] = "From " .. U.Pron("{their}") .. " journal: \"" .. U.Truncate(rpgd.lastEntry.text, 280) .. "\""
  end

  if #paras == 0 then return nil end
  return table.concat(paras, "\n\n")
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
  local race = (U.Call(UnitRace, "player") or "traveller"):lower()
  local noun = W.CLASS_NOUN[world.class or ""] or "wanderer"
  local paras = {}
  local p = article(seasoned(world.level, "seasoned")) .. " " .. race .. " " .. noun
  local build = physique(c)
  if build then p = p .. ", " .. build end
  paras[#paras + 1] = sentence(p)

  local k = kit(world, false)
  if k then paras[#paras + 1] = k end
  local app = c.chronicle and c.chronicle.appearance
  local finest = (world.gear and world.gear.finest) or (app and app.finest)
  if finest and finest.name then
    local where = W.SLOT_NOUN[finest.slot] or "gear"
    paras[#paras + 1] = sentence("The eye goes to " .. U.Pron("{their} ") .. where .. ": " .. finest.name)
  end

  local marks = {}
  local deaths = deathCount(c)
  if deaths >= 10 then marks[#marks + 1] = "scars on top of scars"
  elseif deaths >= 3 then marks[#marks + 1] = "a few scars worth asking about" end
  if c.rpgd and (c.rpgd.insanity or 0) >= 30 then marks[#marks + 1] = "eyes that never quite settle" end
  if c.rpgd and (c.rpgd.align.taint or 0) >= 30 then marks[#marks + 1] = "a faint wrongness that clings like smoke" end
  if world.gear and world.gear.durability and world.gear.durability < 0.25 then marks[#marks + 1] = "armour badly in need of a smith" end
  if #marks > 0 then paras[#paras + 1] = sentence("Marked by " .. U.Join(marks)) end
  return table.concat(paras, "\n\n")
end

---------------------------------------------------------------------------
-- Name fields
---------------------------------------------------------------------------
-- The short title: a rank by experience ("Initiate" at the start).
function Compose.Title()
  local world = ns.cache.world
  local ranks = W.RANKS[world.class or ""] or W.RANKS.default
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
  return U.Pick(W.MOTTOS[key] or W.MOTTOS.default, seed("motto:" .. key))
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
    ooc = Compose.OOCNote(),
    birthplace = Compose.Birthplace(),
    motto = Compose.Motto(),
    nickname = Compose.Nickname(),
  }
end
