-- Scheduling, the first-time setup prompt, slash commands, the settings panel and the
-- preview window.
local _, ns = ...

local U = ns.U
local TRP = ns.TRP
local UI = {}
ns.UI = UI

---------------------------------------------------------------------------
-- What goes where
---------------------------------------------------------------------------
local FAST = { walkup = true, currently = true, glance_mood = true, glance_lately = true, glance_company = true, glance_marks = true }

local function values(sheet)
  local v = {
    currently = sheet.currently, title = sheet.title, fulltitle = sheet.fulltitle,
    residence = sheet.residence, birthplace = sheet.birthplace, motto = sheet.motto,
    nickname = sheet.nickname, icon = sheet.icon, bearing = sheet.bearing, history = sheet.history,
    physical = sheet.physical, traits = sheet.traits, relationship = sheet.relationship, ooc = sheet.ooc,
    walkup = sheet.walkup,
    namecolour = sheet.namecolour, music = sheet.music,   -- 0.21.0 (Register.lua)
    glance_mood = sheet.glances.mood, glance_lately = sheet.glances.lately,
    glance_company = sheet.glances.company, glance_ambition = sheet.glances.ambition,
    glance_marks = sheet.glances.marks,
  }
  for _, st in ipairs(ns.Compose.STATS) do v["stat_" .. st.key] = sheet.stats and sheet.stats[st.key] end
  return v
end

local lastFast, lastSlow, slowDue = 0, 0, true
UI.STORY_GAP = 30      -- seconds, at least, between story rewrites when something happens
UI.STORY_EVERY = 300   -- and a refresh of the story this often regardless

-- force: write everything now. Otherwise "Currently" and the glances are written whenever
-- they've changed (at most every few seconds), and the story when something happened.
function UI.Update(force, fresh, mood)
  if not ns.char or not ns.db.enabled then return end
  if not TRP.Managed() then return end
  -- Nothing is written in combat, so don't work it out either: leaving combat catches up.
  if U.Call(InCombatLockdown) or U.Call(UnitAffectingCombat, "player") then
    if force then ns.Print("Not updated: in combat.") end
    return
  end
  local now = U.Now()
  local only = {}
  local any = false
  local paused = ns.db.pauseOOC and TRP.IsOOC()
  local gap = ns.db.currentlyEvery or 15
  if not paused and (force or now - lastFast >= gap) then
    for k in pairs(FAST) do only[k] = true end
    any = true
  end
  -- The OOC line says what you're doing out of character, so it isn't paused with the rest.
  if ns.db.fields.ooc_doing and (force or now - lastFast >= gap) then only.ooc, any = true, true end
  if force or (slowDue and now - lastSlow >= UI.STORY_GAP) or now - lastSlow >= UI.STORY_EVERY then
    for k in pairs(TRP.FIELDS) do if not FAST[k] then only[k] = true end end
    any = true
  end
  if not any then
    -- Too soon: come back when the gap has passed (unless paused, when the ticker will do).
    if not paused then UI.Later(math.max(1, gap - (now - lastFast))) end
    return
  end
  local sheet = ns.Compose.Sheet(fresh, mood, only)
  local changed, why = TRP.Apply(values(sheet), only)
  if not changed then
    if force then ns.Print("Not updated: " .. tostring(why) .. ".") end
    return
  end
  -- The gap only counts from a real write, so a quiet minute never delays the next change.
  local wroteFast = false
  for _, k in ipairs(changed) do if FAST[k] then wroteFast = true end end
  if wroteFast then lastFast = now end
  if only.history then lastSlow, slowDue = now, false end
  UI.NoteWrite(changed, now)
  if force then
    if #changed > 0 then
      local names = {}
      for i, k in ipairs(changed) do names[i] = TRP.LABELS[k] or k end
      table.sort(names)
      ns.Print("Updated: " .. table.concat(names, ", ") .. ".")
    else
      ns.Print("Your profile is already up to date.")
    end
  end
end

---------------------------------------------------------------------------
-- Reacting: game events ask for a pass soon. Several events in a burst make one pass.
---------------------------------------------------------------------------
local pending, lastReact = false, 0
UI.DEBOUNCE = 1.5

-- One pass: read everything, notice news, update mood, badge and profile.
function UI.React()
  pending = false
  if not ns.char then return end
  if U.Call(InCombatLockdown) or U.Call(UnitAffectingCombat, "player") then return end
  lastReact = U.Now()
  ns.Compose.Refresh()
  ns.Mood.Watch()
  local mood = ns.Mood.Current(ns.cache.world)
  ns.Mood.Note(mood)
  UI.UpdateBadge(mood)
  UI.Update(false, true, mood)
end

function UI.Later(seconds)
  if pending then return end
  pending = true
  ns.After(seconds, UI.React)
end

-- story: the History/About side should catch up too.
function UI.Poke(story)
  if story then slowDue = true end
  if pending then return end
  if U.Call(InCombatLockdown) or U.Call(UnitAffectingCombat, "player") then return end
  local wait = UI.DEBOUNCE
  local since = U.Now() - lastReact
  if since < 3 then wait = math.max(wait, 3 - since) end
  UI.Later(wait)
end

local FAST_EVENTS = {
  "ZONE_CHANGED", "ZONE_CHANGED_INDOORS", "ZONE_CHANGED_NEW_AREA", "PLAYER_UPDATE_RESTING",
  "PLAYER_REGEN_ENABLED", "PLAYER_ALIVE", "PLAYER_UNGHOST", "GROUP_ROSTER_UPDATE",
  "PLAYER_MOUNT_DISPLAY_CHANGED", "UPDATE_SHAPESHIFT_FORM", "PLAYER_CONTROL_LOST", "PLAYER_CONTROL_GAINED",
  "MAIL_SHOW", "BANKFRAME_OPENED", "AUCTION_HOUSE_SHOW", "MERCHANT_SHOW", "TRAINER_SHOW",
  "TRADE_SKILL_SHOW", "CRAFT_SHOW", "TAXIMAP_OPENED", "CHAT_MSG_LOOT", "CHAT_MSG_TEXT_EMOTE",
  "PLAYER_MONEY", "BAG_UPDATE_DELAYED", "UPDATE_STEALTH", "PLAYER_FLAGS_CHANGED",
  "GOSSIP_SHOW", "QUEST_DETAIL", "QUEST_GREETING", "ITEM_TEXT_BEGIN", "DUEL_REQUESTED", "DUEL_INBOUNDS",
  "DUEL_FINISHED",
}
local STORY_EVENTS = {
  "PLAYER_DEAD", "PLAYER_LEVEL_UP", "ENCOUNTER_END", "QUEST_TURNED_IN", "GOSSIP_CLOSED", "QUEST_FINISHED",
  "PLAYER_EQUIPMENT_CHANGED", "UPDATE_FACTION", "PLAYER_GUILD_UPDATE", "SKILL_LINES_CHANGED", "LEARNED_SPELL_IN_TAB", "LEARNED_SPELL_IN_SKILL_LINE",
}
for _, e in ipairs(FAST_EVENTS) do ns.On(e, function() UI.Poke(false) end) end
for _, e in ipairs(STORY_EVENTS) do ns.On(e, function() UI.Poke(true) end) end
ns.OnUnit("UNIT_AURA", "player", function() UI.Poke(false) end)
ns.OnUnit("UNIT_PET", "player", function() UI.Poke(false) end)
ns.OnUnit("UNIT_SPELLCAST_CHANNEL_START", "player", function() UI.Poke(false) end)
ns.OnUnit("UNIT_SPELLCAST_START", "player", function(_, _, _, spellID)
  if spellID == 8690 or spellID == 556 then UI.Poke(false) end
end)
ns.Listen("MOOD_CHANGED", function() UI.Poke(false) end)

-- The other addons don't announce their changes, so glance at a few counters every five
-- seconds (cheap: no reading of the data itself) and react when one moves.
local function pulse()
  local r, c, sd = _G.RPGDialogueCharDB, _G.ChronicleCharDB, _G.SocialDiaryCharDB
  local parts = {}
  if type(r) == "table" then
    parts[#parts + 1] = tostring(r.conversations)
    parts[#parts + 1] = tostring(type(r.journal) == "table" and #r.journal or 0)
    parts[#parts + 1] = tostring(r.deathCount)
    parts[#parts + 1] = tostring(type(r.insanity) == "table" and r.insanity.level or 0)
    parts[#parts + 1] = tostring(r.drunk)
  end
  if type(_G.Chronicle) == "table" and type(_G.Chronicle.char) == "table" then c = _G.Chronicle.char end
  if type(c) == "table" then
    parts[#parts + 1] = tostring(type(c.events) == "table" and #c.events or 0)
    parts[#parts + 1] = tostring(type(c.goals) == "table" and #c.goals or 0)
    parts[#parts + 1] = tostring(type(c.quests) == "table" and #c.quests or 0)
    local q = type(c.quests) == "table" and c.quests[1]
    parts[#parts + 1] = tostring(type(q) == "table" and q.time or 0)
  end
  local acct = _G.SocialDiaryDB
  local diary = (type(acct) == "table" and type(acct.settings) == "table" and acct.settings.shareDiary and type(acct.shared) == "table" and acct.shared)
    or (type(sd) == "table" and type(sd.data) == "table" and sd.data) or nil
  if diary then
    local n = 0
    for _ in pairs(type(diary.diary) == "table" and diary.diary or {}) do n = n + 1 end
    parts[#parts + 1] = tostring(n)
  end
  return table.concat(parts, ":")
end
local lastPulse
ns.Listen("LOGIN", function()
  lastPulse = pulse()
  ns.Ticker(5, function()
    local now = pulse()
    if now ~= lastPulse then lastPulse = now; ns.Compose.SourcesChanged(); UI.Poke(true) end
  end)
end)

---------------------------------------------------------------------------
-- First run
---------------------------------------------------------------------------
StaticPopupDialogs["AUTOTRP_SETUP"] = {
  text = "|cffc8a165Auto TRP|r can keep your Total RP 3 profile up to date with your story: your mood, where you are, your history and the people you've met.\n\nIt will make a new profile, a copy of your current one, and only ever write to that. Anything you edit there yourself stays yours.",
  button1 = "Make the profile",
  button2 = "Not now",
  button3 = "Use my current profile",
  OnAccept = function() UI.Setup() end,
  OnCancel = function()
    -- Escape and "Not now" look the same to the popup, so ask again on a later login,
    -- and stop after the third no.
    ns.char.declines = (ns.char.declines or 0) + 1
    if ns.char.declines >= 3 then ns.char.declined = true end
    ns.Print("No problem. |cffffd100/atrp setup|r whenever you'd like.")
  end,
  OnAlt = function() UI.UseCurrent() end,
  timeout = 0, whileDead = true, hideOnEscape = true, preferredIndex = 3,
}

function UI.Setup()
  local ok, msg = TRP.Setup()
  if ok then
    ns.Print("Made and selected the profile |cffffd100" .. msg .. "|r. Writing it now.")
    ns.After(1, function() UI.Update(true) end)
  else
    ns.Print("Couldn't make a profile: " .. tostring(msg))
  end
end

function UI.UseCurrent()
  local ok, msg = TRP.UseCurrent()
  if ok then
    ns.Print("Using |cffffd100" .. tostring(msg) .. "|r. Your own text there stays as it is.")
    ns.After(1, function() UI.Update(true) end)
  else
    ns.Print("Can't use this profile: " .. tostring(msg))
  end
end

local function firstRun(tries)
  if not TRP.Loaded() then return end
  if not TRP.CurrentID() then
    if tries < 10 then ns.After(3, function() firstRun(tries + 1) end) end
    return
  end
  if ns.char.profileID or ns.char.declined or UI.askedThisSession then return end
  UI.askedThisSession = true
  if U.Call(InCombatLockdown) then ns.After(10, function() firstRun(tries) end) return end
  UI.ShowFirstRun()
end

local warnedOther = false
ns.Listen("LOGIN", function()
  ns.char.seedName = (U.Call(UnitName, "player") or "") .. "-" .. (U.Call(GetRealmName) or "")
  ns.After(6, function() firstRun(0) end)
  ns.Ticker(ns.Mood.TICK, function()
    ns.Mood.Road(ns.Mood.TICK)
    if U.Call(InCombatLockdown) or U.Call(UnitAffectingCombat, "player") then return end
    ns.Compose.Refresh()
    ns.Mood.Watch()
    ns.Mood.CheckHome()
    local mood = ns.Mood.Current(ns.cache.world)
    ns.Mood.Log(mood, ns.cache.world)
    ns.Mood.Note(mood)
    UI.UpdateBadge(mood)
    local profile, why = TRP.Managed()
    if profile then
      warnedOther = false
      UI.Update(false, true, mood)
    elseif ns.char.profileID and why and why:find("different") and not warnedOther then
      warnedOther = true
      if not ns.db.quiet then ns.Print("You've switched Total RP 3 profiles, so Auto TRP is pausing. Switch back, or |cffffd100/atrp use|r this one.") end
    end
  end)
  ns.After(10, function() UI.Update(false) end)
end)

---------------------------------------------------------------------------
-- Welcome: the first-run window
---------------------------------------------------------------------------
UI.WELCOME_LINES = {
  "Auto TRP writes your Total RP 3 profile for you, from what your character does, feels and goes through.",
  "It works on its own copy of your profile, and never writes over words you wrote yourself.",
  "Total RP 3 is all it needs. RPG Dialogue, Social Diary and Chronicle give it more to tell.",
}

local function welcomeButton(f, text, w, tip, fn)
  local b = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  b:SetSize(w, 24)
  b:SetText(text)
  b:SetScript("OnClick", fn)
  if UI.Tooltip then UI.Tooltip(b, text, tip) end
  return b
end

function UI.BuildWelcome()
  if UI.welcomeFrame then return UI.welcomeFrame end
  local f = CreateFrame("Frame", "AutoTRPWelcome", UIParent, "BasicFrameTemplateWithInset")
  f:SetSize(460, 214)
  f:SetPoint("CENTER", 0, 80)
  f:SetFrameStrata("DIALOG")
  f:SetMovable(true)
  f:EnableMouse(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", function(self) self:StartMoving() end)
  f:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
  f:Hide()
  f.chose = false
  local title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  title:SetPoint("TOP", 0, -5)
  title:SetText("Welcome to Auto TRP")
  local icon = f:CreateTexture(nil, "ARTWORK")
  icon:SetSize(40, 40)
  icon:SetPoint("TOPLEFT", 18, -36)
  icon:SetTexture("Interface\\Icons\\INV_Misc_Book_11")
  local text = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  text:SetPoint("TOPLEFT", icon, "TOPRIGHT", 12, 0)
  text:SetPoint("RIGHT", -18, 0)
  text:SetJustifyH("LEFT")
  text:SetSpacing(4)
  text:SetText(table.concat(UI.WELCOME_LINES, "\n"))

  -- Closing it without choosing counts as "not now": asked again on a later login, and
  -- not after the third time.
  f:SetScript("OnHide", function(self)
    if self.chose == true then return end
    ns.char.declines = (ns.char.declines or 0) + 1
    if ns.char.declines >= 3 then ns.char.declined = true end
    ns.Print("No problem. |cffffd100/atrp setup|r whenever you'd like, or |cffffd100/atrp welcome|r to see this again.")
  end)
  local function choose(fn)
    return function() f.chose = true; f:Hide(); fn() end
  end
  f.buttons = {
    make = welcomeButton(f, "Make my Auto TRP profile", 200,
      "Copies your current Total RP 3 profile as \"Name (Auto TRP)\", switches to it, and writes it now.", choose(UI.Setup)),
    use = welcomeButton(f, "Use my current profile", 200,
      "Auto TRP writes to the profile you're using now. Fields that already have your text stay yours.", choose(UI.UseCurrent)),
    settings = welcomeButton(f, "Settings", 120, "Look at what it writes first. This window comes back on your next login.",
      choose(function() UI.OpenSettings() end)),
    never = welcomeButton(f, "Don't ask again", 140, "Auto TRP stays idle on this character. /atrp setup starts it any time.",
      choose(function()
        ns.char.declined = true
        ns.Print("It won't ask again on this character. |cffffd100/atrp setup|r whenever you'd like.")
      end)),
  }
  local b = f.buttons
  b.make:SetPoint("BOTTOMLEFT", 22, 46)
  b.use:SetPoint("LEFT", b.make, "RIGHT", 16, 0)
  b.settings:SetPoint("BOTTOMLEFT", 22, 16)
  b.never:SetPoint("BOTTOMRIGHT", -22, 16)
  tinsert(UISpecialFrames, "AutoTRPWelcome")
  UI.welcomeFrame = f
  return f
end

-- again: shown on request (/atrp welcome), so closing it isn't a "no".
function UI.ShowWelcome(again)
  local f = UI.BuildWelcome()
  f.chose = again and true or false
  f:Show()
  return f
end

-- The first-run prompt: the welcome window, or the plain popup if that can't be made.
function UI.ShowFirstRun()
  local ok = pcall(UI.ShowWelcome)
  if not ok then StaticPopup_Show("AUTOTRP_SETUP") end
end

---------------------------------------------------------------------------
-- Preview
---------------------------------------------------------------------------
-- How each field stands, in a word or two.
local STATUS_WORDS = { auto = "|cff80ff80Auto TRP's|r", yours = "|cffffd100yours, left alone|r", off = "|cff808080switched off|r", waiting = "|cffaaaaaanot written yet|r" }
UI.STATUS_WORDS = STATUS_WORDS

-- "|T...|t" for an icon name, file path or file ID.
function UI.IconString(ic, size)
  if ic == nil or ic == "" then return "" end
  size = size or 16
  local path = tostring(ic)
  if type(ic) == "string" and not ic:find("\\") then path = "Interface\\Icons\\" .. ic end
  return ("|T%s:%d:%d|t "):format(path, size, size)
end

-- Total RP 3's colour markup shown as the game's, or taken out for copying.
local function shown(text)
  if type(text) ~= "string" then return text end
  return (text:gsub("{col:(%x%x%x%x%x%x)}", "|cff%1"):gsub("{/col}", "|r"))
end
local function plainCopy(text)
  if type(text) ~= "string" then return "" end
  return U.Plain((text:gsub("{col:%x+}", ""):gsub("{/col}", ""))) or ""
end
UI.CopyText = plainCopy

UI.PREVIEW_TABS = { "Now", "About", "Names and titles", "Statistics" }
local GLANCES = { "mood", "lately", "company", "ambition", "marks" }

-- What the profile would say, as tabs of rows. A row: key (the field, nil for the mood),
-- label, icon, title (a glance's), text, note (grey, not copied), status.
function UI.PreviewSections(s)
  s = s or ns.Compose.Sheet()
  local tabs = {}
  for i, name in ipairs(UI.PREVIEW_TABS) do tabs[i] = { name = name, rows = {} } end
  local function add(t, key, text, extra)
    extra = extra or {}
    if text == "" then text = nil end
    local rows = tabs[t].rows
    rows[#rows + 1] = {
      key = key, label = extra.label or (key and TRP.LABELS[key]) or key, icon = extra.icon, title = extra.title,
      text = text, note = extra.note, empty = extra.empty, status = key and TRP.Status(key) or nil,
    }
  end

  -- Now: mood, Currently, the glances.
  local why = s.mood.reasons and (" (" .. table.concat(s.mood.reasons, ", ") .. ")") or ""
  add(1, nil, s.mood.title .. why, { label = "Mood", icon = s.mood.icon, note = s.mood.tell })
  add(1, "currently", s.currently)
  for _, g in ipairs(GLANCES) do
    local v = s.glances[g]
    local slot = TRP.GlanceSlot(g)
    add(1, "glance_" .. g, v and v.TX, {
      label = (TRP.LABELS["glance_" .. g] or g) .. (slot > 0 and ("  |cff808080slot " .. slot .. "|r") or "  |cff808080no slot|r"),
      icon = v and v.IC, title = v and v.TI, empty = "nothing to say yet",
    })
  end

  -- About: the trait bars and the three About sections.
  local traits
  if s.traits then
    local t = {}
    for _, b in ipairs(s.traits) do t[#t + 1] = ("%s %d / %d %s"):format(b.LT, b.V2, 20 - b.V2, b.RT) end
    traits = table.concat(t, "\n")
  end
  add(2, "traits", traits)
  add(2, "bearing", s.bearing)
  add(2, "history", s.history)
  add(2, "physical", s.physical)

  -- Names and titles.
  add(3, "title", s.title)
  add(3, "fulltitle", s.fulltitle)
  local e = ns.Compose.Earned()
  local from = e and e.deed and U.Cap(e.deed) .. "." or nil
  local others = {}
  for _, o in ipairs(ns.Compose.EarnedAll()) do if o ~= e then others[#others + 1] = o.nick end end
  local also = #others > 0 and ("Also earned: " .. U.Join(others) .. " (/atrp names, /atrp name <n>).") or nil
  add(3, "nickname", s.nickname, {
    note = (from and also) and (from .. " " .. also) or from or also,
    empty = "earned by a story, quest chain, master or bounty you saw through",
  })
  add(3, "motto", s.motto, { note = from, empty = "comes with the deed behind the nickname" })
  add(3, "icon", s.icon, { icon = s.icon })
  add(3, "residence", s.residence)
  add(3, "birthplace", s.birthplace)
  add(3, "relationship", s.relationship and ({ [2] = "Taken", [3] = "Married" })[s.relationship])
  add(3, "ooc", s.ooc)
  add(3, "namecolour", s.namecolour and ("|cff" .. s.namecolour .. s.namecolour .. "|r"), { empty = "from your class colour" })
  add(3, "music", s.music and (tostring(s.musicName) .. " (" .. tostring(s.music) .. ")"), { empty = "your home's music, or where you are" })
  add(3, "walkup", s.walkup == 2 and "Open to walk-ups" or s.walkup == 1 and "Not open to walk-ups" or nil, { empty = "no change" })

  -- Statistics.
  for _, st in ipairs(ns.Compose.STATS) do
    if not st.retired then add(4, "stat_" .. st.key, s.stats and s.stats[st.key], { icon = st.icon }) end
  end
  return tabs, s
end

-- The same as text, for chat and the offline test.
function UI.PreviewText()
  local out = {}
  for _, tab in ipairs(UI.PreviewSections()) do
    for _, r in ipairs(tab.rows) do
      if not r.key then
        out[#out + 1] = "|cffc8a165" .. r.label .. "|r  " .. r.text
      else
        out[#out + 1] = "|cffc8a165" .. (TRP.LABELS[r.key] or r.key) .. "|r  " .. STATUS_WORDS[r.status]
        if r.text then
          out[#out + 1] = (r.title and (r.title .. ": ") or "") .. r.text
          if r.note then out[#out + 1] = "    |cff808080" .. r.note .. "|r" end
        else
          out[#out + 1] = "|cff808080(nothing yet" .. (r.empty and (": " .. r.empty) or "") .. ")|r"
        end
      end
      out[#out + 1] = ""
    end
  end
  return table.concat(out, "\n")
end

-- Height of a font string's text at a width: measured when the game can, else a fair guess.
local function textHeight(fs, text, width, lineH)
  local h = fs.GetStringHeight and fs:GetStringHeight()
  if type(h) == "number" and h > 0 then return h end
  local plain = U.Plain(text or "") or ""
  local per = math.max(10, math.floor(width / 6))
  local lines = 0
  for para in ((text or "") .. "\n"):gmatch("(.-)\n") do
    lines = lines + math.max(1, math.ceil(#(U.Plain(para) or "") / per))
  end
  if plain == "" then lines = 1 end
  return lines * (lineH or 14)
end
UI.TextHeight = textHeight

-- A read-only box holding a field's text in one line: click it, then Ctrl+C.
local function copyBox(parent)
  local b = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
  b:SetSize(150, 18)
  b:SetAutoFocus(false)
  b:SetFontObject(ChatFontSmall or ChatFontNormal)
  b:SetScript("OnTextChanged", function(self, user)
    if user then self:SetText(self.full or ""); self:HighlightText() end
  end)
  b:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
  b:SetScript("OnEditFocusLost", function(self) self:HighlightText(0, 0); self:SetCursorPosition(0) end)
  b:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
  b:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
  b:SetScript("OnEnter", function(self)
    if not GameTooltip then return end
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:AddLine("Copy")
    GameTooltip:AddLine("Click, then Ctrl+C. The text comes without colours or line breaks.", 0.8, 0.8, 0.8, true)
    GameTooltip:Show()
  end)
  b:SetScript("OnLeave", function() if GameTooltip then GameTooltip:Hide() end end)
  return b
end

local function previewRow(f)
  local c = f.content
  local r = {}
  r.head = c:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  r.head:SetJustifyH("LEFT")
  r.copy = copyBox(c)
  r.body = c:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  r.body:SetJustifyH("LEFT")
  r.body:SetJustifyV("TOP")
  r.note = c:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
  r.note:SetJustifyH("LEFT")
  f.rows[#f.rows + 1] = r
  return r
end

local function savePreviewPlace(f)
  local point, _, relPoint, x, y = f:GetPoint()
  if not point then return end
  local pos = { point = point, relPoint = relPoint, x = x, y = y }
  local w, h = f:GetWidth(), f:GetHeight()
  if type(w) == "number" and type(h) == "number" then pos.w, pos.h = math.floor(w + 0.5), math.floor(h + 0.5) end
  ns.db.previewPos = pos
end

-- Lays out the chosen tab. Only runs on opening, a tab click, Refresh and a finished resize.
function UI.RenderPreview()
  local f = UI.previewFrame
  if not f then return end
  local tab = f.data and f.data[f.tab]
  for i, b in ipairs(f.tabs) do if i == f.tab then b:LockHighlight() else b:UnlockHighlight() end end
  local fw = f:GetWidth()
  local width = math.max(300, (type(fw) == "number" and fw or 560) - 64)
  f.content:SetWidth(width)
  local y = -4
  local n = 0
  if f.combat then
    f.notice:SetText("In combat: the preview catches up afterwards.")
  else
    f.notice:SetText("")
  end
  for _, row in ipairs(tab and tab.rows or {}) do
    n = n + 1
    local r = f.rows[n] or previewRow(f)
    local status = row.status and ("  " .. STATUS_WORDS[row.status]) or ""
    r.head:ClearAllPoints()
    r.head:SetPoint("TOPLEFT", 0, y)
    r.head:SetWidth(width - 160)
    r.head:SetText(UI.IconString(row.icon) .. "|cffc8a165" .. row.label .. "|r" .. (row.title and ("  " .. row.title) or "") .. status)
    r.head:Show()
    local copy = row.text and plainCopy(row.text) or ""
    r.copy.full = copy
    r.copy:ClearAllPoints()
    r.copy:SetPoint("TOPRIGHT", f.content, "TOPRIGHT", -4, y + 2)
    r.copy:SetText(copy)
    r.copy:SetCursorPosition(0)
    if copy ~= "" then r.copy:Show() else r.copy:Hide() end
    y = y - math.max(20, textHeight(r.head, r.head:GetText(), width - 160, 14) + 6)
    local body = row.text and shown(row.text) or ("|cff808080(nothing yet" .. (row.empty and (": " .. row.empty) or "") .. ")|r")
    r.body:ClearAllPoints()
    r.body:SetPoint("TOPLEFT", 8, y)
    r.body:SetWidth(width - 12)
    r.body:SetText(body)
    r.body:Show()
    y = y - textHeight(r.body, body, width - 12, 14) - 4
    if row.note then
      r.note:ClearAllPoints()
      r.note:SetPoint("TOPLEFT", 8, y)
      r.note:SetWidth(width - 12)
      r.note:SetText(row.note)
      r.note:Show()
      y = y - textHeight(r.note, row.note, width - 12, 12) - 4
    else
      r.note:Hide()
    end
    y = y - 10
  end
  for i = n + 1, #f.rows do
    local r = f.rows[i]
    r.head:Hide(); r.body:Hide(); r.note:Hide(); r.copy:Hide()
  end
  f.content:SetHeight(-y + 10)
end

function UI.PreviewTab(i)
  local f = UI.previewFrame
  if not f or not f.data or not f.data[i] then return end
  f.tab = i
  ns.db.previewTab = i
  UI.RenderPreview()
end

function UI.BuildPreview()
  if UI.previewFrame then return UI.previewFrame end
  local f = CreateFrame("Frame", "AutoTRPPreview", UIParent, "BasicFrameTemplateWithInset")
  f:SetSize(580, 600)
  f:SetPoint("CENTER")
  local pos = ns.db.previewPos
  if type(pos) == "table" and pos.point then
    f:ClearAllPoints()
    f:SetPoint(pos.point, UIParent, pos.relPoint or pos.point, pos.x or 0, pos.y or 0)
    if pos.w and pos.h then f:SetSize(pos.w, pos.h) end
  end
  f:SetMovable(true)
  f:SetResizable(true)
  if f.SetResizeBounds then f:SetResizeBounds(420, 320, 1200, 1400) elseif f.SetMinResize then f:SetMinResize(420, 320) end
  f:SetClampedToScreen(true)
  f:EnableMouse(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", function(self) self:StartMoving() end)
  f:SetScript("OnDragStop", function(self) self:StopMovingOrSizing(); savePreviewPlace(self) end)
  f:SetFrameStrata("DIALOG")
  f:Hide()
  f.data, f.combat = {}, false

  local title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  title:SetPoint("TOP", 0, -5)
  title:SetText("Auto TRP: what your profile would say")

  f.tabs = {}
  for i, name in ipairs(UI.PREVIEW_TABS) do
    local b = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    b:SetSize(i == 3 and 130 or 100, 22)
    if i == 1 then b:SetPoint("TOPLEFT", 12, -30) else b:SetPoint("LEFT", f.tabs[i - 1], "RIGHT", 4, 0) end
    b:SetText(name)
    b:SetScript("OnClick", function() UI.PreviewTab(i) end)
    f.tabs[i] = b
  end

  local legend = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  legend:SetPoint("TOPLEFT", 14, -58)
  legend:SetPoint("RIGHT", -14, 0)
  legend:SetJustifyH("LEFT")
  legend:SetText(STATUS_WORDS.auto .. ": it keeps this up to date.   " .. STATUS_WORDS.yours .. ": you wrote it, it isn't touched.")
  f.notice = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  f.notice:SetPoint("TOPLEFT", legend, "BOTTOMLEFT", 0, -2)

  local scroll = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
  scroll:SetPoint("TOPLEFT", 12, -86)
  scroll:SetPoint("BOTTOMRIGHT", -32, 44)
  f.content = CreateFrame("Frame", nil, scroll)
  f.content:SetSize(516, 400)
  scroll:SetScrollChild(f.content)
  f.rows = {}

  local hint = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  hint:SetPoint("BOTTOMLEFT", 16, 18)
  hint:SetText("Each box on the right holds a field's text: click it, then Ctrl+C.")

  local write = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  write:SetSize(110, 24)
  write:SetPoint("BOTTOMRIGHT", -24, 12)
  write:SetText("Write it now")
  write:SetScript("OnClick", function() UI.Update(true); f.Refresh() end)
  local refresh = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  refresh:SetSize(80, 24)
  refresh:SetPoint("RIGHT", write, "LEFT", -4, 0)
  refresh:SetText("Refresh")
  refresh:SetScript("OnClick", function() f.Refresh() end)
  local settings = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  settings:SetSize(80, 24)
  settings:SetPoint("RIGHT", refresh, "LEFT", -4, 0)
  settings:SetText("Settings")
  settings:SetScript("OnClick", function() f:Hide(); UI.OpenSettings() end)

  -- Drag the corner to resize; the text is laid out again when you let go.
  local grip = CreateFrame("Button", nil, f)
  grip:SetSize(16, 16)
  grip:SetPoint("BOTTOMRIGHT", -4, 4)
  grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
  grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
  grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
  grip:SetScript("OnMouseDown", function() f:StartSizing("BOTTOMRIGHT") end)
  grip:SetScript("OnMouseUp", function() f:StopMovingOrSizing(); savePreviewPlace(f); UI.RenderPreview() end)

  -- Nothing is worked out in combat: the last preview stays, with a note.
  function f.Refresh()
    if U.Call(InCombatLockdown) or U.Call(UnitAffectingCombat, "player") then
      f.combat = true
    else
      f.combat = false
      f.data = UI.PreviewSections()
    end
    UI.RenderPreview()
  end

  f.tab = (UI.PREVIEW_TABS[ns.db.previewTab or 1] and ns.db.previewTab) or 1
  tinsert(UISpecialFrames, "AutoTRPPreview")
  UI.previewFrame = f
  return f
end

function UI.Preview()
  local f = UI.BuildPreview()
  f.Refresh()
  f:Show()
end

---------------------------------------------------------------------------
-- Settings panel
---------------------------------------------------------------------------
local OPTIONS = {
  { head = "What Auto TRP writes" },
  { path = { "fields", "currently" }, label = "Currently: your mood, what you're doing and where" },
  { path = { "fields", "glances" }, label = "At first glance (all five slots below)" },
  { path = { "fields", "glance_mood" }, label = "   1: Mood, what a stranger notices" },
  { path = { "fields", "glance_lately" }, label = "   2: Lately, the freshest news" },
  { path = { "fields", "glance_company" }, label = "   3: Company, who you travel with" },
  { path = { "fields", "glance_ambition" }, label = "   4: Ambition, what you're after" },
  { path = { "fields", "glance_marks" }, label = "   5: Marks, scars, gear and tells" },
  { path = { "fields", "traits" }, label = "Personality traits, from your choices in conversation" },
  { path = { "fields", "bearing" }, label = "About: Personality (temperament and beliefs)" },
  { path = { "fields", "history" }, label = "About: History (origin, roads, people, deeds)" },
  { path = { "fields", "physical" }, label = "About: Physical (build, gear, scars)" },
  { path = { "fields", "title" }, label = "Title: your rank by experience (\"Initiate\")" },
  { path = { "fields", "fulltitle" }, label = "Full title: alignment and standing (\"Lightsworn, Friend of Goldshire\")" },
  { path = { "fields", "nickname" }, label = "Nickname: earned by a story, quest chain, master or bounty you saw through (/atrp names)" },
  { path = { "fields", "motto" }, label = "Motto: the saying that deed left you with" },
  { path = { "fields", "icon" }, label = "Icon: your nickname's, else your class crest" },
  { path = { "fields", "residence" }, label = "Residence: where your hearthstone is" },
  { path = { "fields", "birthplace" }, label = "Birthplace" },
  { path = { "fields", "relationship" }, label = "Relationship status, from a partner in Social Diary" },
  { path = { "fields", "ooc" }, label = "OOC note saying the profile updates itself" },
  { path = { "fields", "ooc_doing" }, label = "OOC: what you're doing (\"Levelling in Duskwood\", \"Looking for a group\")" },
  { path = { "fields", "namecolour" }, label = "Name colour: your class colour" },
  { path = { "fields", "music" }, label = "Profile music: your home's music (else where you are)" },
  { path = { "fields", "walkup" }, label = "Open to walk-ups follows your mood" },
  { head = "Statistics (Additional information on the Characteristics tab)" },
  { path = { "fields", "stats" }, label = "Write statistics (all of them; the switches below pick which)" },
  { head = "Where it looks" },
  { path = { "sources", "rpgd" }, label = "RPG Dialogue" },
  { path = { "sources", "socialDiary" }, label = "Social Diary" },
  { path = { "sources", "chronicle" }, label = "Chronicle" },
  { head = "Details" },
  { path = { "diaryExcerpt" }, label = "Quote your latest diary entry in History" },
  { path = { "journalInProfile" }, label = "Quote your Auto TRP journal in History and Lately when nothing's fresher (/atrp journal)" },
  { path = { "richText" }, label = "Colour quotes and item names on the About page" },
  { path = { "chronicleGoals" }, label = "Share your open Chronicle goal as an ambition" },
  { path = { "nameFriends" }, label = "Name the players you marked as friends in Social Diary" },
  { path = { "pauseOOC" }, label = "Pause Currently and glances while out of character" },
  { path = { "reactPeople" }, label = "Friends, foes and enemies you target move your mood" },
  { path = { "reactPlaces" }, label = "Places and spells that matter to your race and class" },
  { path = { "moodNotes" }, label = "A quiet chat line when your mood turns" },
  { path = { "showBadge" }, label = "Show the mood badge (drag to move)", after = function() UI.UpdateBadge() end },
  { path = { "quiet" }, label = "Quiet: no chat messages" },
}

local function getPath(path)
  local t = ns.db
  for i = 1, #path - 1 do t = t[path[i]] end
  return t, path[#path]
end

-- Every option at once, on or off ("Keep my profile up to date" is left as it is).
function UI.SetAllOptions(on)
  for _, opt in ipairs(OPTIONS) do
    if opt.path then
      local t, k = getPath(opt.path)
      t[k] = on and true or false
    end
  end
  -- And every field switch, including each statistic's own (letters and people met are
  -- retired and stay off).
  for k in pairs(ns.db.fields) do
    ns.db.fields[k] = on and k ~= "stat_met" and k ~= "stat_letters" or false
  end
  for _, opt in ipairs(OPTIONS) do if opt.path and opt.after then opt.after() end end
  UI.RefreshPanel()
end

UI.OPTIONS = OPTIONS

-- A line under each heading. Keyed by the heading's text, so new headings simply go without.
UI.HEAD_NOTES = {
  ["What Auto TRP writes"] = "Each field it can fill. A field you've edited yourself stays yours whatever these say.",
  ["Statistics (Additional information on the Characteristics tab)"] = "Plain counts, listed after your own entries. Switched off, they're taken down.",
  ["Where it looks"] = "Other addons it reads, never changes. Total RP 3 alone is enough.",
  ["Details"] = "Tone, privacy and chat.",
}

-- What each switch does, shown when you hover over it. Keyed by the option's path
-- ("fields.currently"); an option can also carry its own `tip`.
UI.TIPS = {
  ["fields.currently"] = "The \"Currently\" line: how you seem, what you're doing and where. Rewritten as things change, at most every 15 seconds.",
  ["fields.glances"] = "All five At first glance slots. Off hides them; the switches below pick single ones. /atrp slot moves them around.",
  ["fields.glance_mood"] = "What a stranger would notice about your mood right now.",
  ["fields.glance_lately"] = "The freshest news: a death, a victory, a story moving on, a new land.",
  ["fields.glance_company"] = "Your group, your Social Diary friends, where you're known, or travelling alone.",
  ["fields.glance_ambition"] = "Your Chronicle goal, an unfinished story, or the next rank on your road.",
  ["fields.glance_marks"] = "Wounds, drink, battered or remarkable gear, old scars; else what you wear and carry.",
  ["fields.traits"] = "The personality bars (Good/Evil, Kind/Cruel and the rest). From your RPG Dialogue choices, else leaning gently by race and class.",
  ["fields.bearing"] = "About, Personality: temperament, beliefs, the opinions you've voiced and the spell you reach for most.",
  ["fields.history"] = "About, History: where you came from, the latest news first, then your deeds, people and standing.",
  ["fields.physical"] = "About, Physical: your build, what you wear and carry, and how you are right now.",
  ["fields.title"] = "Your rank by experience, specific to your race and class.",
  ["fields.fulltitle"] = "Your alignment and where you're liked, kept modest.",
  ["fields.nickname"] = "A name earned by a deed. /atrp names lists yours; /atrp name <n> wears another.",
  ["fields.motto"] = "The saying that came with the deed behind your nickname.",
  ["fields.icon"] = "The profile's icon: your nickname's, else your class crest.",
  ["fields.residence"] = "The inn your hearthstone is set to.",
  ["fields.birthplace"] = "Your homeland, or the origin you chose in RPG Dialogue.",
  ["fields.relationship"] = "Married or Taken, if you've named a partner in Social Diary.",
  ["fields.ooc"] = "A short out-of-character note saying the profile updates itself.",
  ["fields.ooc_doing"] = "An out-of-character line on what you're doing: levelling somewhere, looking for a group, in a dungeon, or away. Off by default.",
  ["fields.namecolour"] = "Shows your name in your class colour on your profile.",
  ["fields.music"] = "Sets your profile's music to your home's zone music, or where you are, when the game has a match.",
  ["fields.walkup"] = "Marks you open to walk-ups when your mood is sociable, and not when it isn't.",
  ["fields.stats"] = "The Statistics entries under Additional information. Your own entries there stay as they are.",
  ["fields.stat_role"] = "The \"Role\" statistic: what you mostly do in a group's fights (healing, holding the foe, or striking), worked out from your own fights. Off, Auto TRP takes down what it wrote there.",
  ["fields.stat_speciality"] = "The \"Speciality\" statistic: your main talent tree and its points. Off, Auto TRP takes down what it wrote there.",
  ["sources.rpgd"] = "Your origin, alignment, choices, opinions, the people you've met, stories and diary.",
  ["sources.socialDiary"] = "The players you've marked as friends, a partner, and your recent groups.",
  ["sources.chronicle"] = "Goals, bosses, dungeons, rare beasts, professions and gear. Your private notes are never read.",
  ["diaryExcerpt"] = "A line from your latest RPG Dialogue diary entry at the end of History.",
  ["journalInProfile"] = "When nothing fresher has happened, History and Lately quote a line from your Auto TRP journal.",
  ["richText"] = "Uses Total RP 3's colour markup: quotes in cream, items in their quality colour.",
  ["chronicleGoals"] = "Your open Chronicle goal becomes the Ambition glance.",
  ["nameFriends"] = "Friends you marked in Social Diary are named on your profile. Off, they're left out.",
  ["pauseOOC"] = "While Total RP 3 shows you out of character, Currently and the glances stay as they are.",
  ["reactPeople"] = "Targeting someone from your records (a friend, a rival, an enemy) nudges your mood.",
  ["reactPlaces"] = "Places and spells that mean something to your race and class nudge your mood.",
  ["moodNotes"] = "A line in your own chat when your mood turns. Nobody else sees it.",
  ["showBadge"] = "The small mood icon on screen. Hover for why, click for the preview, drag to move.",
  ["quiet"] = "Keeps Auto TRP out of your chat unless you ask it something.",
}

function UI.TipFor(opt)
  if opt.tip then return opt.tip end
  if not opt.path then return nil end
  local key = table.concat(opt.path, ".")
  if UI.TIPS[key] then return UI.TIPS[key] end
  local stat = key:match("^fields%.stat_(.+)$")
  if stat then
    for _, st in ipairs(ns.Compose.STATS) do
      if st.key == stat then return "The \"" .. st.label .. "\" statistic. Off, Auto TRP takes down what it wrote there." end
    end
  end
  return nil
end

-- The options under each heading, in order: { head = text, items = { option, ... } }.
function UI.Groups()
  local groups, cur = {}, nil
  for _, opt in ipairs(OPTIONS) do
    if opt.head then
      cur = { head = opt.head, items = {} }
      groups[#groups + 1] = cur
    elseif opt.path and cur then
      cur.items[#cur.items + 1] = opt
    end
  end
  return groups
end

-- Every option under one heading, on or off; the rest stay as they are.
function UI.SetGroupOptions(head, on)
  for _, g in ipairs(UI.Groups()) do
    if g.head == head then
      for _, opt in ipairs(g.items) do
        local t, k = getPath(opt.path)
        t[k] = on and true or false
      end
      for _, opt in ipairs(g.items) do if opt.after then opt.after() end end
      UI.RefreshPanel()
      return true
    end
  end
  return false
end

-- What each addon brings. Total RP 3 alone is enough; the others add to it.
UI.SOURCES = {
  { name = "Total RP 3", loaded = function() return TRP.Loaded() end,
    adds = "all it needs: Currently, glances, titles, History, statistics from what the game records" },
  { name = "RPG Dialogue", key = "rpgd", loaded = function() return ns.Sources.RPGD.Loaded() end,
    adds = "origin, alignment and traits, opinions, people met, stories, diary" },
  { name = "Social Diary", key = "socialDiary", loaded = function() return ns.Sources.SocialDiary.Loaded() end,
    adds = "friends you've marked, a partner, recent groups" },
  { name = "Chronicle", key = "chronicle", loaded = function() return ns.Sources.Chronicle.Loaded() end,
    adds = "goals, bosses, dungeons, rare beasts, professions, gear" },
}

function UI.SourceLines()
  local out = {}
  for _, src in ipairs(UI.SOURCES) do
    local ok, loaded = pcall(src.loaded)
    loaded = ok and loaded
    local state
    if not loaded then
      state = src.key and "|cff808080not installed|r" or "|cffff6060not loaded|r"
    elseif src.key and ns.db.sources[src.key] == false then
      state = "|cffaaaaaafound, switched off below|r"
    else
      state = "|cff80ff80found|r"
    end
    out[#out + 1] = "|cffffd100" .. src.name .. "|r " .. state .. ": " .. (src.key and "adds " or "") .. src.adds
  end
  return out
end

function UI.StatusLine()
  local _, why = TRP.Managed()
  local where = {}
  if ns.Sources.RPGD.Loaded() then where[#where + 1] = "RPG Dialogue" end
  if ns.Sources.SocialDiary.Loaded() then where[#where + 1] = "Social Diary" end
  if ns.Sources.Chronicle.Loaded() then where[#where + 1] = "Chronicle" end
  local p = TRP.Managed() and ("Writing to |cffffd100" .. tostring((TRP.Current() or {}).profileName) .. "|r.") or ("Not writing: " .. tostring(why))
  return p .. "  Reading: " .. (#where > 0 and U.Join(where) or "the game only") .. "."
end

-- Hover text for any control: a title and a line of explanation.
local function tooltip(owner, title, text)
  owner:SetScript("OnEnter", function(self)
    if not GameTooltip then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine(title, 1, 1, 1, true)
    if text then GameTooltip:AddLine(text, 1, 0.82, 0, true) end
    GameTooltip:Show()
  end)
  owner:SetScript("OnLeave", function() if GameTooltip then GameTooltip:Hide() end end)
end
UI.Tooltip = tooltip

StaticPopupDialogs["AUTOTRP_RESTORE"] = {
  text = "Put your Total RP 3 profile back exactly as it was before Auto TRP first wrote to it?\n\nEvery field becomes yours again. |cffffd100/atrp claim all|r hands them back later.",
  button1 = "Restore", button2 = "Cancel",
  OnAccept = function() UI.Restore() end,
  timeout = 0, whileDead = true, hideOnEscape = true, preferredIndex = 3,
}

function UI.Restore()
  local ok, why = TRP.Restore()
  if ok then
    ns.Print("Your profile is back as it was. Every field is yours again; |cffffd100/atrp claim all|r hands them back to Auto TRP.")
  else
    ns.Print("Couldn't restore: " .. tostring(why))
  end
  UI.RefreshPanel()
  return ok
end

function UI.OpenJournalOrDays()
  if ns.Journal and type(ns.Journal.Show) == "function" then ns.Journal.Show()
  elseif type(UI.OpenJournal) == "function" then UI.OpenJournal()
  else UI.ListDays() end
end

function UI.OpenSettings()
  if U.Call(InCombatLockdown) then ns.Print("The settings open after combat.") return end
  if UI.category and Settings and Settings.OpenToCategory then
    Settings.OpenToCategory(UI.category:GetID())
  elseif InterfaceOptionsFrame_OpenToCategory and UI.panel then
    -- The old options window needs asking twice the first time.
    InterfaceOptionsFrame_OpenToCategory(UI.panel)
    InterfaceOptionsFrame_OpenToCategory(UI.panel)
  else
    UI.Preview()
  end
end

-- Puts every switch back in step with the saved settings.
function UI.RefreshPanel()
  local panel = UI.panel
  if not panel or panel.built ~= true then return end
  panel.enable:SetChecked(ns.db.enabled)
  for _, cb in ipairs(UI.boxes or {}) do
    local t, k = getPath(cb.path)
    cb:SetChecked(t[k] and true or false)
  end
  panel.status:SetText(UI.StatusLine())
  panel.sources:SetText(table.concat(UI.SourceLines(), "\n"))
end

-- The panel's frame is made at login (the settings window needs it); what's in it is made
-- the first time it's shown.
function UI.BuildPanel()
  if UI.panel then return UI.panel end
  local panel = CreateFrame("Frame")
  panel.name = "Auto TRP"
  panel.built = false
  panel:SetScript("OnShow", function(self)
    if self.built ~= true then UI.FillPanel(self) end
    UI.RefreshPanel()
  end)
  if Settings and Settings.RegisterCanvasLayoutCategory then
    local category = Settings.RegisterCanvasLayoutCategory(panel, "Auto TRP")
    Settings.RegisterAddOnCategory(category)
    UI.category = category
  elseif InterfaceOptions_AddCategory then
    InterfaceOptions_AddCategory(panel)
  end
  UI.panel = panel
  return panel
end

local COL_X, COL_W = { 8, 330 }, 300
UI.COLUMN_BREAK = { ["Where it looks"] = true }   -- headings that start the right-hand column

function UI.FillPanel(panel)
  panel.built = true
  local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", 16, -16)
  title:SetText("Auto TRP |cff8a8a8a" .. tostring(ns.VERSION) .. "|r")
  local status = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  status:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
  status:SetPoint("RIGHT", -16, 0)
  status:SetJustifyH("LEFT")
  panel.status = status
  local sources = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  sources:SetPoint("TOPLEFT", status, "BOTTOMLEFT", 0, -6)
  sources:SetPoint("RIGHT", -16, 0)
  sources:SetJustifyH("LEFT")
  sources:SetSpacing(2)
  panel.sources = sources

  local enable = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
  enable:SetPoint("TOPLEFT", sources, "BOTTOMLEFT", -4, -4)
  local enableLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  enableLabel:SetPoint("LEFT", enable, "RIGHT", 2, 0)
  enableLabel:SetText("Keep my profile up to date")
  enable:SetScript("OnClick", function(self)
    ns.db.enabled = self:GetChecked() and true or false
    UI.UpdateBadge()
  end)
  tooltip(enable, "Keep my profile up to date", "Off pauses Auto TRP: your profile stays exactly as it is. Right-clicking the mood badge does the same.")
  panel.enable = enable

  local function topButton(text, tip, fn, anchor)
    local b = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    b:SetSize(80, 22)
    if anchor then b:SetPoint("RIGHT", anchor, "LEFT", -6, 0) else b:SetPoint("RIGHT", panel, "RIGHT", -36, 0); b:SetPoint("TOP", enable, "TOP", 0, -2) end
    b:SetText(text)
    b:SetScript("OnClick", fn)
    tooltip(b, text, tip)
    return b
  end
  local allOff = topButton("All off", "Every switch below off, every field and statistic too. Auto TRP itself stays on.", function() UI.SetAllOptions(false) end)
  topButton("All on", "Every switch below on, every field and statistic too.", function() UI.SetAllOptions(true) end, allOff)

  -- The options scroll, so the panel fits any screen.
  local scroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
  scroll:SetPoint("TOPLEFT", enable, "BOTTOMLEFT", 4, -6)
  scroll:SetPoint("BOTTOMRIGHT", -30, 52)
  local content = CreateFrame("Frame", nil, scroll)
  content:SetSize(640, 800)
  scroll:SetScrollChild(content)
  UI.BuildOptions(content)

  local function button(text, w, tip, fn, anchor)
    local b = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    b:SetSize(w, 24)
    if anchor then b:SetPoint("LEFT", anchor, "RIGHT", 6, 0) else b:SetPoint("BOTTOMLEFT", 16, 16) end
    b:SetText(text)
    b:SetScript("OnClick", fn)
    tooltip(b, text, tip)
    return b
  end
  local b1 = button("Preview", 90, "What your profile would say, field by field, and which fields are yours.", function() UI.Preview() end)
  local b2 = button("Write it now", 110, "Write everything now instead of waiting for the next change.", function() UI.Update(true); UI.RefreshPanel() end, b1)
  local b3 = button("Journal", 90, "Your character's journal: a day's entry from each session. Without it, the mood journal's last week.", function() UI.OpenJournalOrDays() end, b2)
  local b4 = button("Restore...", 100, "Put your profile back as it was before Auto TRP wrote to it. Asks first.", function() StaticPopup_Show("AUTOTRP_RESTORE") end, b3)
  button("Make a profile for it", 160, "Make a copy of your current Total RP 3 profile for Auto TRP to write to, and switch to it.", function() UI.Setup(); UI.RefreshPanel() end, b4)
end

-- The switches, from OPTIONS, two columns, each heading with its own All on / All off.
function UI.BuildOptions(content)
  local y, col, lowest = -4, 1, 0
  local x = COL_X[col]
  local boxes = {}
  for _, opt in ipairs(OPTIONS) do
    if opt.head then
      if UI.COLUMN_BREAK[opt.head] and col == 1 then col, y = 2, -4 end
      x = COL_X[col]
      local h = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
      h:SetPoint("TOPLEFT", x, y)
      h:SetWidth(COL_W - 104)
      h:SetJustifyH("LEFT")
      h:SetText(opt.head)
      local head = opt.head
      local off = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
      off:SetSize(48, 18)
      off:SetPoint("TOPLEFT", x + COL_W - 48, y + 2)
      off:SetText("Off")
      off:SetScript("OnClick", function() UI.SetGroupOptions(head, false) end)
      tooltip(off, "All off", "Every switch under \"" .. head .. "\" off.")
      local on = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
      on:SetSize(48, 18)
      on:SetPoint("RIGHT", off, "LEFT", -4, 0)
      on:SetText("On")
      on:SetScript("OnClick", function() UI.SetGroupOptions(head, true) end)
      tooltip(on, "All on", "Every switch under \"" .. head .. "\" on.")
      y = y - math.max(22, textHeight(h, opt.head, COL_W - 104, 14) + 6)
      local note = UI.HEAD_NOTES[opt.head]
      if note then
        local d = content:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
        d:SetPoint("TOPLEFT", x, y)
        d:SetWidth(COL_W)
        d:SetJustifyH("LEFT")
        d:SetText(note)
        y = y - textHeight(d, note, COL_W, 12) - 6
      end
    elseif opt.path then
      local cb = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
      cb:SetSize(24, 24)
      cb:SetPoint("TOPLEFT", x - 4, y)
      local l = content:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
      l:SetPoint("TOPLEFT", cb, "TOPRIGHT", 2, -5)
      l:SetWidth(COL_W - 30)
      l:SetJustifyH("LEFT")
      l:SetText(opt.label)
      cb:SetScript("OnClick", function(self)
        local t, k = getPath(opt.path)
        t[k] = self:GetChecked() and true or false
        if opt.after then opt.after() end
      end)
      tooltip(cb, (opt.label:gsub("^%s+", "")), UI.TipFor(opt))
      cb.path = opt.path
      cb.opt = opt
      boxes[#boxes + 1] = cb
      y = y - math.max(22, textHeight(l, opt.label, COL_W - 30, 12) + 10)
    end
    lowest = math.min(lowest, y)
  end
  content:SetHeight(-lowest + 16)
  UI.boxes = boxes
  return boxes
end

ns.Listen("LOGIN", function() UI.BuildPanel(); UI.BuildBadge() end)

---------------------------------------------------------------------------
-- Mood badge: a small icon showing how your character feels. Hover for why, what your
-- profile says and when it was last written; click for the preview, shift-click to see your
-- Currently in chat, ctrl-click for the settings, right-click to pause or resume. Drag to move.
-- It glows briefly when the mood turns.
---------------------------------------------------------------------------
local badge, badgeMood

-- The last real write: when, and which fields (by their labels), for the badge's tooltip.
function UI.NoteWrite(changed, now)
  if not ns.char or type(changed) ~= "table" or #changed == 0 then return end
  local names = {}
  for i, k in ipairs(changed) do names[i] = TRP.LABELS[k] or k end
  table.sort(names)
  ns.char.lastWrite = { t = now or U.Now(), fields = names }
end

-- "just now", "4 min ago", "2 h ago", "3 days ago".
function UI.Ago(t)
  if type(t) ~= "number" then return nil end
  local d = math.max(0, U.Now() - t)
  if d < 60 then return "just now" end
  if d < 3600 then return math.floor(d / 60) .. " min ago" end
  if d < 86400 then return math.floor(d / 3600) .. " h ago" end
  local n = math.floor(d / 86400)
  return n .. U.Plural(n, " day", " days") .. " ago"
end

-- Shift-click: your Currently in your own chat window (nobody else sees it).
function UI.EchoCurrently()
  local profile = TRP.Managed()
  local cu = profile and TRP.FIELDS.currently.read(profile)
  if not cu or cu == "" then
    ns.Print("Nothing in Currently yet.")
  else
    ns.Print("Currently: " .. cu .. " |cff808080(only you see this)|r")
  end
end

-- A short glow when the mood turns: an animation the game runs, nothing ticking here.
function UI.PulseBadge()
  if not badge or not badge:IsShown() then return end
  if not badge.glow then
    local g = badge:CreateTexture(nil, "OVERLAY")
    if not g then return end
    g:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    g:SetBlendMode("ADD")
    g:SetPoint("CENTER")
    g:SetSize(64, 64)
    g:SetAlpha(0)
    badge.glow = g
    local ag = g.CreateAnimationGroup and g:CreateAnimationGroup()
    if ag then
      local up = ag:CreateAnimation("Alpha")
      if up then
        up:SetFromAlpha(0); up:SetToAlpha(1); up:SetDuration(0.25); up:SetOrder(1)
        local down = ag:CreateAnimation("Alpha")
        down:SetFromAlpha(1); down:SetToAlpha(0); down:SetDuration(0.6); down:SetOrder(2)
        ag:SetLoopingType("NONE")
        ag:SetScript("OnFinished", function() g:SetAlpha(0) end)
        badge.pulse = ag
      end
    end
  end
  if badge.pulse then badge.pulse:Stop(); badge.pulse:Play() end
end

function UI.BadgeTooltip(self)
  if not GameTooltip then return end
  local m = badgeMood
  GameTooltip:SetOwner(self or UIParent, "ANCHOR_BOTTOM")
  GameTooltip:AddLine("Auto TRP" .. (ns.db.enabled and "" or " |cff808080(paused)|r"))
  if m then
    GameTooltip:AddLine(UI.IconString(m.icon, 14) .. m.title, 1, 0.82, 0)
    if m.reasons then GameTooltip:AddLine("Because: " .. table.concat(m.reasons, ", "), 0.8, 0.8, 0.8, true) end
    if m.also then GameTooltip:AddLine("And " .. m.also, 0.8, 0.8, 0.8, true) end
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(m.tell, 1, 1, 1, true)
    local earned = ns.Compose.Earned()
    if earned then
      GameTooltip:AddLine(" ")
      GameTooltip:AddLine("Known as \"" .. earned.nick .. "\"", 1, 0.82, 0)
      GameTooltip:AddLine(earned.deed, 0.8, 0.8, 0.8, true)
    end
  end
  local profile = TRP.Managed()
  local cu = profile and TRP.FIELDS.currently.read(profile)
  if cu and cu ~= "" then
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("Currently: " .. cu, 0.6, 0.9, 0.6, true)
  end
  local w = ns.char and ns.char.lastWrite
  GameTooltip:AddLine(" ")
  if type(w) == "table" and w.t then
    GameTooltip:AddLine("Profile last written " .. UI.Ago(w.t), 0.8, 0.8, 0.8)
    if type(w.fields) == "table" and #w.fields > 0 then
      GameTooltip:AddLine("Changed: " .. table.concat(w.fields, ", "), 0.6, 0.6, 0.6, true)
    end
  elseif not profile then
    GameTooltip:AddLine("Not writing yet: |cffffd100/atrp setup|r makes a profile for it.", 0.8, 0.8, 0.8, true)
  else
    GameTooltip:AddLine("Nothing written this session yet.", 0.8, 0.8, 0.8)
  end
  GameTooltip:AddLine(" ")
  GameTooltip:AddLine("Click: preview.  Shift-click: Currently in your chat.  Ctrl-click: settings.  Right-click: pause or resume.  Drag: move.", 0.5, 0.5, 0.5, true)
  GameTooltip:Show()
end

function UI.BadgeClick(button)
  if button == "RightButton" then
    UI.TogglePause()
  elseif U.Call(IsShiftKeyDown) then
    UI.EchoCurrently()
  elseif U.Call(IsControlKeyDown) then
    UI.OpenSettings()
  else
    UI.Preview()
  end
end

function UI.BuildBadge()
  if badge then return end
  badge = CreateFrame("Button", "AutoTRPBadge", UIParent)
  UI.badge = badge
  badge.glow, badge.pulse = false, false
  badge:SetSize(30, 30)
  badge:SetFrameStrata("MEDIUM")
  badge:SetMovable(true)
  badge:SetClampedToScreen(true)
  badge:RegisterForDrag("LeftButton")
  badge:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  local pos = ns.db.badgePos
  if type(pos) == "table" and pos.point then
    badge:SetPoint(pos.point, UIParent, pos.relPoint or pos.point, pos.x or 0, pos.y or 0)
  else
    badge:SetPoint("TOP", UIParent, "TOP", 0, -120)
  end
  badge.icon = badge:CreateTexture(nil, "ARTWORK")
  badge.icon:SetAllPoints()
  badge.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  badge.border = badge:CreateTexture(nil, "OVERLAY")
  badge.border:SetTexture("Interface\\Buttons\\UI-Quickslot2")
  badge.border:SetPoint("CENTER")
  badge.border:SetSize(52, 52)
  badge:SetScript("OnDragStart", function(self) self:StartMoving() end)
  badge:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, relPoint, x, y = self:GetPoint()
    ns.db.badgePos = { point = point, relPoint = relPoint, x = x, y = y }
  end)
  badge:SetScript("OnClick", function(_, button) UI.BadgeClick(button) end)
  badge:SetScript("OnEnter", function(self) UI.BadgeTooltip(self) end)
  badge:SetScript("OnLeave", function() GameTooltip:Hide() end)
  UI.UpdateBadge()
end

function UI.UpdateBadge(mood)
  if not badge then return end
  if not ns.db.showBadge then badge:Hide() return end
  badge:Show()
  if mood then
    if badgeMood and badgeMood.key ~= mood.key then UI.PulseBadge() end
    badgeMood = mood
  end
  local icon = badgeMood and badgeMood.icon or "INV_Misc_Book_11"
  badge.icon:SetTexture("Interface\\Icons\\" .. icon)
  badge.icon:SetDesaturated(not ns.db.enabled)
  -- Border: green for a good mood, red for a bad one, plain otherwise.
  local v = badgeMood and ns.Words.VALENCE[badgeMood.key] or 0
  if v > 0 then badge.border:SetVertexColor(0.5, 1, 0.5)
  elseif v < 0 then badge.border:SetVertexColor(1, 0.45, 0.45)
  else badge.border:SetVertexColor(1, 1, 1) end
end

---------------------------------------------------------------------------
-- The AddOns compartment (by the minimap) and key bindings
---------------------------------------------------------------------------
function AutoTRP_OnCompartmentClick(_, button)
  if button == "RightButton" then UI.TogglePause()
  elseif U.Call(IsControlKeyDown) then UI.OpenSettings()
  else UI.Preview() end
end
function AutoTRP_OnCompartmentEnter(_, frame)
  if not GameTooltip then return end
  GameTooltip:SetOwner(frame or UIParent, "ANCHOR_LEFT")
  GameTooltip:AddLine("Auto TRP" .. (ns.db and not ns.db.enabled and " |cff808080(paused)|r" or ""))
  if badgeMood then GameTooltip:AddLine(badgeMood.title, 1, 0.82, 0) end
  local w = ns.char and ns.char.lastWrite
  if type(w) == "table" and w.t then GameTooltip:AddLine("Profile last written " .. UI.Ago(w.t), 0.8, 0.8, 0.8) end
  GameTooltip:AddLine("Click: preview.  Ctrl-click: settings.  Right-click: pause or resume.", 0.5, 0.5, 0.5, true)
  GameTooltip:Show()
end
function AutoTRP_OnCompartmentLeave() if GameTooltip then GameTooltip:Hide() end end

function UI.TogglePause()
  ns.db.enabled = not ns.db.enabled
  ns.Print(ns.db.enabled and "Resumed." or "Paused. Your profile stays as it is.")
  UI.UpdateBadge()
  if ns.db.enabled then UI.Update(true) end
end

function AutoTRP_Binding(what)
  if what == "preview" then UI.Preview() elseif what == "pause" then UI.TogglePause() elseif what == "update" then UI.Update(true) end
end

BINDING_HEADER_AUTOTRP = "Auto TRP"
BINDING_NAME_AUTOTRP_PREVIEW = "Show the preview"
BINDING_NAME_AUTOTRP_PAUSE = "Pause or resume"
BINDING_NAME_AUTOTRP_UPDATE = "Write my profile now"

---------------------------------------------------------------------------
-- Slash commands
---------------------------------------------------------------------------
-- One switch per statistic, under the master switch.
do
  local at
  for i, o in ipairs(OPTIONS) do if o.path and o.path[2] == "stats" then at = i end end
  local n = 0
  for _, st in ipairs(ns.Compose.STATS) do
    if not st.retired then
      n = n + 1
      table.insert(OPTIONS, at + n, { path = { "fields", "stat_" .. st.key }, label = "    " .. st.label })
    end
  end
end

-- /atrp help. Keep in step with the Commands table in README.md (the offline test checks).
-- An entry is { usage, what it does }; a plain string is printed as it is.
local HELP = {
  { "/atrp", "open the settings" },
  { "/atrp help", "this list" },
  { "/atrp preview", "see what your profile would say, and which fields are Auto TRP's and which are yours" },
  { "/atrp update", "write it now" },
  { "/atrp setup", "make a profile for Auto TRP (a copy of your current one)" },
  { "/atrp use", "let Auto TRP write to the profile you're using now (your existing text stays)" },
  { "/atrp claim <field|all>", "hand a field back to Auto TRP" },
  { "/atrp release <field|all>", "take a field back" },
  { "/atrp mood", "how your character feels, and why (also /atrp why)" },
  { "/atrp feel <mood>", "choose a mood for the next hour (/atrp feel lists them, /atrp feel clear lets it go)" },
  { "/atrp intent <text>", "add what you're up to to Currently for two hours (/atrp intent alone clears it)" },
  { "/atrp days", "the mood journal: the last week of feelings and places" },
  { "/atrp journal", "your character's journal, a day's entry for each day you played, newest first" },
  { "/atrp journal today", "today's entry, in your own chat (never sent to anyone)" },
  { "/atrp spells", "the spells and abilities you cast most" },
  { "/atrp names", "every name you've earned, what for, and which one you wear" },
  { "/atrp name <number|auto>", "wear one of your earned names (auto: the greatest deed's)" },
  { "/atrp slot <glance> <1-5|0>", "move a glance (mood, lately, company, ambition, marks) to another slot, or 0 to drop it" },
  { "/atrp restore", "put your profile back as it was before Auto TRP" },
  { "/atrp all on", "switch every option, field and statistic on (/atrp all off: off)" },
  { "/atrp badge", "show or hide the mood badge" },
  { "/atrp status", "which profile it writes to and which addons it reads" },
  { "/atrp welcome", "show the welcome window again" },
  { "/atrp on", "resume (/atrp off: pause; your profile stays as it is)" },
  "Fields: currently, title, fulltitle, nickname, motto, icon, residence, birthplace, relationship, ooc, walkup, namecolour, music, traits, bearing, history, physical, glance_mood, glance_lately, glance_company, glance_ambition, glance_marks, stat_<name> (deaths, lands, road, dungeons, foes, rares, slain, jobs, wealth, crafts, standing, names, spell, books, faction, guild, level, role, speciality, fish, made, gathered, duels, battles, gold, inns, hit, renown, keepsake)",
}
UI.HELP = HELP

-- "|" starts an escape in chat, so a literal one is written twice.
function UI.HelpLines()
  local out = {}
  for _, h in ipairs(HELP) do
    if type(h) == "table" then
      out[#out + 1] = "|cffffd100" .. h[1]:gsub("|", "||") .. "|r: " .. h[2]:gsub("|", "||")
    else
      out[#out + 1] = h
    end
  end
  return out
end

function UI.PrintHelp()
  ns.Print("Commands (|cffffd100/autotrp|r works too):")
  for _, l in ipairs(UI.HelpLines()) do ns.Print(l) end
end

-- Earned names: list them, or choose which to wear.
function UI.ListNames()
  ns.Compose.Refresh()
  local all, worn = ns.Compose.EarnedAll(), ns.Compose.Earned()
  if #all == 0 then
    ns.Print("No name earned yet. One comes from finishing a story in RPG Dialogue or a quest chain, bringing down a dungeon's master, or collecting a bounty.")
    return
  end
  ns.Print("Names you've earned:")
  for i, e in ipairs(all) do
    local mark = e == worn and " |cff80ff80(worn)|r" or ""
    ns.Print(("  %d. |cffffd100%s|r: %s%s%s"):format(i, e.nick, e.deed:gsub("^%u", string.lower),
      e.motto and (". \"" .. e.motto .. "\"") or "", mark))
  end
  if #all > 1 then
    ns.Print((ns.char.chosenName and "You chose this one" or "Auto TRP picks the greatest deed's")
      .. "; |cffffd100/atrp name <number>|r wears another, |cffffd100/atrp name auto|r lets Auto TRP choose.")
  end
end

function UI.ChooseName(arg)
  ns.Compose.Refresh()
  local all = ns.Compose.EarnedAll()
  if arg == "" or arg == "auto" then
    ns.char.chosenName = nil
    local e = ns.Compose.Earned()
    ns.Print(e and ("Going by \"" .. e.nick .. "\", for the greatest deed.") or "No name earned yet.")
    UI.Update(true)
    return
  end
  local pick = all[tonumber(arg) or 0]
  if not pick then
    for _, e in ipairs(all) do if e.nick:lower() == arg then pick = e end end
  end
  if not pick then
    ns.Print("No earned name '" .. arg .. "'. |cffffd100/atrp names|r lists them.")
    return
  end
  ns.char.chosenName = pick.key
  ns.Print("Going by \"" .. pick.nick .. "\" from now on.")
  UI.Update(true)
end

-- The mood journal: the last week, a line a day.
function UI.ListDays()
  local days = ns.Mood.RecentDays(7)
  if #days == 0 then
    ns.Print("Nothing in the mood journal yet. Each day's main feeling and place are kept for two weeks.")
    return
  end
  ns.Print("The last week:")
  for _, d in ipairs(days) do
    local m = d.mood and ns.Words.MOODS[d.mood] and ns.Words.MOODS[d.mood].title or "Steady"
    ns.Print("  " .. U.Cap(d.label) .. ": " .. m .. (d.zone and (", mostly in " .. d.zone) or ""))
  end
end

local function eachField(arg, fn)
  if arg == "all" then
    for key in pairs(TRP.FIELDS) do fn(key) end
    return true
  end
  if TRP.FIELDS[arg] then fn(arg); return true end
  ns.Print("No field called '" .. tostring(arg) .. "'. Try |cffffd100/atrp help|r.")
  return false
end

SLASH_AUTOTRP1, SLASH_AUTOTRP2 = "/atrp", "/autotrp"
SlashCmdList.AUTOTRP = function(msg)
  local cmd, arg = (msg or ""):lower():match("^%s*(%S*)%s*(.-)%s*$")
  if cmd == "" or cmd == "settings" or cmd == "config" then
    UI.OpenSettings()
  elseif cmd == "help" then
    UI.PrintHelp()
  elseif cmd == "welcome" then
    UI.ShowWelcome(true)
  elseif cmd == "preview" then UI.Preview()
  elseif cmd == "update" then UI.Update(true)
  elseif cmd == "setup" then UI.Setup()
  elseif cmd == "use" then UI.UseCurrent()
  elseif cmd == "on" then ns.db.enabled = true; ns.Print("On."); UI.Update(true)
  elseif cmd == "off" then ns.db.enabled = false; ns.Print("Paused. Your profile stays as it is.")
  elseif cmd == "claim" then
    if not ns.char.profileID then ns.Print("Choose a profile first: |cffffd100/atrp setup|r or |cffffd100/atrp use|r.") return end
    if eachField(arg, function(k) TRP.Claim(k) end) then ns.Print("Handed to Auto TRP: " .. arg .. "."); UI.Update(true) end
  elseif cmd == "release" then
    if eachField(arg, function(k) TRP.Release(k) end) then ns.Print("Yours again: " .. arg .. ". Auto TRP won't touch it.") end
  elseif cmd == "mood" or cmd == "why" then
    ns.Compose.Refresh()
    local m = ns.Mood.Current(ns.cache.world)
    ns.Print(m.title .. ": " .. m.tell)
    local scores, list = ns.Mood.Scores(ns.cache.world), {}
    for k, v in pairs(scores) do if v >= 1 then list[#list + 1] = { k = k, v = v } end end
    table.sort(list, function(a, b) return a.v > b.v end)
    local parts = {}
    for i = 1, math.min(5, #list) do parts[i] = ("%s %d"):format(list[i].k, list[i].v) end
    if #parts > 0 then ns.Print("Feeling: " .. table.concat(parts, ", ")) end
  elseif cmd == "feel" then
    if arg == "" then
      local names = {}
      for k in pairs(ns.Words.MOODS) do names[#names + 1] = k end
      table.sort(names)
      ns.Print("Moods: " .. table.concat(names, ", "))
    elseif arg == "clear" then
      ns.Mood.SetManual(nil); ns.Print("Your mood follows events again."); UI.Update(true)
    elseif ns.Mood.SetManual(arg) then
      ns.Print("Feeling " .. ns.Words.MOODS[arg].title:lower() .. " for the next hour."); UI.Update(true)
    else
      ns.Print("No mood called '" .. arg .. "'. |cffffd100/atrp feel|r lists them.")
    end
  elseif cmd == "intent" then
    local raw = (msg or ""):match("^%s*%S+%s*(.-)%s*$")
    if raw == "" then
      ns.char.intent = nil; ns.Print("Intent cleared.")
    else
      local text = U.Plain(raw)
      if not text then ns.Print("Nothing to add.") return end
      ns.char.intent = { text = U.Truncate(text, 120), untilT = U.Now() + 7200 }
      ns.Print("Added to Currently for two hours: " .. ns.char.intent.text)
    end
    UI.Update(true)
  elseif cmd == "restore" then
    UI.Restore()
  elseif cmd == "slot" then
    local which, n = arg:match("^(%a+)%s+(%d)$")
    n = tonumber(n)
    local slots = ns.char.glanceSlots
    if not which or slots[which] == nil or not n or n > 5 then
      local cur = {}
      for k, v in pairs(slots) do cur[#cur + 1] = k .. "=" .. v end
      table.sort(cur)
      ns.Print("Usage: /atrp slot <mood|lately|company|ambition|marks> <1-5, or 0 for none>. Now: " .. table.concat(cur, ", "))
      return
    end
    local from = slots[which]
    if from == n then return end
    local id = ns.char.profileID
    local mine = id and TRP.Owned(id)
    -- Whatever shares the target slot swaps into the old one, and what Auto TRP knows about
    -- each slot's text goes with it, so neither is mistaken for your own words.
    local other
    for k, v in pairs(slots) do if n > 0 and v == n and k ~= which then other = k end end
    if mine then
      local a, b = mine["glance_" .. which], other and mine["glance_" .. other]
      if other then mine["glance_" .. which], mine["glance_" .. other] = b, a
      else mine["glance_" .. which] = nil end
    end
    if other then slots[other] = from end
    slots[which] = n
    -- A slot left empty is switched off if Auto TRP's text was in it.
    if not other and from > 0 and mine and TRP.Managed() then
      local profile = TRP.Managed()
      local pe = profile.player.misc and profile.player.misc.PE
      if type(pe) == "table" and type(pe[tostring(from)]) == "table" then pe[tostring(from)].AC = false end
    end
    ns.Print("Glance '" .. which .. "' is now in slot " .. n .. ".")
    UI.Update(true)
  elseif cmd == "days" then
    UI.ListDays()
  elseif cmd == "journal" then
    if arg == "today" then ns.Journal.PrintToday() else ns.Journal.Show() end
  elseif cmd == "all" and (arg == "on" or arg == "off") then
    UI.SetAllOptions(arg == "on")
    ns.Print(arg == "on" and "Every option switched on." or "Every option switched off.")
    UI.Update(true)
  elseif cmd == "badge" then
    ns.db.showBadge = not ns.db.showBadge
    UI.UpdateBadge()
    ns.Print(ns.db.showBadge and "Mood badge shown." or "Mood badge hidden.")
  elseif cmd == "status" then
    ns.Print(UI.StatusLine())
  elseif cmd == "names" then
    UI.ListNames()
  elseif cmd == "spells" then
    local top = ns.Compose.TopSpells(5)
    if #top == 0 then
      ns.Print("No spells counted yet. Every spell and ability you cast from now on is counted (not swings, the hearthstone, gathering or crafting).")
    else
      local parts = {}
      for i, s in ipairs(top) do parts[i] = ("%s %d"):format(s.name, s.n) end
      local since = ns.char.casts and ns.char.casts.since
      ns.Print("Cast most" .. (since and date and (" since " .. date("%d %b %Y", since)) or "") .. ": " .. table.concat(parts, ", ") .. ".")
    end
  elseif cmd == "name" then
    UI.ChooseName(arg)
  else
    ns.Print("No command '" .. cmd .. "'.")
    UI.PrintHelp()
  end
end
