-- How the character fights: the role they take in a group (from what they actually do, not
-- what they say), their talents, whether they fight up close, from range or with spells, the
-- school they deal most, how long their fights run and how often they have one, whether they
-- strike first, the spells they cut off, the afflictions they lift from others, the foes they
-- take out of a fight, the kinds of creature they fight most, and their weapon skills.
-- Kept per character in AutoTRPCharDB.style and read into ns.cache.style.
--
-- Light by design: the combat log handler makes two comparisons (is the player the source or
-- the target?) and is out for every other line; what's left is a table lookup and a few
-- additions. Everything else (the role a fight showed, the foe's kind, the group) is read
-- as a fight starts or ends. Other players are never kept: only counts.
local _, ns = ...

local U = ns.U
local W = ns.Words
local Style = {}
ns.Sources = ns.Sources or {}
ns.Sources.Style = Style

Style.CAP = 20             -- spells kept by name (interrupts, crowd control)
Style.CAP_FOES = 16        -- kinds of creature (the game has about a dozen)
Style.MAX_FIGHT = 600      -- a fight longer than ten minutes counts as ten

-- The combat log's spell schools (a bit mask; a mixed school counts as its lowest part).
Style.SCHOOLS = { [1] = "Physical", [2] = "Holy", [4] = "Fire", [8] = "Nature", [16] = "Frost", [32] = "Shadow", [64] = "Arcane" }
local SCHOOL_BITS = { 1, 2, 4, 8, 16, 32, 64 }

-- Abilities that only make sense for someone holding a foe's attention.
Style.THREAT = {
  ["Taunt"] = 2, ["Growl"] = 2, ["Mocking Blow"] = 2, ["Challenging Shout"] = 2, ["Challenging Roar"] = 2,
  ["Righteous Defense"] = 2, ["Hand of Reckoning"] = 2,
  ["Sunder Armor"] = 1, ["Revenge"] = 1, ["Shield Slam"] = 1, ["Shield Block"] = 1, ["Shield Wall"] = 1,
  ["Maul"] = 1, ["Swipe"] = 1, ["Holy Shield"] = 1, ["Frenzied Regeneration"] = 1, ["Demoralizing Roar"] = 1,
}

-- Crowd control the player puts on a foe, by the aura's name: the kind it is.
Style.CC = {
  ["Polymorph"] = "sheep", ["Polymorph: Pig"] = "sheep", ["Polymorph: Turtle"] = "sheep", ["Hex"] = "sheep",
  ["Sap"] = "stun", ["Gouge"] = "stun", ["Blind"] = "stun", ["Kidney Shot"] = "stun", ["Cheap Shot"] = "stun",
  ["Hammer of Justice"] = "stun", ["Repentance"] = "stun", ["Concussion Blow"] = "stun", ["Bash"] = "stun",
  ["War Stomp"] = "stun", ["Scatter Shot"] = "stun", ["Freezing Trap Effect"] = "stun", ["Intimidation"] = "stun",
  ["Fear"] = "fear", ["Psychic Scream"] = "fear", ["Howl of Terror"] = "fear", ["Intimidating Shout"] = "fear",
  ["Scare Beast"] = "fear", ["Turn Undead"] = "fear", ["Seduction"] = "fear", ["Death Coil"] = "fear",
  ["Hibernate"] = "sleep", ["Wyvern Sting"] = "sleep", ["Shackle Undead"] = "sleep", ["Banish"] = "sleep",
  ["Entangling Roots"] = "root", ["Frost Nova"] = "root",
}

-- Weapon skills, from the skill lines (Defense and Unarmed aren't what anyone fights with).
Style.WEAPONS = {
  ["Swords"] = "swords", ["Two-Handed Swords"] = "two-handed swords", ["Axes"] = "axes",
  ["Two-Handed Axes"] = "two-handed axes", ["Maces"] = "maces", ["Two-Handed Maces"] = "two-handed maces",
  ["Daggers"] = "daggers", ["Staves"] = "staves", ["Polearms"] = "polearms", ["Fist Weapons"] = "fist weapons",
  ["Bows"] = "bows", ["Guns"] = "guns", ["Crossbows"] = "crossbows", ["Thrown"] = "thrown weapons", ["Wands"] = "wands",
}

local function store()
  if not ns.char then return nil end
  local d = ns.char.style
  if type(d) ~= "table" then d = {}; ns.char.style = d end
  d.since = tonumber(d.since) or U.Now()
  for _, k in ipairs({ "fights", "group", "secs", "min", "opened", "melee", "ranged", "spell", "heal", "dmg", "taken",
    "interrupts", "cleanse", "purge", "cc" }) do
    d[k] = tonumber(d[k]) or 0
  end
  for _, k in ipairs({ "roles", "schools", "kicked", "ccBy", "foes" }) do
    if type(d[k]) ~= "table" then d[k] = {} end
  end
  return d
end
Style.Store = store

-- t[key] += n, keeping at most cap keys: a new key pushes out the least counted one.
local function bump(t, key, n, cap)
  if t[key] then t[key] = t[key] + n; return end
  local count, lo, lk = 0, nil, nil
  for k, v in pairs(t) do
    count = count + 1
    if not lo or v < lo then lo, lk = v, k end
  end
  if count >= cap then
    if lo and lo <= n then t[lk] = nil else return end
  end
  t[key] = n
end

local function top(t)
  local best, bn, total = nil, 0, 0
  for k, v in pairs(type(t) == "table" and t or {}) do
    if type(v) == "number" then
      total = total + v
      if v > bn or (v == bn and best and tostring(k) < tostring(best)) then best, bn = k, v end
    end
  end
  return best, bn, total
end
Style.Top = top

local function schoolOf(mask)
  if type(mask) ~= "number" or mask <= 0 then return nil end
  for _, bit in ipairs(SCHOOL_BITS) do
    if math.floor(mask / bit) % 2 == 1 then return Style.SCHOOLS[bit] end
  end
end
Style.SchoolOf = schoolOf

---------------------------------------------------------------------------
-- The fight now (this session only, never saved)
---------------------------------------------------------------------------
local cur = { on = false }       -- the fight going on: what the player has done in it
local party = { fights = 0, roles = {} } -- the group they're in now: the roles its fights showed
local firstHit                   -- the player's own blow just before the fight began (when the log is first)
Style.cur, Style.party = cur, party

local function partyBusy()
  if U.Call(IsInRaid) then return true end
  for i = 1, 4 do
    if U.Call(UnitAffectingCombat, "party" .. i) then return true end
  end
  return false
end

function Style.FightStarted()
  local d = store()
  if not d then return end
  cur.on, cur.start = true, U.Now()
  cur.heal, cur.dmg, cur.taken, cur.threat, cur.kicks, cur.cc = 0, 0, 0, 0, 0, 0
  cur.group = U.Call(IsInGroup) and true or false
  cur.busy = cur.group and partyBusy() or false
  cur.first = (firstHit and U.Now() - firstHit <= 2) and "me" or nil
  firstHit = nil
  -- What they're fighting, read once as it starts.
  if U.Call(UnitExists, "target") and U.Call(UnitCanAttack, "player", "target") and not U.Call(UnitIsPlayer, "target") then
    local kind = U.Plain(U.Call(UnitCreatureType, "target"))
    if kind and kind ~= "Critter" and kind ~= "Not specified" then bump(d.foes, kind, 1, Style.CAP_FOES) end
  end
end

-- What a fight showed: "healer", "tank", "damage", or nil when they did nothing telling.
function Style.Classify(f)
  if (f.threat or 0) >= 2 then return "tank" end
  if (f.heal or 0) > 0 and f.heal >= (f.dmg or 0) then return "healer" end
  if (f.dmg or 0) > 0 then
    if (f.taken or 0) >= 2 * f.dmg and (f.threat or 0) >= 1 then return "tank" end
    return "damage"
  end
  return nil
end

function Style.FightEnded()
  local d = store()
  if not d or not cur.on then return end
  cur.on = false
  local secs = math.min(Style.MAX_FIGHT, math.max(1, U.Now() - (cur.start or U.Now())))
  if cur.dmg + cur.heal + cur.taken + cur.threat == 0 then return end   -- in combat, but not in a fight
  d.fights, d.secs = d.fights + 1, d.secs + secs
  if cur.group then
    d.group = d.group + 1
    if cur.first == "me" and not cur.busy then d.opened = d.opened + 1 end
    local role = Style.Classify(cur)
    if role then
      d.roles[role] = (d.roles[role] or 0) + 1
      party.fights = party.fights + 1
      party.roles[role] = (party.roles[role] or 0) + 1
    end
  end
  if cur.kicks > (tonumber(d.bestKicks) or 0) then d.bestKicks, d.bestKicksT = cur.kicks, U.Now() end
  -- A well-played fight: several casters cut off in one go.
  if cur.kicks >= 3 and ns.Mood and U.Now() - (Style.cheeredAt or 0) > 600 then
    Style.cheeredAt = U.Now()
    local why = U.Pick(W.STYLE.MOOD, cur.kicks .. ":" .. U.Now()):gsub("{n}", U.Number(cur.kicks))
    ns.Mood.Push("satisfied", math.min(40, 16 + 6 * cur.kicks), why)
    ns.Mood.Push("smug", 10)
  end
end

ns.On("PLAYER_REGEN_DISABLED", function() Style.FightStarted() end)
ns.On("PLAYER_REGEN_ENABLED", function() Style.FightEnded() end)
ns.On("GROUP_ROSTER_UPDATE", function()
  if not U.Call(IsInGroup) then party.fights = 0; party.roles = {} end
end)

---------------------------------------------------------------------------
-- The combat log: the player's own lines only, two comparisons for everything else.
---------------------------------------------------------------------------
local SWING, RANGE, SPELL, HEAL, KICK, DISPEL, AURA, CAST = 1, 2, 3, 4, 5, 6, 7, 8
local KIND = {
  SWING_DAMAGE = SWING, RANGE_DAMAGE = RANGE, SPELL_DAMAGE = SPELL, SPELL_PERIODIC_DAMAGE = SPELL,
  SPELL_HEAL = HEAL, SPELL_PERIODIC_HEAL = HEAL, SPELL_INTERRUPT = KICK, SPELL_DISPEL = DISPEL,
  SPELL_AURA_APPLIED = AURA, SPELL_CAST_SUCCESS = CAST,
}
local FRIENDLY, HOSTILE = 0x10, 0x40
local function has(flags, bit) return type(flags) == "number" and math.floor(flags / bit) % 2 == 1 end
local function shot(name) return type(name) == "string" and (name:find("Shot") or name:find("Throw")) ~= nil end

local me
function Style.ResetGUID() me = nil end
ns.On("PLAYER_ENTERING_WORLD", function() me = nil end)

local function dealt(d, amount, mask, how)
  if type(amount) ~= "number" or amount <= 0 then return end
  if not cur.on then firstHit = U.Now(); return end
  if not cur.first then cur.first = "me" end
  cur.dmg = cur.dmg + amount
  d.dmg, d[how] = d.dmg + amount, d[how] + amount
  local school = schoolOf(mask)
  if school then d.schools[school] = (d.schools[school] or 0) + amount end
end

function Style.OnCombatLog(_, sub, _, src, _, _, _, dest, _, destFlags, _, a12, a13, a14, a15, a16)
  if src ~= me and dest ~= me then
    if me then return end
    me = U.Call(UnitGUID, "player")
    if not me or (src ~= me and dest ~= me) then return end
  end
  local k = KIND[sub]
  if not k then return end
  local d = ns.char and ns.char.style
  if type(d) ~= "table" or type(d.schools) ~= "table" then d = store(); if not d then return end end
  if src ~= me then
    -- Struck by something.
    if not cur.on or (k ~= SWING and k ~= RANGE and k ~= SPELL) then return end
    local amount = k == SWING and a12 or a15
    if type(amount) == "number" and amount > 0 then
      cur.taken, d.taken = cur.taken + amount, d.taken + amount
      if not cur.first then cur.first = "them" end
    end
    return
  end
  if k == SWING then dealt(d, a12, 1, "melee")
  elseif k == RANGE then dealt(d, a15, a14, "ranged")
  elseif k == SPELL then
    if dest ~= me then dealt(d, a15, a14, (a14 == 1 and not shot(a13)) and "melee" or (a14 == 1 and "ranged" or "spell")) end
  elseif k == HEAL then
    if dest ~= me and cur.on and type(a15) == "number" then
      local done = a15 - (tonumber(a16) or 0)
      if done > 0 then cur.heal, d.heal = cur.heal + done, d.heal + done end
    end
  elseif k == KICK then
    d.interrupts = d.interrupts + 1
    if type(a13) == "string" then bump(d.kicked, a13, 1, Style.CAP) end
    if cur.on then cur.kicks = cur.kicks + 1 end
  elseif k == DISPEL then
    if dest == me then return end
    if has(destFlags, HOSTILE) then d.purge = d.purge + 1
    elseif has(destFlags, FRIENDLY) then d.cleanse = d.cleanse + 1 end
  elseif k == AURA then
    if a15 == "DEBUFF" and dest ~= me and Style.CC[a13] then
      d.cc = d.cc + 1
      bump(d.ccBy, Style.CC[a13], 1, Style.CAP)
      if cur.on then cur.cc = cur.cc + 1 end
    end
  elseif k == CAST then
    local t = cur.on and Style.THREAT[a13]
    if t then cur.threat = cur.threat + t end
  end
end
ns.On("COMBAT_LOG_EVENT_UNFILTERED", function()
  Style.OnCombatLog(U.CallAll(_G.CombatLogGetCurrentEventInfo))
end)

-- Minutes in the world, for fights an hour (away from the keyboard doesn't count).
function Style.Minute()
  local d = store()
  if d and not U.Call(UnitIsAFK, "player") then d.min = d.min + 1 end
end

---------------------------------------------------------------------------
-- Talents and weapon skills, read from the game when asked (out of the combat log)
---------------------------------------------------------------------------
-- Points in each talent tree: { { name, points }, ... } in the game's order, or nil.
-- Classic returns (name, icon, points, ...); later clients (id, name, description, icon, points, ...).
function Style.Talents()
  local n = U.Call(_G.GetNumTalentTabs)
  if type(n) ~= "number" or n < 1 then return nil end
  local out = {}
  for i = 1, math.min(n, 4) do
    local a, b, c = U.Call(_G.GetTalentTabInfo, i)
    local name, pts
    if type(a) == "string" then
      name, pts = a, c
    elseif type(b) == "string" then
      name = b
      pts = U.Call(function(tab) return (select(5, _G.GetTalentTabInfo(tab))) end, i)
    end
    out[#out + 1] = { name = U.Plain(name), points = type(pts) == "number" and pts or 0 }
  end
  return out
end

-- The main tree: { name, points, second, secondPoints, total, split = "5/21/0" }, or nil.
function Style.Spec()
  local trees = Style.Talents()
  if not trees then return nil end
  local best, second, total, split = nil, nil, 0, {}
  for _, t in ipairs(trees) do
    total = total + t.points
    split[#split + 1] = tostring(t.points)
    if t.name and t.points > 0 then
      if not best or t.points > best.points then best, second = t, best
      elseif not second or t.points > second.points then second = t end
    end
  end
  if not best then return nil end
  return { name = best.name, points = best.points, second = second and second.name, secondPoints = second and second.points or 0,
    total = total, split = table.concat(split, "/") }
end

-- Weapon skills, best first: { { name = "maces", rank, max } }.
function Style.Weapons()
  local n = tonumber((U.Call(_G.GetNumSkillLines))) or 0
  local out = {}
  for i = 1, math.min(n, 80) do
    local name, header, _, rank, _, _, max = U.Call(_G.GetSkillLineInfo, i)
    name = U.Plain(name)
    if not header and name and Style.WEAPONS[name] and type(rank) == "number" and rank > 0 then
      out[#out + 1] = { name = Style.WEAPONS[name], rank = rank, max = type(max) == "number" and max or nil }
    end
  end
  table.sort(out, function(a, b) if a.rank ~= b.rank then return a.rank > b.rank end return a.name < b.name end)
  return out
end

---------------------------------------------------------------------------
-- Reading it back: a fresh table each time.
---------------------------------------------------------------------------
local function share(n, total) return total > 0 and n / total or 0 end

function Style.Read()
  local d = store()
  if not d then return nil end
  local o = { since = d.since, fights = d.fights, group = d.group, opened = d.opened, interrupts = d.interrupts,
    cleanse = d.cleanse, purge = d.purge, cc = d.cc, heal = d.heal, dmg = d.dmg, taken = d.taken, minutes = d.min,
    bestKicks = tonumber(d.bestKicks) or 0 }
  o.avgSecs = d.fights > 0 and d.secs / d.fights or 0
  o.perHour = d.min >= 60 and d.fights / (d.min / 60) or nil
  o.openShare = share(d.opened, d.group)
  -- The role their group fights show, and how often.
  local role, rn, rt = top(d.roles)
  o.roles, o.role, o.roleN, o.roleShare = {}, role, rn, share(rn, rt)
  for k, v in pairs(d.roles) do o.roles[k] = v end
  local second, sn = nil, 0
  for k, v in pairs(d.roles) do if k ~= role and v > sn then second, sn = k, v end end
  o.role2, o.role2Share = second, share(sn, rt)
  -- Up close, from range or with spells.
  local styles = { melee = d.melee, ranged = d.ranged, spell = d.spell }
  local how, hn, ht = top(styles)
  o.style, o.styleShare = how, share(hn, ht)
  local school, scn, sct = top(d.schools)
  o.school, o.schoolShare = school, share(scn, sct)
  o.kickTop = (top(d.kicked))
  o.ccTop = (top(d.ccBy))
  local foe, fn, ft = top(d.foes)
  o.foe, o.foeN, o.foeShare = foe, fn, share(fn, ft)
  -- The group they're in now.
  local pr, pn, pt = top(party.roles)
  o.party = { fights = party.fights, role = pr, share = share(pn, pt) }
  o.spec = Style.Spec()
  o.weapons = Style.Weapons()
  return o
end

---------------------------------------------------------------------------
-- What it means, in words (Compose.lua calls these; the words are W.STYLE's)
---------------------------------------------------------------------------
local function seed(key) return (ns.char and ns.char.seedName or "") .. ":style:" .. key end
local function pick(list, key) return type(list) == "table" and #list > 0 and U.Pick(list, seed(key)) or nil end

-- The role, said plainly: "healer", "tank", or for damage how they deal it ("melee",
-- "ranged", "spell"). from: a Read() table. Nil until enough fights show it.
function Style.RoleKey(st, minFights, minShare)
  if not st or (st.group or 0) < (minFights or 15) or not st.role or st.roleShare < (minShare or 0.55) then return nil end
  if st.role == "damage" then return st.style end
  return st.role
end

-- "Healer, mostly", "Healer and spellcaster, by turns", "Defender, nearly always".
function Style.RoleStat(st)
  if not st or st.group < 10 or not st.role then return nil end
  local words = W.STYLE.ROLE
  local function word(role) return words[role == "damage" and (st.style or "melee") or role] end
  local main = word(st.role)
  if not main then return nil end
  if st.roleShare >= 0.85 then return main .. ", nearly always" end
  if st.roleShare >= 0.6 then return main .. ", mostly" end
  local other = st.role2 and st.role2Share >= 0.25 and word(st.role2)
  if other and other ~= main then return main .. " and " .. other:lower() .. ", by turns" end
  return main .. ", more often than not"
end

-- "Holy, 31 points", "Holy, 31 points, and 20 in Discipline".
function Style.SpecStat(st)
  local s = st and st.spec
  if not s or not s.name or s.points < 1 then return nil end
  local out = s.name .. ", " .. s.points .. " " .. U.Plural(s.points, "point")
  if s.second and s.secondPoints >= 10 then out = out .. ", and " .. s.secondPoints .. " in " .. s.second end
  return out
end

-- Personality: up to k lines on how they fight, strongest first, each backed by the counts.
function Style.TemperLines(st, k)
  if not st or st.fights < 20 then return {} end
  local T = W.STYLE.TEMPER
  local cands = {}
  local function add(score, key) if T[key] then cands[#cands + 1] = { score = score, key = key } end end
  local roles = st.roles or {}
  local heals, hurts = roles.healer or 0, roles.damage or 0
  if st.group >= 15 and heals >= 0.3 * st.group and hurts >= 0.3 * st.group then add(3, "hybrid")
  else
    local role = Style.RoleKey(st)
    if role == "healer" or role == "tank" then add(3, role) end
  end
  local spellSchool = st.school and st.school ~= "Physical" and st.schoolShare >= 0.5 and st.dmg >= 5000
  if spellSchool and st.style == "spell" then add(2.6, st.school)
  elseif st.style and st.styleShare >= 0.65 and st.dmg >= 5000 then add(2, st.style) end
  if st.school == "Holy" and spellSchool and st.style ~= "spell" then add(1.5, "Holy") end
  if st.interrupts >= 15 then add(2.4, "interrupt") end
  if st.opened >= 10 and st.openShare >= 0.4 then add(1.8, "opener") end
  if st.cleanse >= 25 then add(1.7, "cleanse") end
  if st.cc >= 25 then add(1.6, "cc") end
  if st.fights >= 50 then
    if st.avgSecs <= 10 then add(1.2, "quick") elseif st.avgSecs >= 35 then add(1.2, "long") end
  end
  if st.perHour and st.minutes >= 300 and st.perHour >= 25 then add(1, "often")
  elseif st.perHour and st.minutes >= 600 and st.perHour <= 2 then add(1, "seldom") end
  table.sort(cands, function(a, b) if a.score ~= b.score then return a.score > b.score end return a.key < b.key end)
  local out = {}
  for i = 1, math.min(k or 2, #cands) do out[i] = pick(T[cands[i].key], "temper:" .. cands[i].key) end
  return out
end

-- History's older record: clauses after "{they've}".
function Style.HistoryClauses(st, level)
  if not st then return {} end
  local H = W.STYLE.HISTORY
  local out = {}
  local role = st.group >= 25 and st.roleShare >= 0.5 and st.role
  if role then out[#out + 1] = pick(H[role], "hist:" .. role) end
  if st.interrupts >= 50 then out[#out + 1] = (pick(H.interrupt, "hist:kick"):gsub("{n}", U.Roughly(st.interrupts))) end
  if st.cleanse >= 50 then out[#out + 1] = (pick(H.cleanse, "hist:cleanse"):gsub("{n}", U.Roughly(st.cleanse))) end
  local foes = st.foe and st.foeN >= 100 and st.foeShare >= 0.35 and W.STYLE.FOES[st.foe]
  if foes then out[#out + 1] = (pick(H.foe, "hist:foe"):gsub("{foes}", foes)) end
  local w = st.weapons and st.weapons[1]
  if w and type(level) == "number" and level >= 20 and w.rank >= 5 * level - 5 then
    local list = { w.name }
    local w2 = st.weapons[2]
    if w2 and w2.rank >= 5 * level - 5 then list[2] = w2.name end
    out[#out + 1] = (pick(H.weapons, "hist:weapons"):gsub("{list}", U.Join(list)))
  end
  return out
end

-- Physical: how they carry themselves in a fight, once enough fights show it.
function Style.Bearing(st)
  if not st or st.fights < 30 then return nil end
  local key = Style.RoleKey(st, 15, 0.6)
  if not key and st.styleShare >= 0.65 and st.dmg >= 5000 then key = st.style end
  return key and pick(W.STYLE.PHYSICAL[key], "phys:" .. key) or nil
end

-- The Company glance: the part they play in the group they're in now ("the group's healer").
-- The fights in this group say, else (once there are enough) the role they usually take.
function Style.PartyClause(st)
  if not st then return nil end
  local key
  local p = st.party
  if p and p.fights >= 3 and p.role and p.share >= 0.6 then key = p.role == "damage" and st.style or p.role
  elseif p and p.fights < 3 then key = Style.RoleKey(st, 20, 0.7) end
  return key and pick(W.STYLE.COMPANY[key], "co:" .. key) or nil
end

ns.Listen("LOGIN", function()
  if not store() then return end
  me = U.Call(UnitGUID, "player")
  ns.Ticker(60, Style.Minute)
end)
