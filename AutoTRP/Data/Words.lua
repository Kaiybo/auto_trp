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
    adj = { "Still shaken", "Pale and shaken", "Not quite steady yet", "White about the lips", "Unsteady on {their} feet",
      "Shaky" },
    tells = {
      "Flinches at sudden noises. The hands haven't stopped trembling.",
      "Keeps touching an old wound as if to make sure it's closed.",
      "Has the far-off look of someone who came very close to the end.",
      "Pale to the lips, and slow to answer when spoken to.",
      "The hands won't keep still, so {they} fold{s} them away.",
      "Voice thin and careful, as if it might crack.",
      "Eyes on the ground, breathing like someone counting each breath.",
      "Startles when anyone moves too quickly nearby.",
    },
  },
  rattled = {
    title = "Rattled", icon = "Ability_Rogue_FeignDeath",
    adj = { "A little rattled", "Breathing hard", "Bruised and rattled", "Shaken up", "Still catching {their} breath",
      "Jumpy after a close call" },
    tells = {
      "Breathing hard, eyes still checking the treeline.",
      "Patched up in a hurry, and still hurting.",
      "Still catching {their} breath, and talking too fast.",
      "Laughs too quickly at nothing, the way people do after a close call.",
      "Eyes keep going back the way {they} came.",
      "Flexes both hands as if checking they still work.",
    },
  },
  elated = {
    title = "In High Spirits", icon = "Spell_Holy_SurgeOfLight",
    adj = { "In high spirits", "Flushed with success", "Grinning to {themselves}", "Beaming", "Riding high",
      "In the best of moods" },
    tells = {
      "Walks taller today. Something long worked for has come good.",
      "Keeps smiling at nothing in particular.",
      "Can't keep the grin off {their} face for long.",
      "Laughs easily today, and means it.",
      "Greets strangers like old friends.",
      "Bright-eyed, and talking faster than usual.",
      "Has the loose, happy stride of someone whose luck just turned.",
    },
  },
  triumphant = {
    title = "Triumphant", icon = "INV_BannerPVP_02",
    adj = { "Fresh from a hard-won victory", "Triumphant", "Flushed with victory", "Victorious", "Still riding the win" },
    tells = {
      "Has the swagger of someone who just won a hard fight.",
      "Battle-stained but upright. Whatever it was, it's dead now.",
      "Chin up and eyes bright. The fight is over, and {they} won it.",
      "Bruised, tired and grinning anyway.",
      "Speaks louder than usual, with a winner's ease.",
      "Carries {their} {mainhand} like a trophy today.",
      "Has the look of someone already telling the story of the fight in {their} head.",
    },
  },
  satisfied = {
    title = "Satisfied", icon = "INV_Misc_Note_01",
    adj = { "Quietly satisfied", "Content with a day's work", "Pleased with {themselves}", "Content", "Easy in {their} mind" },
    tells = {
      "Has the easy shoulders of someone who kept {their} word today.",
      "{their} {pouch} is heavier than it was this morning.",
      "A small, private smile, the kind that comes from finishing something.",
      "Unhurried, with nothing left nagging at {them}.",
      "Nods to people in passing, in a good humour.",
    },
  },
  weary = {
    title = "Road-Weary", icon = "Spell_Nature_Sleep",
    adj = { "Bone-tired", "Road-weary", "Worn thin", "Dead on {their} feet", "Footsore", "Heavy-eyed", "Flagging" },
    tells = {
      "Moves slowly, like someone who has been on the road too long.",
      "Dark circles under the eyes. Could sleep standing up.",
      "Road-weary, moving like every mile is still in {their} legs.",
      "Yawns behind a hand, and doesn't bother hiding the next one.",
      "Slow to answer, and slower to smile.",
      "Eyelids heavy. Blinks hard to keep them up.",
      "Shoulders sagging, every step an effort.",
    },
  },
  ease = {
    title = "At Ease", icon = "INV_Drink_04",
    adj = { "At ease", "Warm and unhurried", "Rested", "Relaxed", "Untroubled", "In no hurry" },
    tells = {
      "Shoulders down. Nothing is chasing {them} today.",
      "Rested, and in no hurry.",
      "Breathing slow and even. Nothing to prove today.",
      "Smiles easily and lets the world go by.",
      "Loose-limbed and unhurried.",
      "Has the look of someone who slept well and ate better.",
      "Quiet, comfortable, content to listen.",
    },
  },
  merry = {
    title = "Merry", icon = "INV_Drink_05",
    adj = { "Merry", "Several cups in", "Cheerfully unsteady", "Tipsy", "Rosy-cheeked and loud", "In {their} cups" },
    tells = {
      "Smells of ale and laughs too loudly.",
      "Swaying slightly, and very fond of everyone right now.",
      "Cheeks flushed, laughing at {their} own jokes.",
      "Calls everyone friend and means it, for now.",
      "Voice a notch louder than it needs to be, and happy about it.",
      "Sways gently whenever {they} stand{s} still.",
      "Breathing ale over anyone who leans close, and grinning about it.",
    },
  },
  haunted = {
    title = "Haunted", icon = "Spell_Shadow_Possession",
    adj = { "Haunted", "Not entirely present", "Muttering under {their} breath", "Hollow-eyed and distant", "Far away",
      "Listening to something no one else hears" },
    tells = {
      "Glances at empty corners as if someone just spoke there.",
      "Starts at shadows, and doesn't say why.",
      "Talks to {themselves} in a low voice, then stops when noticed.",
      "Eyes fixed on something just past whoever {they're} talking to.",
      "Laughs at the wrong moments, and stops abruptly.",
      "Answers questions no one asked.",
    },
  },
  wonder = {
    title = "Wide-Eyed", icon = "INV_Misc_Spyglass_02",
    adj = { "Wide-eyed", "Taking it all in", "Curious about everything", "Agog", "Looking everywhere at once", "Fascinated" },
    tells = {
      "Keeps stopping to look at things the locals stopped seeing years ago.",
      "New to these parts, and making no secret of it.",
      "Head turning at every new sight, trying to see it all at once.",
      "Asks the locals the names of things.",
      "Eyes wide, missing nothing.",
      "Stops mid-step to stare at whatever caught {their} eye.",
      "Has the look of someone seeing all this for the first time, and liking it.",
    },
  },
  homecoming = {
    title = "Home Again", icon = "INV_Misc_Rune_01",
    adj = { "Glad to be home", "Back on familiar ground", "Home at last", "Back where {they} belong{s}" },
    tells = {
      "Greets the place like an old friend. The tension's gone out of {their} shoulders.",
      "Breathes in deep, the way people do when they smell home.",
      "Smiling at the familiar streets.",
      "Walks the old ways without needing to look.",
      "Looser in the shoulders than {they've} been in days.",
    },
  },
  tense = {
    title = "On Guard", icon = "Ability_Warrior_DefensiveStance",
    adj = { "On guard", "Wound tight", "Watchful", "Alert", "Ready for trouble", "Edgy" },
    tells = {
      "Keeps {their} {mainhand} close and listens before every corner.",
      "Moves like someone who expects the floor to give way.",
      "Eyes on every doorway, weight on the balls of {their} feet.",
      "Speaks low and short, listening the whole time.",
      "Never turns {their} back on the room.",
      "Jaw tight, every muscle ready.",
      "Keeps {their} {shield} up and {their} eyes moving.",
    },
  },
  uneasy = {
    title = "Uneasy", icon = "Spell_Shadow_Twilight",
    adj = { "Uneasy", "Jumpy", "Keeping to the light", "Ill at ease", "On edge", "Looking over {their} shoulder" },
    tells = {
      "Keeps {their} back to a wall.",
      "Doesn't like this place, and doesn't pretend to.",
      "Eyes keep sliding to the shadows.",
      "Talks fast, and listens harder.",
      "Stiff-shouldered, glancing back every few steps.",
      "Doesn't trust the quiet here.",
      "Rubs {their} arms as if against a chill.",
    },
  },
  sociable = {
    title = "Talkative", icon = "INV_Letter_15",
    adj = { "Talkative", "Full of news", "In a sociable mood", "Chatty", "Friendly", "Eager to talk" },
    tells = {
      "Has been talking to a lot of people lately, and is in the mood for more.",
      "Quick to strike up a conversation today.",
      "Has a ready smile and a question for whoever's nearest.",
      "Remembers names, and uses them.",
      "Laughs easily, and invites others to.",
      "Leans in to listen when people talk.",
      "Open-faced and easy to approach today.",
    },
  },
  intrigued = {
    title = "Intrigued", icon = "INV_Misc_Book_06",
    adj = { "Turning something over", "Intrigued", "Preoccupied", "Puzzling something out", "Absorbed", "Deep in thought" },
    tells = {
      "Frowning over some news {they} can't let go of.",
      "Lost in thought, piecing something together.",
      "Brow furrowed, eyes far away.",
      "Mutters half-sentences, then nods to {themselves}.",
      "Asks pointed questions, and remembers the answers.",
      "Taps a finger against {their} chin, thinking.",
      "Has the look of someone who almost has it worked out.",
    },
  },
  determined = {
    title = "Determined", icon = "Ability_Warrior_BattleShout",
    adj = { "Determined", "Set on a purpose", "Resolute", "Single-minded", "Purposeful", "Not to be put off" },
    tells = {
      "Has the look of someone with somewhere to be.",
      "Jaw set, eyes forward.",
      "Walks fast and doesn't stop to chat.",
      "Answers short, eyes already on the road ahead.",
      "Wears the face of someone who has made up {their} mind.",
    },
  },
  company = {
    title = "In Good Company", icon = "Spell_Holy_PrayerOfSpirit",
    adj = { "In good company", "Among friends", "Glad of the company", "Easy among friends",
      "Cheerful among {their} companions" },
    tells = {
      "Glad of the company.",
      "Laughs at a companion's joke, and makes one back.",
      "Keeps checking that everyone's keeping up.",
      "Easier in the shoulders with others around.",
      "Talks more than usual, and listens too.",
      "Has the look of someone glad not to be alone.",
    },
  },
  sorrowful = {
    title = "Sorrowful", icon = "Spell_Holy_PainSupression",
    adj = { "Red-eyed and quiet", "Sorrowful", "Heavy-hearted", "Grieving", "Mournful", "Low-spirited" },
    tells = {
      "Eyes rimmed red. Answers in as few words as {they} can manage.",
      "Carries some private grief, and carries it badly today.",
      "Voice thick. Swallows hard before speaking.",
      "Looks at nothing for long stretches.",
      "Smiles when spoken to, and lets it drop the moment no one is looking.",
      "Eyes wet, and not hiding it.",
    },
  },
  angry = {
    title = "Short-Tempered", icon = "Ability_Warrior_Rampage",
    adj = { "Fuming", "Short-tempered", "Spoiling for a fight", "Seething", "In a black mood", "Bristling" },
    tells = {
      "Jaw set, knuckles white. People give {them} room.",
      "Something has {their} blood up, and it isn't cooling.",
      "Answers in a growl, if at all.",
      "A muscle jumps in {their} jaw.",
      "Breathing through the nose, slow and loud.",
      "Hands clenching and unclenching.",
      "Glares at anyone who looks too long.",
    },
  },
  smitten = {
    title = "Smitten", icon = "INV_ValentinesCandy",
    adj = { "Smitten", "Distracted by someone", "Humming to {themselves}", "Moon-eyed", "Lovesick", "Starry-eyed" },
    tells = {
      "Keeps smiling at nothing.",
      "Has the dreamy, faraway look of someone thinking about a particular face.",
      "Drifts off mid-sentence, smiling.",
      "Blushes at nothing.",
      "Sighs, and doesn't seem to notice.",
      "Answers questions a beat late, mind elsewhere.",
    },
  },
  devout = {
    title = "At Prayer", icon = "Spell_Holy_PrayerOfHealing",
    adj = { "Quiet and prayerful", "Lost in prayer", "Reverent", "Hushed", "Solemn", "Full of faith" },
    tells = {
      "Head bowed, lips moving. Somewhere far from here.",
      "Has the stillness of someone who has just finished praying.",
      "Speaks softly, as if in a temple.",
      "Eyes half-closed, lips still moving.",
      "Hands clasped, head bent.",
      "Quiet in a way that asks not to be interrupted.",
    },
  },
  fed = {
    title = "Well-Fed", icon = "INV_Misc_Food_15",
    adj = { "Well-fed", "Pleasantly full", "Comfortably stuffed", "Full and content" },
    tells = {
      "Has the contented look of someone who just ate well.",
      "Lazy and loose after a good meal.",
      "Smacks {their} lips now and then, still tasting it.",
      "Moving slower, the way a full stomach makes anyone.",
    },
  },
  downcast = {
    title = "Downcast", icon = "Spell_Shadow_GatherShadows",
    adj = { "Downcast", "Quiet and grim", "Carrying a bad day on {their} shoulders", "Low", "Glum", "Dispirited" },
    tells = {
      "Has the hollow, quiet look of someone who has died recently and hasn't made peace with it.",
      "Moves carefully, like someone not yet sure the ground will hold.",
      "Doesn't laugh at jokes today. Something cold followed {them} back.",
      "Eyes on the ground. Answers in a mumble.",
      "Smiles when it's expected, and drops it after.",
      "A slow, flat voice, as if nothing much matters today.",
      "Shoulders rounded, hands still.",
    },
  },
  frustrated = {
    title = "Frustrated", icon = "Ability_Warrior_Revenge",
    adj = { "Thoroughly fed up", "Frustrated", "At the end of {their} rope", "Exasperated", "Irritable", "Out of patience" },
    tells = {
      "Muttering curses at no one in particular.",
      "Has fallen more than once today and is taking it personally.",
      "Sighs through the teeth at every small thing.",
      "Snaps, then apologises, then snaps again.",
      "Rubs {their} face with both hands and groans.",
      "Glowers at the road like it owes {them} something.",
    },
  },
  bolstered = {
    title = "In Fine Fettle", icon = "Spell_Holy_WordFortitude",
    adj = { "In fine fettle", "Brimming with vigour", "Feeling unstoppable", "Hale and hearty", "Bursting with energy" },
    tells = {
      "Fairly crackling with borrowed blessings. Stands like nothing could knock {them} down.",
      "Wrapped in wards and blessings that glow at the edges.",
      "Stands tall, breathing deep and easy.",
      "Moves like someone who could walk all day and fight all night.",
      "Colour high in the cheeks, energy to spare.",
    },
  },
  glorious = {
    title = "Glorious", icon = "INV_Misc_Head_Dragon_01",
    adj = { "Riding high on a city's cheer", "Glorious", "Blazing with borrowed glory", "Exultant", "Shining" },
    tells = {
      "Carries the blessing of a whole city's victory and walks like it.",
      "Stands taller for the blessing, and knows it won't last.",
      "Glowing with a city's blessing, chin high.",
      "Walks as if the whole city were still cheering.",
    },
  },
  ailing = {
    title = "Ailing", icon = "Spell_Shadow_AbominationExplosion",
    adj = { "Feverish", "Ailing", "Green about the gills", "Sickly", "Unwell", "Shivering with fever" },
    tells = {
      "Pale and sweating, with a cough that doesn't sound good.",
      "Whatever {they} caught out there is still in {their} blood.",
      "Clammy, flushed and short of breath.",
      "Eyes glassy with fever.",
      "Moves slowly, one arm held across the middle.",
      "Looks like {they} should be in bed.",
    },
  },
  drained = {
    title = "Drained", icon = "Spell_Shadow_SoulLeech_2",
    adj = { "Drained", "Weak as a kitten", "Hollow-eyed", "Spent", "Washed out", "Wrung out" },
    tells = {
      "Still grey from the trip back from the other side. Every movement costs.",
      "Pale as milk, and slow to move.",
      "Speaks quietly, saving breath.",
      "Has to stop and steady {themselves} now and then.",
      "Shivers now and then, as if not yet warm again.",
    },
  },
  wounded = {
    title = "Wounded", icon = "Ability_Rogue_FeignDeath",
    adj = { "Nursing fresh wounds", "Bloodied", "Limping", "Hurting", "Battered" },
    tells = {
      "Hurt, and moving carefully around it.",
      "Wincing when {they} think{s} no one's looking.",
      "Holds one arm close, and winces when it moves.",
      "Pale around the mouth, breathing carefully.",
      "Favouring one leg, and not hiding it well.",
    },
  },
  festive = {
    title = "Festive", icon = "INV_Holiday_Christmas_Present_01",
    adj = { "In a festive mood", "Full of the season", "Cheerful" },
    tells = { "Caught up in the season's cheer.", "Smiling at everyone, in the spirit of the day.", "Humming a holiday tune." },
  },
  fierce = {
    title = "Battle-Hungry", icon = "Ability_Warrior_BattleShout",
    adj = { "Blood up", "Battle-hungry", "Spoiling for the next fight", "Fired up", "Hungry for a fight", "Raring to go" },
    tells = {
      "Still breathing hard from the last fight and already looking for the next.",
      "Fresh blood on {their} {mainhand}, none of it {their} own.",
      "Eyes bright and hard, looking for the next one.",
      "Bouncing on the balls of {their} feet, blood still up.",
      "Grins at the thought of a fight.",
      "Breathing hard, nostrils flared, ready for more.",
    },
  },
  worried = {
    title = "Worried", icon = "INV_Misc_Coin_04",
    adj = { "Worried about money", "Counting copper", "Down to {their} last coins", "Short of coin", "Fretting over money" },
    tells = {
      "{their} {pouch} hangs light. Checks prices twice before buying anything.",
      "Has the pinched look of someone short of money.",
      "Winces at every price.",
      "Worry lines that have nothing to do with fighting.",
      "Talks about prices more than anyone should.",
    },
  },
  flush = {
    title = "Flush", icon = "INV_Misc_Coin_01",
    adj = { "Flush with coin", "Feeling wealthy", "Jingling as {they} walk{s}", "Well-heeled", "Free with {their} coin" },
    tells = {
      "Flush with coin, and in a generous mood.",
      "Recently came into money and has started to swagger.",
      "{their} {pouch} sits heavy, and {they} know{s} it.",
      "Has the easy look of someone who can pay for the next round.",
      "Grinning about a good haul.",
    },
  },
  thrilled = {
    title = "Thrilled", icon = "INV_Misc_Gem_Pearl_04",
    adj = { "Thrilled", "Admiring a new prize", "Barely able to keep still", "Delighted", "Over the moon", "Giddy" },
    tells = {
      "Keeps taking out a new treasure to admire it.",
      "Has just found something wonderful, and wants everyone to ask about it.",
      "Grinning ear to ear.",
      "Talks about a new find to anyone who'll listen.",
      "Practically bouncing.",
    },
  },
  conflicted = {
    title = "Conflicted", icon = "Spell_Shadow_UnholyStrength",
    adj = { "Conflicted", "Troubled by a choice", "Second-guessing {themselves}", "Torn", "Wrestling with {themselves}" },
    tells = {
      "Turns something over and over in {their} head, and doesn't like the answer.",
      "Has the look of someone who did a thing they're not proud of.",
      "Starts to speak, then stops.",
      "Frowns down at {their} own hands.",
      "Can't meet anyone's eyes for long.",
      "Sighs often, and doesn't explain.",
    },
  },
  righteous = {
    title = "Righteous", icon = "Spell_Holy_SealOfRighteousness",
    adj = { "Quietly righteous", "At peace with {their} choices", "Clear-eyed", "Upright", "Clean of conscience" },
    tells = {
      "Stands straighter, like someone who just did the right thing.",
      "Clear-eyed and steady. No regrets today.",
      "Calm, with the ease of a clean conscience.",
      "Meets every gaze without flinching.",
      "Speaks plainly, and stands by it.",
    },
  },
  proud = {
    title = "Proud", icon = "INV_Misc_Ribbon_01",
    adj = { "Proud", "Standing tall", "Head held high", "Chest out" },
    tells = {
      "Has earned some goodwill lately, and walks like it.",
      "Chin up, back straight.",
      "Smiles when people nod {their} way.",
      "Walks taller than usual.",
    },
  },
  ashamed = {
    title = "Ashamed", icon = "Spell_Shadow_Charm",
    adj = { "Ashamed", "Keeping {their} head down", "Shamefaced", "Red-faced", "Quiet and sheepish" },
    tells = {
      "Avoids meeting people's eyes. Word of something has got around.",
      "Ears burning, eyes down.",
      "Speaks quietly, and doesn't push.",
      "Flushes when anyone looks too long.",
    },
  },
  eager = {
    title = "Eager", icon = "Spell_Holy_BlessingOfStrength",
    adj = { "Eager", "On the verge of something", "Restless with promise", "Keen", "Itching to get on" },
    tells = {
      "Has the restless energy of someone right on the edge of getting better at this.",
      "Can't stand still for long.",
      "Bright-eyed and impatient.",
      "Has the restless look of someone very nearly there.",
    },
  },
  burdened = {
    title = "Overloaded", icon = "INV_Misc_Bag_08",
    adj = { "Weighed down", "Overloaded", "Laden", "Loaded down" },
    tells = {
      "Bags stuffed to bursting, clanking with every step.",
      "Clinks and rattles at every step.",
      "Walks bent under {their} load.",
      "Grunts every time {they} shift{s} {their} load.",
    },
  },
  newsy = {
    title = "Full of News", icon = "INV_Letter_03",
    adj = { "Full of news", "Mulling over a letter", "Thinking over some news", "Distracted by news" },
    tells = {
      "Has had news, and keeps going back to it in {their} head.",
      "Distracted, with fresh news on {their} mind.",
      "Keen to share some news with whoever will listen.",
    },
  },
  accomplished = {
    title = "Accomplished", icon = "INV_Misc_Note_06",
    adj = { "Having a good day", "On a roll", "Making good progress", "Pleased with the day's work" },
    tells = {
      "Has been crossing jobs off the list all day and is pleased about it.",
      "Brisk, and pleased with {themselves}.",
      "Nods to {themselves} now and then, like someone ticking things off.",
    },
  },
  lonely = {
    title = "Solitary", icon = "Spell_Shadow_Teleport",
    adj = { "Alone with {their} thoughts", "Keeping to {themselves}", "Solitary", "Lonesome", "Self-contained" },
    tells = {
      "Has the quiet manner of someone who's been on {their} own a long while.",
      "Startled to be spoken to, then glad of it.",
      "Speaks slowly, like someone out of practice.",
      "Watches groups pass with an unreadable face.",
      "Used to {their} own company.",
    },
  },
}

-- Baseline when nothing stands out, tinted by temperament (the top RPG Dialogue trait).
W.CALM = {
  default = { title = "Steady", icon = "Spell_Nature_Tranquility", adj = { "Steady", "Calm", "Even-tempered", "Composed" },
    tells = { "Unremarkable at a glance.", "Calm, watchful, and in no hurry.", "Gives nothing much away.",
      "Easy to pass in a crowd, and seems to like it that way.", "Steady-eyed and quiet." } },
  kind = { title = "Warm", icon = "Spell_Holy_Renew", adj = { "In good spirits", "Warm", "Good-humoured", "Gentle" },
    tells = { "Quick with a smile and a nod for strangers.", "Has a kind face, and the patience to match.",
      "Listens properly when people speak.", "Soft-spoken, and quick to help." } },
  stern = { title = "Composed", icon = "Ability_Warrior_CommandingShout", adj = { "Composed", "Stern-faced", "Grave", "Unsmiling" },
    tells = { "Stands straight, speaks little, misses nothing.", "A face that gives nothing away.",
      "Weighs every word before letting it go.", "Doesn't smile much, and doesn't seem to miss it." } },
  witty = { title = "Wry", icon = "INV_Misc_Toy_07", adj = { "Wry", "Amused at something", "Sharp-tongued", "Twinkling" },
    tells = { "A half-smile, as though everything is a joke only {they've} heard.", "Has a quick answer for most things.",
      "Eyes that laugh a moment before the mouth does.", "Never far from a joke, and quick to share it." } },
  cruel = { title = "Cold", icon = "Spell_Shadow_ShadowWordPain", adj = { "Cold", "Hard-eyed", "Icy", "Flinty" },
    tells = { "People step out of {their} way without quite knowing why.", "A thin smile that never warms.",
      "Looks at people the way a butcher looks at livestock.", "Speaks softly, and somehow it's worse." } },
  pious = { title = "Prayerful", icon = "Spell_Holy_PrayerOfHealing", adj = { "Prayerful", "Serene", "Tranquil", "Devoted" },
    tells = { "Lips move now and then in a quiet prayer.", "Calm in the way of someone with faith to lean on.",
      "Serene, as though listening to something holy.", "Gives thanks under {their} breath for small things." } },
  skeptical = { title = "Doubtful", icon = "INV_Misc_QuestionMark", adj = { "Doubtful", "Unconvinced", "Wary", "Dry" },
    tells = { "An eyebrow that's permanently halfway raised.", "Listens to every story like it's a sales pitch.",
      "Says \"we'll see\" more than anything else.", "Has a dry look for anything that sounds too good to be true." } },
  greedy = { title = "Calculating", icon = "INV_Misc_Coin_02", adj = { "Calculating", "Thinking about money", "Shrewd", "Sharp-eyed" },
    tells = { "Eyes that price everything they land on.", "Always seems to be adding something up.",
      "Interested in anyone who might be useful.", "Smiles most when talk turns to coin." } },
  generous = { title = "Open-Handed", icon = "INV_Misc_Bag_10", adj = { "Open-handed", "Generous", "Big-hearted", "Easy-going" },
    tells = { "Quick to share with anyone who needs it.", "An open, welcoming face.",
      "Never seems to count what {they} give{s} away.", "Asks after other people's troubles before {their} own." } },
  curious = { title = "Inquisitive", icon = "INV_Misc_Book_09", adj = { "Inquisitive", "Curious", "Interested in everything", "Bright-eyed" },
    tells = { "Asks one question too many, and listens to every answer.", "Eyes that wander to everything new.",
      "Always looks about to ask something.", "Leans in close to anything interesting." } },
  brave = { title = "Bold", icon = "Ability_Warrior_BattleShout", adj = { "Bold", "Unafraid", "Fearless", "Steady-nerved" },
    tells = { "Walks into rooms like {they've} already decided how it ends.", "Meets every eye straight on.",
      "Doesn't flinch, and doesn't seem to know how.", "Stands square, like a door that won't be pushed." } },
  cautious = { title = "Careful", icon = "Ability_Stealth", adj = { "Careful", "Watchful", "Guarded", "Wary" },
    tells = { "Always knows where the nearest door is.", "Thinks before every step.",
      "Sits with {their} back to the wall when {they} can.", "Slow to trust, slower to commit." } },
  charming = { title = "Charming", icon = "INV_ValentinesCard02", adj = { "Charming", "Easy-going", "Winsome", "Silver-tongued" },
    tells = { "Has a way of making people feel like the only one in the room.", "A warm laugh, and good at drawing others out.",
      "Remembers what people like, and mentions it.", "An easy smile that comes out often." } },
  reserved = { title = "Reserved", icon = "INV_Misc_Book_08", adj = { "Reserved", "Quiet", "Private", "Self-possessed" },
    tells = { "Speaks only when it's worth the breath.", "Keeps {their} own counsel.",
      "Polite, short and hard to read.", "Listens far more than {they} talk{s}." } },
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

-- Mild leans by class, for the trait bars when there are no choices to read them from.
-- Keyed by the left word of a TRAIT_BARS or AXIS_BARS bar; positive leans left (+4 is a
-- gentle lean, never an extreme).
W.CLASS_LEANS = {
  WARRIOR = { Brave = 4, Playful = -3, Lawful = 2 },
  PALADIN = { Religious = 5, Good = 4, Lawful = 4 },
  HUNTER = { Outgoing = -3, Brave = 2, Playful = 1 },
  ROGUE = { Honest = -3, Outgoing = -2, Lawful = -3 },
  PRIEST = { Religious = 5, Kind = 4, Generous = 2 },
  SHAMAN = { Religious = 3, Kind = 2, Playful = -2 },
  MAGE = { Brave = -2, Playful = -2, Religious = -3 },
  WARLOCK = { Good = -3, Outgoing = -3, Generous = -2 },
  DRUID = { Kind = 3, Outgoing = -2, Lawful = -2 },
  DEATHKNIGHT = { Kind = -3, Playful = -4, Brave = 3 },
}

-- And by race, added to the class's. Kept smaller, so the class leads.
W.RACE_LEANS = {
  Human = { Lawful = 2, Outgoing = 1 },
  Dwarf = { Outgoing = 2, Generous = 1, Brave = 2 },
  Gnome = { Playful = 3, Religious = -2 },
  NightElf = { Outgoing = -2, Religious = 2 },
  Orc = { Brave = 3, Honest = 2 },
  Troll = { Playful = 2, Religious = 2 },
  Tauren = { Kind = 2, Religious = 2, Honest = 1 },
  Scourge = { Kind = -2, Playful = -1, Religious = -3 },
  Undead = { Kind = -2, Playful = -1, Religious = -3 },
  Goblin = { Generous = -3, Outgoing = 2, Lawful = -1 },
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
-- game's language, so these are matched on English clients only). deed: how History tells
-- it. tier: how much it took (1 a local errand seen through, 2 a land's long chain, 3 a
-- dungeon's chain, 4 the way into a raid); the greatest one done names them, and between
-- equals the first one done.
W.EARNED_QUEST = {
  -- Eastern Kingdoms
  ["Princess Must Die!"] = { tier = 1, nick = "Pig-Sticker", motto = "Even a pig can be a menace.",
    icon = "INV_Misc_Food_15", deed = "Put an end to Princess at the Brackwell Pumpkin Patch" },
  ["The People's Militia"] = { tier = 2, nick = "Militia-Hand", motto = "Look after your own.",
    icon = "INV_BannerPVP_02", deed = "Stood with the People's Militia in Westfall" },
  ["The Defias Brotherhood"] = { tier = 3, nick = "Defias-Breaker", motto = "Pay what's owed, or someone will collect.",
    icon = "INV_Misc_Mask_01", deed = "Followed the trail of the Defias Brotherhood to its end" },
  ["The Legend of Stalvan"] = { tier = 2, nick = "Stalvan's Witness", motto = "The truth comes out in the end.",
    icon = "INV_Misc_Book_08", deed = "Uncovered the story of Stalvan Mistmantle" },
  ["Stalvan Mistmantle"] = { tier = 2, nick = "Stalvan's Witness", motto = "The truth comes out in the end.",
    icon = "INV_Misc_Book_08", deed = "Saw the story of Stalvan Mistmantle to its end in Duskwood" },
  ["Morganth"] = { tier = 2, nick = "Morganth's Bane", motto = "Old towers hold old trouble.",
    icon = "Spell_Shadow_ShadowBolt", deed = "Put an end to Morganth in the Tower of Ilgalar" },
  ["The Stockade Riots"] = { tier = 3, nick = "Riot-Breaker", motto = "Locks are only as good as the guards.",
    icon = "INV_Misc_Key_14", deed = "Put down the riots in the Stockade" },
  ["Crime and Punishment"] = { tier = 3, nick = "Dextren's Bane", motto = "The guilty answer in the end.",
    icon = "INV_Misc_Key_14", deed = "Saw Dextren Ward answer for his crimes in the Stockade" },
  ["Mor'Ladim"] = { tier = 2, nick = "Grave-Settler", motto = "Some debts outlive the debtor.",
    icon = "Spell_Shadow_RaiseDead", deed = "Put Mor'Ladim to rest in Duskwood" },
  ["Morbent Fel"] = { tier = 2, nick = "Lamp-Lighter", motto = "Light a lamp and keep it lit.",
    icon = "Spell_Holy_HolyBolt", deed = "Saw Morbent Fel brought down in Duskwood" },
  ["Big Game Hunter"] = { tier = 2, nick = "Bangalash's Bane", motto = "Respect what you hunt.",
    icon = "Ability_Hunter_BeastCall", deed = "Brought King Bangalash's head back to Nesingwary's camp" },
  ["The Green Hills of Stranglethorn"] = { tier = 1, nick = "Page-Gatherer", motto = "Finish the book.",
    icon = "INV_Misc_Book_08", deed = "Gathered every page of The Green Hills of Stranglethorn" },
  ["Rin'ji is Trapped!"] = { tier = 1, nick = "Rin'ji's Friend", motto = "A promise to a stranger is still a promise.",
    icon = "Spell_Holy_Renew", deed = "Got Rin'ji out of Quel'Danil Lodge in the Hinterlands" },
  ["Battle of Darrowshire"] = { tier = 2, nick = "Darrowshire's Friend", motto = "A lost battle can still be won.",
    icon = "INV_BannerPVP_02", deed = "Saw the Battle of Darrowshire through" },
  ["In Dreams"] = { tier = 3, nick = "Taelan's Witness", motto = "Mercy is braver than a blade.",
    icon = "Spell_Holy_SealOfRighteousness", deed = "Walked with Taelan Fordring to the end of his road" },
  ["The Platinum Discs"] = { tier = 3, nick = "Disc-Reader", motto = "Old records tell old truths.",
    icon = "INV_Misc_Rune_01", deed = "Brought the Platinum Discs out of Uldaman" },
  ["The Royal Rescue"] = { tier = 3, nick = "Shadowforge-Breaker", motto = "Ask what the rescued want.",
    icon = "INV_Hammer_20", deed = "Went down into Blackrock Depths after Princess Moira" },
  ["The Key to Scholomance"] = { tier = 3, nick = "Key-Bearer", motto = "Hold the key, mind the door.",
    icon = "INV_Misc_Key_14", deed = "Won the key to Scholomance" },
  ["Seal of Ascension"] = { tier = 4, nick = "Spire-Climber", motto = "Climb anyway.",
    icon = "INV_Misc_Rune_01", deed = "Forged the Seal of Ascension" },
  ["Drakefire Amulet"] = { tier = 4, nick = "the Unmasker", motto = "Watch the court as well as the wilds.",
    icon = "INV_Misc_Head_Dragon_Black", deed = "Earned the Drakefire Amulet" },
  ["Attunement to the Core"] = { tier = 4, nick = "Core-Walker", motto = "Every fire has a heart.",
    icon = "Spell_Fire_Incinerate", deed = "Was let into the Molten Core" },
  -- Kalimdor
  ["Burning Blade Medallion"] = { tier = 1, nick = "Coven-Breaker", motto = "Hunt the cult in its own cave.",
    icon = "Spell_Shadow_ShadowBolt", deed = "Took the Burning Blade Medallion from Yarrog Baneshadow" },
  ["The Absent Minded Prospector"] = { tier = 2, nick = "Prospector's Guide", motto = "Keep an eye on the clever ones.",
    icon = "INV_Misc_Spyglass_02", deed = "Got Prospector Remtravel out of the Darkshore dig in one piece" },
  ["The Tower of Althalaxx"] = { tier = 2, nick = "Tower-Breaker", motto = "Shadow is patient. Be more patient.",
    icon = "Spell_Shadow_GatherShadows", deed = "Saw the business of the Tower of Althalaxx through" },
  ["Lost in Battle"] = { tier = 1, nick = "Mankrik's Friend", motto = "Somebody is always waiting for news.",
    icon = "INV_Letter_03", deed = "Found out what became of Mankrik's wife in the Barrens" },
  ["Kolkar Leaders"] = { tier = 1, nick = "Barak's Bane", motto = "Strike the leader and the raid breaks.",
    icon = "Ability_Warrior_BattleShout", deed = "Brought down Barak Kodobane of the Kolkar in the Barrens" },
  ["Counterattack!"] = { tier = 2, nick = "Kolkar-Breaker", motto = "Hold the line.",
    icon = "Ability_Warrior_DefensiveStance", deed = "Beat back the Kolkar counterattack beside Regthar Deathgate" },
  ["Leaders of the Fang"] = { tier = 3, nick = "Fang-Breaker", motto = "Even dreams can be poisoned.",
    icon = "Ability_Hunter_Pet_Wolf", deed = "Brought back the gems of the Fang's leaders from the Wailing Caverns" },
  ["Willix the Importer"] = { tier = 3, nick = "Willix's Guard", motto = "Get the cargo out.",
    icon = "INV_Misc_Note_06", deed = "Got Willix the Importer out of Razorfen Kraul" },
  ["Extinguishing the Idol"] = { tier = 3, nick = "Idol-Quencher", motto = "Put the fire out before it spreads.",
    icon = "Spell_Frost_FrostNova", deed = "Stood guard while Belnistrasz quenched the idol in Razorfen Downs" },
  ["Bring the End"] = { tier = 3, nick = "Barrow-Breaker", motto = "The cold passes.",
    icon = "Spell_Frost_FrostNova", deed = "Brought the end to Amnennar the Coldbringer" },
  ["The Missing Diplomat"] = { tier = 2, nick = "Diplomat-Finder", motto = "Find the missing man and you find the plot.",
    icon = "INV_Letter_03", deed = "Saw the business of the missing diplomat through" },
  ["It's Dangerous to Go Alone"] = { tier = 2, nick = "Linken's Friend", motto = "Never set out alone.",
    icon = "INV_Sword_04", deed = "Helped Linken remember who he was" },
  ["Corruption of Earth and Seed"] = { tier = 3, nick = "Earth-Healer", motto = "Rot starts at the roots.",
    icon = "Spell_Nature_Tranquility", deed = "Saw Princess Theradras brought down in Maraudon" },
  ["Blood of the Black Dragon Champion"] = { tier = 4, nick = "Dragon-Hunter", motto = "Look the dragon in the eye.",
    icon = "INV_Misc_Head_Dragon_Black", deed = "Finished the hunt for the Black Dragon Champion's blood" },
  -- Dungeons, from either side
  ["In the Name of the Light"] = { tier = 3, nick = "Scarlet-Breaker", motto = "The Light doesn't need zealots.",
    icon = "Spell_Holy_SealOfRighteousness", deed = "Saw the Scarlet Monastery's leaders brought down" },
  ["Into The Scarlet Monastery"] = { tier = 3, nick = "Scarlet-Breaker", motto = "The Light doesn't need zealots.",
    icon = "Spell_Holy_SealOfRighteousness", deed = "Saw the Scarlet Monastery's leaders brought down" },
  ["Gnomer-gooooone!"] = { tier = 3, nick = "Gear-Breaker", motto = "Trust the tinker, check the work.",
    icon = "Trade_Engineering", deed = "Saw Mekgineer Thermaplugg brought down in Gnomeregan" },
  ["Arugal Must Die"] = { tier = 3, nick = "Arugal's Bane", motto = "Not every gift is a blessing.",
    icon = "Ability_Hunter_Pet_Wolf", deed = "Saw Archmage Arugal's end in Shadowfang Keep" },
  ["The Grand Betrayal"] = { tier = 3, nick = "Gear-Breaker", motto = "Trust the tinker, check the work.",
    icon = "Trade_Engineering", deed = "Answered the grand betrayal of Gnomeregan" },
  -- Class chains
  ["Whirlwind Weapon"] = { tier = 2, class = "WARRIOR", nick = "the Whirlwind", motto = "Watch every side.",
    icon = "Ability_Whirlwind", deed = "Earned a whirlwind weapon at the end of a warrior's long trial" },
  ["Verigan's Fist"] = { tier = 2, class = "PALADIN", nick = "Verigan's Heir", motto = "Strike for those who can't.",
    icon = "INV_Hammer_02", deed = "Had Verigan's Fist forged" },
}

-- Dungeon and raid masters brought down (Chronicle's boss list), easiest first: the hardest
-- one felled names them. nick: the name; motto: the saying; icon: the profile icon.
W.EARNED_BOSS = {
  { name = "Taragaman the Hungerer", nick = "Taragaman's Bane", motto = "Look under your own city first.", icon = "Spell_Fire_FlameBolt" },
  { name = "Mutanus the Devourer", nick = "Dream-Waker", motto = "Every nightmare ends.", icon = "Spell_Nature_Sleep" },
  { name = "Edwin VanCleef", nick = "VanCleef's Bane", motto = "Every mask comes off.", icon = "INV_Misc_Mask_01" },
  { name = "Archmage Arugal", nick = "Arugal's Bane", motto = "Not every gift is a blessing.", icon = "Ability_Hunter_Pet_Wolf" },
  { name = "Bazil Thredd", nick = "Riot-Breaker", motto = "Locks are only as good as the guards.", icon = "INV_Misc_Key_14" },
  { name = "Aku'mai", nick = "Aku'mai's Bane", motto = "The deep keeps what it takes.", icon = "INV_Misc_Head_Dragon_01" },
  { name = "Mekgineer Thermaplugg", nick = "Thermaplugg's Bane", motto = "Trust the tinker, check the work.", icon = "Trade_Engineering" },
  { name = "Charlga Razorflank", nick = "Thorn-Cutter", motto = "Mind the thorns.", icon = "Spell_Nature_Thorns" },
  { name = "Bloodmage Thalnos", nick = "Thalnos's Bane", motto = "The dead don't keep their bargains.", icon = "Spell_Shadow_RaiseDead" },
  { name = "Arcanist Doan", nick = "Doan's Bane", motto = "Some books should stay shut.", icon = "INV_Misc_Book_08" },
  { name = "Herod", nick = "Herod's Bane", motto = "Loud isn't strong.", icon = "Ability_Whirlwind" },
  { name = "High Inquisitor Whitemane", nick = "Whitemane's Bane", motto = "Faith without mercy isn't faith.", icon = "Spell_Holy_SealOfRighteousness" },
  { name = "Amnennar the Coldbringer", nick = "Frost-Breaker", motto = "The cold passes.", icon = "Spell_Frost_FrostNova" },
  { name = "Archaedas", nick = "Vault-Breaker", motto = "Some doors were shut for a reason.", icon = "INV_Misc_Rune_01" },
  { name = "Chief Ukorz Sandscalp", nick = "Sandscalp's Bane", motto = "Water is worth more than gold out here.", icon = "INV_Drink_04" },
  { name = "Princess Theradras", nick = "Theradras's Bane", motto = "The earth remembers.", icon = "Spell_Nature_Earthquake" },
  { name = "Shade of Eranikus", nick = "Dream-Warden", motto = "Nightmares end at dawn.", icon = "Spell_Nature_Sleep" },
  { name = "Overlord Wyrmthalak", nick = "Wyrmthalak's Bane", motto = "One floor at a time.", icon = "INV_Misc_Head_Dragon_01" },
  { name = "Emperor Dagran Thaurissan", nick = "Thaurissan's Bane", motto = "No crown outlasts its forge.", icon = "INV_Hammer_20" },
  { name = "Alzzin the Wildshaper", nick = "Wildshaper's Bane", motto = "The wild isn't yours to twist.", icon = "Ability_Druid_Maul" },
  { name = "Prince Tortheldrin", nick = "Tortheldrin's Bane", motto = "Power hoarded is power wasted.", icon = "Spell_Holy_SealOfWisdom" },
  { name = "King Gordok", nick = "Gordok's Bane", motto = "The bigger they are...", icon = "INV_Hammer_20" },
  { name = "Darkmaster Gandling", nick = "Gandling's Bane", motto = "Some lessons shouldn't be taught.", icon = "Spell_Shadow_DeathCoil" },
  { name = "Balnazzar", nick = "Balnazzar's Bane", motto = "Look twice at a friendly face.", icon = "Spell_Shadow_DeathCoil" },
  { name = "Baron Rivendare", nick = "Rivendare's Bane", motto = "The dead stay dead.", icon = "Spell_Shadow_RaiseDead" },
  { name = "General Drakkisath", nick = "Drakkisath's Bane", motto = "Dragons bleed like anyone.", icon = "INV_Misc_Head_Dragon_Black" },
  -- Raids
  { name = "Onyxia", raid = true, nick = "Onyxia's Bane", motto = "Watch the court as well as the wilds.", icon = "INV_Misc_Head_Dragon_Black" },
  { name = "Hakkar", raid = true, nick = "Hakkar's Bane", motto = "Blood buys nothing.", icon = "Spell_Shadow_SoulLeech_2" },
  { name = "Ossirian the Unscarred", raid = true, nick = "Ossirian's Bane", motto = "Nothing is unscarred.", icon = "INV_Misc_Rune_01" },
  { name = "Ragnaros", raid = true, nick = "Ragnaros's Bane", motto = "Even fire can be put out.", icon = "Spell_Fire_Incinerate" },
  { name = "Nefarian", raid = true, nick = "Nefarian's Bane", motto = "Every lair has a master.", icon = "INV_Misc_Head_Dragon_Black" },
  { name = "C'Thun", raid = true, nick = "C'Thun's Bane", motto = "Don't listen to what the dark says.", icon = "Spell_Shadow_ShadowWordPain" },
  { name = "Kel'Thuzad", raid = true, nick = "Kel'Thuzad's Bane", motto = "Cold hands, colder hearts.", icon = "Spell_Frost_FrostNova" },
}

-- Bounties: "Wanted: <name>" quests (English titles). A bounty named here has its own
-- saying; the rest are named after their target with no saying.
W.EARNED_BOUNTY = {
  Hogger = { motto = "Even a gnoll can be brought to heel." },
  ["Gath'Ilzogg"] = { motto = "Every warband has a head." },
  Fangore = { motto = "Rank doesn't stop a blade." },
  Murkdeep = { motto = "Wait for the tide." },
  Longshore = { motto = "Pirates hang like anyone." },
}
-- Words that mean a "Wanted:" poster is after a crowd, not a person.
W.BOUNTY_NOT_A_NAME = { personnel = true, ones = true, raiders = true, bandits = true, pirates = true, poachers = true,
  thieves = true, gnolls = true, murlocs = true, brutes = true, gang = true, crew = true, outlaws = true, rebels = true,
  deserters = true, cultists = true, smugglers = true, trolls = true, ogres = true, kobolds = true, centaurs = true }
W.EARNED_BOUNTY_ICON = "INV_Misc_Note_06"

---------------------------------------------------------------------------
-- The most cast spell. Not counted: swings and shots, the hearthstone, gathering and the
-- crafts (by name, and by spell ID for the few that matter on any language).
---------------------------------------------------------------------------
W.CAST_IGNORE = {
  ["Attack"] = true, ["Auto Shot"] = true, ["Shoot"] = true, ["Throw"] = true, ["Hearthstone"] = true,
  ["Opening"] = true, ["Mining"] = true, ["Herb Gathering"] = true, ["Skinning"] = true, ["Fishing"] = true,
  ["Disenchant"] = true, ["Smelting"] = true, ["Cooking"] = true, ["First Aid"] = true, ["Alchemy"] = true,
  ["Blacksmithing"] = true, ["Leatherworking"] = true, ["Tailoring"] = true, ["Engineering"] = true,
  ["Enchanting"] = true, ["Basic Campfire"] = true, ["Find Herbs"] = true, ["Find Minerals"] = true,
  ["Find Treasure"] = true, ["Food"] = true, ["Drink"] = true, ["Refreshment"] = true,
}
W.CAST_IGNORE_ID = { [6603] = true, [75] = true, [5019] = true, [2764] = true, [8690] = true, [3365] = true }
-- What the most cast one is called, by class (a warrior or rogue has abilities, not spells).
W.CAST_NOUN = { WARRIOR = "ability", ROGUE = "ability" }

-- The profile icon before any nickname is earned: the class crest.
W.CLASS_ICON = {
  WARRIOR = "ClassIcon_Warrior", PALADIN = "ClassIcon_Paladin", HUNTER = "ClassIcon_Hunter", ROGUE = "ClassIcon_Rogue",
  PRIEST = "ClassIcon_Priest", SHAMAN = "ClassIcon_Shaman", MAGE = "ClassIcon_Mage", WARLOCK = "ClassIcon_Warlock",
  DRUID = "ClassIcon_Druid", DEATHKNIGHT = "ClassIcon_DeathKnight",
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
  Undead = "Tirisfal Glades", Goblin = "Kezan",
}

W.RACE_NOUN = {
  Human = "human", Dwarf = "dwarf", Gnome = "gnome", NightElf = "night elf", Orc = "orc", Troll = "troll",
  Tauren = "tauren", Scourge = "Forsaken", Undead = "Forsaken", Goblin = "goblin",
}

W.CLASS_NOUN = {
  WARRIOR = "soldier", PALADIN = "paladin", HUNTER = "hunter", ROGUE = "rogue", PRIEST = "priest",
  SHAMAN = "shaman", MAGE = "mage", WARLOCK = "warlock", DRUID = "druid", DEATHKNIGHT = "death knight",
}

-- When there's little to go on (no RPG Dialogue, nothing earned yet), the class still says
-- something about how a character was trained to carry themselves. Each is a disposition,
-- never an action or a thing they hold.
W.CLASS_TEMPER = {
  WARRIOR = { "Trained to hold a line, and slow to give ground in an argument as well.",
    "Has a soldier's habit of sizing up a room by who could cause trouble in it.",
    "Plain-spoken, and more at ease with orders than with speeches.",
    "Respects anyone who stands their ground, whichever side they're on.",
    "Eats when there's food and sleeps when it's quiet, the way soldiers learn to.",
    "Would rather settle a thing face to face than talk about it behind anyone's back.",
    "Slow to boast, and slower to forgive anyone who leaves a comrade behind." },
  PALADIN = { "Holds {themselves} to the oaths of {their} order, and expects others to keep their word too.",
    "Has the steadiness of someone taught that the Light asks for patience as well as courage.",
    "Quick to stand between trouble and the people it's aimed at.",
    "Believes most people are better than they act, and treats them that way until shown otherwise.",
    "Courteous to a fault, even with people who haven't earned it.",
    "Treats a promise as something owed, not something said.",
    "Patient with the weak, and much less so with bullies." },
  HUNTER = { "More at home out in the wild than under a roof.",
    "Notices tracks, weather and the way animals are behaving before anything else.",
    "Patient in the way of someone used to waiting for the right moment.",
    "Sleeps lightly and wakes all at once.",
    "Uses the same quiet voice for animals and people.",
    "Uneasy in crowds, and easy again the moment the trees close in.",
    "Measures distance in days on foot, not in miles." },
  ROGUE = { "Keeps {their} own counsel, and gives little away about where {they've} been.",
    "Watches people's hands out of long habit.",
    "Friendly enough on the surface, and hard to know underneath.",
    "Tells a story differently each time, depending on who's listening.",
    "Sits where the door can be seen, out of long habit.",
    "Trusts a deal more than a promise, and a locked door more than either.",
    "Quick to notice what people would rather keep hidden, and slow to mention it." },
  PRIEST = { "Has the patience of someone trained to tend the hurt.",
    "Listens more than {they} talk{s}, and remembers what people say.",
    "Takes faith seriously, though not so seriously as to lecture about it.",
    "Gentle in manner, and harder to shake than that gentleness suggests.",
    "Asks how people are, and waits for the real answer.",
    "Slow to judge, and hard to shock.",
    "Keeps a calm voice for the worst news." },
  SHAMAN = { "Speaks of the elements the way others speak of neighbours.",
    "Has a calm about {them} that comes of listening to the spirits.",
    "Holds to the old ways without much interest in arguing for them.",
    "Notices when the wind shifts, and says so.",
    "Prefers to let a quarrel run its course, like weather.",
    "Treats fire, stone and water with the respect owed to elders.",
    "Says thanks for small things: water, shelter, a fire that catches." },
  MAGE = { "Curious about everything, and inclined to say so at length.",
    "Thinks before acting, sometimes for longer than the moment allows.",
    "Has a scholar's habit of correcting small mistakes.",
    "Finds most things interesting and a few things fascinating, and says which.",
    "Impatient with guesswork, and fond of the word \"precisely\".",
    "Keeps careful hours, and grows short-tempered when they're broken.",
    "Respects learning wherever it turns up, even in people {they} would otherwise overlook." },
  WARLOCK = { "Guarded about {their} studies, and used to people keeping their distance.",
    "Measures every bargain twice before agreeing to it.",
    "Calm in a way that unsettles people who know what a warlock is.",
    "Polite in a precise, unhurried way that people find hard to warm to.",
    "Leaves what {they} want{s} until the end of a conversation.",
    "Unbothered by what others call unclean, and dry about their fears.",
    "Remembers favours owed with great exactness, in both directions." },
  DRUID = { "Thinks in seasons rather than days.",
    "Has the unhurried manner of someone at peace in the wild.",
    "Feels for the land the way others feel for family.",
    "Patient as roots, and as hard to pull up once settled.",
    "Uneasy behind stone walls, and quietly glad to leave them.",
    "Grants every creature the right to be where it is, until it proves otherwise.",
    "Speaks slowly, and listens to silences as carefully as to words." },
}

W.CLASS_TEMPER.DEATHKNIGHT = { "Carries {themselves} like someone who has already died once and found it overrated.",
  "Speaks rarely, and seldom warmly.", "Has little patience left for fear, {their} own or anyone else's.",
  "Cold in manner, and colder when pressed.",
  "Wastes no words on comfort, though {they} sometimes stay{s} close to people who need it.",
  "Hard to frighten, and uninterested in frightening others for its own sake.",
  "Watches the living with a patience that makes them uneasy." }

-- The same for race: what a stranger expects of {their} people, said of this one.
W.RACE_TEMPER = {
  Human = { "Has a human's knack for getting along with almost anyone.", "Practical in the way of people raised on farms and walls.",
    "Hopeful in a stubborn, everyday way, like people who have rebuilt more than once.",
    "Quick to make friends, and quick to take sides.", "Fond of a plain meal, a warm inn and a fair bargain.",
    "Restless, like most humans, and seldom content to stay put." },
  Dwarf = { "Stubborn as stone once {their} mind is made up.", "Has a dwarf's love of a good story, and a better ale.",
    "Loyal to clan and friends past the point of good sense.", "Trusts what has been tested, and wants to test the rest.",
    "Loud in company and steady in trouble.", "Keeps a grudge carefully, the way others keep savings." },
  Gnome = { "Thinks quickly and talks faster.", "Treats most problems as puzzles waiting for the right tool.",
    "Cheerful in a way that survives most setbacks.", "Bored by anything that can't be taken apart, at least in principle.",
    "Interrupts, though usually to help.", "Treats the size of a problem as a detail." },
  NightElf = { "Takes the long view, as {their} people do.", "Reserved with strangers, and slow to trust the younger races.",
    "Quiet in the way of people used to a forest's quiet.", "Courteous, and distant with it.",
    "Mindful of Elune, and of the moon's turning.", "Slow to speak of what {their} people have lost." },
  Orc = { "Values strength, and respects it in others.", "Blunt, and expects bluntness back.",
    "Honours a debt, and expects others to.", "Short with flatterers, and patient with honest fools.",
    "Proud of {their} people's freedom, and touchy with anyone who doubts it.", "Laughs loudly, when {they} laugh{s} at all." },
  Troll = { "Easy-going on the surface, with a long memory for slights.", "Keeps the old loa close, in word if not in show.",
    "Relaxed in a way that makes some people forget how quick {they} can be.", "Fond of a joke, especially at someone else's expense.",
    "Treats the spirits as neighbours who are owed a greeting.", "Loyal to the Darkspear first, and the Horde a close second." },
  Tauren = { "Slow to anger and hard to stop once roused.", "Gentle-spoken, and careful of the land underfoot.",
    "Thinks before speaking, and often decides not to.", "Patient with the young, and with most people besides.",
    "Honours the Earth Mother in small courtesies to the land.", "Hospitable by habit, and wary only of those who abuse it." },
  Scourge = { "Wry about being dead, and touchy about it too.", "Has the patience of someone with no heartbeat to hurry.",
    "Bitter in a dry, patient way, and rarely loud about it.", "Suspicious of the living's kindness, and of most other kindness too.",
    "Doesn't scare easily. There isn't much left to scare.", "Fiercely protective of {their} own will, having lost it once." },
  Goblin = { "Always working out what something is worth.", "Talks a deal through before {they} talk{s} about anything else.",
    "Never says no to an offer before hearing the price.", "Cheerful about risk, so long as someone else is covering it.",
    "Impatient with anything slow, including caution.", "Quick to spot an angle, and quicker to deny there was one." },
}
W.RACE_TEMPER.Undead = W.RACE_TEMPER.Scourge

-- Nickname until one is earned: where they're from.
W.RACE_NICK = {
  Human = "of Elwynn", Dwarf = "of Ironforge", Gnome = "of Gnomeregan", NightElf = "of Teldrassil",
  Orc = "of Durotar", Troll = "of the Darkspear", Tauren = "of Mulgore", Scourge = "of Tirisfal",
  Undead = "of Tirisfal", Goblin = "of Kezan",
}

-- A motto until one is earned: what the class teaches, in plain words.
W.CLASS_MOTTO = {
  WARRIOR = { "Hold the line.", "Stand fast.", "Nobody gets past.", "Keep your feet.", "Watch the flank.", "Rest when it's over." },
  PALADIN = { "Keep the oath.", "The Light asks nothing easy.", "Stand for those who can't.", "Mercy first, if there's room for it.",
    "Be the wall.", "Right is right, even when it costs." },
  HUNTER = { "Patience, then one clean shot.", "Read the trail.", "The wild keeps its own counsel.",
    "Follow the tracks, not the rumours.", "Wait for the wind.", "Take only what you need." },
  ROGUE = { "Never the same way twice.", "Everyone has a price.", "Quiet feet, open eyes.", "Leave no trace.",
    "Smile, and count the exits.", "Trust the lock, not the locksmith." },
  PRIEST = { "Mend what can be mended.", "Faith is work.", "No one is past help.", "Every wound can be tended.",
    "Kindness costs nothing.", "Pray, then get up and help." },
  SHAMAN = { "Listen to the elements.", "Balance in all things.", "The spirits remember.", "Ask the wind first.",
    "Take nothing without thanks.", "Water finds a way." },
  MAGE = { "Knowledge first.", "Study, then act.", "Every problem has an answer.", "Measure twice, cast once.",
    "Never stop asking why.", "Mind the details." },
  WARLOCK = { "Power has a price.", "Read the bargain twice.", "Fear is a tool.", "Everything can be bargained for.",
    "Know what you're calling.", "Pay what you owe." },
  DRUID = { "Everything in its season.", "The land remembers.", "Grow, endure, return.", "Tread lightly.",
    "Leave it greener than you found it.", "Rest is part of the cycle." },
  DEATHKNIGHT = { "Death was only the start.", "Nothing left to fear.", "Cold hands, clear head.", "Endure.",
    "Mercy is for the living.", "Finish what you start." },
}
W.RACE_MOTTO = {
  Human = { "Hold what's ours.", "For hearth and home.", "We've rebuilt before.", "Every harvest is earned.",
    "Keep the walls standing.", "Do the work in front of you." },
  Dwarf = { "Stone endures.", "Dig deep.", "A promise is iron.", "Never leave a kinsman behind.",
    "Strike while it's hot.", "Measure the stone before you cut it." },
  Gnome = { "There's always a better way.", "Fix it, then fix it better.", "Size is just a measurement.",
    "Every failure is data.", "Gnomeregan will be ours again.", "Try it again, carefully." },
  NightElf = { "Elune guide my path.", "The forest remembers.", "Patience outlasts everything.", "Walk softly under the moon.",
    "Guard the trees, and they'll guard you.", "What is lost can be grown again." },
  Orc = { "Strength and honour.", "Blood and thunder.", "Never again in chains.", "Honour the ancestors.",
    "Earn your place.", "Fight with honour or not at all." },
  Troll = { "Respect da loa.", "Spirits guide us.", "Stay sharp, stay alive.", "Every hunt be a lesson.",
    "Darkspear never die.", "Patience, mon." },
  Tauren = { "Walk with the Earth Mother.", "The plains provide.", "Strength in gentleness.", "Take only what the land can spare.",
    "Honour those who walked before.", "The wind carries every word." },
  Scourge = { "We serve no one.", "Our will is our own.", "Remember Lordaeron.", "No master but ourselves.",
    "The living forget. We don't.", "Trust the dark." },
  Goblin = { "Time is money.", "Never pay full price.", "Profit first, questions later.", "A deal's a deal.",
    "Always read the contract.", "If it blows up, it was a prototype." },
}
W.RACE_MOTTO.Undead = W.RACE_MOTTO.Scourge

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
  PALADIN = { "To be worthy of the Light {they} carr{ies}.", "To stand between the innocent and the dark." },
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

-- Rank ladders by class, one rank per ten levels: what every race and faction shares, when
-- no ladder below is more particular. (Lost in 0.14.0, which left a human warlock or a
-- dwarf rogue with no ladder at all, and their story fields unwritten.)
W.RANKS = {
  WARRIOR = { "Recruit", "Militia", "Soldier", "Sergeant", "Veteran", "Battle-Hardened", "Hardened Veteran" },
  PALADIN = { "Initiate", "Squire", "Knight", "Templar", "Crusader", "Justicar", "Elder Templar" },
  HUNTER = { "Novice", "Tracker", "Ranger", "Pathfinder", "Stalker", "Huntmaster", "Master Hunter" },
  ROGUE = { "Cutpurse", "Footpad", "Thief", "Shadow", "Blade", "Nightblade", "Master Assassin" },
  PRIEST = { "Acolyte", "Initiate", "Deacon", "Priest", "Confessor", "Senior Cleric", "Elder Cleric" },
  SHAMAN = { "Initiate", "Seer", "Spirit-Speaker", "Stormcaller", "Farseer", "Elder Farseer", "Elder Shaman" },
  MAGE = { "Apprentice", "Novice", "Adept", "Magus", "Sorcerer", "Arcanist", "Master Arcanist" },
  WARLOCK = { "Initiate", "Occultist", "Summoner", "Shadowcaster", "Diabolist", "Dreadcaller", "Master Diabolist" },
  DRUID = { "Initiate", "Neophyte", "Grove Warden", "Wild Walker", "Shapeshifter", "Elder Druid", "Wildkeeper" },
  default = { "Initiate", "Apprentice", "Journeyman", "Adept", "Expert", "Master", "Old Hand" },
}

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
  Orc = { "Heavy-jawed and thick through the shoulders, with jutting tusks.", "Massive shoulders, a heavy brow and jutting tusks." },
  Troll = { "Tall and lanky, with long tusks and longer ears.", "Loose-limbed and hunched, tusks curving up past a wide grin." },
  Tauren = { "Enormous and calm, horned and hoofed, with gentle eyes.", "A towering bulk of fur and muscle, crowned with horns." },
  Scourge = { "Rotting flesh stretched over bone, with a jaw that doesn't quite close.", "Gaunt, eyes burning a cold yellow in a ruined face." },
}

-- What a class carries that marks it out.
W.CLASS_LOOK = {
  WARRIOR = { "Carries {their} {mainhand} the way other people carry a walking stick." },
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
  SHAMAN = { uneasy = { "Frowning at the restless spirits of this place." }, ease = { "Calm and settled, at home in this place." }, angry = { "Very still, and the stillness isn't calm." } },
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
local function addTo(into, t)
  for k, v in pairs(t) do
    into[k] = into[k] or {}
    for _, line in ipairs(v) do table.insert(into[k], line) end
  end
end
local function more(race, t) W.RACE_TELLS[race] = W.RACE_TELLS[race] or {}; addTo(W.RACE_TELLS[race], t) end
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
local function moreClass(class, t) W.CLASS_TELLS[class] = W.CLASS_TELLS[class] or {}; addTo(W.CLASS_TELLS[class], t) end
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
  { max = 400, word = "Comfortable", flair = "These days {they're} comfortable, with enough coin put by not to worry about it.", pouch = "{their} {pouch} clinks when {they} walk{s}" },
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
  { max = 2, text = "Everything {they} wear{s} is well kept" },
}

---------------------------------------------------------------------------
-- More ways each race shows a mood. Face, voice and posture only: nothing they'd have to
-- be holding or wearing, and nothing a player can customise (hair, beards, skin).
---------------------------------------------------------------------------
more("Human", {
  weary = { "Rolls {their} neck, stiff from the road.", "Moves like a farmhand at the end of harvest." },
  ease = { "Easy and open-faced, like a Sunday in Goldshire.", "Relaxed, in the plain, comfortable way of Elwynn folk." },
  angry = { "Red in the face and speaking through {their} teeth.", "Face set like a soldier's before a charge." },
  tense = { "Stands like a guardsman on watch, feet planted.", "Watching the road the way Westfall folk learned to." },
  sorrowful = { "Quiet and red-eyed, the way people grieve in Stormwind: privately." },
  wonder = { "Gawping like a country cousin come to the city.", "Taking it all in, the way a farm-born traveller does." },
  proud = { "Stands straight, like a recruit at muster." },
  homecoming = { "Breathes easier among the oaks and the farm smells." },
  sociable = { "Friendly as a tavern-keeper, and just as chatty." },
  frustrated = { "Sighs, and rubs the bridge of {their} nose." },
  determined = { "Jaw set, the stubborn Lordaeron kind of set." },
})
more("Dwarf", {
  tense = { "Planted like a boulder, ready to be moved by nothing.", "Squinting hard at the dark, muttering about tunnels." },
  uneasy = { "Grumbling, and doesn't like how quiet it's got.", "Shifting {their} weight, far from good stone." },
  sorrowful = { "Rumbles a low dwarven dirge under {their} breath." },
  sociable = { "Booming greetings to all and sundry.", "Clapping shoulders and asking everyone's name." },
  proud = { "Chest puffed out like a forge bellows." },
  frustrated = { "Grumbling in Dwarven, none of it polite." },
  homecoming = { "Glad to smell forge-smoke and snow again." },
  determined = { "Has dug in, and will not be argued out of it." },
  triumphant = { "Roaring with laughter and calling for a round." },
  worried = { "Grumbling about prices like a true Ironforge merchant." },
  fed = { "Contented, the way only a well-fed dwarf can be." },
  lonely = { "Quiet, for a dwarf, which is still louder than most." },
})
more("Gnome", {
  intrigued = { "Muttering numbers, eyes unfocused, working something out.", "Ears twitching as an idea takes shape." },
  tense = { "Ears straight up, on the alert for anything that clanks." },
  merry = { "Giggling, and a full head shorter than everyone laughing with {them}." },
  sociable = { "Chattering away, happy to explain anything to anyone." },
  frustrated = { "Muttering about bad design and worse luck." },
  sorrowful = { "Ears drooping and quiet, thinking of Gnomeregan." },
  proud = { "Standing as tall as a gnome can, which is not very." },
  fierce = { "Small, fast and furious, and nobody's laughing." },
  thrilled = { "Practically vibrating with excitement." },
  weary = { "Dragging {their} feet, ears flat with tiredness." },
  determined = { "Lips pressed tight, ears forward. Problem identified; solving it." },
})
more("NightElf", {
  tense = { "Utterly still, ears turned to every sound.", "Silver eyes narrowed, as still as a hunting cat." },
  sorrowful = { "Ears low, silver eyes dim with an old grief." },
  merry = { "Laughing softly, a rare and musical sound." },
  devout = { "Face lifted, as if feeling Elune's light." },
  fierce = { "Eyes blazing silver, poised like a Sentinel." },
  proud = { "Holding {themselves} with the old grace of the Kaldorei." },
  lonely = { "Distant, as if ten thousand years were all at once too long." },
  haunted = { "Ears twitching at voices only the old forests carry." },
  homecoming = { "Ears relaxed at last, under the great boughs." },
  frustrated = { "Ears flattening, patience fraying for once." },
  intrigued = { "Head tilted, silver eyes thoughtful." },
})
more("Orc", {
  tense = { "Lip curled over the tusks, ready.", "Head low, nostrils flaring, watching." },
  fierce = { "Grinning around the tusks, ready to taste battle.", "Rolling massive shoulders, blood up." },
  proud = { "Standing tall with the pride of the Horde." },
  sorrowful = { "Quiet and grim, mourning the orc way: without words." },
  sociable = { "A gruff nod and a gruffer greeting, but meant warmly." },
  triumphant = { "Thumping {their} chest, tusks bared in a grin." },
  frustrated = { "Snorting through the tusks, short on patience." },
  determined = { "Brow lowered, tusks set. Nothing will turn {them} aside." },
  wonder = { "Peering about, grudgingly impressed." },
  lonely = { "Silent as a lone wolf." },
  homecoming = { "Sniffing the dry red air of home, satisfied." },
})
more("Troll", {
  tense = { "Crouched low, long arms loose and ready." },
  weary = { "Slouching even lower than usual, mon.", "Long arms dangling, eyes half-closed." },
  sociable = { "Grinning, full of jokes and hard to understand." },
  fierce = { "Tusks bared, eyes bright, ready for da hunt." },
  frustrated = { "Hissing curses in Zandali." },
  haunted = { "Tusks clacking, listening to whispers from da loa." },
  sorrowful = { "Quiet, long ears drooping." },
  proud = { "Standing tall, a proud Darkspear." },
  devout = { "Murmuring softly to da loa." },
  intrigued = { "Grinning slowly, as if da spirits just told a secret." },
  homecoming = { "Loose and easy, back among da Darkspear." },
})
more("Tauren", {
  tense = { "Hooves planted, horns lowered, watchful." },
  sorrowful = { "Head bowed low, rumbling a mourning song." },
  merry = { "A deep, booming laugh, and a friendly snort." },
  devout = { "Eyes closed, breathing deep, at peace with the Earth Mother." },
  fierce = { "Pawing the ground, horns forward.", "Breathing like a bellows, ready to charge." },
  proud = { "Standing tall, horns high, the pride of the plains." },
  sociable = { "Gentle and warm, rumbling a greeting." },
  determined = { "Slow, steady and unstoppable as a kodo." },
  frustrated = { "Snorting loudly, ears pinned back." },
  homecoming = { "Ears soft and easy, back where the grass is long." },
  lonely = { "Quiet as the open plain." },
})
more("Scourge", {
  tense = { "Jaw clenched, joints locked, ready to move." },
  uneasy = { "Head twitching at every sound, eyes narrowed." },
  sorrowful = { "Stares at nothing, as if mourning someone {they} can no longer name." },
  fierce = { "Hissing through ruined teeth, eager for the fight." },
  proud = { "Standing upright and defiant, free of the Lich King's will." },
  sociable = { "Hoarse and rasping, but surprisingly chatty." },
  frustrated = { "A dry, rattling sigh." },
  determined = { "Unblinking. The dead don't tire, and don't give up." },
  haunted = { "Twitches, as if a voice from the old life spoke." },
  lonely = { "Silent and still, the way only the dead can wait." },
  homecoming = { "Settled, as much as the dead ever settle, among the Forsaken." },
  triumphant = { "A rasping laugh, cold eyes glowing brighter." },
})

---------------------------------------------------------------------------
-- More ways each class shows a mood.
---------------------------------------------------------------------------
moreClass("WARRIOR", {
  tense = { "Feet set wide, ready for the charge.", "Holding {their} {shield} up and watching." },
  triumphant = { "Grinning, battle-stained and proud of it." },
  proud = { "Stands like a soldier at review." },
  frustrated = { "Cracking {their} knuckles, glaring." },
  uneasy = { "Hand drifting toward {their} {mainhand} at every noise." },
  wounded = { "Hurt, and acting like it's nothing." },
  determined = { "Squares {their} shoulders like it's another march." },
  weary = { "Moves like someone who has held a line all day." },
})
moreClass("PALADIN", {
  tense = { "Steady, watchful, a guardian on duty." },
  sorrowful = { "Head bowed, praying for the fallen." },
  proud = { "Stands tall, an upright servant of the Light." },
  uneasy = { "Frowning, sensing something unholy." },
  fierce = { "Eyes bright, ready to bring the Light to bear." },
  determined = { "Calm and set, as if sworn to it." },
  weary = { "Tired, but still holding {themselves} upright." },
  devout = { "Lips moving in a soldier's prayer." },
})
moreClass("HUNTER", {
  tense = { "Still as a hunter in a blind, watching." },
  sorrowful = { "Quiet, with {pet} pressed close against {their} legs." },
  merry = { "Laughing, with {pet} close at heel." },
  weary = { "Tired, but still reading every track." },
  lonely = { "Alone except for {pet}, and seems fine with that." },
  angry = { "Eyes narrowed, the hunter's patience gone." },
  determined = { "On the trail, and won't leave it." },
  intrigued = { "Studying tracks with a frown." },
})
moreClass("ROGUE", {
  weary = { "Even tired, never fully off guard." },
  sociable = { "Charming and talkative, eyes never still." },
  merry = { "Laughing easily, one eye always on the door." },
  downcast = { "Withdrawn, keeping to the corners." },
  intrigued = { "Quiet and curious, filing away every detail." },
  worried = { "Eyes drifting to other people's coin." },
  thrilled = { "A quick, crooked grin about a good haul." },
  determined = { "Quiet and focused, already planning the next step." },
})
moreClass("PRIEST", {
  weary = { "Tired from tending others, but still kind." },
  downcast = { "Quiet, praying for comfort." },
  shaken = { "Hands clasped tight to stop them shaking." },
  tense = { "Calm, but ready with a prayer." },
  haunted = { "Murmuring wards against the dark." },
  righteous = { "Serene, as if the Light approves." },
  sociable = { "Gentle, ready with a kind word." },
  conflicted = { "Praying for guidance, frowning." },
})
moreClass("SHAMAN", {
  tense = { "Still, listening to the wind." },
  fierce = { "Eyes bright as lightning." },
  sorrowful = { "Quiet, as if the spirits mourn too." },
  devout = { "Murmuring to the spirits of the land." },
  weary = { "Tired, the spirits quiet for now." },
  intrigued = { "Head tilted, listening to the elements." },
  haunted = { "Frowning at restless voices on the wind." },
  merry = { "Laughing like a spring storm." },
})
moreClass("MAGE", {
  tense = { "Fingers twitching, a spell half-formed." },
  uneasy = { "Frowning at strange currents in the air." },
  downcast = { "Withdrawn, lost in gloomy calculation." },
  frustrated = { "Muttering about incompetence." },
  merry = { "Laughing at jokes too clever for the room." },
  sociable = { "Talking at length about something arcane." },
  proud = { "A scholar's satisfied smile." },
  determined = { "Calculating, and certain of the answer." },
})
moreClass("WARLOCK", {
  tense = { "Cold eyes watchful, a dark word ready." },
  uneasy = { "Frowning, as if sensing a rival presence." },
  weary = { "Pale and tired, the price of power." },
  merry = { "A dry, unsettling laugh." },
  intrigued = { "A thin, curious smile." },
  proud = { "Smug, and not hiding it." },
  determined = { "Cold and certain, eyes on what {they} want{s}." },
  sorrowful = { "Cold, quiet grief, hard to read." },
})
moreClass("DRUID", {
  tense = { "Still as prey that knows it's watched." },
  fierce = { "Eyes bright and wild, more beast than person." },
  sorrowful = { "Quiet, grieving like the wounded land." },
  merry = { "Laughing freely, like the wind in the trees." },
  weary = { "Tired, slow as a bear before winter." },
  devout = { "Quiet and reverent, close to nature." },
  intrigued = { "Watching the land with keen interest." },
  homecoming = { "Calm, back among the green." },
})

---------------------------------------------------------------------------
-- Currently: how they're getting about, with the place filled in. {where} is the zone,
-- {place} the spot ("the Lion's Pride Inn, Elwynn Forest"), {around} "around <spot>" or
-- "in <zone>", {beast} the flight's mount, {mount} what they ride.
---------------------------------------------------------------------------
W.TRAVEL = {
  ghost = { "a restless spirit drifting near {where}", "somewhere between this world and the next, near {where}",
    "a wandering ghost at the edge of {where}", "a spirit looking for the way back, near {where}" },
  taxi = { "on the back of {beast} over {where}", "flying {beast} over {where}", "high over {where} on {beast}",
    "watching {where} pass below from the back of {beast}" },
  dungeon = { "deep inside {where}", "delving into {where}", "somewhere in the depths of {where}", "picking a way through {where}" },
  battleground = { "fighting for the banner in {where}", "in the thick of the fighting at {where}", "under arms at {where}" },
  inn = { "resting at {place}", "staying at {place}", "lodging at {place}", "taking a room at {place}" },
  town = { "about the streets of {place}", "passing through {place}", "walking the streets of {place}", "in town at {place}" },
  stealth = { "keeping to the shadows {around}", "unseen {around}", "slipping quietly through the shadows {around}" },
  swimming = { "wading through the waters of {where}", "swimming in the waters of {where}", "soaked to the skin in {where}" },
  flying = { "flying over {where}", "high in the air above {where}" },
  mounted = { "{mount} through {where}", "{mount} across {where}", "{mount} on the roads of {where}" },
  road = { "on the road {around}", "out {around}", "travelling {around}", "abroad {around}", "on the move {around}" },
}

W.TIME_OF_DAY = {
  night = { "under the stars", "after dark", "by moonlight", "in the dark hours" },
  dawn = { "at first light", "as the sun comes up", "in the early morning" },
  dusk = { "as the light goes", "at dusk", "as evening falls" },
}

-- Adds lines to a word list (a single phrase becomes a list).
local function extend(t, key, list)
  local cur = t[key]
  if type(cur) == "string" then cur = { cur } end
  cur = cur or {}
  for _, l in ipairs(list) do cur[#cur + 1] = l end
  t[key] = cur
end
local function extendAll(t, more) for k, list in pairs(more) do extend(t, k, list) end end

extendAll(W.ZONE_FLAVOR, {
  ["Elwynn Forest"] = { "under the oaks of Elwynn Forest", "among the fields and farmsteads of Elwynn" },
  ["Westfall"] = { "among the scarecrows and dry fields of Westfall", "on the windy coast road of Westfall" },
  ["Redridge Mountains"] = { "along the shores of Lake Everstill", "on the red-rock trails above Lakeshire" },
  ["Duskwood"] = { "under the twisted boughs of Duskwood", "in the endless twilight of Duskwood" },
  ["Stranglethorn Vale"] = { "under the thick canopy of Stranglethorn", "among the overgrown troll ruins of Stranglethorn" },
  ["Dun Morogh"] = { "on the snowy slopes of Dun Morogh", "in the cold, clear air of Dun Morogh" },
  ["Loch Modan"] = { "in the shadow of the great dam of Loch Modan", "on the lakeside roads of Loch Modan" },
  ["Wetlands"] = { "in the rain and reeds of the Wetlands", "on the boggy roads of the Wetlands" },
  ["Arathi Highlands"] = { "across the grassy uplands of Arathi", "near the broken walls of Stromgarde" },
  ["Hillsbrad Foothills"] = { "among the farms of Hillsbrad", "on the green hills of Hillsbrad" },
  ["Alterac Mountains"] = { "in the snowy Alterac Mountains", "on the windswept heights of Alterac" },
  ["The Hinterlands"] = { "in the tangled hills of the Hinterlands", "among the troll ruins of the Hinterlands" },
  ["Silverpine Forest"] = { "on the shadowed roads of Silverpine", "among the dark pines of Silverpine" },
  ["Tirisfal Glades"] = { "under the grey skies of Tirisfal", "among the abandoned farms of Tirisfal" },
  ["Western Plaguelands"] = { "on the plague-scarred roads of the Western Plaguelands", "among the sickly fields of the Western Plaguelands" },
  ["Eastern Plaguelands"] = { "under the poisoned skies of the Eastern Plaguelands", "among the dead lands of the east" },
  ["Badlands"] = { "on the cracked earth of the Badlands", "in the dusty wastes of the Badlands" },
  ["Searing Gorge"] = { "under the ash and smoke of the Searing Gorge", "on the cinder roads of the Searing Gorge" },
  ["Burning Steppes"] = { "under the red sky of the Burning Steppes", "among the ash fields of the Burning Steppes" },
  ["Swamp of Sorrows"] = { "in the murky waters of the Swamp of Sorrows", "among the drowned trees of the Swamp of Sorrows" },
  ["Blasted Lands"] = { "under the blood-red sky of the Blasted Lands" },
  ["Deadwind Pass"] = { "under the grey sky of Deadwind Pass", "in the cold wind of Deadwind Pass" },
  ["Durotar"] = { "under the hot sun of Durotar", "among the rocky hills of Durotar" },
  ["Mulgore"] = { "on the rolling grasslands of Mulgore", "under the wide sky of Mulgore" },
  ["The Barrens"] = { "on the dusty plains of the Barrens", "under the hot sun of the Barrens" },
  ["Teldrassil"] = { "among the ancient roots of Teldrassil", "in the green hush of Teldrassil" },
  ["Darkshore"] = { "on the cold shore of Darkshore", "among the ruins along Darkshore" },
  ["Ashenvale"] = { "among the giant trees of Ashenvale", "on the shadowed trails of Ashenvale" },
  ["Stonetalon Mountains"] = { "among the peaks of Stonetalon", "on the rocky paths of Stonetalon" },
  ["Desolace"] = { "on the bone-strewn plains of Desolace", "in the grey desert of Desolace" },
  ["Thousand Needles"] = { "in the dusty canyons of Thousand Needles", "beneath the tall rock spires of Thousand Needles" },
  ["Dustwallow Marsh"] = { "in the swampy fens of Dustwallow Marsh", "under the hanging moss of Dustwallow" },
  ["Feralas"] = { "among the ancient ruins of Feralas", "in the green, rainy wilds of Feralas" },
  ["Tanaris"] = { "under the hot desert sun of Tanaris", "in the dry heat of Tanaris" },
  ["Un'Goro Crater"] = { "among the giant ferns of Un'Goro", "in the hot, steaming crater of Un'Goro" },
  ["Felwood"] = { "under the sickly canopy of Felwood", "on the poisoned paths of Felwood" },
  ["Azshara"] = { "among the red-leafed trees of Azshara", "near the ruined shores of Azshara" },
  ["Winterspring"] = { "in the cold, snowy valleys of Winterspring", "under the frosted trees of Winterspring" },
  ["Moonglade"] = { "by the quiet lake of Moonglade", "in the moonlit groves of Moonglade" },
  ["Silithus"] = { "among the dunes and hives of Silithus", "in the hot winds of Silithus" },
})

extendAll(W.ACTIVITY, {
  mail = { "collecting the post in {place}", "going through {their} letters in {place}" },
  bank = { "at the bank in {place}", "seeing to {their} vault in {place}" },
  auction = { "browsing the auction house in {place}", "bidding at the auction house in {place}" },
  merchant = { "trading with a merchant in {place}", "doing business with a trader in {place}" },
  trainer = { "training in {place}", "studying under a master in {place}" },
  fishing = { "casting a line in {place}", "waiting for a bite in {place}" },
  eating = { "having a bite to eat in {place}", "taking a meal in {place}" },
  drinking = { "having a drink in {place}", "stopping for a drink in {place}" },
  flightmaster = { "booking a flight out of {place}", "at the flight master in {place}" },
  talk = { "chatting with {who} in {place}", "in conversation with {who} in {place}" },
  reading = { "poring over {what} in {place}", "lost in {what}, in {place}" },
  duel = { "testing {their} skill in a duel in {place}" },
  away = { "miles away in {their} head, in {place}", "daydreaming in {place}" },
  sitting = { "resting {their} feet in {place}", "sitting a while in {place}" },
  sleeping = { "fast asleep in {place}", "sleeping in {place}" },
  dancing = { "dancing happily in {place}" },
  hearth = { "going home from {place}", "returning home from {place}" },
  portal = { "opening a way to {dest} in {place}", "weaving a portal to {dest} in {place}" },
  summoning = { "leading a summoning ritual in {place}" },
  shadowmeld = { "fading into the shadows in {place}", "hidden in the shadows in {place}" },
  cannibalize = { "feeding on the fallen in {place}" },
  mining = { "mining ore in {place}" },
  herbs = { "collecting herbs in {place}", "searching for herbs in {place}" },
  skinning = { "skinning a beast in {place}", "taking hides in {place}" },
  disenchant = { "drawing the magic out of an old trinket in {place}" },
  lockpick = { "working at a lock in {place}" },
  pickpocket = { "picking pockets in {place}" },
})

extendAll(W.CRAFT, {
  Alchemy = { "mixing potions", "brewing something in a bubbling flask" },
  Blacksmithing = { "working metal at the forge", "beating hot iron into shape" },
  Leatherworking = { "stitching leather", "cutting and tooling leather" },
  Tailoring = { "sewing", "cutting cloth" },
  Engineering = { "fiddling with gears and springs", "building something that ticks" },
  Enchanting = { "weaving enchantments", "working arcane runes" },
  Cooking = { "preparing a meal", "stirring a pot" },
  ["First Aid"] = { "preparing bandages", "seeing to supplies for the wounded" },
  Jewelcrafting = { "setting stones" },
  Mining = { "melting ore down at the smelter" },
  Poisons = { "brewing poisons with steady hands" },
})

extendAll(W.PET, {
  HUNTER = { "{pet} close at {their} side", "{pet} the {kind} never far away" },
  WARLOCK = { "{pet} the {kind} hovering nearby", "{pet} following at a distance" },
})

-- Dungeons, raids and city districts get a second and third way of saying it.
extendAll(W.INSTANCE_FLAVOR, {
  ["The Deadmines"] = { "among the Defias in the Deadmines", "in the mines under Moonbrook" },
  ["Wailing Caverns"] = { "among the moaning caves of the Wailing Caverns" },
  ["Shadowfang Keep"] = { "in the haunted keep of Shadowfang", "beneath the howling towers of Shadowfang Keep" },
  ["Ragefire Chasm"] = { "in the hot tunnels under Orgrimmar" },
  ["Blackfathom Deeps"] = { "in the sunken halls of Blackfathom Deeps" },
  ["The Stockade"] = { "among the rioting prisoners of the Stockade" },
  ["Gnomeregan"] = { "among the radiation and ruin of Gnomeregan" },
  ["Razorfen Kraul"] = { "in the thorny tunnels of the quilboar" },
  ["Scarlet Monastery"] = { "among the fanatics of the Scarlet Monastery", "in the red halls of the Scarlet Crusade" },
  ["Razorfen Downs"] = { "among the dead quilboar of Razorfen Downs" },
  ["Uldaman"] = { "among the stone keepers of Uldaman" },
  ["Zul'Farrak"] = { "on the hot sands of Zul'Farrak" },
  ["Maraudon"] = { "in the poisoned caverns of Maraudon" },
  ["The Temple of Atal'Hakkar"] = { "in the flooded halls of the Sunken Temple" },
  ["Blackrock Depths"] = { "in the burning halls of Blackrock Depths" },
  ["Blackrock Spire"] = { "among the orc clans of Blackrock Spire" },
  ["Dire Maul"] = { "in the overgrown ruins of Dire Maul" },
  ["Stratholme"] = { "among the undead in the ruins of Stratholme" },
  ["Scholomance"] = { "in the dark school of Scholomance" },
  ["Molten Core"] = { "deep in the fiery heart of Blackrock" },
  ["Onyxia's Lair"] = { "in the dragon's den of Onyxia" },
  ["Blackwing Lair"] = { "among the black dragons atop Blackrock" },
  ["Zul'Gurub"] = { "in the jungle city of the Gurubashi" },
  ["Ruins of Ahn'Qiraj"] = { "among the broken walls of Ahn'Qiraj" },
  ["Temple of Ahn'Qiraj"] = { "in the dark heart of Ahn'Qiraj" },
  ["Naxxramas"] = { "in the cold halls of Naxxramas" },
})
extendAll(W.CITY_FLAVOR, {
  ["Trade District"] = { "among the merchants of Stormwind's Trade District" },
  ["Cathedral Square"] = { "in the shadow of Stormwind Cathedral" },
  ["Old Town"] = { "in the narrow lanes of Old Town" },
  ["Dwarven District"] = { "among the anvils of Stormwind's Dwarven District" },
  ["Mage Quarter"] = { "in the quiet lanes of the Mage Quarter" },
  ["Stormwind Harbor"] = { "on the busy docks of Stormwind Harbor" },
  ["The Commons"] = { "among the crowds of the Ironforge Commons" },
  ["The Great Forge"] = { "by the great anvil of Ironforge" },
  ["Tinker Town"] = { "among the gnomes of Tinker Town" },
  ["The Military Ward"] = { "among the soldiers of Ironforge's Military Ward" },
  ["The Mystic Ward"] = { "among the scholars of the Mystic Ward" },
  ["Hall of Explorers"] = { "among the explorers of Ironforge" },
  ["Craftsmen's Terrace"] = { "among the craftsfolk of Darnassus" },
  ["Temple of the Moon"] = { "beneath the moonlight of Elune's temple" },
  ["Tradesmen's Terrace"] = { "among the merchants of Darnassus" },
  ["Warrior's Terrace"] = { "among the Sentinels of Darnassus" },
  ["Cenarion Enclave"] = { "in the green hush of the Cenarion Enclave" },
  ["Valley of Strength"] = { "in the busy heart of Orgrimmar" },
  ["The Drag"] = { "in the narrow alleys of the Drag" },
  ["Valley of Honor"] = { "among the training grounds of the Valley of Honor" },
  ["Valley of Wisdom"] = { "near Grommash Hold in the Valley of Wisdom" },
  ["Valley of Spirits"] = { "among the shamans of the Valley of Spirits" },
  ["Cleft of Shadow"] = { "in the shadowed tunnels of the Cleft" },
  ["Elder Rise"] = { "among the Elders on Elder Rise" },
  ["Spirit Rise"] = { "among the spirit-talkers of Spirit Rise" },
  ["Hunter Rise"] = { "among the hunters of Thunder Bluff" },
  ["Lower Rise"] = { "on the lower terraces of Thunder Bluff" },
  ["The Trade Quarter"] = { "among the Forsaken merchants of the Undercity" },
  ["The Apothecarium"] = { "among the alchemists of the Apothecarium" },
  ["The Magic Quarter"] = { "among the Forsaken mages of the Magic Quarter" },
  ["The War Quarter"] = { "among the soldiers of the War Quarter" },
  ["The Rogues' Quarter"] = { "among the rogues of the Undercity" },
})

---------------------------------------------------------------------------
-- More ambitions, builds and looks.
---------------------------------------------------------------------------
extendAll(W.AMBITIONS, {
  WARRIOR = { "To never lose a comrade on {their} watch.", "To master every weapon worth holding.", "To be worth the trust of whoever stands beside {them}." },
  PALADIN = { "To bring the Light where it's needed most.", "To prove {their} faith in deed, not word.", "To never turn away anyone who needs help." },
  HUNTER = { "To find a companion worthy of the wild.", "To never miss a shot that matters.", "To see every corner of the wilds." },
  ROGUE = { "To never be caught.", "To be the best at what no one admits doing.", "To always have a way out." },
  PRIEST = { "To heal more than {they} harm{s}.", "To find answers in faith.", "To be a light in the dark for others." },
  SHAMAN = { "To heal the wounds of the land.", "To hear the elements clearly.", "To guide others to the spirits." },
  MAGE = { "To master a school of magic completely.", "To push the boundaries of the arcane.", "To discover something no one else knows." },
  WARLOCK = { "To bend the darkness to {their} will.", "To command demons without fear.", "To understand the shadow, completely." },
  DRUID = { "To protect the wild from those who'd harm it.", "To keep the balance of nature.", "To be one with every living thing." },
  default = { "To see the world.", "To make something of {themselves}." },
})
extendAll(W.PHYSIQUE, {
  strength = { "powerfully built", "brawny, with a heavy tread" },
  agility = { "quick and supple", "nimble, light on {their} feet" },
  stamina = { "hardy and enduring", "built to last" },
  intellect = { "keen-eyed and thoughtful", "with a sharp, studious face" },
  spirit = { "serene and steady", "calm-faced and unhurried" },
})
extendAll(W.RACE_LOOK, {
  Human = { "Human, of ordinary height and build.", "A human, much like any other at first glance." },
  Dwarf = { "Short and stout, built like a barrel.", "Broad and squat, with a heavy step." },
  Gnome = { "Barely waist-high, with large bright eyes.", "Small and quick, with oversized ears." },
  NightElf = { "Tall and lean, with pointed ears and glowing eyes.", "Graceful and long-limbed, eyes shining silver." },
  Orc = { "Broad and powerful, with a heavy jaw and tusks.", "A big, heavily muscled orc." },
  Troll = { "Long-limbed and lean, tusks curving up.", "Lanky and stooped, with long arms." },
  Tauren = { "Huge and horned, with broad hooves.", "A towering tauren, horned and heavy." },
  Scourge = { "Thin and decayed, with glowing eyes.", "Pale, rotting and gaunt." },
})
extendAll(W.CLASS_LOOK, {
  WARRIOR = { "Stands like someone used to holding a line." },
  PALADIN = { "Holds {their} {mainhand} like a sworn guardian.", "Carries {their} {shield} as if it were part of {them}." },
  HUNTER = { "Watches everything with a tracker's eye." },
  ROGUE = { "Light on {their} feet, always watching." },
  PRIEST = { "Calm-eyed and gentle in manner." },
  SHAMAN = { "Carries {their} {mainhand} with quiet confidence." },
  MAGE = { "Has a scholar's watchful eyes." },
  WARLOCK = { "Cold-eyed, and watches people carefully." },
  DRUID = { "Moves lightly, and stops often to look and listen." },
})
local FESTIVAL_MORE = {
  winterveil = { adj = { "Jolly", "Merry with the season" }, tells = { "Rosy-cheeked and cheerful.", "Bright-eyed with the season's cheer." } },
  hallowsend = { adj = { "Mischievous" }, tells = { "Grinning wickedly, as if planning a trick." } },
  love = { adj = { "Starry-eyed" }, tells = { "Smiling softly at nothing." } },
  midsummer = { adj = { "Sunny and warm" }, tells = { "Warm-faced and cheerful." } },
  brewfest = { adj = { "Ruddy and cheerful" }, tells = { "Ruddy-cheeked and laughing." } },
  lunar = { adj = { "Reflective" }, tells = { "Thoughtful, with a quiet respect for those who came before." } },
  noblegarden = { adj = { "Light-hearted" }, tells = { "Light-hearted and cheerful." } },
}
for k, m in pairs(FESTIVAL_MORE) do
  if W.FESTIVALS[k] then extend(W.FESTIVALS[k], "adj", m.adj); extend(W.FESTIVALS[k], "tells", m.tells) end
end
extendAll(W.WEEK_TONE, {
  hard = { "These have been hard days.", "The last stretch has worn {them} down." },
  good = { "These have been good days.", "The last stretch has treated {them} well." },
})

---------------------------------------------------------------------------
-- Ways of saying the facts the glances and About report. One is picked per event (or per
-- character), so two characters, or the same one on another day, don't read alike. The
-- facts stay the same: {who}, {t}, {place}, {n} and the rest are filled in from the game.
---------------------------------------------------------------------------
W.SAY = {
  -- Lately
  thread_stirring = { "Has been asking around about {t}.", "Has caught wind of {t}.", "Has started looking into {t}.",
    "Has heard enough about {t} to want to know more.", "Is only beginning to get the measure of {t}." },
  thread_unfolding = { "Is caught up in {t}.", "Can't leave {t} alone.", "Is in the middle of {t}.",
    "Is in deep with {t} now.", "Has got further into {t} than {they} meant to." },
  thread_resolved = { "Saw {t} through to the end.", "Had a hand in settling {t}.", "Helped put {t} to rest.",
    "Is done with {t} at last.", "Has just seen the end of {t}." },
  thread_soured = { "Watched {t} go badly wrong.", "Was there when {t} went sour.", "Saw {t} turn out badly.",
    "Has seen {t} come to a bad end.", "Couldn't stop {t} going wrong." },
  boss = { "Was there when {who} fell{where}.", "Helped bring down {who}{where}.", "Stood in the fight that finished {who}{where}.",
    "Has just seen {who} beaten{where}.", "Was one of those who put an end to {who}{where}." },
  cleared = { "Has just come back up out of {place}.", "Is fresh out of {place}.", "Has only just climbed back out of {place}.",
    "Is back from {place}, and glad of the daylight.", "Came up out of {place} only lately." },
  fight = { "Fresh from a fight with {who}.", "Has just seen off {who}.", "Still breathing hard after a fight with {who}.",
    "Has only just finished with {who}.", "Got the better of {who} a moment ago." },
  fight_long = { "Fresh from a long, hard fight with {who}.", "Has just come through a long fight with {who}.",
    "Took a long time to put down {who}, and looks it.", "Has just won a long, grinding fight with {who}." },
  fight_close = { "Barely survived a fight with {who}.", "Came close to losing a fight with {who}.", "Only just got the better of {who}.",
    "Nearly went down to {who}, and knows it.", "Came out of a fight with {who} by the narrowest margin." },
  job = { "Just saw a job through: {q}{where}.", "Has just finished a job: {q}{where}.", "Has just wrapped up a job: {q}{where}.",
    "Has one less job to worry about: {q}{where}.", "Is newly done with a job: {q}{where}." },
  find = { "Recently found {item}{where}.", "Has just come by {item}{where}.", "Turned up {item}{where} lately.",
    "Came away with {item}{where} only lately.", "Has a new find: {item}{where}." },
  newzone = { "New to {zone}, and seeing it for the first time.", "Has only just arrived in {zone}.", "A newcomer to {zone}.",
    "Still finding {their} way around {zone}.", "Has not been in {zone} long." },
  talk = { "Was just talking {how}with {who}{where}.", "Has just been speaking {how}with {who}{where}.",
    "Has been talking {how}with {who}{where} just now.", "Spoke {how}with {who}{where} only a moment ago." },
  lastseen = { "Was last seen in conversation with {who}.", "Was last seen talking with {who}.",
    "Spent some time talking with {who} lately.", "Has spent time with {who} in the last day." },
  around = { "Has been around {where} lately.", "Has been spending time around {where}.", "Has been keeping to {where} lately.",
    "Has been seen about {where} these last days.", "Has mostly been around {where} these last days." },
  -- Company
  host = { "Marching with a host of {n}.", "One of a host of {n}.", "Part of a company {n} strong.",
    "Travelling in a great company, {n} strong.", "One of {n} under the same banner today." },
  party = { "Travelling with {party}.", "On the road with {party}.", "In the company of {party}.",
    "Keeping company with {party}.", "Sharing the road with {party}." },
  alone = { "Travels alone.", "Keeps to {themselves} on the road.", "Goes about alone.",
    "On {their} own for now.", "Makes {their} way alone, and seems used to it." },
  alone_reserved = { "Travels alone, and keeps conversations short.", "Travels alone, and says little.",
    "Keeps to {themselves}, and would rather it stayed that way.", "Alone on the road, and not looking for company." },
  pet_only = { "Travels with no one but {pet}{mood}.", "Has only {pet} for company{mood}.",
    "Alone on the road, apart from {pet}{mood}.", "Goes about with {pet} and nobody else{mood}." },
  -- Ambition and Marks
  nextrank = { "Working toward the rank of {rank}.", "Aims to rise to {rank}.", "Has {their} sights on the rank of {rank}.",
    "Means to rise to {rank} one day.", "Hopes to earn the rank of {rank} before long." },
  unfinished = { "Wants to get to the bottom of {t}.", "Means to see {t} through.", "Means to find out the truth of {t}.",
    "Won't rest easy until {t} is settled.", "Has unfinished business with {t}." },
  remarkable = { "{their} {item} is the first thing people notice.", "{their} {item} draws a second look.",
    "{their} {item} stands out at once.", "People look twice at {their} {item}.", "{their} {item} catches the eye before anything else." },
  plain = { "Gives little away at first glance.", "Hard to read at first glance.", "Nothing about {them} stands out at first.",
    "Easy to pass by without a second look.", "Ordinary enough at first sight." },
  -- About
  stories = { "Has stories about {list}", "Can tell a story or two about {list}", "Has tales to tell about {list}",
    "Knows a thing or two about {list}", "Could talk for a while about {list}" },
  friends = { "{name} counts {list} among {their} friends", "{name} is on good terms with {list}", "{name} has made friends of {list}",
    "{name} gets on well with {list}", "{name} is close to {list}" },
  rival = { "There is no love lost between {them} and {who}", "Is at odds with {who}", "Doesn't get on with {who}",
    "Has never seen eye to eye with {who}", "Has no time for {who}", "Is on poor terms with {who}" },
  delved = { "Has gone down into {list} and come back up", "Has been down into {list}, and come out again",
    "Has seen the inside of {list}", "Knows the dark of {list} at first hand" },
  bosses = { "Has helped bring down {n} named foes, the latest {who}", "Has been in at the end of {n} named foes, most recently {who}",
    "Has seen {n} named foes fall, {who} the latest", "Counts {n} named foes brought down, the last of them {who}" },
  rares = { "Has tracked down {n} rare beasts", "Has hunted down {n} rare beasts", "Has found and killed {n} rare beasts",
    "Has run {n} rare beasts to ground" },
  jobs = { "Has seen {n} jobs through for the people who asked", "Has done {n} jobs for the people who asked",
    "Has taken on and finished {n} jobs", "Has done {n} jobs for whoever needed them done" },
  crafts = { "Between roads {they're} {list}", "Off the road {they're} {list}", "By trade {they're} {list}",
    "Between journeys {they} work{s} as {list}", "When {they're} not travelling, {they're} {list}" },
  finds = { "Found {list}", "Has come by {list}", "Has turned up {list} on {their} travels", "Picked up {list} along the way",
    "Was lucky enough to come by {list}" },
  setout = { "{name} has only just set out, and hasn't been far from home yet",
    "{name} is new to the road, and hasn't been far from home yet",
    "{they've} not long set out", "It's early days on the road for {them}", "{they're} still new to the road" },
  home = { "Home these days is {inn}", "Calls {inn} home", "Has made {inn} {their} home", "{inn} is home for now",
    "Comes back to {inn} between roads" },
  lastplace = { "The last new place {they} reached was {place}", "Most recently reached {place}", "{place} is the newest land on {their} road",
    "Has lately reached {place}" },
  -- History: how a run of recent events opens, and how the older record does.
  when_near = { "In the last day or two", "Only in the last couple of days", "Just these past days", "Not two days ago",
    "Within the last couple of days" },
  when_week = { "Earlier this week", "In the past week", "A few days ago", "Some days back", "This past week" },
  when_lastweek = { "Last week", "The week before", "A week or so ago", "About a week back", "Something over a week ago" },
  when_fortnight = { "A couple of weeks ago", "Two weeks or so back", "Earlier in the month", "Some two weeks ago",
    "Two or three weeks back" },
  before = { "Before all that,", "Before that,", "Further back,", "Earlier on,", "Before any of this," },
  alongtheway = { "Along the way", "Over time", "On the road so far", "All told,", "Up to now", "In {their} time on the road" },
  -- Filling a sparse History
  rankso = { "Has risen as far as {rank}", "Has made it as far as the rank of {rank}", "Has reached the rank of {rank}",
    "{they've} come up as far as {rank}", "{they} stand{s} at the rank of {rank} for now", "Holds the rank of {rank}, for now" },
  keepsto = { "These days {they} keep{s} mostly to {zone}", "Lately {they've} been around {zone}", "For now {their} road runs through {zone}",
    "{they're} mostly to be found in {zone} lately", "Most days find {them} somewhere in {zone}" },
  -- Earned names: where the name came from, the saying that came with it, the others that
  -- stuck, and a name earned only lately (Lately).
  earned = { "{deed}. That's how {name} came to be called {nick}", "{deed}, and some have called {name} {nick} since",
    "{deed}. The name {nick} has stuck to {name} since", "{deed}. It's why {name} answers to {nick}",
    "{deed}, which is where the name {nick} comes from", "{deed}. Since then some call {name} {nick}" },
  saying = { "It's where {they} picked up the saying {motto}", "{they} came away from it with a saying: {motto}",
    "{they} took a saying from it: {motto}", "A saying came with it, too: {motto}", "It left {them} with a saying: {motto}" },
  othernames = { "Has been called {list} as well", "Also answers to {list}", "Other names have stuck too: {list}" },
  favspell = { "Reaches for {spell} more than any other {noun}", "{spell} is the {noun} {they} use{s} most",
    "Uses {spell} more often than any other {noun}" },
  newname = { "Has lately come to be called {nick}.", "Some have started calling {them} {nick}.",
    "Answers to {nick} now, a name earned only lately." },
}

---------------------------------------------------------------------------
-- Life on the road (Sources/Life.lua): fishing, crafts, gathering, duels, battles, money,
-- inns, flight masters, mounts, emotes, company, close calls. A block of its own, kept apart
-- from the lists above.
---------------------------------------------------------------------------
W.LIFE = {
  -- Fishing loot that is a fish without "Raw" in its name.
  FISH = { ["Oily Blackmouth"] = true, ["Firefin Snapper"] = true, ["Stonescale Eel"] = true, ["Deviate Fish"] = true,
    ["Darkclaw Lobster"] = true, ["Winter Squid"] = true, ["Summer Bass"] = true, ["Nightfin Snapper"] = true,
    ["Sunscale Salmon"] = true, ["Lightning Eel"] = true },
  -- What a trade's "You create" lines add up to, for History: "{they've} cooked {n} meals".
  MADE = {
    Cooking = "cooked {n} meals", ["First Aid"] = "wound {n} bandages", Tailoring = "sewn {n} pieces of cloth",
    Blacksmithing = "forged {n} pieces at the anvil", Leatherworking = "worked {n} pieces of leather",
    Alchemy = "brewed {n} potions and elixirs", Engineering = "built {n} contraptions",
    Enchanting = "made {n} things at the enchanter's trade", Jewelcrafting = "cut {n} gems and settings",
    Mining = "smelted {n} bars of metal", Poisons = "mixed {n} batches of poison",
  },
  GATHERED = { herbs = "picked {n} herbs", ore = "dug out {n} loads of ore and stone", hides = "taken {n} hides and strips of leather" },
  -- Habits for Personality, only once the counts back them.
  HABIT = {
    fish_many = { "Fishes whenever there's water nearby", "Rarely passes good water without casting a line",
      "Will stop to fish at almost any lake or river" },
    fish_some = { "Fishes when there's time for it", "Knows {their} way around a fishing line", "Has the patience for fishing" },
    cook = { "Does a lot of {their} own cooking", "Cooks often, and plenty of it", "Is rarely short of something {they've} cooked" },
    craft = { "Works at {their} trade whenever there's the chance", "Keeps {their} hands busy with {their} trade" },
    gather = { "Can't walk past a herb or a seam of ore without stopping", "Stops for every herb and seam of ore along the road" },
    duel_wins = { "Rarely turns down a duel, and mostly wins", "Takes up a duel readily, and usually comes out on top" },
    duel_losses = { "Takes on duels often, and loses more of them than {they} win{s}", "Keeps accepting duels {they} mostly lose{s}" },
    duel_some = { "Has a taste for duelling", "Enjoys a duel" },
    company = { "Seldom travels alone for long", "Is usually in company on the road", "Falls in with others easily" },
    alone = { "Keeps to {their} own company on the road", "Travels alone, as a rule" },
    inns = { "Has rested in more inns than most", "Knows a good many inns by now" },
    falls = { "Takes the quick way down from high places more often than is wise", "Has a habit of jumping before looking" },
    close = { "Has walked away from more bad fights than most", "Has a knack for surviving fights that go badly" },
    battles = { "Answers the call to battle often", "Is a familiar face on the battlefield" },
  },
  -- The emote a character uses most, as a habit (by the verb after "You ...").
  EMOTE = {
    wave = { "Waves at people a lot", "Is quick to wave" }, bow = { "Bows to people more than most do", "Is quick to bow" },
    laugh = { "Laughs easily and often", "Laughs a lot" }, cheer = { "Cheers loudly and often", "Is quick to cheer" },
    thank = { "Says thank you a lot", "Is quick with a thank you" }, dance = { "Dances whenever the mood takes {them}", "Dances a lot" },
    hug = { "Hugs people freely", "Is free with hugs" }, smile = { "Smiles at people a lot", "Is quick to smile" },
    salute = { "Salutes like a soldier, and often", "Is quick to salute" }, sigh = { "Sighs a lot", "Is given to sighing" },
    cry = { "Weeps more often than most", "Is quick to tears" }, flex = { "Shows off {their} muscles at every chance", "Flexes a lot" },
    roar = { "Roars when the mood takes {them}", "Is given to roaring" }, pray = { "Stops to pray often", "Prays a lot" },
    greet = { "Greets people readily", "Is quick with a greeting" }, nod = { "Nods along a lot", "Is quick to nod" },
    shrug = { "Shrugs a lot", "Is given to shrugging" }, applaud = { "Applauds others readily", "Is quick to applaud" },
    clap = { "Claps for others readily", "Is quick to clap" }, grin = { "Grins a lot", "Is quick to grin" },
    blow = { "Blows kisses freely", "Is free with blown kisses" }, flirt = { "Flirts readily", "Flirts a lot" },
    chicken = { "Clucks like a chicken at people more than is wise", "Is fond of clucking at people" },
    giggle = { "Giggles a lot", "Is given to giggling" }, chuckle = { "Chuckles a lot", "Is quick to chuckle" },
    raise = { "Raises a glass often", "Is quick to raise a glass" }, kiss = { "Is free with kisses", "Kisses people readily" },
    point = { "Points at things a lot", "Is quick to point" }, beckon = { "Beckons people over a lot", "Is quick to beckon" },
    growl = { "Growls a lot", "Is given to growling" }, glare = { "Glares at people a lot", "Is quick to glare" },
    yawn = { "Yawns a lot", "Is given to yawning" },
  },
}

-- More ways for the glances and History to say what Life records (into W.SAY, by key).
for k, v in pairs({
  -- History, the last three weeks (past-tense predicates)
  ev_fish = { "caught {item} in {zone}", "pulled {item} out of the water in {zone}", "landed {item} in {zone}" },
  ev_duel_won = { "won a duel in {zone}", "came out on top of a duel in {zone}" },
  ev_duel_lost = { "lost a duel in {zone}", "came off worse in a duel in {zone}" },
  ev_duels = { "fought {n} duels, winning {what}", "took on {n} duels, winning {what}" },
  ev_battle_won = { "won a battle in {place}", "came back from {place} with a win" },
  ev_battle_lost = { "lost a battle in {place}", "came back from {place} beaten" },
  ev_inn = { "rested at {inn} for the first time", "stopped at {inn} for the first time" },
  ev_path = { "found the flight master at {place}", "learned the way to fly from {place}" },
  ev_paths = { "found new flight masters at {list}", "learned the flight routes from {list}" },
  ev_mount = { "started riding {item}", "took to riding {item}" },
  ev_wear = { "started wearing {item}", "put on {item}" },
  ev_wield = { "took up {item}", "started carrying {item}" },
  ev_book = { "read {list}", "found time to read {list}" },
  ev_close = { "only just came through a fight{who} in {zone}", "came within a breath of losing a fight{who} in {zone}" },
  ev_made = { "spent a long stretch at {what} in {zone}", "put in a good while at {what} in {zone}" },
  rankpace = { ", only {n} after the rank before", ", {n} after the one before" },
  -- History, the longer record: what fills the gaps between roads
  life_pastimes = { "and {they've} {list}", "and so far {they've} {list}" },
  life_lead = { "Away from the fighting, {they've} {list}", "In quieter hours {they've} {list}", "Between the harder days {they've} {list}" },
  company_count = { "Has travelled in company with {n} different people", "Has shared the road with {n} different people" },
  company_friend = { ", most often {who}", ", {who} more than anyone" },
  -- Lately glance
  lately_fish = { "Pulled {item} out of the water in {zone} a short while back.", "Has been fishing in {zone}, and caught {item}." },
  lately_fishing = { "Has been fishing in {zone}, and has {n} to show for it.", "Spent a while fishing in {zone}: {n} caught." },
  lately_duel_won = { "Won a duel in {zone} within the hour.", "Came out on top of a duel in {zone} just now." },
  lately_duel_lost = { "Lost a duel in {zone} within the hour.", "Came off worse in a duel in {zone} just now." },
  lately_battle_won = { "Came back from {place} with a win.", "Fought in {place}, and the day was won." },
  lately_battle_lost = { "Came back from {place} beaten.", "Fought in {place}, and the day was lost." },
  lately_mount = { "Rides {item} now, and hasn't had it long.", "Has only lately started riding {item}." },
  lately_wear = { "Has only just started wearing {item}.", "Wears {item} now, and not for long yet." },
  lately_book = { "Was reading {item} only a short while ago.", "Has lately been reading {item}." },
  lately_made = { "Has been busy at {what} in {zone}.", "Spent the last while at {what} in {zone}." },
  lately_inn = { "Rested at {inn} for the first time in the last day.", "Has only lately found {inn}." },
  -- Marks glance
  mark_fish = { "Smells of fish.", "Smells strongly of fish, and of the water." },
  mark_cook = { "Smells of cooking smoke.", "Carries the smell of a cooking fire." },
  mark_herbs = { "Smells of crushed leaves and soil.", "Smells of fresh-cut herbs." },
  mark_mining = { "Covered in rock dust.", "Rock dust clings to {their} clothes." },
  mark_skinning = { "Smells of fresh hides.", "Smells of the hides {they've} just taken." },
  mark_duel = { "Still breathing hard from a duel.", "Fresh from a duel, and still catching {their} breath." },
  mark_fall = { "Moving stiffly, after a fall.", "Limping after a bad fall." },
  mark_swim = { "Soaked through.", "Dripping wet." },
}) do W.SAY[k] = v end

---------------------------------------------------------------------------
-- The journal (Journal.lua): the day as the character writes it, in the first person, from
-- what the game recorded. Each list is one beat; one line is picked per day. Placeholders:
-- {zone} {place} {tod} {q} {list} {n} {times} {there} {company} {inn} {foe} {where} {who}
-- {rank} {mood} {money} {feel} {end} {flavor}. Lines joined after a comma start with a
-- capital the composer lowers. No pronoun tags: it's the character's own voice (except the
-- two profile quotes at the end, which are third person).
---------------------------------------------------------------------------
W.JOURNAL = {
  tod = {
    dawn = { "at first light", "early", "before the sun was well up", "at daybreak" },
    morning = { "in the morning", "mid-morning", "while it was still morning" },
    noon = { "around midday", "at midday", "about noon" },
    afternoon = { "in the afternoon", "after midday", "some time after noon" },
    evening = { "in the evening", "toward evening", "as the light went", "with the evening coming on" },
    night = { "after dark", "in the dark hours", "well after nightfall", "late at night" },
  },
  -- The start of the day: moving on, or staying put.
  open_move = { "Set out from {place} {tod}", "Left {place} {tod}", "Was on the road out of {place} {tod}",
    "Got moving from {place} {tod}", "Was up and away from {place} {tod}" },
  open_stay = { "Kept to {zone} today", "Didn't stray far from {place} today", "Stayed in and around {place}",
    "Spent the day around {place}", "Never left {zone} today" },
  -- Reaching a land.
  arrive_new = { "Went on to {zone}, which I'd never seen before", "Reached {zone} for the first time",
    "Crossed into {zone}, new ground for me", "Saw {zone} for the first time", "Came to {zone}, somewhere I hadn't been" },
  arrive_on = { "Went on to {zone}", "Moved on to {zone}", "Carried on into {zone}", "Made for {zone}", "Took the road to {zone}" },
  arrive_back = { "Went back to {zone}", "Made my way back to {zone}", "Headed back into {zone}", "Was back in {zone} later on" },
  flew = { "Took a flight to {zone}", "Flew on to {zone}", "Caught a flight to {zone}" },
  flew_new = { "Flew to {zone}, my first sight of the place", "Took a flight to {zone}, somewhere I'd never been",
    "Caught a flight to {zone}, new ground for me" },
  instance = { "Went down into {zone}{company}", "Went into {zone}{company}", "Spent a while inside {zone}{company}" },
  instance_new = { "Went into {zone} for the first time{company}", "Saw the inside of {zone} for the first time{company}",
    "Went down into {zone}{company}, my first time there" },
  raid = { "Went into {zone} with a raid", "Joined a raid into {zone}" },
  pass = { "Passed through {list}", "Went by way of {list}", "Crossed {list} without stopping long" },
  pass_end = { "Passed through {list} after that", "Then on through {list}", "Crossed {list} later on" },
  -- What was done there. {there}: " there", " before I left" or nothing.
  quest_one = { "Turned in \"{q}\"{there}", "Saw \"{q}\" through{there}", "Finished \"{q}\"{there}",
    "Got \"{q}\" done{there}" },
  quest_few = { "Turned in {list}{there}", "Saw {list} through{there}", "Finished {list}{there}" },
  quest_many = { "Saw {n} jobs through{there}, {list} among them", "Turned in {n} jobs{there}, including {list}",
    "Finished {n} jobs{there}, {list} among them" },
  inn_mid = { "Rested at {inn}", "Stopped to rest at {inn}", "Took a rest at {inn}" },
  boss_group = { "Between us we brought down {list}", "We brought down {list} in there", "We put an end to {list}",
    "Together we finished {list}" },
  boss_solo = { "Brought down {list} there", "Put an end to {list}", "Finished {list} on my own" },
  -- Dying and nearly dying.
  death_one = { "Died to {foe} {where}", "{foe} killed me {where}", "Fell to {foe} {where}", "Was killed by {foe} {where}" },
  death_player = { "Was cut down by {foe} {where}", "Lost a fight to {foe} {where}", "{foe} caught me {where} and that was that" },
  death_unknown = { "Died {where}", "Was killed {where}", "Didn't survive a fight {where}" },
  death_many = { "Died {times} {where}", "Was killed {times} {where}", "Lost my life {times} {where}" },
  death_last = { ", the last time to {foe}", ", and {foe} was the last of it", ", lastly to {foe}" },
  close = { "Came close to dying to {foe} {where}", "Nearly lost a fight with {foe} {where}",
    "Only just got the better of {foe} {where}", "Barely came through a fight with {foe} {where}" },
  -- How the character takes it: by RPG Dialogue temperament if there is one, else race, else class.
  after_death = {
    default = { "I'll be more careful there", "I'll go more carefully next time", "Not my finest hour",
      "I won't make that mistake twice if I can help it" },
    brave = { "Next time I'll be ready for it", "It won't go that way twice", "I'll be back for that one" },
    cautious = { "I should have seen it coming", "I'll give that place a wider berth", "I pushed my luck and paid for it" },
    kind = { "Nobody else was hurt for it, at least", "Better me than someone with less sense" },
    cruel = { "I'll pay that back with interest", "Someone will answer for it" },
    witty = { "A poor way to spend an afternoon", "I've had better days, and fewer deaths in them" },
    pious = { "Light grant me better judgement next time", "Light keep me steadier tomorrow" },
    reserved = { "Enough said about that", "I'd rather not dwell on it" },
    greedy = { "And the repairs won't be cheap", "Dying costs coin, and I felt every copper of it" },
    Scourge = { "Dying is no novelty for one of us, but it still costs me time",
      "Death and I are old acquaintances; I'd still rather keep my distance" },
    Dwarf = { "I'll not be caught that way again", "Stubborn as I am, I can still learn" },
    Orc = { "There is no shame in falling, only in staying down", "Next time the blood spilled won't be mine" },
    Tauren = { "Patience would have served me better", "I'll walk more carefully on the Earth Mother's ground" },
    Troll = { "Da spirits not want me yet", "Next time, I be the one doing the killing" },
    Gnome = { "I'll work out where my reckoning went wrong", "Back to the drawing board" },
    NightElf = { "Even a long life shouldn't be thrown away", "I should have trusted my instincts" },
    WARRIOR = { "Next time I'll hit harder and sooner", "I'll be ready for that one" },
    ROGUE = { "I should have stayed in the shadows", "I'll pick my moment better" },
    MAGE = { "I'll keep more distance next time", "A lesson in keeping my distance" },
    HUNTER = { "I'll read the ground better next time", "Should have kept my distance" },
  },
  after_close = {
    default = { "I'll be more careful in those parts", "Too close by half", "I won't forget that one quickly" },
    brave = { "Close, but that's the road for you", "Close, and I'd do it again" },
    cautious = { "Too close; I'll be more careful in those parts", "I don't mean to cut it that fine again" },
    witty = { "My heart is still going faster than it should", "Not the kind of excitement I was after" },
    pious = { "The Light was with me today" },
  },
  -- The rest of the day.
  group_friends = { "Had {who} for company for part of the day", "Spent part of the day with {who}",
    "Travelled a while alongside {who}" },
  group_one = { "Had company for part of the day", "Fell in with a group for a while", "Joined up with others for a stretch" },
  group_many = { "Joined up with others {times} over the day", "Was in {n} different groups over the day",
    "Fell in with one group or another {times}" },
  loot = { "Came away with {list}", "Found {list} today", "Picked up {list} along the way", "{list} came my way today" },
  loot_epic = { "Came away with {list}, and I can hardly believe my luck", "Found {list} today, the best thing I've come by in a long while",
    "{list} came my way today, which made the whole day worth it" },
  level = { "Grew stronger", "Felt myself grow stronger", "I'm stronger now than when the day began",
    "Grew into my strength a step further" },
  level_many = { "Grew stronger {times} over", "Grew stronger {times} in one day", "Felt myself grow stronger {times}" },
  rank = { "I can call myself {rank} now", "I'm {rank} now, by any fair measure", "I've earned the name of {rank}" },
  skill = { "Got better at {list}", "Put some practice into {list}", "Made headway with {list}", "My {list} came along" },
  -- How the day ended. {feel}: how I felt, with the purse if it changed.
  end_at = { "Ended the day at {end}, {feel}", "Finished at {end}, {feel}", "Called it a day at {end}, {feel}" },
  end_inn = { "Stopped for the night at {end}, {feel}", "Ended the day at {end}, {feel}", "Called it a night at {end}, {feel}" },
  end_flavor = { "Ended the day {flavor}, {feel}", "Finished up {flavor} {tod}, {feel}", "Called it a day {flavor}, {feel}" },
  end_early = { "Left off at {end} {tod}, {feel}", "Broke off at {end} {tod}, {feel}", "Stopped at {end} {tod}, {feel}" },
  purse = {
    gain_good = { "{mood} and {money} richer", "{mood}, with {money} more than I started with", "{mood}, and {money} the better off" },
    gain_bad = { "{mood}, but {money} better off", "{mood}, though {money} the richer", "{mood}, if {money} richer" },
    loss_good = { "{mood}, if {money} lighter", "{mood} despite being {money} down", "{mood}, though {money} poorer" },
    loss_bad = { "{mood}, and {money} poorer for it", "{mood} and {money} down on the day", "{mood}, and {money} lighter besides" },
  },
  feel = {
    shaken = { "still shaken", "not steady yet" }, rattled = { "jumpy", "on edge after it all" },
    elated = { "in high spirits", "pleased with myself" }, triumphant = { "flushed with the win", "proud of the day's work" },
    satisfied = { "satisfied", "content with the work done" }, weary = { "tired", "worn out", "ready to sleep" },
    ease = { "at ease", "comfortable" }, merry = { "merry", "in good cheer" }, haunted = { "troubled", "uneasy in my own head" },
    wonder = { "still taking it all in", "wide awake with it all" }, homecoming = { "glad to be home", "happy to be back" },
    tense = { "on edge", "wary" }, uneasy = { "uneasy", "not liking the dark" }, sociable = { "glad of the company", "in good company" },
    company = { "glad of the company", "in good company" }, intrigued = { "turning things over", "curious what comes next" },
    determined = { "set on what comes next", "determined" }, sorrowful = { "heavy-hearted", "sad" },
    angry = { "angry", "still angry" }, smitten = { "with someone on my mind" }, devout = { "at peace", "prayerful" },
    fed = { "well fed", "full and content" }, downcast = { "low", "out of sorts" }, frustrated = { "frustrated", "fed up" },
    bolstered = { "in fine fettle", "strong and well" }, glorious = { "fit to take on anything" }, ailing = { "feeling poorly", "sick" },
    drained = { "drained", "spent" }, wounded = { "sore", "nursing my hurts" }, festive = { "in a festive mood" },
    fierce = { "with my blood still up" }, worried = { "anxious", "worried about money" }, flush = { "pleased with my purse" },
    thrilled = { "thrilled", "still grinning" }, conflicted = { "unsure of myself", "of two minds" },
    righteous = { "sure I did right" }, proud = { "proud", "pleased with myself" }, ashamed = { "ashamed of myself", "not proud of myself" },
    eager = { "eager for tomorrow", "impatient for more" }, burdened = { "weighed down", "carrying more than I'd like" },
    newsy = { "full of news" }, accomplished = { "with plenty done", "satisfied with the work" }, lonely = { "lonely", "missing company" },
    good = { "in good spirits", "content" }, bad = { "out of sorts", "glad the day was over" },
    calm = { "steady enough", "none the worse for it", "quiet in myself", "tired in the ordinary way" },
  },
  -- A last word, now and then, in the character's own manner.
  signoff = {
    PRIEST = { "Light keep the road clear tomorrow", "Light willing, tomorrow will be kinder" },
    PALADIN = { "The Light willing, tomorrow goes as well", "Tomorrow, the same road and the same oath" },
    WARRIOR = { "Tomorrow, more of the same", "Rest now, and fight again tomorrow" },
    ROGUE = { "Nobody saw more than I wanted them to", "Quiet days are the profitable ones" },
    MAGE = { "There's always more to learn", "Tomorrow, more study" },
    WARLOCK = { "Power has its price, and I'll go on paying it", "Tomorrow the work goes on" },
    HUNTER = { "Tomorrow, the trail again", "The wilds will be there in the morning" },
    DRUID = { "The wild keeps its own time; so will I", "Balance, tomorrow as today" },
    SHAMAN = { "The spirits were quiet today", "Tomorrow I'll listen to the elements again" },
    DEATHKNIGHT = { "Another day spent among the living", "Rest doesn't come easily to my kind" },
  },
  -- Quoting the journal on the profile (third person). {when}: today, yesterday, on Tuesday.
  history = { "{their} journal for {when} begins", "{their} own journal, {when}, reads", "In {their} journal {when}, {they} wrote" },
  glance = { "From {their} journal, {when}: {q}", "Wrote in {their} journal {when}: {q}" },
}

---------------------------------------------------------------------------
-- 0.21.0: more words. Race x class temperament, and more ways to say what the glances,
-- History and Physical already report. (Kept in one block to ease merging.)
---------------------------------------------------------------------------

-- How a particular race and class carry themselves together, for Personality: a dwarf
-- paladin, a Forsaken priest, a troll shaman. Dispositions and manner only, never an action
-- they took or a thing they hold. Pairs that don't exist in the lore are left out.
W.RACE_CLASS_TEMPER = {
  Human = {
    WARRIOR = { "Has the drilled steadiness of a Stormwind soldier, and a soldier's habit of grumbling about the quartermaster.",
      "Practical about fighting: there's no glory in it, but someone has to stand on the wall.",
      "Thinks of the kingdom's walls and farms as things worth bleeding for, and says so plainly." },
    PALADIN = { "Holds to the Light the way the Silver Hand taught it: as a duty, not a comfort.",
      "Speaks of Uther's knights with respect, and measures {themselves} against them.",
      "Patient with farmers and children, and stiff with nobles." },
    HUNTER = { "More comfortable under Elwynn's oaks than in Stormwind's streets.",
      "Has a countryman's eye for weather, and a countryman's patience with it.",
      "Plain-spoken and watchful, like most people raised where wolves come down from the hills." },
    ROGUE = { "Has the easy manner of Stormwind's Old Town, and its habit of checking who's listening.",
      "Polite to the city watch, and relieved when it passes.",
      "Knows that in the human kingdoms a kind word and ready coin open most doors." },
    PRIEST = { "Speaks of the Light in the plain words of a village chapel, not a cathedral.",
      "Believes in second chances, and offers them freely.",
      "Takes the Holy Light's teaching as practical advice: tend the sick, feed the hungry, bury the dead." },
    MAGE = { "Has the confidence of someone taught that Dalaran's ways are the proper ones.",
      "Curious and careful, and inclined to mention where {they} studied.",
      "Respects the arcane, and is wary of anyone who doesn't." },
    WARLOCK = { "Polite and well-spoken, which makes what {they} stud{ies} harder to believe.",
      "Keeps {their} studies away from the neighbours, out of habit more than shame.",
      "Has a human's ambition, turned somewhere most humans won't follow." },
    DEATHKNIGHT = { "Still has a human's manners, worn thin and cold.",
      "Tired of being stared at in Stormwind's streets, and past caring much.",
      "Grim, and dry about it." },
  },
  Dwarf = {
    WARRIOR = { "Thinks about a fight the way dwarves think about building: slow, solid and meant to last.",
      "Proud of the Ironforge regiments, and happy to say so over a drink.",
      "Unshakeable once planted, in a fight or an argument." },
    PALADIN = { "Keeps the Light with a dwarf's stubbornness: once sworn, sworn for good.",
      "Blesses a meal and a forge with the same seriousness.",
      "Treats the Light as a craft to be practised, not a feeling to be waited on." },
    HUNTER = { "Has a mountaineer's patience, and a mountaineer's low opinion of flat ground.",
      "Talks of the high passes of Dun Morogh the way others talk of home.",
      "Reads snow and stone the way others read signposts." },
    ROGUE = { "Quieter than most dwarves, which still isn't very quiet.",
      "Has a tunneller's sense of where the way out is.",
      "Practical about property: things belong to whoever keeps them safe." },
    PRIEST = { "Has a dwarf's faith: plain, stubborn and fond of a good hymn.",
      "Tends the hurt with a firm hand and a firmer opinion about how they got hurt.",
      "Takes a pint and a prayer with equal care." },
    SHAMAN = { "Listens to the stone in a way {their} grandparents never thought to.",
      "Has an Explorer's curiosity about what the old rock remembers.",
      "Respects the mountain more than any king." },
    MAGE = { "Treats magic like a tricky seam of ore: worth working, and best approached with care.",
      "Has a scholar's patience and a dwarf's temper, usually in that order.",
      "Fond of the Explorers' League, and of any old ruin worth a look." },
    DEATHKNIGHT = { "Has lost a dwarf's warmth, but not a dwarf's stubbornness.",
      "Silent in the tavern, which other dwarves find hardest of all to forgive.",
      "Holds on to old oaths out of something like habit." },
  },
  Gnome = {
    WARRIOR = { "Treats being small as a tactical advantage, and won't hear otherwise.",
      "Brave out of all proportion to {their} size.",
      "Has opinions on the engineering of every wall and gate {they} see{s}." },
    HUNTER = { "Treats tracking as a kind of applied arithmetic.",
      "Fond of animals, and of anything with clever moving parts.",
      "Patient outdoors in a way {they} never manage{s} indoors." },
    ROGUE = { "Quick-fingered and quicker-witted, with an engineer's love of locks.",
      "Small enough to be overlooked, and counts on it.",
      "Cheerful and chatty, and far more observant than {they} let{s} on." },
    PRIEST = { "Approaches the Light like an experiment that keeps coming out right.",
      "Kind in a brisk, practical way, already thinking about the next patient.",
      "Optimistic about everyone's recovery, and often right." },
    MAGE = { "Thinks of spells as formulas, and gets restless when one won't balance.",
      "Excitable about the arcane, and frank about the explosions.",
      "Curious to the point of carelessness, and cheerful about it." },
    WARLOCK = { "Treats demons as a technical problem, which the demons find insulting.",
      "Cheerful about the dark arts in a way that worries everyone else.",
      "Keeps careful count of every bargain, down to the last clause." },
    DEATHKNIGHT = { "Still thinks like an engineer, only colder.",
      "Has lost a gnome's cheer, though not a gnome's curiosity.",
      "Precise and unsmiling, which other gnomes find unsettling." },
  },
  NightElf = {
    WARRIOR = { "Has the discipline of the Sentinels, patient and exact.",
      "Unhurried even in danger, as if there were always time to do a thing properly.",
      "Proud of {their} people's long watch over the forests." },
    HUNTER = { "As quiet in company as in the woods.",
      "Takes the bond with animals as something old and natural, not a trick to be learned.",
      "Watchful by night, and easy under the moon." },
    ROGUE = { "Patient, silent and hard to see coming.",
      "Has a night elf's long memory for wrongs, and a rogue's patience in settling them.",
      "Reserved even by the standards of {their} people." },
    PRIEST = { "Holds to Elune with a calm that years of loss haven't shaken.",
      "Speaks of the moon as a presence, not a symbol.",
      "Gentle, grave and very hard to hurry." },
    MAGE = { "Wary of the arcane in the way only a night elf can be, remembering what it once cost.",
      "Studies magic carefully, as if expecting to be judged for it.",
      "Precise and reserved, and conscious of what {their} people think of mages." },
    DRUID = { "Thinks of the Emerald Dream the way others think of a distant home.",
      "Patient with the forest's slow work, and impatient with those who spoil it.",
      "Speaks of Cenarius and the old ways with quiet certainty." },
    DEATHKNIGHT = { "Has a night elf's stillness, with the warmth gone out of it.",
      "Speaks of Elune rarely, and never lightly.",
      "Holds {themselves} apart, even from other night elves." },
  },
  Orc = {
    WARRIOR = { "Has a warrior's idea of honour, and expects enemies to share it.",
      "Proud of the Horde's strength, and of {their} own place in it.",
      "Blunt and brave, and impatient with talk that goes nowhere." },
    HUNTER = { "Respects the beasts of Durotar for surviving it.",
      "Patient on the hunt, and blunt everywhere else.",
      "Speaks of wolves with real affection." },
    ROGUE = { "Quieter than most orcs, which is how {they} like{s} it.",
      "Thinks of cunning as another kind of strength.",
      "Respects the Shattered Hand's way: unseen, until it matters." },
    SHAMAN = { "Speaks to the spirits as Thrall taught {their} people to: asking, never commanding.",
      "Believes the elements have long memories, and that the orcs owe them a great deal.",
      "Calm and grave, mindful of the mistakes the old shamans made." },
    MAGE = { "Knows what the old warlocks did to {their} people, and keeps to the arcane carefully.",
      "Has an orc's directness and a mage's exactness, which surprises people.",
      "Bristles when anyone calls study unorcish." },
    WARLOCK = { "Knows how fel magic once enslaved the orcs, and studies it anyway.",
      "Watched warily by other orcs, and used to it.",
      "Proud, guarded and very sure of {their} own control." },
    DEATHKNIGHT = { "Still thinks about honour, though {they} can't always say what it means now.",
      "Has an orc's pride and a dead thing's patience.",
      "Grim even for an orc." },
  },
  Troll = {
    WARRIOR = { "Loose and easy until trouble starts, and very quick after.",
      "Proud of the Darkspear, who bent for no one.",
      "Laughs in the middle of trouble, which unnerves the other side." },
    HUNTER = { "Speaks of the jungle with fondness, and of its beasts with respect.",
      "Patient as a hunter on a branch, and as still.",
      "Keeps the old troll hunting ways: respect the kill, waste nothing." },
    ROGUE = { "Grins too much for anyone to guess what {they're} thinking.",
      "Quick and quiet, and quicker still to laugh.",
      "Treats the shadows like old friends." },
    PRIEST = { "Honours the loa, and keeps a healer's calm.",
      "Talks about the spirits matter-of-factly, as if they'd just stepped out.",
      "Gentle with the sick, and blunt with the healthy." },
    SHAMAN = { "Speaks with the loa as familiars, not distant gods.",
      "Easy-going, with a witch doctor's long patience.",
      "Takes the spirits' warnings seriously, and most other things lightly." },
    MAGE = { "Treats the arcane with a wary grin, like a beast that might bite.",
      "Proud that the Darkspear have mages of their own.",
      "Mixes old troll wisdom with new learning, and enjoys the confusion it causes." },
    WARLOCK = { "Has a troll's comfort with dark magic, and few qualms about it.",
      "Unbothered by demons, which bothers everyone else.",
      "Laughs softly at things others would shudder at." },
    DRUID = { "Follows the old troll ways of the wild, closer to the loa than to Cenarius.",
      "Feels the wild as something to run with, not something to tame.",
      "Patient with the jungle, and impatient with cities." },
    DEATHKNIGHT = { "Has kept a troll's grin, though it's colder now.",
      "Has more respect for the loa of death than {they} used to.",
      "Patient, and in no hurry about anything." },
  },
  Tauren = {
    WARRIOR = { "Gentle by nature, and frightening when that runs out.",
      "Thinks of strength as something meant to protect.",
      "Respects a brave enemy, and says so." },
    PALADIN = { "Keeps faith with An'she, the sun, as a Sunwalker does.",
      "Calm and warm-spirited, like the plains at noon.",
      "Sees no difference between serving the Light and serving the Earth Mother." },
    HUNTER = { "Honours the beasts {they} hunt{s}, as tauren always have.",
      "At ease on the open plains, and restless anywhere enclosed.",
      "Patient and quiet, and mindful of what the land can spare." },
    PRIEST = { "Keeps faith with An'she and Mu'sha, the sun and the moon.",
      "Gentle-voiced and slow to judge.",
      "Speaks of light and warmth as things the Earth Mother gives freely." },
    SHAMAN = { "Hears the elements as old voices, and answers them with respect.",
      "Calm and patient, like the ground itself.",
      "Believes balance is kept in small daily courtesies." },
    DRUID = { "Close to the Earth Mother in thought and in manner.",
      "Treats every creature as a neighbour on the plains.",
      "Has the slow, deliberate wisdom of the Cenarion Circle." },
    DEATHKNIGHT = { "Keeps a tauren's dignity, though not a tauren's warmth.",
      "Speaks rarely, and the plains seem far away from {them}.",
      "Patient in a cold, unmoving way." },
  },
  Scourge = {
    WARRIOR = { "Fearless in the way of someone who has already died.",
      "Grimly practical: a wound is a repair job.",
      "Loyal to the Dark Lady's cause, and to little else." },
    HUNTER = { "Patient on a trail. The dead don't get bored.",
      "Finds beasts better company than the living.",
      "Has a Forsaken's dry humour about the things {they} track{s}." },
    ROGUE = { "Cold, quiet and very good at going unnoticed.",
      "Trusts no one, and is seldom disappointed.",
      "Has the Deathstalkers' patience, and their dislike of questions." },
    PRIEST = { "Speaks of the Light warily, as of something that once failed {them}.",
      "Tends other Forsaken with a dry, unsentimental kindness.",
      "Believes in nothing easily, and in the shadow a good deal." },
    MAGE = { "Has a scholar's chill: detached, exact and patient.",
      "Treats the arcane as one of the few things death didn't take.",
      "Precise and sardonic, and short with fools." },
    WARLOCK = { "Sees no reason the dead should fear the dark.",
      "Cold-tempered and coldly curious.",
      "Bargains with demons without much fear for {their} soul, all things considered." },
    DEATHKNIGHT = { "Doubly dead, and dry about it.",
      "Hates the Scourge with a patience that won't wear out.",
      "At home among the Forsaken, as much as {they're} at home anywhere." },
  },
  Goblin = {
    WARRIOR = { "Thinks of a fight as a contract, and always reads the terms.",
      "Loud and brash, and surprisingly hard to put down.",
      "Brave enough, so long as the pay is right." },
    HUNTER = { "Sizes up every beast for what it would fetch.",
      "Talks to animals like business partners.",
      "Prefers a clever trap to a long chase." },
    ROGUE = { "Treats every room as a market and every stranger as a customer.",
      "Charming and quick, and always a step ahead of the bill.",
      "Never gives anything away for free, secrets least of all." },
    PRIEST = { "Thinks of good deeds as an investment that pays out eventually.",
      "Kind in a brisk way, and doesn't like being thanked for long.",
      "Has a goblin's practical faith: the Light works, so why not use it." },
    SHAMAN = { "Treats the elements as the best business partners {they've} ever had.",
      "Respects the spirits, though {they} sometimes tr{ies} to haggle with them.",
      "Calmer than most goblins, and proud of it." },
    MAGE = { "Sees the arcane as the most profitable trade there is.",
      "Impatient with theory, and fond of results.",
      "Cheerful about the risks, and quick to blame the equipment." },
    WARLOCK = { "Reads every demon's terms twice, looking for the loophole.",
      "Bargains with demons as {they} would with anyone: hard.",
      "Unworried by the dark, as long as it pays." },
    DEATHKNIGHT = { "Still counts coin, though the joy has gone out of it.",
      "Has kept a goblin's sharp eye, and lost the grin.",
      "Grim and efficient, and no longer interested in haggling." },
  },
}
W.RACE_CLASS_TEMPER.Undead = W.RACE_CLASS_TEMPER.Scourge

-- More ways the glances and About say things (W.SAY above), and new ones for lines that
-- used to be written one way only.
extendAll(W.SAY, {
  othernames = { "Some know {them} as {list} instead", "Goes by {list} in some company" },
  favspell = { "Leans on {spell} above any other {noun}", "Has a habit of reaching for {spell}" },
  newname = { "Has picked up a new name lately: {nick}.", "Has been going by {nick} of late." },
})
-- Company: friends from Social Diary, and local ties.
W.SAY.seenwith_rel = { "Often seen with {who}, {their} {rel}.", "Seldom far from {who}, {their} {rel}.",
  "Usually in the company of {who}, {their} {rel}.", "Keeps close to {who}, {their} {rel}." }
W.SAY.seenwith = { "Often seen in the company of {list}.", "Often seen with {list}.", "Usually found with {list}.",
  "Keeps company with {list}.", "Spends a good deal of time with {list}." }
W.SAY.getson = { "gets on well with {who}", "is friendly with {who}", "is on good terms with {who}", "counts {who} a friend" }
-- Marks: how they are right now.
W.SAY.mark_wounded = { "Freshly wounded, and moving carefully.", "Hurt, and favouring the hurt side.",
  "Moving stiffly around a fresh wound.", "Bloodied, and trying not to let on how badly." }
W.SAY.mark_drunk = { "Unsteady on {their} feet, and smelling of drink.", "Smells of ale from a few paces off.",
  "Loose in the knees, and fragrant with drink.", "Has had a drink or three, and walks like it." }
W.SAY.mark_mad = { "{their} eyes never settle on anything for long.", "Glances at things no one else is looking at.",
  "Has a restless, wandering look that doesn't go away.", "Mutters now and then, and doesn't seem to notice." }
W.SAY.mark_taint = { "Something about {them} is off, in a way that's hard to name.",
  "There's something wrong about {them} that people feel before they see.",
  "Gives off a wrongness that's hard to put a finger on.", "Makes people uneasy without doing anything at all." }
-- History: the people, and how things stand.
W.SAY.guild = { "Wears the colours of {guild}", "Belongs to {guild}", "Is a member of {guild}",
  "Has thrown in {their} lot with {guild}" }
W.SAY.fought = { "Has fought beside {n} others this past week", "Has shared the road with {n} others this past week",
  "Has stood with {n} others in one fight or another this week", "Has been in company with {n} others this past week" }
W.SAY.foes = { "Has made {what} on the road", "Has picked up {what} along the way", "Has made {what} out there",
  "Not everyone on the road wishes {them} well: {they've} made {what}" }
W.SAY.diary = { "{their} latest journal entry reads {q}", "The newest page in {their} journal reads {q}",
  "The last thing {they} wrote down reads {q}", "{their} journal's most recent entry: {q}" }

-- Moods with fewer than four ways to show.
extend(W.MOODS.accomplished, "tells", { "Has the brisk step of someone getting through a long list.",
  "Looks like {they've} had a productive day, and would happily have another." })
extend(W.MOODS.festive, "adj", { "In holiday spirits", "Celebrating" })
extend(W.MOODS.festive, "tells", { "Cheerful in the way holidays make people.", "Greets everyone as if they were all invited." })
extend(W.MOODS.newsy, "tells", { "Keeps frowning, then nodding, as if turning some news over.",
  "Has the look of someone who has just heard something worth repeating." })
for k, more in pairs({
  winterveil = { adj = { "Snug and cheerful" }, tells = { "Pink-cheeked from the cold, and smiling." } },
  hallowsend = { adj = { "Ghoulishly cheerful" }, tells = { "Grinning like someone in on a joke.", "Delighted by anything spooky." } },
  love = { adj = { "Sweet-tempered" }, tells = { "Softer in manner than usual.", "Smiles a beat too long at people." } },
  midsummer = { adj = { "Bright and easy" }, tells = { "Easy-going and warm, like the long days.", "Squinting cheerfully into the light." } },
  brewfest = { tells = { "Cheerful, loud and in no hurry to be anywhere." } },
  lunar = { adj = { "Respectful of the old year", "Mindful of the elders" },
    tells = { "Speaks of absent friends with warmth.", "Calm and respectful, the old year on {their} mind." } },
  noblegarden = { adj = { "Sunny", "Spring-hearted" },
    tells = { "Cheerful, like the first warm day of the year.", "Smiling, with spring in {their} step." } },
}) do
  if W.FESTIVALS[k] then extend(W.FESTIVALS[k], "adj", more.adj or {}); extend(W.FESTIVALS[k], "tells", more.tells or {}) end
end

extendAll(W.AMBITIONS, {
  default = { "To earn a name worth keeping.", "To find a place worth calling home." },
  DEATHKNIGHT = { "To make the Scourge pay for every life it took.", "To find out what's left of who {they} used to be.",
    "To be more than what the Lich King made.", "To stand where the living can't, and hold." },
})

-- Currently: activities and travel with fewer than four ways to say them.
extendAll(W.ACTIVITY, {
  cannibalize = { "feeding on the dead in {place}, which is best ignored" },
  dancing = { "dancing for the joy of it in {place}" },
  disenchant = { "unmaking a magic trinket in {place}", "reducing an old trinket to its essence in {place}" },
  drinking = { "nursing a drink in {place}" },
  duel = { "fighting a friendly duel in {place}" },
  flightmaster = { "waiting for a mount at the flight master in {place}" },
  lockpick = { "coaxing a lock open in {place}", "bent over a stubborn lock in {place}" },
  mining = { "breaking ore loose in {place}" },
  pickpocket = { "relieving someone of their coin in {place}" },
  portal = { "tearing open a way to {dest} in {place}" },
  shadowmeld = { "gone still as shadow in {place}" },
  skinning = { "working a hide loose in {place}" },
  summoning = { "drawing someone across the miles to {place}", "calling someone through to {place}" },
})
extendAll(W.TRAVEL, {
  battleground = { "fighting for {their} side at {where}" },
  flying = { "riding the high winds over {where}", "on the wing above {where}" },
  mounted = { "{mount} along the roads of {where}" },
  stealth = { "out of sight {around}" },
  swimming = { "making for the shore in {where}" },
})
extendAll(W.TIME_OF_DAY, {
  dawn = { "with the day just beginning", "in the grey of dawn" },
  dusk = { "in the last of the light", "as the day ends" },
})

-- Physical: what every one of a race shares, and more ways to say build and bearing.
extendAll(W.RACE_LOOK, {
  Human = { "Human, and built for work rather than show." },
  Dwarf = { "Low to the ground and heavy-boned, made for stone and cold." },
  Gnome = { "Small and wiry, with a long nose and quick, clever hands." },
  NightElf = { "Long-limbed and tall, ears sweeping back, eyes glowing in the shade." },
  Orc = { "A powerful orc, heavy through the jaw and shoulders." },
  Troll = { "Stooped from great height, with long arms and longer tusks.", "Rangy and loose-jointed, tusks jutting." },
  Tauren = { "Massive and deliberate, every step a heavy one on broad hooves." },
  Scourge = { "Thin to the bone, joints showing, eyes a cold glow in a sunken face." },
  Goblin = { "Short, wiry and sharp-featured, with long ears and a long nose.",
    "Small and bony, with big ears, a big nose and eyes that miss nothing.",
    "A goblin, all angles and ears, with quick, clever hands." },
})
extendAll(W.CLASS_LOOK, {
  WARRIOR = { "Stands square, weight even, like someone used to being pushed and not moving.",
    "Has the thick forearms and straight back of long drill." },
  PALADIN = { "Holds {themselves} upright, with the stillness of someone used to vigils.",
    "Has a calm, level gaze that settles on people and stays." },
  HUNTER = { "Steps quietly even on stone, from long habit.", "Has a weathered, outdoor look." },
  ROGUE = { "Keeps to the edges of the light, out of habit.", "Moves without a sound, and smiles without much warmth." },
  PRIEST = { "Has a quiet, attentive face, used to listening.", "Stands with folded hands and an easy patience." },
  SHAMAN = { "Has the weathered look of someone who spends long hours under the sky.",
    "Stands easy, head tilted, as if listening to the wind.", "Calm in manner, with a steady, grounded stance." },
  MAGE = { "Has the pale, indoor look of long study.", "Holds {themselves} with a scholar's slight stoop." },
  WARLOCK = { "Has a pale, sharp look, as if sleep comes seldom.", "Smiles rarely, and never all the way." },
  DRUID = { "Has a weathered, outdoor look, and an animal's alertness.", "Stands very still, the way creatures do in the wild." },
  DEATHKNIGHT = { "Moves with a heavy, deliberate tread, and breathes too little.",
    "Eyes burn a cold blue, and the cold seems to come off {them}.",
    "Stands utterly still between movements, in a way the living can't.",
    "Pale and grim, with the stillness of the grave about {them}." },
})
extendAll(W.PHYSIQUE, {
  strength = { "thick through the arms and shoulders", "solidly built, with a heavy, deliberate tread" },
  agility = { "lithe and balanced, seldom still", "quick-handed, with a light, easy step" },
  stamina = { "broad and tough, built to take a beating", "barrel-chested and enduring" },
  intellect = { "slight of build, with an intent, studious gaze", "lean, with a thinker's quick eyes" },
  spirit = { "composed, with a steady, patient bearing", "quiet-faced, and still in a way that calms others" },
})
