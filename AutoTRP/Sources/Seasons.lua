-- Auto TRP's record of the character's time: their sessions (when they start and end, how
-- long they run), the hours of the game's clock they're usually abroad in, the real days of
-- the week they turn up, the longest session and the longest absence (and the return after
-- it), runs of days played, the day Auto TRP first saw them (or the earliest record any
-- source has), anniversaries of the road and of each new rank, the festivals they actually
-- took part in (a holiday buff, quest, item or place seen while the festival was on), visits
-- to the Darkmoon Faire, and how each month went, from the mood journal (Mood.lua keeps the
-- days; they're folded in here by month). Kept per character in AutoTRPCharDB.seasons and
-- read into ns.cache.seasons. Only game events and game APIs: no other addon is needed.
--
-- Light by design: a ticker once a minute adds a few numbers; auras are only looked at out
-- of a fight and only while a festival is on (or near the faire); every list is capped.
local _, ns = ...

local U = ns.U
local S = {}
ns.Sources = ns.Sources or {}
ns.Sources.Seasons = S

S.TICK = 60
S.KEEP_SESSIONS = 30
S.KEEP_FESTS = 24
S.KEEP_MONTHS = 14
S.KEEP_TOLD = 30
S.AWAY = 3 * 86400     -- a gap this long is an absence, and coming back is news

local DAY = 86400

-- The festivals, by the calendar (month, day; inclusive), and the words that show the
-- character took part: in a buff, a quest, an item looted or the place they're in.
S.FESTIVALS = {
  { key = "winterveil", name = "Winter Veil", from = { 12, 15 }, to = { 1, 2 },
    signs = { "Winter Veil", "Greatfather Winter", "Smokywood", "Mistletoe", "Snowball", "Gingerbread", "Holly", "Winter's Kiss" } },
  { key = "lunar", name = "the Lunar Festival", from = { 1, 20 }, to = { 2, 3 },
    signs = { "Lunar", "Elder", "Ancestry", "Festival Firecracker", "Red Envelope", "Moonglade" } },
  { key = "love", name = "Love is in the Air", from = { 2, 7 }, to = { 2, 20 },
    signs = { "Love is in the Air", "Love Token", "Lovely", "Adoration", "Amorous", "Cologne", "Perfume", "Bouquet" } },
  { key = "noblegarden", name = "Noblegarden", from = { 4, 1 }, to = { 4, 14 },
    signs = { "Noblegarden", "Brightly Colored", "Spring Robes", "Spring Circlet", "Bunny" } },
  { key = "children", name = "Children's Week", from = { 5, 1 }, to = { 5, 7 },
    signs = { "Children's Week", "Orphan", "Matron" } },
  { key = "midsummer", name = "Midsummer", from = { 6, 21 }, to = { 7, 5 },
    signs = { "Midsummer", "Bonfire", "Fire Festival", "Ribbon Pole", "Ribbon Dance", "Festival of Fire", "Flame Warden", "Flame Keeper" } },
  { key = "harvest", name = "the Harvest Festival", from = { 9, 12 }, to = { 9, 19 },
    signs = { "Harvest Festival", "Harvest Fruit", "Harvest Boar", "Harvest Fish", "Harvest Bread", "Harvest Nectar" } },
  { key = "brewfest", name = "Brewfest", from = { 9, 20 }, to = { 10, 4 },
    signs = { "Brewfest", "Brewmaster", "Ram Racing", "Brew of the Month" } },
  { key = "hallowsend", name = "Hallow's End", from = { 10, 18 }, to = { 11, 1 },
    signs = { "Hallow", "Wickerman", "Pumpkin", "Tricked or Treated", "Treat Bag", "Costume", "Candy", "Jack-o'-Lantern" } },
  { key = "dead", name = "the Day of the Dead", from = { 11, 1 }, to = { 11, 2 },
    signs = { "Day of the Dead", "Marigold", "Catrina", "Spirit of Remembrance", "Bread of the Dead", "Grim Visage" } },
}
S.BY_KEY = {}
for _, f in ipairs(S.FESTIVALS) do S.BY_KEY[f.key] = f end
S.FAIRE = "the Darkmoon Faire"

local function store()
  if not ns.char then return nil end
  local d = ns.char.seasons
  if type(d) ~= "table" then d = {}; ns.char.seasons = d end
  d.first = tonumber(d.first) or U.Now()
  for _, k in ipairs({ "sessions", "hours", "wdays", "fests", "months", "told", "faire" }) do
    if type(d[k]) ~= "table" then d[k] = {} end
  end
  return d
end
S.Store = store

local function dt(t) return date and date("*t", t) or nil end
local function dayKey(t) return date and date("%Y-%m-%d", t) or tostring(math.floor(t / DAY)) end
local function zone() return U.Plain(U.Call(GetRealZoneText)) end
local function subzone() return U.Plain(U.Call(GetSubZoneText)) end
local function inCombat() return U.Call(InCombatLockdown) or U.Call(UnitAffectingCombat, "player") end
local function changed() if ns.Compose then ns.Compose.SourcesChanged() end end

-- Keeps at most n keys of a table, dropping the smallest by `field` (or the key itself).
local function trim(t, n, field)
  local keys = {}
  for k in pairs(t) do keys[#keys + 1] = k end
  if #keys <= n then return end
  table.sort(keys, function(a, b)
    local va, vb = field and type(t[a]) == "table" and (t[a][field] or 0) or a, field and type(t[b]) == "table" and (t[b][field] or 0) or b
    if va ~= vb then return va < vb end
    return tostring(a) < tostring(b)
  end)
  for i = 1, #keys - n do t[keys[i]] = nil end
end

---------------------------------------------------------------------------
-- Words for time
---------------------------------------------------------------------------
local MONTHS = { "January", "February", "March", "April", "May", "June", "July", "August", "September",
  "October", "November", "December" }
S.MONTHS = MONTHS
local function ordinal(n)
  local tens = n % 100
  local suffix = (tens >= 11 and tens <= 13) and "th" or ({ "st", "nd", "rd" })[n % 10] or "th"
  return n .. suffix
end
S.Ordinal = ordinal

-- "the 3rd of March", with the year when it isn't this one ("the 3rd of March, 2025").
function S.DateWords(t, withYear)
  local d = dt(t)
  if type(d) ~= "table" then return nil end
  local s = "the " .. ordinal(d.day) .. " of " .. MONTHS[d.month]
  local now = dt(U.Now())
  if withYear == true or (withYear ~= false and now and now.year ~= d.year) then s = s .. ", " .. d.year end
  return s
end

-- "eleven days", "three weeks", "two months", "a year".
function S.Span(seconds)
  local days = math.floor((seconds or 0) / DAY)
  if days < 1 then
    local h = math.max(1, math.floor((seconds or 0) / 3600 + 0.5))
    return h == 1 and "an hour" or (U.Number(h) .. " hours")
  end
  if days == 1 then return "a day" end
  if days < 14 then return U.Number(days) .. " days" end
  if days < 60 then local w = math.floor(days / 7 + 0.5); return U.Number(w) .. " weeks" end
  if days < 360 then local m = math.floor(days / 30.4 + 0.5); return m == 1 and "a month" or (U.Number(m) .. " months") end
  local y = math.floor(days / 365 + 0.25)
  return y <= 1 and "a year" or (U.Number(y) .. " years")
end

-- "nine hours", "an hour and a half".
function S.Hours(seconds)
  local h = (seconds or 0) / 3600
  if h < 1.25 then return "an hour" end
  if h < 1.75 then return "an hour and a half" end
  return U.Number(math.floor(h + 0.5)) .. " hours"
end

---------------------------------------------------------------------------
-- The calendar
---------------------------------------------------------------------------
local function inRange(m, day, from, to)
  local v, a, b = m * 100 + day, from[1] * 100 + from[2], to[1] * 100 + to[2]
  if a <= b then return v >= a and v <= b end
  return v >= a or v <= b   -- across the new year
end

-- The festivals on at time t: a list of { key, name, year } (Winter Veil that starts in
-- December belongs to that December's year).
function S.FestivalsOn(t)
  local d = dt(t or U.Now())
  if type(d) ~= "table" then return {} end
  local out = {}
  for _, f in ipairs(S.FESTIVALS) do
    if inRange(d.month, d.day, f.from, f.to) then
      local year = d.year
      if f.from[1] > f.to[1] and d.month <= f.to[1] then year = year - 1 end
      out[#out + 1] = { key = f.key, name = f.name, year = year, def = f }
    end
  end
  return out
end

local function hasSign(text, def)
  if type(text) ~= "string" then return false end
  for _, w in ipairs(def.signs) do if text:find(w, 1, true) then return true end end
  return false
end

local function festEntry(d, f)
  local id = f.key .. ":" .. f.year
  local e = d.fests[id]
  if not e then
    e = { key = f.key, year = f.year, first = U.Now(), last = 0, signs = 0, zones = {} }
    d.fests[id] = e
    trim(d.fests, S.KEEP_FESTS, "first")
  end
  return e, id
end

---------------------------------------------------------------------------
-- Recording
---------------------------------------------------------------------------
local notes = {}   -- what's been said (journal, mood) this session, so nothing is said twice

-- A sign of taking part in a festival that's on: a buff, a quest, an item, a place.
function S.Sign(text)
  local d = store()
  if not d or type(text) ~= "string" then return false end
  if text:find("Darkmoon", 1, true) or text:find("^Sayge's") then S.Faire(); return true end
  local hit = false
  for _, f in ipairs(S.FestivalsOn()) do
    if hasSign(text, f.def) then
      local e = festEntry(d, f)
      local firstSign = e.signs == 0
      e.signs, e.last = e.signs + 1, U.Now()
      local z, sub = zone(), subzone()
      if z then e.where = z end
      if sub and sub ~= z then e.sub = sub end
      hit = true
      if firstSign then
        if ns.Mood then ns.Mood.Push("merry", 10, "keeping " .. f.name) end
        S.JournalNote("fest", { fest = f.name, zone = U.Mid(e.where or "these parts") }, e.key .. e.year)
        changed()
      end
    end
  end
  return hit
end

-- A day at the Darkmoon Faire (counted once a day).
function S.Faire()
  local d = store()
  if not d then return end
  local key = dayKey(U.Now())
  local fa = d.faire
  if fa.day == key then return end
  fa.day, fa.n, fa.last, fa.zone = key, (fa.n or 0) + 1, U.Now(), zone()
  if ns.Mood then ns.Mood.Push("merry", 10, "a day at the Darkmoon Faire") end
  changed()
end

-- A day played: the count of days, the run of days, and the month's tally.
local function markDay(d, now)
  local key = dayKey(now)
  if d.today == key then return false end
  local yesterday = dayKey(now - DAY)
  d.daysN = (d.daysN or 0) + 1
  local st = d.streak or {}
  if st.last == yesterday then st.n = (st.n or 1) + 1 else st.n = 1 end
  st.last = key
  d.streak = st
  if not d.best or st.n > (d.best.n or 0) then d.best = { n = st.n, last = key } end
  d.today = key
  local mk = key:sub(1, 7)
  local m = d.months[mk] or { d = 0, g = 0, b = 0, f = {} }
  m.played = (m.played or 0) + 1
  d.months[mk] = m
  trim(d.months, S.KEEP_MONTHS)
  return true
end

-- The mood journal's finished days, folded into their months (Mood.lua keeps two weeks).
function S.FoldMonths()
  local d = store()
  local days = ns.char and ns.char.days
  if not d or type(days) ~= "table" then return end
  local today = dayKey(U.Now())
  local V = ns.Words and ns.Words.VALENCE or {}
  for key, day in pairs(days) do
    if type(key) == "string" and key < today and key:match("^%d+%-%d+%-%d+$") and type(day) == "table" then
      local mk, dd = key:sub(1, 7), key:sub(9, 10)
      local m = d.months[mk]
      if not m then m = { d = 0, g = 0, b = 0, f = {} }; d.months[mk] = m end
      m.f = m.f or {}
      if not m.f[dd] then
        m.f[dd] = true
        m.d = (m.d or 0) + 1
        local best, n
        for mood, c in pairs(day.moods or {}) do if not n or c > n or (c == n and mood < best) then best, n = mood, c end end
        local v = best and V[best] or 0
        if v > 0 then m.g = (m.g or 0) + 1 elseif v < 0 then m.b = (m.b or 0) + 1 end
      end
    end
  end
  trim(d.months, S.KEEP_MONTHS)
end

-- A session begins: a gap since the last one long enough is an absence, and this the return.
function S.Begin()
  local d = store()
  if not d then return end
  local now = U.Now()
  if d.cur then S.End(d.cur.last) end
  local last = d.sessions[#d.sessions]
  local prevEnd = last and last.e
  if prevEnd and now - prevEnd >= S.AWAY then
    local gap = now - prevEnd
    d.back = { n = gap, t = now, from = prevEnd }
    if not d.gap or gap > (d.gap.n or 0) then d.gap = { n = gap, from = prevEnd, back = now } end
    if gap >= 14 * DAY and ns.Mood then ns.Mood.Push("homecoming", 12, "back after " .. S.Span(gap)) end
    S.JournalNote("back", { span = S.Span(gap) }, "back" .. now)
  end
  d.cur = { s = now, last = now }
  d.n = (d.n or 0) + 1
  markDay(d, now)
  S.FoldMonths()
  S.CheckAnniversaries()
end

-- A session ends (logging out; or found unfinished at the next login, ended where it was last seen).
function S.End(at)
  local d = store()
  if not d or not d.cur then return end
  local s, e = d.cur.s or U.Now(), math.max(at or U.Now(), d.cur.s or 0)
  d.cur = nil
  if e - s < 60 then return end
  table.insert(d.sessions, { s = s, e = e })
  while #d.sessions > S.KEEP_SESSIONS do table.remove(d.sessions, 1) end
  if not d.longest or e - s > (d.longest.n or 0) then d.longest = { n = e - s, s = s } end
end

-- Once a minute: the session, the hour and the weekday, the day, the festival. Out of a
-- fight it also looks at the buffs and the place for a festival's signs.
function S.Tick(seconds)
  local d = store()
  if not d then return end
  seconds = seconds or S.TICK
  local now = U.Now()
  if not d.cur then d.cur = { s = now - seconds, last = now - seconds }; d.n = (d.n or 0) + 1 end
  d.cur.last = now
  d.total = (d.total or 0) + seconds
  local hour = tonumber((U.Call(GetGameTime)))
  if hour and hour >= 0 and hour < 24 then
    local h = math.floor(hour) + 1
    d.hours[h] = (d.hours[h] or 0) + seconds
  end
  local wd = date and tonumber(date("%w", now))
  if wd then d.wdays[wd + 1] = (d.wdays[wd + 1] or 0) + seconds end
  if markDay(d, now) then S.FoldMonths(); S.CheckAnniversaries() end
  -- Where the festival found them.
  local on = S.FestivalsOn(now)
  local z = zone()
  for _, f in ipairs(on) do
    local e = festEntry(d, f)
    if z then
      e.zones[z] = (e.zones[z] or 0) + seconds
      trim(e.zones, 8, nil)
    end
  end
  if inCombat() then return end
  local sub = subzone()
  if (sub and sub:find("Darkmoon", 1, true)) or (z and z:find("Darkmoon", 1, true)) then S.Faire() end
  if #on > 0 or (sub and sub:find("Darkmoon", 1, true)) then
    if sub then S.Sign(sub) end
    local auras = ns.World and ns.World.Auras and ns.World.Auras()
    for name in pairs(auras and auras.names or {}) do S.Sign(name) end
    for name in pairs(auras and auras.harm or {}) do S.Sign(name) end   -- "Tricked or Treated" is a debuff
  end
end

---------------------------------------------------------------------------
-- Anniversaries: of the road (a month, a hundred days, half a year, each year) and of each
-- new rank (a month, each year). "This week" is three days either side.
---------------------------------------------------------------------------
local SPANS = {
  { id = "year", days = 365, near = 3.5, word = "a year" },
  { id = "half", days = 182, near = 3, word = "half a year", setout = true },
  { id = "hundred", days = 100, near = 3, word = "a hundred days", setout = true },
  { id = "month", days = 30, near = 3, word = "a month" },
}
S.SPANS = SPANS

-- The milestones worth remembering: setting out, and each new rank (Mood.lua's milestones).
function S.Milestones(first)
  local list = {}
  if first then list[1] = { id = "setout", kind = "setout", t = first } end
  for _, m in ipairs(ns.char and ns.char.milestones or {}) do
    if tonumber(m.t) and tonumber(m.level) then
      list[#list + 1] = { id = "rank" .. m.level, kind = "rank", t = m.t, level = m.level, rank = m.rank }
    end
  end
  return list
end

-- The anniversary falling this week, or nil: { id, kind, span, n, target, today, ... }.
function S.Anniversary(first, now)
  now = now or U.Now()
  local best
  for _, m in ipairs(S.Milestones(first)) do
    local age = now - m.t
    for rank, sp in ipairs(SPANS) do
      if (not sp.setout or m.kind == "setout") and age > 0 then
        local n = sp.id == "year" and math.floor(age / (sp.days * DAY) + 0.5) or 1
        local target = m.t + n * sp.days * DAY
        if n >= 1 and math.abs(now - target) <= sp.near * DAY then
          local word = sp.id == "year" and (n == 1 and "a year" or (U.Number(n) .. " years")) or sp.word
          local a = { id = m.id .. ":" .. sp.id .. n, kind = m.kind, span = word, spanId = sp.id, n = n, target = target,
            today = dayKey(target) == dayKey(now), rank = m.rank, level = m.level, t = m.t, weight = (#SPANS - rank) * 2 + (m.kind == "setout" and 1 or 0) }
          if not best or a.weight > best.weight or (a.weight == best.weight and a.t < best.t) then best = a end
        end
      end
    end
  end
  return best
end

-- Said once: a small lift in mood, and a line in the day's journal.
function S.CheckAnniversaries()
  local d = store()
  if not d then return end
  local a = S.Anniversary(S.Birthday())
  if not a or d.told[a.id] then return end
  d.told[a.id] = U.Now()
  trim(d.told, S.KEEP_TOLD)
  local why = a.kind == "setout" and (a.span .. " on the road") or (a.span .. " since rising to " .. tostring(a.rank or "a new rank"))
  if ns.Mood then ns.Mood.Push("proud", 12, why) end
  S.JournalNote(a.kind == "setout" and "anniv" or "anniv_rank", { span = a.span, rank = a.rank or "a new rank" }, a.id)
end

-- A line for today's journal entry, in the character's own voice (Journal.lua writes it).
function S.JournalNote(kind, vars, tag)
  if notes[tag] then return end
  notes[tag] = true
  local JW = ns.Words and ns.Words.SEASONS and ns.Words.SEASONS.journal
  local list = JW and JW[kind]
  if not list or not ns.Journal or not ns.Journal.Note then return end
  local line = U.Pick(list, (ns.char and ns.char.seedName or "") .. ":seasons:" .. tostring(tag))
  line = line:gsub("{(%a+)}", function(k) if vars[k] ~= nil then return vars[k] end end)
  ns.Journal.Note({ k = "season", text = U.Cap(line) })
end

---------------------------------------------------------------------------
-- Reading it back
---------------------------------------------------------------------------
-- The character's first day: when Auto TRP first saw them, or the earliest any record has.
function S.Birthday(c)
  local d = store()
  if not d then return nil end
  c = c or ns.cache or {}
  local first = d.first
  local function older(t) t = tonumber(t); if t and t > 86400 * 365 and t < first then first = t end end
  older(c.life and c.life.since)
  older(c.deeds and c.deeds.since)
  older(c.chronicle and c.chronicle.created)
  local z = c.rpgd and c.rpgd.zones and c.rpgd.zones[1]
  older(z and z.t)
  for k in pairs(ns.char and ns.char.days or {}) do
    local y, m, dd = tostring(k):match("^(%d+)-(%d+)-(%d+)$")
    if y and time then older(time({ year = tonumber(y), month = tonumber(m), day = tonumber(dd), hour = 12 })) end
  end
  return first
end

-- When they're usually abroad by the game's clock: "night", "dawn", "day", "evening" or nil.
local BINS = { night = { 21, 22, 23, 0, 1, 2, 3, 4 }, dawn = { 5, 6, 7, 8 }, day = { 9, 10, 11, 12, 13, 14, 15, 16, 17 },
  evening = { 18, 19, 20 } }
local NEED = { night = 0.55, dawn = 0.35, day = 0.6, evening = 0.4 }
function S.Habit(d)
  local total = 0
  for h = 1, 24 do total = total + (d.hours[h] or 0) end
  if total < 4 * 3600 or (d.daysN or 0) < 3 then return nil, 0 end
  local best, bestRatio
  for name, hours in pairs(BINS) do
    local n = 0
    for _, h in ipairs(hours) do n = n + (d.hours[h + 1] or 0) end
    local share = n / total
    local ratio = share / (#hours / 24)
    if share >= NEED[name] and (not bestRatio or ratio > bestRatio) then best, bestRatio = name, ratio end
  end
  return best, total
end

local WEEKDAYS = { "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" }
-- The real days of the week they turn up: "weekend", a day's name, or nil.
function S.Weekdays(d)
  local total = 0
  for i = 1, 7 do total = total + (d.wdays[i] or 0) end
  if total < 4 * 3600 or U.Now() - (d.first or U.Now()) < 14 * DAY then return nil end
  if ((d.wdays[1] or 0) + (d.wdays[7] or 0)) / total >= 0.6 then return "weekend" end
  local best, n = nil, 0
  for i = 1, 7 do if (d.wdays[i] or 0) > n then best, n = i, d.wdays[i] end end
  if best and n / total >= 0.4 then return WEEKDAYS[best] end
  return nil
end

local SEASON_OF = { [12] = "winter", [1] = "winter", [2] = "winter", [3] = "spring", [4] = "spring", [5] = "spring",
  [6] = "summer", [7] = "summer", [8] = "summer", [9] = "autumn", [10] = "autumn", [11] = "autumn" }
S.SEASON_OF = SEASON_OF
local function monthKey(y, m) return ("%04d-%02d"):format(y, m) end
local function tone(g, b, need)
  if b >= need and b > g * 2 then return "hard" end
  if g >= need and g > b * 2 then return "good" end
  return nil
end
-- How the season just past went (from the months' days), else the month just past:
-- { season = "autumn", tone = "hard" } or { month = "October", tone = "good" } or nil.
function S.Tone(d)
  local now = dt(U.Now())
  if type(now) ~= "table" then return nil end
  -- The three months of the season before this one.
  local y, m = now.year, now.month
  local function back(k) local mm, yy = m - k, y; while mm < 1 do mm, yy = mm + 12, yy - 1 end return yy, mm end
  local k = 1
  while SEASON_OF[select(2, back(k))] == SEASON_OF[m] do k = k + 1 end
  local season = SEASON_OF[select(2, back(k))]
  local g, b, days = 0, 0, 0
  for i = k, k + 2 do
    local yy, mm = back(i)
    if SEASON_OF[mm] ~= season then break end
    local mo = d.months[monthKey(yy, mm)]
    if mo then g, b, days = g + (mo.g or 0), b + (mo.b or 0), days + (mo.d or 0) end
  end
  local t = days >= 8 and tone(g, b, 5)
  if t then return { season = season, tone = t, good = g, bad = b } end
  local yy, mm = back(1)
  local mo = d.months[monthKey(yy, mm)]
  t = mo and (mo.d or 0) >= 5 and tone(mo.g or 0, mo.b or 0, 4)
  if t then return { month = MONTHS[mm], tone = t, good = mo.g, bad = mo.b } end
  return nil
end

-- Everything for the profile: a fresh table each time. c: ns.cache (for the birthday).
function S.Read(c)
  local d = store()
  if not d then return nil end
  local now = U.Now()
  local o = { first = S.Birthday(c), seen = d.first, sessions = d.n or 0, days = d.daysN or 0, total = d.total or 0 }
  o.cur = d.cur and { s = d.cur.s, n = now - d.cur.s } or nil
  o.longest = d.longest
  if o.cur and (not o.longest or o.cur.n > o.longest.n) then o.longest = { n = o.cur.n, s = o.cur.s } end
  o.gap, o.back = d.gap, d.back
  o.hours = S.Habit(d)
  o.weekdays = S.Weekdays(d)
  local st = d.streak or {}
  local live = st.last == dayKey(now) or st.last == dayKey(now - DAY)
  o.streak = live and st.n or 0
  o.best = d.best and d.best.n or 0
  o.anniv = S.Anniversary(o.first, now)
  o.tone = S.Tone(d)
  -- Festivals kept (a sign seen), the latest first; where they spent the most of it.
  o.fests = {}
  for _, e in pairs(d.fests) do
    if (e.signs or 0) > 0 and S.BY_KEY[e.key] then
      local where, wn = e.where, 0
      for z, n in pairs(e.zones or {}) do if n > wn or (n == wn and z < (where or "")) then where, wn = z, n end end
      o.fests[#o.fests + 1] = { key = e.key, year = e.year, name = S.BY_KEY[e.key].name, t = e.last or 0, first = e.first,
        where = where or e.where, sub = e.sub, signs = e.signs }
    end
  end
  table.sort(o.fests, function(a, b) if a.t ~= b.t then return a.t > b.t end return a.key < b.key end)
  o.festKinds = {}
  local seenKind = {}
  for _, f in ipairs(o.fests) do
    if not seenKind[f.key] then seenKind[f.key] = true; o.festKinds[#o.festKinds + 1] = f.name end
  end
  o.faire = (d.faire.n or 0) > 0 and { n = d.faire.n, t = d.faire.last, zone = d.faire.zone } or nil
  o.now = S.FestivalsOn(now)
  return o
end

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------
ns.Listen("LOGIN", function()
  if not store() then return end
  S.Begin()
  ns.Ticker(S.TICK, function() S.Tick(S.TICK) end)
end)
ns.On("PLAYER_LOGOUT", function() S.End() end)

-- Quests and loot carry a festival's signs (and the faire's), checked only while one is on.
local pendingTitle
ns.On("QUEST_COMPLETE", function() pendingTitle = U.Plain(U.Call(GetTitleText)) end)
ns.On("QUEST_TURNED_IN", function(_, questID)
  local QL = _G.C_QuestLog
  local title = QL and QL.GetTitleForQuestID and questID and U.Plain(U.Call(QL.GetTitleForQuestID, questID)) or pendingTitle
  pendingTitle = nil
  if title then S.Sign(title) end
end)
ns.On("CHAT_MSG_LOOT", function(_, msg)
  msg = ns.World and ns.World.Safe(msg) or msg
  if type(msg) ~= "string" or not msg:find("^You receive") then return end
  local item = msg:match("%[(.-)%]")
  if item and (#S.FestivalsOn() > 0 or item:find("Darkmoon", 1, true)) then S.Sign(item) end
end)
ns.On("ZONE_CHANGED", function()
  if inCombat() then return end
  local sub = subzone()
  if sub and sub:find("Darkmoon", 1, true) then S.Faire() end
end)
