-- Dungeon and raid runs told as stories (0.22.0), from Auto TRP's own record of them
-- (Sources/Delves.lua, ns.cache.delves): History tells the most telling recent run as a
-- small story with a line on what the place is like, then the master that fought hardest,
-- the place they keep going back to, the first full clear and a place left unfinished;
-- Lately has a fresh run, Marks a hard one; and two statistics, Deepest run and Wipes.
-- Other players are only ever counted (by class); Social Diary friends are named when
-- that's allowed. Loaded after Compose.lua, which calls in here.
local _, ns = ...

local U, W, Compose = ns.U, ns.Words, ns.Compose
local R = {}
ns.Runs = R

local ITEM_COLOUR = { [3] = "0070dd", [4] = "a335ee", [5] = "ff8000", [6] = "e6cc80" }
local RECENT = 21 * 86400

local function seed(key) return (ns.char and ns.char.seedName or "") .. ":run:" .. key end
local function fill(line, vars)
  return (line:gsub("{([%a']+)}", function(k) if vars and vars[k] ~= nil then return vars[k] end end))
end
local function pick(key, vars, which)
  return fill(U.Pick(W.DELVE_SAY[key], seed(key .. ":" .. tostring(which or ""))), vars)
end
local function choose(list, which) return U.Pick(list, seed(tostring(which))) end

local function article(word) return (word:lower():match("^[aeiou]") and "an " or "a ") .. word end

-- The key with the biggest count in a { key = n } table (ties by name, so it stays put).
local function top(t)
  local best, bn
  for k, v in pairs(type(t) == "table" and t or {}) do
    if type(v) == "number" and (not bn or v > bn or (v == bn and tostring(k) < tostring(best))) then best, bn = k, v end
  end
  return best, bn or 0
end

-- "a warrior, a priest and two mages", from the class counts (nil if they don't add up).
local function classWords(run)
  local list = {}
  local n = 0
  for class, k in pairs(run.classes or {}) do
    local pl = W.CLASS_PLURAL[class]
    if pl and k > 0 then list[#list + 1] = { class = class, k = k, pl = pl }; n = n + k end
  end
  if #list == 0 or n ~= run.others then return nil end
  table.sort(list, function(a, b) if a.k ~= b.k then return a.k < b.k end return a.class < b.class end)
  local words = {}
  for i, e in ipairs(list) do words[i] = e.k == 1 and article(e.pl[1]) or (U.Number(e.k) .. " " .. e.pl[2]) end
  return U.Join(words)
end

-- Social Diary friends still marked as friends, when naming them is allowed.
local function friendsOf(run)
  if not ns.db or not ns.db.nameFriends or type(run.friends) ~= "table" then return {} end
  local sd = ns.cache and ns.cache.sd
  local known = {}
  for _, f in ipairs(sd and sd.friends or {}) do known[f.name] = true end
  local out = {}
  for _, name in ipairs(run.friends) do if known[name] then out[#out + 1] = name end end
  return out
end

-- " with four others", " with Mirelle and three others", " alone", " with a raid of forty".
function R.Company(run)
  local others = run.others or 0
  if others == 0 then return pick("alone", nil, run.start) end
  local friends = friendsOf(run)
  local rest = others - #friends
  if #friends > 0 then
    local list = {}
    for _, f in ipairs(friends) do list[#list + 1] = f end
    if rest > 0 then list[#list + 1] = U.Number(rest) .. " " .. U.Plural(rest, "other") end
    return " with " .. U.Join(list)
  end
  if run.kind == "raid" or others >= 5 then
    return choose({ " with a raid " .. U.Number(others + 1) .. " strong", " as one of a raid of " .. U.Number(others + 1),
      " with " .. U.Number(others) .. " others" }, "raid:" .. run.start)
  end
  local classes = classWords(run)
  local count = " with " .. U.Number(others) .. " " .. U.Plural(others, "other")
  if classes and U.Hash(seed("co:" .. run.start)) % 2 == 0 then return " with " .. classes end
  return count
end

-- "the five of them", or the character alone.
local function group(run) return "the " .. U.Number((run.others or 0) + 1) .. " of them" end

-- The worst of the run, as a clause: the master that threw them back most, else the one
-- that cost them most, else deaths along the way. nil for a clean run.
function R.Setback(run, name)
  local solo = (run.others or 0) == 0
  local g = group(run)
  local hb, ht = top(run.tries)
  if hb and ht >= 1 then
    local lost = run.lostTo and run.lostTo[hb] or 0
    if solo then
      return choose({ fill("{boss} beat {them} back {times}", { boss = hb, times = U.Times(ht) }),
        fill("{boss} sent {them} back to the start {times}", { boss = hb, times = U.Times(ht) }) }, "solo:" .. run.start), hb
    end
    return pick(lost > 0 and "lost_wiped" or "wiped", { group = g, boss = hb, times = U.Times(ht), n = U.Number(lost) }, run.start), hb
  end
  if not solo then
    local worst
    for _, b in ipairs(run.bosses or {}) do if (b.lost or 0) > 0 and (not worst or b.lost > worst.lost) then worst = b end end
    if worst then return pick("lost", { group = g, boss = worst.name, n = U.Number(worst.lost) }, run.start), worst.name end
    if (run.deaths or 0) >= 1 then return pick("fell_some", { group = g, n = U.Number(run.deaths) }, run.start) end
  end
  if (run.mine or 0) >= 1 then return pick("fell_self", { name = name, times = U.Times(run.mine) }, run.start) end
  return nil
end

local function itemName(l)
  local col = ITEM_COLOUR[l.q or 0]
  return Compose.Colour and col and Compose.Colour(l.name, col) or l.name
end

local function finest(run, max)
  local list = {}
  for _, l in ipairs(run.loot or {}) do list[#list + 1] = l end
  table.sort(list, function(a, b) if a.q ~= b.q then return a.q > b.q end return a.name < b.name end)
  local out = {}
  for i = 1, math.min(max, #list) do out[i] = list[i] end
  return out
end

local function hard(run) return (run.wipes or 0) >= 2 or (run.mine or 0) >= 1 or (run.deaths or 0) >= 3 end

-- Something happened in it: a master down, a wipe, a death, a fine piece.
function R.Eventful(run)
  return #(run.bosses or {}) + (run.wipes or 0) + (run.deaths or 0) + (run.mine or 0) + #(run.loot or {}) > 0
end

-- How much a run has to tell.
local function worth(run)
  return #(run.bosses or {}) + 2 * (run.wipes or 0) + (run.deaths or 0) + (run.mine or 0) + 2 * #(run.loot or {})
    + (run.full and 3 or 0) + (run.firstClear and 4 or 0) + ((run.of and not run.full) and 1 or 0)
end

-- Not the words History's news opens with (W.SAY.when_*): the run story follows the news,
-- and two paragraphs in a row shouldn't open "In the last day or two".
local WHEN = {
  { 2 * 86400, { "Only a day or two back", "Very lately" } },
  { 7 * 86400, { "Some days ago", "Earlier in the week" } },
  { 14 * 86400, { "The week before this one", "A week or more back" } },
  { RECENT, { "Around a fortnight back", "Half a month ago" } },
  { math.huge, { "Some while back", "A good while ago" } },
}
local function when(t)
  local age = U.Now() - t
  for _, w in ipairs(WHEN) do if age < w[1] then return choose(w[2], "when:" .. t) end end
end

local function ago(t)
  local days = math.floor((U.Now() - t) / 86400)
  if days < 2 then return "only days ago" end
  if days < 14 then return U.Number(days) .. " days ago" end
  if days < 60 then return U.Number(math.floor(days / 7)) .. " weeks ago" end
  return U.Number(math.floor(days / 30)) .. " months ago"
end

-- How many masters were left when the run ended, or nil. A run whose last master down is
-- the place's own last one reached the end, masters skipped or not: never "turned back
-- after Edwin VanCleef, five masters short of the end".
local function shortOf(run, last)
  if not (run.of and not run.full and last) then return nil end
  local Dv = ns.Sources and ns.Sources.Delves
  local entry = Dv and Dv.Place and Dv.Place(run.place)
  for _, w in ipairs(entry and (entry.wings or { { bosses = entry.bosses } }) or {}) do
    if type(w.bosses) == "table" and w.bosses[#w.bosses] == last then return nil end
  end
  return run.of - (run.got or 0)
end
R.ShortOf = shortOf

-- One run as a story: "Last week Aldric went into the Deadmines with four others; the five
-- of them lost two to Mr. Smite before Edwin VanCleef fell, and Aldric came out with Cruel Barb."
function R.Story(run, name)
  local last = run.bosses[#run.bosses] and run.bosses[#run.bosses].name
  local open = pick(run.entry and run.entry.down and "go_down" or "go", { place = run.name, with = R.Company(run) }, run.start)
  local s = when(run.stop or run.start) .. " " .. name .. " " .. open
  -- After the opening, the subject is a pronoun: "Aldric went down into the Deadmines; he fell once".
  local setback, sb = R.Setback(run, "{they}")
  local short = shortOf(run, last)
  local items = {}
  for i, l in ipairs(finest(run, 2)) do items[i] = itemName(l) end
  if setback then
    s = s .. "; " .. setback
    if last and sb == last then
      s = s .. " " .. choose({ "before it finally fell", "before it went down at last", "and won through in the end" }, "same:" .. run.start)
      if run.full then s = s .. choose({ ", and with it the place was clear", ", the last of its masters" }, "samefull:" .. run.start) end
    elseif run.full then
      s = s .. " " .. choose({ "before " .. last .. " fell and the place was clear", "before the last of its masters, " .. last .. ", went down",
        "before " .. last .. " fell, the last master in the place" }, "full:" .. run.start)
    elseif short and short > 0 then
      s = s .. " " .. choose({ "and turned back after " .. last .. ", " .. U.Number(short) .. " " .. U.Plural(short, "master") .. " short of the end",
        "and came out after " .. last .. " with " .. U.Number(short) .. " of its masters still standing" }, "left:" .. run.start)
    elseif last then
      s = s .. " " .. pick("before", { last = last }, run.start)
    else
      s = s .. " " .. choose({ "and came back out with no master down", "and gave it up before any master fell" }, "none:" .. run.start)
    end
    if #items > 0 then s = s .. ", " .. pick("loot", { name = "{they}", item = U.Join(items) }, run.start) end
  else
    if run.full then s = s .. " " .. pick(run.firstClear and "clear_first" or "clear", nil, run.start)
    elseif short and short > 0 then s = s .. " " .. pick("left", { last = last, n = U.Number(short) }, run.start)
    elseif last then s = s .. " " .. pick("down", { last = last }, run.start)
    else s = s .. " " .. pick("none", nil, run.start) end
    if #items > 0 then
      s = s .. choose({ ", coming out with " .. U.Join(items), ", and came away with " .. U.Join(items), "; {they} came out with " .. U.Join(items) }, "loot:" .. run.start)
    end
  end
  local out = { s }
  local lines = run.entry and run.entry.lines
  if lines then out[2] = choose(lines, "line:" .. run.place .. ":" .. run.start) end
  return out
end

-- History's paragraph on the deep: sentences, and what it told (masters and items), so
-- the news doesn't tell them again. nil when there's nothing to tell.
function R.Tales(c, name)
  local dv = c and c.delves
  if not dv or (#dv.runs == 0 and not next(dv.places)) then return nil end
  local now = U.Now()
  local out = {}
  local told = { bosses = {}, items = {}, place = nil }
  local best, bw
  for _, run in ipairs(dv.runs) do
    local w = worth(run) + ((now - (run.stop or 0) <= RECENT) and 100 or 0)
    if R.Eventful(run) and (w > 100 or worth(run) >= 2) and (not bw or w > bw) then best, bw = run, w end
  end
  if best then
    for _, s in ipairs(R.Story(best, name)) do out[#out + 1] = s end
    told.place = best.place
    told.solo = (best.others or 0) == 0
    if now - (best.stop or 0) <= RECENT then told.name = best.name end
    if now - (best.stop or 0) <= RECENT then
      for _, b in ipairs(best.bosses or {}) do told.bosses[b.name] = true end
      for _, l in ipairs(best.loot or {}) do told.items[l.name] = true end
    end
  end
  -- The master that fought hardest, over every run.
  local hb, hn, hp
  for pname, p in pairs(dv.places) do
    local b, n = top(p.tries)
    if b and n >= 2 and (not hn or n > hn) then hb, hn, hp = b, n, pname end
  end
  local storyTries = best and best.tries and best.tries[hb] or 0
  if hb and not (best and best.place == hp and storyTries == hn) then
    local p = dv.places[hp]
    out[#out + 1] = pick((p.kills or {})[hb] and "hardest" or "hardest_standing", { boss = hb, place = p.name, times = U.Times(hn) }, hb)
  end
  -- The place they keep going back to.
  local ap, an
  for pname, p in pairs(dv.places) do
    if (p.runs or 0) >= 3 and (not an or p.runs > an or (p.runs == an and (p.last or 0) > (dv.places[ap].last or 0))) then ap, an = pname, p.runs end
  end
  if ap then
    local p = dv.places[ap]
    local clears = ""
    if p.clears >= p.runs then clears = pick("again_clear_all", nil, ap)
    elseif p.clears > 0 then clears = pick("again_clears", { k = U.Number(p.clears) }, ap) end
    out[#out + 1] = pick("again", { place = p.name, n = U.Number(p.runs), times = U.Times(p.runs), clears = clears }, ap)
  end
  -- The first full clear (unless the story was it).
  local fp, ft
  for pname, p in pairs(dv.places) do
    if p.firstClear and (not ft or p.firstClear < ft) then fp, ft = pname, p.firstClear end
  end
  if fp and not (best and best.firstClear and best.place == fp) and fp ~= ap then
    out[#out + 1] = pick("first_clear", { place = dv.places[fp].name, ago = ago(ft) }, fp)
  end
  -- A place left unfinished: never cleared, the latest such.
  local up, ut
  for pname, p in pairs(dv.places) do
    if p.entry and (p.clears or 0) == 0 and (p.runs or 0) >= 1 and pname ~= fp and pname ~= ap and pname ~= hp
      and not (best and best.place == pname and (best.of and not best.full)) and (not ut or (p.last or 0) > ut) then
      up, ut = pname, p.last or 0
    end
  end
  if up then
    local p = dv.places[up]
    if (p.best or 0) > 0 and p.bestLast then out[#out + 1] = pick("unfinished", { place = p.name, boss = p.bestLast }, up)
    else out[#out + 1] = pick("unfinished_none", { place = p.name }, up) end
  end
  if #out == 0 then return nil end
  return out, told
end

-- Lately: a run just over (within three hours). { t, prio, g } or nil.
function R.Lately(c)
  local dv = c and c.delves
  local run = dv and dv.runs[1]
  if not run or U.Now() - (run.stop or 0) > 3 * 3600 or not R.Eventful(run) then return nil end
  local last = run.bosses[#run.bosses] and run.bosses[#run.bosses].name
  local short = shortOf(run, last)
  local vars = { place = run.name, with = R.Company(run), last = last, n = short and U.Number(short) }
  local key, ti, prio
  local setback = hard(run) and R.Setback(run, (ns.TRP and ns.TRP.FirstName and ns.TRP.FirstName()) or U.Call(UnitName, "player") or "This one")
  if setback then
    vars.hard = setback
    key, ti, prio = "lately_hard", "A Hard Run", 2
  elseif run.full then key, ti, prio = "lately_clear", "A Clean Sweep", 2
  elseif short and short > 0 then key, ti, prio = "lately_left", "Turned Back", 1
  elseif last then key, ti, prio = "lately_run", "Out of the Deep", 1
  else key, ti, prio = "lately_none", "Out of the Deep", 0 end
  local tx
  if key == "lately_run" then
    tx = choose({ "Just back from " .. vars.place .. vars.with .. ", with " .. last .. " down.",
      "Fresh out of " .. vars.place .. ", where " .. last .. " fell.", "Has just come back up out of " .. vars.place .. vars.with .. "." }, "run:" .. run.start)
  else
    tx = pick(key, vars, run.start)
  end
  return { t = run.stop, prio = prio, g = { TI = ti, TX = U.Pron(U.Cap(tx)), IC = run.kind == "raid" and "INV_Misc_Head_Dragon_01" or "INV_Misc_Key_13" } }
end

-- Marks: just out of a hard run (within the hour). { prio, title, text, icon } or nil.
function R.Mark(c)
  local dv = c and c.delves
  local run = dv and dv.runs[1]
  local world = c and c.world or {}
  if not run or dv.inside or world.combat or world.dead or U.Now() - (run.stop or 0) > 3600 or not hard(run) then return nil end
  return { prio = 4.7, title = "A Hard Run", text = pick("mark_hard", { place = run.name }, run.start), icon = "Spell_Shadow_DeathScream" }
end

-- Statistics: Deepest run ("Blackrock Depths, 14 masters"), Wipes ("14, five of them to Mr. Smite").
function R.Stats(c, out)
  local dv = c and c.delves
  if not dv then return end
  local function figure(n) return n >= 100 and U.Number(n) or tostring(n) end
  local bp, bn
  for pname, p in pairs(dv.places) do
    local full = (p.clears or 0) > 0
    local score = (p.best or 0) + (full and 0.5 or 0)
    if (p.best or 0) > 0 and (not bn or score > bn) then bp, bn = pname, score end
  end
  if bp then
    local p = dv.places[bp]
    local judgeOf = p.entry and (p.entry.wings and nil or #p.entry.bosses)
    local all = (p.clears or 0) > 0 and judgeOf and p.best >= judgeOf
    out.deepest = U.Cap(p.name) .. ", " .. (all and ("all " .. figure(p.best) .. " masters") or (figure(p.best) .. " " .. U.Plural(p.best, "master")))
      .. ((p.clears or 0) > 0 and not all and ", cleared" or "")
  end
  local total, tb, tn = 0, nil, 0
  for _, p in pairs(dv.places) do
    total = total + (p.wipes or 0)
    local b, n = top(p.tries)
    if b and n > tn then tb, tn = b, n end
  end
  if dv.runs[1] and dv.runs[1].ongoing then total = total + (dv.runs[1].wipes or 0) end
  if total > 0 then
    out.wipes = figure(total) .. ((tb and tn >= 2 and tn < total) and (", " .. figure(tn) .. " of them to " .. tb) or (tb and tn == total and tn >= 2 and (", all to " .. tb) or ""))
  end
end
