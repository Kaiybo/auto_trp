-- KIN: race and homeland. The words for Auto TRP's record of a character's people
-- (Sources/Kin.lua): their capital and home lands, the racial gifts they use, the tongues
-- they speak, the places that matter to their people and the old enemies they cut down.
-- Loaded after Words.lua; it only adds W.KIN. Every line says only what the record backs:
-- a homecoming is a homecoming the game saw, a count is a count. Pronouns are {they},
-- {them}, {their}, {they've}, {they're} with {s}/{es}.
local _, ns = ...
local W = ns.Words

local K = {}
W.KIN = K

---------------------------------------------------------------------------
-- Where home is. capital: the city (as W.CAPITALS); home: the lands around it, said in
-- prose as `say`; lands: every zone that counts as home (by the English zone name, which
-- World's zoneKey gives on any client); faction: the home city's reputation.
---------------------------------------------------------------------------
K.HOME = {
  Human = { capital = "Stormwind City", say = "Elwynn and the Stormwind lands", faction = "Stormwind",
    lands = { ["Stormwind City"] = true, ["Elwynn Forest"] = true, ["Westfall"] = true, ["Redridge Mountains"] = true, ["Duskwood"] = true } },
  Dwarf = { capital = "Ironforge", say = "Dun Morogh and Khaz Modan", faction = "Ironforge",
    lands = { ["Ironforge"] = true, ["Dun Morogh"] = true, ["Loch Modan"] = true } },
  Gnome = { capital = "Ironforge", say = "Dun Morogh", faction = "Gnomeregan Exiles",
    lands = { ["Ironforge"] = true, ["Dun Morogh"] = true } },
  NightElf = { capital = "Darnassus", say = "Teldrassil and the forests of home", faction = "Darnassus",
    lands = { ["Darnassus"] = true, ["Teldrassil"] = true, ["Darkshore"] = true, ["Ashenvale"] = true } },
  Orc = { capital = "Orgrimmar", say = "Durotar", faction = "Orgrimmar",
    lands = { ["Orgrimmar"] = true, ["Durotar"] = true } },
  Troll = { capital = "Orgrimmar", say = "Durotar and the Echo Isles", faction = "Darkspear Trolls",
    lands = { ["Orgrimmar"] = true, ["Durotar"] = true } },
  Tauren = { capital = "Thunder Bluff", say = "Mulgore", faction = "Thunder Bluff",
    lands = { ["Thunder Bluff"] = true, ["Mulgore"] = true } },
  Scourge = { capital = "Undercity", say = "Tirisfal and the Forsaken lands", faction = "Undercity",
    lands = { ["Undercity"] = true, ["Tirisfal Glades"] = true, ["Silverpine Forest"] = true } },
}
K.HOME.Undead = K.HOME.Scourge

-- Each race's own tongue beside the common one of its side, as the game names it, and how
-- prose says it.
K.TONGUE = { Dwarf = "Dwarvish", Gnome = "Gnomish", NightElf = "Darnassian", Troll = "Troll", Tauren = "Taurahe",
  Scourge = "Gutterspeak", Undead = "Gutterspeak", Goblin = "Goblin" }
K.TONGUE_SAY = { Troll = "Zandali" }

---------------------------------------------------------------------------
-- Racial gifts, by the spell's name: the race it belongs to, and what made a use of it
-- matter (Sources/Kin.lua reads the moment: a fear just landed, a poison ticking, low
-- health, a fight on).
---------------------------------------------------------------------------
K.RACIALS = {
  ["Perception"] = { race = "Human" },
  ["Stoneform"] = { race = "Dwarf", when = "dot" },
  ["Find Treasure"] = { race = "Dwarf" },
  ["Escape Artist"] = { race = "Gnome", when = "root" },
  ["Shadowmeld"] = { race = "NightElf", when = "fight" },
  ["Blood Fury"] = { race = "Orc", when = "low" },
  ["Berserking"] = { race = "Troll", when = "low" },
  ["War Stomp"] = { race = "Tauren", when = "low" },
  ["Will of the Forsaken"] = { race = "Scourge", when = "mind" },
  ["Cannibalize"] = { race = "Scourge", when = "mend" },
  ["Rocket Jump"] = { race = "Goblin" },
  ["Rocket Barrage"] = { race = "Goblin", when = "low" },
}
-- Crowd control the gifts break: a fear, charm or sleep for the Forsaken's will, a root
-- (or a snare) for a gnome's escape.
K.MIND = { fear = true, charm = true, sleep = true }
K.ROOT = { root = true }
K.SNARES = { ["Hamstring"] = true, ["Frostbolt"] = true, ["Crippling Poison"] = true, ["Wing Clip"] = true,
  ["Frost Shock"] = true, ["Concussive Shot"] = true, ["Piercing Howl"] = true, ["Cone of Cold"] = true }

-- What a use that mattered was, as a past-tense predicate for History (after the name).
K.MATTERED = {
  fear = { "shook off a fear by will alone", "threw off a fear with the will of the Forsaken", "stopped running from a fear and turned to fight" },
  charm = { "threw off another's hold on {their} mind", "took {their} own will back from a charm" },
  sleep = { "broke out of a magical sleep by will alone", "shrugged off a spell of sleep in the middle of a fight" },
  root = { "slipped out of a binding that should have held {them}", "wriggled free of a root and got clear", "squirmed out of a hold, gnome-fashion" },
  snare = { "slipped a crippling spell and got clear", "shook off a hobbling blow, gnome-fashion" },
  poison = { "turned to stone to throw off a poison", "went to stone and let a poison pass" },
  bleed = { "turned to stone to stop {their} own bleeding", "went to stone with a wound still open, and closed it" },
  fight = { "melted into the shadows in the middle of a fight", "dropped into the shadows with a fight still going on" },
  mend = { "fed on the fallen to mend {their} wounds", "knelt over the dead after a hard fight, and fed" },
  low = {
    ["Blood Fury"] = { "fought on in a blood fury with little left in {them}", "called up the blood fury when the fight was going against {them}" },
    ["Berserking"] = { "went berserk with {their} life running out", "fought on in a berserker's rage at the very end of {their} strength" },
    ["War Stomp"] = { "stamped the ground and stunned {their} foes when it was going badly", "brought {their} hooves down with the fight nearly lost" },
    ["Rocket Barrage"] = { "fired off a rocket barrage with the fight going against {them}" },
  },
}

-- Personality, from how often a gift has been used (n: uses, m: uses that mattered).
K.HABIT = {
  ["Stoneform"] = { many = { "Turns to stone without a second thought when poison or a wound takes hold: {times} so far",
    "Has gone to stone {times} at need" }, few = { "Has gone to stone {times} at need" } },
  ["Find Treasure"] = { many = { "Keeps an eye out for buried things, with the dwarven knack for it: {times} so far",
    "Has gone looking for treasure the dwarven way {times}" } },
  ["Escape Artist"] = { many = { "Hard to hold: has slipped out of bindings {times}",
    "Has wriggled free of whatever held {them} {times} now" } },
  ["Shadowmeld"] = { many = { "Slips into the shadows the way {their} people do, and often: {times} so far",
    "Has melted into the dark {times}" } },
  ["Blood Fury"] = { many = { "Has called up the blood fury {times}", "Lets the blood fury out often: {times} so far" } },
  ["Berserking"] = { many = { "Has gone berserk {times}", "Gives in to the berserker's rage often: {times} so far" } },
  ["War Stomp"] = { many = { "Has brought {their} hooves down in a war stomp {times}", "Settles a crowd of foes with a war stomp: {times} so far" } },
  ["Will of the Forsaken"] = { many = { "Fear doesn't keep a hold on {them} for long: {times} now {they've} thrown it off",
    "Has called on the will of the Forsaken {times}" } },
  ["Cannibalize"] = { many = { "Feeds on the fallen without fuss: {times} so far", "Has fed on the dead {times}" } },
  ["Perception"] = { many = { "Keeps a sharp eye out for what's hidden: {times} so far" } },
}

---------------------------------------------------------------------------
-- Personality: the bond to their people, from where they spend their time.
-- {capital} the city, {home} the home lands, {span} how long, {times} how often.
---------------------------------------------------------------------------
K.BOND = {
  away = { "Hasn't set foot in {capital} in {span}", "Has stayed away from {capital} for {span} now",
    "Hasn't been home to {capital} in {span}", "Has kept clear of {capital} for {span}" },
  home = { "Spends most of {their} days in and around {home}", "Rarely strays far from {home}",
    "Keeps close to {home}, and to {their} own people", "Is seldom away from {home} for long" },
  abroad = { "Spends nearly all {their} time far from {home}", "Has spent far more of {their} days abroad than in {home}",
    "Is rarely anywhere near {home} these days", "Lives on the road, a long way from {home}" },
  visits = { "Always finds {their} way back to {capital} in the end", "Goes home to {capital} between long roads",
    "Comes back to {capital} after every long road" },
  trusted = { "Has earned the trust of {faction}", "Stands high with {faction}" },
  liked = { "Stands well with {faction}", "Is on good terms with {faction}" },
  -- {foe}: "the Scarlet Crusade", "Dark Iron dwarves" (History has the count).
  foes = { "Kills {foe} wherever {they} find{s} them, as {their} people always have", "Has a long quarrel with {foe}, and keeps it up",
    "Keeps up {their} people's old quarrel with {foe}" },
}

---------------------------------------------------------------------------
-- History predicates (after the name, past tense).
---------------------------------------------------------------------------
K.EV = {
  homecoming = { "came home to {capital} after {days} away", "went back to {capital} after {days} on the road",
    "turned up in {capital} again after {days}", "walked back into {capital} after {days} away" },
  place = { "made the journey to {place}", "went to see {place}", "found {their} way to {place}", "went to {place}" },
  visits = { "gone home to {capital} {times} after long roads", "come back to {capital} {times} after long stretches away" },
  places = { "been to {list}", "made the journey to {list}" },
  foes = { "cut down {n} {foe}", "killed {n} {foe}" },
}

---------------------------------------------------------------------------
-- Lately: a homecoming (by race; {capital} {days}), and a place of their people seen for
-- the first time (by the feeling W.RACE_PLACES gives it; {place}).
---------------------------------------------------------------------------
K.HOMECOMING = {
  Human = { "Back inside the walls of {capital} after {days} on the road.", "Home in {capital} again, {days} after {they} last left it.",
    "Walked back through the gates of {capital} after {days} away.", "Has come home to {capital} for the first time in {days}.",
    "In {capital} again after {days}, among {their} own people." },
  Dwarf = { "Back under the mountain in {capital} after {days} away.", "Home to {capital} after {days} on the road, and the forges still going.",
    "Has come in out of the snows to {capital}, {days} after {they} last left.", "Back among the halls of {capital} for the first time in {days}.",
    "In {capital} again after {days}, with good dwarven stone overhead." },
  Gnome = { "Back in {capital} after {days} away, as near home as a gnome gets these days.",
    "Has come back to the tinkers' corner of {capital} after {days}.", "In {capital} again after {days}, among what's left of Gnomeregan's people.",
    "Back with the exiles in {capital}, {days} after {they} last left." },
  NightElf = { "Back beneath the boughs of {capital} after {days} away.", "Has come home to {capital} after {days} abroad.",
    "In {capital} again, {days} since {they} last walked its paths.", "Returned to {capital} after {days} among the younger races.",
    "Home under the world tree, back in {capital} after {days} away." },
  Orc = { "Back in {capital} after {days} in the field.", "Has come home to {capital}, {days} after {they} last left it.",
    "Back behind the red walls of {capital} after {days} away.", "In {capital} again after {days}, among the Horde's own." },
  Troll = { "Back in {capital} after {days} on the road.", "Has come back to {capital} after {days}, to the Valley of Spirits and {their} own.",
    "In {capital} again, {days} after {they} last left.", "Home among the Horde in {capital}, after {days} away." },
  Tauren = { "Back atop the bluffs of {capital} after {days} away.", "Has made the long climb back up to {capital} after {days} on the road.",
    "Home in {capital} for the first time in {days}.", "In {capital} again after {days}, close to the Earth Mother's plains." },
  Scourge = { "Back in {capital} after {days} away, down among {their} own dead.", "Has gone down into {capital} again, {days} after {they} last left it.",
    "In {capital} again after {days}, under the ruins of Lordaeron.", "Back in {capital} after {days}, as close to home as the Forsaken have." },
}
K.HOMECOMING.Undead = K.HOMECOMING.Scourge

K.PLACE = {
  sorrowful = { title = "Old Sorrows", icon = "Spell_Holy_Restoration", lines = {
    "Has been to {place} lately, and came away quieter.", "Went to {place}, which is a hard place for one of {their} people to see.",
    "Stood in {place} not long since, and was the sadder for it.", "Has seen {place} with {their} own eyes now.",
    "Went as far as {place}, and has been subdued since." } },
  downcast = { title = "Old Ground", icon = "Spell_Shadow_GatherShadows", lines = {
    "Has walked {place} again, and it took something out of {them}.", "Went back to {place}, where so much was lost.",
    "Has been to {place}, and is low after it.", "Stood in {place} lately, among what is left." } },
  angry = { title = "Old Enemies", icon = "Ability_Warrior_Rampage", lines = {
    "Has been to {place}, and came back with {their} jaw set.", "Went into {place} lately, and isn't calm about it yet.",
    "Went to {place}, and is still angry about it.", "Has walked {place}, among {their} people's enemies." } },
  ease = { title = "Kindred Ground", icon = "Spell_Nature_Tranquility", lines = {
    "Has been to {place} lately, and was easier there.", "Found {their} way to {place}, which sits well with {them}.",
    "Spent time in {place}, among {their} own kind.", "Went to {place}, and was glad of it." } },
  intrigued = { title = "Old Secrets", icon = "INV_Misc_Book_11", lines = {
    "Has been poking about {place} lately.", "Went to see {place}, and came back with questions.",
    "Has been to {place}, where {their} people's past lies close to the surface.", "Took a long look at {place} lately." } },
  uneasy = { title = "Uneasy Ground", icon = "Spell_Shadow_Twilight", lines = {
    "Has been to {place}, and didn't care for it.", "Went to {place} lately, and kept looking over {their} shoulder.",
    "Saw {place} for the first time, and was uneasy there.", "Has walked through {place}, warily." } },
  devout = { title = "Holy Ground", icon = "Spell_Holy_PrayerOfHealing", lines = {
    "Has been to {place}, and prayed there.", "Went to {place}, which means a great deal to {their} people.",
    "Stood in {place} lately, with bowed head.", "Made the journey to {place}." } },
  fierce = { title = "Contested Ground", icon = "Ability_DualWield", lines = {
    "Has been to {place}, where {their} people still fight.", "Went to {place} lately, ready for trouble.",
    "Walked into {place} with {their} blood up.", "Has stood in {place}, on the front." } },
  conflicted = { title = "Old Ground", icon = "Spell_Shadow_Charm", lines = {
    "Has been to {place}, and doesn't know what to make of it.", "Went to {place} lately, where {their} people's story turned.",
    "Stood in {place}, and is of two minds since.", "Has seen {place}, where it all began." } },
  wonder = { title = "A Marvel", icon = "Spell_Nature_StarFall", lines = {
    "Has been to {place}, and is still talking about it.", "Went to see {place}, and was taken with it.",
    "Has stood in {place} with {their} mouth open.", "Saw {place} for the first time lately." } },
}

---------------------------------------------------------------------------
-- About: Physical, how they are right now: being in this place, as one of their people.
-- By race, then the English zone name (or subzone); `abroad` is for a long road far from
-- home (a week or more since the capital, in no land of their own).
---------------------------------------------------------------------------
K.HERE = {
  Human = {
    ["Stormwind City"] = { "At home in the stone streets, and moving like it", "Easy in the city of {their} birth", "Walks Stormwind like {they've} known it all {their} life", "Settled, here behind Stormwind's walls" },
    ["Elwynn Forest"] = { "Easy among the farms and woods of home", "Walks the Elwynn roads without needing to look", "Relaxed, on home soil" },
    ["Westfall"] = { "Grim-faced among the empty farms", "Quieter than usual, here where the farms were left", "Looks over the empty fields with something like grief" },
    ["Undercity"] = { "Tight-shouldered in the dead city", "Keeps a hand near {their} weapon down here among the Forsaken" },
    ["Ruins of Lordaeron"] = { "Quiet among the ruins of the old kingdom", "Looks up at the broken throne room as if it might come back" },
    abroad = { "Has the road-worn look of someone a long way from Stormwind", "Far from the Stormwind lands, and looks it", "A long way from home, and getting used to it" },
  },
  Dwarf = {
    ["Ironforge"] = { "At home under the mountain, and moving like it", "Easy in the forge-heat and noise of Ironforge", "Walks the Ironforge halls without needing to look", "Settled, with good stone overhead" },
    ["Dun Morogh"] = { "Easy in the snows of home", "Breathes the cold of Dun Morogh like a dwarf born to it", "Relaxed, among the home peaks" },
    ["Searing Gorge"] = { "Jaw set, in Dark Iron country", "Watches the Dark Iron diggings with open dislike" },
    ["Badlands"] = { "Keeps stopping to look at the old stonework", "Has a digger's eye on the ruins hereabouts" },
    abroad = { "A long way from the mountain, and feeling it", "Has the look of a dwarf too long away from stone", "Far from Khaz Modan, and making the best of it" },
  },
  Gnome = {
    ["Ironforge"] = { "Busy and at ease among the tinkers of Ironforge", "Settled in Ironforge, as near home as a gnome gets now", "Moves through Tinker Town like {they've} never known anywhere else" },
    ["Dun Morogh"] = { "Keeps glancing toward Gnomeregan", "Quieter than usual, this close to the lost city", "Looks up the road to Gnomeregan now and then" },
    ["Gnomeregan"] = { "Grim and watchful, in what's left of the home city", "Very quiet, here among the ruins of Gnomeregan" },
    abroad = { "A long way from Ironforge, and too curious to mind", "Far from the exiles' corner of Ironforge, and getting on with it" },
  },
  NightElf = {
    ["Darnassus"] = { "Easy beneath the boughs of Darnassus", "Walks the city's quiet paths like {they've} walked them for centuries", "Settled, here among {their} own people", "Calm under the great tree" },
    ["Teldrassil"] = { "At home among the roots of the world tree", "Moves through Teldrassil's woods without a sound", "Easy, in {their} own forest" },
    ["Ashenvale"] = { "Watches the treeline for orc axes", "Stiffens at the sound of logging somewhere off in the woods", "Watchful, in a forest {their} people are fighting for" },
    ["Felwood"] = { "Sickened by the rot in the trees", "Grief-struck at the state of the forest" },
    abroad = { "A long way from the world tree, and patient about it", "Far from Teldrassil, and quiet about how far", "Has the stillness of someone used to long roads by now" },
  },
  Orc = {
    ["Orgrimmar"] = { "At home in the noise of Orgrimmar", "Walks the Valley of Strength like {they} own{s} it", "Settled, inside the red walls", "Easy, among the Horde's own" },
    ["Durotar"] = { "Easy on the red earth of Durotar", "At home in the dust and heat of Durotar", "Relaxed, on land {their} people took for their own" },
    ["Hillsbrad Foothills"] = { "Grim, in the country of the old camps", "Watches the human towns here with a long memory" },
    ["Ashenvale"] = { "Eyes the old trees like timber still owed", "Blood up, in the elves' forest" },
    abroad = { "Far from Durotar, and none the softer for it", "A long way from Orgrimmar, and on the move", "Has the road-hardened look of a long way from home" },
  },
  Troll = {
    ["Orgrimmar"] = { "Easy in Orgrimmar, among the Darkspear and the rest", "At home in the Valley of Spirits", "Settled, here with the Horde" },
    ["Durotar"] = { "Easy near the Darkspear shore", "Relaxed, close to the Echo Isles", "At home on the Durotar coast" },
    ["Stranglethorn Vale"] = { "Moves through the jungle like {they} grew up in it", "Easy in the heat and green of the old jungle", "At home among the vines" },
    ["Zul'Gurub"] = { "Wary of the old gods in this place", "Very quiet, here in Hakkar's temple" },
    abroad = { "A long way from the islands, and taking it in stride", "Far from Darkspear country, and in no hurry about it" },
  },
  Tauren = {
    ["Thunder Bluff"] = { "At peace atop the bluffs", "Easy among the totems and tents of home", "Settled, here in Thunder Bluff", "Moves through Thunder Bluff like the wind is at {their} back" },
    ["Mulgore"] = { "Easy on the open plains of Mulgore", "Breathes the grass-scented air of home", "Relaxed, on the Earth Mother's plains" },
    ["Stonetalon Mountains"] = { "Grim at the sight of the stripped slopes", "Angry at what's been done to the mountains" },
    ["Thousand Needles"] = { "Looks over the old tauren lands with a long memory", "Thoughtful, among the needles" },
    abroad = { "A long way from Mulgore, and patient about it", "Far from the plains of home, and making the best of it", "Has the slow, steady look of a long road behind {them}" },
  },
  Scourge = {
    ["Undercity"] = { "At ease in the dark of the Undercity", "Moves through the Undercity like {they've} never known the sun", "Settled, down among {their} own dead", "Easy in the green gloom below the ruins" },
    ["Tirisfal Glades"] = { "At home among the dead trees of Tirisfal", "Easy in the grey light of the Glades", "Walks Tirisfal like {they} own{s} it, which in a way is true" },
    ["Silverpine Forest"] = { "Watches the woods for worgen", "Uneasy, in worgen country" },
    ["Stormwind City"] = { "Wrapped up tight, and very far from welcome", "Keeps to the shadows here, among the living" },
    ["Western Plaguelands"] = { "Quiet among the farms of what was Lordaeron", "Walks the old kingdom with a long memory" },
    ["Eastern Plaguelands"] = { "Hard-eyed, in the Scourge's own country", "Watches the shambling dead here with open hatred" },
    abroad = { "A long way from the Undercity, and none the worse for it", "Far from the Forsaken lands, and getting stares", "Has gone a long way from Tirisfal" },
  },
}
K.HERE.Undead = K.HERE.Scourge

---------------------------------------------------------------------------
-- About: Physical, the voice: which tongue they speak in. {tongue} their own, {common}
-- their side's common one.
---------------------------------------------------------------------------
K.VOICE = {
  mostly = { "Speaks {tongue} more often than {common} when {they} speak{s} aloud", "Says most of what {they} say{s} aloud in {tongue}",
    "Talks in {tongue} by preference" },
  some = { "Mostly speaks {common}, slipping into {tongue} now and then", "Speaks {common} for the most part, and {tongue} some of the time" },
  never = { "Sticks to {common}, though {they} know{s} {tongue}", "Speaks {common} out loud, never {tongue}" },
}

---------------------------------------------------------------------------
-- Marks: what a gift just used leaves on them. { title, icon, lines } by spell; `aura`
-- marks while the aura is on, otherwise for `for` seconds after the cast.
---------------------------------------------------------------------------
K.MARK = {
  ["Cannibalize"] = { title = "Fed on the Fallen", icon = "Ability_Racial_Cannibalize", ["for"] = 600, lines = {
    "There's grave-dirt on {their} hands, and worse at the corners of {their} mouth", "Has the dark-mouthed look of a Forsaken just fed",
    "Wipes {their} mouth with the back of a hand, having just fed on the dead" } },
  ["Stoneform"] = { title = "Stone-Skinned", icon = "Spell_Shadow_UnholyStrength", aura = true, ["for"] = 60, lines = {
    "{their} skin still has the grey, hard look of stone", "Stiff and grey-skinned, not yet out of {their} stoneform" } },
  ["Blood Fury"] = { title = "Blood Fury", icon = "Racial_Orc_BerserkerStrength", aura = true, ["for"] = 60, lines = {
    "Eyes red with the blood fury", "Breathing hard, the blood fury still on {them}" } },
  ["Berserking"] = { title = "Berserk", icon = "Racial_Troll_Berserk", aura = true, ["for"] = 60, lines = {
    "Still wild-eyed from a berserker's rage", "Breathing hard, with the berserk only just leaving {them}" } },
  ["War Stomp"] = { title = "Dust and Thunder", icon = "Ability_WarStomp", ["for"] = 120, lines = {
    "Dust still settling around {their} hooves from a war stomp", "Has the dust of a war stomp still on {their} legs" } },
}

---------------------------------------------------------------------------
-- Old enemies, by the names the combat log gives the creatures killed: { key, say (how
-- prose names them, plural), names (exact), prefix (name starts with), word (a word in it) }.
---------------------------------------------------------------------------
K.FOES = {
  Human = {
    { key = "defias", say = "of the Defias Brotherhood", prefix = { "Defias " } },
    { key = "gnolls", say = "gnolls", prefix = { "Riverpaw ", "Redridge ", "Mosshide ", "Rot Hide ", "Shadowhide " }, word = { "Gnoll" } },
    { key = "blackrock", say = "Blackrock orcs", prefix = { "Blackrock " } },
    { key = "syndicate", say = "of the Syndicate", prefix = { "Syndicate " } },
  },
  Dwarf = {
    { key = "darkiron", say = "Dark Iron dwarves", prefix = { "Dark Iron " } },
    { key = "troggs", say = "troggs", prefix = { "Rockjaw ", "Stonesplinter " }, word = { "Trogg" } },
    { key = "frostmane", say = "Frostmane trolls", prefix = { "Frostmane " } },
  },
  Gnome = {
    { key = "troggs", say = "troggs", prefix = { "Rockjaw ", "Stonesplinter " }, word = { "Trogg" } },
    { key = "leper", say = "leper gnomes", prefix = { "Leper Gnome", "Irradiated ", "Caverndeep " } },
    { key = "darkiron", say = "Dark Iron dwarves", prefix = { "Dark Iron " } },
  },
  NightElf = {
    { key = "satyrs", say = "satyrs", prefix = { "Xavian ", "Jadefire ", "Haldarr ", "Felmusk ", "Bleakheart ", "Jaedenar " }, word = { "Satyr" } },
    { key = "warsong", say = "Warsong orcs", prefix = { "Warsong " } },
    { key = "furbolg", say = "corrupted furbolgs", prefix = { "Gnarlpine ", "Deadwood ", "Foulweald " } },
  },
  Orc = {
    { key = "burningblade", say = "of the Burning Blade", prefix = { "Burning Blade " } },
    { key = "kultiras", say = "Kul Tiran soldiers", prefix = { "Kul Tiran ", "Kul Tiras " } },
    { key = "theramore", say = "Theramore soldiers", prefix = { "Theramore " } },
    { key = "blackrock", say = "Blackrock orcs", prefix = { "Blackrock " } },
  },
  Troll = {
    { key = "voodoo", say = "of Zalazane's thralls", prefix = { "Voodoo Troll", "Hexed Troll", "Zalazane" } },
    { key = "jungle", say = "jungle trolls of the old tribes", prefix = { "Bloodscalp ", "Skullsplitter ", "Gurubashi ", "Hakkari " } },
    { key = "kultiras", say = "Kul Tiran soldiers", prefix = { "Kul Tiran ", "Kul Tiras " } },
  },
  Tauren = {
    { key = "centaur", say = "centaurs", prefix = { "Kolkar ", "Galak ", "Magram ", "Gelkis ", "Maraudine " } },
    { key = "grimtotem", say = "of the Grimtotem", prefix = { "Grimtotem " } },
    { key = "venture", say = "of the Venture Company", prefix = { "Venture Co. " } },
    { key = "quilboar", say = "quilboar", prefix = { "Bristleback ", "Razormane " } },
  },
  Scourge = {
    { key = "scarlet", say = "of the Scarlet Crusade", prefix = { "Scarlet " } },
    { key = "scourge", say = "of the Scourge", prefix = { "Skeletal ", "Rotting ", "Plague ", "Ghoul", "Cultist", "Scourge " }, word = { "Ghoul", "Zombie" } },
    { key = "worgen", say = "worgen", prefix = { "Moonrage " }, names = { ["Son of Arugal"] = true }, word = { "Worgen" } },
  },
}
K.FOES.Undead = K.FOES.Scourge

---------------------------------------------------------------------------
-- More places that matter to each people (added to W.RACE_PLACES: { mood, strength, why },
-- by zone or subzone). The mood reads them while there; Sources/Kin.lua records the visit.
---------------------------------------------------------------------------
local MORE_PLACES = {
  Human = {
    ["Redridge Mountains"] = { "fierce", 10, "Blackrock raiders on the border" },
    ["Stromgarde Keep"] = { "sorrowful", 15, "Stromgarde's broken keep" },
    ["Ruins of Lordaeron"] = { "sorrowful", 18, "the old northern kingdom" },
    ["Stormwind Keep"] = { "proud", 12, "the king's keep" },
  },
  Dwarf = {
    ["Thandol Span"] = { "angry", 15, "the bridge the Dark Irons broke" },
    ["Aerie Peak"] = { "ease", 15, "Wildhammer kin" },
    ["Hall of Explorers"] = { "intrigued", 15, "the Explorers' League" },
  },
  Gnome = {
    ["Gadgetzan"] = { "intrigued", 10, "goblin engineering" },
    ["Steelgrill's Depot"] = { "ease", 12, "a gnome-run depot near home" },
    ["Brewnall Village"] = { "ease", 8, "the frozen lake near home" },
  },
  NightElf = {
    ["Darkshore"] = { "sorrowful", 10, "the ruins along the coast" },
    ["Feralas"] = { "ease", 10, "the old kaldorei forests" },
    ["Silithus"] = { "angry", 15, "the qiraji hives" },
    ["Temple of the Moon"] = { "devout", 18, "Elune's temple" },
  },
  Orc = {
    ["Burning Steppes"] = { "conflicted", 14, "Blackrock orcs still under the old banner" },
    ["Valley of Trials"] = { "ease", 12, "where the young ones start" },
    ["Alterac Valley"] = { "fierce", 15, "Frostwolf country" },
  },
  Troll = {
    ["Zul'Farrak"] = { "uneasy", 15, "the Sandfury temple" },
    ["The Hinterlands"] = { "angry", 10, "the Witherbark country" },
    ["Valley of Spirits"] = { "ease", 18, "the Darkspear quarter" },
  },
  Tauren = {
    ["Red Rocks"] = { "devout", 20, "the tauren burial ground" },
    ["Feralas"] = { "ease", 10, "the hills around Camp Mojache" },
    ["Desolace"] = { "angry", 12, "the centaurs' war lands" },
  },
  Scourge = {
    ["Stratholme"] = { "angry", 22, "the city that was culled" },
    ["Andorhal"] = { "downcast", 15, "a dead town of the plague" },
    ["Deathknell"] = { "ease", 15, "where the Forsaken wake" },
  },
}
for race, list in pairs(MORE_PLACES) do
  W.RACE_PLACES[race] = W.RACE_PLACES[race] or {}
  for place, v in pairs(list) do
    if not W.RACE_PLACES[race][place] then W.RACE_PLACES[race][place] = v end
  end
end
K.PLACE.proud = { title = "A Proud Place", icon = "INV_BannerPVP_02", lines = {
  "Has been to {place} lately, and stood straighter there.", "Went to {place}, the heart of {their} people's kingdom.",
  "Has walked through {place}, with {their} head up.", "Stood in {place} lately, and was proud to." } }
