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
  { "Devout", "Skeptical", "pious", "skeptical", "Spell_Holy_PrayerOfHealing", "INV_Misc_QuestionMark" },
  { "Charming", "Reserved", "charming", "reserved", "INV_ValentinesCard02", "INV_Misc_Book_08" },
  { "Witty", "Stern", "witty", "stern", "INV_Misc_Toy_07", "Ability_Warrior_CommandingShout" },
}

-- Alignment axes: positive is the left word.
W.AXIS_BARS = {
  { axis = "light", left = "Light", right = "Shadow", li = "Spell_Holy_HolyBolt", ri = "Spell_Shadow_ShadowBolt" },
  { axis = "order", left = "Lawful", right = "Free-Spirited", li = "INV_Misc_Book_11", ri = "Spell_Nature_Cyclone" },
  { axis = "honor", left = "Honest", right = "Silver-Tongued", li = "Spell_Holy_SealOfWisdom", ri = "INV_Misc_Mask_01" },
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
