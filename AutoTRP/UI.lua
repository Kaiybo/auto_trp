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
  StaticPopup_Show("AUTOTRP_SETUP")
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
  local function add(key, text, until_)
    out[#out + 1] = "|cffc8a165" .. (TRP.LABELS[key] or key) .. "|r  " .. STATUS_WORDS[TRP.Status(key)]
    out[#out + 1] = (text and text ~= "") and text or ("|cff808080(nothing yet" .. (until_ and (": " .. until_) or "") .. ")|r")
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
  local e = ns.Compose.Earned()
  local from = e and ("  |cff808080(" .. e.deed:gsub("^%u", string.lower) .. ")|r") or ""
  local others = {}
  for _, o in ipairs(ns.Compose.EarnedAll()) do if o ~= e then others[#others + 1] = o.nick end end
  local choose = #others > 0 and ("\n    |cff808080also earned: " .. U.Join(others) .. " (/atrp names, /atrp name <n>)|r") or ""
  add("nickname", s.nickname and (s.nickname .. from .. choose), "earned by a story, quest chain, master or bounty you saw through")
  add("motto", s.motto and (s.motto .. from), "comes with the deed behind the nickname")
  add("icon", s.icon)
  add("residence", s.residence)
  add("birthplace", s.birthplace)
  add("relationship", s.relationship and ({ [2] = "Taken", [3] = "Married" })[s.relationship])
  add("ooc", s.ooc)
  add("walkup", s.walkup == 2 and "Open to walk-ups" or s.walkup == 1 and "Not open to walk-ups" or "(no change)")
  add("traits", traits)
  add("bearing", s.bearing)
  add("history", s.history)
  add("physical", s.physical)
  if s.stats then
    for _, st in ipairs(ns.Compose.STATS) do if not st.retired then add("stat_" .. st.key, s.stats[st.key]) end end
  end
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
  { path = { "fields", "nickname" }, label = "Nickname: earned by a story, quest chain, master or bounty you saw through (/atrp names)" },
  { path = { "fields", "motto" }, label = "Motto: the saying that deed left you with" },
  { path = { "fields", "icon" }, label = "Icon: your nickname's, else your class crest" },
  { path = { "fields", "residence" }, label = "Residence: where your hearthstone is" },
  { path = { "fields", "birthplace" }, label = "Birthplace" },
  { path = { "fields", "relationship" }, label = "Relationship status, from a partner in Social Diary" },
  { path = { "fields", "ooc" }, label = "OOC note saying the profile updates itself" },
  { path = { "fields", "walkup" }, label = "Open to walk-ups follows your mood" },
  { head = "Statistics (Additional information on the Characteristics tab)" },
  { path = { "fields", "stats" }, label = "Write statistics (all of them; the switches below pick which)" },
  { head = "Where it looks" },
  { path = { "sources", "rpgd" }, label = "RPG Dialogue" },
  { path = { "sources", "socialDiary" }, label = "Social Diary" },
  { path = { "sources", "chronicle" }, label = "Chronicle" },
  { head = "Details" },
  { path = { "annals" }, label = "History keeps your moments month by month (ranks, masters, names, standing)" },
  { path = { "diaryExcerpt" }, label = "Quote your latest diary entry in History" },
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

  -- The options scroll, so the panel fits any screen.
  local scroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
  scroll:SetPoint("TOPLEFT", 8, -104)
  scroll:SetPoint("BOTTOMRIGHT", -30, 52)
  local content = CreateFrame("Frame", nil, scroll)
  content:SetSize(620, 800)
  scroll:SetScrollChild(content)

  local y, x, col, lowest = -4, 8, 0, 0
  local boxes = {}
  for _, opt in ipairs(OPTIONS) do
    if opt.head then
      if opt.head == "Where it looks" then col, y = 1, -4 end
      local h = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
      x = col == 0 and 8 or 330
      h:SetPoint("TOPLEFT", x, y)
      h:SetText(opt.head)
      y = y - 20
    else
      local cb = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
      cb:SetSize(24, 24)
      cb:SetPoint("TOPLEFT", x - 4, y)
      local l = content:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
      l:SetPoint("LEFT", cb, "RIGHT", 2, 0)
      l:SetWidth(col == 0 and 290 or 260)
      l:SetJustifyH("LEFT")
      l:SetText(opt.label)
      cb:SetScript("OnClick", function(self)
        local t, k = getPath(opt.path)
        t[k] = self:GetChecked() and true or false
        if opt.after then opt.after() end
      end)
      cb.path = opt.path
      boxes[#boxes + 1] = cb
      y = y - 21
    end
    lowest = math.min(lowest, y)
  end
  content:SetHeight(-lowest + 16)

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

ns.Listen("LOGIN", function() UI.BuildPanel(); UI.BuildBadge() end)

---------------------------------------------------------------------------
-- Mood badge: a small icon showing how your character feels. Hover for why and what your
-- profile says; click for the preview; right-click to pause or resume. Drag to move.
---------------------------------------------------------------------------
local badge, badgeMood
function UI.BuildBadge()
  if badge then return end
  badge = CreateFrame("Button", "AutoTRPBadge", UIParent)
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
  badge:SetScript("OnClick", function(_, button)
    if button == "RightButton" then
      UI.TogglePause()
    else
      UI.Preview()
    end
  end)
  badge:SetScript("OnEnter", function(self)
    local m = badgeMood
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    GameTooltip:AddLine("Auto TRP" .. (ns.db.enabled and "" or " |cff808080(paused)|r"))
    if m then
      GameTooltip:AddLine(m.title, 1, 0.82, 0)
      if m.reasons then GameTooltip:AddLine(table.concat(m.reasons, ", "), 0.8, 0.8, 0.8, true) end
      if m.also then GameTooltip:AddLine("and " .. m.also, 0.8, 0.8, 0.8, true) end
      GameTooltip:AddLine(" ")
      GameTooltip:AddLine(m.tell, 1, 1, 1, true)
      local earned = ns.Compose.Earned()
      if earned then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Known as \"" .. earned.nick .. "\"", 1, 0.82, 0)
        GameTooltip:AddLine(earned.deed, 0.8, 0.8, 0.8, true)
      end
    end
    local cu = TRP.Managed() and TRP.FIELDS.currently.read((TRP.Managed()))
    if cu and cu ~= "" then
      GameTooltip:AddLine(" ")
      GameTooltip:AddLine("Currently: " .. cu, 0.6, 0.9, 0.6, true)
    end
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("Click: preview.  Right-click: pause/resume.  Drag: move.", 0.5, 0.5, 0.5, true)
    GameTooltip:Show()
  end)
  badge:SetScript("OnLeave", function() GameTooltip:Hide() end)
  UI.UpdateBadge()
end

function UI.UpdateBadge(mood)
  if not badge then return end
  if not ns.db.showBadge then badge:Hide() return end
  badge:Show()
  if mood then badgeMood = mood end
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
  if button == "RightButton" then UI.TogglePause() else UI.Preview() end
end
function AutoTRP_OnCompartmentEnter(_, frame)
  if not GameTooltip then return end
  GameTooltip:SetOwner(frame or UIParent, "ANCHOR_LEFT")
  GameTooltip:AddLine("Auto TRP" .. (ns.db and not ns.db.enabled and " |cff808080(paused)|r" or ""))
  if badgeMood then GameTooltip:AddLine(badgeMood.title, 1, 0.82, 0) end
  GameTooltip:AddLine("Click: preview.  Right-click: pause/resume.", 0.5, 0.5, 0.5, true)
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
  "|cffffd100/atrp restore|r: put your profile back exactly as it was before Auto TRP wrote to it",
  "|cffffd100/atrp slot <glance> <1-5|0>|r: move a glance (mood, lately, company, ambition, marks) to another slot, or 0 to drop it",
  "|cffffd100/atrp badge|r: show or hide the mood badge",
  "|cffffd100/atrp days|r: the mood journal, the last week of feelings and places",
  "|cffffd100/atrp names|r: every name you've earned, and what for",
  "|cffffd100/atrp spells|r: the spells and abilities you cast most",
  "|cffffd100/atrp name <number|auto>|r: wear one of your earned names (|cffffd100auto|r: the greatest deed's)",
  "Fields: currently, title, fulltitle, nickname, motto, icon, residence, birthplace, relationship, ooc, traits, bearing, history, physical, glance_mood, glance_lately, glance_company, glance_ambition, glance_marks, stat_<name> (deaths, lands, road, dungeons, foes, rares, slain, jobs, wealth, crafts, standing, names, spell, books)",
}

-- Earned names: list them, or choose which to wear.
function UI.ListNames()
  ns.Compose.Refresh()
  local all, worn = ns.Compose.EarnedAll(), ns.Compose.Earned()
  local reach = ns.Compose.InReach()
  local function within()
    if #reach == 0 then return end
    ns.Print("Within reach (in your quest log):")
    for _, r in ipairs(reach) do
      ns.Print(("  |cffffd100%s|r: finish %s%s"):format(r.nick, r.quest, r.motto and (". \"" .. r.motto .. "\"") or ""))
    end
  end
  if #all == 0 then
    ns.Print("No name earned yet. One comes from finishing a story in RPG Dialogue or a quest chain, bringing down a dungeon's master, or collecting a bounty.")
    within()
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
  within()
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
    local ok, why = TRP.Restore()
    if ok then
      ns.Print("Your profile is back as it was. Every field is yours again; |cffffd100/atrp claim all|r hands them back to Auto TRP.")
    else
      ns.Print("Couldn't restore: " .. tostring(why))
    end
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
    for _, l in ipairs(HELP) do ns.Print(l) end
  end
end
