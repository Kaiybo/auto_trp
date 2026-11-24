-- What the game itself says about the moment: where you are, what you're doing, the hour.
-- Every call is protected; a missing API just leaves its detail out.
local _, ns = ...

local U = ns.U
local World = {}
ns.World = World

local function call(name, ...)
  return U.Call(_G[name], ...)
end

function World.Snapshot()
  local s = {}
  s.zone = U.Plain(call("GetRealZoneText")) or U.Plain(call("GetZoneText"))
  s.subzone = U.Plain(call("GetSubZoneText"))
  if s.subzone == s.zone then s.subzone = nil end
  s.resting = call("IsResting") and true or false
  s.combat = call("UnitAffectingCombat", "player") and true or false
  s.dead = call("UnitIsDeadOrGhost", "player") and true or false
  s.ghost = call("UnitIsGhost", "player") and true or false
  s.taxi = call("UnitOnTaxi", "player") and true or false
  s.mounted = call("IsMounted") and true or false
  s.swimming = call("IsSwimming") and true or false
  s.flying = call("IsFlying") and true or false
  s.indoors = call("IsIndoors") and true or false
  local inInstance, kind = call("IsInInstance")
  s.instance = inInstance and kind ~= "none" and kind or nil
  s.grouped = (call("IsInGroup") or call("IsInRaid")) and true or false
  s.level = call("UnitLevel", "player")
  s.race = select(2, call("UnitRace", "player"))
  s.class = select(2, call("UnitClass", "player"))
  s.faction = call("UnitFactionGroup", "player")
  s.name = call("UnitName", "player")
  s.bind = U.Plain(call("GetBindLocation"))
  local hp, max = call("UnitHealth", "player"), call("UnitHealthMax", "player")
  if type(hp) == "number" and type(max) == "number" and max > 0 then s.health = hp / max end
  local hour = call("GetGameTime")
  s.hour = type(hour) == "number" and hour or nil
  s.night = s.hour and (s.hour >= 21 or s.hour < 5) or false
  s.dawn = s.hour and s.hour >= 5 and s.hour < 8 or false
  s.dusk = s.hour and s.hour >= 18 and s.hour < 21 or false
  return s
end

-- Inns and taverns, by the words in their names.
local INN_WORDS = { "Inn", "Tavern", "Rest", "Lodge", "Hall", "Barracks", "Hostel", "Brewery" }
function World.IsInn(sub)
  if type(sub) ~= "string" then return false end
  for _, w in ipairs(INN_WORDS) do if sub:find(w) then return true end end
  return false
end

-- "resting at the Lion's Pride Inn in Goldshire" etc. Never the exact spot in the open
-- world: a profile is public, and "around Goldshire" is plenty.
function World.Activity(s, seed)
  local sub = s.subzone
  if sub and World.IsInn(sub) and not sub:find("^The ") then sub = "the " .. sub end
  local place = sub and (U.Mid(sub) .. ", " .. (s.zone or "")) or s.zone or "the road"
  local where = U.Mid(s.zone) or "the wilds"
  if s.ghost or s.dead then
    return U.Pick({ "a restless spirit drifting near " .. where, "somewhere between this world and the next, near " .. where }, seed)
  end
  if s.taxi then return U.Pick({ "on the wing over " .. where, "riding a flight over " .. where }, seed) end
  if s.instance == "party" or s.instance == "raid" then
    return U.Pick({ "deep inside " .. where, "delving into " .. where }, seed)
  end
  if s.instance == "pvp" then return "fighting for the banner in " .. where end
  if s.resting and World.IsInn(s.subzone) then
    return U.Pick({ "resting at " .. place, "warming up by the fire at " .. place, "taking a room at " .. place }, seed)
  end
  if s.resting then return U.Pick({ "about the streets of " .. place, "passing through " .. place }, seed) end
  if s.swimming then return "wading through the waters of " .. where end
  if s.flying then return "flying over " .. where end
  if s.mounted then return U.Pick({ "riding through " .. where, "on horseback in " .. where }, seed) end
  local around = s.subzone and ("around " .. place) or ("in " .. where)
  return U.Pick({ "on the road " .. around, "out " .. around, "travelling " .. around }, seed)
end

function World.TimeOfDay(s)
  if s.indoors or s.instance then return nil end
  if s.night then return "under the stars" end
  if s.dawn then return "at first light" end
  if s.dusk then return "as the light goes" end
  return nil
end
