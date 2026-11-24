-- Reads Social Diary's saved data: the players you added to your diary (with their tags and
-- the relationship you wrote) and the groups you've travelled in. Read-only.
-- Layout follows Social Diary's Core/DB.lua: the diary in use is SocialDiaryDB.shared when
-- the account shares one, else SocialDiaryCharDB.data.
local _, ns = ...

local U = ns.U
local SD = {}
ns.Sources = ns.Sources or {}
ns.Sources.SocialDiary = SD

local function diary()
  local acct, ch = _G.SocialDiaryDB, _G.SocialDiaryCharDB
  if type(acct) == "table" and type(acct.settings) == "table" and acct.settings.shareDiary == true
    and type(acct.shared) == "table" then
    return acct.shared
  end
  if type(ch) == "table" and type(ch.data) == "table" then return ch.data end
  return nil
end

function SD.Loaded()
  return ns.db.sources.socialDiary and diary() ~= nil
end

local function nameOf(d, guid)
  local rec = type(d.characters) == "table" and d.characters[guid]
  local names = type(rec) == "table" and rec.names
  local latest = type(names) == "table" and names[#names]
  if type(latest) ~= "table" then return nil, rec end
  return U.Plain(latest.first), rec
end

local function hasTag(entry, tag)
  for _, t in ipairs(type(entry.tags) == "table" and entry.tags or {}) do
    if t == tag then return true end
  end
  return false
end

function SD.Read()
  if not SD.Loaded() then return nil end
  local d = diary()
  local me = U.Call(UnitGUID, "player")
  local now = U.Now()
  local out = { friends = {}, foes = {}, added = 0, recentGroups = 0, recentPeople = 0 }

  for guid, entry in pairs(type(d.diary) == "table" and d.diary or {}) do
    if type(entry) == "table" then
      out.added = out.added + 1
      local name, rec = nameOf(d, guid)
      if name and not (type(rec) == "table" and rec.isSelf) then
        local relationship = U.Plain(entry.relationship)
        local p = { name = name, relationship = relationship, lastSeen = type(rec) == "table" and tonumber(rec.lastSeen) or 0 }
        if hasTag(entry, "foe") or hasTag(entry, "avoid") then
          out.foes[#out.foes + 1] = p
        elseif relationship or hasTag(entry, "friend") then
          out.friends[#out.friends + 1] = p
        end
      end
    end
  end
  table.sort(out.friends, function(a, b) return a.lastSeen > b.lastSeen end)
  -- A partner, if a relationship says so: TRP3's status 3 (married) or 2 (taken).
  for _, f in ipairs(out.friends) do
    local r = f.relationship and f.relationship:lower() or ""
    for _, w in ipairs({ "wife", "husband", "spouse", "married" }) do
      if r:find(w) then out.partner = { name = f.name, status = 3 }; break end
    end
    if out.partner then break end
    for _, w in ipairs({ "betrothed", "fianc", "lover", "sweetheart", "girlfriend", "boyfriend", "beloved" }) do
      if r:find(w) then out.partner = { name = f.name, status = 2 }; break end
    end
    if out.partner then break end
  end
  table.sort(out.foes, function(a, b) return a.lastSeen > b.lastSeen end)

  -- Groups this week: sessions this character was in.
  local people = {}
  for _, s in pairs(type(d.sessions) == "table" and d.sessions or {}) do
    if type(s) == "table" and (not me or s.me == me) and (tonumber(s.startedAt) or 0) > now - 7 * 86400 then
      out.recentGroups = out.recentGroups + 1
      for guid in pairs(type(s.participants) == "table" and s.participants or {}) do people[guid] = true end
    end
  end
  out.recentPeople = U.Count(people)
  return out
end
