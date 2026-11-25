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
      "Breathing hard, eyes still checking the treeline.",
      "Patched up in a hurry, and still hurting.",
    },
  },
  elated = {
    title = "In High Spirits", icon = "Spell_Holy_SurgeOfLight",
    adj = { "In high spirits", "Flushed with success", "Grinning to {themselves}" },
    tells = {
      "Walks taller today. Something long worked for has come good.",
      "Keeps smiling at nothing in particular.",
    },
  },
  triumphant = {
    title = "Triumphant", icon = "INV_BannerPVP_02",
    adj = { "Fresh from a hard-won victory", "Triumphant" },
    tells = {
      "Has the swagger of someone who just won a hard fight.",
      "Battle-stained but upright. Whatever it was, it's dead now.",
    },
  },
  satisfied = {
    title = "Satisfied", icon = "INV_Misc_Note_01",
    adj = { "Quietly satisfied", "Content with a day's work" },
    tells = {
      "Has the easy shoulders of someone who kept {their} word today.",
      "{their} {pouch} is heavier than it was this morning.",
    },
  },
  weary = {
    title = "Road-Weary", icon = "Spell_Nature_Sleep",
    adj = { "Bone-tired", "Road-weary", "Worn thin" },
    tells = {
      "Moves slowly, like someone who has been on the road too long.",
      "Dark circles under the eyes. Could sleep standing up.",
      "Road-weary, moving like every mile is still in {their} legs.",
    },
  },
  ease = {
    title = "At Ease", icon = "INV_Drink_04",
    adj = { "At ease", "Warm and unhurried", "Rested" },
    tells = {
      "Shoulders down. Nothing is chasing {them} today.",
      "Rested, and in no hurry.",
    },
  },
  merry = {
    title = "Merry", icon = "INV_Drink_05",
    adj = { "Merry", "Several cups in", "Cheerfully unsteady" },
    tells = {
      "Smells of ale and laughs too loudly.",
      "Swaying slightly, and very fond of everyone right now.",
    },
  },
  haunted = {
    title = "Haunted", icon = "Spell_Shadow_Possession",
    adj = { "Haunted", "Not entirely present", "Muttering under {their} breath" },
    tells = {
      "Glances at empty corners as if someone just spoke there.",
      "Starts at shadows, and doesn't say why.",
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
      "Keeps {their} {mainhand} close and listens before every corner.",
      "Moves like someone who expects the floor to give way.",
    },
  },
  uneasy = {
    title = "Uneasy", icon = "Spell_Shadow_Twilight",
    adj = { "Uneasy", "Jumpy", "Keeping to the light" },
    tells = {
      "Keeps {their} back to a wall.",
      "Doesn't like this place, and doesn't pretend to.",
    },
  },
  sociable = {
    title = "Talkative", icon = "INV_Letter_15",
    adj = { "Talkative", "Full of news", "In a sociable mood" },
    tells = {
      "Has been talking to a lot of people lately, and is in the mood for more.",
      "Quick to strike up a conversation today.",
    },
  },
  intrigued = {
    title = "Intrigued", icon = "INV_Misc_Book_06",
    adj = { "Turning something over", "Intrigued", "Preoccupied" },
    tells = {
      "Frowning over some news {they} can't let go of.",
      "Lost in thought, piecing something together.",
    },
  },
  determined = {
    title = "Determined", icon = "Ability_Warrior_BattleShout",
    adj = { "Determined", "Set on a purpose" },
    tells = {
      "Has the look of someone with somewhere to be.",
    },
  },
  company = {
    title = "In Good Company", icon = "Spell_Holy_PrayerOfSpirit",
    adj = { "In good company", "Among friends" },
    tells = {
      "Glad of the company.",
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
      "Jaw set, knuckles white. People give {them} room.",
      "Something has {their} blood up, and it isn't cooling.",
    },
  },
  smitten = {
    title = "Smitten", icon = "INV_ValentinesCandy",
    adj = { "Smitten", "Distracted by someone", "Humming to {themselves}" },
    tells = {
      "Keeps smiling at nothing.",
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
    tells = { "Has the contented air of someone who just ate well." },
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
      "Muttering curses at no one in particular.",
      "Has fallen more than once today and is taking it personally.",
    },
  },
  bolstered = {
    title = "In Fine Fettle", icon = "Spell_Holy_WordFortitude",
    adj = { "In fine fettle", "Brimming with vigour", "Feeling unstoppable" },
    tells = {
      "Fairly crackling with borrowed blessings. Stands like nothing could knock {them} down.",
      "Wrapped in wards and blessings that glow at the edges.",
    },
  },
  glorious = {
    title = "Glorious", icon = "INV_Misc_Head_Dragon_01",
    adj = { "Riding high on a city's cheer", "Glorious", "Blazing with borrowed glory" },
    tells = {
      "Carries the blessing of a whole city's victory and walks like it.",
      "Stands taller for the blessing, and knows it won't last.",
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
      "Hurt, and moving carefully around it.",
      "Wincing when {they} think no one's looking.",
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
      "Fresh blood on {their} {mainhand}, none of it {their} own.",
    },
  },
  worried = {
    title = "Worried", icon = "INV_Misc_Coin_04",
    adj = { "Worried about money", "Counting copper", "Down to {their} last coins" },
    tells = {
      "{their} {pouch} hangs light. Checks prices twice before buying anything.",
      "Has the pinched look of someone short of money.",
    },
  },
  flush = {
    title = "Flush", icon = "INV_Misc_Coin_01",
    adj = { "Flush with coin", "Feeling wealthy", "Jingling as {they} walk" },
    tells = {
      "Flush with coin, and in a generous mood.",
      "Recently came into money and has started to swagger.",
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
    tells = { "Stands straighter, like someone who just did the right thing." },
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
    tells = { "Bags stuffed to bursting, clanking with every step." },
  },
  newsy = {
    title = "Full of News", icon = "INV_Letter_03",
    adj = { "Full of news", "Mulling over a letter" },
    tells = { "Has had news, and keeps going back to it in {their} head." },
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
    tells = { "Unremarkable at a glance.", "Calm, watchful, and in no hurry." } },
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
  greedy = { title = "Calculating", icon = "INV_Misc_Coin_02", adj = { "Calculating", "Thinking about money" },
    tells = { "Eyes that price everything they land on." } },
  generous = { title = "Open-Handed", icon = "INV_Misc_Bag_10", adj = { "Open-handed", "Generous" },
    tells = { "Quick to share with anyone who needs it." } },
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
  light = { [1] = "keeps to the Light", [-1] = "walks closer to the shadow than most would like" },
  order = { [1] = "believes in law and keeping one's place", [-1] = "answers to no rules but {their} own" },
  honor = { [1] = "keeps {their} word", [-1] = "lies easily and well" },
}

---------------------------------------------------------------------------
-- Earned names. A nickname, a motto and an icon come from something the character saw
-- through: a story finished in RPG Dialogue, a quest chain finished (Chronicle), a bounty
-- collected or a dungeon's master brought down. History says where each came from.
-- nick: what people call them. motto: the saying they took from it (optional). icon: the
-- profile icon while that nickname stands.
---------------------------------------------------------------------------
W.EARNED_STORY = {
  arugal_wolves = { nick = "Wolf-Hunter", motto = "Bar the door when the moon is up.", icon = "Ability_Hunter_Pet_Wolf" },
  ashenvale_axes = { nick = "Axe-Breaker", motto = "Count the cost before the first blow.", icon = "INV_Axe_02" },
  blackrock_down = { nick = "Mountain-Watcher", motto = "Watch the passes.", icon = "Ability_Warrior_DefensiveStance" },
  blood_god = { nick = "Priest-Breaker", motto = "No god is owed blood.", icon = "Spell_Shadow_SoulLeech_2" },
  bloodsail_eye = { nick = "Dock-Watcher", motto = "Watch the ships, not the sailors.", icon = "INV_Misc_Spyglass_02" },
  both_shores = { nick = "Rot-Finder", motto = "Sickness doesn't care which shore it's on.", icon = "Spell_Shadow_AbominationExplosion" },
  burning_blade = { nick = "Blade-Breaker", motto = "Cut the root, not the branch.", icon = "Ability_Warrior_Rampage" },
  darkspear_isles = { nick = "Hex-Breaker", motto = "A curse is only words until you believe it.", icon = "Spell_Shadow_ShadowWordPain" },
  dawn_letters = { nick = "the Dawn's Courier", motto = "Deliver the letter, whatever it says.", icon = "INV_Letter_15" },
  desolace_clans = { nick = "Clan-Talker", motto = "Hear every side before you pick one.", icon = "INV_BannerPVP_02" },
  dru_alliance = { nick = "Bear-Friend", motto = "Some choose the wild. Let them.", icon = "Ability_Druid_Maul" },
  dru_circle = { nick = "Fire-Sharer", motto = "There's room at the fire for two.", icon = "Spell_Nature_Tranquility" },
  dru_horde = { nick = "Fang-Friend", motto = "Watch what you turn into.", icon = "Ability_Druid_Maul" },
  dwarf_haldin = { nick = "Gorge-Walker", motto = "Kin is kin, even in the Gorge.", icon = "INV_Hammer_20" },
  dwarves_and_dark_iron = { nick = "Span-Mender", motto = "A broken bridge can still be crossed.", icon = "INV_Hammer_20" },
  eldre_thalas = { nick = "Ruin-Walker", motto = "Old stones keep old secrets.", icon = "INV_Misc_Rune_01" },
  elf_saelra = { nick = "the Watcher", motto = "Someone has to keep watch.", icon = "Spell_Holy_MindVision" },
  elwynn_gold = { nick = "Mine-Warden", motto = "Gold isn't worth a life.", icon = "INV_Misc_Coin_02" },
  farholde_lost = { nick = "Fern's Friend", motto = "Nobody is lost while someone's looking.", icon = "Spell_Holy_Renew" },
  felwood_rot = { nick = "Rot-Cleanser", motto = "Sick land can heal.", icon = "Spell_Nature_Tranquility" },
  gadgetzan_water = { nick = "Water-Bringer", motto = "Water first. Then talk.", icon = "INV_Drink_04" },
  gnomeregan_lost = { nick = "Gnomeregan's Friend", motto = "Find out who's to blame before you blame them.", icon = "Trade_Engineering" },
  grimtotem = { nick = "Totem-Breaker", motto = "Keep an eye on the hills.", icon = "INV_BannerPVP_02" },
  hinterlands_trolls = { nick = "Hill-Climber", motto = "Go up and look for yourself.", icon = "INV_Misc_Spyglass_02" },
  hun_alliance = { nick = "Bear-Tracker", motto = "Read the tracks before you draw.", icon = "Ability_Hunter_BeastCall" },
  hun_horde = { nick = "Herd-Keeper", motto = "Take only what the herd can spare.", icon = "Ability_Hunter_BeastCall" },
  hun_rhokdelar = { nick = "Stranger's Friend", motto = "Be kind to strangers.", icon = "Ability_Hunter_BeastCall" },
  kolkar_war = { nick = "Well-Keeper", motto = "Whoever holds the water holds the land.", icon = "INV_Drink_04" },
  lock_summit = { nick = "the Climber", motto = "There's always a higher step.", icon = "Spell_Shadow_ShadowBolt" },
  lock_surena = { nick = "Gakin's Student", motto = "Learn from the master, then surpass him.", icon = "Spell_Shadow_ShadowBolt" },
  lock_zelk = { nick = "Zelk's Heir", motto = "Every road has a toll.", icon = "Spell_Shadow_Teleport" },
  mage_alliance = { nick = "Bread-Bringer", motto = "Magic should feed people.", icon = "INV_Misc_Food_15" },
  mage_dalaran = { nick = "Dome-Watcher", motto = "Ask what's behind the door.", icon = "Spell_Holy_SealOfWisdom" },
  mage_horde = { nick = "Frost-Friend", motto = "Choose your own path, even if it's cold.", icon = "Spell_Nature_Cyclone" },
  missing_diplomat = { nick = "Diplomat-Finder", motto = "Find the missing man and you find the plot.", icon = "INV_Letter_03" },
  new_plague = { nick = "Plague-Finder", motto = "Burn it before it spreads.", icon = "Spell_Shadow_AbominationExplosion" },
  plague_cauldrons = { nick = "Cauldron-Breaker", motto = "Break the pot, stop the poison.", icon = "Spell_Shadow_AbominationExplosion" },
  plague_light = { nick = "Plaguelands Lantern", motto = "Light a candle in the dark places.", icon = "Spell_Holy_HolyBolt" },
  portal_watch = { nick = "Portal-Watcher", motto = "Somebody has to watch the gate.", icon = "Spell_Shadow_GatherShadows" },
  scarlet_path = { nick = "Crimson-Walker", motto = "Zeal is not the same as right.", icon = "Spell_Holy_SealOfRighteousness" },
  silithus_stirring = { nick = "Sand-Listener", motto = "Listen to the ground.", icon = "INV_Misc_Spyglass_02" },
  solomons_letters = { nick = "Solomon's Runner", motto = "A plea for help deserves an answer.", icon = "INV_Letter_15" },
  stalvan = { nick = "Stalvan's Witness", motto = "The truth comes out in the end.", icon = "INV_Misc_Book_08" },
  the_circle = { nick = "Keeper's Hand", motto = "Do the work the land asks of you.", icon = "Spell_Nature_Tranquility" },
  venture_mulgore = { nick = "Venture-Breaker", motto = "Not everything is for sale.", icon = "Trade_Engineering" },
  war_garvak = { nick = "Fever-Breaker", motto = "Keep the blood cool.", icon = "Ability_Warrior_Rampage" },
  war_harlan = { nick = "the Unbeaten", motto = "Get back up.", icon = "Ability_Warrior_BattleShout" },
  war_willem = { nick = "Harry's Hand", motto = "Finish the list.", icon = "INV_Misc_Note_01" },
  westfall_left = { nick = "Westfall's Friend", motto = "Nobody should have to fend for themselves.", icon = "Spell_Holy_PrayerOfHealing" },
  winterfall_firewater = { nick = "Firewater-Breaker", motto = "Pour it out.", icon = "INV_Drink_05" },
}

-- Quest chains, by the title of the quest that ends them (Chronicle keeps titles in the
-- game's language, so these are matched on English clients only). deed: how History tells it.
W.EARNED_QUEST = {
  ["The Defias Brotherhood"] = { nick = "Defias-Breaker", motto = "Pay what's owed, or someone will collect.",
    icon = "INV_Misc_Mask_01", deed = "Followed the trail of the Defias Brotherhood to its end" },
  ["Princess Must Die!"] = { nick = "Pig-Sticker", icon = "INV_Misc_Food_15", deed = "Put an end to Princess at the Brackwell Pumpkin Patch" },
  ["The Legend of Stalvan"] = { nick = "Stalvan's Witness", motto = "The truth comes out in the end.",
    icon = "INV_Misc_Book_08", deed = "Uncovered the story of Stalvan Mistmantle" },
  ["The Missing Diplomat"] = { nick = "Diplomat-Finder", motto = "Find the missing man and you find the plot.",
    icon = "INV_Letter_03", deed = "Saw the business of the missing diplomat through" },
}

-- Dungeon masters brought down (Chronicle's boss list), easiest first: the hardest one
-- felled names them. short: the name the nickname uses.
W.EARNED_BOSS = {
  { name = "Edwin VanCleef", short = "VanCleef" },
  { name = "Mutanus the Devourer", short = "Mutanus" },
  { name = "Archmage Arugal", short = "Arugal" },
  { name = "Bazil Thredd", short = "Thredd" },
  { name = "Aku'mai", short = "Aku'mai" },
  { name = "Mekgineer Thermaplugg", short = "Thermaplugg" },
  { name = "Charlga Razorflank", short = "Razorflank" },
  { name = "High Inquisitor Whitemane", short = "Whitemane" },
  { name = "Amnennar the Coldbringer", short = "Amnennar" },
  { name = "Archaedas", short = "Archaedas" },
  { name = "Princess Theradras", short = "Theradras" },
  { name = "Shade of Eranikus", short = "Eranikus" },
  { name = "Emperor Dagran Thaurissan", short = "Thaurissan" },
  { name = "King Gordok", short = "Gordok" },
  { name = "Darkmaster Gandling", short = "Gandling" },
  { name = "Baron Rivendare", short = "Rivendare" },
  { name = "General Drakkisath", short = "Drakkisath" },
}
W.EARNED_BOSS_ICON = "INV_Misc_Head_Dragon_01"
W.EARNED_BOUNTY_ICON = "INV_Misc_Note_06"

-- The profile icon before any nickname is earned: the class crest.
W.CLASS_ICON = {
  WARRIOR = "ClassIcon_Warrior", PALADIN = "ClassIcon_Paladin", HUNTER = "ClassIcon_Hunter", ROGUE = "ClassIcon_Rogue",
  PRIEST = "ClassIcon_Priest", SHAMAN = "ClassIcon_Shaman", MAGE = "ClassIcon_Mage", WARLOCK = "ClassIcon_Warlock",
  DRUID = "ClassIcon_Druid",
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
  cenarion_circle = "the Cenarion Circle", teldrassil = "Teldrassil", teldrassil_tree = "Teldrassil",
  argent_dawn = "the Argent Dawn", kirin_tor = "the Kirin Tor", thrall = "Thrall", cairne = "Cairne",
  dark_iron = "the Dark Irons", blackrock = "the Blackrock clan", burning_blade = "the Burning Blade",
  syndicate = "the Syndicate", sentinels = "the Sentinels", earthen_ring = "the Earthen Ring",
  bronzebeard = "the Bronzebeards", magram = "the Magram", gelkis = "the Gelkis",
}

-- Topic ids RPG Dialogue may add later read with "the" when they name a group.
W.GROUP_WORDS = { circle = true, crusade = true, company = true, league = true, dawn = true, hammer = true,
  brotherhood = true, council = true, order = true, army = true, guard = true, legion = true, cult = true,
  clan = true, tribe = true, syndicate = true, alliance = true, horde = true, scourge = true, sentinels = true }

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
  { name = "Reviled", max = -60, phrase = "isn't welcome in {town}" },
  { name = "Distrusted", max = -20, phrase = "isn't trusted in {town}" },
  { name = "Stranger", max = 9 },
  { name = "Known", max = 29, phrase = "has been seen around {town}" },
  { name = "Liked", max = 54, phrase = "is liked in {town}" },
  { name = "Respected", max = 79, phrase = "is trusted in {town}" },
  { name = "Hero", max = 100, phrase = "is well thought of in {town}" },
}

W.FULLTITLE_TIER = {
  Liked = "Friend of {town}", Respected = "Friend of {town}", Hero = "Friend of {town}",
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

W.RACE_NOUN = {
  Human = "human", Dwarf = "dwarf", Gnome = "gnome", NightElf = "night elf", Orc = "orc", Troll = "troll",
  Tauren = "tauren", Scourge = "Forsaken", Undead = "Forsaken",
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
  { max = 99, words = { "long-travelled", "weathered" } },
}

---------------------------------------------------------------------------
-- Zone atmosphere for "Currently", out on the road. Each is a whole phrase.
---------------------------------------------------------------------------
W.ZONE_FLAVOR = {
  ["Elwynn Forest"] = { "wandering the oak woods of Elwynn", "walking the farm lanes of Elwynn" },
  ["Westfall"] = { "crossing the fallow fields of Westfall", "on the dusty roads of Westfall, past empty farmhouses" },
  ["Redridge Mountains"] = { "in the red hills above Lake Everstill", "on the mountain trails of Redridge" },
  ["Duskwood"] = { "beneath the dead trees of Duskwood", "on the dark road through Duskwood" },
  ["Stranglethorn Vale"] = { "deep in the jungle of Stranglethorn", "sweating through the vines of Stranglethorn" },
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
  ["Tanaris"] = { "out on the dunes of Tanaris", "in the shifting sands of Tanaris" },
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
    tells = { "Full of the season's cheer, humming carols under {their} breath." } },
  hallowsend = { title = "Spooky", adj = { "In a spooky mood", "Grinning like a carved gourd" },
    tells = { "A mischievous glint in {their} eye, as if planning a prank." } },
  love = { title = "Lovestruck", adj = { "Feeling romantic", "Lovestruck" },
    tells = { "A soft look about {them}, and a mind somewhere else." } },
  midsummer = { title = "Sun-Warmed", adj = { "Sun-warmed and cheerful", "Full of summer" },
    tells = { "Sun-warmed and slow to stop smiling." } },
  brewfest = { title = "Brewfest Spirit", adj = { "In the Brewfest spirit", "Ale-happy" },
    tells = { "Wears {their} {head} at a festive angle and smiles at everyone.", "In the mood for a drink and a song." } },
  lunar = { title = "Honouring Elders", adj = { "Thoughtful, as the old year turns" },
    tells = { "Quiet, with a thought for those who came before." } },
  noblegarden = { title = "Springtime", adj = { "Full of spring" },
    tells = { "Bright-eyed with the spring, and in a playful mood." } },
}

-- What a character wants, when nothing else says (by class). Kept broad and lore-safe.
W.AMBITIONS = {
  WARRIOR = { "To be the last one standing when it matters.", "To be the one others count on in a fight." },
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
  intellect = { "sharp-eyed and thoughtful", "quick-eyed, with a thinker's frown" },
  spirit = { "calm, with an unhurried air", "even-tempered and slow to rattle" },
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
    uneasy = { "Keeps a hand near {their} {mainhand} and glances over a shoulder at every sound." },
  },
  Dwarf = {
    weary = { "Legs heavy as anvils, but still marching." },
    merry = { "A booming laugh, and another drink never far away." },
    angry = { "Face red, jaw working, looking for someone to blame." },
    ease = { "Content as a dwarf by a forge." },
  },
  Gnome = {
    weary = { "Eyes red-rimmed, and slower on {their} feet than usual." },
    elated = { "Bouncing on {their} toes and talking a mile a minute about something technical." },
    uneasy = { "Ears twitching at every sound, eyes darting." },
    wonder = { "Asking how everything works, and remembering every answer." },
  },
  NightElf = {
    weary = { "Ears drooping, eyes dimmer than usual." },
    uneasy = { "Ears flicking at every sound, silver eyes narrowed at the dark." },
    ease = { "Still as a moonlit pool. Centuries of patience in one quiet breath." },
    downcast = { "Ears low, eyes distant." },
  },
  Orc = {
    angry = { "Tusks bared, knuckles cracking. The bloodlust is close to the surface today." },
    merry = { "Roaring with laughter, louder with every drink." },
    weary = { "Shoulders hunched like a wolf after a long hunt." },
    elated = { "Chest out, chin up. Lok'tar written in every step." },
  },
  Troll = {
    ease = { "Lounging loose-limbed, tusks catching the light, in no hurry at all, mon." },
    uneasy = { "Muttering to the loa under {their} breath." },
    merry = { "Grinning wide around the tusks and swaying to a rhythm only {they} can hear." },
    angry = { "Hunched low, tusks forward. The look of a Darkspear about to settle a score." },
  },
  Tauren = {
    weary = { "Great head bowed, hooves dragging. Even the Earth Mother's children need rest." },
    ease = { "Ears twitching lazily, breathing slow and deep like the plains at evening." },
    uneasy = { "Nostrils flared, ears pinned back. Doesn't like the smell of this place." },
    downcast = { "Massive shoulders slumped, head low." },
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
    WARRIOR = { "Recruit", "Grunt", "Raider", "Sergeant", "Veteran", "Battle-Hardened", "Blooded Veteran" },
    ROGUE = { "Cutthroat", "Footpad", "Thief", "Shadow", "Blade", "Nightblade", "Master Assassin" },
  },
  Alliance = {
    WARRIOR = { "Recruit", "Foot Soldier", "Soldier", "Sergeant", "Veteran", "Battle-Hardened", "Hardened Veteran" },
  },
}

-- Ladders specific to a race and class: these win over the class and faction ones.
W.RANKS_RACE = {
  Scourge = {
    ROGUE = { "Newly Risen", "Footpad", "Deathstalker Initiate", "Deathstalker", "Senior Deathstalker", "Shadow Blade", "Master Deathstalker" },
    PRIEST = { "Acolyte", "Initiate", "Dark Acolyte", "Dark Cleric", "Shadow Priest", "Deathspeaker", "Elder Deathspeaker" },
    MAGE = { "Apprentice", "Novice", "Adept", "Magus", "Dark Sorcerer", "Arcanist", "Master Arcanist" },
    WARLOCK = { "Initiate", "Occultist", "Summoner", "Necrolyte", "Diabolist", "Dreadcaller", "Master Diabolist" },
    WARRIOR = { "Risen", "Grunt", "Deathguard Recruit", "Deathguard", "Deathguard Sergeant", "Deathguard Veteran", "Deathguard Elder" },
  },
  Dwarf = {
    HUNTER = { "Novice", "Mountaineer", "Mountaineer Scout", "Sharpshooter", "Senior Mountaineer", "Mountain Ranger", "Master Mountaineer" },
    WARRIOR = { "Recruit", "Shieldbearer", "Guard", "Ironforge Sergeant", "Hold Guard", "Ironforge Veteran", "Hold Veteran" },
    PRIEST = { "Acolyte", "Initiate", "Cleric of the Light", "Priest", "Confessor", "High Cleric", "Elder Cleric" },
    PALADIN = { "Initiate", "Squire", "Knight of Ironforge", "Templar", "Crusader", "Justicar", "Elder Templar" },
  },
  Gnome = {
    MAGE = { "Apprentice", "Tinker-Mage", "Adept", "Magus", "Arcanotech", "Arcanist", "Grand Arcanotech" },
    ROGUE = { "Pickpocket", "Saboteur", "Thief", "Shadow", "Infiltrator", "Nightblade", "Master Saboteur" },
    WARRIOR = { "Recruit", "Foot Soldier", "Gnomeregan Guard", "Sergeant", "Veteran", "Gnomeregan Veteran", "Hardened Veteran" },
    WARLOCK = { "Initiate", "Occultist", "Summoner", "Shadowcaster", "Diabolist", "Dreadcaller", "Master Diabolist" },
  },
  NightElf = {
    HUNTER = { "Novice", "Tracker", "Ranger", "Pathfinder", "Moonstalker", "Huntmaster", "Master of the Wilds" },
    PRIEST = { "Novice of Elune", "Initiate of Elune", "Acolyte of Elune", "Priest of the Moon", "Moon Priest", "Senior Moon Priest", "Elder of the Moon" },
    DRUID = { "Initiate", "Neophyte", "Grove Warden", "Wild Walker", "Shapeshifter", "Elder Druid", "Wildkeeper" },
    WARRIOR = { "Recruit", "Sentinel Recruit", "Sentinel", "Sentinel Sergeant", "Senior Sentinel", "Sentinel Veteran", "Elder Sentinel" },
    ROGUE = { "Cutpurse", "Shadow-Walker", "Thief", "Shadow", "Blade", "Nightblade", "Master of Shadows" },
  },
  Human = {
    ROGUE = { "Cutpurse", "Footpad", "Thief", "Informant", "Operative", "Agent", "Master Assassin" },
    PALADIN = { "Initiate", "Squire", "Knight", "Knight of the Light", "Crusader", "Justicar", "Elder Knight" },
    PRIEST = { "Acolyte", "Initiate", "Cleric of the Light", "Priest", "Confessor", "Senior Cleric", "Elder Cleric" },
    MAGE = { "Apprentice", "Novice", "Adept", "Magus", "Sorcerer", "Arcanist", "Master Arcanist" },
  },
  Orc = {
    SHAMAN = { "Initiate", "Seer", "Spirit-Speaker", "Stormcaller", "Farseer", "Elder Farseer", "Elder Shaman" },
    HUNTER = { "Novice", "Tracker", "Wolf Rider", "Pathfinder", "Beastmaster", "Huntmaster", "Master Hunter" },
    WARLOCK = { "Initiate", "Occultist", "Summoner", "Shadowcaster", "Diabolist", "Dreadcaller", "Master Diabolist" },
  },
  Troll = {
    HUNTER = { "Novice", "Tracker", "Headhunter", "Pathfinder", "Shadow Stalker", "Huntmaster", "Master Headhunter" },
    SHAMAN = { "Initiate", "Seer", "Loa-Speaker", "Witch Doctor", "Hexer", "Elder Witch Doctor", "Master Witch Doctor" },
    PRIEST = { "Acolyte", "Initiate", "Loa-Speaker", "Priest", "Shadow Priest", "High Priest", "Elder Loa-Speaker" },
    ROGUE = { "Cutthroat", "Footpad", "Thief", "Shadow", "Shadow Blade", "Nightblade", "Master Assassin" },
    MAGE = { "Apprentice", "Novice", "Adept", "Magus", "Sorcerer", "Arcanist", "Master Arcanist" },
  },
  Tauren = {
    WARRIOR = { "Young Brave", "Brave", "Plainsrunner", "Warrior", "Veteran Brave", "Seasoned Brave", "Elder Brave" },
    HUNTER = { "Novice", "Brave", "Plainsrunner", "Pathfinder", "Wind Rider", "Huntmaster", "Hunter of the Earth Mother" },
    DRUID = { "Initiate", "Neophyte", "Grove Warden", "Wild Walker", "Shapeshifter", "Elder", "Elder of the Grove" },
    SHAMAN = { "Initiate", "Seer", "Spirit-Speaker", "Earthcaller", "Farseer", "Elder Seer", "Elder Shaman" },
  },
}

-- How each race looks to a stranger.
W.RACE_LOOK = {
  Human = { "Human, of middling height and ordinary build." },
  Dwarf = { "Short, broad and solid as the mountain.", "Stocky, with forearms like anvils." },
  Gnome = { "Small, bright-eyed and never still.", "Tiny and quick, with large eyes and long ears." },
  NightElf = { "Tall and graceful, with long ears and eyes that glow faintly silver.", "Tall, with long sweeping ears and silver eyes." },
  Orc = { "Green-skinned and heavy-jawed, with jutting tusks.", "Massive shoulders, a heavy brow and jutting tusks." },
  Troll = { "Tall and lanky, with long tusks and longer ears.", "Loose-limbed and hunched, tusks curving up past a wide grin." },
  Tauren = { "Enormous and calm, horned and hoofed, with gentle eyes.", "A towering bulk of fur and muscle, crowned with horns." },
  Scourge = { "Grey, rotting flesh stretched over bone, with a jaw that doesn't quite close.", "Gaunt, eyes burning a cold yellow in a ruined face." },
}

-- What a class carries that marks it out.
W.CLASS_LOOK = {
  WARRIOR = { "Carries {their} {mainhand} like it weighs nothing." },
  HUNTER = { "{pet} is never far from {their} side.", "Keeps {their} {ranged} where {they} can reach it." },
  ROGUE = { "Hands never far from {their} {mainhand}." },
  MAGE = { "Keeps {their} {mainhand} close at hand." },
  WARLOCK = { "{pet} lurks close behind {them}." },
  DRUID = { "Keeps {their} {mainhand} close at hand." },
}




-- Class tells for moods (used about a third of the time, when one fits).
W.CLASS_TELLS = {
  WARRIOR = { angry = { "Jaw clenched, hand on {their} {mainhand}, looking for an excuse." }, weary = { "Arms hanging heavy, the fight gone out of {them} for now." }, fierce = { "Rolling {their} shoulders and grinning at the next fight." } },
  PALADIN = { downcast = { "Head bowed, as if praying for strength." }, righteous = { "Calm and certain, like someone who has just done right by the Light." }, conflicted = { "Troubled in conscience, praying under {their} breath." } },
  HUNTER = { ease = { "Content, with {pet} at {their} feet." }, uneasy = { "Eyes on the treeline, {their} {ranged} close to hand." }, wonder = { "Watching the local beasts with a hunter's interest." } },
  ROGUE = { uneasy = { "Eyes on every exit, fingers near {their} {mainhand}." }, flush = { "Suspiciously well off, and not saying where it came from." }, tense = { "Moving silently, never quite in the light." } },
  PRIEST = { shaken = { "Murmuring a prayer, over and over, until the hands stop shaking." }, devout = { "Lips moving in quiet devotion." }, sorrowful = { "Grieving, and holding it together for others." } },
  SHAMAN = { uneasy = { "Frowning at the restless spirits of this place." }, ease = { "Calm and settled, at home in this place." }, angry = { "Tense as a storm about to break." } },
  MAGE = { weary = { "Rubbing {their} temples, and short of patience." }, intrigued = { "Muttering formulae under {their} breath." }, angry = { "Speaking in clipped, cold sentences." } },
  WARLOCK = { ease = { "{pet} is quiet today, and so is {their} temper." }, haunted = { "Glances over {their} shoulder at nothing." }, angry = { "Cold, quiet anger, the worrying kind." } },
  DRUID = { uneasy = { "Restless, and listening hard." }, ease = { "At one with the place, and in no hurry." }, angry = { "A low growl in the throat that sounds more bear than person." } },
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
  ["Stoneform"] = { mood = { "rattled", 18, "had to turn to stone" } },
  ["Escape Artist"] = { mood = { "rattled", 18, "a narrow escape" } },
  ["Feed Pet"] = { mood = { "ease", 12, "fed {their} companion" } },
}
-- Mage portals: "Portal: Stormwind" -> "opening a portal to Stormwind".
W.ACTIVITY.portal = { "opening a portal to {dest} in {place}" }
W.ACTIVITY.summoning = { "performing a summoning ritual in {place}" }
W.ACTIVITY.shadowmeld = { "melting into the shadows in {place}" }
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
  Scourge = { downcast = 1.2, haunted = 0.7, shaken = 0.7, uneasy = 0.6, smitten = 0.7 },
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
  shaken = { "Hands shaking, muttering a prayer to the Light." },
  elated = { "Grinning like a farmhand at harvest festival." },
  downcast = { "Shoulders slumped, staring at nothing, like a soldier after a lost battle." },
  fierce = { "Arms loose, eyes hard. A veteran's calm before the charge." },
})
more("Dwarf", {
  shaken = { "Face pale, and for once short of words." },
  downcast = { "Staring at nothing, shoulders slumped." },
  elated = { "Slapping backs and bellowing for another round." },
  wonder = { "Peering at the stonework, muttering about Titan craft." },
  fierce = { "Face red and {their} {mainhand} in hand, ready to give a grudge its due." },
})
more("Gnome", {
  shaken = { "Ears flat, voice an octave higher than usual." },
  downcast = { "Uncharacteristically quiet." },
  angry = { "Red to the tips of {their} ears, waving {their} arms." },
  ease = { "Humming to {themselves}, quick hands at rest." },
})
more("NightElf", {
  shaken = { "Ears pinned back, eyes glowing too bright." },
  elated = { "Moves with a dancer's lightness, silver eyes shining." },
  angry = { "Eyes narrowed to burning slits. Ten thousand years of patience are wearing thin." },
  wonder = { "Studying the place as if comparing it to a memory centuries old." },
})
more("Orc", {
  shaken = { "Breathing hard through the tusks, refusing to look rattled." },
  downcast = { "Hunched and silent, the way an orc grieves: alone." },
  ease = { "Loose-shouldered and easy, for an orc." },
  uneasy = { "Sniffing the air, hackles up." },
})
more("Troll", {
  shaken = { "Muttering to the loa, tusks clacking." },
  downcast = { "Long ears drooping, tusks down, quiet as the swamp." },
  elated = { "Cackling to {themselves}, mon." },
  wonder = { "Head tilted, taking it all in with a wide, tusky grin." },
})
more("Tauren", {
  shaken = { "Massive hands trembling, murmuring to the Earth Mother for calm." },
  elated = { "A deep, rumbling laugh that shakes the ground a little." },
  angry = { "Snorting, head lowered, horns forward. Slow to anger, but there now." },
  wonder = { "Taking slow, careful steps, as if listening to the land itself." },
})
more("Scourge", {
  shaken = { "A dead thing shouldn't tremble, but this one does." },
  elated = { "Jaw hanging in what might be a grin." },
  angry = { "Eyes blazing a cold yellow." },
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
  shaken = { "Leaning on {their} {mainhand} more than usual." },
  elated = { "Loud and laughing, chest out." },
  downcast = { "Says nothing, and doesn't want to be asked." },
  ease = { "Shoulders loose, at ease for once." },
})
moreClass("PALADIN", {
  shaken = { "Praying hard, hands clasped tight." },
  elated = { "Practically glowing, and not only with the Light." },
  angry = { "Righteous fury in {their} eyes. Someone has offended the Light." },
  ease = { "Calm, and at peace with the Light." },
})
moreClass("HUNTER", {
  shaken = { "Staying close to {pet}." },
  elated = { "Grinning, with {pet} close at heel." },
  downcast = { "Quiet, with {pet} close by." },
  fierce = { "Eyes already on the next quarry." },
})
moreClass("ROGUE", {
  shaken = { "Fingers drumming on {their} {mainhand}, eyes darting." },
  elated = { "A crooked grin and a new spring in {their} step. Something went very right." },
  ease = { "Easy and loose, but still watching the room." },
  angry = { "Very still and very quiet. That's usually worse." },
})
moreClass("PRIEST", {
  elated = { "Humming a hymn, radiant." },
  angry = { "Lips pressed thin, patience gone." },
  ease = { "Serene, and in no hurry." },
  uneasy = { "Praying under {their} breath that the dark stays back." },
})
moreClass("SHAMAN", {
  shaken = { "Breathing slowly, trying to find {their} footing again." },
  elated = { "Bright-eyed, as if the elements had good news." },
  downcast = { "Quiet, as if asking the spirits for answers they won't give." },
  wonder = { "Head tilted, listening to what the land here has to say." },
})
moreClass("MAGE", {
  shaken = { "Muttering a counterspell under {their} breath out of habit." },
  elated = { "Talking quickly, eyes bright." },
  ease = { "Unhurried, with {their} mind on something else." },
  wonder = { "Studying the place with a scholar's interest." },
})
moreClass("WARLOCK", {
  shaken = { "Pale, and less sure of {themselves} than usual." },
  elated = { "A thin, satisfied smile, as if a bargain paid off." },
  downcast = { "Staring into the middle distance, lost in dark thought." },
  fierce = { "Eager, with a thin smile." },
})
moreClass("DRUID", {
  shaken = { "Breathing slowly, steadying {themselves} the way a cornered animal does." },
  elated = { "Light on {their} feet and smiling." },
  downcast = { "Quiet and withdrawn, slow to answer." },
  wonder = { "Taking in every unfamiliar plant and beast." },
})

---------------------------------------------------------------------------
-- City districts (Currently, while in a capital).
---------------------------------------------------------------------------
W.CITY_FLAVOR = {
  ["Trade District"] = "among the shops of Stormwind's Trade District",
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
  ["The Drag"] = "among the crowds of the Drag",
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


---------------------------------------------------------------------------
-- Classic zone map IDs -> the English names the tables above use, so zone touches work
-- whatever language the game runs in.
---------------------------------------------------------------------------
W.ZONE_BY_MAP = {
  [1411] = "Durotar", [1412] = "Mulgore", [1413] = "The Barrens", [1416] = "Alterac Mountains",
  [1417] = "Arathi Highlands", [1418] = "Badlands", [1419] = "Blasted Lands", [1420] = "Tirisfal Glades",
  [1421] = "Silverpine Forest", [1422] = "Western Plaguelands", [1423] = "Eastern Plaguelands",
  [1424] = "Hillsbrad Foothills", [1425] = "The Hinterlands", [1426] = "Dun Morogh", [1427] = "Searing Gorge",
  [1428] = "Burning Steppes", [1429] = "Elwynn Forest", [1430] = "Deadwind Pass", [1431] = "Duskwood",
  [1432] = "Loch Modan", [1433] = "Redridge Mountains", [1434] = "Stranglethorn Vale", [1435] = "Swamp of Sorrows",
  [1436] = "Westfall", [1437] = "Wetlands", [1438] = "Teldrassil", [1439] = "Darkshore", [1440] = "Ashenvale",
  [1441] = "Thousand Needles", [1442] = "Stonetalon Mountains", [1443] = "Desolace", [1444] = "Feralas",
  [1445] = "Dustwallow Marsh", [1446] = "Tanaris", [1447] = "Azshara", [1448] = "Felwood", [1449] = "Un'Goro Crater",
  [1450] = "Moonglade", [1451] = "Silithus", [1452] = "Winterspring", [1453] = "Stormwind City",
  [1454] = "Orgrimmar", [1455] = "Ironforge", [1456] = "Thunder Bluff", [1457] = "Darnassus", [1458] = "Undercity",
}

-- Gathering and tradecraft (successful casts).
W.SPELLS["Mining"] = { context = "mining" }
W.SPELLS["Herb Gathering"] = { context = "herbs" }
W.SPELLS["Skinning"] = { context = "skinning" }
W.SPELLS["Disenchant"] = { context = "disenchant" }
W.SPELLS["Pick Lock"] = { context = "lockpick" }
W.SPELLS["Pick Pocket"] = { context = "pickpocket", mood = { "flush", 6, "lightened a purse" } }
W.ACTIVITY.mining = { "working a mineral vein in {place}", "chipping ore out of the rock in {place}" }
W.ACTIVITY.herbs = { "gathering herbs in {place}", "picking herbs in {place}" }
W.ACTIVITY.skinning = { "skinning a fresh kill in {place}" }
W.ACTIVITY.disenchant = { "breaking down a magic trinket for its essence in {place}" }
W.ACTIVITY.lockpick = { "quietly picking a lock in {place}" }
W.ACTIVITY.pickpocket = { "lightening someone's purse in {place}", "light-fingered around {place}" }

---------------------------------------------------------------------------
-- The character's arc, for About. These read as a life, not a ledger: where they stand on
-- the road, what it has made of them, what dying taught them. Keyed by level band
-- (new, finding their feet, established, veteran) and then by the strongest trait.
---------------------------------------------------------------------------

W.PROF_NOUN = {
  herbalism = "herbalist", mining = "miner", skinning = "skinner", alchemy = "alchemist", blacksmithing = "blacksmith",
  leatherworking = "leatherworker", tailoring = "tailor", engineering = "engineer", enchanting = "enchanter",
  cooking = "cook", ["first aid"] = "field medic", fishing = "angler", jewelcrafting = "jeweller", inscription = "scribe",
}

-- How the mood journal reads as part of a life.
W.WEEK_TONE = {
  hard = { "The last few days have been hard on {them}.", "It's been a bad stretch." },
  good = { "The last few days have been good ones.", "Things have been going well lately." },
}


-- Class reagents and tools in the bags (item id, name if the game can't say). What a class
-- carries is told only when it's really in the bags.
W.CLASS_REAGENTS = {
  PALADIN = { { 21177, "Symbol of Kings" }, { 17033, "Symbol of Divinity" } },
  PRIEST = { { 17029, "Sacred Candle" }, { 17028, "Holy Candle" } },
  SHAMAN = { { 5175, "Earth Totem" }, { 5176, "Fire Totem" }, { 5177, "Water Totem" }, { 5178, "Air Totem" }, { 17030, "Ankh" } },
  MAGE = { { 17020, "Arcane Powder" }, { 17031, "Rune of Teleportation" }, { 17032, "Rune of Portals" } },
  WARLOCK = { { 6265, "Soul Shard" } },
  DRUID = { { 17026, "Wild Thornroot" }, { 17021, "Wild Berries" }, { 17034, "Maple Seed" } },
  ROGUE = { { 5140, "Flash Powder" }, { 5530, "Blinding Powder" }, { 6947, "Instant Poison" } },
}

-- How well off they are, against what's usual at their level (money in copper / level^2).
W.WEALTH = {
  { max = 20, word = "Living hand to mouth", flair = "These days {they're} living hand to mouth, with almost nothing put by.", pouch = "{their} {pouch} is close to empty" },
  { max = 100, word = "Getting by", flair = "These days {they're} getting by, with little to spare.", pouch = "{their} {pouch} is light" },
  { max = 400, word = "Comfortable", flair = "These days {they're} comfortable, with enough coin put by not to worry about it.", pouch = "{their} {pouch} clinks when {they} walk" },
  { max = 1500, word = "Well off", flair = "These days {they're} well off, and money hasn't been a worry for a while.", pouch = "{their} {pouch} sits heavy" },
  { max = math.huge, word = "Wealthy", flair = "These days {they're} wealthy, with more gold than {they} could easily spend.", pouch = "{their} {pouch} is fat with gold" },
}

-- How kept their gear is, by the worst piece's durability in the game. {item} is that piece.
W.DURABILITY = {
  { max = 0.001, glance = "Broken Gear", text = "{item} is broken outright and needs a smith before it's any use" },
  { max = 0.2, glance = "Battered Kit", text = "{item} is close to breaking" },
  { max = 0.4, glance = "Worn Kit", text = "{item} is badly worn and overdue for a smith" },
  { max = 0.6, text = "{item} shows hard use" },
  { max = 0.8, text = "{item} is scuffed from the road" },
  { max = 0.95 },
  { max = 2, text = "Everything {they} wear is well kept" },
}
