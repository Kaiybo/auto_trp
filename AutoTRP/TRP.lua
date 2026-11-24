-- Writes to Total RP 3. The safety rules:
--   1. Only one profile: the one you gave Auto TRP (/atrp setup makes one, /atrp use takes the
--      current one). Switch to another profile in Total RP 3 and Auto TRP stops writing.
--   2. Never Total RP 3's default profile (Total RP 3 itself refuses edits to it).
--   3. Never over your own words. A field that already has text Auto TRP didn't write is
--      left alone, and a field you edit after Auto TRP wrote it goes back to you. /atrp claim
--      hands one back to Auto TRP.
--   4. Never in combat, and "Currently" no more often than the setting allows.
-- Writing follows Total RP 3's own pattern (Core/Player.lua UpdateProfileField): set the
-- field, bump the section's version, fire REGISTER_DATA_UPDATED so other players fetch it.
local _, ns = ...

local U = ns.U
local TRP = {}
ns.TRP = TRP

local MISC_MOTTO, MISC_NICKNAME, MISC_PRONOUNS = 4, 3, 7
local CLAIM = "\001claimed"

function TRP.Loaded()
  return type(TRP3_API) == "table" and type(TRP3_API.profile) == "table"
    and type(TRP3_API.profile.getPlayerCurrentProfile) == "function"
end

function TRP.CurrentID()
  if not TRP.Loaded() then return nil end
  return U.Call(TRP3_API.profile.getPlayerCurrentProfileID)
end

function TRP.Current()
  if not TRP.Loaded() then return nil end
  return U.Call(TRP3_API.profile.getPlayerCurrentProfile)
end

function TRP.IsDefault(id)
  if type(id) ~= "string" or id == "" then return true end
  return id:sub(-1) == "*"
end

-- The profile Auto TRP may write to right now, or nil and why.
function TRP.Managed()
  if not TRP.Loaded() then return nil, "Total RP 3 isn't loaded." end
  local id, profile = TRP.CurrentID(), TRP.Current()
  if not id or type(profile) ~= "table" then return nil, "Total RP 3 hasn't finished loading." end
  if not ns.char.profileID then return nil, "No profile chosen yet (/atrp setup)." end
  if id ~= ns.char.profileID then return nil, "You're using a different Total RP 3 profile." end
  if TRP.IsDefault(id) then return nil, "That's Total RP 3's default profile, which it won't let addons change." end
  if type(profile.player) ~= "table" then profile.player = {} end
  return profile, id
end

local function sub(profile, name)
  local p = profile.player
  if type(p[name]) ~= "table" then p[name] = { v = 1 } end
  if type(p[name].v) ~= "number" then p[name].v = 1 end
  return p[name]
end

local function icon(name)
  if type(name) ~= "string" then return name end
  if type(TRP3_IconUtil) == "table" and type(TRP3_IconUtil.SerializeIcon) == "function" then
    local ok, v = pcall(TRP3_IconUtil.SerializeIcon, name)
    if ok and v then return v end
  end
  return name
end

local function miscEntry(ch, id)
  if type(ch.MI) ~= "table" then ch.MI = {} end
  for i, e in ipairs(ch.MI) do
    if type(e) == "table" and e.ID == id then return e, i end
  end
end

-- The player's own first name and pronouns from the profile, for prose.
function TRP.FirstName()
  local p = TRP.Current()
  local ch = type(p) == "table" and type(p.player) == "table" and p.player.characteristics
  return type(ch) == "table" and U.Plain(ch.FN) or nil
end

function TRP.CustomPronouns()
  local p = TRP.Current()
  local ch = type(p) == "table" and type(p.player) == "table" and p.player.characteristics
  if type(ch) ~= "table" or type(ch.MI) ~= "table" then return nil end
  for _, e in ipairs(ch.MI) do
    if type(e) == "table" and e.ID == MISC_PRONOUNS then return U.Plain(e.VA) end
  end
end

---------------------------------------------------------------------------
-- Fields. read(profile) -> signature string ("" when empty); write(profile, value).
---------------------------------------------------------------------------
local function textField(section, key)
  return {
    section = section,
    read = function(p) return U.Plain(sub(p, section)[key]) or "" end,
    write = function(p, v) sub(p, section)[key] = v end,
  }
end

local function aboutField(part)
  return {
    section = "about",
    read = function(p)
      local about = sub(p, "about")
      local t3 = type(about.T3) == "table" and about.T3[part]
      return type(t3) == "table" and (U.Plain(t3.TX) or "") or ""
    end,
    write = function(p, v)
      local about = sub(p, "about")
      if type(about.T3) ~= "table" then about.T3 = {} end
      if type(about.T3[part]) ~= "table" then about.T3[part] = {} end
      about.T3[part].TX = v
    end,
    -- About only shows template 3's sections when the profile uses template 3. Switch to it
    -- only when the other templates are empty.
    ready = function(p)
      local about = sub(p, "about")
      if about.TE == 3 then return true end
      local t1 = type(about.T1) == "table" and U.Plain(about.T1.TX)
      local t2 = type(about.T2) == "table" and #about.T2 > 0
      if t1 or t2 then return false end
      about.TE = 3
      return true
    end,
  }
end

local function miscField(id, label, iconName)
  return {
    section = "characteristics",
    read = function(p)
      local e = miscEntry(sub(p, "characteristics"), id)
      return e and (U.Plain(e.VA) or "") or ""
    end,
    write = function(p, v)
      local ch = sub(p, "characteristics")
      local e, i = miscEntry(ch, id)
      if not v then
        if i then table.remove(ch.MI, i) end
        return
      end
      if not e then
        e = { ID = id, NA = label, IC = icon(iconName) }
        table.insert(ch.MI, e)
      end
      e.VA = v
    end,
  }
end

local function glanceField(slotKey)
  local function slot() return tostring(ns.db.glanceSlots[slotKey] or 0) end
  return {
    section = "misc",
    read = function(p)
      local misc = sub(p, "misc")
      local g = type(misc.PE) == "table" and misc.PE[slot()]
      if type(g) ~= "table" or not g.AC then return "" end
      return (U.Plain(g.TI) or "") .. "\n" .. (U.Plain(g.TX) or "")
    end,
    write = function(p, v)
      local misc = sub(p, "misc")
      if type(misc.PE) ~= "table" then misc.PE = {} end
      if not v then
        if type(misc.PE[slot()]) == "table" then misc.PE[slot()].AC = false end
        return
      end
      misc.PE[slot()] = { AC = true, TI = v.TI, TX = v.TX, IC = icon(v.IC) }
    end,
    sig = function(v) return v and ((U.Plain(v.TI) or "") .. "\n" .. (U.Plain(v.TX) or "")) or "" end,
  }
end

local function traitsSig(list)
  if type(list) ~= "table" then return "" end
  local parts = {}
  for _, t in ipairs(list) do
    if type(t) == "table" then
      parts[#parts + 1] = tostring(t.LT or t.ID or "") .. "|" .. tostring(t.RT or "") .. "|" .. tostring(t.V2 or t.VA or "")
    end
  end
  return table.concat(parts, ";")
end

TRP.FIELDS = {
  currently = textField("character", "CU"),
  title = textField("characteristics", "TI"),
  fulltitle = textField("characteristics", "FT"),
  residence = textField("characteristics", "RE"),
  birthplace = textField("characteristics", "BP"),
  motto = miscField(MISC_MOTTO, "Motto", "INV_Scroll_01"),
  nickname = miscField(MISC_NICKNAME, "Nickname", "INV_Misc_Note_04"),
  bearing = aboutField("PS"),
  history = aboutField("HI"),
  physical = aboutField("PH"),
  traits = {
    section = "characteristics",
    read = function(p) return traitsSig(sub(p, "characteristics").PS) end,
    write = function(p, v)
      local list = {}
      for i, t in ipairs(v or {}) do
        list[i] = { LT = t.LT, RT = t.RT, LI = icon(t.LI), RI = icon(t.RI), V2 = t.V2 }
      end
      sub(p, "characteristics").PS = list
    end,
    sig = traitsSig,
  },
  glance_mood = glanceField("mood"),
  glance_lately = glanceField("lately"),
  glance_company = glanceField("company"),
}

TRP.LABELS = {
  currently = "Currently", title = "Title", fulltitle = "Full title", residence = "Residence",
  birthplace = "Birthplace", motto = "Motto", nickname = "Nickname", bearing = "About: Personality",
  history = "About: History", physical = "About: Physical", traits = "Personality traits",
  glance_mood = "Glance: mood", glance_lately = "Glance: lately", glance_company = "Glance: company",
}

-- Which setting switches a field on.
local function enabled(key)
  local f = ns.db.fields
  if key:find("^glance_") then return f.glances and (ns.db.glanceSlots[key:sub(8)] or 0) > 0 end
  return f[key] and true or false
end

---------------------------------------------------------------------------
-- Ownership bookkeeping, per profile
---------------------------------------------------------------------------
local function owned(id)
  ns.char.owned[id] = ns.char.owned[id] or {}
  return ns.char.owned[id]
end
local function released(id)
  ns.char.released[id] = ns.char.released[id] or {}
  return ns.char.released[id]
end

function TRP.Claim(key, id)
  id = id or ns.char.profileID
  if not id then return end
  released(id)[key] = nil
  owned(id)[key] = CLAIM
end

function TRP.Release(key, id)
  id = id or ns.char.profileID
  if not id or released(id)[key] then return end
  released(id)[key] = true
  owned(id)[key] = nil
end

function TRP.Status(key, id)
  id = id or ns.char.profileID
  if not enabled(key) then return "off" end
  if not id then return "waiting" end
  if released(id)[key] then return "yours" end
  if owned(id)[key] then return "auto" end
  return "waiting"
end

---------------------------------------------------------------------------
-- Writing
---------------------------------------------------------------------------
local function fire(id, sections)
  local playerID = type(TRP3_API.globals) == "table" and TRP3_API.globals.player_id
  for section in pairs(sections) do
    if type(TRP3_Addon) == "table" and type(TRP3_Addon.TriggerEvent) == "function" and type(TRP3_Addon.Events) == "table" then
      pcall(TRP3_Addon.TriggerEvent, TRP3_Addon, TRP3_Addon.Events.REGISTER_DATA_UPDATED, playerID, id, section)
    elseif type(TRP3_API.events) == "table" and type(TRP3_API.events.fireEvent) == "function" then
      pcall(TRP3_API.events.fireEvent, TRP3_API.events.REGISTER_DATA_UPDATED, playerID, id, section)
    end
  end
end

local function bump(section)
  local v = section.v or 1
  v = v + 1
  if v >= 100 then v = 1 end
  section.v = v
end

-- values: field key -> new value (nil clears a field Auto TRP owns).
-- Returns the list of field keys that changed.
function TRP.Apply(values, only)
  local profile, id = TRP.Managed()
  if not profile then return nil, id end
  if U.Call(InCombatLockdown) or U.Call(UnitAffectingCombat, "player") then return nil, "in combat" end
  local mine, theirs = owned(id), released(id)
  local dirty, changed, left = {}, {}, {}

  for key, def in pairs(TRP.FIELDS) do
    if (not only or only[key]) and enabled(key) and not theirs[key] then
      local value = values[key]
      if type(value) == "string" then value = U.Plain(value) and value or nil end
      local want = def.sig and def.sig(value) or (U.Plain(value) or "")
      local have = def.read(profile)
      local last = mine[key]
      if last == nil then
        if have ~= "" and have ~= want then
          TRP.Release(key, id); left[#left + 1] = key   -- your text was here first
        else
          last = have
        end
      elseif last ~= CLAIM and last ~= have then
        TRP.Release(key, id); left[#left + 1] = key     -- you edited what Auto TRP wrote
        last = nil
      end
      if last ~= nil then
        if have == want then
          mine[key] = have
        elseif def.ready and not def.ready(profile) then
          TRP.Release(key, id); left[#left + 1] = key   -- About uses another layout, with text
        else
          def.write(profile, value)
          mine[key] = def.read(profile)
          bump(sub(profile, def.section))
          dirty[def.section] = true
          changed[#changed + 1] = key
        end
      end
    end
  end
  if next(dirty) then fire(id, dirty) end
  if #left > 0 and not ns.db.quiet then
    local names = {}
    for i, key in ipairs(left) do names[i] = TRP.LABELS[key] or key end
    table.sort(names)
    ns.Print("Leaving your own words alone in: " .. table.concat(names, ", ")
      .. ". |cffffd100/atrp claim <field>|r (or |cffffd100/atrp claim all|r) hands them to Auto TRP.")
  end
  return changed
end

---------------------------------------------------------------------------
-- Choosing a profile
---------------------------------------------------------------------------
-- Makes "<Name> (Auto TRP)": a copy of the current profile (names, looks, everything), then
-- selected, with every field Auto TRP fills handed to it.
function TRP.Setup()
  if not TRP.Loaded() then return false, "Total RP 3 isn't loaded." end
  local api = TRP3_API.profile
  local current = TRP.Current()
  if type(current) ~= "table" or type(api.duplicateProfile) ~= "function" or type(api.selectProfile) ~= "function" then
    return false, "this version of Total RP 3 doesn't offer what Auto TRP needs."
  end
  local base = (U.Call(UnitName, "player") or "Character") .. " (Auto TRP)"
  local name, n = base, 1
  while type(api.isProfileNameAvailable) == "function" and not api.isProfileNameAvailable(name) do
    n = n + 1
    name = base .. " " .. n
  end
  local ok, id = pcall(api.duplicateProfile, current, name)
  if not ok or type(id) ~= "string" then return false, tostring(id) end
  local selected = pcall(api.selectProfile, id)
  if not selected then return false, "the profile was made but couldn't be selected." end
  ns.char.profileID = id
  ns.char.owned[id], ns.char.released[id] = {}, {}
  for key in pairs(TRP.FIELDS) do TRP.Claim(key, id) end
  return true, name
end

-- Uses the profile in use now, respecting everything already written in it.
function TRP.UseCurrent()
  local id = TRP.CurrentID()
  if not id then return false, "Total RP 3 hasn't finished loading." end
  if TRP.IsDefault(id) then return false, "that's Total RP 3's default profile, which it won't let addons change. Try /atrp setup." end
  ns.char.profileID = id
  ns.char.owned[id] = ns.char.owned[id] or {}
  ns.char.released[id] = ns.char.released[id] or {}
  return true, (TRP.Current() or {}).profileName or id
end
