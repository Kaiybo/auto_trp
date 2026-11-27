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
      "Breath that could strip paint, and a grin to match.",
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
      "Head turning at every new sight, like a child at a fair.",
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
      "Smiles when spoken to, but it doesn't reach the eyes.",
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
  away_rest = { "nodding off in {place}", "half asleep in {place}", "dozing in {place}" },
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
  determined = { "Stubborn as a mountain, and twice as hard to shift." },
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
  DRUID = { "Moves with a wild, easy grace." },
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
  thread_stirring = { "Has been asking around about {t}.", "Has caught wind of {t}.", "Has started looking into {t}." },
  thread_unfolding = { "Is caught up in {t}.", "Can't leave {t} alone.", "Is in the middle of {t}." },
  thread_resolved = { "Saw {t} through to the end.", "Had a hand in settling {t}.", "Helped put {t} to rest." },
  thread_soured = { "Watched {t} go badly wrong.", "Was there when {t} went sour.", "Saw {t} turn out badly." },
  boss = { "Was there when {who} fell{where}.", "Helped bring down {who}{where}.", "Stood in the fight that finished {who}{where}." },
  cleared = { "Has just come back up out of {place}.", "Is fresh out of {place}.", "Has only just climbed back out of {place}." },
  fight = { "Fresh from a fight with {who}.", "Has just seen off {who}.", "Still breathing hard after a fight with {who}." },
  fight_long = { "Fresh from a long, hard fight with {who}.", "Has just come through a long fight with {who}." },
  fight_close = { "Barely survived a fight with {who}.", "Came close to losing a fight with {who}.", "Only just got the better of {who}." },
  job = { "Just saw a job through: {q}{where}.", "Has just finished a job: {q}{where}.", "Has just wrapped up a job: {q}{where}." },
  find = { "Recently found {item}{where}.", "Has just come by {item}{where}.", "Turned up {item}{where} lately." },
  newzone = { "New to {zone}, and seeing it for the first time.", "Has only just arrived in {zone}.", "A newcomer to {zone}." },
  talk = { "Was just talking {how}with {who}{where}.", "Has just been speaking {how}with {who}{where}." },
  lastseen = { "Was last seen in conversation with {who}.", "Was last seen talking with {who}." },
  around = { "Has been around {where} lately.", "Has been spending time around {where}.", "Has been keeping to {where} lately." },
  -- Company
  host = { "Marching with a host of {n}.", "One of a host of {n}.", "Part of a company {n} strong." },
  party = { "Travelling with {party}.", "On the road with {party}.", "In the company of {party}." },
  alone = { "Travels alone.", "Keeps to {themselves} on the road.", "Goes about alone." },
  alone_reserved = { "Travels alone, and keeps conversations short.", "Travels alone, and says little." },
  pet_only = { "Travels with no one but {pet}{mood}.", "Has only {pet} for company{mood}." },
  -- Ambition and Marks
  nextrank = { "Working toward the rank of {rank}.", "Aims to rise to {rank}.", "Has {their} sights on the rank of {rank}." },
  unfinished = { "Wants to get to the bottom of {t}.", "Means to see {t} through.", "Means to find out the truth of {t}." },
  inreach = { "Has taken on a job worth finishing: {q}.", "Has {their} mind on a job not yet done: {q}.",
    "Is partway through a job: {q}." },
  remarkable = { "{their} {item} is the first thing people notice.", "{their} {item} draws a second look.",
    "{their} {item} stands out at once." },
  plain = { "Gives little away at first glance.", "Hard to read at first glance.", "Nothing about {them} stands out at first." },
  -- About
  stories = { "Has stories about {list}", "Can tell a story or two about {list}", "Has tales to tell about {list}" },
  friends = { "{name} counts {list} among {their} friends", "{name} is on good terms with {list}", "{name} has made friends of {list}" },
  rival = { "There is no love lost between {them} and {who}", "Is at odds with {who}", "Doesn't get on with {who}" },
  delved = { "Has gone down into {list} and come back up", "Has been down into {list}, and come out again",
    "Has seen the inside of {list}" },
  bosses = { "Has helped bring down {n} named foes, the latest {who}", "Has been in at the end of {n} named foes, most recently {who}" },
  rares = { "Has tracked down {n} rare beasts", "Has hunted down {n} rare beasts" },
  jobs = { "Has seen {n} jobs through for the people who asked", "Has done {n} jobs for the people who asked",
    "Has taken on and finished {n} jobs" },
  crafts = { "Is {list}", "Works as {list}" },
  finds = { "Found {list}", "Has come by {list}" },
  setout = { "{name} has only just set out, and hasn't been far from home yet",
    "{name} is new to the road, and hasn't been far from home yet" },
  home = { "Calls {inn} home", "Has made {inn} {their} home" },
  lastplace = { "The last new place {they} reached was {place}", "Most recently reached {place}" },
  -- Earned names: where the name came from, the saying that came with it, the others that
  -- stuck, and a name earned only lately (Lately).
  earned = { "{deed}. That's how {name} came to be called {nick}", "{deed}, and some have called {name} {nick} since",
    "{deed}. The name {nick} has stuck to {name} since", "{deed}. It's why {name} answers to {nick}" },
  saying = { "It's where {they} picked up the saying {motto}", "{they} came away from it with a saying: {motto}",
    "{they} took a saying from it: {motto}" },
  othernames = { "Has been called {list} as well", "Also answers to {list}", "Other names have stuck too: {list}" },
  favspell = { "Reaches for {spell} more than any other {noun}", "{spell} is the {noun} {they} use{s} most",
    "Uses {spell} more often than any other {noun}" },
  newname = { "Has lately come to be called {nick}.", "Some have started calling {them} {nick}.",
    "Answers to {nick} now, a name earned only lately." },
}
