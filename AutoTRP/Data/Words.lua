-- The words Auto TRP writes with. Kept in one place so tone can be tuned without touching
-- logic. Plain, in-world English: no game terms ("XP", "quest", "level") in profile text.
local _, ns = ...

local W = {}
ns.Words = W

---------------------------------------------------------------------------
-- Moods. `adj` reads in "Currently" ("Bone-tired, resting at..."), `title` and `tells`
-- are the "At first glance" slot: what a stranger would notice.
---------------------------------------------------------------------------
W.MOODS = {
  shaken = {
    title = "Shaken", icon = "Spell_Shadow_DeathScream",
    adj = { "Still shaken", "Pale and shaken", "Not quite steady yet" },
    tells = {
      "Flinches at sudden noises. The hands haven't stopped trembling.",
      "Keeps touching an old wound as if to make sure it's closed.",
      "Has the far-off look of someone who came very close to the end.",
    },
  },
  rattled = {
    title = "Rattled", icon = "Ability_Rogue_FeignDeath",
    adj = { "A little rattled", "Breathing hard", "Bruised and rattled" },
    tells = {
      "Fresh bruises, a torn sleeve, and eyes that keep checking the treeline.",
      "Patched up in a hurry. Bandages still spotting through.",
    },
  },
  elated = {
    title = "In High Spirits", icon = "Spell_Holy_SurgeOfLight",
    adj = { "In high spirits", "Flushed with success", "Grinning to {themselves}" },
    tells = {
      "Walks a little taller today, as if something long worked for finally came good.",
      "Can't quite keep the smile off {their} face.",
    },
  },
  triumphant = {
    title = "Triumphant", icon = "INV_BannerPVP_02",
    adj = { "Fresh from a hard-won victory", "Triumphant" },
    tells = {
      "Carries a trophy that wasn't won cheaply, and the swagger to match.",
      "Battle-stained but upright. Whatever it was, it's dead now.",
    },
  },
  satisfied = {
    title = "Satisfied", icon = "INV_Misc_Note_01",
    adj = { "Quietly satisfied", "Content with a day's work" },
    tells = {
      "Has the easy shoulders of someone who kept {their} word today.",
      "A coin purse a little heavier than this morning.",
    },
  },
  weary = {
    title = "Road-Weary", icon = "Spell_Nature_Sleep",
    adj = { "Bone-tired", "Road-weary", "Worn thin" },
    tells = {
      "Dust to the knees, and the slow walk of someone who's been on the road too long.",
      "Dark circles under the eyes. Could sleep standing up.",
      "Boots worn through at the heel; a pack that's clearly been carried a long way.",
    },
  },
  ease = {
    title = "At Ease", icon = "INV_Drink_04",
    adj = { "At ease", "Warm and unhurried", "Rested" },
    tells = {
      "Boots off, shoulders down. For once, nothing seems to be chasing {them}.",
      "Clean, fed and rested, and it shows.",
    },
  },
  merry = {
    title = "Merry", icon = "INV_Drink_05",
    adj = { "Merry", "Several cups in", "Cheerfully unsteady" },
    tells = {
      "Smells of ale and laughs a little too loudly.",
      "Swaying slightly, and very fond of everyone right now.",
    },
  },
  haunted = {
    title = "Haunted", icon = "Spell_Shadow_Possession",
    adj = { "Haunted", "Not entirely present", "Muttering under {their} breath" },
    tells = {
      "Glances at empty corners as if someone just spoke there.",
      "Counts things under {their} breath. Doesn't like what the shadows are doing.",
    },
  },
  wonder = {
    title = "Wide-Eyed", icon = "INV_Misc_Spyglass_02",
    adj = { "Wide-eyed", "Taking it all in", "Curious about everything" },
    tells = {
      "Keeps stopping to look at things the locals stopped seeing years ago.",
      "New to these parts, and making no secret of it.",
    },
  },
  homecoming = {
    title = "Home Again", icon = "INV_Misc_Rune_01",
    adj = { "Glad to be home", "Back on familiar ground" },
    tells = {
      "Greets the place like an old friend. The tension's gone out of {their} shoulders.",
    },
  },
  tense = {
    title = "On Guard", icon = "Ability_Warrior_DefensiveStance",
    adj = { "On guard", "Wound tight", "Watchful" },
    tells = {
      "Weapon never far from hand. Listens before every corner.",
      "Moves like someone who expects the floor to give way.",
    },
  },
  uneasy = {
    title = "Uneasy", icon = "Spell_Shadow_Twilight",
    adj = { "Uneasy", "Jumpy", "Keeping to the light" },
    tells = {
      "Keeps the lantern close and the back to a wall.",
      "Doesn't like this place, and doesn't pretend to.",
    },
  },
  sociable = {
    title = "Talkative", icon = "INV_Letter_15",
    adj = { "Talkative", "Full of news", "In a sociable mood" },
    tells = {
      "Has been talking to half the town and seems to know everyone's business.",
      "Quick to strike up a conversation today.",
    },
  },
  intrigued = {
    title = "Intrigued", icon = "INV_Misc_Book_06",
    adj = { "Turning something over", "Intrigued", "Preoccupied" },
    tells = {
      "Has heard something they can't let go of. It shows in the frown.",
      "Lost in thought, piecing something together.",
    },
  },
  determined = {
    title = "Determined", icon = "Ability_Warrior_BattleShout",
    adj = { "Determined", "Set on a purpose" },
    tells = {
      "Has the look of someone with somewhere to be and something to prove.",
    },
  },
  company = {
    title = "In Good Company", icon = "Spell_Holy_PrayerOfSpirit",
    adj = { "In good company", "Among friends" },
    tells = {
      "Travelling with others, and easier for it.",
    },
  },
  sorrowful = {
    title = "Sorrowful", icon = "Spell_Holy_PainSupression",
    adj = { "Red-eyed and quiet", "Sorrowful", "Heavy-hearted" },
    tells = {
      "Eyes rimmed red. Answers in as few words as {they} can manage.",
      "Carries some private grief, and carries it badly today.",
    },
  },
  angry = {
    title = "Short-Tempered", icon = "Ability_Warrior_Rampage",
    adj = { "Fuming", "Short-tempered", "Spoiling for a fight" },
    tells = {
      "Jaw set, knuckles white. Best not to jostle {them} right now.",
      "Something has {their} blood up, and it isn't cooling.",
    },
  },
  smitten = {
    title = "Smitten", icon = "INV_ValentinesCandy",
    adj = { "Smitten", "Distracted by someone", "Humming to {themselves}" },
    tells = {
      "Keeps smiling at nothing, and checking the door for someone.",
      "Has the dreamy, faraway look of someone thinking about a particular face.",
    },
  },
  devout = {
    title = "At Prayer", icon = "Spell_Holy_PrayerOfHealing",
    adj = { "Quiet and prayerful", "Lost in prayer" },
    tells = {
      "Head bowed, lips moving. Somewhere far from here.",
      "Has the stillness of someone who has just finished praying.",
    },
  },
  fed = {
    title = "Well-Fed", icon = "INV_Misc_Food_15",
    adj = { "Well-fed", "Pleasantly full" },
    tells = { "Crumbs on the collar and the contented air of a good meal." },
  },
  downcast = {
    title = "Downcast", icon = "Spell_Shadow_GatherShadows",
    adj = { "Downcast", "Quiet and grim", "Carrying a bad day on {their} shoulders" },
    tells = {
      "Has the hollow, quiet look of someone who has died recently and hasn't made peace with it.",
      "Moves carefully, like someone not yet sure the ground will hold.",
      "Doesn't laugh at jokes today. Something cold followed {them} back.",
    },
  },
  frustrated = {
    title = "Frustrated", icon = "Ability_Warrior_Revenge",
    adj = { "Thoroughly fed up", "Frustrated", "At the end of {their} rope" },
    tells = {
      "Muttering curses at no one in particular. It has clearly been one of those days.",
      "Has fallen more than once today and is taking it personally.",
    },
  },
  bolstered = {
    title = "In Fine Fettle", icon = "Spell_Holy_WordFortitude",
    adj = { "In fine fettle", "Brimming with vigour", "Feeling unstoppable" },
    tells = {
      "Fairly crackling with borrowed blessings. Stands like nothing could knock {them} down.",
      "Glowing faintly with wards and blessings, and enjoying it.",
    },
  },
  glorious = {
    title = "Glorious", icon = "INV_Misc_Head_Dragon_01",
    adj = { "Riding high on a city's cheer", "Glorious", "Blazing with borrowed glory" },
    tells = {
      "Carries the blessing of a whole city's victory. It shows in every step.",
      "Positively radiant. Someone, somewhere, is singing about this.",
    },
  },
  ailing = {
    title = "Ailing", icon = "Spell_Shadow_AbominationExplosion",
    adj = { "Feverish", "Ailing", "Green about the gills" },
    tells = {
      "Pale and sweating, with a cough that doesn't sound good.",
      "Whatever {they} caught out there is still in {their} blood.",
    },
  },
  drained = {
    title = "Drained", icon = "Spell_Shadow_SoulLeech_2",
    adj = { "Drained", "Weak as a kitten", "Hollow-eyed" },
    tells = {
      "Still grey from the trip back from the other side. Every movement costs.",
    },
  },
  wounded = {
    title = "Wounded", icon = "Ability_Rogue_FeignDeath",
    adj = { "Nursing fresh wounds", "Bloodied", "Limping" },
    tells = {
      "Bandages wrapped tight and still spotting red.",
      "Favouring one leg and wincing when {they} think no one's looking.",
    },
  },
  festive = {
    title = "Festive", icon = "INV_Holiday_Christmas_Present_01",
    adj = { "In a festive mood" }, tells = { "Caught up in the season's cheer." },
  },
  fierce = {
    title = "Battle-Hungry", icon = "Ability_Warrior_BattleShout",
    adj = { "Blood up", "Battle-hungry", "Spoiling for the next fight" },
    tells = {
      "Still breathing hard from the last fight and already looking for the next.",
      "Fresh blood on the blade, none of it {their} own.",
    },
  },
  worried = {
    title = "Worried", icon = "INV_Misc_Coin_04",
    adj = { "Worried about money", "Counting copper", "Down to {their} last coins" },
    tells = {
      "Purse hangs light and flat. Checks prices twice before buying anything.",
      "Mending {their} own gear because the smith costs too much.",
    },
  },
  flush = {
    title = "Flush", icon = "INV_Misc_Coin_01",
    adj = { "Flush with coin", "Feeling wealthy", "Jingling as {they} walk" },
    tells = {
      "A heavy purse and a generous mood. Someone's buying the next round.",
      "Recently came into money, and it shows in the swagger.",
    },
  },
  thrilled = {
    title = "Thrilled", icon = "INV_Misc_Gem_Pearl_04",
    adj = { "Thrilled", "Admiring a new prize", "Barely able to keep still" },
    tells = {
      "Keeps taking out a new treasure to admire it.",
      "Has just found something wonderful, and wants everyone to ask about it.",
    },
  },
  conflicted = {
    title = "Conflicted", icon = "Spell_Shadow_UnholyStrength",
    adj = { "Conflicted", "Troubled by a choice", "Second-guessing {themselves}" },
    tells = {
      "Turns something over and over in {their} head, and doesn't like the answer.",
      "Has the look of someone who did a thing they're not proud of.",
    },
  },
  righteous = {
    title = "Righteous", icon = "Spell_Holy_SealOfRighteousness",
    adj = { "Quietly righteous", "At peace with {their} choices" },
    tells = { "Stands a little straighter, like someone who just did the right thing." },
  },
  proud = {
    title = "Proud", icon = "INV_Misc_Ribbon_01",
    adj = { "Proud", "Standing tall" },
    tells = { "Has earned some goodwill lately, and walks like it." },
  },
  ashamed = {
    title = "Ashamed", icon = "Spell_Shadow_Charm",
    adj = { "Ashamed", "Keeping {their} head down" },
    tells = { "Avoids meeting people's eyes. Word of something has got around." },
  },
  eager = {
    title = "Eager", icon = "Spell_Holy_BlessingOfStrength",
    adj = { "Eager", "On the verge of something", "Restless with promise" },
    tells = { "Has the restless energy of someone right on the edge of getting better at this." },
  },
  burdened = {
    title = "Overloaded", icon = "INV_Misc_Bag_08",
    adj = { "Weighed down", "Overloaded" },
    tells = { "Packs stuffed to bursting, clanking with every step." },
  },
  newsy = {
    title = "Full of News", icon = "INV_Letter_03",
    adj = { "Full of news", "Mulling over a letter" },
    tells = { "Has a letter tucked in {their} coat and keeps rereading it." },
  },
  accomplished = {
    title = "Accomplished", icon = "INV_Misc_Note_06",
    adj = { "Having a good day", "On a roll" },
    tells = { "Has been crossing jobs off the list all day and is pleased about it." },
  },
  lonely = {
    title = "Solitary", icon = "Spell_Shadow_Teleport",
    adj = { "Alone with {their} thoughts", "Keeping to {themselves}" },
    tells = {
      "Has the quiet manner of someone who's been on {their} own a long while.",
    },
  },
}

-- Baseline when nothing stands out, tinted by temperament (the top RPG Dialogue trait).
W.CALM = {
  default = { title = "Steady", icon = "Spell_Nature_Tranquility", adj = { "Steady", "Calm", "Even-tempered" },
    tells = { "Unremarkable at a glance, which may be the point.", "Calm, watchful, and in no hurry." } },
  kind = { title = "Warm", icon = "Spell_Holy_Renew", adj = { "In good spirits", "Warm" },
    tells = { "Quick with a smile and a nod for strangers." } },
  stern = { title = "Composed", icon = "Ability_Warrior_CommandingShout", adj = { "Composed", "Stern-faced" },
    tells = { "Stands straight, speaks little, misses nothing." } },
  witty = { title = "Wry", icon = "INV_Misc_Toy_07", adj = { "Wry", "Amused at something" },
    tells = { "A half-smile, as though everything is a joke only {they've} heard." } },
  cruel = { title = "Cold", icon = "Spell_Shadow_ShadowWordPain", adj = { "Cold", "Hard-eyed" },
    tells = { "People step out of {their} way without quite knowing why." } },
  pious = { title = "Prayerful", icon = "Spell_Holy_PrayerOfHealing", adj = { "Prayerful", "Serene" },
    tells = { "Lips move now and then in a quiet prayer." } },
  skeptical = { title = "Doubtful", icon = "INV_Misc_QuestionMark", adj = { "Doubtful", "Unconvinced" },
    tells = { "An eyebrow that's permanently halfway raised." } },
  greedy = { title = "Calculating", icon = "INV_Misc_Coin_02", adj = { "Calculating", "Counting coin" },
    tells = { "Eyes that price everything they land on." } },
  generous = { title = "Open-Handed", icon = "INV_Misc_Bag_10", adj = { "Open-handed", "Generous" },
    tells = { "Always seems to have a spare coin or a spare loaf for someone." } },
  curious = { title = "Inquisitive", icon = "INV_Misc_Book_09", adj = { "Inquisitive", "Curious" },
    tells = { "Asks one question too many, and listens to every answer." } },
  brave = { title = "Bold", icon = "Ability_Warrior_BattleShout", adj = { "Bold", "Unafraid" },
    tells = { "Walks into rooms like {they've} already decided how it ends." } },
  cautious = { title = "Careful", icon = "Ability_Stealth", adj = { "Careful", "Watchful" },
    tells = { "Always knows where the nearest door is." } },
  charming = { title = "Charming", icon = "INV_ValentinesCard02", adj = { "Charming", "Easy-going" },
    tells = { "Has a way of making people feel like the only one in the room." } },
  reserved = { title = "Reserved", icon = "INV_Misc_Book_08", adj = { "Reserved", "Quiet" },
    tells = { "Speaks only when it's worth the breath." } },
}

---------------------------------------------------------------------------
-- RPG Dialogue traits, as words and as personality bars.
---------------------------------------------------------------------------
W.TRAIT_ADJ = {
  witty = "quick-witted", stern = "stern", kind = "kind", cruel = "cruel", pious = "devout",
  skeptical = "skeptical", greedy = "grasping", generous = "generous", curious = "curious",
  brave = "brave", cautious = "careful", charming = "charming", reserved = "reserved",
}

-- Personality bars: left word, right word, left trait, right trait, icons.
W.TRAIT_BARS = {
  { "Kind", "Cruel", "kind", "cruel", "Spell_Holy_Renew", "Spell_Shadow_ShadowWordPain" },
  { "Brave", "Cautious", "brave", "cautious", "Ability_Warrior_BattleShout", "Ability_Stealth" },
  { "Generous", "Greedy", "generous", "greedy", "INV_Misc_Bag_10", "INV_Misc_Coin_02" },
  { "Religious", "Skeptical", "pious", "skeptical", "Spell_Holy_PrayerOfHealing", "INV_Misc_QuestionMark" },
  { "Outgoing", "Reserved", "charming", "reserved", "INV_ValentinesCard02", "INV_Misc_Book_08" },
  { "Playful", "Serious", "witty", "stern", "INV_Misc_Toy_07", "Ability_Warrior_CommandingShout" },
}

-- Alignment axes: positive is the left word.
W.AXIS_BARS = {
  { axis = "light", left = "Good", right = "Evil", li = "Spell_Holy_HolyBolt", ri = "Spell_Shadow_ShadowBolt" },
  { axis = "order", left = "Lawful", right = "Chaotic", li = "INV_Misc_Book_11", ri = "Spell_Nature_Cyclone" },
  { axis = "honor", left = "Honest", right = "Deceitful", li = "Spell_Holy_SealOfWisdom", ri = "INV_Misc_Mask_01" },
}

-- RPG Dialogue's alignment titles (Effects.TITLES), by faction.
W.ALIGN_TITLES = {
  { id = "lightsworn", axis = "light", sign = 1, Alliance = "Lightsworn", Horde = "Sunwalker-hearted" },
  { id = "shadowed", axis = "light", sign = -1, Alliance = "Shadowed", Horde = "Shadow-touched" },
  { id = "lawkeeper", axis = "order", sign = 1, Alliance = "Lawkeeper", Horde = "Loyal Blade" },
  { id = "wildborn", axis = "order", sign = -1, Alliance = "Wild Heart", Horde = "Spirit-walker" },
  { id = "oathbound", axis = "honor", sign = 1, Alliance = "Oathbound", Horde = "Honor-bound" },
  { id = "silvertongue", axis = "honor", sign = -1, Alliance = "Silvertongue", Horde = "Shadow-dealer" },
}

-- How a lean shows in a sentence ("walks in the Light").
W.AXIS_PROSE = {
  light = { [1] = "keeps to the Light", [-1] = "is no stranger to shadow" },
  order = { [1] = "believes in law and keeping one's place", [-1] = "answers to no one's rules but {their} own" },
  honor = { [1] = "keeps {their} word", [-1] = "can lie with a straight face" },
}

---------------------------------------------------------------------------
-- Mottos by dominant trait (one is picked and kept).
---------------------------------------------------------------------------
W.MOTTOS = {
  kind = { "Leave every place a little better than you found it.", "No one walks alone if I can help it." },
  cruel = { "Mercy is a debt the strong never collect.", "Fear keeps longer than gratitude." },
  brave = { "Forward, and let the dark do its worst.", "If it bleeds, it can be beaten." },
  cautious = { "Count the exits before you count the coin.", "The patient blade cuts deepest." },
  generous = { "What's mine is the road's.", "A full purse is a lonely thing." },
  greedy = { "Everything has a price. Most people ask too little.", "Gold remembers what people forget." },
  pious = { "The Light sees the road ahead even when I can't.", "Faith first. The rest follows." },
  skeptical = { "Trust, but count your fingers after.", "Show me, and then I'll believe it." },
  witty = { "If it can't be fixed, it can at least be laughed at.", "Life's too short to be dull." },
  stern = { "Duty before comfort.", "Say less. Mean all of it." },
  curious = { "Every road leads somewhere worth seeing.", "There's always one more question." },
  charming = { "A kind word opens more doors than a crowbar.", "Make friends first. Ask favours later." },
  reserved = { "Listen twice, speak once.", "Still water runs deep." },
  default = { "One road at a time.", "Keep moving." },
}

---------------------------------------------------------------------------
-- Opinions from RPG Dialogue (char.opinions[topic].stance).
---------------------------------------------------------------------------
W.TOPICS = {
  the_light = "the Light", warchief = "the Warchief", night_elves = "the night elves",
  humans = "humans", orcs = "orcs", forsaken = "the Forsaken", alliance = "the Alliance", horde = "the Horde",
  scarlet_crusade = "the Scarlet Crusade", defias = "the Defias", the_elements = "the elements",
  twilights_hammer = "the Twilight's Hammer", explorers_league = "the Explorers' League",
  venture_company = "the Venture Company", demons = "demons", sylvanas = "the Dark Lady",
  jaina = "Lady Proudmoore", bolvar = "Highlord Bolvar", prestor = "Lady Prestor",
  stormwind = "Stormwind", westfall = "Westfall", ashenvale = "the war in Ashenvale",
  alterac = "Alterac", stromgarde = "Stromgarde", dwarves = "dwarves", gnomes = "gnomes",
  trolls = "trolls", tauren = "tauren", undead = "the undead", magic = "magic", druids = "druids",
}

-- {t} is the topic. Stances not listed here are left out rather than guessed at.
W.STANCES = {
  respect = "respects {t}", admire = "admires {t}", trust = "trusts {t}", loyal = "is loyal to {t}",
  distrust = "distrusts {t}", hate = "has no love for {t}", pity = "pities {t}",
  mixed = "is of two minds about {t}", arrogant = "finds {t} arrogant", traitor = "calls {t} a traitor",
  faith = "keeps faith in {t}", enemy = "counts {t} an enemy", dangerous = "thinks {t} dangerous",
  useful = "thinks {t} useful", power = "respects the power of {t}", defy = "would defy {t}",
  sympathize = "has some sympathy for {t}", soft = "thinks {t} too soft", abandoned = "feels {t} was abandoned",
  abandoned_its_own = "feels {t} abandoned its own", hardline = "has no patience for {t}",
  masons_wronged = "believes the stonemasons behind {t} were wronged", wrong = "thinks {t} is wrong",
  necessary = "thinks {t} is a necessary evil", lost = "thinks {t} is lost", retake = "wants {t} retaken",
  dead = "thinks {t} is dead and buried", mistaken = "thinks {t} was a mistake",
}

W.PEACE = {
  ["for"] = "would rather keep the peace", peace = "would rather keep the peace",
  against = "doesn't believe the peace will hold", war = "thinks war is coming, and should",
}

---------------------------------------------------------------------------
-- Standing (RPG Dialogue town tiers).
---------------------------------------------------------------------------
W.TIERS = {
  { name = "Reviled", max = -60, phrase = "reviled in {town}" },
  { name = "Distrusted", max = -20, phrase = "distrusted in {town}" },
  { name = "Stranger", max = 9 },
  { name = "Known", max = 29, phrase = "known in {town}" },
  { name = "Liked", max = 54, phrase = "well-liked in {town}" },
  { name = "Respected", max = 79, phrase = "respected in {town}" },
  { name = "Hero", max = 100, phrase = "a hero to {town}" },
}

W.FULLTITLE_TIER = {
  Known = "Known in {town}", Liked = "Friend of {town}", Respected = "Respected in {town}", Hero = "Hero of {town}",
}

---------------------------------------------------------------------------
-- Places. Zones with a mood of their own.
---------------------------------------------------------------------------
W.EERIE_ZONES = {
  ["Duskwood"] = true, ["Tirisfal Glades"] = true, ["Silverpine Forest"] = true, ["Felwood"] = true,
  ["Western Plaguelands"] = true, ["Eastern Plaguelands"] = true, ["Deadwind Pass"] = true,
  ["Swamp of Sorrows"] = true, ["Blasted Lands"] = true, ["Desolace"] = true, ["Undercity"] = true,
}

W.RACE_HOME = {
  Human = "Elwynn Forest", Dwarf = "Dun Morogh", Gnome = "Dun Morogh", NightElf = "Teldrassil",
  Orc = "Durotar", Troll = "the Echo Isles", Tauren = "Mulgore", Scourge = "Tirisfal Glades",
  Undead = "Tirisfal Glades",
}

W.CLASS_NOUN = {
  WARRIOR = "soldier", PALADIN = "paladin", HUNTER = "hunter", ROGUE = "rogue", PRIEST = "priest",
  SHAMAN = "shaman", MAGE = "mage", WARLOCK = "warlock", DRUID = "druid",
}

-- Seasoning by level band: how a stranger would size them up.
W.SEASONED = {
  { max = 9, words = { "green", "untested" } },
  { max = 24, words = { "promising", "road-tested" } },
  { max = 44, words = { "seasoned", "capable" } },
  { max = 59, words = { "hardened", "veteran" } },
  { max = 99, words = { "legendary", "battle-scarred" } },
}

---------------------------------------------------------------------------
-- Zone atmosphere for "Currently", out on the road. Each is a whole phrase.
---------------------------------------------------------------------------
W.ZONE_FLAVOR = {
  ["Elwynn Forest"] = { "wandering the oak woods of Elwynn", "walking the farm lanes of Elwynn" },
  ["Westfall"] = { "crossing the fallow fields of Westfall", "on the dusty roads of Westfall, past empty farmhouses" },
  ["Redridge Mountains"] = { "in the red hills above Lake Everstill", "on the mountain trails of Redridge" },
  ["Duskwood"] = { "beneath the dead trees of Duskwood", "on the dark road through Duskwood" },
  ["Stranglethorn Vale"] = { "hacking through the jungle of Stranglethorn", "sweating through the vines of Stranglethorn" },
  ["Dun Morogh"] = { "trudging through the snows of Dun Morogh", "in the frozen valleys of Dun Morogh" },
  ["Loch Modan"] = { "along the shores of Loch Modan", "in the green hills of Loch Modan" },
  ["Wetlands"] = { "slogging through the Wetlands", "knee-deep in the marshes of the Wetlands" },
  ["Arathi Highlands"] = { "crossing the windswept Arathi Highlands", "among the old stones of Arathor" },
  ["Hillsbrad Foothills"] = { "in the rolling foothills of Hillsbrad", "among the orchards of Hillsbrad" },
  ["Alterac Mountains"] = { "in the cold passes of Alterac", "among the ruins of Alterac" },
  ["The Hinterlands"] = { "in the wild Hinterlands", "under the gryphon-haunted peaks of the Hinterlands" },
  ["Silverpine Forest"] = { "under the grey pines of Silverpine", "in the fog of Silverpine Forest" },
  ["Tirisfal Glades"] = { "among the withered fields of Tirisfal", "in the gloom of Tirisfal Glades" },
  ["Western Plaguelands"] = { "in the blighted fields of the Western Plaguelands", "past the ruined farms of Lordaeron" },
  ["Eastern Plaguelands"] = { "deep in the Eastern Plaguelands", "on the ash-grey roads of the Plaguelands" },
  ["Badlands"] = { "under the baking sun of the Badlands", "among the dry canyons of the Badlands" },
  ["Searing Gorge"] = { "in the smoke and slag of the Searing Gorge" },
  ["Burning Steppes"] = { "on the scorched earth of the Burning Steppes" },
  ["Swamp of Sorrows"] = { "in the mists of the Swamp of Sorrows" },
  ["Blasted Lands"] = { "on the red wastes of the Blasted Lands", "within sight of the Dark Portal" },
  ["Deadwind Pass"] = { "in the silent gorge of Deadwind Pass" },
  ["Durotar"] = { "on the red earth of Durotar", "in the dry canyons of Durotar" },
  ["Mulgore"] = { "on the open grass of Mulgore", "beneath the mesas of Mulgore" },
  ["The Barrens"] = { "crossing the endless Barrens", "on the long, hot road through the Barrens" },
  ["Teldrassil"] = { "beneath the great boughs of Teldrassil", "in the twilight woods of Teldrassil" },
  ["Darkshore"] = { "along the grey beaches of Darkshore", "on the misty shore of Darkshore" },
  ["Ashenvale"] = { "under the ancient canopy of Ashenvale", "in the deep woods of Ashenvale" },
  ["Stonetalon Mountains"] = { "on the high trails of Stonetalon", "among the logged-out slopes of Stonetalon" },
  ["Desolace"] = { "crossing the barren wastes of Desolace" },
  ["Thousand Needles"] = { "among the stone spires of Thousand Needles" },
  ["Dustwallow Marsh"] = { "slogging through Dustwallow Marsh", "in the humid fens of Dustwallow" },
  ["Feralas"] = { "in the rain-soaked forests of Feralas", "beneath the giant trees of Feralas" },
  ["Tanaris"] = { "squinting across the dunes of Tanaris", "in the shifting sands of Tanaris" },
  ["Un'Goro Crater"] = { "in the steaming jungle of Un'Goro", "keeping clear of the dinosaurs in Un'Goro" },
  ["Felwood"] = { "in the sickly woods of Felwood", "among the corrupted trees of Felwood" },
  ["Azshara"] = { "among the ruined Highborne halls of Azshara", "on the autumn coast of Azshara" },
  ["Winterspring"] = { "in the snowfields of Winterspring", "on the frozen roads of Winterspring" },
  ["Moonglade"] = { "in the peaceful glades of Moonglade" },
  ["Silithus"] = { "in the stinging sands of Silithus", "among the hives of Silithus" },
}

---------------------------------------------------------------------------
-- What you're busy with (held for a few minutes after it happens). {place} is filled in.
---------------------------------------------------------------------------
W.ACTIVITY = {
  mail = { "reading letters at the mailbox in {place}", "sorting the post in {place}" },
  bank = { "settling accounts at the bank in {place}", "counting coin at the bank in {place}" },
  auction = { "haggling at the auction house in {place}", "picking over the auction lots in {place}" },
  merchant = { "bartering with a merchant in {place}", "haggling over prices in {place}" },
  trainer = { "taking lessons in {place}", "learning something new in {place}" },
  fishing = { "fishing the waters of {place}", "with a line in the water at {place}" },
  eating = { "sitting down to a meal in {place}", "eating in {place}" },
  drinking = { "taking a long drink in {place}" },
  flightmaster = { "waiting on a flight out of {place}" },
  talk = { "talking with {who} in {place}", "deep in conversation with {who} in {place}" },
  reading = { "reading {what} in {place}", "with {their} nose in {what}, in {place}" },
  duel = { "trading blows in a duel in {place}", "squaring off in a duel in {place}" },
  away = { "lost in thought in {place}, not really listening", "staring into the middle distance in {place}" },
  sitting = { "sitting down for a rest in {place}", "taking a seat in {place}" },
  sleeping = { "asleep in {place}", "dozing in {place}" },
  dancing = { "dancing in {place}", "dancing without a care in {place}" },
  hearth = { "heading home from {place}", "on {their} way back home" },
}

-- Mounts, by the words in the mount's name (checked in order).
W.MOUNTS = {
  { "Felsteed", "on a fel-fire steed" }, { "Dreadsteed", "on a dreadsteed wreathed in flame" },
  { "Charger", "astride a holy charger" }, { "Warhorse", "on a paladin's warhorse" },
  { "Skeletal", "on a skeletal horse" }, { "Mechanostrider", "astride a clanking mechanostrider" },
  { "Ram", "riding a mountain ram" }, { "Kodo", "riding a great kodo" }, { "Raptor", "riding a raptor" },
  { "Wolf", "on wolfback" }, { "saber", "on a nightsaber" }, { "Tiger", "on a striped tiger" },
  { "Stallion", "on horseback" }, { "Mare", "on horseback" }, { "Pinto", "on horseback" }, { "Horse", "on horseback" },
  { "Steed", "on horseback" }, { "Palomino", "on horseback" },
}
-- When the mount can't be told apart: what that race usually rides.
W.RACE_MOUNT = {
  Human = "on horseback", Dwarf = "riding a mountain ram", Gnome = "astride a clanking mechanostrider",
  NightElf = "on a nightsaber", Orc = "on wolfback", Troll = "riding a raptor", Tauren = "riding a great kodo",
  Scourge = "on a skeletal horse",
}
-- Flights, by faction (bats in the Forsaken's lands, hippogryphs over Kalimdor for the Alliance).
W.KALIMDOR = {
  ["Teldrassil"] = true, ["Darkshore"] = true, ["Ashenvale"] = true, ["Stonetalon Mountains"] = true,
  ["Desolace"] = true, ["Feralas"] = true, ["Thousand Needles"] = true, ["Tanaris"] = true, ["Un'Goro Crater"] = true,
  ["Silithus"] = true, ["Felwood"] = true, ["Winterspring"] = true, ["Azshara"] = true, ["Moonglade"] = true,
  ["Dustwallow Marsh"] = true, ["The Barrens"] = true, ["Durotar"] = true, ["Mulgore"] = true,
  ["Darnassus"] = true, ["Orgrimmar"] = true, ["Thunder Bluff"] = true,
}
W.BAT_ZONES = { ["Tirisfal Glades"] = true, ["Silverpine Forest"] = true, ["Hillsbrad Foothills"] = true,
  ["Undercity"] = true, ["Western Plaguelands"] = true, ["Eastern Plaguelands"] = true }

-- At work on a craft (keyed by the profession name the game reports).
W.CRAFT = {
  Alchemy = "bent over an alchemy table", Blacksmithing = "hammering at the anvil",
  Leatherworking = "working a stretched hide", Tailoring = "busy with needle and thread",
  Engineering = "tinkering with a half-built contraption", Enchanting = "tracing runes with a glowing rod",
  Cooking = "cooking over an open fire", ["First Aid"] = "rolling bandages", Jewelcrafting = "cutting gems",
  Mining = "smelting ore", Poisons = "mixing poisons, carefully",
}

-- Text emotes you use move your mood. Matched against "You <verb>..." lines.
W.EMOTES = {
  sorrowful = { "cry", "sob", "weep", "mourn" },
  angry = { "rage", "growl", "snarl", "threaten", "glare", "angry", "fume" },
  merry = { "dance", "cheer", "laugh", "giggle", "chuckle", "toast", "rofl", "guffaw" },
  smitten = { "flirt", "kiss", "blush", "love", "swoon", "cuddle" },
  devout = { "pray", "kneel" },
  shaken = { "cower", "scared", "flee", "tremble" },
  sociable = { "wave", "greet", "hug", "thank", "bow", "welcome", "hail" },
  ease = { "sleep", "relax" },
}

---------------------------------------------------------------------------
-- What you wear and carry (for the Physical sketch and the Marks glance).
---------------------------------------------------------------------------
W.ARMOR = { Plate = "plate", Mail = "mail", Leather = "leathers", Cloth = "robes" }
W.WEAR_QUALITY = { [0] = "threadbare", [1] = "patched, mismatched", [2] = "serviceable", [3] = "fine", [4] = "remarkable", [5] = "storied" }
W.WEAPONS = {
  ["Two-Handed Axes"] = "a great axe", ["One-Handed Axes"] = "an axe", ["Two-Handed Swords"] = "a greatsword",
  ["One-Handed Swords"] = "a sword", ["Two-Handed Maces"] = "a heavy maul", ["One-Handed Maces"] = "a mace",
  ["Polearms"] = "a polearm", ["Staves"] = "a staff", ["Daggers"] = "a dagger", ["Fist Weapons"] = "fist weapons",
  ["Bows"] = "a bow", ["Guns"] = "a rifle", ["Crossbows"] = "a crossbow", ["Wands"] = "a wand",
  ["Thrown"] = "throwing knives", ["Fishing Poles"] = "a fishing pole", ["Shields"] = "a shield",
}

-- Pets, for "Currently": {pet} is its name, {kind} what it is.
W.PET = {
  HUNTER = { "with {pet} at heel", "{pet} the {kind} padding alongside" },
  WARLOCK = { "with {pet} the {kind} in tow", "{pet} the {kind} lurking close behind" },
}

-- The festive mood takes the season's colours.
W.FESTIVALS = {
  winterveil = { title = "Merry Winter Veil", adj = { "Full of Winter Veil cheer", "Festive" },
    tells = { "Smells of pine and gingerbread, and has a gift-wrapped something under one arm." } },
  hallowsend = { title = "Spooky", adj = { "In a spooky mood", "Grinning like a carved gourd" },
    tells = { "There are candle drippings on {their} sleeves and a mischievous glint in {their} eye." } },
  love = { title = "Lovestruck", adj = { "Feeling romantic", "Lovestruck" },
    tells = { "Has a pink ribbon tucked somewhere and a soft look about {them}." } },
  midsummer = { title = "Sun-Warmed", adj = { "Sun-warmed and cheerful", "Full of summer" },
    tells = { "Smells of bonfire smoke and summer flowers." } },
  brewfest = { title = "Brewfest Spirit", adj = { "In the Brewfest spirit", "Ale-happy" },
    tells = { "Wears a slightly crooked festival hat and a foam moustache." } },
  lunar = { title = "Honouring Elders", adj = { "Thoughtful, as the old year turns" },
    tells = { "Carries a lantern and a quiet thought for those who came before." } },
  noblegarden = { title = "Springtime", adj = { "Full of spring" },
    tells = { "Has a painted egg in one pocket and grass stains on {their} knees." } },
}

-- What a character wants, when nothing else says (by class). Kept broad and lore-safe.
W.AMBITIONS = {
  WARRIOR = { "To be the last one standing when it matters.", "To earn a name worth shouting on a battlefield." },
  PALADIN = { "To be worthy of the Light {they} carry.", "To stand between the innocent and the dark." },
  HUNTER = { "To track down the beast no one else can.", "To know every trail in the wild by heart." },
  ROGUE = { "One big score, and then maybe an honest life.", "To always know a little more than anyone else in the room." },
  PRIEST = { "To mend what can be mended, and bury what can't.", "To keep faith when it's hardest." },
  SHAMAN = { "To keep the elements in balance.", "To be a voice the spirits will listen to." },
  MAGE = { "To understand the arcane, not just wield it.", "To find a library no one else has read." },
  WARLOCK = { "Power enough that no one can ever take anything from {them} again.", "To master what others only fear." },
  DRUID = { "To heal the wounded land.", "To walk every shape the wild offers." },
  default = { "To find out what's over the next hill." },
}

-- What a stranger notices on the body, by physique (strongest attribute).
W.PHYSIQUE = {
  strength = { "broad-shouldered and strong", "heavy with muscle" },
  agility = { "lean and quick on {their} feet", "wiry and light-footed" },
  stamina = { "sturdy and hard to knock down", "thick-set and solid" },
  intellect = { "sharp-eyed, with a scholar's stoop", "ink-stained and thoughtful" },
  spirit = { "calm, with an unhurried air", "serene, with steady eyes" },
}

W.SLOT_NOUN = { [1] = "helm", [3] = "shoulders", [5] = "chest", [7] = "legs", [10] = "gloves", [15] = "cloak",
  [16] = "weapon", [17] = "off-hand", [18] = "ranged weapon", [19] = "tabard", [8] = "boots", [6] = "belt", [9] = "bracers" }

---------------------------------------------------------------------------
-- Rank by experience (the short title before your name), per class, in level bands
-- 1-9, 10-19, 20-29, 30-39, 40-49, 50-59, 60.
---------------------------------------------------------------------------
W.RANKS = {
  WARRIOR = { "Recruit", "Militia", "Soldier", "Sergeant", "Veteran", "Champion", "Warmaster" },
  PALADIN = { "Initiate", "Squire", "Knight", "Templar", "Crusader", "Justicar", "Grand Templar" },
  HUNTER = { "Novice", "Tracker", "Ranger", "Pathfinder", "Stalker", "Huntmaster", "Master Hunter" },
  ROGUE = { "Cutpurse", "Footpad", "Thief", "Shadow", "Blade", "Nightblade", "Master Assassin" },
  PRIEST = { "Acolyte", "Initiate", "Deacon", "Priest", "Confessor", "High Cleric", "Elder Cleric" },
  SHAMAN = { "Initiate", "Seer", "Spirit-Speaker", "Stormcaller", "Farseer", "Elder Farseer", "Elder Shaman" },
  MAGE = { "Apprentice", "Novice", "Adept", "Magus", "Sorcerer", "Arcanist", "Master Arcanist" },
  WARLOCK = { "Initiate", "Occultist", "Summoner", "Shadowcaster", "Diabolist", "Dreadcaller", "Master Diabolist" },
  DRUID = { "Initiate", "Neophyte", "Grove Warden", "Wild Walker", "Shapeshifter", "Elder Druid", "Elder of the Circle" },
  default = { "Initiate", "Apprentice", "Journeyman", "Adept", "Expert", "Master", "Grandmaster" },
}

-- Professions by skill, for History.
W.PROF_RANK = {
  { min = 225, word = "a master" }, { min = 150, word = "an expert" },
  { min = 75, word = "a journeyman" }, { min = 1, word = "an apprentice" },
}

-- Faction names read with "the" in a sentence, except places and a few proper names.
W.FACTION_NO_THE = {
  Stormwind = true, Ironforge = true, Darnassus = true, Orgrimmar = true, ["Thunder Bluff"] = true,
  Undercity = true, ["Booty Bay"] = true, Gadgetzan = true, Everlook = true, Ratchet = true,
  Ravenholdt = true, ["Shen'dralar"] = true, ["Timbermaw Hold"] = true,
}
function W.FactionName(name)
  if type(name) ~= "string" or W.FACTION_NO_THE[name] or name:find("^The ") then return name and (name:gsub("^The ", "the ")) end
  return "the " .. name
end

---------------------------------------------------------------------------
-- Racial tells: how a mood shows on this body. Used about half the time, when one fits.
---------------------------------------------------------------------------
W.RACE_TELLS = {
  Human = {
    weary = { "Rubs the back of {their} neck and stifles a yawn every few steps." },
    merry = { "Humming an Elwynn drinking song, slightly off key." },
    uneasy = { "Keeps a hand near the hilt and glances over a shoulder at every sound." },
  },
  Dwarf = {
    weary = { "Beard tangled with road dust; even a dwarf's legs have limits." },
    merry = { "Booming laugh, foam in the beard, and a tankard that never seems empty." },
    angry = { "Beard bristling, jaw working. Something has offended {their} clan honour." },
    ease = { "Pipe lit, boots up, beard combed. Content as a dwarf by a forge." },
  },
  Gnome = {
    weary = { "Goggles pushed up and eyes red-rimmed. Hasn't stopped tinkering in hours." },
    elated = { "Bouncing on {their} toes and talking a mile a minute about something technical." },
    uneasy = { "Fiddling nervously with a gadget that whirs every time something moves." },
    wonder = { "Taking notes on everything, with diagrams." },
  },
  NightElf = {
    weary = { "Even the long-lived tire. Ears droop a little, eyes dimmer than usual." },
    uneasy = { "Ears flick at every sound; silver eyes narrowed at the dark." },
    ease = { "Still as a moonlit pool. Centuries of patience in one quiet breath." },
    downcast = { "Ears low, eyes distant, carrying a grief older than most kingdoms." },
  },
  Orc = {
    angry = { "Tusks bared, knuckles cracking. The bloodlust is close to the surface today." },
    merry = { "Roaring with laughter and pounding the table hard enough to spill the grog." },
    weary = { "Shoulders hunched like a wolf after a long hunt." },
    elated = { "Chest out, chin up. Lok'tar written in every step." },
  },
  Troll = {
    ease = { "Lounging loose-limbed, tusks catching the light, in no hurry at all, mon." },
    uneasy = { "Muttering to the loa under {their} breath and touching a charm at {their} neck." },
    merry = { "Grinning wide around the tusks and swaying to a rhythm only {they} can hear." },
    angry = { "Hunched low, tusks forward. The look of a Darkspear about to settle a score." },
  },
  Tauren = {
    weary = { "Great head bowed, hooves dragging. Even the Earth Mother's children need rest." },
    ease = { "Ears twitching lazily, breathing slow and deep like the plains at evening." },
    uneasy = { "Nostrils flared, ears pinned back. Doesn't like the smell of this place." },
    downcast = { "Massive shoulders slumped. Grief sits heavy on one so large." },
  },
  Scourge = {
    weary = { "Joints creaking louder than usual. Even the dead wear down." },
    merry = { "A rattling, jawbone laugh that makes the living flinch." },
    ease = { "Perfectly still, the way only the dead can be. No breath to steady." },
    downcast = { "Stares at nothing with empty eyes, remembering a life that was taken." },
    fed = { "Has eaten something, and nobody wants to ask what." },
  },
}

---------------------------------------------------------------------------
-- RACE AND CLASS
---------------------------------------------------------------------------

-- Rank ladders that differ by faction (shared bands as W.RANKS).
W.RANKS_FACTION = {
  Horde = {
    WARRIOR = { "Recruit", "Grunt", "Raider", "Sergeant", "Veteran", "Champion", "Warlord" },
    ROGUE = { "Cutthroat", "Footpad", "Thief", "Shadow", "Blade", "Nightblade", "Master Assassin" },
  },
  Alliance = {
    WARRIOR = { "Recruit", "Foot Soldier", "Soldier", "Sergeant", "Veteran", "Knight-Champion", "Warmaster" },
  },
}

-- Ladders specific to a race and class: these win over the class and faction ones.
W.RANKS_RACE = {
  Scourge = {
    ROGUE = { "Newly Risen", "Footpad", "Deathstalker Initiate", "Deathstalker", "Deathstalker Captain", "Dark Ranger's Blade", "Master Deathstalker" },
    PRIEST = { "Acolyte", "Initiate", "Dark Acolyte", "Dark Cleric", "Shadow Priest", "Deathspeaker", "High Deathspeaker" },
    MAGE = { "Apprentice", "Novice", "Adept", "Magus", "Dark Sorcerer", "Arcanist", "Master Arcanist" },
    WARLOCK = { "Initiate", "Occultist", "Summoner", "Necrolyte", "Diabolist", "Dreadcaller", "Master Diabolist" },
    WARRIOR = { "Risen", "Grunt", "Deathguard Recruit", "Deathguard", "Deathguard Sergeant", "Executor", "High Executor" },
  },
  Dwarf = {
    HUNTER = { "Novice", "Mountaineer", "Mountaineer Scout", "Sharpshooter", "Senior Mountaineer", "Mountain King's Hunter", "Master Mountaineer" },
    WARRIOR = { "Recruit", "Shieldbearer", "Guard", "Ironforge Sergeant", "Thane's Guard", "Champion of the Hold", "Mountain Thane" },
    PRIEST = { "Acolyte", "Initiate", "Cleric of the Light", "Priest", "Confessor", "High Cleric", "Elder of the Mystic Ward" },
    PALADIN = { "Initiate", "Squire", "Knight of Ironforge", "Templar", "Crusader", "Justicar", "Hammer of the Light" },
  },
  Gnome = {
    MAGE = { "Apprentice", "Tinker-Mage", "Adept", "Magus", "Arcanotech", "Arcanist", "Grand Arcanotech" },
    ROGUE = { "Pickpocket", "Saboteur", "Thief", "Shadow", "Infiltrator", "Nightblade", "Master Saboteur" },
    WARRIOR = { "Recruit", "Foot Soldier", "Gnomeregan Guard", "Sergeant", "Veteran", "Champion of Gnomeregan", "Warmaster" },
    WARLOCK = { "Initiate", "Occultist", "Summoner", "Shadowcaster", "Diabolist", "Dreadcaller", "Master Diabolist" },
  },
  NightElf = {
    HUNTER = { "Novice", "Tracker", "Ranger", "Pathfinder", "Moonstalker", "Huntmaster", "Master of the Wilds" },
    PRIEST = { "Novice of Elune", "Initiate of Elune", "Acolyte of Elune", "Priest of the Moon", "Moon Priest", "High Priest of the Moon", "Voice of Elune" },
    DRUID = { "Initiate", "Neophyte", "Grove Warden", "Wild Walker", "Shapeshifter", "Elder Druid", "Elder of the Cenarion Circle" },
    WARRIOR = { "Recruit", "Sentinel Recruit", "Sentinel", "Sentinel Sergeant", "Sentinel Captain", "Champion of the Kaldorei", "Warden" },
    ROGUE = { "Cutpurse", "Shadow-Walker", "Thief", "Shadow", "Blade", "Nightblade", "Master of Shadows" },
  },
  Human = {
    ROGUE = { "Cutpurse", "Footpad", "Thief", "Informant", "SI:7 Operative", "SI:7 Agent", "Master Assassin" },
    PALADIN = { "Initiate", "Squire", "Knight", "Knight of the Silver Hand", "Crusader", "Justicar", "Exemplar of the Silver Hand" },
    PRIEST = { "Acolyte", "Initiate", "Cleric of the Light", "Priest", "Confessor", "Bishop", "Archbishop's Chosen" },
    MAGE = { "Apprentice", "Novice", "Adept", "Magus", "Sorcerer", "Arcanist", "Magister" },
  },
  Orc = {
    SHAMAN = { "Initiate", "Seer", "Spirit-Speaker", "Stormcaller", "Farseer", "Elder Farseer", "Elder Shaman" },
    HUNTER = { "Novice", "Tracker", "Wolf Rider", "Pathfinder", "Beastmaster", "Huntmaster", "Master Hunter" },
    WARLOCK = { "Initiate", "Occultist", "Summoner", "Shadowcaster", "Diabolist", "Dreadcaller", "Master Diabolist" },
  },
  Troll = {
    HUNTER = { "Novice", "Tracker", "Headhunter", "Pathfinder", "Shadow Stalker", "Huntmaster", "Master Headhunter" },
    SHAMAN = { "Initiate", "Seer", "Loa-Speaker", "Witch Doctor", "Hexer", "Elder Witch Doctor", "Voice of the Loa" },
    PRIEST = { "Acolyte", "Initiate", "Loa-Speaker", "Priest", "Shadow Priest", "High Priest", "Voice of the Loa" },
    ROGUE = { "Cutthroat", "Footpad", "Thief", "Shadow", "Shadow Hunter's Blade", "Nightblade", "Master Assassin" },
    MAGE = { "Apprentice", "Novice", "Adept", "Magus", "Sorcerer", "Arcanist", "Master Arcanist" },
  },
  Tauren = {
    WARRIOR = { "Young Brave", "Brave", "Plainsrunner", "Warrior", "Veteran Brave", "Champion of the Tribes", "Chieftain's Guard" },
    HUNTER = { "Novice", "Brave", "Plainsrunner", "Pathfinder", "Wind Rider", "Huntmaster", "Hunter of the Earth Mother" },
    DRUID = { "Initiate", "Neophyte", "Grove Warden", "Wild Walker", "Shapeshifter", "Elder", "Archdruid's Chosen" },
    SHAMAN = { "Initiate", "Seer", "Spirit-Speaker", "Earthcaller", "Farseer", "Elder Seer", "Elder Shaman" },
  },
}

-- How each race looks to a stranger.
W.RACE_LOOK = {
  Human = { "Broad, open features weathered by wind and road.", "An ordinary human face that's seen more than its share of trouble." },
  Dwarf = { "A thick braided beard, broad shoulders and forearms like anvils.", "Stocky and solid as the mountain, beard braided with bands of metal." },
  Gnome = { "Small, bright-eyed and constantly fidgeting, hair sticking out at odd angles.", "Tiny, quick and covered in soot smudges and little burns." },
  NightElf = { "Tall and graceful, with long ears and eyes that glow faintly silver.", "Violet skin, sweeping ears and the stillness of someone who has lived a very long time." },
  Orc = { "Green-skinned and heavy-jawed, tusks jutting from a scarred face.", "Massive shoulders, a heavy brow and the bearing of a born warrior." },
  Troll = { "Tall and lanky, blue-skinned, with long tusks and a wild crest of hair.", "Loose-limbed and hunched, tusks curving up past a wide grin." },
  Tauren = { "Enormous and calm, horned and hoofed, with braided mane and gentle eyes.", "A towering bulk of fur and muscle, horns hung with beads and feathers." },
  Scourge = { "Grey, rotting flesh stretched over bone, with a jaw that doesn't quite close.", "Gaunt and stitched-together, eyes burning a cold yellow in a ruined face." },
}

-- What a class carries that marks it out.
W.CLASS_LOOK = {
  WARRIOR = { "Moves with the heavy confidence of someone used to taking hits.", "Knuckles scarred, shoulders squared; built for the front line." },
  PALADIN = { "A holy symbol hangs at {their} breast, polished bright.", "Carries {themselves} like a sworn knight, with a prayer book on the belt." },
  HUNTER = { "Quiver at the hip, tracks and fur stuck to {their} boots.", "A hunter's patience in the eyes; never far from {their} beast." },
  ROGUE = { "Soft boots, dark clothes, and more blades than are visible.", "Hands never still, always resting near a hidden knife." },
  PRIEST = { "A worn prayer book and a quiet, attentive manner.", "Smells faintly of incense and clean linen." },
  SHAMAN = { "Totems hang from {their} belt, carved and painted.", "Bones and feathers knotted into hair and harness; the spirits' mark." },
  MAGE = { "Ink-stained fingers, a pouch of reagents, the faint smell of ozone.", "A spellbook chained to the belt and frost on the cuffs." },
  WARLOCK = { "A faint whiff of brimstone; shadows lean a little closer.", "Eyes a shade too knowing; a soul-shard pouch at the hip." },
  DRUID = { "Leaves tangled in {their} hair and earth under the nails.", "Feathers and antler charms; smells of moss and rain." },
}

-- Where they come from, when RPG Dialogue has no origin chosen. {name} is filled in.
W.RACE_BACKGROUND = {
  Human = { "{name} grew up in the shadow of Stormwind's walls, in a kingdom still rebuilding from war.", "{name} comes from farming stock in Elwynn, raised on stories of the Second War." },
  Dwarf = { "{name} hails from the halls of Ironforge, where the forges never go cold.", "{name} was raised among the snows of Dun Morogh, in a clan that never forgets a grudge or a debt." },
  Gnome = { "{name} fled Gnomeregan when the troggs came and the city was flooded with poison, and has been rebuilding ever since.", "{name} is a child of Gnomeregan, living as an exile in Ironforge's Tinker Town." },
  NightElf = { "{name} was born beneath the boughs of Teldrassil, in a people only lately woken from long isolation.", "{name} is kaldorei, of a people who have watched the forests of Kalimdor for ten thousand years." },
  Orc = { "{name} was born in an internment camp after the Second War and freed by the Warchief.", "{name} grew up in the new Durotar, raised on stories of Draenor and the long road to freedom." },
  Troll = { "{name} is Darkspear, of the tribe that followed Thrall to Durotar after the sea witch drove them from the Echo Isles.", "{name} grew up on the Echo Isles, until Zalazane's madness drove the Darkspear to Sen'jin." },
  Tauren = { "{name} grew up on the grasslands of Mulgore, under Cairne Bloodhoof's wise rule.", "{name} is tauren of Mulgore, raised to honour the Earth Mother and walk the plains." },
  Scourge = { "{name} woke in a crypt in Tirisfal, free of the Lich King's grip, with only fragments of a former life.", "{name} died in the plague and rose again; the Dark Lady gave {them} a will of {their} own." },
}

W.CLASS_BACKGROUND = {
  WARRIOR = { "Took up the sword because someone had to stand in front.", "Learned to fight before learning much else." },
  PALADIN = { "Swore the oaths of the Light and has tried to live up to them since.", "Was raised to the Light and taught to carry a hammer for it." },
  HUNTER = { "Learned to track and shoot as a child, and has never been comfortable indoors.", "Bonded with a beast early and has rarely travelled alone since." },
  ROGUE = { "Learned early that quick hands and a quiet step solve most problems.", "Took to the shadows when honest work didn't pay." },
  PRIEST = { "Answered a calling to tend the hurt and the dying.", "Studied the faith and found it asks more than it gives, most days." },
  SHAMAN = { "Heard the elements speak young, and learned to answer.", "Was taught by an elder shaman to listen to earth, fire, water and air." },
  MAGE = { "Showed a spark of the arcane young, and has been chasing it ever since.", "Spent years with books and candles before ever casting in anger." },
  WARLOCK = { "Went looking for power the respectable schools wouldn't teach.", "Learned the darker arts, and keeps the reasons private." },
  DRUID = { "Was drawn to the Cenarion Circle and the old ways of the wild.", "Learned to walk in other shapes and listen to the land." },
}

-- What they do when out and about, by class (a choice alongside the zone's own).
W.CLASS_ACTIVITY = {
  WARRIOR = { "patrolling around {place}", "looking for a fight around {place}" },
  PALADIN = { "keeping watch over {place}", "seeing to the faithful around {place}" },
  HUNTER = { "tracking something through {place}", "out hunting around {place}" },
  ROGUE = { "keeping a low profile around {place}", "watching the comings and goings around {place}" },
  PRIEST = { "tending to travellers around {place}", "seeing to the sick around {place}" },
  SHAMAN = { "listening to the spirits of {place}", "reading the winds around {place}" },
  MAGE = { "studying the ley lines around {place}", "taking arcane readings around {place}" },
  WARLOCK = { "gathering reagents best not named around {place}", "about some private business around {place}" },
  DRUID = { "walking the wilds around {place}", "tending the land around {place}" },
}

-- Class tells for moods (used about a third of the time, when one fits).
W.CLASS_TELLS = {
  WARRIOR = { angry = { "Jaw clenched, hand on the hilt, looking for an excuse." }, weary = { "Armour straps loosened; even the strongest arms tire." }, fierce = { "Rolling {their} shoulders and grinning at the next fight." } },
  PALADIN = { downcast = { "Hand on {their} holy symbol, praying for strength." }, righteous = { "A faint golden warmth seems to follow {them} today." }, conflicted = { "Turning a prayer bead over and over, troubled in conscience." } },
  HUNTER = { ease = { "Brushing out {their} companion's coat, perfectly content." }, uneasy = { "Reading the ground for tracks, bow half-drawn." }, wonder = { "Studying the local beasts with keen interest." } },
  ROGUE = { uneasy = { "Eyes on every exit, fingers near a hidden blade." }, flush = { "Suspiciously well off. Nobody's asking where it came from." }, tense = { "Moving silently, never quite in the light." } },
  PRIEST = { shaken = { "Murmuring a prayer, over and over, until the hands stop shaking." }, devout = { "Kneeling in quiet devotion, lips moving." }, sorrowful = { "Has said the rites over someone recently. It shows." } },
  SHAMAN = { uneasy = { "The spirits are restless here, and it shows in {their} face." }, ease = { "Humming with the earth, perfectly at home." }, angry = { "The air crackles a little around {them}. Best not to provoke the storm." } },
  MAGE = { weary = { "Rubbing {their} temples; too many hours over spellbooks." }, intrigued = { "Muttering formulae and scribbling notes in the margins." }, angry = { "Small sparks dance at {their} fingertips." } },
  WARLOCK = { ease = { "A faint smell of brimstone; the demon at {their} side is, for once, quiet." }, haunted = { "Whispers that aren't {their} own seem to cling to {them}." }, angry = { "The shadows around {them} have grown noticeably darker." } },
  DRUID = { uneasy = { "Leaves in {their} hair rustle though there's no wind." }, ease = { "Barefoot on the grass, at one with the place." }, angry = { "A low growl in the throat that sounds more bear than person." } },
}

-- Ambitions by race (mixed with the class ones).
W.RACE_AMBITIONS = {
  Human = { "To see Stormwind made whole again.", "To earn a place in the histories of the kingdom." },
  Dwarf = { "To uncover the secrets of the Titans buried in the deep places.", "To bring honour to {their} clan and a good story home to Ironforge." },
  Gnome = { "To see Gnomeregan taken back from the troggs.", "To build something no one has ever built before." },
  NightElf = { "To keep the forests of Kalimdor safe from axe and fel.", "To prove the kaldorei were right to wake and walk the world again." },
  Orc = { "To prove the orcs are more than the monsters humans remember.", "To earn a place in the Warchief's sagas." },
  Troll = { "To see the Echo Isles free of Zalazane's hexes.", "To make the loa proud, mon." },
  Tauren = { "To walk every plain the Earth Mother made.", "To bring honour to {their} tribe and the memory of {their} ancestors." },
  Scourge = { "To find out who {they} were before the plague.", "To make the Lich King pay for what was taken." },
}

-- Mottos by race (mixed with the temperament ones).
W.RACE_MOTTOS = {
  Human = { "For the Alliance, and for home.", "Stand fast." },
  Dwarf = { "Stone and steel and stubbornness.", "Never trust a beardless wizard." },
  Gnome = { "If it's not broken, improve it.", "Gnomeregan forever!" },
  NightElf = { "Elune guides my path.", "The forest remembers." },
  Orc = { "Lok'tar ogar!", "Strength and honour." },
  Troll = { "Stay away from da voodoo.", "Da loa are watchin'." },
  Tauren = { "Walk with the Earth Mother.", "The winds guide us." },
  Scourge = { "Victory for the Forsaken.", "What joy is there in this curse?" },
}

---------------------------------------------------------------------------
-- Places that mean something to a race or class. Keyed by zone or subzone:
-- { mood, strength, why }. Checked while you're there.
---------------------------------------------------------------------------
W.CAPITALS = {
  Human = "Stormwind City", Dwarf = "Ironforge", Gnome = "Ironforge", NightElf = "Darnassus",
  Orc = "Orgrimmar", Troll = "Orgrimmar", Tauren = "Thunder Bluff", Scourge = "Undercity",
}
W.ENEMY_CAPITALS = {
  Alliance = { ["Orgrimmar"] = true, ["Thunder Bluff"] = true, ["Undercity"] = true },
  Horde = { ["Stormwind City"] = true, ["Ironforge"] = true, ["Darnassus"] = true },
}

W.RACE_PLACES = {
  Human = {
    ["Westfall"] = { "sorrowful", 14, "Westfall's empty farms" },
    ["Alterac Mountains"] = { "angry", 12, "Alterac's treachery" },
    ["Elwynn Forest"] = { "ease", 12, "home soil" },
    ["Northshire Abbey"] = { "devout", 15, "the abbey where it began" },
  },
  Dwarf = {
    ["Searing Gorge"] = { "angry", 18, "Dark Iron land" },
    ["Burning Steppes"] = { "angry", 15, "Dark Iron land" },
    ["Badlands"] = { "intrigued", 15, "old Titan ruins" },
    ["Uldaman"] = { "intrigued", 25, "the Titans' secrets" },
    ["Dun Morogh"] = { "ease", 14, "home snows" },
    ["Loch Modan"] = { "ease", 10, "dwarven hills" },
  },
  Gnome = {
    ["Gnomeregan"] = { "sorrowful", 30, "lost Gnomeregan" },
    ["Dun Morogh"] = { "sorrowful", 8, "near lost Gnomeregan" },
    ["Tinker Town"] = { "ease", 18, "among fellow tinkers" },
  },
  NightElf = {
    ["Felwood"] = { "sorrowful", 22, "a corrupted forest" },
    ["Ashenvale"] = { "angry", 12, "orc axes in the ancient woods" },
    ["Teldrassil"] = { "ease", 14, "beneath the world tree" },
    ["Moonglade"] = { "ease", 22, "sacred Moonglade" },
    ["Azshara"] = { "uneasy", 15, "the Highborne ruins" },
  },
  Orc = {
    ["Durnholde Keep"] = { "angry", 25, "the old internment camps" },
    ["Hillsbrad Foothills"] = { "angry", 8, "the camps' country" },
    ["Blasted Lands"] = { "conflicted", 18, "the Dark Portal" },
    ["Ashenvale"] = { "fierce", 12, "the war for timber" },
    ["Durotar"] = { "ease", 12, "the Horde's new home" },
  },
  Troll = {
    ["Stranglethorn Vale"] = { "ease", 14, "the ancestral jungle" },
    ["Echo Isles"] = { "angry", 20, "Zalazane's hold on the Echo Isles" },
    ["Zul'Gurub"] = { "uneasy", 25, "Hakkar's temple" },
    ["Sen'jin Village"] = { "ease", 20, "among the Darkspear" },
  },
  Tauren = {
    ["Mulgore"] = { "ease", 16, "the Earth Mother's plains" },
    ["The Barrens"] = { "ease", 6, "open grassland" },
    ["Thousand Needles"] = { "intrigued", 10, "the old tauren lands" },
    ["Stonetalon Mountains"] = { "angry", 14, "the logged-out slopes" },
  },
  Scourge = {
    ["Western Plaguelands"] = { "downcast", 16, "memories of Lordaeron" },
    ["Eastern Plaguelands"] = { "angry", 18, "the Scourge's land" },
    ["Ruins of Lordaeron"] = { "downcast", 22, "the kingdom that was" },
    ["Tirisfal Glades"] = { "ease", 12, "home, such as it is" },
    ["Silverpine Forest"] = { "uneasy", 8, "worgen country" },
  },
}

W.CLASS_PLACES = {
  PALADIN = { ["Light's Hope Chapel"] = { "devout", 28, "holy ground" }, ["Cathedral Square"] = { "devout", 18, "the cathedral" },
    ["Stratholme"] = { "angry", 20, "the culling's city" } },
  PRIEST = { ["Cathedral Square"] = { "devout", 20, "the cathedral" }, ["Temple of the Moon"] = { "devout", 22, "Elune's temple" },
    ["Light's Hope Chapel"] = { "devout", 20, "holy ground" } },
  DRUID = { ["Moonglade"] = { "ease", 25, "the druids' sanctuary" }, ["Felwood"] = { "angry", 15, "a poisoned forest" },
    ["Cenarion Enclave"] = { "ease", 15, "the Cenarion Enclave" } },
  SHAMAN = { ["Elder Rise"] = { "ease", 20, "the elders' rise" }, ["Valley of Wisdom"] = { "ease", 18, "the Valley of Wisdom" },
    ["Silithus"] = { "uneasy", 14, "the elements in turmoil" } },
  WARLOCK = { ["Felwood"] = { "intrigued", 15, "fel-touched land" }, ["Blasted Lands"] = { "intrigued", 15, "the Dark Portal" },
    ["Cleft of Shadow"] = { "ease", 18, "among your own kind" } },
  MAGE = { ["Alterac Mountains"] = { "intrigued", 12, "Dalaran's shield" }, ["Azshara"] = { "intrigued", 18, "Highborne ruins" },
    ["Wizard's Sanctum"] = { "ease", 15, "the Wizard's Sanctum" } },
  HUNTER = { ["Feralas"] = { "wonder", 12, "wild hunting grounds" }, ["Un'Goro Crater"] = { "wonder", 18, "the beasts of Un'Goro" } },
  ROGUE = { ["Booty Bay"] = { "ease", 15, "a port with no questions" }, ["Ravenholdt Manor"] = { "ease", 22, "Ravenholdt" } },
  WARRIOR = { ["Gurubashi Arena"] = { "fierce", 25, "the arena" }, ["Hall of Champions"] = { "proud", 18, "the Hall of Champions" } },
}

---------------------------------------------------------------------------
-- Spells and racial abilities you cast: { mood, strength, why } and/or a context.
---------------------------------------------------------------------------
W.SPELLS = {
  ["Resurrection"] = { mood = { "righteous", 30, "brought someone back from death" } },
  ["Redemption"] = { mood = { "righteous", 30, "brought someone back from death" } },
  ["Ancestral Spirit"] = { mood = { "righteous", 30, "called a spirit back" } },
  ["Rebirth"] = { mood = { "righteous", 30, "brought someone back from death" } },
  ["Ritual of Summoning"] = { context = "summoning" },
  ["Shadowmeld"] = { context = "shadowmeld" },
  ["Cannibalize"] = { context = "cannibalize", mood = { "fed", 25, "fed on the fallen" } },
  ["Will of the Forsaken"] = { mood = { "fierce", 15, "shrugged off fear" } },
  ["Berserking"] = { mood = { "fierce", 20, "berserking" } },
  ["Blood Fury"] = { mood = { "fierce", 22, "the blood fury" } },
  ["War Stomp"] = { mood = { "fierce", 15, "a war stomp" } },
  ["Stoneform"] = { mood = { "rattled", 10, "had to turn to stone" } },
  ["Escape Artist"] = { mood = { "rattled", 10, "a narrow escape" } },
  ["Feed Pet"] = { mood = { "ease", 12, "fed {their} companion" } },
}
-- Mage portals: "Portal: Stormwind" -> "opening a portal to Stormwind".
W.ACTIVITY.portal = { "opening a portal to {dest} in {place}" }
W.ACTIVITY.summoning = { "performing a summoning ritual in {place}" }
W.ACTIVITY.shadowmeld = { "melted into the shadows in {place}" }
W.ACTIVITY.cannibalize = { "crouched over a corpse in {place}, best not to look" }

-- Hunter pet happiness (GetPetHappiness: 1 unhappy, 2 content, 3 happy).
W.PET_HAPPY = { [1] = "who looks hungry and sullen", [2] = "who seems content", [3] = "who is plainly devoted" }

---------------------------------------------------------------------------
-- Temperament by race and class: how hard each feeling lands (multiplies).
---------------------------------------------------------------------------
W.RACE_BIAS = {
  Human = { company = 1.2, sociable = 1.2, homecoming = 1.2 },
  Dwarf = { merry = 1.4, angry = 1.15, intrigued = 1.2, uneasy = 0.8 },
  Gnome = { wonder = 1.3, intrigued = 1.3, elated = 1.2, worried = 1.1 },
  NightElf = { sorrowful = 1.2, downcast = 1.15, ease = 1.1, uneasy = 0.9 },
  Orc = { fierce = 1.3, angry = 1.25, proud = 1.2, shaken = 0.8 },
  Troll = { ease = 1.2, merry = 1.2, fierce = 1.15, worried = 0.8 },
  Tauren = { ease = 1.2, angry = 0.8, devout = 1.2, frustrated = 0.8 },
  Scourge = { downcast = 1.2, haunted = 0.7, shaken = 0.7, uneasy = 0.6, fed = 0.5, smitten = 0.7 },
}
W.CLASS_BIAS = {
  WARRIOR = { fierce = 1.3, triumphant = 1.2, rattled = 0.8 },
  PALADIN = { devout = 1.3, righteous = 1.3, conflicted = 1.2 },
  HUNTER = { wonder = 1.2, ease = 1.1, lonely = 0.7 },
  ROGUE = { tense = 0.8, flush = 1.3, thrilled = 1.2 },
  PRIEST = { devout = 1.3, sorrowful = 1.2, righteous = 1.2 },
  SHAMAN = { uneasy = 1.2, devout = 1.1, ease = 1.1 },
  MAGE = { intrigued = 1.3, wonder = 1.2, weary = 1.1 },
  WARLOCK = { haunted = 0.6, conflicted = 0.7, uneasy = 0.8 },
  DRUID = { ease = 1.2, wonder = 1.1, angry = 0.9 },
}

-- The hour, by race: { mood, strength, why } at night / dawn / dusk.
W.RACE_TIME = {
  NightElf = { night = { "ease", 10, "the night suits {them}" } },
  Tauren = { dawn = { "devout", 10, "the sun rising over the Earth Mother" } },
  Scourge = { night = { "ease", 6, "the dark is kinder" } },
  Troll = { dusk = { "ease", 6, "the jungle hour" } },
}

-- More ways a mood shows on each body.
local function more(race, t) for k, v in pairs(t) do W.RACE_TELLS[race][k] = v end end
more("Human", {
  shaken = { "Hands shaking; mutters a prayer to the Light under {their} breath." },
  elated = { "Grinning like a farmhand at harvest festival." },
  downcast = { "Shoulders slumped, staring at nothing, like a soldier after a lost battle." },
  fierce = { "Sword arm loose, eyes hard. A veteran's calm before the charge." },
})
more("Dwarf", {
  shaken = { "Beard trembling, and for once short of words." },
  downcast = { "Staring into an empty tankard, beard drooping." },
  elated = { "Slapping backs and bellowing for another round." },
  wonder = { "Peering at the stonework, muttering about Titan craft." },
  fierce = { "Beard bristling and axe in hand, ready to give a grudge its due." },
})
more("Gnome", {
  shaken = { "Ears flat, hair singed, voice an octave higher than usual." },
  downcast = { "Uncharacteristically quiet, fiddling with a broken cog." },
  angry = { "Red to the tips of {their} ears, waving a wrench." },
  ease = { "Tinkering contentedly with something small and clicking." },
})
more("NightElf", {
  shaken = { "Ears pinned back, eyes glowing a little too bright." },
  elated = { "Moves with a dancer's lightness, silver eyes shining." },
  angry = { "Eyes narrowed to burning slits; ten thousand years of patience wearing thin." },
  wonder = { "Studying the place as if comparing it to a memory centuries old." },
})
more("Orc", {
  shaken = { "Breathing hard through the tusks, refusing to look rattled." },
  downcast = { "Hunched and silent, the way an orc grieves: alone." },
  ease = { "Sitting by the fire, sharpening an axe with long, easy strokes." },
  uneasy = { "Sniffing the air, hand on the haft, hackles up." },
})
more("Troll", {
  shaken = { "Muttering a charm to the loa, tusks clacking." },
  downcast = { "Long ears drooping, tusks down, quiet as the swamp." },
  elated = { "Cackling and doing a little dance, mon." },
  wonder = { "Head tilted, taking it all in with a wide, tusky grin." },
})
more("Tauren", {
  shaken = { "Massive hands trembling; murmurs to the Earth Mother for calm." },
  elated = { "A deep, rumbling laugh that shakes the ground a little." },
  angry = { "Snorting, head lowered, horns forward. Slow to anger, but there now." },
  wonder = { "Taking slow, careful steps, as if listening to the land itself." },
})
more("Scourge", {
  shaken = { "A dead thing shouldn't tremble, but this one does." },
  elated = { "Jaw hanging in what might be a grin." },
  angry = { "Eyes blazing a cold yellow; the Dark Lady's fury in miniature." },
  wonder = { "Peering about with empty eyes, as if trying to remember being alive." },
})

---------------------------------------------------------------------------
-- Dungeons and raids: what it's like inside (Currently).
---------------------------------------------------------------------------
W.INSTANCE_FLAVOR = {
  ["The Deadmines"] = "in the dripping tunnels of the Deadmines",
  ["Wailing Caverns"] = "deep in the twisting Wailing Caverns",
  ["Shadowfang Keep"] = "among the cursed halls of Shadowfang Keep",
  ["Ragefire Chasm"] = "in the smoky depths of Ragefire Chasm",
  ["Blackfathom Deeps"] = "wading through the drowned temple of Blackfathom Deeps",
  ["The Stockade"] = "in the cells of the Stormwind Stockade",
  ["Gnomeregan"] = "in the poisoned halls of Gnomeregan",
  ["Razorfen Kraul"] = "among the thorny warrens of Razorfen Kraul",
  ["Scarlet Monastery"] = "behind the zealots' walls of the Scarlet Monastery",
  ["Razorfen Downs"] = "in the bone-strewn barrows of Razorfen Downs",
  ["Uldaman"] = "in the ancient Titan vaults of Uldaman",
  ["Zul'Farrak"] = "in the sun-baked troll city of Zul'Farrak",
  ["Maraudon"] = "in the crystal caverns of Maraudon",
  ["The Temple of Atal'Hakkar"] = "in the sunken temple of Atal'Hakkar",
  ["Blackrock Depths"] = "deep in the Dark Iron city of Blackrock Depths",
  ["Blackrock Spire"] = "climbing the orc-held heights of Blackrock Spire",
  ["Dire Maul"] = "among the ruined Highborne halls of Dire Maul",
  ["Stratholme"] = "in the burning, plague-ridden streets of Stratholme",
  ["Scholomance"] = "in the necromancers' halls of Scholomance",
  ["Molten Core"] = "in the fire and magma of the Molten Core",
  ["Onyxia's Lair"] = "in the brood mother's lair",
  ["Blackwing Lair"] = "in Nefarian's lair atop Blackrock",
  ["Zul'Gurub"] = "in the blood-soaked jungle temple of Zul'Gurub",
  ["Ruins of Ahn'Qiraj"] = "among the ruins of Ahn'Qiraj",
  ["Temple of Ahn'Qiraj"] = "deep in the hive-temple of Ahn'Qiraj",
  ["Naxxramas"] = "in the floating necropolis of Naxxramas",
}

-- More ways each class shows a mood.
local function moreClass(class, t) for k, v in pairs(t) do W.CLASS_TELLS[class][k] = v end end
moreClass("WARRIOR", {
  shaken = { "Leaning on {their} weapon a little more than usual." },
  elated = { "Banging a fist on {their} shield and laughing." },
  downcast = { "Polishing a dented helm in silence." },
  ease = { "Armour off for once, stretching out sore shoulders." },
})
moreClass("PALADIN", {
  shaken = { "Clutching {their} holy symbol a little too tightly." },
  elated = { "Practically glowing, and not only with the Light." },
  angry = { "A righteous fury in {their} eyes; someone has offended the Light." },
  ease = { "Kneeling in quiet prayer, perfectly calm." },
})
moreClass("HUNTER", {
  shaken = { "Kneeling by {their} companion, checking it over for wounds." },
  elated = { "Ruffling {their} companion's fur and grinning." },
  downcast = { "Sitting close to {their} companion, saying nothing." },
  fierce = { "Bowstring humming, eyes on the next quarry." },
})
moreClass("ROGUE", {
  shaken = { "Fingers drumming on a dagger hilt, eyes darting." },
  elated = { "A crooked grin and a new spring in {their} step. Something went very right." },
  ease = { "Leaning in a doorway, idly flipping a coin." },
  angry = { "Very still and very quiet. That's usually worse." },
})
moreClass("PRIEST", {
  elated = { "Humming a hymn, radiant." },
  angry = { "Lips pressed thin; even saints have limits." },
  ease = { "Reading scripture with a contented sigh." },
  uneasy = { "Holding a candle a little higher, praying the dark stays back." },
})
moreClass("SHAMAN", {
  shaken = { "Touching the earth with one hand to steady {themselves}." },
  elated = { "Thunder seems to rumble somewhere happily overhead." },
  downcast = { "Sitting cross-legged, asking the spirits for answers they won't give." },
  wonder = { "Head tilted, listening to what the land here has to say." },
})
moreClass("MAGE", {
  shaken = { "Muttering a counterspell under {their} breath out of habit." },
  elated = { "Fingertips glittering with stray sparks of excitement." },
  ease = { "Conjured tea in hand, reading by an arcane light." },
  wonder = { "Scribbling observations about the local ley lines." },
})
moreClass("WARLOCK", {
  shaken = { "The shadows around {them} flicker nervously." },
  elated = { "A thin, satisfied smile, as if a bargain paid off." },
  downcast = { "Staring into a soul shard, lost in thought." },
  fierce = { "Fel fire dances at {their} fingertips, eager." },
})
moreClass("DRUID", {
  shaken = { "Breathing slowly, steadying {themselves} the way a cornered animal does." },
  elated = { "Flowers seem to perk up as {they} pass." },
  downcast = { "Sitting beneath a tree, one hand on the bark." },
  wonder = { "Kneeling to examine every unfamiliar plant." },
})

---------------------------------------------------------------------------
-- City districts (Currently, while in a capital).
---------------------------------------------------------------------------
W.CITY_FLAVOR = {
  ["Trade District"] = "haggling in the bustle of Stormwind's Trade District",
  ["Cathedral Square"] = "beneath the spires of Cathedral Square",
  ["Old Town"] = "in the rougher streets of Stormwind's Old Town",
  ["Dwarven District"] = "amid the forge-smoke of Stormwind's Dwarven District",
  ["Mage Quarter"] = "among the violet towers of the Mage Quarter",
  ["Stormwind Harbor"] = "by the gulls and rigging of Stormwind Harbor",
  ["The Commons"] = "in the echoing Commons of Ironforge",
  ["The Great Forge"] = "in the heat and clangour of the Great Forge",
  ["Tinker Town"] = "in the whirring chaos of Tinker Town",
  ["The Military Ward"] = "in Ironforge's Military Ward",
  ["The Mystic Ward"] = "in the quiet Mystic Ward of Ironforge",
  ["Hall of Explorers"] = "among the relics in the Hall of Explorers",
  ["Craftsmen's Terrace"] = "on the moonlit Craftsmen's Terrace",
  ["Temple of the Moon"] = "in the silver hush of the Temple of the Moon",
  ["Tradesmen's Terrace"] = "on Darnassus' Tradesmen's Terrace",
  ["Warrior's Terrace"] = "on the Warrior's Terrace of Darnassus",
  ["Cenarion Enclave"] = "among the druids of the Cenarion Enclave",
  ["Valley of Strength"] = "in the dusty Valley of Strength",
  ["The Drag"] = "shouldering through the crowds of the Drag",
  ["Valley of Honor"] = "among the warriors of the Valley of Honor",
  ["Valley of Wisdom"] = "in Orgrimmar's Valley of Wisdom",
  ["Valley of Spirits"] = "among the trolls of the Valley of Spirits",
  ["Cleft of Shadow"] = "in the dim, smoky Cleft of Shadow",
  ["Elder Rise"] = "up on Elder Rise, near the Elders",
  ["Spirit Rise"] = "on the quiet heights of Spirit Rise",
  ["Hunter Rise"] = "on Hunter Rise among the braves",
  ["Lower Rise"] = "on Thunder Bluff's Lower Rise",
  ["The Trade Quarter"] = "in the green-lit Trade Quarter of the Undercity",
  ["The Apothecarium"] = "among the bubbling vats of the Apothecarium",
  ["The Magic Quarter"] = "in the Undercity's Magic Quarter",
  ["The War Quarter"] = "in the Undercity's War Quarter",
  ["The Rogues' Quarter"] = "in the shadowed Rogues' Quarter",
}

-- Good or bad, for the badge's border colour (anything not listed is neutral).
W.VALENCE = {
  elated = 1, triumphant = 1, satisfied = 1, ease = 1, merry = 1, wonder = 1, homecoming = 1, sociable = 1,
  company = 1, bolstered = 1, glorious = 1, fed = 1, festive = 1, flush = 1, thrilled = 1, righteous = 1,
  proud = 1, eager = 1, accomplished = 1, smitten = 1, devout = 1,
  shaken = -1, rattled = -1, weary = -1, haunted = -1, tense = -1, uneasy = -1, lonely = -1, sorrowful = -1,
  angry = -1, downcast = -1, frustrated = -1, ailing = -1, drained = -1, wounded = -1, worried = -1,
  conflicted = -1, ashamed = -1, burdened = -1,
}

-- Class names for a party ("a priest, a mage and two warriors").
W.CLASS_PLURAL = {
  WARRIOR = { "warrior", "warriors" }, PALADIN = { "paladin", "paladins" }, HUNTER = { "hunter", "hunters" },
  ROGUE = { "rogue", "rogues" }, PRIEST = { "priest", "priests" }, SHAMAN = { "shaman", "shamans" },
  MAGE = { "mage", "mages" }, WARLOCK = { "warlock", "warlocks" }, DRUID = { "druid", "druids" },
}
