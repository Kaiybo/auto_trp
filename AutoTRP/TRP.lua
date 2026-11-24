-- Writes to Total RP 3. The safety rules:
--   1. Only one profile: the one you gave Auto TRP (/atrp setup makes one, /atrp use takes the
--      current one). Switch to another profile in Total RP 3 and Auto TRP stops writing.
--   2. Never Total RP 3's default profile (Total RP 3 itself refuses edits to it).
--   3. Never over your own words. A field that already has text Auto TRP didn't write is
--      left alone, and a field you edit after Auto TRP wrote it goes back to you. /atrp claim
--      hands one back to Auto TRP. /atrp restore puts back exactly the fields it wrote.
--   4. Never in combat, never into a section whose Total RP 3 editor is open, and
--      "Currently" and the glances only when they change, at most every 15 seconds.
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

local function copy(v)
  if type(v) ~= "table" then return v end
  local o = {}
  for k, x in pairs(v) do o[k] = copy(x) end
  return o
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

-- Total RP 3's roleplay status: 1 in character, 2 out of character.
function TRP.IsOOC()
  local p = TRP.Current()
  local ch = type(p) == "table" and type(p.player) == "table" and p.player.character
  return type(ch) == "table" and ch.RP == 2
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
-- Text as Total RP 3 will keep it: its own sanitizer (and no line breaks in one-line fields),
-- so what Auto TRP compares is what TRP3 stores after a reload.
---------------------------------------------------------------------------
local function clean(text, multiLine)
  if type(text) ~= "string" then return nil end
  local util = type(TRP3_API) == "table" and type(TRP3_API.utils) == "table" and TRP3_API.utils.str
  if util and type(util.sanitize) == "function" then
    local ok, v = pcall(util.sanitize, text, multiLine)
    if ok and type(v) == "string" then text = v end
  end
  if not multiLine then text = text:gsub("[\r\n]+", " ") end
  if not U.Plain(text) then return nil end
  return text
end
TRP.Clean = clean

---------------------------------------------------------------------------
-- Fields. read(profile) -> signature string ("" when empty); write(profile, value);
-- raw/setRaw for the backup.
---------------------------------------------------------------------------
local function textField(section, key)
  return {
    section = section,
    read = function(p) return U.Plain(sub(p, section)[key]) or "" end,
    write = function(p, v) sub(p, section)[key] = clean(v, false) end,
    raw = function(p) return sub(p, section)[key] end,
    setRaw = function(p, v) sub(p, section)[key] = v end,
  }
end

local SECTION_ICONS = { PH = "INV_Chest_Cloth_17", PS = "Spell_Holy_MindVision", HI = "INV_Misc_Book_09" }

local function t3(p)
  local about = sub(p, "about")
  if type(about.T3) ~= "table" then about.T3 = {} end
  for _, part in ipairs({ "PH", "PS", "HI" }) do
    if type(about.T3[part]) ~= "table" then about.T3[part] = {} end
  end
  return about.T3
end

-- Template 2 counts as used only when one of its frames has text (as TRP3 itself decides).
local function t2HasText(about)
  for _, frame in pairs(type(about.T2) == "table" and about.T2 or {}) do
    if type(frame) == "table" and U.Plain(frame.TX) then return true end
  end
  return false
end

local function aboutField(part)
  return {
    section = "about", multiLine = true,
    read = function(p)
      local about = sub(p, "about")
      local sec = type(about.T3) == "table" and about.T3[part]
      return type(sec) == "table" and (U.Plain(sec.TX) or "") or ""
    end,
    write = function(p, v)
      local sec = t3(p)[part]
      sec.TX = clean(v, true)
      if sec.TX and not sec.IC then sec.IC = icon(SECTION_ICONS[part]) end
    end,
    raw = function(p) return copy(t3(p)[part]) end,
    setRaw = function(p, v) t3(p)[part] = type(v) == "table" and v or {} end,
    -- About only shows template 3's sections when the profile uses template 3. Switch to it
    -- only when the other templates are empty.
    ready = function(p, id)
      local about = sub(p, "about")
      if about.TE == 3 then return true end
      local t1 = type(about.T1) == "table" and U.Plain(about.T1.TX)
      if t1 or t2HasText(about) then return false end
      local b = ns.TRP.BackupFor(id)
      if b.TE == nil then b.TE = about.TE or false end
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
      v = clean(v, false)
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
    raw = function(p) local e = miscEntry(sub(p, "characteristics"), id); return copy(e) end,
    setRaw = function(p, v)
      local ch = sub(p, "characteristics")
      local _, i = miscEntry(ch, id)
      if i then table.remove(ch.MI, i) end
      if type(v) == "table" then table.insert(ch.MI, i or (#ch.MI + 1), v) end
    end,
  }
end

-- The slot each glance lives in, for this character.
function TRP.GlanceSlot(slotKey)
  local slots = ns.char and ns.char.glanceSlots or ns.db.glanceSlots
  return slots[slotKey] or 0
end

local function glanceField(slotKey)
  local function slot() return tostring(TRP.GlanceSlot(slotKey)) end
  return {
    section = "misc",
    -- An inactive slot still holds the player's words; count them.
    read = function(p)
      local misc = sub(p, "misc")
      local g = type(misc.PE) == "table" and misc.PE[slot()]
      if type(g) ~= "table" then return "" end
      local ti, tx = U.Plain(g.TI), U.Plain(g.TX)
      if not ti and not tx then return "" end
      return (g.AC and "" or "off:") .. (ti or "") .. "\n" .. (tx or "")
    end,
    write = function(p, v)
      local misc = sub(p, "misc")
      if type(misc.PE) ~= "table" then misc.PE = {} end
      if not v then
        if type(misc.PE[slot()]) == "table" then misc.PE[slot()].AC = false end
        return
      end
      misc.PE[slot()] = { AC = true, TI = clean(v.TI, false), TX = clean(v.TX, true), IC = icon(v.IC) }
    end,
    sig = function(v) return v and ((U.Plain(v.TI) or "") .. "\n" .. (U.Plain(v.TX) or "")) or "" end,
    raw = function(p) local misc = sub(p, "misc"); return copy(type(misc.PE) == "table" and misc.PE[slot()] or nil) end,
    setRaw = function(p, v) local misc = sub(p, "misc"); if type(misc.PE) ~= "table" then misc.PE = {} end; misc.PE[slot()] = v end,
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
  ooc = textField("character", "CO"),
  -- Total RP 3's "open to walk-ups" (2 yes, 1 no). "No" reads as empty, the profile default.
  walkup = {
    section = "character", keepOnNil = true,
    read = function(p) return sub(p, "character").WU == 2 and "2" or "" end,
    write = function(p, v) sub(p, "character").WU = (v == 2) and 2 or 1 end,
    sig = function(v) return v == 2 and "2" or "" end,
    raw = function(p) return sub(p, "character").WU end,
    setRaw = function(p, v) sub(p, "character").WU = v end,
  },
  relationship = {
    section = "characteristics",
    read = function(p) local v = sub(p, "characteristics").RS; return (v and v ~= 0) and tostring(v) or "" end,
    write = function(p, v) sub(p, "characteristics").RS = v end,
    sig = function(v) return v and tostring(v) or "" end,
    raw = function(p) return sub(p, "characteristics").RS end,
    setRaw = function(p, v) sub(p, "characteristics").RS = v end,
  },
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
    raw = function(p) return copy(sub(p, "characteristics").PS) end,
    setRaw = function(p, v) sub(p, "characteristics").PS = type(v) == "table" and v or {} end,
  },
  glance_mood = glanceField("mood"),
  glance_lately = glanceField("lately"),
  glance_company = glanceField("company"),
  glance_ambition = glanceField("ambition"),
  glance_marks = glanceField("marks"),
}

TRP.LABELS = {
  currently = "Currently", title = "Title", fulltitle = "Full title", residence = "Residence",
  birthplace = "Birthplace", motto = "Motto", nickname = "Nickname", bearing = "About: Personality",
  history = "About: History", physical = "About: Physical", traits = "Personality traits",
  glance_mood = "Glance: mood", glance_lately = "Glance: lately", glance_company = "Glance: company",
  glance_ambition = "Glance: ambition", glance_marks = "Glance: marks",
  ooc = "OOC note", relationship = "Relationship status", walkup = "Open to walk-ups",
}

-- Which setting switches a field on.
local function enabled(key)
  local f = ns.db.fields
  if key:find("^glance_") then return f.glances and f[key] ~= false and TRP.GlanceSlot(key:sub(8)) > 0 end
  return f[key] and true or false
end
TRP.Enabled = enabled

---------------------------------------------------------------------------
-- Ownership bookkeeping, per profile, kept account-wide so two characters sharing one
-- profile agree about what Auto TRP wrote.
---------------------------------------------------------------------------
local function book(name, id)
  ns.db[name] = ns.db[name] or {}
  ns.db[name][id] = ns.db[name][id] or {}
  return ns.db[name][id]
end
local function owned(id) return book("owned", id) end
local function released(id) return book("released", id) end
local function previous(id) return book("previous", id) end   -- the signature before the last write

function TRP.Owned(id) return owned(id or ns.char.profileID) end

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
  if type(TRP3_Addon) ~= "table" or type(TRP3_Addon.TriggerEvent) ~= "function" or type(TRP3_Addon.Events) ~= "table" then return end
  for section in pairs(sections) do
    pcall(TRP3_Addon.TriggerEvent, TRP3_Addon, TRP3_Addon.Events.REGISTER_DATA_UPDATED, playerID, id, section)
  end
end

local function bump(section)
  local v = section.v or 1
  v = v + 1
  if v >= 100 then v = 1 end
  section.v = v
end

-- Total RP 3's Characteristics and About editors work on a copy and put it back on Save.
-- While one is open, leave those sections alone (the next pass catches up).
local EDITED_SECTIONS = { characteristics = true, about = true }
function TRP.Editing()
  local nav = type(TRP3_API) == "table" and type(TRP3_API.navigation) == "table" and TRP3_API.navigation.page
  if type(nav) ~= "table" or type(nav.getCurrentContext) ~= "function" then return false end
  local ok, ctx = pcall(nav.getCurrentContext)
  if not ok or type(ctx) ~= "table" or not ctx.isEditMode then return false end
  local main = _G.TRP3_MainFrame
  return not (type(main) == "table" and main.IsShown and not main:IsShown())
end

---------------------------------------------------------------------------
-- Backup: before Auto TRP first writes a field in a profile, the field as it was, so
-- /atrp restore can put back exactly those fields and nothing else.
---------------------------------------------------------------------------
function TRP.BackupFor(id)
  ns.db.backup = ns.db.backup or {}
  ns.db.backup[id] = ns.db.backup[id] or { fields = {} }
  return ns.db.backup[id]
end

-- Puts every field Auto TRP touched back as it was and hands them all to the player.
function TRP.Restore()
  local profile, id = TRP.Managed()
  if not profile then return false, id end
  if U.Call(InCombatLockdown) then return false, "not in combat." end
  local b = ns.db.backup and ns.db.backup[id]
  if not b or not next(b.fields) then return false, "there's no backup for this profile (Auto TRP hasn't written to it yet)." end
  local sections = {}
  for key, saved in pairs(b.fields) do
    local def = TRP.FIELDS[key]
    if def and def.setRaw then
      def.setRaw(profile, copy(saved.raw))
      sections[def.section] = true
    end
  end
  if b.TE ~= nil then sub(profile, "about").TE = b.TE or nil; sections.about = true end
  for section in pairs(sections) do bump(sub(profile, section)) end
  for key in pairs(TRP.FIELDS) do TRP.Release(key, id) end
  ns.db.backup[id] = nil
  fire(id, sections)
  return true
end

-- values: field key -> new value (nil clears a field Auto TRP owns).
-- Returns the list of field keys that changed.
function TRP.Apply(values, only)
  local profile, id = TRP.Managed()
  if not profile then return nil, id end
  if U.Call(InCombatLockdown) or U.Call(UnitAffectingCombat, "player") then return nil, "in combat" end
  local mine, theirs, prev = owned(id), released(id), previous(id)
  local dirty, changed, left = {}, {}, {}
  local editing = TRP.Editing()
  local bk = TRP.BackupFor(id)

  for key, def in pairs(TRP.FIELDS) do
    -- keepOnNil: "no opinion right now" leaves the field exactly as it is.
    local keep = def.keepOnNil and values[key] == nil
    if not keep and (not only or only[key]) and enabled(key) and not theirs[key] and not (editing and EDITED_SECTIONS[def.section]) then
      local value = values[key]
      if type(value) == "string" then value = clean(value, def.multiLine) end
      local want = def.sig and def.sig(value) or (U.Plain(value) or "")
      local have = def.read(profile)
      local last = mine[key]
      if last == nil then
        if have ~= "" and have ~= want then
          TRP.Release(key, id); left[#left + 1] = key   -- your text was here first
        else
          last = have
        end
      elseif last ~= CLAIM and last ~= have and prev[key] ~= have then
        TRP.Release(key, id); left[#left + 1] = key     -- you edited what Auto TRP wrote
        last = nil
      end
      -- (have == prev[key]: an editor saved an older copy over Auto TRP's text; just rewrite.)
      if last ~= nil then
        if have == want then
          mine[key] = have
        elseif def.ready and not def.ready(profile, id) then
          TRP.Release(key, id); left[#left + 1] = key   -- About uses another layout, with text
        else
          if not bk.fields[key] and def.raw then bk.fields[key] = { raw = copy(def.raw(profile)) } end
          prev[key] = have
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
  ns.db.owned = ns.db.owned or {}; ns.db.released = ns.db.released or {}
  ns.db.owned[id], ns.db.released[id] = {}, {}
  for key in pairs(TRP.FIELDS) do TRP.Claim(key, id) end
  return true, name
end

-- Uses the profile in use now, respecting everything already written in it.
function TRP.UseCurrent()
  local id = TRP.CurrentID()
  if not id then return false, "Total RP 3 hasn't finished loading." end
  if TRP.IsDefault(id) then return false, "that's Total RP 3's default profile, which it won't let addons change. Try /atrp setup." end
  ns.char.profileID = id
  return true, (TRP.Current() or {}).profileName or id
end
