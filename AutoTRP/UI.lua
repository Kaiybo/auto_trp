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
local FAST = { currently = true, glance_mood = true, glance_lately = true, glance_company = true, glance_marks = true }

local function values(sheet)
  return {
    currently = sheet.currently, title = sheet.title, fulltitle = sheet.fulltitle,
    residence = sheet.residence, birthplace = sheet.birthplace, motto = sheet.motto,
    nickname = sheet.nickname, bearing = sheet.bearing, history = sheet.history,
    physical = sheet.physical, traits = sheet.traits,
    glance_mood = sheet.glances.mood, glance_lately = sheet.glances.lately,
    glance_company = sheet.glances.company, glance_ambition = sheet.glances.ambition,
    glance_marks = sheet.glances.marks,
  }
end

local lastFast, lastSlow, slowDue = 0, 0, true

-- force: write everything now. Otherwise "Currently" and the glances follow the setting's
-- pace, the rest every five minutes or after something that matters (a level, a death).
function UI.Update(force)
  if not ns.char or not ns.db.enabled then return end
  if not TRP.Managed() then return end
  local now = U.Now()
  local only = {}
  local any = false
  local paused = ns.db.pauseOOC and TRP.IsOOC()
  if not paused and (force or now - lastFast >= (ns.db.currentlyEvery or 90)) then
    for k in pairs(FAST) do only[k] = true end
    any = true
  end
  if force or slowDue or now - lastSlow >= 300 then
    for k in pairs(TRP.FIELDS) do if not FAST[k] then only[k] = true end end
    any = true
  end
  if not any then return end
  local sheet = ns.Compose.Sheet()
  local changed, why = TRP.Apply(values(sheet), only)
  if not changed then
    if force then ns.Print("Not updated: " .. tostring(why) .. ".") end
    return
  end
  if only.currently then lastFast = now end
  if only.history then lastSlow, slowDue = now, false end
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

-- Something happened: let "Currently" catch up soon, and the story too when asked.
local function soon(story)
  if story then slowDue = true end
  lastFast = math.min(lastFast, U.Now() - (ns.db.currentlyEvery or 90) + 8)
end

ns.On("ZONE_CHANGED_NEW_AREA", function() soon(false) end)
ns.On("PLAYER_LEVEL_UP", function() soon(true) end)
ns.On("PLAYER_DEAD", function() soon(true) end)
ns.On("PLAYER_UNGHOST", function() soon(false) end)
ns.On("PLAYER_UPDATE_RESTING", function() soon(false) end)
ns.On("GROUP_ROSTER_UPDATE", function() soon(false) end)
ns.On("ENCOUNTER_END", function() soon(true) end)

---------------------------------------------------------------------------
-- First run
---------------------------------------------------------------------------
StaticPopupDialogs = StaticPopupDialogs or {}
StaticPopupDialogs["AUTOTRP_SETUP"] = {
  text = "|cffc8a165Auto TRP|r can keep your Total RP 3 profile up to date with your story: your mood, where you are, your history and the people you've met.\n\nIt will make a new profile, a copy of your current one, and only ever write to that. Anything you edit there yourself stays yours.",
  button1 = "Make the profile",
  button2 = "Not now",
  button3 = "Use my current profile",
  OnAccept = function() UI.Setup() end,
  OnCancel = function(_, _, reason)
    if reason == "clicked" then
      ns.char.declined = true
      ns.Print("No problem. |cffffd100/atrp setup|r whenever you'd like.")
    end
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
  if ns.char.profileID or ns.char.declined then return end
  if U.Call(InCombatLockdown) then ns.After(10, function() firstRun(tries) end) return end
  StaticPopup_Show("AUTOTRP_SETUP")
end

local warnedOther = false
ns.Listen("LOGIN", function()
  ns.char.seedName = (U.Call(UnitName, "player") or "") .. "-" .. (U.Call(GetRealmName) or "")
  ns.After(6, function() firstRun(0) end)
  ns.Ticker(ns.Mood.TICK, function()
    ns.Compose.Refresh()
    ns.Mood.Tick()
    local profile, why = TRP.Managed()
    if profile then
      warnedOther = false
      UI.Update(false)
    elseif ns.char.profileID and why and why:find("different") and not warnedOther then
      warnedOther = true
      if not ns.db.quiet then ns.Print("You've switched Total RP 3 profiles, so Auto TRP is pausing. Switch back, or |cffffd100/atrp use|r this one.") end
    end
  end)
  ns.After(10, function() UI.Update(false) end)
end)

---------------------------------------------------------------------------
-- Preview
---------------------------------------------------------------------------
local STATUS_WORDS = { auto = "|cff80ff80written by Auto TRP|r", yours = "|cffffd100yours (left alone)|r", off = "|cff808080off|r", waiting = "|cffaaaaaawaiting|r" }

local function glanceText(g)
  if not g then return "(nothing to say yet)" end
  return g.TI .. ": " .. g.TX
end

function UI.PreviewText()
  local s = ns.Compose.Sheet()
  local out = {}
  local function add(key, text)
    out[#out + 1] = "|cffc8a165" .. (TRP.LABELS[key] or key) .. "|r  " .. STATUS_WORDS[TRP.Status(key)]
    out[#out + 1] = (text and text ~= "") and text or "|cff808080(nothing to say yet)|r"
    out[#out + 1] = ""
  end
  local traits
  if s.traits then
    local t = {}
    for _, b in ipairs(s.traits) do t[#t + 1] = ("%s %d / %d %s"):format(b.LT, b.V2, 20 - b.V2, b.RT) end
    traits = table.concat(t, "\n")
  end
  local why = s.mood.reasons and (" (" .. table.concat(s.mood.reasons, ", ") .. ")") or ""
  out[#out + 1] = "|cffc8a165Mood|r  " .. s.mood.title .. why
  out[#out + 1] = ""
  add("currently", s.currently)
  add("glance_mood", glanceText(s.glances.mood))
  add("glance_lately", s.glances.lately and glanceText(s.glances.lately))
  add("glance_company", s.glances.company and glanceText(s.glances.company))
  add("glance_ambition", s.glances.ambition and glanceText(s.glances.ambition))
  add("glance_marks", s.glances.marks and glanceText(s.glances.marks))
  add("title", s.title)
  add("fulltitle", s.fulltitle)
  add("nickname", s.nickname)
  add("motto", s.motto)
  add("residence", s.residence)
  add("birthplace", s.birthplace)
  add("traits", traits)
  add("bearing", s.bearing)
  add("history", s.history)
  add("physical", s.physical)
  return table.concat(out, "\n")
end

local preview
function UI.Preview()
  if not preview then
    local f = CreateFrame("Frame", "AutoTRPPreview", UIParent, "BasicFrameTemplateWithInset")
    f:SetSize(520, 560)
    f:SetPoint("CENTER")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:SetFrameStrata("DIALOG")
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("TOP", 0, -5)
    title:SetText("Auto TRP: what your profile would say")
    local scroll = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 12, -32)
    scroll:SetPoint("BOTTOMRIGHT", -32, 44)
    local text = CreateFrame("EditBox", nil, scroll)
    text:SetMultiLine(true)
    text:SetFontObject(ChatFontNormal)
    text:SetWidth(460)
    text:SetAutoFocus(false)
    text:SetScript("OnEscapePressed", function() f:Hide() end)
    text:SetScript("OnTextChanged", function(self, user) if user then self:SetText(f.body or "") end end)
    scroll:SetScrollChild(text)
    f.text = text
    local write = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    write:SetSize(140, 24)
    write:SetPoint("BOTTOMRIGHT", -12, 12)
    write:SetText("Write it now")
    write:SetScript("OnClick", function() UI.Update(true); f.Refresh() end)
    local refresh = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    refresh:SetSize(100, 24)
    refresh:SetPoint("RIGHT", write, "LEFT", -6, 0)
    refresh:SetText("Refresh")
    refresh:SetScript("OnClick", function() f.Refresh() end)
    function f.Refresh()
      f.body = UI.PreviewText()
      f.text:SetText(f.body)
      f.text:SetCursorPosition(0)
    end
    tinsert(UISpecialFrames, "AutoTRPPreview")
    preview = f
  end
  preview.Refresh()
  preview:Show()
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
  { path = { "fields", "nickname" }, label = "Nickname: an epithet you've earned" },
  { path = { "fields", "motto" }, label = "Motto, in keeping with your temperament" },
  { path = { "fields", "residence" }, label = "Residence: where your hearthstone is" },
  { path = { "fields", "birthplace" }, label = "Birthplace" },
  { head = "Where it looks" },
  { path = { "sources", "rpgd" }, label = "RPG Dialogue" },
  { path = { "sources", "socialDiary" }, label = "Social Diary" },
  { path = { "sources", "chronicle" }, label = "Chronicle" },
  { head = "Details" },
  { path = { "diaryExcerpt" }, label = "Quote your latest diary entry in History" },
  { path = { "chronicleGoals" }, label = "Share your open Chronicle goal as an ambition" },
  { path = { "nameFriends" }, label = "Name the players you marked as friends in Social Diary" },
  { path = { "pauseOOC" }, label = "Pause Currently and glances while out of character" },
  { path = { "quiet" }, label = "Quiet: no chat messages" },
}

local function getPath(path)
  local t = ns.db
  for i = 1, #path - 1 do t = t[path[i]] end
  return t, path[#path]
end

function UI.BuildPanel()
  local panel = CreateFrame("Frame")
  panel.name = "Auto TRP"
  local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", 16, -16)
  title:SetText("Auto TRP")
  local status = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  status:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
  status:SetPoint("RIGHT", -16, 0)
  status:SetJustifyH("LEFT")

  local enable = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
  enable:SetPoint("TOPLEFT", status, "BOTTOMLEFT", -4, -6)
  local enableLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  enableLabel:SetPoint("LEFT", enable, "RIGHT", 2, 0)
  enableLabel:SetText("Keep my profile up to date")
  enable:SetScript("OnClick", function(self) ns.db.enabled = self:GetChecked() and true or false end)

  local y, x, col = -110, 16, 0
  local boxes = {}
  for _, opt in ipairs(OPTIONS) do
    if opt.head then
      if opt.head == "Where it looks" then col, y = 1, -110 end
      local h = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
      x = col == 0 and 16 or 340
      h:SetPoint("TOPLEFT", x, y)
      h:SetText(opt.head)
      y = y - 20
    else
      local cb = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
      cb:SetSize(24, 24)
      cb:SetPoint("TOPLEFT", x - 4, y)
      local l = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
      l:SetPoint("LEFT", cb, "RIGHT", 2, 0)
      l:SetWidth(col == 0 and 290 or 260)
      l:SetJustifyH("LEFT")
      l:SetText(opt.label)
      cb:SetScript("OnClick", function(self)
        local t, k = getPath(opt.path)
        t[k] = self:GetChecked() and true or false
      end)
      cb.path = opt.path
      boxes[#boxes + 1] = cb
      y = y - 21
    end
  end

  local function button(text, w, anchorX, fn)
    local b = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    b:SetSize(w, 24)
    b:SetPoint("BOTTOMLEFT", anchorX, 16)
    b:SetText(text)
    b:SetScript("OnClick", fn)
    return b
  end
  button("Preview", 110, 16, function() UI.Preview() end)
  button("Write it now", 120, 132, function() UI.Update(true) end)
  button("Make a profile for it", 170, 258, function() UI.Setup() end)

  panel:SetScript("OnShow", function()
    enable:SetChecked(ns.db.enabled)
    for _, cb in ipairs(boxes) do
      local t, k = getPath(cb.path)
      cb:SetChecked(t[k])
    end
    status:SetText(UI.StatusLine())
  end)

  if Settings and Settings.RegisterCanvasLayoutCategory then
    local category = Settings.RegisterCanvasLayoutCategory(panel, "Auto TRP")
    Settings.RegisterAddOnCategory(category)
    UI.category = category
  elseif InterfaceOptions_AddCategory then
    InterfaceOptions_AddCategory(panel)
  end
  UI.panel = panel
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

ns.Listen("LOGIN", function() UI.BuildPanel() end)

---------------------------------------------------------------------------
-- Slash commands
---------------------------------------------------------------------------
local HELP = {
  "|cffffd100/atrp|r: settings",
  "|cffffd100/atrp preview|r: see what your profile would say",
  "|cffffd100/atrp update|r: write it now",
  "|cffffd100/atrp setup|r: make a profile for Auto TRP (a copy of your current one)",
  "|cffffd100/atrp use|r: let Auto TRP write to the profile you're using now",
  "|cffffd100/atrp claim <field|all>|r: hand a field you wrote back to Auto TRP",
  "|cffffd100/atrp release <field|all>|r: take a field back from Auto TRP",
  "|cffffd100/atrp mood|r: how your character feels, and why",
  "|cffffd100/atrp feel <mood>|r: choose a mood for the next hour (|cffffd100/atrp feel|r alone lists them, |cffffd100/atrp feel clear|r lets it go)",
  "|cffffd100/atrp intent <text>|r: add what you're up to to Currently for two hours (|cffffd100/atrp intent|r alone clears it)",
  "|cffffd100/atrp on|r / |cffffd100off|r: pause or resume",
  "Fields: currently, title, fulltitle, nickname, motto, residence, birthplace, traits, bearing, history, physical, glance_mood, glance_lately, glance_company",
}

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
  if cmd == "" then
    if UI.category and Settings and Settings.OpenToCategory then
      Settings.OpenToCategory(UI.category:GetID())
    elseif InterfaceOptionsFrame_OpenToCategory and UI.panel then
      InterfaceOptionsFrame_OpenToCategory(UI.panel)
    else
      UI.Preview()
    end
  elseif cmd == "help" then
    for _, l in ipairs(HELP) do ns.Print(l) end
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
  elseif cmd == "mood" then
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
      ns.char.intent = { text = U.Truncate(U.Plain(raw), 120), untilT = U.Now() + 7200 }
      ns.Print("Added to Currently for two hours: " .. ns.char.intent.text)
    end
    UI.Update(true)
  elseif cmd == "status" then
    ns.Print(UI.StatusLine())
  else
    for _, l in ipairs(HELP) do ns.Print(l) end
  end
end
