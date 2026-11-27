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
-- Reputation as people would see it (Sources/Renown.lua). Hearsay stays local and modest:
-- a town's regulars, a faction's people, the guards of one place. Every line is filled
-- from one stored record ({town}, {story}, {people}, {why}, {foes}, {where}, {quest}, {n},
-- {times}, {place}, {zone}, {enemy}, {faction}, {word}); pronouns are tags.
---------------------------------------------------------------------------
W.RENOWN = {
  STANDING = { "Hated", "Hostile", "Unfriendly", "Neutral", "Friendly", "Honored", "Revered", "Exalted" },
  -- Who speaks for a faction, in a sentence. Anything else reads as W.FactionName.
  PEOPLE = {
    ["Booty Bay"] = "the goblins of Booty Bay", ["Gadgetzan"] = "the goblins of Gadgetzan",
    ["Ratchet"] = "the goblins of Ratchet", ["Everlook"] = "the goblins of Everlook",
    ["Steamwheedle Cartel"] = "the goblins of Steamwheedle", ["Bloodsail Buccaneers"] = "the Bloodsail Buccaneers",
    ["Timbermaw Hold"] = "the Timbermaw furbolgs", ["Thorium Brotherhood"] = "the smiths of the Thorium Brotherhood",
    ["Argent Dawn"] = "the Argent Dawn", ["Cenarion Circle"] = "the druids of the Cenarion Circle",
    ["Hydraxian Waterlords"] = "the Hydraxian Waterlords", ["Ravenholdt"] = "the folk at Ravenholdt",
    ["Zandalar Tribe"] = "the Zandalar trolls", ["Wintersaber Trainers"] = "the Wintersaber Trainers",
    ["Gelkis Clan Centaur"] = "the Gelkis centaur", ["Magram Clan Centaur"] = "the Magram centaur",
    ["Syndicate"] = "the Syndicate", ["Shen'dralar"] = "the Shen'dralar",
    ["Frostwolf Clan"] = "the Frostwolf orcs", ["Stormpike Guard"] = "the Stormpike dwarves",
    ["Silverwing Sentinels"] = "the Silverwing Sentinels", ["Warsong Outriders"] = "the Warsong Outriders",
    ["Stormwind"] = "the people of Stormwind", ["Ironforge"] = "the dwarves of Ironforge",
    ["Gnomeregan Exiles"] = "the gnomes of Gnomeregan", ["Darnassus"] = "the night elves of Darnassus",
    ["Orgrimmar"] = "the orcs of Orgrimmar", ["Thunder Bluff"] = "the tauren of Thunder Bluff",
    ["Undercity"] = "the Forsaken of the Undercity", ["Darkspear Trolls"] = "the Darkspear trolls",
  },
  -- Those who keep a town's peace (creature names).
  GUARDS = { "Guard$", "Guardian$", "Guards?man$", "Bruiser$", "Grunt$", "Sentinel$", "Deathguard", "Protector$",
    "Patroller$", "Peacekeeper$", "Watchman$", "Mountaineer$", "Bluffwatcher$" },

  -- A town where they've done many jobs, and the story of its land they saw most of.
  TOWN_STORY = {
    "In {town} the regulars at the inn have heard of {them}, mostly over {story}",
    "Talk of {them} in {town} turns, sooner or later, to {story}",
    "A few folk in {town} could put a face to {their} name, mostly because of {story}",
    "Mention {them} in {town} and the talk soon turns to {story}",
    "Around {town}, {their} name tends to come up alongside {story}",
  },
  -- The same with no story to tell: the jobs done there ({n}, four or more).
  TOWN_JOBS = {
    "In {town} a few people have {their} name from the {n} jobs {they've} done there",
    "Around {town}, {their} name means work done and paid for: {n} jobs of it",
    "The people of {town} have handed {them} {n} jobs so far, and speak of {them} kindly enough",
    "In {town} the word is that {they} can be trusted with a job; {n} of them, so far",
    "Folk in {town} have seen {them} through {n} of their jobs, and say so over a drink",
  },
  -- A faction they've lost much standing with, and why ({why} from WHY_KILL or WHY_QUEST).
  FALLOUT = {
    "{people} have no love for {them}, {why}",
    "{people} won't hear a good word about {them}, {why}",
    "There's little welcome for {them} among {people}, {why}",
    "{people} speak of {them} sourly, {why}",
    "Among {people}, {their} name gets a scowl, {why}",
  },
  WHY_KILL = {
    "after what happened in {where}",
    "after the {foes} {they've} cut down in {where}",
    "not since the business with the {foes} in {where}",
    "on account of the {foes} in {where}",
    "for the {foes} {they} put down in {where}",
  },
  WHY_QUEST = { "over {quest}", "ever since {quest}", "after {quest}", "not since {quest}", "all because of {quest}" },
  -- A faction they've done much for, and what for.
  GOOD = {
    "{people} speak well of {them}, mostly {why}",
    "Among {people}, {their} name comes up kindly, {why}",
    "{people} have a good word for {them}, {why}",
    "{people} count {them} a help, {why}",
    "{people} are glad of {them}, {why}",
  },
  GOOD_KILL = {
    "for the {foes} {they've} cleared out of {where}",
    "for clearing {foes} out of {where}",
    "for the work against the {foes} in {where}",
    "for thinning out the {foes} in {where}",
  },
  GOOD_QUEST = { "for {quest}", "for seeing {quest} through", "for the help with {quest}", "for {their} work on {quest}" },
  GOOD_QUESTS = { "for {quest}, {times} over", "for answering {quest} {times}", "for coming back with {quest} {times}",
    "for turning in {quest} {times}" },
  -- Losses with a faction in the last two weeks.
  COOLING = {
    "{people} have cooled toward {them} lately",
    "{people} have been less glad to see {them} of late",
    "{people} have had less to say to {them} these past weeks",
    "{their} welcome among {people} has worn thin lately",
    "{people} are warier of {them} than they were",
  },
  -- Guards killed ({n}), or guards who had the better of them ({times}).
  GUARDS_KILLED = {
    "The guards of {place} haven't forgotten the {n} of their own who fell to {them}",
    "In {place} the guards keep a close eye on {them}, after losing {n} of their number",
    "The watch in {place} still counts the {n} of its guards {they've} put down",
    "The guards around {place} have reason to remember {them}: {n} of theirs fell to {them}",
    "Nobody on guard in {place} has forgotten {them}, or the {n} they lost",
  },
  GUARDS_WON = {
    "The guards of {place} have had to put {them} down {times}",
    "The guards in {place} have seen {them} off {times}",
    "In {place}, the guards have had the better of {them} {times}",
    "The guards around {place} have laid {them} out {times}",
  },
  -- The war: kills in one land ({n}, three or more), or deaths to the other side ({times}).
  HONOUR = {
    "In {zone}, the {enemy} have lost {n} fighters to {them}",
    "The {enemy} in {zone} have learned to watch for {them}, after {n} of theirs fell",
    "Word among the {enemy} in {zone} is to mind {them}; {they've} put down {n} of theirs there",
    "The {enemy} count {n} of their own lost to {them} in {zone}",
    "The {enemy} who pass through {zone} have {n} reasons to give {them} room",
  },
  HONOUR_LOST = {
    "The {enemy} in {zone} have had the better of {them} {times}",
    "In {zone}, the {enemy} have sent {them} to the spirit healer {times}",
    "The {enemy} raiding {zone} have caught {them} out {times}",
    "The {enemy} around {zone} have brought {them} down {times}",
  },
  -- History news: a step down to Neutral or worse, a step down otherwise ({word}), a run of
  -- losses, a great deal of work.
  EV_FELL = { "fell out with {faction}", "lost the goodwill of {faction}", "wore out {their} welcome with {faction}",
    "fell from favour with {faction}", "found {faction} turned against {them}" },
  EV_SLIP = { "slipped to {word} with {faction}", "dropped back to {word} with {faction}", "fell back to {word} with {faction}",
    "lost a step with {faction}, down to {word}" },
  EV_LOST = { "lost ground with {faction}", "lost standing with {faction}", "gave {faction} cause to think less of {them}",
    "set {faction} against {them} a step at a time", "spent some of {their} goodwill with {faction}" },
  EV_WORK = { "did a good deal of work for {faction}", "put in long days for {faction}", "gave {faction} plenty of help",
    "kept busy on behalf of {faction}", "earned the thanks of {faction} more than once" },
  -- Full title, from real standing (Revered, Exalted). Kept modest.
  TITLE = {
    Revered = { "Friend of {faction}", "Helper of {faction}", "Ally of {faction}" },
    Exalted = { "Friend of {faction}", "Trusted by {faction}", "Sworn Friend of {faction}" },
  },
}

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

-- The shape of their time (Sources/Seasons.lua): the hours they keep, the days they come,
-- anniversaries, absences and returns, the festivals they kept, how a season went. {name}
-- is the character's first name; the rest are filled by Compose (TimeLines, the Lately glance).
W.SEASONS = {
  -- By the game's clock, from the hours they're usually abroad.
  night = {
    "Is most often abroad after dark",
    "Keeps late hours, and does most of {their} travelling after nightfall",
    "Is seen about far more by night than by day",
    "Tends to be out once the sun is down and the roads are quiet",
    "Does most of {their} business after dark, going by the hours {they} keep{s}",
  },
  dawn = {
    "Is an early riser, usually on the road by first light",
    "Keeps early hours, and is mostly abroad in the morning",
    "Likes an early start: most of {their} days begin at dawn",
    "Is usually up and about while the dew is still on the grass",
  },
  day = {
    "Keeps to the daylight, and is seldom out after dark",
    "Travels by day and is rarely seen once night falls",
    "Keeps honest daylight hours on the road",
    "Is mostly about between morning and dusk, and indoors by nightfall",
  },
  evening = {
    "Is mostly about in the evenings",
    "Tends to take to the road as the day draws in",
    "Is most often seen at dusk and into the evening",
    "Does most of {their} travelling in the last hours of the day",
  },
  -- The real days of the week. {day}: "Tuesday".
  weekend = {
    "Is mostly seen at the end of the week",
    "Turns up chiefly at the week's end, and is scarcer in between",
    "Keeps the end of the week for {their} travels",
    "Is a week's-end traveller, more often than not",
  },
  weekday = {
    "Is most often seen of a {day}",
    "Can usually be found on the road on a {day}",
    "Has a habit of turning up on {day}s",
    "Is about more on {day}s than on any other day",
  },
  -- Anniversaries. {span}: "a year", "two years", "half a year", "a hundred days", "a month";
  -- {when}: "this week" or "today"; {rank}: the rank risen to.
  anniv = {
    "It's {span} {when} since {name} first set out",
    "{span} ago {when}, {name} first took to the road",
    "{name} has been on the road {span} {when}",
    "{when} makes {span} since {name} set out",
    "It was {span} ago {when} that {name}'s road began",
  },
  anniv_rank = {
    "It's {span} {when} since {name} rose to {rank}",
    "{span} ago {when}, {name} rose to {rank}",
    "{name} rose to {rank} {span} ago {when}",
    "{when} makes {span} since {name} rose to {rank}",
  },
  -- Coming back. {span}: "eleven days", "three weeks".
  back = {
    "Came back after {span} away",
    "Has only lately come back, after {span} away",
    "Turned up again after {span} gone",
    "Is newly back on the road after {span} away",
    "Is back again, after {span} away from the road",
  },
  gap = {
    "Was gone {span} once, and came back",
    "Once went {span} without being seen on the road",
    "Has been away as long as {span} before now",
    "Once dropped out of sight for {span}",
  },
  -- Runs of days. {n}: "seven".
  streak = {
    "Has been on the road {n} days running",
    "Hasn't missed a day in {n}",
    "Has been out every one of the last {n} days",
    "Has kept at it {n} days straight",
  },
  -- The longest session. {span}: "nine hours".
  longest = {
    "Has gone {span} at a stretch before now",
    "Once stayed out {span} straight",
    "{name}'s longest day on the road ran to {span}",
    "Can keep going for {span} at a time",
  },
  -- Festivals. {fest}: "Hallow's End"; {zone}; {list}: several festivals.
  fest = {
    "Spent {fest} in {zone}",
    "Kept {fest} in {zone}",
    "Was in {zone} for {fest}",
    "Saw {fest} through in {zone}",
    "Marked {fest} in {zone}",
  },
  fest_list = {
    "Has kept {list} on the road",
    "Has turned out for {list}",
    "Has made time for {list}",
    "Has joined in {list} in {their} time",
  },
  faire = {
    "Has been to the Darkmoon Faire {times}",
    "Has visited the Darkmoon Faire {times}",
    "Has called at the Darkmoon Faire {times}",
    "Has taken in the Darkmoon Faire {times}",
    "Knows the Darkmoon Faire, having been {times}",
  },
  -- How the season (or the month) just past went. {season}: "autumn"; {month}: "October".
  season_hard = {
    "Had a hard {season} of it",
    "The {season} went hard for {them}",
    "Came through a bleak {season}",
    "Found the {season} a hard one",
    "Has had a rough {season}",
  },
  season_good = {
    "Had a good {season}",
    "The {season} treated {them} well",
    "Came through the {season} in good heart",
    "Found the {season} a kind one",
    "Had the best of the {season}",
  },
  month_hard = {
    "{month} was a hard month for {them}",
    "Had a bleak {month}",
    "Found {month} hard going",
    "{month} went badly for {them}",
  },
  month_good = {
    "{month} was a good month for {them}",
    "Had a fine {month}",
    "{month} went well for {them}",
    "Did well through {month}",
  },
  -- The Lately glance.
  lately_anniv = {
    "{span} ago {when}, {name} first set out.",
    "{name} has been on the road {span} {when}.",
    "It's {span} {when} since {name} took to the road.",
    "{when} makes {span} on the road for {name}.",
  },
  lately_rank = {
    "It's {span} {when} since {name} rose to {rank}.",
    "{span} ago {when}, {name} rose to {rank}.",
    "{when} makes {span} since {name} rose to {rank}.",
    "{name} rose to {rank} {span} ago {when}.",
  },
  lately_fest = {
    "Out for {fest} in {zone}.",
    "Keeping {fest} in {zone}.",
    "In {zone} for {fest}.",
    "Making the most of {fest} in {zone}.",
    "Turned out for {fest}, in {zone}.",
  },
  lately_faire = {
    "At the Darkmoon Faire in {zone}.",
    "Spent some of the day at the Darkmoon Faire in {zone}.",
    "Took in the Darkmoon Faire in {zone}.",
    "Down at the Darkmoon Faire in {zone}.",
  },
  lately_back = {
    "Back on the road after {span} away.",
    "Only just back, after {span} gone.",
    "Newly returned after {span} away.",
    "Has come back after {span} away.",
    "Out again after {span} away.",
  },
  -- The journal, in the character's own voice.
  journal = {
    anniv = {
      "It's {span} this week since I set out",
      "{span} on the road now, near enough to the day",
      "I've been on the road {span} this week",
      "{span} since I first set out, and I thought about that today",
    },
    anniv_rank = {
      "It's {span} since I rose to {rank}",
      "{span} now since I rose to {rank}",
      "I rose to {rank} {span} ago this week",
      "{span} as {rank}, near enough",
    },
    back = {
      "Back on the road after {span} away",
      "First day back after {span}",
      "{span} away, and now back on the road",
      "I came back today after {span} away",
    },
    fest = {
      "{fest} was on, and I kept it in {zone}",
      "I kept {fest} in {zone}",
      "Spent some of the day on {fest} in {zone}",
      "{fest} in {zone}, and I joined in",
    },
  },
  -- Lately's headings, by the span.
  titles = { year = "A Year On", half = "Half a Year On", hundred = "A Hundred Days", month = "A Month On" },
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
-- ======================== PHYSICAL (0.21.0) ==============================
-- About: Physical and the Marks glance: how the body carries itself, what is worn and
-- how, and what is on them right now (spells, sickness, drink, shapes). Everything here is
-- used only when the game says so: armour by what most of it is, weapons by their type,
-- auras by their names. {main} {off} {ranged} {item} {set} are filled with real items.
---------------------------------------------------------------------------
-- Every one of a race shares these: voice, gait, bulk. Nothing a player can customise.
W.RACE_BEARING = {
  Human = { "Speaks plainly, in the common tongue of the eastern kingdoms.", "Neither tall nor short, and easy to lose in a crowd." },
  Dwarf = { "Speaks with a deep mountain burr.", "Plants {their} feet like {they} mean{s} to stay there." },
  Gnome = { "Talks quickly, in a high, bright voice.", "Has to look up at almost everyone, and doesn't seem to mind." },
  NightElf = { "Moves almost without sound.", "Has the patience of a people who count their lives in centuries." },
  Orc = { "Speaks in a rough, growling voice.", "Takes up more room than most, and knows it." },
  Troll = { "Talks with the rolling lilt of the jungle tribes.", "Stands stooped, and still looks down on most people." },
  Tauren = { "Each step lands heavy.", "Speaks slowly, in a low, rumbling voice." },
  Scourge = { "Joints creak when {they} move{s}, and {their} voice rasps.", "Smells of grave-earth, the way all the Forsaken do." },
  Goblin = { "Talks fast, and usually about money.", "Quick-handed, with a voice that carries." },
}
W.RACE_LOOK.Goblin = W.RACE_LOOK.Goblin or { "Small and green, with long ears and sharp teeth.", "Big-eared and sharp-toothed, with quick, calculating eyes." }

-- How a class carries itself, by how far along the road they are (under 20, under 45, beyond).
W.PHYS_STANCE = {
  WARRIOR = {
    green = { "Stands square, like someone still drilling the basics.", "Holds {themselves} stiffly, the way new recruits do." },
    seasoned = { "Stands with {their} weight forward, ready to move.", "Plants {their} feet wide out of habit." },
    veteran = { "Moves with the unhurried economy of someone who has fought for years.", "Stands loose and balanced, never caught flat-footed." },
  },
  PALADIN = {
    green = { "Stands very straight, as if someone were watching.", "Carries {themselves} with a novice's careful dignity." },
    seasoned = { "Upright and steady, with a calm that doesn't shift much.", "Holds {their} head up and {their} shoulders back." },
    veteran = { "Stands with the settled calm of long service.", "Has the steady, patient bearing of someone sworn for years." },
  },
  HUNTER = {
    green = { "Keeps glancing at the edges of things, still learning to watch.", "Restless, with a newcomer's ear for every sound." },
    seasoned = { "Quiet on {their} feet, eyes always moving.", "Stands loose and easy, ready to turn." },
    veteran = { "Goes still in a way only long years in the wild teach.", "Watches the world with the patience of a practised tracker." },
  },
  ROGUE = {
    green = { "Fidgety, and too obvious about watching the door.", "Tries hard to look like nobody in particular." },
    seasoned = { "Keeps {their} back to the wall and {their} face hard to read.", "Light on {their} feet and hard to pin down." },
    veteran = { "Easy to overlook, which is plainly on purpose.", "Moves so quietly that people lose track of {them}." },
  },
  PRIEST = {
    green = { "Earnest and attentive, and quick to notice who is hurting.", "Holds {themselves} with a novice's careful piety." },
    seasoned = { "Patient, with a healer's steady hands.", "Calm and watchful, in the way of someone who mends people." },
    veteran = { "Has the deep, settled calm of long devotion.", "Unhurried, with the composed face of a long-serving healer." },
  },
  SHAMAN = {
    green = { "Tilts {their} head now and then, as if listening for something.", "Earnest, and still finding {their} footing with the spirits." },
    seasoned = { "Grounded and steady, rooted where {they} stand{s}.", "Has a listener's stillness about {them}." },
    veteran = { "Calm in the deep way of someone the elements answer.", "Still as old stone, until {they} move{s}." },
  },
  MAGE = {
    green = { "Bright-eyed and too eager to explain things.", "Has the restless fingers of an apprentice." },
    seasoned = { "Composed and precise, choosing words with care.", "Holds {themselves} with a scholar's poise." },
    veteran = { "Cool and exact, with the poise of long practice.", "Unhurried and certain, like someone who has read the ending." },
  },
  WARLOCK = {
    green = { "Wary, as if braced for something to go wrong.", "Keeps {their} distance, and {their} voice low." },
    seasoned = { "Cool and guarded, giving little away.", "Has a stillness about {them} that unsettles people." },
    veteran = { "Cold, composed and hard to read.", "Self-possessed in a way that makes others step back." },
  },
  DRUID = {
    green = { "Moves with an awkward, half-learned grace.", "Restless under a roof, and plainly happier outside." },
    seasoned = { "Easy in {their} body, and quiet on {their} feet.", "Has the patient stillness of someone who watches animals." },
    veteran = { "Patient as the old groves.", "Moves like something wild that has decided to trust you." },
  },
  DEATHKNIGHT = {
    green = { "Holds {themselves} with a cold, deliberate stillness." },
    seasoned = { "Moves with a heavy, purposeful tread." },
    veteran = { "Cold and deliberate, wasting no movement at all." },
  },
}

-- How they are in body right now, by health (out of a fight) and rest.
W.PHYS_HEALTH = {
  { max = 0.25, glance = "Badly Hurt", text = { "Badly hurt, and moving stiffly to spare it", "Hurt badly, and every step gives it away" } },
  { max = 0.5, glance = "Bloodied", text = { "Freshly wounded, and moving carefully", "Carrying fresh wounds, and favouring them" } },
  { max = 0.8, text = { "Nursing a few fresh hurts", "Somewhat the worse for wear from a recent scrape" } },
}
W.PHYS_RESTED = { "Looks well rested", "Rested and clear-eyed" }
W.PHYS_UNRESTED = { "Has the drawn look of someone overdue for a night in a proper bed", "Road-weary, and short of a good night's sleep" }
W.PHYS_UNHURT = { "Unhurt for now, and steady on {their} feet", "Whole and unhurt at the moment", "Hale, with nothing ailing {them} just now" }

-- Armour, by what most of it is.
W.ARMOUR_WORD = { Cloth = "cloth", Leather = "leather", Mail = "mail", Plate = "plate" }
W.PHYS_ARMOUR = {
  Cloth = { "Goes about in cloth, soft and unarmoured", "Dresses in cloth, light and loose", "Wears cloth, and nothing heavier" },
  Leather = { "Goes about in leather, close-fitting and quiet", "Dresses in supple leather", "Wears leather that creaks softly when {they} move{s}" },
  Mail = { "Goes about in mail", "Wears mail that chinks softly with each step", "Is armoured in mail" },
  Plate = { "Goes about in plate", "Wears heavy plate, and the clank of it announces {them}", "Is armoured in plate, heavy and close-fitted" },
}
W.PHYS_ARMOUR_MIX = { "Wears a mix of {list}", "Goes about in a patchwork of {list}" }
-- Lighter than the class usually wears by then (plate classes from forty, mail from forty).
W.PHYS_ARMOUR_LIGHT = { "Lighter than most of {their} calling would choose", "Light gear, for one of {their} calling" }

-- How fine it is, by the quality most pieces share: a clause after the armour.
W.QUALITY_WORD = { [0] = "worn out", [1] = "plain and serviceable", [2] = "sound, honest work", [3] = "fine work",
  [4] = "remarkable", [5] = "beyond price" }
W.PHYS_QUALITY = {
  all = { "All of it is {word}", "Every piece of it is {word}" },
  most = { "Most of it is {word}", "The bulk of it is {word}" },
  finer = { "with one finer piece among it", "and one piece is finer than the rest" },
  finerN = { "with {n} finer pieces among it", "and {n} pieces are finer than the rest" },
}
-- How it sits with their experience (from the items' level against their own).
W.PHYS_FIT = {
  behind = { "Much of it is older gear {they've} outgrown", "Most of it is kit {they} could do better than by now" },
  ahead = { "Better gear than most at {their} stage of the road", "Finer kit than {their} years on the road would suggest" },
  top = { "The kind of gear only the hardest fights give up" },
}

-- The pieces that show: chest first, then head and shoulders.
W.PHYS_OUTFIT = {
  armoured = { "Chief among it is {outfit}", "Most noticeable is {outfit}", "What shows first is {outfit}" },
  bare = { "{they} wear{s} {outfit}", "{they} go{es} about in {outfit}" },
}
W.PHYS_ON = { [1] = "on {their} head", [3] = "across {their} shoulders" }
W.PHYS_LAYERS = {
  both = { "{cloak} hangs at {their} back, and {tabard} goes over the top", "Over it all go {tabard} and, at {their} back, {cloak}" },
  tabard = { "{tabard} is worn over the top", "Over it all {they} wear{s} {tabard}" },
  cloak = { "{cloak} hangs at {their} back", "{cloak} falls behind {them}", "{they} wear{s} {cloak} at {their} back" },
  shirt = { "Above the waist {they} wear{s} only {shirt}", "{shirt} is all {they} wear{s} above the waist" },
}

-- Weapons, by how they're carried. {kind} is what the weapon is ("a great axe").
W.TWO_HANDED = { ["Two-Handed Axes"] = true, ["Two-Handed Swords"] = true, ["Two-Handed Maces"] = true, Polearms = true, Staves = true }
W.PHYS_ARMS = {
  twohand = { "{main}, {kind}, is slung across {their} back", "Carries {main}, {kind}, across {their} back", "Goes armed with {main}, {kind} that takes both hands" },
  staff = { "{main}, {their} staff, is never far from {their} hand", "Carries {main}, a staff", "Walks with {main}, a staff" },
  dual = { "Carries a weapon for each hand: {main} and {off}", "Fights with {main} and {off}, one in each hand", "Wears {main} and {off} at {their} sides" },
  shield = { "Carries {main}, with {shield} slung on {their} back", "{main} hangs at {their} side, {shield} on {their} back", "Goes armed with {main} and {shield}" },
  holdable = { "Carries {main}, with {off} held in the other hand", "{main} at {their} side, and {off} in the other hand" },
  one = { "{main} hangs at {their} side", "Carries {main}, {kind}", "Goes armed with {main}, {kind}" },
  offonly = { "Carries {off}, and nothing else in hand" },
  none = { "Carries no weapon anyone can see", "Goes unarmed, as far as anyone can tell" },
}
W.PHYS_RANGED = {
  Bows = { "{ranged}, a bow, rides on {their} back", "Keeps {ranged}, a bow, ready over {their} shoulder" },
  Crossbows = { "{ranged}, a crossbow, is slung on {their} back", "Carries {ranged}, a crossbow, on {their} back" },
  Guns = { "{ranged}, a gun, is slung across {their} back", "Carries {ranged}, a gun, on {their} back" },
  Wands = { "Keeps {ranged}, a wand, at {their} hip", "Carries {ranged}, a wand, within easy reach" },
  Thrown = { "Carries {ranged} for throwing", "Keeps {ranged} ready to throw" },
  Idols = { "Keeps {ranged}, a druid's idol, close", "Carries {ranged}, a druid's idol" },
  Totems = { "Keeps {ranged}, a shaman's totem, close", "Carries {ranged}, a shaman's totem" },
  Librams = { "Keeps {ranged}, a paladin's libram, close", "Carries {ranged}, a paladin's libram" },
  default = { "Carries {ranged} as well" },
}

-- Matched pieces, enchantments, jewellery and the finest piece.
W.PHYS_SET = {
  named = { "{n} of the pieces match, all from {set}", "{n} pieces are a matched set, {set}", "Part of it is matched: {n} pieces of {set}" },
  unnamed = { "{n} of the pieces match, made as a set", "{n} pieces were plainly made to go together" },
  full = { "{n} of the pieces make up one matched set, {set}", "Most of it is one matched set: {n} pieces of {set}" },
}
W.PHYS_ENCHANT = {
  weapon = { "{main} carries an enchanter's work", "{main} has been enchanted" },
  it = { "It has been enchanted, too", "An enchanter has worked on it as well" },
  one = { "{item} has been enchanted", "{item} carries an enchanter's work" },
  many = { "{n} of the pieces carry an enchanter's work", "{n} pieces have been enchanted" },
}
W.PHYS_JEWEL = {
  ring = { "Wears {item} on one finger", "{item} sits on one finger" },
  rings = { "Wears {item} and {item2}, one on each hand" },
  neck = { "{item} hangs at {their} throat", "Wears {item} at {their} throat" },
  neckAlso = { "with {item} at {their} throat", "and {item} hangs at {their} throat" },
  trinket = { "Keeps {item} about {them}", "Carries {item} as well" },
}
W.PHYS_FINEST = { "The finest piece is {item}", "The best of it is {item}", "Nothing else {they} wear{s} matches {item}" }

-- What is on them right now, from their auras. Each `names` is matched exactly, `prefix`
-- by the start of the name. `glance` titles the Marks glance; prio ranks it.
W.AURA_LOOK = {
  { names = { "Ice Block" }, prio = 6.8, glance = "Encased in Ice", icon = "Spell_Frost_Frost",
    text = { "Locked inside a block of ice", "Sealed in a shell of solid ice" } },
  { names = { "Divine Shield", "Divine Protection", "Blessing of Protection" }, prio = 6.7, glance = "Shielded by the Light", icon = "Spell_Holy_DivineIntervention",
    text = { "Blazing inside a dome of golden light", "Wrapped in a shell of golden light" } },
  { names = { "Shadowmeld" }, prio = 5.5, glance = "In the Shadows", icon = "Ability_Ambush",
    text = { "Melted into the shadows, all but invisible" } },
  { names = { "Power Word: Shield" }, prio = 4.8, glance = "Warded", icon = "Spell_Holy_PowerWordShield",
    text = { "A shimmering ward of holy light surrounds {them}", "Held inside a bright, shimmering ward" } },
  { names = { "Inner Fire" }, prio = 4.7, glance = "Inner Fire", icon = "Spell_Holy_InnerFire",
    text = { "A pale holy fire flickers over {their} skin", "Wrapped in a thin glow of holy fire" } },
  { names = { "Lightning Shield" }, prio = 4.7, glance = "Crackling", icon = "Spell_Nature_LightningShield",
    text = { "Small orbs of lightning circle {them}, crackling", "Lightning circles {them} in little spitting orbs" } },
  { names = { "Demon Skin", "Demon Armor" }, prio = 4.6, glance = "Fel-Warded", icon = "Spell_Shadow_RagingScream",
    text = { "{their} skin has a dark, hard sheen, a demon's ward", "A sullen fel glow clings to {their} skin" } },
  { names = { "Frost Armor", "Ice Armor" }, prio = 4.6, glance = "Rimed in Frost", icon = "Spell_Frost_FrostArmor02",
    text = { "Frost creeps over {them}, and the air nearby is cold", "Rimed with a thin skin of frost" } },
  { names = { "Mage Armor" }, prio = 4.5, glance = "Arcane Ward", icon = "Spell_MageArmor",
    text = { "A pale arcane shimmer wraps {them}", "The air around {them} shimmers with arcane force" } },
  { names = { "Fire Shield" }, prio = 4.5, glance = "Wreathed in Flame", icon = "Spell_Fire_FireArmor",
    text = { "Flames lick harmlessly about {them}", "Ringed in small, harmless flames" } },
  { names = { "Thorns" }, prio = 4.4, glance = "Thorn-Wrapped", icon = "Spell_Nature_Thorns",
    text = { "Thorny vines twist about {them}", "Wrapped in a thorny, living ward" } },
  { names = { "Stoneskin" }, prio = 4.3, glance = "Stoneskin", icon = "Spell_Nature_StoneSkinTotem",
    text = { "{their} skin has the hard grey look of stone", "Looks hard as stone, by a shaman's grace" } },
  { names = { "Rallying Cry of the Dragonslayer", "Songflower Serenade", "Spirit of Zandalar", "Warchief's Blessing",
    "Fengus' Ferocity", "Mol'dar's Moxie", "Slip'kik's Savvy", "Boon of Blackfathom" }, prio = 3.6, glance = "A City's Blessing", icon = "Spell_Holy_PrayerOfHealing",
    text = { "Still carries the blessing of {aura}", "{aura} is still on {them}" } },
  { names = { "Well Fed" }, prefix = "Well Fed", prio = 2, glance = "Well Fed", icon = "Spell_Misc_Food",
    text = { "Has eaten well, and looks it", "Well fed, and the better for it" } },
  { names = { "Mark of the Wild", "Gift of the Wild" }, prio = 1.5, icon = "Spell_Nature_Regeneration",
    text = { "Carries a druid's blessing, the Mark of the Wild" } },
  { prefix = "Blessing of", prio = 1.5, icon = "Spell_Holy_FistOfJustice", text = { "Carries a paladin's blessing" } },
  { prefix = "Greater Blessing of", prio = 1.5, icon = "Spell_Holy_FistOfJustice", text = { "Carries a paladin's blessing" } },
  { names = { "Power Word: Fortitude", "Prayer of Fortitude" }, prio = 1.4, icon = "Spell_Holy_WordFortitude",
    text = { "Stands steadier for a priest's blessing of fortitude" } },
  { names = { "Arcane Intellect", "Arcane Brilliance" }, prio = 1.3, icon = "Spell_Holy_MagicalSentry",
    text = { "A mage's Arcane Intellect sharpens {their} eyes" } },
}
-- Shapes, by aura name (the shape's own phrase comes from World.Form).
W.FORM_MARK = {
  ["Bear Form"] = { "Bear-Shaped", "Ability_Racial_BearForm" }, ["Dire Bear Form"] = { "Bear-Shaped", "Ability_Racial_BearForm" },
  ["Cat Form"] = { "Cat-Shaped", "Ability_Druid_CatForm" }, ["Travel Form"] = { "Stag-Shaped", "Ability_Druid_TravelForm" },
  ["Aquatic Form"] = { "Sea-Shaped", "Ability_Druid_AquaticForm" }, ["Moonkin Form"] = { "Moonkin", "Spell_Nature_ForceOfNature" },
  ["Ghost Wolf"] = { "Ghost Wolf", "Spell_Nature_SpiritWolf" }, ["Shadowform"] = { "Shadowform", "Spell_Shadow_Shadowform" },
}
W.PHYS_FORM = { "Is {form} for now", "For now {they're} {form}" }
W.PHYS_MOUNT = { "Is {mount} for now", "For now {they're} {mount}" }
W.PHYS_STEALTH = { "Keeps to the shadows, hard to make out at all", "Hard to see at all, keeping to the shadows" }
W.PHYS_GHOST = { "A spirit for now, pale and drifting", "Only a ghost at the moment, pale and half-there" }
W.PHYS_MEAL = { eating = { "In the middle of a meal" }, drinking = { "Taking a long, slow drink" } }
W.PHYS_PET = { "{pet} the {kind} keeps close", "{pet}, {their} {kind}, is never far away" }
-- Drink, by how much (the game's own "tipsy", "drunk", "completely smashed").
W.PHYS_DRUNK = {
  { glance = "Tipsy", text = { "Tipsy, and cheerful with it", "Loose-limbed and merry with drink" } },
  { glance = "Smells of Ale", text = { "Plainly drunk, and smelling of it", "Unsteady on {their} feet, and smelling of drink" } },
  { glance = "Roaring Drunk", text = { "Thoroughly drunk, and none too steady", "Drunk enough to sway where {they} stand{s}" } },
}
-- Afflictions, by the kind the game gives them.
W.PHYS_AILMENT = {
  Disease = { prio = 7.4, glance = "Sickly", icon = "Spell_Shadow_AbominationExplosion",
    text = { "Has the hollow, feverish look of someone fighting off a disease", "Sickly and feverish, with a disease on {them}" } },
  Poison = { prio = 7.3, glance = "Poisoned", icon = "Spell_Nature_CorrosiveBreath",
    text = { "Sweating and unsteady, with poison in {their} blood", "Grey and shaky with poison" } },
  Curse = { prio = 7.2, glance = "Cursed", icon = "Spell_Shadow_AntiShadow",
    text = { "Something about {them} feels cursed, and it hasn't lifted", "Labours under a curse that hasn't lifted yet" } },
  Magic = { prio = 3, glance = "Spellbound", icon = "Spell_Shadow_Teleport",
    text = { "Some spell still clings to {them}", "Still under some spell or other" } },
}
W.PHYS_RESSICK = { "Weak and grey, newly back from death", "Newly back from death, and weak with it" }
-- Gear marks for the glance.
W.PHYS_MARK = {
  set = { "Matched Set", "INV_Chest_Plate03" }, enchanted = { "Enchanted Weapon", "Spell_Holy_GreaterHeal" },
  twohand = { "Great Weapon", "INV_Axe_09" }, dual = { "Two Weapons", "Ability_DualWield" },
  jewel = { "Rare Jewellery", "INV_Jewelry_Ring_15" }, plate = { "Plate-Clad", "INV_Chest_Plate01" },
}
-- ====================== end of PHYSICAL (0.21.0) =========================

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
  -- Company: see W.COMPANY at the end of this file.
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
-- Auto TRP's own reading of the character (Sources/Self.lua), for when RPG Dialogue isn't
-- there to say: the stories quest chains tell, the towns and their factions, what counts as
-- holy, playful or not a book, and the few lines History needs for it.
---------------------------------------------------------------------------
-- Storylines, by the quests that make them up (English titles, as the game shows them).
-- ends: the quests that settle it (then it's seen through); otherwise it's only followed.
-- title reads after "saw ... through to the end", "got caught up in ...", "stories about ...".
W.SELF_STORIES = {
  -- Eastern Kingdoms
  { id = "echo_ridge", zone = "Elwynn Forest", title = "the kobold trouble at Echo Ridge",
    quests = { "Kobold Camp Cleanup", "Investigate Echo Ridge" }, ends = { "Skirmish at Echo Ridge" } },
  { id = "riverpaw", zone = "Elwynn Forest", title = "the gnoll raids on Elwynn's border",
    quests = { "Riverpaw Gnoll Bounty", "Protect the Frontier", "Find the Lost Guards", "Discover Rolf's Fate", "Report to Thomas" },
    ends = { "Wanted: \"Hogger\"" } },
  { id = "young_lovers", zone = "Elwynn Forest", title = "the Maclure girl's secret romance",
    quests = { "Young Lovers", "Speak with Gramma", "Note to William", "Collecting Kelp" }, ends = { "The Escape" } },
  { id = "stonefield", zone = "Elwynn Forest", title = "the Stonefields' trouble with a pig",
    quests = {}, ends = { "Princess Must Die!" } },
  { id = "westfall_farms", zone = "Westfall", title = "the hunger on Westfall's farms",
    quests = { "The Killing Fields", "Poor Old Blanchy", "Westfall Stew", "Goretusk Liver Pie", "The Forgotten Heirloom" } },
  { id = "defias", zone = "Westfall", title = "the Defias trouble in Westfall",
    quests = { "Red Leather Bandanas", "The People's Militia", "Patrolling Westfall" }, ends = { "The Defias Brotherhood" } },
  { id = "redridge_blackrock", zone = "Redridge Mountains", title = "the Blackrock threat to Lakeshire",
    quests = { "Blackrock Menace", "Blackrock Bounty", "Shadow Magic", "Assessing the Threat", "Solomon's Law", "Wanted: Lieutenant Fangore" } },
  { id = "stalvan", zone = "Duskwood", title = "the old story of Stalvan Mistmantle",
    quests = { "An Old History Book", "Mistmantle's Revenge" }, ends = { "The Legend of Stalvan", "Stalvan Mistmantle" } },
  { id = "morbent", zone = "Duskwood", title = "the trouble with Duskwood's walking dead",
    quests = { "The Hermit", "Seeking Wisdom", "The Daughter Who Lived", "A Daughter's Love" }, ends = { "Morbent Fel" } },
  { id = "morladim", zone = "Duskwood", title = "the haunting of Raven Hill",
    quests = { "The Totem of Infliction" }, ends = { "Mor'Ladim" } },
  { id = "nesingwary", zone = "Stranglethorn Vale", title = "Nesingwary's great hunt",
    quests = { "Welcome to the Jungle", "Raptor Mastery", "Tiger Mastery", "Panther Mastery" }, ends = { "Big Game Hunter" } },
  { id = "coldridge", zone = "Dun Morogh", title = "the troll trouble in Coldridge Valley",
    quests = { "Dwarven Outfitters", "Coldridge Valley Mail Delivery", "A New Threat" }, ends = { "The Troll Cave" } },
  { id = "darrowshire", zone = "Eastern Plaguelands", title = "the ghosts of Darrowshire",
    quests = { "Sister Pamela", "Pamela's Doll", "Uncle Carlin" }, ends = { "Battle of Darrowshire" } },
  -- Kalimdor
  { id = "burning_blade", zone = "Durotar", title = "the Burning Blade's hold on Durotar",
    quests = { "Vile Familiars", "Dark Storms" }, ends = { "Burning Blade Medallion" } },
  { id = "zalazane", zone = "Durotar", title = "the trouble with Zalazane on the Echo Isles",
    quests = { "Minshina's Skull", "Report to Sen'jin Village" }, ends = { "Zalazane" } },
  { id = "earthmother", zone = "Mulgore", title = "the rites of the Earthmother",
    quests = { "Rite of Strength", "Rites of the Earthmother", "Rite of Vision", "Rite of Wisdom" }, ends = { "Journey into Thunder Bluff" } },
  { id = "kolkar", zone = "The Barrens", title = "the Kolkar war in the Barrens",
    quests = { "Centaur Bracers", "Kolkar Leaders" }, ends = { "Counterattack!" } },
  { id = "mankrik", zone = "The Barrens", title = "the search for Mankrik's wife", quests = {}, ends = { "Lost in Battle" } },
  { id = "shadowglen", zone = "Teldrassil", title = "the sickness in Shadowglen",
    quests = { "The Balance of Nature", "Webwood Venom", "Webwood Egg", "Tenaron's Summons" }, ends = { "Crown of the Earth" } },
  { id = "prospector", zone = "Darkshore", title = "the rescue of Prospector Remtravel",
    quests = {}, ends = { "The Absent Minded Prospector" } },
  { id = "althalaxx", zone = "Darkshore", title = "the business of the Tower of Althalaxx", quests = {}, ends = { "The Tower of Althalaxx" } },
}

-- A land where many jobs were done, and no chain above tells it: its troubles in a phrase.
W.SELF_ZONE_STORY = {
  ["Elwynn Forest"] = "the troubles of Elwynn's farms and mines", ["Westfall"] = "the troubles of Westfall's farmers",
  ["Redridge Mountains"] = "the troubles of Lakeshire", ["Duskwood"] = "the long night over Duskwood",
  ["Loch Modan"] = "the troubles of Loch Modan", ["Dun Morogh"] = "the troubles of Dun Morogh",
  ["Wetlands"] = "the troubles of Menethil Harbor", ["Stranglethorn Vale"] = "the troubles of Stranglethorn",
  ["Teldrassil"] = "the troubles of Teldrassil", ["Darkshore"] = "the troubles of Darkshore",
  ["Durotar"] = "the troubles of Durotar", ["Mulgore"] = "the troubles of Mulgore",
  ["Tirisfal Glades"] = "the troubles of Tirisfal", ["Silverpine Forest"] = "the troubles of Silverpine",
  ["The Barrens"] = "the troubles of the Barrens", ["Ashenvale"] = "the troubles of Ashenvale",
}

-- A town's people, by the faction they answer to (for how well thought of you are there).
W.SELF_TOWN_FACTION = {
  ["Goldshire"] = "Stormwind", ["Northshire Abbey"] = "Stormwind", ["Sentinel Hill"] = "Stormwind",
  ["Lakeshire"] = "Stormwind", ["Darkshire"] = "Stormwind", ["Stormwind City"] = "Stormwind",
  ["Ironforge"] = "Ironforge", ["Kharanos"] = "Ironforge", ["Thelsamar"] = "Ironforge", ["Menethil Harbor"] = "Ironforge",
  ["Darnassus"] = "Darnassus", ["Dolanaar"] = "Darnassus", ["Auberdine"] = "Darnassus", ["Astranaar"] = "Darnassus",
  ["Orgrimmar"] = "Orgrimmar", ["Razor Hill"] = "Orgrimmar", ["The Crossroads"] = "Orgrimmar",
  ["Thunder Bluff"] = "Thunder Bluff", ["Bloodhoof Village"] = "Thunder Bluff", ["Camp Taurajo"] = "Thunder Bluff",
  ["Undercity"] = "Undercity", ["Brill"] = "Undercity", ["The Sepulcher"] = "Undercity", ["Tarren Mill"] = "Undercity",
  ["Sen'jin Village"] = "Darkspear Trolls", ["Booty Bay"] = "Booty Bay", ["Ratchet"] = "Ratchet",
  ["Gadgetzan"] = "Gadgetzan", ["Everlook"] = "Everlook",
}
-- Inns whose town the game doesn't say while you're inside (the subzone is the inn).
W.SELF_INN_TOWN = {
  ["Lion's Pride Inn"] = "Goldshire", ["Scarlet Raven Tavern"] = "Darkshire", ["Lakeshire Inn"] = "Lakeshire",
  ["Thunderbrew Distillery"] = "Kharanos", ["Stoutlager Inn"] = "Thelsamar", ["Deepwater Tavern"] = "Menethil Harbor",
  ["Gallows' End Tavern"] = "Brill",
}

-- NPCs who are part of the scenery, not people one gets to know.
W.SELF_NPC_SKIP = { "Guard$", "Guardian$", "Patroller$", "Grunt$", "Sentinel$", "Deathguard", "Protector$", "Bruiser$" }

-- Spells that are holy work (prayer, the Light, the spirits and the Earthmother's gifts).
W.SELF_HOLY = { "^Holy ", "^Flash of Light", "^Flash Heal", "^Heal$", "^Greater Heal", "^Lesser Heal", "^Renew",
  "^Prayer of ", "^Blessing of ", "^Seal of ", "^Smite", "^Resurrection", "^Redemption", "^Divine ", "^Ancestral Spirit",
  "^Healing Wave", "^Lesser Healing Wave", "^Rejuvenation", "^Healing Touch", "^Power Word: Fortitude", "^Inner Fire" }
-- Your own emotes that are in fun ("You dance", "You tell a joke"...), and toys.
W.SELF_PLAYFUL_EMOTES = { "^you dance", "^you burst into dance", "joke", "silly", "^you giggle", "^you laugh", "^you tickle",
  "^you flex", "^you chicken", "^you cackle", "^you wink", "^you moo", "^you train" }
W.SELF_PLAYFUL_SPELLS = { ["Snowball"] = true, ["Fireworks"] = true, ["Blue Firework"] = true, ["Green Firework"] = true,
  ["Red Firework"] = true, ["Rocket"] = true, ["Toasting Goblet"] = true, ["Party Grenade"] = true, ["Noggenfogger Elixir"] = true }
-- Text items that aren't books.
W.SELF_NOT_BOOKS = { ["Plain Letter"] = true, ["Letter"] = true }

-- History: the trainer where it began, or the one gone back to.
W.SAY.trainer_first = { "Had {their} first lessons from {who} in {place}", "Learned the first of {their} trade from {who} in {place}" }
W.SAY.trainer_usual = { "Still goes back to {who} in {place} for lessons", "Takes {their} lessons from {who} in {place}" }

---------------------------------------------------------------------------
-- Life on the road (Sources/Life.lua): fishing, crafts, gathering, duels, battles, money,
-- inns, flight masters, mounts, emotes, company, close calls. A block of its own, kept apart
-- from the lists above.
---------------------------------------------------------------------------
-- What a character carries (Sources/Pack.lua, told in Keepsakes.lua). Every line names only
-- what is in the bags at the time; {item} is the thing's own name.
W.PACK = {
  -- Companion pets in classic are carried as items; most are caught by the patterns below.
  PETS = { ["Mechanical Squirrel Box"] = true, ["Tiny Crimson Whelpling"] = true, ["Tiny Emerald Whelpling"] = true,
    ["Dark Whelpling"] = true, ["Azure Whelpling"] = true, ["Sprite Darter Egg"] = true, ["Wood Frog Box"] = true,
    ["Tree Frog Box"] = true, ["Prairie Dog Whistle"] = true, ["Rabbit Crate (Snowshoe)"] = true, ["Pet Bombling"] = true,
    ["Lil' Smoky"] = true, ["Worg Carrier"] = true, ["Smolderweb Carrier"] = true, ["Disgusting Oozeling"] = true,
    ["Jubling"] = true, ["Pet Fish"] = true, ["Panda Collar"] = true, ["Zergling Leash"] = true, ["Diablo Stone"] = true,
    ["Ancona Chicken"] = true, ["Chicken Egg"] = true, ["Hawk Owl"] = true, ["Great Horned Owl"] = true,
    ["Snake Egg"] = true },
  PET_PATTERNS = { "Carrier", "Parrot Cage", "Box %(", "Hatchling$", " Whelpling$" },
  MOUNT_PATTERNS = { "^Reins of ", "^Horn of the ", "^Whistle of the ", " Bridle$", "Mechanostrider$",
    " Skeletal Horse$", " Skeletal Warhorse$", "^%a+ Kodo$", "^%a+ Ram$", "^Swift %a+ Ram$" },
  -- Toys and novelties: kept for the fun of it.
  TOYS = { ["Toy Train Set"] = true, ["Piccolo of the Flaming Fire"] = true, ["Orb of Deception"] = true,
    ["Dartol's Rod of Transformation"] = true, ["Gnomish Universal Remote"] = true, ["Gnomish Net-o-Matic Projector"] = true,
    ["Gnomish Shrink Ray"] = true, ["Goblin Jumper Cables"] = true, ["Discombobulator Ray"] = true,
    ["Snowball"] = true, ["Handful of Snowflakes"] = true, ["Mistletoe"] = true, ["Fresh Holly"] = true,
    ["Winter Veil Disguise Kit"] = true, ["Red Rose"] = true, ["Elune's Candle"] = true, ["Festival Firecracker"] = true,
    ["Blue Firework"] = true, ["Green Firework"] = true, ["Red Firework"] = true, ["Large Blue Rocket"] = true,
    ["Large Red Rocket"] = true, ["Large Green Rocket"] = true, ["Cluster Launcher"] = true, ["Firework Launcher"] = true,
    ["Noggenfogger Elixir"] = true, ["Savory Deviate Delight"] = true, ["Wand of Holiday Cheer"] = true,
    ["Hallowed Wand - Pirate"] = true, ["Hallowed Wand - Ninja"] = true, ["Hallowed Wand - Bat"] = true,
    ["Hallowed Wand - Ghost"] = true, ["Ogre Pocket Knife"] = true, ["Barov Peasant Caller"] = true,
    ["Bag of Marbles"] = true, ["Crashin' Thrashin' Robot"] = true },
  RECIPE_PATTERNS = { "^Recipe: ", "^Pattern: ", "^Plans: ", "^Formula: ", "^Schematic: ", "^Manual: " },
  -- A recipe as carried: "a Westfall Stew recipe card".
  RECIPE_NOUN = { Recipe = "recipe card", Pattern = "pattern", Plans = "set of plans", Formula = "formula",
    Schematic = "schematic", Manual = "manual" },
  LETTER_PATTERNS = { "Letter", " Note$", "^Note ", "Missive", "Orders$", "Correspondence", "Dispatch" },
  -- Letters that are the game's own and safe to name whatever their title says.
  LETTERS = { ["Plain Letter"] = true, ["Letter to Stormpike"] = true, ["Sealed Letter"] = true,
    ["Torn Letter"] = true, ["Tattered Letter"] = true, ["Bloodstained Letter"] = true,
    ["Stained Letter"] = true, ["Waterlogged Letter"] = true, ["An Undelivered Letter"] = true },
  -- Stacks big enough to tell, first match wins: pat (name), type and sub (the game's item
  -- type and subtype), min (how many is a lot), mass (no plural: "Conjured Water").
  STACKS = {
    { pat = "Bandage$", kind = "bandage", min = 10 },
    { pat = "Potion$", kind = "potion", min = 5 },
    { pat = "Elixir", kind = "potion", min = 5 },
    { pat = "Water$", kind = "drink", min = 20, mass = true },
    { pat = "Milk$", kind = "drink", min = 20, mass = true },
    { pat = "Juice$", kind = "drink", min = 20, mass = true },
    { pat = "Cider$", kind = "drink", min = 20, mass = true },
    { pat = "Ale$", kind = "drink", min = 10, mass = true },
    { pat = "Mead$", kind = "drink", min = 10, mass = true },
    { type = "Projectile", kind = "ammo", min = 200 },
    { pat = "Arrow$", kind = "ammo", min = 200 },
    { pat = "Shot$", kind = "ammo", min = 200 },
    { pat = "Cloth$", kind = "goods", min = 40, mass = true },
    { pat = "Bread$", kind = "food", min = 20, mass = true },
    { pat = "Jerky$", kind = "food", min = 20, mass = true },
    { pat = "Cheese$", kind = "food", min = 20, mass = true },
    { sub = "Food & Drink", kind = "food", min = 20 },
    { type = "Reagent", kind = "reagent", min = 10 },
    { type = "Trade Goods", kind = "goods", min = 40 },
    { type = "Consumable", kind = "food", min = 20 },
  },
  -- The kinds of bag worth telling (the game's subtype), in the order they're told.
  BAGS = { "Quiver", "Ammo Pouch", "Soul Bag", "Herb Bag", "Enchanting Bag", "Engineering Bag", "Mining Bag" },

  -- About: Physical, a short paragraph of what they carry. {item} names it.
  CARRY = {
    pet = { "Has {item} packed carefully among {their} things", "Keeps {item} near the top of {their} pack",
      "Travels with {item}, and checks on it more often than on {their} supplies",
      "Makes room in {their} pack for {item}, whatever else has to go", "Carries {item} wherever {they} go{es}" },
    mount = { "Has {item} among {their} things", "Keeps {item} with {them} for the long roads",
      "Carries {item}, ready for the next long ride", "Owns {item}, and keeps it close" },
    toy = { "Carries {item}, for no better reason than the fun of it", "Has {item} rattling about in {their} pack",
      "Keeps {item} in {their} pack for idle moments", "Never seems to leave {item} behind",
      "Has {item} tucked away for a slow evening" },
    pole = { "Has {item} packed for any water worth stopping at", "Carries {item}, in case of a good river",
      "Keeps {item} with {their} things, ready to cast", "Has {item} along for quiet hours by the water" },
    key = { "Has {item} on {their} keyring", "Carries {item}, and knows which door it opens",
      "Keeps {item} safe with the rest of {their} keys", "Has {item} among {their} keys" },
    keys = { "Has a keyring with {item} on it", "Carries {item} on {their} keyring", "Keeps {item} on {their} keyring",
      "Has {item} among {their} keys" },
    starts = { "Carries {item}, which someone will surely want to see", "Has {item} in {their} pack, still waiting for the right hands",
      "Holds on to {item}, not yet sure who should have it", "Has {item} with {them}, and a reason to find someone about it" },
    letter = { "Keeps {item} folded small in {their} pack", "Carries {item}, read more than once by the look of it",
      "Has {item} tucked away with {their} things", "Holds on to {item}", "Keeps {item} where it won't get creased" },
    book = { "Carries a copy of {item}", "Has {item} in {their} pack, the spine well worn", "Keeps {item} for reading on the road",
      "Has {item} packed among {their} things", "Carries {item} to read when the road is quiet" },
    recipe = { "Has carried {item} for {dur} without learning it", "Still has {item} in {their} pack, {dur} on and unlearned",
      "Carries {item}, and has done for {dur}", "Has had {item} for {dur} and not yet tried it" },
    since = { "Has carried {item} since {zone}", "Still has {item} from {zone}", "Has kept {item} since {zone}",
      "Holds on to {item}, picked up in {zone} {dur} ago", "Has had {item} with {them} since {zone}" },
    long = { "Has carried {item} for {dur}", "Has held on to {item} for {dur}, for reasons of {their} own",
      "Has kept {item} for {dur} now", "Still carries {item}, {dur} on", "Has not been without {item} in {dur}" },
    hearth = { "{their} hearthstone is set to {town}", "Carries a hearthstone that would take {them} home to {town}",
      "Keeps a hearthstone bound to {town}", "Has a hearthstone tied to {town}", "{their} hearthstone answers to {town}" },
    stack = { "Has {n} {item} stacked in {their} bags", "Is carrying {n} {item}, more than anything else",
      "Keeps {n} {item} in {their} bags", "The bulk of {their} pack is {n} {item}" },
    full = { "{their} bags are full to the last slot", "Has bags packed so full nothing more would fit",
      "Is carrying all {their} bags will hold", "Has not a slot to spare in {their} bags" },
    light = { "Travels light, {their} bags mostly empty", "Carries little, with plenty of room to spare",
      "Has more empty space in {their} bags than not", "Keeps {their} pack light" },
    Quiver = { "Wears {item} across {their} back", "Keeps {their} arrows in {item}", "Has {item} slung for {their} arrows",
      "Carries {item}, full of fletching" },
    ["Ammo Pouch"] = { "Keeps {their} shot in {item}", "Carries {item} for {their} shot", "Has {item} heavy with shot",
      "Keeps {item} for {their} ammunition" },
    ["Soul Bag"] = { "Keeps {their} soul shards in {item}", "Carries {item} for the shards {they} gather{s}",
      "Has {item}, heavy with what {they've} taken", "Carries {item}, never far from {their} hand" },
    ["Herb Bag"] = { "Keeps {their} herbs sorted in {item}", "Carries {item}, smelling of whatever {they} picked last",
      "Has {item} for the herbs {they} gather{s}", "Keeps {item} for {their} herbs" },
    ["Enchanting Bag"] = { "Keeps {their} dusts and shards in {item}", "Carries {item} for {their} enchanting",
      "Has {item}, glittering faintly with dust", "Keeps {item} for {their} enchanter's stock" },
    ["Engineering Bag"] = { "Carries {their} tools and parts in {item}", "Has {item} full of gears and bolts",
      "Keeps {item} for {their} engineering", "Has {item} clanking with parts" },
    ["Mining Bag"] = { "Keeps ore and stone in {item}", "Carries {item} for {their} ore", "Has {item} heavy with stone",
      "Keeps {item} for what {they} dig{s} up" },
  },
  -- At first glance (Marks): { title, icon, lines }.
  MARK = {
    full = { "Heavy Pack", "INV_Misc_Bag_10", { "Bags stuffed to bursting, with not a slot to spare.",
      "Carries everything {they} own{s}, by the look of the bags.", "Laden down, bags full to the brim.",
      "Weighed down with full bags." } },
    pet = { "A Small Companion", "INV_Box_PetCarrier_01", { "Carries {item} wherever {they} go{es}.",
      "Has {item} close at hand.", "Never far from {item}.", "Keeps {item} in {their} pack, and a careful hand on it." } },
    toy = { "Something Fun", "INV_Misc_Toy_01", { "Has {item} in {their} pack, and the look of someone who uses it.",
      "Carries {item}, just for fun.", "Keeps {item} close, for when things get dull.", "Has {item} along, for no good reason." } },
    starts = { "Something to Deliver", "INV_Misc_Note_01", { "Carries {item}, and someone should see it.",
      "Has {item} that wants taking to the right person.", "Holds {item}, as yet undelivered.",
      "Has {item} to show someone." } },
    keepsake = { "A Keepsake", "INV_Misc_Bag_11", { "Has carried {item} for {dur}.", "Still carries {item}, {dur} on.",
      "Has kept {item} for {dur}.", "Has not let go of {item} in {dur}." } },
    hoard = { "Well Stocked", "INV_Misc_Bag_09", { "Carries {n} {item}, and plenty more besides.",
      "Bags heavy with {n} {item}.", "Is well stocked: {n} {item}.", "Has {n} {item} packed away." } },
  },
  -- Lately: something new in the bags, something long kept let go, something long carried.
  LATELY = {
    new = { "Has a new {item} in {their} pack.", "Has come by {item}, and keeps it close.", "Picked up {item} lately.",
      "Has {item} now, and is still getting used to it." },
    new_pet = { "Has a new companion: {item}.", "Has come by {item}, and keeps checking on it.",
      "Got {item} lately, and is rarely without it.", "Has taken on {item}." },
    new_toy = { "Has a new toy: {item}.", "Picked up {item} lately, and has been trying it out.",
      "Has been playing with {item}.", "Came by {item}, and can't leave it alone." },
    new_starts = { "Came by {item}, which someone will want to see.", "Has picked up {item}, and has someone to find.",
      "Turned up {item}, and wonders who it's for.", "Found {item}, and it means work." },
    sold = { "Sold the {item} {they've} carried for {dur}.", "Has sold {item}, after {dur} of carrying it.",
      "Let a merchant have {item}, kept for {dur}.", "Finally sold {item}, after {dur}." },
    auctioned = { "Put {item} up for auction, after {dur}.", "Has sent {item} to auction, carried {dur}.",
      "Let {item} go at auction, after carrying it {dur}.", "Is selling {item}, kept for {dur}." },
    given = { "Gave away {item}, kept for {dur}.", "Has given {item} away, after {dur}.",
      "Handed over {item}, after carrying it {dur}.", "Parted with {item}, a gift after {dur}." },
    sent = { "Sent {item} off by post, after {dur}.", "Has mailed {item} away, kept for {dur}.",
      "Posted {item} away, after {dur} carrying it.", "Let {item} go by the mail, after {dur}." },
    destroyed = { "Threw away {item}, after carrying it for {dur}.", "Got rid of {item}, kept for {dur}.",
      "Has finally thrown out {item}, after {dur}.", "Destroyed {item}, carried for {dur}." },
    carried = { "Has carried {item} for {dur}.", "Is still carrying {item}, {dur} on.", "Has had {item} for {dur} now.",
      "Has kept {item} for {dur}, and shows no sign of letting go." },
  },
  LATELY_TITLE = { new = "Something New", new_pet = "A New Companion", new_toy = "A New Toy", new_starts = "Something to Deliver",
    sold = "Let Go", auctioned = "Let Go", given = "Given Away", sent = "Sent Off", destroyed = "Thrown Out", carried = "Long Carried" },
  -- Personality: what's hoarded, once it's been kept well stocked for days. {item} is the plural.
  HABIT = {
    bandage = { "Never seems to travel without a few {item} to spare", "Always has {item} on hand, and plenty of them",
      "Keeps a stock of {item} for whoever needs one", "Is rarely caught short of {item}" },
    potion = { "Never goes far without {item}", "Keeps {item} close, for the fight that goes wrong",
      "Always has a few {item} put by", "Carries {item} as a matter of course" },
    food = { "Is never short of {item}", "Always has {item} packed for the road", "Keeps {their} bags well stocked with {item}",
      "Travels with enough {item} to feed a small camp" },
    drink = { "Is never short of {item}", "Always has {item} to hand", "Keeps more {item} in {their} bags than one person needs",
      "Carries {item} enough for a long dry road" },
    ammo = { "Never lets {their} stock of {item} run low", "Always carries more {item} than {they} need{s}",
      "Keeps {their} bags heavy with {item}", "Is never caught short of {item}" },
    reagent = { "Keeps a good stock of {item}", "Never lets {their} {item} run short", "Always has {item} put by",
      "Restocks {their} {item} before {they} need{s} to" },
    goods = { "Hoards {item}, and has done for a while", "Has been sitting on a stack of {item} for some time",
      "Can't seem to part with {their} {item}", "Keeps a stockpile of {item}, against some future need" },
    keepsakes = { "Holds on to small things long after they stop being useful", "Keeps odds and ends anyone else would throw out",
      "Finds it hard to throw anything away", "Carries things kept for their own sake" },
  },
  -- History: what's been kept longest.
  HISTORY = {
    since = { "Has kept {item} since {zone}, {dur} now", "Still carries {item}, picked up in {zone} {dur} ago",
      "Has held on to {item} since {zone}", "Has carried {item} all the way from {zone}", "Carries {item}, kept since {zone}" },
    long = { "Has carried {item} for {dur} and more", "Has kept {item} for {dur} at the least",
      "Has had {item} for {dur}, and longer", "Has not been without {item} in {dur}" },
    lost = { "Let go of {item} after carrying it for {dur}", "Parted with {item} after {dur}",
      "Gave up {item}, after {dur} of keeping it", "Finally let {item} go, after {dur}" },
  },
}

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
-- COMPANY (0.21.0): the group, the pet, the guild and the road alone, for the Company
-- glance and History's people paragraph (Compose.CompanyGlance, Compose.History part 4,
-- facts from Sources/Company.lua). Other players are only ever counted, never named
-- (Social Diary friends aside). Glance pieces are fragments without a full stop; the
-- composer joins them. {party} {n} {guild} {span} {pet} {kind} {akind} {faction} {races}
-- {times} {name} {rank} {list} {mood} are filled in; pronouns as everywhere else.
---------------------------------------------------------------------------
W.CLASS_PLURAL.DEATHKNIGHT = { "death knight", "death knights" }
W.RACE_PLURAL = {
  Human = "humans", Dwarf = "dwarves", Gnome = "gnomes", NightElf = "night elves", Orc = "orcs", Troll = "trolls",
  Tauren = "tauren", Scourge = "Forsaken", Undead = "Forsaken", Goblin = "goblins", BloodElf = "blood elves",
  Draenei = "draenei",
}
-- Guildmates about, as a person would count them (never the exact number).
W.GUILD_ONLINE = {
  { max = 4, words = "a few" }, { max = 9, words = "a handful" }, { max = 19, words = "a dozen or more" },
  { max = 49, words = "a good many" }, { max = math.huge, words = "dozens" },
}
W.COMPANY = {
  -- The group
  party = { "Travelling with {party}", "On the road with {party}", "In the company of {party}",
    "Keeping company with {party}", "Out and about with {party}",
    "Sharing the road with {party}" },
  party_lead = { "Leading {party}", "Setting the pace for {party}", "Out in front of {party}",
    "Calling the turns for {party}", "At the head of a small band: {party}" },
  host = { "Marching with a host of {n}", "One of a host of {n}", "Part of a company {n} strong",
    "One of {n} gathered under the same banner", "Among a host {n} strong",
    "Travelling in a great company, {n} strong", "One of {n} under the same banner today" },
  host_lead = { "Leading a host of {n}", "At the head of a host {n} strong", "In charge of a company of {n}",
    "Setting the course for a host of {n}" },
  battle = { "Fighting for the {faction}, one of {n} on the field", "One of {n} holding the line for the {faction}",
    "On the battlefield with the {faction}, {n} strong", "In the thick of a battle, one of {n} for the {faction}" },
  -- What the rest of the group are to them (after a comma)
  guild_all = { "every one of them from {guild}", "all of them from {guild}", "every last one of them of {guild}",
    "all of them wearing the colours of {guild}" },
  guild_some = { "{n} of them from {guild}", "{n} of them fellow members of {guild}", "with {n} from {guild} among them",
    "{n} of them guildmates from {guild}" },
  guild_one = { "one of them from {guild}", "one of them a fellow member of {guild}", "with one guildmate among them",
    "one of them out of {guild} as well" },
  guild_single = { "a fellow member of {guild}", "from {guild} as well", "another of {guild}", "who belongs to {guild} too" },
  guild_none = { "none of them from {guild}", "not one of them from {guild}", "none of them guildmates",
    "with nobody from {guild} among them" },
  guild_none_single = { "not one of {guild}", "from outside {guild}", "who isn't of {guild}", "from beyond {guild}" },
  familiar_one = { "one of them a familiar face", "one of them no stranger by now", "with one face among them from earlier roads",
    "one of them a companion from before" },
  familiar_many = { "{n} of them familiar faces", "{n} of them no strangers by now", "with {n} faces among them from earlier roads",
    "{n} of them companions from before" },
  familiar_all = { "every one of them a familiar face", "all of them no strangers by now", "all of them companions from before",
    "faces from earlier roads, every one" },
  familiar_single = { "a familiar face by now", "no stranger by now", "met on an earlier road", "a companion from before" },
  races_all = { "all of them {races}", "{races}, every one", "every one of them {races}", "{races} to the last" },
  races_most = { "most of them {races}", "{races} for the most part", "mostly {races}", "the greater part of them {races}" },
  -- How long together, and where they stand among the rest
  together = { "Together for {span} now", "{span} on the road together so far", "Grouped up for {span} now",
    "With them for {span} so far" },
  youngest = { "the greenest of the lot", "the youngest hand among them", "the least seasoned of the group",
    "newer to the road than the rest" },
  eldest = { "the most seasoned of them", "the old hand of the group", "further down the road than the rest",
    "the most travelled among them" },
  even = { "evenly matched with the rest", "about as seasoned as the others", "no greener than the rest",
    "much of a match for the others" },
  -- The pet, when there's no one else
  -- ({mood} is "who seems content" and the like, so it always follows the pet itself)
  pet_hunter = { "Travels with {pet}, {their} {kind}{mood}", "Has no company but {pet} the {kind}{mood}",
    "Shares the road with {pet} the {kind}{mood}", "On the road with no one but {pet}, {their} {kind}{mood}",
    "Goes about with {akind} at heel: {pet}{mood}", "Alone on the road, apart from {pet}, {their} {kind}{mood}" },
  pet_warlock = { "Has {pet}, {akind}, bound to {their} side", "Goes about with {pet} the {kind} at heel",
    "Keeps {pet}, {their} {kind}, on a short leash", "Travels with no one but {pet}, {akind} of {their} own summoning" },
  pet_since = { "{pet} has been at {their} side for {span}", "The two of them have been together {span}",
    "Has had {pet} for {span}", "{pet} has been with {them} {span} now" },
  pet_new = { "{pet} is a new companion", "{pet} has only lately joined {them}", "The two of them are newly met",
    "{pet} is new to {their} side" },
  pet_fallen = { ", and has fallen {times} in that time", ", going down {times} along the way",
    ", and has been brought down {times} since", ", though {pet} has fallen {times}" },
  -- The guild, when they're out alone
  guild_about = { "Alone for now, though {n} of {guild} are about", "Travels alone today, with {n} of {guild} somewhere about",
    "Out on {their} own, though {n} of {guild} are about", "No company on the road, but {n} of {guild} are about" },
  guild_quiet = { "Wears the colours of {guild}, though {they} travel{s} alone for now", "Of {guild}, but on {their} own for now",
    "Belongs to {guild}, but walks alone today", "Answers to {guild}, but keeps {their} own road for now" },
  -- Alone
  alone = { "Travels alone", "Keeps to {themselves} on the road", "Goes about alone", "Walks {their} road alone",
    "Makes {their} way without company",
    "On {their} own for now" },
  alone_reserved = { "Travels alone, and keeps conversations short", "Travels alone, and says little",
    "Goes about alone and keeps {their} own counsel", "Keeps to {themselves}, and speaks when spoken to",
    "Alone on the road, and not looking for company" },
  alone_for = { "On {their} own for {span} now", "{span} since {they} last travelled in company",
    "Hasn't had company on the road for {span}", "Has gone {span} without a travelling companion" },
  -- How they usually go, from the share of time spent in a group
  loner = { "Nearly always travels alone", "Keeps {their} own company far more often than not", "Rarely travels in company",
    "Seldom has anyone along for long" },
  mostly_alone = { "Usually travels alone, though not always", "Travels alone more often than not",
    "Walks alone most of the time, with company now and then", "Mostly keeps {their} own company, joining others now and then" },
  mixed = { "Travels in company about as often as alone", "Spends as much of the road in company as out of it",
    "Takes the road alone or in company, as it comes", "Is as often in a group as out of one" },
  social = { "Seldom alone on the road for long", "Usually found in company", "More often in a group than not",
    "Rarely goes far without company" },

  -- History: the people paragraph
  h_loner = { "{name} nearly always travels alone", "{name} keeps {their} own company far more often than not",
    "{name} rarely travels in company", "{name} seldom has anyone along for long" },
  h_mostly_alone = { "{name} usually travels alone, though not always", "{name} walks alone more often than not, with company now and then",
    "More often than not, {name} travels alone", "{name} mostly keeps {their} own company, joining others now and then" },
  h_mixed = { "{name} travels in company about as often as alone", "{name} spends as much of the road in company as out of it",
    "{name} takes the road alone or in company, as it comes", "{name} is as often in a group as out of one" },
  h_social = { "{name} is seldom alone on the road for long", "{name} is usually found in company",
    "{name} travels in a group more often than not", "{name} rarely goes far without company" },
  h_week = { "has travelled with {n} others this past week", "has shared the road with {n} others in the past week",
    "has fought beside {n} others in the past week", "has fallen in with {n} others over the past week",
    "has stood with {n} others in one fight or another this week", "has been in company with {n} others this past week" },
  h_recurring = { "{n} companions have travelled with {them} more than once", "{n} faces have turned up at {their} side more than once",
    "{they've} travelled with {n} of the same companions more than once", "Some faces come back: {n} have shared {their} road more than once" },
  h_recurring_one = { "One companion has travelled with {them} more than once", "One face has turned up at {their} side more than once",
    "{they've} travelled with one companion more than once", "One face keeps coming back to {their} road" },
  h_solo = { "Has gone down into a dungeon single-handed {times}", "{they've} gone into a dungeon with no one at {their} back {times}",
    "Has braved a dungeon on {their} own {times}", "Has taken on a dungeon unaccompanied {times}" },
  h_pet = { "{pet}, {their} {kind}, has been at {their} side for {span}", "{name} has had {pet} the {kind} for {span}",
    "For {span} now, {pet} the {kind} has gone where {name} goes", "{pet}, {akind}, has kept at {name}'s heel for {span}" },
  h_pet_new = { "{name} has only lately taken on {pet}, {akind}", "{pet} the {kind} is a new companion",
    "{pet}, {akind}, is newly at {name}'s side", "{name} has not had {pet} the {kind} long" },
  h_pets_before = { "Before {pet}, there was {list}", "{list} came before {pet}", "{pet} isn't the first: {list} came before",
    "{they've} kept {list} as well, at one time or another" },
  h_demon = { "Of the demons {they} call{s} on, {pet} the {kind} comes most often", "{name} calls on {pet}, {akind}, more than any other demon",
    "{pet} the {kind} is the demon most often at {name}'s side", "When {name} calls a demon, it is usually {pet}, {akind}" },
  h_guild = { "Has worn the colours of {guild} for {span}{rank}", "Has belonged to {guild} for {span}{rank}",
    "Has been one of {guild} for {span}{rank}", "For {span} now, {name} has worn the colours of {guild}{rank}" },
  h_guild_now = { "Wears the colours of {guild}{rank}", "Belongs to {guild}{rank}", "Is one of {guild}{rank}",
    "Answers to {guild}{rank}",
    "Is a member of {guild}{rank}", "Has thrown in {their} lot with {guild}{rank}" },
}

---------------------------------------------------------------------------
-- MOOD MODEL 0.21.0: the moods the game's own signals feed (being healed, a roll lost, a
-- duel, a long session, far from home...), and what those signals sound like. Face, voice
-- and posture only, like every mood: nothing held, nothing done that the game didn't show.
---------------------------------------------------------------------------
local NEW_MOODS = {
  grateful = {
    title = "Grateful", icon = "Spell_Holy_Heal02",
    adj = { "Grateful", "Thankful", "Touched by a kindness", "Warm toward strangers", "Glad of the help",
      "In someone's debt, and glad of it" },
    tells = {
      "Has the softened face of someone a stranger just looked after.",
      "Thanks people for small things, and means each one.",
      "Looks at passers-by more kindly than usual.",
      "A warmth in the voice, as if {they've} been reminded people can be decent.",
      "Nods to anyone who meets {their} eye, slow and sincere.",
      "Quick to smile, slower to forget who helped.",
      "Shoulders loose, the guard let down by someone else's kindness.",
    },
  },
  humbled = {
    title = "Humbled", icon = "Spell_Holy_Excorcism_02",
    adj = { "Humbled", "Taken down a peg", "Quieter than usual", "Chastened", "Thoughtful after a setback",
      "Less sure of {themselves}" },
    tells = {
      "Speaks more quietly today, and listens more.",
      "Eyes lowered, like someone going over what went wrong.",
      "Laughs at {themselves} before anyone else can.",
      "Has the careful manner of someone lately reminded of {their} limits.",
      "A rueful half-smile that comes and goes.",
      "Lets others speak first, which isn't like {them}.",
    },
  },
  bored = {
    title = "Bored", icon = "INV_Misc_PocketWatch_01",
    adj = { "Bored", "Restless", "At a loose end", "Itching for something to happen", "Drumming {their} fingers",
      "Under-occupied" },
    tells = {
      "Sighs through {their} nose and looks for something, anything, to happen.",
      "Shifts from foot to foot like someone waiting on a late coach.",
      "Eyes wandering, attention anywhere but here.",
      "Brightens at once if anyone speaks to {them}.",
      "Yawns, and not from tiredness.",
      "Has the glazed look of someone counting the hours.",
      "Restless hands, and a face that says nothing is happening.",
    },
  },
  homesick = {
    title = "Homesick", icon = "INV_Misc_Rune_01",
    adj = { "Homesick", "Missing home", "A long way from home", "Thinking of home", "Far from {their} own hearth",
      "Wistful" },
    tells = {
      "Gets a faraway look whenever talk turns to home.",
      "Asks strangers where they're from, and listens closely to the answer.",
      "Quiet, {their} thoughts somewhere else entirely.",
      "Smiles at a familiar accent like it's an old friend.",
      "A wistful note in the voice, and eyes that keep drifting to the road home.",
      "Lets out a slow breath, the kind people sigh for distant places.",
    },
  },
  smug = {
    title = "Smug", icon = "Ability_CriticalStrike",
    adj = { "Smug", "Pleased as anything", "Insufferably pleased", "Wearing a knowing smile",
      "Very pleased with {themselves}", "Self-satisfied" },
    tells = {
      "A small, private smile that refuses to go away.",
      "Chin a notch higher than it needs to be.",
      "Has the look of someone waiting to be asked how it went.",
      "Hums to {themselves}, unbearably cheerful.",
      "Raises an eyebrow at anyone who doubts {them}.",
      "Struts more than walks today.",
      "Smirks, then pretends not to.",
    },
  },
  exhausted = {
    title = "Exhausted", icon = "Spell_Nature_Slow",
    adj = { "Exhausted", "Running on nothing", "Spent", "Past tired", "Grey with fatigue", "Asleep on {their} feet" },
    tells = {
      "Eyes red-rimmed, blinking slowly, as if each blink might stick.",
      "Sways whenever {they} stand{s} still.",
      "Voice gone flat and slow with fatigue.",
      "Rubs {their} eyes with the heels of {their} hands.",
      "Loses the thread mid-sentence and has to start again.",
      "The face of someone who should have slept hours ago.",
      "Every movement slower than it means to be.",
    },
  },
  cheerful = {
    title = "Cheerful", icon = "INV_Misc_Flower_02",
    adj = { "Cheerful", "Sunny", "In a good mood", "Light-hearted", "Bright and easy", "Whistling under {their} breath" },
    tells = {
      "Smiles at strangers without being asked to.",
      "Light on {their} feet, and quick to laugh.",
      "Whistles tunelessly, and doesn't care who hears.",
      "Laughs easily, and the laugh reaches the eyes.",
      "Greets people by the time of day, and means it.",
      "Bright-faced, as if the day has been kind so far.",
      "Chatty, in an easy, sunny way.",
    },
  },
  bitter = {
    title = "Bitter", icon = "Spell_Shadow_UnholyFrenzy",
    adj = { "Bitter", "Sour", "Nursing a grudge", "In a black mood", "Sore about something", "Sharp-tongued today" },
    tells = {
      "Mouth set in a thin, sour line.",
      "Answers in short, clipped words, and doesn't look up.",
      "Has the narrow-eyed look of someone keeping score.",
      "A hard edge to the voice that wasn't there yesterday.",
      "Scowls at nothing, and then at anyone who notices.",
      "Jaw tight, chewing on some private injustice.",
    },
  },
}
for k, v in pairs(NEW_MOODS) do W.MOODS[k] = v end

-- Good or bad, for the badge (humbled is neither).
for k, v in pairs({ grateful = 1, cheerful = 1, smug = 1, bored = -1, homesick = -1, exhausted = -1, bitter = -1 }) do
  W.VALENCE[k] = v
end

-- How hard the new moods land, by race and class.
for race, t in pairs({
  Human = { cheerful = 1.1, homesick = 1.1 },
  Dwarf = { homesick = 1.2, bitter = 1.15, smug = 1.1 },
  Gnome = { bored = 1.3, cheerful = 1.2, exhausted = 0.9 },
  NightElf = { homesick = 1.2, bored = 0.8, exhausted = 0.7 },
  Orc = { humbled = 0.8, bitter = 1.2, smug = 1.15 },
  Troll = { cheerful = 1.2, bored = 1.1, bitter = 1.1 },
  Tauren = { grateful = 1.2, homesick = 1.2, smug = 0.8, bitter = 0.8 },
  Scourge = { homesick = 0.4, exhausted = 0.6, bitter = 1.25, cheerful = 0.8, grateful = 0.8 },
  Goblin = { smug = 1.3, bitter = 1.2, bored = 1.2, homesick = 0.8 },
}) do
  W.RACE_BIAS[race] = W.RACE_BIAS[race] or {}
  for k, v in pairs(t) do W.RACE_BIAS[race][k] = v end
end
for class, t in pairs({
  WARRIOR = { smug = 1.2, humbled = 0.9, exhausted = 0.9 },
  PALADIN = { humbled = 1.2, smug = 0.8, grateful = 1.1 },
  HUNTER = { homesick = 0.7, bored = 0.9 },
  ROGUE = { smug = 1.3, bitter = 1.1, grateful = 0.9 },
  PRIEST = { grateful = 1.2, humbled = 1.2, bitter = 0.8 },
  SHAMAN = { grateful = 1.1, homesick = 1.1 },
  MAGE = { bored = 1.2, smug = 1.15 },
  WARLOCK = { bitter = 1.2, grateful = 0.8, smug = 1.1 },
  DRUID = { homesick = 1.1, cheerful = 1.1 },
  DEATHKNIGHT = { exhausted = 0.6, cheerful = 0.7, bitter = 1.2, homesick = 0.6 },
}) do
  W.CLASS_BIAS[class] = W.CLASS_BIAS[class] or {}
  for k, v in pairs(t) do W.CLASS_BIAS[class][k] = v end
end

-- The new moods on each body.
more("Human", {
  grateful = { "Ducks {their} head in thanks, the way country folk do." },
  humbled = { "Rubs the back of {their} neck, sheepish as a scolded farmhand." },
  bored = { "Fidgets like a recruit kept standing at muster." },
  homesick = { "Gets a faraway look, like someone remembering Elwynn in spring." },
  smug = { "Grins like a Goldshire card player holding the winning hand." },
  exhausted = { "Moves like a farmhand at the end of a double harvest." },
  cheerful = { "Open-faced and friendly, a market-day sort of smile." },
  bitter = { "Mutters about fairness, the way Westfall folk learned to." },
})
more("Dwarf", {
  grateful = { "Gruff about it, but the thanks are plain in {their} voice." },
  humbled = { "Unusually short of boasts today." },
  bored = { "Huffs through {their} nose like a forge left to go cold." },
  homesick = { "Gets misty-eyed at any mention of Ironforge's halls." },
  smug = { "Chest out, chuckling deep in the throat." },
  exhausted = { "Even a dwarf's legs give out eventually, and these are close." },
  cheerful = { "A rumbling laugh close to the surface all day." },
  bitter = { "Has the look of a dwarf adding a name to an old grudge list." },
})
more("Gnome", {
  grateful = { "Beams up at whoever helped, ears pink with thanks." },
  humbled = { "Ears drooping, muttering about miscalculations." },
  bored = { "Fidgeting, quick fingers looking for something to take apart." },
  homesick = { "Quiet, the way gnomes go quiet when they remember Gnomeregan." },
  smug = { "Rocks on {their} heels like a theory just proven." },
  exhausted = { "Ears limp, the usual chatter gone slow and slurred." },
  cheerful = { "Chattering brightly at a mile a minute." },
  bitter = { "Ears flat, grumbling about faulty parts and fouler luck." },
})
more("NightElf", {
  grateful = { "Inclines {their} head, slow and gracious, in the old way." },
  humbled = { "Ears lowered, eyes thoughtful. Even centuries leave room to learn." },
  bored = { "Ears twitching, the patience of ages wearing thin." },
  homesick = { "Silver eyes turned west, toward the great tree." },
  smug = { "A cool, knowing look down a long nose." },
  exhausted = { "Ears drooping, the glow of the eyes dimmed with weariness." },
  cheerful = { "Light on {their} feet, eyes bright as moonlight on water." },
  bitter = { "Eyes narrowed to cold slivers of light." },
})
more("Orc", {
  grateful = { "A grunt and a short nod: an orc's thanks, and meant." },
  humbled = { "Tusks low, saying less than usual. Defeat teaches, if you let it." },
  bored = { "Grunting, restless as a wolf in a pen." },
  homesick = { "Talks of Durotar's red earth more than usual." },
  smug = { "A wide, tusky grin that dares anyone to argue." },
  exhausted = { "Head hanging, breathing heavy, but still upright." },
  cheerful = { "A rough laugh that comes easy today." },
  bitter = { "Snorting through the tusks, a grudge in the making." },
})
more("Troll", {
  grateful = { "Grins wide and nods slow. Da kindness be remembered, mon." },
  humbled = { "Long ears down, muttering that da loa be teaching a lesson." },
  bored = { "Rocking on {their} heels, looking for some trouble to get into." },
  homesick = { "Speaks of da Echo Isles with a far-off look." },
  smug = { "Cackling low, tusks bared in a grin." },
  exhausted = { "Slouched lower than ever, eyelids half shut." },
  cheerful = { "Swaying easy, grinning around the tusks." },
  bitter = { "Hissing through the tusks, eyes hard." },
})
more("Tauren", {
  grateful = { "Lowers the great head slowly, thanks in the old way of the plains." },
  humbled = { "Head bowed, ears low, quiet as the grass after a storm." },
  bored = { "Flicks an ear, and lets out a slow, gusting sigh." },
  homesick = { "Turns toward Mulgore whenever the wind comes from there." },
  smug = { "A deep, rumbling chuckle, ears perked." },
  exhausted = { "Hooves dragging, the great shoulders bowed with fatigue." },
  cheerful = { "Ears up, a low hum rolling in the chest." },
  bitter = { "Snorts hard, ears pinned. The slow anger of a herd that remembers." },
})
more("Scourge", {
  grateful = { "A creaking nod. Kindness to the dead is rare, and noticed." },
  humbled = { "Even the jaw seems to hang lower than usual." },
  bored = { "Clicks {their} fingerbones together, one by one, over and over." },
  homesick = { "Stares toward Lordaeron with eyes that remember it whole." },
  smug = { "A rattling chuckle that goes on longer than it should." },
  exhausted = { "The dead don't tire, they say. This one is doing a fair impression." },
  cheerful = { "Something like a grin on the ruined face." },
  bitter = { "A cold, rasping voice soaked in old resentment." },
})
more("Goblin", {
  grateful = { "Looks like {they're} working out how to repay it, with interest." },
  humbled = { "Ears down, quieter than a goblin ought to be." },
  bored = { "Tapping {their} foot like time wasted is money lost." },
  homesick = { "Gets nostalgic about Kezan, then changes the subject fast." },
  smug = { "Grinning like {they} just closed a very good deal." },
  exhausted = { "Even the fast talk has slowed to a mumble." },
  cheerful = { "Grinning wide, all teeth and good humour." },
  bitter = { "Muttering about bad deals and worse luck." },
})

moreClass("WARRIOR", {
  grateful = { "Gives a soldier's nod of thanks, short and sincere." },
  humbled = { "Shoulders down, going over the fight in {their} head." },
  bored = { "Rolls {their} shoulders, itching for a fight that isn't coming." },
  smug = { "Stands like someone who just won an argument with a fist." },
  exhausted = { "Arms hanging heavy, the stance gone soft." },
  bitter = { "Glowering, a fight lost and not forgotten." },
})
moreClass("PALADIN", {
  grateful = { "Murmurs a blessing on whoever helped." },
  humbled = { "Quiet and prayerful, accepting a lesson from the Light." },
  smug = { "Tries to look modest, and doesn't manage it." },
  bitter = { "Struggling to forgive, and losing." },
  exhausted = { "Pale with fatigue, the back still held straight." },
})
moreClass("HUNTER", {
  grateful = { "A brief, wordless nod, the hunter's way of saying thanks." },
  bored = { "Watching the horizon for something worth tracking." },
  homesick = { "Turns {their} face into the wind, as if it might carry the smell of home." },
  smug = { "Has the look of a hunter whose every shot just landed." },
  cheerful = { "Easy and loose, at home anywhere with sky overhead." },
})
moreClass("ROGUE", {
  grateful = { "Uncomfortable being helped, and saying thank you anyway." },
  humbled = { "Keeping to the shadows more than usual today." },
  bored = { "Eyes wandering over other people's belongings, from habit." },
  smug = { "A crooked smirk, like {they} got away with something." },
  bitter = { "Cold-eyed, settling accounts in {their} head." },
})
moreClass("PRIEST", {
  grateful = { "Gives thanks under {their} breath, to the Light and to whoever helped." },
  humbled = { "Head bowed, as if accepting a hard lesson." },
  exhausted = { "Pale and drawn, spent from tending others." },
  cheerful = { "A soft, bright warmth in the face." },
  bitter = { "Wrestling with something unforgiving in {themselves}." },
})
moreClass("SHAMAN", {
  grateful = { "Murmurs thanks to the spirits, and to the living who helped." },
  homesick = { "Listens hard, as if for the spirits of home." },
  bored = { "Restless as still air before a storm." },
  cheerful = { "Calm and bright, at peace with the elements today." },
})
moreClass("MAGE", {
  bored = { "Sighs like someone who has heard every lecture twice over." },
  smug = { "Wears the look of someone proved right by arithmetic." },
  exhausted = { "Rubs {their} temples, every thought slow." },
  humbled = { "Quietly recalculating, after a hard lesson." },
  bitter = { "Speaks in cold, precise, cutting sentences." },
})
moreClass("WARLOCK", {
  grateful = { "Accepts the kindness warily, as if looking for the price." },
  smug = { "A thin, satisfied smile, unsettling to look at." },
  bitter = { "Smoulders quietly. Nobody wants to be on the end of it." },
  bored = { "Drums {their} fingers with open impatience." },
})
moreClass("DRUID", {
  grateful = { "Touched by the kindness, softer in the face for it." },
  homesick = { "Restless away from the old groves." },
  cheerful = { "Bright-eyed and easy, like a morning in the wild." },
  exhausted = { "Slow and heavy, like a bear before the long sleep." },
})
moreClass("DEATHKNIGHT", {
  grateful = { "Gives a stiff nod. Kindness is not something {they} expected again." },
  bitter = { "Cold resentment in the hollow voice." },
  smug = { "A cold, thin smile that doesn't warm the eyes." },
  humbled = { "Silent, considering, as if death taught less than {they} thought." },
})

-- Other players' emotes aimed at you, matched in order against the message:
-- { words, mood, strength, why, why when it's a Social Diary friend (after the name) }.
W.EMOTES_AT_YOU = {
  { "thanks you", "grateful", 20, "someone thanked {them}", "thanked {them}" },
  { "rude", "bitter", 18, "someone was rude to {them}", "was rude to {them}" },
  { "spits", "bitter", 22, "someone spat at {them}", "spat at {them}" },
  { "slaps you", "bitter", 18, "someone slapped {them}", "slapped {them}" },
  { "laughs at you", "humbled", 15, "someone laughed at {them}", "laughed at {them}" },
  { "points at you", "humbled", 10, "someone pointed and stared", "pointed at {them}" },
  { "taunts you", "angry", 15, "someone taunted {them}", "taunted {them}" },
  { "threatens you", "angry", 15, "someone threatened {them}", "threatened {them}" },
  { "glares at you", "angry", 12, "someone glared at {them}", "glared at {them}" },
  { "kiss", "smitten", 18, "someone blew {them} a kiss", "kissed {them}" },
  { "flirts", "smitten", 18, "someone flirted with {them}", "flirted with {them}" },
  { "winks at you", "smitten", 10, "someone winked at {them}", "winked at {them}" },
  { "hugs you", "cheerful", 22, "someone hugged {them}", "hugged {them}" },
  { "waves at you", "cheerful", 16, "someone waved at {them}", "waved at {them}" },
  { "smiles at you", "cheerful", 16, "someone smiled at {them}", "smiled at {them}" },
  { "greets you", "cheerful", 16, "someone greeted {them}", "greeted {them}" },
  { "cheers at you", "cheerful", 18, "someone cheered {them}", "cheered {them}" },
  { "applauds", "smug", 18, "someone applauded {them}", "applauded {them}" },
  { "bows before you", "smug", 15, "someone bowed to {them}", "bowed to {them}" },
  { "salutes you", "proud", 15, "someone saluted {them}", "saluted {them}" },
  { "dances with you", "merry", 20, "someone danced with {them}", "danced with {them}" },
  { "comforts you", "grateful", 20, "someone comforted {them}", "comforted {them}" },
  { "pats you", "cheerful", 12, "someone patted {their} shoulder", "patted {their} shoulder" },
}

-- Crowd control on you, by the aura's name: what kind it is.
W.CROWD_CONTROL = {
  ["Polymorph"] = "sheep", ["Polymorph: Pig"] = "sheep", ["Polymorph: Turtle"] = "sheep", ["Hex"] = "sheep",
  ["Fear"] = "fear", ["Psychic Scream"] = "fear", ["Howl of Terror"] = "fear", ["Intimidating Shout"] = "fear",
  ["Scare Beast"] = "fear", ["Terrify"] = "fear", ["Death Coil"] = "fear", ["Seduction"] = "charm",
  ["Mind Control"] = "charm", ["Sap"] = "stun", ["Gouge"] = "stun", ["Kidney Shot"] = "stun", ["Cheap Shot"] = "stun",
  ["Hammer of Justice"] = "stun", ["Charge Stun"] = "stun", ["Intercept Stun"] = "stun", ["War Stomp"] = "stun",
  ["Bash"] = "stun", ["Concussion Blow"] = "stun", ["Blind"] = "stun", ["Scatter Shot"] = "stun",
  ["Freezing Trap Effect"] = "stun", ["Repentance"] = "stun", ["Hibernate"] = "sleep", ["Sleep"] = "sleep",
  ["Entangling Roots"] = "root", ["Frost Nova"] = "root", ["Net"] = "root",
}
-- What each kind leaves behind: { mood, strength, why }.
W.CC_MOOD = {
  sheep = { { "humbled", 28, "turned into an animal" }, { "bitter", 10 } },
  fear = { { "shaken", 18, "sent running in terror" }, { "humbled", 12 } },
  charm = { { "uneasy", 22, "had {their} will taken" }, { "bitter", 10 } },
  stun = { { "angry", 15, "knocked senseless" }, { "humbled", 8 } },
  sleep = { { "frustrated", 15, "put to sleep in a fight" } },
  root = { { "frustrated", 12, "held fast" } },
}

-- The seasons, beyond the festive mood: { mood, strength, why, when = "night" | "alone" }.
W.FESTIVAL_MOODS = {
  winterveil = { { "cheerful", 12, "Winter Veil" }, { "homesick", 10, "the season for home", when = "alone" } },
  hallowsend = { { "uneasy", 10, "Hallow's End after dark", when = "night" } },
  love = { { "lonely", 12, "the season for sweethearts", when = "alone" } },
  midsummer = { { "cheerful", 12, "the long summer days" } },
  brewfest = { { "merry", 8, "Brewfest" } },
  lunar = { { "homesick", 10, "the old year turning" } },
  noblegarden = { { "cheerful", 10, "spring" } },
}

---------------------------------------------------------------------------
-- AMBITIONS AND DRIVES (0.21.0): what the character is working toward, from the quest log
-- and the state of things (Sources/Goals.lua), for the Ambition glance and "What drives
-- them" at the end of History. Lines are picked per character and per goal; a line whose
-- {tag} has nothing to fill it is skipped, so every kind keeps one that needs only the
-- essentials. {q}: a quest title (quoted), {chain}: what a quest chain is about,
-- {place}: a dungeon, {zone}: the quest's land, {mount}, {gold}, {cost}, {prof}, {rank}
-- (the craft rank now, "an apprentice"), {next} (the rank after, "journeyman"),
-- {nextlevel}, {faction}, {standing} ("honoured by"), {what} (a class trial), {n}, {left},
-- {level}, {goal} (a Chronicle goal), {t} (an RPG Dialogue story).
---------------------------------------------------------------------------

-- Quest chains part-done: what each chain in W.EARNED_QUEST is about, for "Means to see
-- {chain} through."
W.CHAIN_GOAL = {
  ["Princess Must Die!"] = "the business with Princess at the Brackwell Pumpkin Patch",
  ["The People's Militia"] = "the People's Militia's fight for Westfall",
  ["The Defias Brotherhood"] = "the Defias business",
  ["The Legend of Stalvan"] = "the story of Stalvan Mistmantle",
  ["Stalvan Mistmantle"] = "the story of Stalvan Mistmantle",
  ["Morganth"] = "the trouble in the Tower of Ilgalar",
  ["The Stockade Riots"] = "the riots in the Stockade",
  ["Crime and Punishment"] = "the matter of Dextren Ward's crimes",
  ["Mor'Ladim"] = "the matter of Mor'Ladim",
  ["Morbent Fel"] = "the hunt for Morbent Fel",
  ["Big Game Hunter"] = "the hunt for King Bangalash",
  ["The Green Hills of Stranglethorn"] = "the lost pages of The Green Hills of Stranglethorn",
  ["Rin'ji is Trapped!"] = "Rin'ji's rescue from Quel'Danil Lodge",
  ["Battle of Darrowshire"] = "the Battle of Darrowshire",
  ["In Dreams"] = "Taelan Fordring's road",
  ["The Platinum Discs"] = "the Platinum Discs of Uldaman",
  ["The Royal Rescue"] = "the rescue of Princess Moira",
  ["The Key to Scholomance"] = "the key to Scholomance",
  ["Seal of Ascension"] = "the Seal of Ascension",
  ["Drakefire Amulet"] = "the Drakefire Amulet",
  ["Attunement to the Core"] = "the way into the Molten Core",
  ["Burning Blade Medallion"] = "the Burning Blade's medallion",
  ["The Absent Minded Prospector"] = "Prospector Remtravel's dig",
  ["The Tower of Althalaxx"] = "the business of the Tower of Althalaxx",
  ["Lost in Battle"] = "the search for Mankrik's wife",
  ["Kolkar Leaders"] = "the hunt for Barak Kodobane",
  ["Counterattack!"] = "the fight against the Kolkar",
  ["Leaders of the Fang"] = "the matter of the Fang's leaders",
  ["Willix the Importer"] = "Willix the Importer's escape from Razorfen Kraul",
  ["Extinguishing the Idol"] = "the idol in Razorfen Downs",
  ["Bring the End"] = "the business with Amnennar the Coldbringer",
  ["The Missing Diplomat"] = "the missing diplomat",
  ["It's Dangerous to Go Alone"] = "the matter of Linken's lost memory",
  ["Corruption of Earth and Seed"] = "the corruption in Maraudon",
  ["Blood of the Black Dragon Champion"] = "the hunt for the Black Dragon Champion's blood",
  ["In the Name of the Light"] = "the Scarlet Monastery business",
  ["Into The Scarlet Monastery"] = "the Scarlet Monastery business",
  ["Gnomer-gooooone!"] = "the reckoning in Gnomeregan",
  ["The Grand Betrayal"] = "the reckoning in Gnomeregan",
  ["Arugal Must Die"] = "the business with Archmage Arugal",
  ["Whirlwind Weapon"] = "a warrior's trial for a whirlwind weapon",
  ["Verigan's Fist"] = "the forging of Verigan's Fist",
}

-- Earlier steps of those chains, by title -> the chain's last quest (English titles).
W.CHAIN_STEPS = {
  ["Scarlet Subterfuge"] = "In Dreams",
  ["Brother Anton"] = "In the Name of the Light", ["Down the Scarlet Path"] = "In the Name of the Light",
  ["Skeletal Fragments"] = "The Key to Scholomance", ["Mold Rhymes With..."] = "The Key to Scholomance",
  ["Fire Plume Forged"] = "The Key to Scholomance", ["Araj's Scarab"] = "The Key to Scholomance",
  ["Dragonkin Menace"] = "Drakefire Amulet", ["The True Masters"] = "Drakefire Amulet",
  ["Marshal Windsor"] = "Drakefire Amulet", ["Jail Break!"] = "Drakefire Amulet",
  ["The Great Masquerade"] = "Drakefire Amulet", ["The Dragon's Eye"] = "Drakefire Amulet",
  ["For The Horde!"] = "Blood of the Black Dragon Champion", ["What the Wind Carries"] = "Blood of the Black Dragon Champion",
  ["Oculus Illusions"] = "Blood of the Black Dragon Champion",
  ["Emberstrife"] = "Blood of the Black Dragon Champion",
  ["The Tome of Valor"] = "Verigan's Fist", ["The Test of Righteousness"] = "Verigan's Fist",
  ["Morgan Ladimore"] = "Mor'Ladim",
}

-- Dungeons and raids, by the name the quest log files their quests under.
W.GOAL_DUNGEONS = {
  ["Ragefire Chasm"] = {}, ["Wailing Caverns"] = {}, ["The Deadmines"] = {}, ["Shadowfang Keep"] = {},
  ["Blackfathom Deeps"] = {}, ["The Stockade"] = {}, ["Stormwind Stockade"] = {}, ["Gnomeregan"] = {},
  ["Razorfen Kraul"] = {}, ["Scarlet Monastery"] = {}, ["Razorfen Downs"] = {}, ["Uldaman"] = {},
  ["Zul'Farrak"] = {}, ["Maraudon"] = {}, ["Sunken Temple"] = {}, ["The Temple of Atal'Hakkar"] = {},
  ["Blackrock Depths"] = {}, ["Blackrock Spire"] = {}, ["Lower Blackrock Spire"] = {}, ["Upper Blackrock Spire"] = {},
  ["Dire Maul"] = {}, ["Scholomance"] = {}, ["Stratholme"] = {},
  ["Molten Core"] = { raid = true }, ["Onyxia's Lair"] = { raid = true }, ["Blackwing Lair"] = { raid = true },
  ["Zul'Gurub"] = { raid = true }, ["Ruins of Ahn'Qiraj"] = { raid = true }, ["Ahn'Qiraj"] = { raid = true },
  ["Temple of Ahn'Qiraj"] = { raid = true }, ["Naxxramas"] = { raid = true },
}

-- Crafts and gathering skills a trainer takes further, with an icon each.
W.GOAL_PROFS = {
  Alchemy = "Trade_Alchemy", Blacksmithing = "Trade_BlackSmithing", Enchanting = "Trade_Engraving",
  Engineering = "Trade_Engineering", Herbalism = "Trade_Herbalism", Leatherworking = "INV_Misc_ArmorKit_17",
  Mining = "Trade_Mining", Skinning = "INV_Misc_Pelt_Wolf_01", Tailoring = "Trade_Tailoring",
  Cooking = "INV_Misc_Food_15", ["First Aid"] = "Spell_Holy_SealOfSacrifice", Fishing = "Trade_Fishing",
  Jewelcrafting = "INV_Misc_Gem_01",
}
-- The ranks a craft passes through: the cap of each, its name, the next one and the level
-- a trainer asks for it.
W.GOAL_PROF_TIER = {
  { max = 75, word = "an apprentice", next = "journeyman", level = 10 },
  { max = 150, word = "a journeyman", next = "expert", level = 20 },
  { max = 225, word = "an expert", next = "artisan", level = 35 },
}
-- The next standing, as "close to being ... the Argent Dawn".
W.GOAL_STANDING = { [5] = "counted a friend by", [6] = "honoured by", [7] = "revered by", [8] = "exalted by" }

-- A first mount and a swift one, by race, and what they cost (training and mount, roughly).
W.GOAL_MOUNT = {
  Human = { "a horse", "a swift horse" }, Dwarf = { "a ram", "a swift ram" },
  Gnome = { "a mechanostrider", "a swift mechanostrider" }, NightElf = { "a nightsaber", "a swift nightsaber" },
  Orc = { "a riding wolf", "a swift wolf" }, Troll = { "a raptor", "a swift raptor" },
  Tauren = { "a kodo", "a great kodo" }, Scourge = { "a skeletal horse", "a skeletal warhorse" },
  BloodElf = { "a hawkstrider", "a swift hawkstrider" }, Draenei = { "an elekk", "a great elekk" },
  default = { "a mount", "a swift mount" },
}
W.MOUNT_COST = { first = { level = 40, gold = 100 }, swift = { level = 60, gold = 1000 } }

-- Class trials at their level, the first one not yet done (by a spell they'd know, a totem
-- in the bags or a skill line). what: as in "Has come far enough for {what}."
W.GOAL_CLASS = {
  WARLOCK = {
    { level = 10, spell = 697, key = "voidwalker", what = "the binding of a voidwalker", icon = "Spell_Shadow_SummonVoidWalker" },
    { level = 20, spell = 712, key = "succubus", what = "the binding of a succubus", icon = "Spell_Shadow_SummonSuccubus" },
    { level = 30, spell = 691, key = "felhunter", what = "the binding of a felhunter", icon = "Spell_Shadow_SummonFelHunter" },
    { level = 40, spell = 5784, key = "felsteed", what = "a felsteed of {their} own", icon = "Spell_Nature_Swiftness" },
    { level = 60, spell = 23161, key = "dreadsteed", what = "the long summoning of a dreadsteed", icon = "Ability_Mount_Dreadsteed" },
  },
  DRUID = {
    { level = 10, spell = 5487, key = "bear", what = "the trial of the bear", icon = "Ability_Racial_BearForm" },
    { level = 16, spell = 1066, key = "aquatic", what = "the lesson of the sea lion's shape", icon = "Ability_Druid_AquaticForm" },
  },
  PALADIN = {
    { level = 12, spell = 7328, key = "redemption", what = "the trial that teaches Redemption", icon = "Spell_Holy_Resurrection" },
    { level = 40, spell = 13819, key = "warhorse", what = "a warhorse of {their} own", icon = "Spell_Nature_Swiftness" },
    { level = 60, spell = 23214, key = "charger", what = "the long road to a charger", icon = "Ability_Mount_Charger" },
  },
  HUNTER = {
    { level = 10, spell = 1515, key = "taming", what = "a hunter's first taming", icon = "Ability_Hunter_BeastTaming" },
  },
  WARRIOR = {
    { level = 10, spell = 71, key = "defensive", what = "the trial for the defensive stance", icon = "Ability_Warrior_DefensiveStance" },
    { level = 30, spell = 2458, key = "berserker", what = "the trial for the berserker's stance", icon = "Ability_Racial_Avatar" },
  },
  SHAMAN = {
    { level = 4, item = 5175, key = "earth", what = "the trial of earth and its totem", icon = "Spell_Nature_StoneSkinTotem" },
    { level = 10, item = 5176, key = "fire", what = "the trial of fire and its totem", icon = "Spell_Fire_SearingTotem" },
    { level = 20, item = 5177, key = "water", what = "the trial of water and its totem", icon = "Spell_Nature_ManaRegenTotem" },
    { level = 30, item = 5178, key = "air", what = "the trial of air and its totem", icon = "Spell_Nature_InvisibilityTotem" },
  },
  ROGUE = {
    { level = 20, skill = "Poisons", key = "poisons", what = "a rogue's first lessons in poison", icon = "Trade_BrewPoison" },
  },
}

-- The Ambition glance's title and icon for each kind of goal (a chain and a class trial
-- bring their own icon).
W.GOAL_GLANCE = {
  chain = { "Seeing It Through", "INV_Misc_Note_01" },
  raid = { "A Host Wanted", "INV_BannerPVP_02" },
  dungeon = { "A Job Waiting", "INV_Misc_Map_01" },
  ready = { "Back to Collect", "INV_Letter_03" },
  ready_many = { "Back to Collect", "INV_Letter_03" },
  nearly = { "Nearly Done", "INV_Misc_Note_01" },
  classquest = { "A Trial Ahead", "INV_Misc_Book_09" },
  mount_ready = { "Coin for a Mount", "Ability_Mount_RidingHorse" },
  mount = { "Saving Up", "INV_Misc_Coin_02" },
  mount_far = { "On Foot", "Ability_Mount_RidingHorse" },
  swift_ready = { "Coin for a Mount", "Ability_Mount_RidingHorse" },
  swift = { "Saving Up", "INV_Misc_Coin_02" },
  rankup = { "Rising", "INV_Misc_Book_11" },
  prof_cap = { "Learning the Trade", "INV_Misc_Book_09" },
  prof_wait = { "Learning the Trade", "INV_Misc_Book_09" },
  prof_near = { "Learning the Trade", "INV_Misc_Book_09" },
  rep = { "Earning Trust", "INV_Scroll_03" },
  elite = { "Hard Work", "Ability_Warrior_BattleShout" },
  above = { "Work for Later", "INV_Misc_Map_01" },
  current = { "On the Job", "INV_Scroll_03" },
  many = { "Busy Hands", "INV_Misc_Note_01" },
  level = { "Nearly There", "Spell_Holy_SealOfWisdom" },
  level_rested = { "Well Rested", "Spell_Nature_Sleep" },
  nextrank = { "Ambition", "INV_Misc_Book_11" },
  goal = { "Ambition", "INV_Misc_Book_11" },
  thread = { "Unfinished Business", "INV_Misc_Note_02" },
}

-- The Ambition glance: one line, a whole sentence.
W.GOALS = {
  chain = { "Means to see {chain} through.", "Is partway into {chain}, and not stopping there.",
    "Has {chain} to finish, and means to.", "Won't let {chain} go until it's done.", "Is still on the trail of {chain}." },
  raid = { "Has work waiting in {place}, and it will take a whole host.", "Has business in {place} that no party of five will settle.",
    "Has a job that leads into {place}.", "Is gathering the nerve, and the company, for {place}.",
    "Has taken on work meant for a whole host: {q}." },
  dungeon = { "Has a job waiting in {place}.", "Has business down in {place}: {q}.", "Means to go down into {place} before long.",
    "Will need company for {place}.", "Has a job that will need a party behind {them}: {q}." },
  ready = { "Has {q} done, and only needs to hand it in.", "Has finished {q} and has yet to report back.",
    "Has {q} finished, short of turning it in.", "Has only to report back on {q}." },
  ready_many = { "Has {n} jobs done and waiting to be handed in.", "Has {n} jobs to hand in, {q} among them.",
    "Has finished {n} jobs and has yet to collect on them.", "Owes {n} reports to the people who asked." },
  nearly = { "Is nearly done with {q}.", "Is {left} short of finishing {q}.", "Has {q} all but finished.",
    "Is close to the end of {q}." },
  classquest = { "Has come far enough for {what}.", "Has {what} still ahead.", "Is ready for {what}, and hasn't been through it yet.",
    "Is due for {what}." },
  mount_ready = { "Has the coin for {mount}, and the level for it.", "Has saved enough for {mount}.",
    "Can afford {mount} now.", "Has {gold} gold, enough for {mount}." },
  mount = { "Saving for {mount}: {gold} of the {cost} gold put by.", "Is putting coin by for {mount}.",
    "Has {gold} gold saved toward {mount}.", "Is counting coppers toward {mount}." },
  mount_far = { "Is old enough for {mount}, and nowhere near the price.", "Has the level for {mount} but not the {cost} gold.",
    "Is still on foot, and a long way from the price of {mount}.", "Could ride, if {they} had the {cost} gold for {mount}." },
  swift_ready = { "Has the {cost} gold for {mount}.", "Has saved enough for {mount}.", "Can afford {mount} at last.",
    "Has coin enough for {mount} put by." },
  swift = { "Saving for {mount}: {gold} of the {cost} gold so far.", "Is putting coin by for {mount}.",
    "Has {gold} gold saved toward {mount}.", "Is saving hard for {mount}." },
  rankup = { "Is one level short of the rank of {rank}.", "Is close to rising to {rank}.", "Is nearly at the rank of {rank}.",
    "Has the rank of {rank} almost within reach." },
  prof_cap = { "Has learned all {rank} can of {prof}, and needs a trainer to go further.",
    "Needs a trainer who'll teach {prof} at {next} rank.", "Has gone as far in {prof} as {rank} can, and is after {next}'s training.",
    "Has outgrown {their} {prof} lessons." },
  prof_wait = { "Has learned all {rank} can of {prof}; the next lessons wait until level {nextlevel}.",
    "Must wait for level {nextlevel} before {their} {prof} can go further.",
    "Is stuck at the edge of {prof} until level {nextlevel}.", "Has gone as far in {prof} as {their} level allows." },
  prof_near = { "Is close to all {rank} can learn of {prof}.", "Is working {their} {prof} up toward {next} rank.",
    "Is nearly through what {rank} can learn of {prof}.", "Is pushing {their} {prof} toward {next} rank." },
  rep = { "Is close to being {standing} {faction}.", "Is nearly {standing} {faction}.",
    "Is within reach of being {standing} {faction}.", "Is working to be {standing} {faction}." },
  elite = { "Has a job in {zone} that will need company: {q}.", "Has taken on {q}, which no one should try alone.",
    "Has hard work waiting in {zone}.", "Has a job too big for one: {q}." },
  above = { "Has taken on {q}, which is beyond {them} for now.", "Has a job in {zone} that's beyond {them} yet.",
    "Is holding on to {q} for when {they're} stronger.", "Has work waiting in {zone} for when {they've} grown into it." },
  current = { "Is busy with {q} in {zone}.", "Is seeing to {q}.", "Has {q} on hand.", "Is working on {q} in {zone}.",
    "Has taken on {q} and is at it now." },
  many = { "Has {n} jobs on the go.", "Carries {n} jobs at once.", "Has {n} jobs open, and more than enough to do.",
    "Is juggling {n} jobs." },
  level = { "Is close to {their} next level.", "Is nearly at level {level}.", "Has level {level} within reach.",
    "Is almost at level {level}." },
  level_rested = { "Is close to level {level}, and well rested for the push.", "Is nearly at level {level}, after a good rest.",
    "Has level {level} in reach, and rested legs to get there.", "Is rested and nearly at level {level}." },
  nextrank = { "Working toward the rank of {rank}.", "Aims to rise to {rank}.", "Has {their} sights on the rank of {rank}.",
    "Is on the road to the rank of {rank}." },
}

-- What drives them (History, last): the same goals told as part of a life. Whole sentences
-- without a subject, each starting with its verb; the first one gets the character's name.
W.DRIVES = {
  chain = { "Is set on seeing {chain} through to the end.", "Has started on {chain} and means to finish it.",
    "Won't call {their} work done until {chain} is.", "Has {chain} unfinished, and it's what {they} work{s} at." },
  raid = { "Has work that leads into {place}, where a party of five won't do.", "Has business in {place}, and it will take a host.",
    "Has reason to go into {place}.", "Has a job only a whole host can finish." },
  dungeon = { "Has a reason to go down into {place}.", "Has work that will take {them} into {place}, and not alone.",
    "Has a job that ends in {place}.", "Has work that wants a party behind {them}." },
  ready = { "Has {q} done and has yet to collect for it.", "Owes a report on {q}.",
    "Has finished {q}, short of handing it in.", "Has only to walk back and report on {q}." },
  ready_many = { "Has {n} jobs done and waiting to be handed in.", "Has {n} finished jobs to collect on.",
    "Has {n} jobs to hand in, {q} among them.", "Owes {n} reports to the people who asked for them." },
  nearly = { "Is close to the end of {q}.", "Is nearly done with {q}.", "Has {q} all but done.", "Is {left} short on {q}." },
  classquest = { "Has {what} ahead.", "Is ready for {what}.", "Has come far enough in {their} calling for {what}.",
    "Has {what} still to face." },
  mount_ready = { "Has the gold for {mount}.", "Can pay for {mount} now.", "Has saved enough for {mount}.",
    "Has coin enough for {mount}, and the level for it." },
  mount = { "Is putting coin by for {mount}, {gold} of the {cost} gold so far.", "Is saving toward {mount}.",
    "Counts {their} gold against the price of {mount}.", "Has {gold} gold toward {mount}." },
  mount_far = { "Has reached the level for {mount}, but not the price.", "Goes on foot for now; {mount} costs {cost} gold.",
    "Is a long way from the {cost} gold {mount} costs.", "Is still short of the price of {mount}." },
  swift_ready = { "Has the gold for {mount}.", "Has saved the {cost} gold for {mount}.", "Can pay for {mount} now.",
    "Has coin enough for {mount}." },
  swift = { "Is putting coin by for {mount}, {gold} of the {cost} gold so far.", "Is saving toward {mount}.",
    "Counts {their} gold against the price of {mount}.", "Has {gold} gold toward {mount}." },
  rankup = { "Is a level from the rank of {rank}.", "Is close to rising to {rank}.", "Has the rank of {rank} nearly in hand.",
    "Is near enough to {rank} to count the days." },
  prof_cap = { "Has learned all {rank} can of {prof}, and needs a trainer for more.",
    "Needs a trainer to take {their} {prof} to {next} rank.", "Has outgrown {their} {prof} lessons.",
    "Is ready for {next}'s training in {prof}." },
  prof_wait = { "Has gone as far in {prof} as {their} level allows, until {nextlevel}.",
    "Must wait for level {nextlevel} before {their} {prof} can go further.",
    "Has learned all {rank} can of {prof}, and must wait for level {nextlevel} for more.",
    "Is held at the edge of {prof} until level {nextlevel}." },
  prof_near = { "Is working {their} {prof} up toward {next} rank.", "Is close to all {rank} can learn of {prof}.",
    "Is nearly through what {rank} can learn of {prof}.", "Is pushing {their} {prof} toward {next} rank." },
  rep = { "Is close to being {standing} {faction}.", "Is nearly {standing} {faction}.",
    "Is within reach of being {standing} {faction}.", "Has nearly earned the next step with {faction}." },
  elite = { "Has taken on {q}, which no one should try alone.", "Has hard work waiting in {zone}.",
    "Has a job too big for one: {q}.", "Has work in {zone} that will need company." },
  above = { "Is holding on to {q} for when {they're} stronger.", "Has work waiting in {zone} for when {they've} grown into it.",
    "Has taken on {q}, which is beyond {them} for now.", "Has a job in {zone} that's beyond {them} yet." },
  current = { "Is at work on {q} in {zone}.", "Has {q} on hand.", "Is seeing to {q} for now.", "Is busy with {q}." },
  many = { "Has {n} jobs on the go.", "Carries {n} jobs at once.", "Has {n} jobs open.", "Is juggling {n} jobs." },
  level = { "Is close to {their} next level.", "Is nearly at level {level}.", "Has level {level} within reach.",
    "Is almost at level {level}." },
  level_rested = { "Is rested and nearly at level {level}.", "Is close to level {level}, and well rested for it.",
    "Has level {level} in reach, after a good rest.", "Is nearly at level {level}, and rested." },
  nextrank = { "Is working toward the rank of {rank}.", "Aims to rise to {rank}.", "Has {their} sights on the rank of {rank}.",
    "Is on the road to the rank of {rank}." },
  goal = { "Has set {themselves} a goal: {goal}", "Has a goal of {their} own: {goal}", "Has written down what {they're} after: {goal}",
    "Is after one thing in particular: {goal}" },
  thread = { "Wants to get to the bottom of {t}.", "Means to see {t} through.", "Means to find out the truth of {t}.",
    "Has {t} still to settle." },
}

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

-- MOOD MODEL 0.21.0: how the journal (first person) says the new moods.
if W.JOURNAL and W.JOURNAL.feel then
  for k, v in pairs({
    grateful = { "grateful to the people who helped", "thankful for a kindness" },
    humbled = { "humbled", "wiser, and humbler for it" },
    bored = { "restless with nothing to do", "itching for something to happen" },
    homesick = { "missing home", "thinking of home" },
    smug = { "rather pleased with myself", "smug, and I've earned it" },
    exhausted = { "worn to the bone", "exhausted" },
    cheerful = { "cheerful", "in a sunny mood" },
    bitter = { "sour about it all", "nursing a grudge" },
  }) do W.JOURNAL.feel[k] = W.JOURNAL.feel[k] or v end
end

---------------------------------------------------------------------------
-- THE ROAD, land by land (Sources/Road.lua; Compose.RoadStory, the Lately glance and the
-- "Longest stay" statistic). Each line is one sentence without its full stop. {zone}: the
-- land ("Westfall", "the Barrens"), with what it is when there's room ("Westfall, the dry
-- farmland west of Stormwind"); {stay}: how long ("the better part of a week"); {rest}: the
-- level and the work there, each opening with a comma, or nothing; {name}: the character.
---------------------------------------------------------------------------
W.ROAD = {
  -- The first of the lands that mattered.
  first = {
    "Spent {stay} in {zone}{rest}",
    "Gave {stay} to {zone}{rest}",
    "Put in {stay} in {zone}{rest}",
    "Stayed {stay} in {zone}{rest}",
    "Worked {zone} for {stay}{rest}",
  },
  -- The ones after it, in order.
  next = {
    "Then came {stay} in {zone}{rest}",
    "After that {they} spent {stay} in {zone}{rest}",
    "From there it was on to {zone} for {stay}{rest}",
    "Moved on to {zone} next and stayed {stay}{rest}",
    "Later {they} gave {stay} to {zone}{rest}",
    "{zone} came after, with {stay} there{rest}",
  },
  -- The one they stayed in longest (when it isn't the first).
  longest = {
    "{zone} held {them} longest, {stay}{rest}",
    "The longest stay was in {zone}, {stay}{rest}",
    "Most of {their} time went to {zone}, {stay} in all{rest}",
    "No land kept {them} longer than {zone}: {stay}{rest}",
    "{zone} is where {they} stayed longest, {stay}{rest}",
  },
  -- How long, from the days a stay lasted...
  days = {
    { max = 3, words = { "a couple of days", "two days or so" } },
    { max = 5, words = { "a few days", "three or four days" } },
    { max = 8, words = { "the better part of a week", "most of a week" } },
    { max = 12, words = { "more than a week", "a week and more" } },
    { max = 20, words = { "a fortnight or so", "the better part of a fortnight" } },
    { max = 35, words = { "most of a month", "close on a month" } },
    { max = math.huge, words = { "more than a month", "the better part of two months" } },
  },
  -- ...or the hours spent there, when it was all one sitting or two.
  hours = {
    { max = 1.5, words = { "an hour or two", "a short spell" } },
    { max = 4, words = { "a few hours", "an afternoon or so" } },
    { max = 8, words = { "a long day", "the length of a long day" } },
    { max = 16, words = { "a couple of long days", "two long days" } },
    { max = math.huge, words = { "many long days", "day after long day" } },
  },
  -- The level while there: {a} and {b} in words ("twelve", "seventeen").
  climb = { ", going from level {a} to {b} there", ", arriving at level {a} and leaving at {b}", ", climbing from level {a} to {b}",
    ", rising from level {a} to {b} along the way" },
  level = { ", at around level {a}", ", at level {a} or so", ", somewhere about level {a}" },
  -- The work done there: {story} (a storyline), {n} (jobs, in words).
  story = { ", mostly on {story}", ", much of it on {story}", ", most of it caught up in {story}", ", largely on {story}" },
  jobs = { ", seeing {n} jobs through", ", with {n} jobs done there", ", taking on {n} jobs along the way" },
  town = { ", working out of {town}", ", mostly around {town}", ", with {town} for a base" },
  inn = { ", putting up at {inn}", ", lodging at {inn}", ", sleeping at {inn}" },
  -- What else happened there, after a semicolon. {dungeon}, {boss}, {times} ("twice").
  boss = { "it's also where {they} went down into {dungeon} and brought down {boss}",
    "from there {they} went down into {dungeon} after {boss}",
    "{dungeon} is close by, and it was from there that {they} went after {boss}",
    "it was from there that {they} went into {dungeon} and came out with {boss} beaten" },
  dungeon = { "from there {they} went down into {dungeon}", "it's also where {they} first went into {dungeon}",
    "{dungeon} lies close by, and {they} went down into it from there" },
  deaths = { "it's also where {name} fell {times}", "{name} fell there {times}, too", "{name} was laid low there {times}",
    "it's where {name} met {their} end {times} and came back from it" },
  close = { "{name} came close to dying there {times}", "{name} nearly fell there {times}",
    "it's where {name} came nearest to the end, {times}" },
  -- The land they keep coming back to: {n} ("eleven times").
  returns = {
    "Keeps coming back to {zone}, {n} now",
    "Of all the lands, {zone} is the one {they} return{s} to most, {n} so far",
    "{zone} keeps drawing {them} back; {they've} returned {n}",
    "Returns to {zone} more often than anywhere else, {n} so far",
    "Has gone back to {zone} {n}, more than to anywhere else",
  },
  -- The land they left quickly.
  quick = {
    "Didn't stay long in {zone}, and hasn't been back",
    "Passed through {zone} in under an hour and hasn't gone back since",
    "Had seen enough of {zone} within the hour",
    "{zone} got no more than a look before {they} moved on",
    "Left {zone} almost as soon as {they} arrived",
  },
  -- Where they've been this past week ({sub}: ", around Booty Bay" or nothing).
  lately = {
    "These days {they're} mostly in {zone}{sub}",
    "Lately {they've} kept to {zone}{sub}",
    "Most of this past week has gone to {zone}{sub}",
    "{zone} is where {they've} spent this past week{sub}",
    "This week it has been {zone}, for the most part{sub}",
  },
  -- Back in a land after a long while ({away}: "a month").
  lately_back = {
    "Back in {zone} lately, after {away} away",
    "Has come back to {zone} this week, after {away} elsewhere",
    "Is in {zone} again, for the first time in {away}",
    "Returned to {zone} only lately, {away} after last leaving it",
  },
  away = {
    { max = 12, words = "a week" }, { max = 19, words = "two weeks" }, { max = 26, words = "three weeks" },
    { max = 45, words = "a month" }, { max = 75, words = "two months" }, { max = 150, words = "a few months" },
    { max = math.huge, words = "half a year or more" },
  },
}

-- The Lately glance: back in a land, and moving on from a long stay.
W.SAY.lately_back = { "Back in {zone} after {away} away.", "Has come back to {zone} after {away} elsewhere.",
  "In {zone} again, for the first time in {away}.", "Returned to {zone} lately, {away} after last leaving it.",
  "On the roads of {zone} again after {away}." }
W.SAY.lately_moved = { "Has left {from} behind after {stay} there, and is new to {zone}.",
  "After {stay} in {from}, has moved on to {zone}.", "Fresh to {zone}, with {stay} in {from} behind {them}.",
  "Done with {from} for now, after {stay}; {zone} is next.", "Only lately came on to {zone}, after {stay} in {from}." }

---------------------------------------------------------------------------
-- WORK 0.22.0: the kind of work the character takes on (Sources/Work.lua).
---------------------------------------------------------------------------
W.WORK = {
  -- English cues in a job's title, objectives and text (lower case, Lua patterns). On another
  -- language they find nothing and the log's objective types decide.
  CUES = {
    escort = { "escort", "accompany", "see me safely", "see her safely", "see him safely", "safe passage", "protect me",
      "guide me", "lead me out", "lead me to", "get me out of", "walk with me" },
    rescue = { "rescue", "free the ", "free them", "free my", "freed", "release the", "prisoner", "captive", "imprisoned",
      "held hostage", "break out" },
    bounty = { "bounty", "wanted", "dead or alive", "the head of", "his head", "her head", "price on", "reward for the" },
    delivery = { "deliver", "take this", "bring this", "carry this", "letter", "package", "parcel", "report to",
      "report back to", "speak with", "speak to", "message to", "give this", "hand this" },
    investigation = { "investigate", "explore", "scout", "search for", "find out", "discover", "locate", "look into",
      "survey", "find the source", "learn what" },
    slaying = { "kill", "slay", "slain", "destroy", "cull", "thin their", "thin out", "wipe out", "put down", "exterminate" },
    gathering = { "collect", "gather", "bring me", "recover", "retrieve", "fetch", "samples", "harvest" },
    holiday = { "winter veil", "lunar festival", "hallow's end", "midsummer", "love is in the air", "harvest festival",
      "children's week", "noblegarden", "brewfest" },
  },
  -- Quest log headers that say what a job is.
  HOLIDAY = { seasonal = true, ["lunar festival"] = true, ["feast of winter veil"] = true, ["winter veil"] = true,
    ["hallow's end"] = true, ["midsummer fire festival"] = true, ["love is in the air"] = true, ["harvest festival"] = true,
    ["children's week"] = true, noblegarden = true, brewfest = true },
  CLASS_HEADERS = { warrior = true, paladin = true, hunter = true, rogue = true, priest = true, shaman = true, mage = true,
    warlock = true, druid = true },
  PROF_HEADERS = { fishing = true, cooking = true, ["first aid"] = true, alchemy = true, blacksmithing = true,
    enchanting = true, engineering = true, herbalism = true, leatherworking = true, mining = true, skinning = true,
    tailoring = true },

  -- The statistic: "120 slaying, 64 gathering, 31 courier".
  STAT = { slaying = "slaying", gathering = "gathering", delivery = "courier", escort = "escort", investigation = "scouting",
    rescue = "rescue", bounty = "bounty", dungeon = "dungeon", class = "calling", profession = "trade", holiday = "festival" },

  -- History, the longer record: what most of the work has been.
  MAIN = {
    slaying = { "Most of {their} work has been the killing kind",
      "The jobs {they} take{s} on are mostly the ones that end with something dead",
      "Most of what {they've} been paid for has ended with something lying still",
      "When word goes round that something needs killing, {they} tend{s} to be the one who answers",
      "Thinning out whatever troubles the farms and roads has been most of {their} work" },
    gathering = { "Most of {their} work has been fetching and collecting",
      "Filling sacks for other people has been most of {their} work",
      "Most of the jobs {they've} taken have meant gathering something up and bringing it back",
      "Much of {their} working life has gone on collecting things other people needed" },
    delivery = { "Most of {their} work has been carrying things from one person to another",
      "Errands and deliveries make up most of {their} work",
      "Much of {their} work has been running messages and parcels between towns",
      "More of {their} jobs have been deliveries than anything else" },
    escort = { "An unusual share of {their} work has been seeing travellers safely on their way",
      "Much of {their} work has been walking beside people who couldn't make the road alone",
      "Escort work makes up more of {their} jobs than most would take on",
      "Has spent more of {their} working days guarding travellers than doing anything else" },
    investigation = { "Most of {their} work has been looking into things: tracks, ruins, rumours",
      "Much of {their} work has meant going to see what's wrong somewhere and coming back to say",
      "Scouting and asking questions make up most of {their} work",
      "More of {their} jobs have been about finding things out than anything else" },
    rescue = { "A good share of {their} work has been getting people out of cages and cells",
      "Much of {their} work has been bringing back people who were taken",
      "Rescues make up more of {their} jobs than most people's",
      "Has spent much of {their} working life freeing captives" },
    bounty = { "Much of {their} work has been bounty work",
      "Most of {their} jobs have come off the wanted posters",
      "A good deal of {their} work has been hunting down troublemakers for the price on their heads",
      "Bounties make up more of {their} work than anything else" },
    dungeon = { "Much of {their} work has taken {them} underground, into places others won't go",
      "Most of {their} jobs have been the kind that need a group and a long way down",
      "A good share of {their} work has been done in dungeons",
      "More of {their} jobs have led into dungeons than anywhere else" },
    class = { "Much of {their} work has been for those who trained {them}",
      "A good share of {their} work has been set by {their} own trainers",
      "Much of {their} work has been the tests and errands of {their} own calling",
      "More of {their} jobs have come from {their} own teachers than from anyone else" },
    profession = { "Much of {their} work has been for {their} trade",
      "A good share of {their} jobs have come from the masters of {their} craft",
      "More of {their} work has been about {their} trade than about fighting",
      "Much of what {they've} taken on has been to do with {their} craft" },
    holiday = { "A surprising share of {their} work has been festival errands",
      "Much of {their} work has come with the festivals",
      "More of {their} jobs have been festival business than most people's",
      "Has done a good deal of work for the festivals" },
  },
  -- ...and the next kind, where it was done most.
  THOUGH = {
    slaying = { "though {they've} also put down a fair few troublemakers in {zone}",
      "though {zone} has seen {them} take up arms for pay more than once",
      "though in {zone} it tended to end with something dead",
      "though plenty of {their} jobs in {zone} came down to killing" },
    gathering = { "though {they've} filled more than a few sacks for people in {zone}",
      "though {zone} kept {them} busy picking things up for others",
      "though {they've} fetched and carried plenty around {zone}",
      "though in {zone} it was mostly collecting" },
    delivery = { "though {they've} carried more letters across {zone} than anyone needs to",
      "though {they've} run more errands around {zone} than {they} could count",
      "though {zone} has seen {them} carrying parcels from door to door",
      "though in {zone} {they} mostly carried messages" },
    escort = { "though {they've} walked more than one traveller safely through {zone}",
      "though in {zone} {they} kept ending up as someone's escort",
      "though {zone} had {them} guarding travellers more than once",
      "though {they've} seen a few people safely across {zone}" },
    investigation = { "though {they've} done a good deal of poking about in {zone}",
      "though in {zone} the work was mostly finding things out",
      "though {zone} had {them} scouting more often than not",
      "though {they've} gone to look into plenty of trouble around {zone}" },
    rescue = { "though {they've} freed a captive or two in {zone}",
      "though in {zone} {they} brought back people who'd been taken",
      "though {zone} has seen {them} open a few cages",
      "though {they've} pulled people out of trouble in {zone}" },
    bounty = { "though {they've} collected a bounty or two in {zone}",
      "though in {zone} {they} went after the names on the posters",
      "though the wanted posters in {zone} kept {them} busy",
      "though {they've} hunted down a few wanted names around {zone}" },
    dungeon = { "though {they've} gone underground for work more than once",
      "though now and then the work has led down into a dungeon",
      "though a few jobs have taken {them} into the dark with a group",
      "though some of {their} jobs have meant a dungeon and a group at {their} back" },
    class = { "though {their} own trainers have kept {them} busy too",
      "though {they've} made time for the tests of {their} own calling",
      "though {their} teachers have sent {them} on more than one errand",
      "though {they've} also done what {their} own order asked" },
    profession = { "though {their} trade has sent {them} on a few errands of its own",
      "though {they've} also taken on work for {their} craft",
      "though the masters of {their} trade have had a few jobs for {them}",
      "though some of it has been for {their} craft" },
    holiday = { "though the festivals have had {them} running about too",
      "though {they've} done {their} share of festival errands",
      "though every festival seems to find a job for {them}",
      "though {they} rarely miss{es} a festival's odd jobs" },
  },
  -- Escorts seen through and lost: {n} home safely, {lost} lost, the last lost in {zone}.
  ESCORTS = {
    done = { "Has seen {n} escorts home safely", "Has walked {n} travellers safely to where they were going",
      "Has brought {n} people safely through on escort work", "Has seen {n} charges home without losing one",
      "Has guarded {n} travellers on the road and got every one of them there" },
    mixed = { "Has seen {n} escorts home safely and lost {lost} on the road out of {zone}",
      "Has brought {n} travellers safely through, though {lost} never made it out of {zone}",
      "Of the people {they've} escorted, {n} got where they were going; {lost} didn't make it out of {zone}",
      "Has seen {n} escorts through and lost {lost} along the way in {zone}" },
    lost = { "Has tried escort work, and lost {lost} on the road out of {zone}",
      "Has yet to see an escort through; the last was lost on the road out of {zone}",
      "Took on escort work and lost {lost} in {zone}",
      "Has lost {lost} on escort work, the last on the road out of {zone}" },
  },
  -- History's news, past tense after the name.
  EV = {
    escort = { "saw an escort safely through {zone}", "brought a traveller safely across {zone}",
      "walked someone safely through {zone}", "got a charge safely to the end of the road in {zone}" },
    escort_lost = { "lost someone in {their} care on the road in {zone}", "failed to see an escort through {zone}",
      "lost the one {they} guarded on the road through {zone}", "couldn't keep a charge alive on the road in {zone}" },
  },
  -- The one worked for most (History's people).
  GIVER = { "Does a lot of work for {who}", "Has taken more jobs from {who} than from anyone else",
    "Is often to be found doing some job or other for {who}", "Is one of the people {who} sends when something needs doing",
    "Has done more work for {who} than for anyone" },
  -- Personality, once the counts back them.
  HABIT = {
    courier = { "Takes every courier job going", "Never turns down a letter that needs carrying",
      "Will carry a parcel anywhere for anyone", "Is quick to say yes when something needs delivering" },
    coin = { "Prefers coin to kit when a job pays out", "Takes the reward that sells best, not the one that fits",
      "When a job offers a choice, picks whatever fetches the best price",
      "Would rather be paid in something to sell than something to wear" },
    kit = { "Picks the piece {they} can use when a job offers a choice", "Takes the reward {they} can wear over the one that sells",
      "Chooses whatever reward suits {them} best, never mind its price", "Has an eye for the reward {they} can put to use" },
    escort = { "Doesn't mind walking at someone else's pace", "Will take on an escort when others won't",
      "Is often the one walking beside a slow traveller", "Has a patience for escort work that most people lack" },
    slaying = { "Goes for the jobs that need something killed", "Prefers work with a clear enemy at the end of it",
      "Picks the job with the fight in it, given the choice", "Takes to the killing jobs more readily than the errands" },
    gathering = { "Doesn't mind the jobs that mean filling a sack", "Will happily spend a day collecting for someone else",
      "Takes on the gathering jobs others find tedious", "Doesn't mind picking things up one at a time for someone else" },
    investigation = { "Volunteers for the jobs that mean poking about where others won't", "Likes the work that starts with a question",
      "Goes looking when something's gone quiet or gone wrong", "Takes the scouting jobs first" },
    bounty = { "Reads the wanted posters wherever {they} go{es}", "Keeps an eye on the bounty boards",
      "Likes a job with a name and a price on it", "Is drawn to the bounty boards in every town" },
    ["repeat"] = { "Keeps going back for the same steady work", "Turns in the same jobs again and again",
      "Will do the same useful job as often as it's asked for", "Has a few jobs {they} come{s} back to time after time" },
    shared = { "Is happy to take on work a companion passes along", "Takes up whatever job the group is on",
      "Will share the work when a companion has some going", "Rarely says no to a job a companion offers" },
  },
  -- Lately.
  LATELY = {
    escort = { "Has just seen an escort through {zone}.", "Has just brought someone safely across {zone}.",
      "Is fresh from seeing a traveller safely through {zone}.", "Has only just got a traveller safely to the end of the road in {zone}." },
    escort_lost = { "Has just lost someone in {their} care on the road through {zone}.",
      "Couldn't keep {their} charge alive on the road through {zone}.", "Is back from a failed escort in {zone}.",
      "Lost the one {they} guarded on the road in {zone}, and hasn't shaken it yet." },
    run_delivery = { "Has been running errands all over {zone}.", "Has spent the last hour carrying messages around {zone}.",
      "Is partway through a round of deliveries in {zone}.", "Has been back and forth across {zone} with parcels and letters." },
    run_slaying = { "Has been taking on one hunting job after another in {zone}.",
      "Has been clearing out trouble around {zone} for whoever's paying.", "Has done {n} killing jobs in {zone} in the last hour.",
      "Has spent the last hour thinning out what troubles {zone}." },
    run_gathering = { "Has been filling sacks for people around {zone}.", "Has spent the last hour fetching things for folk in {zone}.",
      "Has handed in {n} collecting jobs in {zone} in the last hour.", "Has been gathering for half of {zone}." },
    run_investigation = { "Has been poking about {zone} for answers.", "Has spent the last hour scouting {zone}.",
      "Has been looking into one thing after another in {zone}.", "Has been all over {zone}, finding things out." },
    run = { "Has been taking on one job after another in {zone}.", "Has handed in {n} jobs in {zone} in the last hour.",
      "Has spent the last hour on one job after another in {zone}.", "Has been busy with odd jobs around {zone}." },
  },
  RUN_TITLE = { delivery = "On the Errand Run", slaying = "Hired Help", gathering = "Fetching and Carrying",
    investigation = "Asking Around" },
}

-- HOW THEY FIGHT 0.22.0 (Sources/Style.lua): role, style, school and habits in a fight, each
-- said only once the counts back it.
W.STYLE = {
  -- The Role statistic.
  ROLE = { healer = "Healer", tank = "Defender", melee = "Striker", ranged = "Sharpshooter", spell = "Spellcaster" },
  -- Personality.
  TEMPER = {
    healer = {
      "Fights from the back of a group, mending more than striking",
      "In company, would sooner keep someone on {their} feet than land a blow",
      "Watches {their} companions more closely than the foe, and heals before {they} strike{s}",
      "Leaves the striking to others when there are others to do it, and keeps them standing",
      "Spends a group's fights with an eye on everyone's wounds",
    },
    tank = {
      "Steps in front when a group runs into trouble",
      "Draws a foe's anger and holds it, so the others can work",
      "Takes the blows in a group fight so that nobody else has to",
      "Is the first one a foe turns on, and means to be",
      "Stands at the front of a group and lets the trouble come",
    },
    hybrid = {
      "Turns from mending to striking and back as a fight needs",
      "Heals in one breath and strikes in the next",
      "Switches between keeping others up and putting foes down",
      "Is as ready to mend as to strike, and does both in most fights",
    },
    melee = {
      "Fights up close, near enough to hear a foe breathe",
      "Would rather close the distance than trade blows from afar",
      "Goes in close and stays there until the fight is done",
      "Likes a foe within arm's reach",
      "Does {their} fighting at arm's length or nearer",
    },
    ranged = {
      "Keeps {their} distance in a fight and picks foes off from afar",
      "Prefers a foe at the far end of a long shot",
      "Fights from range, and seldom lets anything get close",
      "Likes plenty of open ground between {them} and a foe",
    },
    spell = {
      "Fights with spells rather than steel",
      "Settles most fights with spellwork",
      "Trusts a spell over a strong arm",
      "Would rather end a fight with a word of power than a swing",
    },
    Fire = { "Reaches for fire first", "Burns most of {their} foes", "Answers trouble with fire",
      "Has a habit of setting {their} foes alight", "Favours fire over every other school" },
    Frost = { "Reaches for frost first", "Slows a foe with cold before finishing it", "Leaves most of {their} foes frozen to the spot",
      "Favours frost over every other school" },
    Shadow = { "Reaches for shadow first", "Fights with shadow, and lets it eat at a foe", "Wears foes down with shadow",
      "Leans on the dark arts in a fight" },
    Holy = { "Fights with the Light as well as for it", "Turns holy fire on {their} foes",
      "Brings the Light down on whatever stands in the way", "Strikes with holy power more than anything else" },
    Nature = { "Calls on nature's own fury in a fight", "Fights with lightning, thorn and venom",
      "Lets the wilds do most of {their} fighting", "Favours the powers of nature over any other" },
    Arcane = { "Reaches for raw arcane power first", "Fights with pure arcane force", "Hurls arcane power at most of {their} foes",
      "Favours the arcane over every other school" },
    interrupt = { "Is quick to cut off a spellcaster mid-word", "Rarely lets an enemy caster finish a spell",
      "Listens for a foe's chanting, and stops it", "Has a sharp ear for a spell being woven, and a sharper answer",
      "Breaks a caster's concentration as a matter of habit" },
    opener = { "Is usually first into a fight", "Strikes first more often than not", "Starts most of {their} group's fights",
      "Seldom waits for anyone else to start a fight", "Tends to open the fight before the rest are ready" },
    cc = { "Takes one foe out of a fight before dealing with the rest", "Would sooner put one foe out of action than fight two at once",
      "Likes to thin a fight out before it starts", "Has a habit of taking the most dangerous foe out of the fight first" },
    cleanse = { "Lifts curses and sickness from others without being asked", "Keeps watch for poisons and curses on the people around {them}",
      "Is quick to clear an affliction from a companion", "Notices when someone nearby is ailing, and does something about it" },
    quick = { "Ends most fights quickly", "Doesn't let a fight drag on", "Fights in short, sharp bursts",
      "Finishes things fast once a fight starts" },
    long = { "Wears a foe down over a long fight", "Is patient in a fight, and outlasts most foes",
      "Lets a fight run long, and is still standing at the end", "Settles in for a long fight without fuss" },
    often = { "Seldom goes long without a fight", "Finds a fight, or is found by one, every few minutes",
      "Spends a good part of every hour fighting", "Rarely has a quiet hour on the road" },
    seldom = { "Picks {their} fights sparingly", "Goes long stretches without raising a hand to anyone", "Fights only now and then",
      "Keeps {their} fights few and far between" },
  },
  -- About: Physical, how they carry themselves in a fight.
  PHYSICAL = {
    healer = { "In a fight {they} keep{s} to the back, where {they} can see everyone",
      "Stands a step behind {their} companions in a fight, watching more than striking",
      "Keeps half an eye on the foe in a fight and the rest on {their} friends' wounds",
      "Hangs back in a fight, light on {their} feet and ready to go to whoever needs {them}" },
    tank = { "Stands square and low in a fight, hard to move", "Squares up to a foe and doesn't give ground",
      "Fights with {their} weight forward, braced for the next blow", "Leans into a fight rather than away from it" },
    melee = { "Moves in close in a fight, quick on {their} feet", "Fights close and low, always pressing forward",
      "Closes on a foe fast and keeps moving", "Circles a foe in a fight, looking for an opening" },
    ranged = { "Keeps moving in a fight, always putting ground between {them} and a foe",
      "Fights from a distance with a steady, unhurried aim", "Holds still at range in a fight, then lets fly",
      "Watches a fight from afar, eyes narrowed" },
    spell = { "Stands still and intent in a fight while {they} work{s} {their} spells",
      "Fights with {their} hands more than {their} feet, weaving one spell after another",
      "Hangs back in a fight, lips moving", "Keeps out of reach in a fight and lets {their} spells do the work" },
  },
  -- History's older record: clauses after "{they've}".
  HISTORY = {
    healer = { "spent most of {their} fights keeping others standing", "done more mending than striking in {their} group fights",
      "kept {their} companions on their feet through most of {their} fights",
      "been the one holding a group together in most of its fights" },
    tank = { "taken the blows meant for others in most of {their} group fights",
      "stood at the front of most of the groups {they've} fought with",
      "held the enemy's attention through most of {their} group fights",
      "been the one the foe went for in most of {their} group fights" },
    damage = { "done most of {their} group's striking", "been one of the hands that ends a group's fights",
      "spent {their} group fights bringing foes down", "put most of {their} effort in a group into the killing" },
    interrupt = { "cut off {n} spells before they were finished", "stopped {n} enemy spells mid-cast",
      "broken off {n} enemy castings", "silenced {n} spells halfway through" },
    cleanse = { "lifted {n} curses, poisons and sicknesses from others", "cleared {n} afflictions from the people around {them}",
      "drawn the poison or the curse out of others {n} times", "rid {their} companions of {n} afflictions" },
    foe = { "fought {foes} more often than anything else", "faced {foes} in more fights than any other kind of foe",
      "spent more of {their} fights against {foes} than against anything else", "made {foes} {their} most common foe" },
    weapons = { "trained {their} hand with {list} as far as {their} years allow",
      "kept {their} skill with {list} as sharp as it can be for now",
      "worked {their} skill with {list} up to the limit of {their} experience",
      "brought {their} skill with {list} as far as it will go for now" },
  },
  -- The kinds of creature (UnitCreatureType), as History says them.
  FOES = { Humanoid = "two-legged foes", Beast = "beasts", Undead = "the undead", Demon = "demons", Elemental = "elementals",
    Dragonkin = "dragonkin", Giant = "giants", Mechanical = "machines", Aberration = "aberrations" },
  -- The Company glance: the part they play in the group they're in now.
  COMPANY = {
    healer = { "the group's healer", "the one keeping them all on their feet", "doing the group's mending",
      "the one they look to when the wounds pile up" },
    tank = { "out in front, taking the blows", "the one standing between the group and the trouble", "the group's front line",
      "the one the trouble goes for first" },
    melee = { "doing the close work", "fighting at the front with the rest", "getting in close when it comes to blows",
      "doing a share of the striking" },
    ranged = { "covering the rest from range", "picking foes off from the back", "keeping the far foes busy",
      "striking from a distance" },
    spell = { "bringing the spellwork", "the one with the spells", "casting from the back of the group",
      "doing the group's spellwork" },
  },
  -- Mood: why a well-played fight left them satisfied.
  MOOD = { "cut off {n} spells in one fight", "stopped {n} casters mid-word in a single fight",
    "broke {n} castings in one fight" },
}
