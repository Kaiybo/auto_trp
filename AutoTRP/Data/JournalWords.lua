-- The journal's wider vocabulary (0.22.0, "Second Wind"): more ways to say each beat, and
-- the new beats Journal.lua draws from Life, Company, Goals and Mood (fish, crafts, duels,
-- battlegrounds, mounts, books, emotes, the pet, the guild, ambitions, standings, a familiar
-- face, a kindness, a lost roll, a long day), milestone openings, a reflective close in the
-- character's own voice (by temperament and by race), and the weekly look back.
-- First person throughout, and only what the game recorded: lines describe how something
-- felt or how it went, never an event, a prop or a person that wasn't there.
-- Placeholders, besides those in Words.lua: {n} {times} {best} {top} {item} {craft} {title}
-- {doing} {mount} {pet} {guild} {rank} {standing} {faction} {span} {won} {lost} {chain}
-- {zones} {who} {good} {bad}.
local _, ns = ...
local W = ns.Words
local JW = W.JOURNAL

local function more(list, lines) for _, l in ipairs(lines) do list[#list + 1] = l end end
local function moreAll(t, add) for k, lines in pairs(add) do t[k] = t[k] or {}; more(t[k], lines) end end

---------------------------------------------------------------------------
-- More ways to say what was already there.
---------------------------------------------------------------------------
moreAll(JW.tod, {
  dawn = { "with the dew still down", "in the grey before sunrise" },
  morning = { "early in the day", "with the morning still young", "once the morning was under way" },
  noon = { "with the sun at its height", "toward the middle of the day", "when the day was half gone" },
  afternoon = { "in the long part of the afternoon", "late in the afternoon", "once noon had come and gone" },
  evening = { "at dusk", "with the light going" },
  night = { "in the small hours", "with the night well along" },
})
moreAll(JW, {
  open_move = { "Was out of {place} and on my way {tod}", "Took the road from {place} {tod}",
    "Gathered myself and left {place} {tod}" },
  open_stay = { "Kept close to {place} all day", "Stayed within reach of {place}", "Made {zone} my whole day",
    "Hardly went beyond {place}" },
  arrive_new = { "Set foot in {zone} for the first time", "Found my way into {zone}, a land I didn't know" },
  arrive_on = { "Pressed on to {zone}", "Kept going as far as {zone}" },
  arrive_back = { "Found myself in {zone} again", "Returned to {zone}" },
  flew = { "Rode the flight path to {zone}", "Went by air to {zone}", "Was carried on to {zone}" },
  flew_new = { "Went by air to {zone}, my first time there", "Was carried on to {zone}, new to me",
    "Flew on to {zone}, which I'd only heard of" },
  instance = { "Went in under {zone}{company}", "Spent some time in {zone}{company}", "Made my way into {zone}{company}" },
  instance_new = { "Saw {zone} for the first time{company}", "Went into {zone}{company}, which I'd never seen",
    "Found my way into {zone} for the first time{company}" },
  raid = { "Went into {zone} as part of a raid", "Was one of a raid into {zone}", "Followed a raid into {zone}",
    "Made one of a raid into {zone}" },
  pass = { "Went across {list}", "Travelled through {list}", "Made my way through {list}" },
  pass_end = { "Went on through {list} after that", "Later I crossed {list}", "Ended up going by way of {list}" },
  quest_one = { "Saw to \"{q}\"{there}", "Put \"{q}\" behind me{there}" },
  quest_few = { "Got {list} done{there}", "Saw to {list}{there}", "Put {list} behind me{there}" },
  quest_many = { "Got through {n} jobs{there}, {list} among them", "Saw {n} jobs to the end{there}, {list} among them",
    "Worked through {n} jobs{there}, including {list}" },
  inn_mid = { "Took a break at {inn}", "Stopped a while at {inn}", "Caught my breath at {inn}" },
  boss_group = { "It took all of us, but {list} went down", "Between us, {list} fell", "We saw the end of {list}" },
  boss_solo = { "Saw the end of {list} myself", "Took down {list} alone", "Beat {list}, and on my own", "{list} fell to me" },
  death_one = { "Lost a fight to {foe} {where}", "{foe} was the death of me {where}" },
  death_player = { "{foe} got the better of me {where}", "Was put down by {foe} {where}", "{foe} ended me {where}" },
  death_unknown = { "Came to grief {where}", "Lost my life {where}", "Was brought down {where}" },
  death_many = { "Was brought down {times} {where}", "Fell {times} {where}", "Came to grief {times} {where}" },
  death_last = { ", the last of them at the hands of {foe}", ", the last to {foe}", ", {foe} the last" },
  close = { "Very nearly died to {foe} {where}", "Was a breath from losing to {foe} {where}" },
  group_friends = { "Shared the road with {who} for a while", "Kept company with {who} for some of it",
    "Had {who} beside me for a stretch" },
  group_one = { "Fell in with others for a stretch", "Travelled in company for part of it", "Had others with me for a while" },
  group_many = { "Joined up with one group and another {times}", "Fell in with others {times} over the day",
    "Found company {times} before the day was out" },
  loot = { "Came by {list}", "Ended up with {list}", "Turned up {list}" },
  loot_epic = { "Came by {list}, and I'm still pleased about it", "Found {list}; I've rarely had better",
    "Ended up with {list}, the find of the season" },
  level = { "Felt stronger by the end of it", "Came away stronger than I started" },
  level_many = { "Grew stronger {times}, one after another", "Came into my strength {times} today",
    "Stepped up {times} in a single day" },
  rank = { "I've earned the right to call myself {rank}", "{rank} is a fair name for me now", "I'll answer to {rank} now" },
  skill = { "Worked at my {list}", "Got some practice in at {list}" },
  end_at = { "Stopped at {end}, {feel}", "Made {end} my last stop, {feel}", "Finished the day at {end}, {feel}" },
  end_inn = { "Took a room at {end}, {feel}", "Settled at {end} for the night, {feel}", "Ended up at {end}, {feel}" },
  end_flavor = { "Stopped {flavor}, {feel}", "Brought the day to a close {flavor}, {feel}", "Left off {flavor} {tod}, {feel}" },
  end_early = { "Left it there at {end} {tod}, {feel}", "Set things down at {end} {tod}, {feel}", "Paused at {end} {tod}, {feel}" },
})
moreAll(JW.purse, {
  gain_good = { "{mood}, with {money} to show for it", "{mood}, and {money} up on the day", "{mood} and {money} heavier" },
  gain_bad = { "{mood}, for all that I'm {money} up", "{mood}, {money} up for my trouble", "{mood}, though the day paid {money}" },
  loss_good = { "{mood}, {money} spent and not missed", "{mood}, even {money} down", "{mood}, {money} lighter and no matter" },
  loss_bad = { "{mood}, and {money} gone as well", "{mood}, with {money} less to my name", "{mood}, {money} down on top of it" },
})
moreAll(JW.after_death, {
  default = { "I'll know better next time", "That's a lesson paid for", "A hard way to learn it" },
  brave = { "I'll go back the same way, and win", "I've had worse, and kept going", "Back on my feet; that's what counts" },
  cautious = { "I'll go slower in those parts", "I saw the risk and took it anyway", "Next time I'll wait for a better moment" },
  kind = { "Nobody else paid for my mistake", "Someone else might have had worse" },
  cruel = { "They'll regret it", "I've a long memory for this sort of thing" },
  witty = { "Not my preferred way to see the ground up close", "I'll put it down as research" },
  pious = { "The Light gave me another try, and I mean to use it" },
  reserved = { "That's all I'll say about it", "No sense going over it" },
  greedy = { "And it'll be my coin that pays for it", "I'm counting what that cost me" },
  Scourge = { "Dying is old news to me, but it's still tiresome", "Not my first death. I doubt it'll be my last" },
  Dwarf = { "Knocked flat, and up again. That's a dwarf for you", "I've been knocked down harder than that" },
  Orc = { "I'll carry that one until it's answered", "I fell. I rose. That is enough" },
  Tauren = { "The Earth Mother let me go, this time", "Slow and steady next time" },
  Troll = { "Ya can't keep a troll down long", "Next time I be quicker, mon" },
  Gnome = { "The plan had a flaw somewhere. I'll find it", "An unscheduled setback, nothing more" },
  NightElf = { "A long life is no excuse to waste it", "I should have listened to the woods" },
  Human = { "I'll get back up. We always do", "Pride before a fall, and I had both" },
  PRIEST = { "I've patched up others from worse" },
  PALADIN = { "Even the Light's own get knocked down" },
  WARLOCK = { "Death owes me nothing, and I owe it less" },
})
moreAll(JW.after_close, {
  default = { "That was nearer than I like", "I'll take the narrow escape", "I came through, and that's what matters" },
  brave = { "Close, and still standing", "Near enough to feel it, and I'd still go back" },
  cautious = { "I won't cut it that fine again if I can help it" },
  witty = { "I'd rather not do that again soon" },
  pious = { "Light keep me, that was close" },
  Scourge = { "Very nearly dead twice over", "Close, though I've less to lose than most" },
  Dwarf = { "Still standing, and that's a dwarf's whole argument" },
  Orc = { "Close. Close is not dead" },
  Troll = { "Da spirits had a good laugh at that one" },
  Gnome = { "The margins were thinner than I calculated" },
  NightElf = { "Patience saved me, barely" },
})
moreAll(JW.feel, {
  calm = { "no worse for any of it", "even enough in myself" },
  good = { "pleased with how it went", "in decent spirits" },
  bad = { "not at my best", "glad to be done" },
  weary = { "weary to the bone" },
})

---------------------------------------------------------------------------
-- Waking: where the day began, and when the road started.
---------------------------------------------------------------------------
JW.open_inn_move = { "Woke at {place} and was away {tod}", "Rose at {place} and set off {tod}",
  "Left the warmth of {place} {tod}", "Was out of {place} and on the road {tod}",
  "Was up at {place} and gone {tod}", "Started from {place}, out the door {tod}" }
JW.open_inn_stay = { "Woke at {place} and kept to {zone} all day", "Rose at {place} and never went far from it",
  "Started at {place}, and {zone} was enough for the day", "Woke at {place} and stayed in those parts",
  "Spent the day around {place}, where I'd woken", "Never strayed far from {place} after waking there" }

---------------------------------------------------------------------------
-- Milestone openings: the first line, on a day worth marking.
---------------------------------------------------------------------------
JW.milestone = {
  -- Every tenth step of strength. {rank}: the name that comes with it.
  level = {
    [10] = { "The first stretch of the road is behind me", "I'm no beginner any more", "The early lessons are done with" },
    [20] = { "I've come a fair way from where I started", "There's a fair bit of road behind me now" },
    [30] = { "I've come halfway up the mountain", "There's real strength in me now, and I know it" },
    [40] = { "Two-thirds of the way up, and still climbing", "I'm stronger than I ever thought I'd be" },
    [50] = { "The end of the climb is in sight", "Only the hardest of the road is left" },
    [60] = { "I've gone as far as strength alone can take me", "There's no higher to climb; from here it's what I make of it",
      "The long climb is over", "Every step of the road, and I've reached the end of it" },
    any = { "A day to remember: I'm {rank} now", "I'll want to remember today. I can call myself {rank}",
      "Today I became {rank}", "Mark the day: {rank}, and earned", "A day for the journal, if any is: I'm {rank}",
      "I'm {rank} from today" },
  },
  dungeon = { "{zone} was my first dungeon", "My first time in a dungeon: {zone}",
    "I went into a dungeon today for the first time, {zone}", "Today was {zone}, my first dungeon",
    "{zone}: my first dungeon, and I'll not forget it", "A first today: {zone}, the first dungeon I've seen inside" },
  death = { "Today I died for the first time", "The first death, and not a pleasant thing",
    "I died today, the first time it's happened", "For the first time, I didn't walk away from a fight",
    "My first death came today", "Today I learned what dying is" },
  mount = { "I rode today, my own {mount}, for the first time", "A mount of my own at last: my {mount}",
    "No more walking everywhere: my {mount} carries me now", "Today I rode my first mount, my {mount}",
    "I've a mount of my own now, the {mount}, and the roads look shorter", "My first time in the saddle of my own {mount}" },
}

---------------------------------------------------------------------------
-- New beats in the travel paragraph.
---------------------------------------------------------------------------
JW.bg = { "Went to fight at {zone}{company}", "Joined the fighting at {zone}{company}", "Took my turn at {zone}{company}",
  "Answered the call to {zone}{company}", "Was at {zone} for a battle{company}", "Fought at {zone}{company}" }
JW.bg_new = { "Fought at {zone} for the first time{company}", "Saw battle at {zone} for the first time{company}",
  "Went to {zone} for the first time{company}", "Joined the fighting at {zone}{company}, new to me",
  "Took my first turn at {zone}{company}", "Saw {zone} for the first time{company}, as a battlefield" }
JW.bg_won = { "We won", "We carried the day", "Our side took it", "We came out on top", "The win was ours", "We had the better of it" }
JW.bg_lost = { "We lost", "The other side took it", "It went against us", "We came away beaten", "We didn't carry it",
  "It was theirs in the end" }
JW.bg_mixed = { "We won {won} and lost {lost}", "Won {won}, lost {lost}", "{won} won and {lost} lost, all told",
  "The tally: {won} won, {lost} lost", "Came out {won} won to {lost} lost", "Won {won} of them and lost {lost}" }
JW.kb = { "I struck the last blow on {n} of the enemy", "{n} of the enemy fell to my hand",
  "I finished {n} of the other side myself", "My hand ended {n} of them", "Put {n} of the enemy down myself",
  "{n} fell to me in the fighting" }
JW.chain_step = { "That moved {chain} a step along", "One more step in {chain}", "That brought {chain} closer to its end",
  "Another piece of {chain} done", "I'm further along in {chain} now", "{chain} moved on a step" }
JW.chain_end = { "That saw {chain} through at last", "And that was the end of {chain}", "With that, {chain} is done",
  "That closed {chain} for good", "{chain} is behind me now", "That finished {chain}" }

---------------------------------------------------------------------------
-- The work of the day: fishing, crafting, books, emotes, a mount, duels.
---------------------------------------------------------------------------
JW.fish_best = { "Fished a while and landed {n}, the pick of them {best}", "Put a line in the water: {n} caught, {best} the best of it",
  "Spent a while fishing and came away with {n}, {best} among them", "Caught {n} fish, and {best} was the one worth telling",
  "Had a line out for a while; {n} came in, {best} the prize", "Landed {n} with rod and line, {best} the best" }
JW.fish_plain = { "Fished a while and caught {n}, mostly {top}", "Put a line in the water and landed {n}",
  "Spent some time fishing: {n} caught", "Caught {n} fish, {top} the most of them", "Had a line out long enough to land {n}",
  "Landed {n} fish, mostly {top}" }
JW.fish_one = { "Caught {best} on the line", "Landed {best}", "Pulled {best} out of the water", "Fished up {best}",
  "Had {best} on the line, and landed it", "Brought in {best}" }
JW.craft_many = { "Put in some time at my {craft}: {n} made, mostly {top}", "Worked at my {craft} and turned out {n}, {top} the most of them",
  "Made {n} things at my {craft}, chiefly {top}", "Got {n} pieces of {craft} done, {top} the most of them",
  "Kept at my {craft}: {n} made", "Turned out {n} things at my {craft}" }
JW.craft_plain = { "Made {n} things, mostly {top}", "Turned out {n} pieces of work, {top} the most of them",
  "Put my hands to some work: {n} made", "Made {n}, chiefly {top}", "Got {n} things made", "Kept my hands busy: {n} made" }
JW.craft_one = { "Made {item}", "Put together {item}", "Finished {item} with my own hands", "Turned out {item}",
  "Worked {item} into being", "Made myself {item}" }
JW.book_one = { "Read \"{title}\"", "Took the time to read \"{title}\"", "Read through \"{title}\"",
  "Found \"{title}\" and read it", "Gave \"{title}\" a reading", "Spent some time with \"{title}\"" }
JW.book_many = { "Read {list}", "Took the time to read {list}", "Read through {list}", "Spent some time with {list}",
  "Gave {list} a reading", "Got some reading in: {list}" }
JW.emote = { "There was a good deal of {doing} today", "It was a day for {doing}", "Did a good deal of {doing}",
  "Plenty of {doing} along the way", "No shortage of {doing}", "A fair share of the day went to {doing}" }
JW.mount_new = { "Rode my new {mount} for the first time", "Took my new {mount} out for the first time",
  "Got my first ride on my new {mount}", "Tried out my new {mount}", "Had my new {mount} out on the road",
  "My new {mount} carried me for the first time" }
JW.duel_won = { "Won {times} at duelling", "Came out on top in duels {times}", "Came out ahead in duels {times}",
  "Won {n} duels", "Took {n} friendly duels", "Bested others in {n} duels" }
JW.duel_won_one = { "Won a duel", "Came out ahead in a friendly duel", "Beat someone in a duel", "Took a duel",
  "Won a friendly bout", "Bested someone in a duel" }
JW.duel_lost = { "Lost {times} at duelling", "Was beaten {times} in friendly duels", "Came off worse in duels {times}",
  "Lost {n} duels", "Was bested in {n} duels", "Had the worst of {n} duels" }
JW.duel_lost_one = { "Lost a duel", "Was beaten in a friendly duel", "Came off worse in a duel", "Was bested in a duel",
  "Lost a friendly bout", "Had the worst of a duel" }
JW.duel_mixed = { "Fought {all} duels: {won} won, {lost} lost", "Duelled {all} times: {won} won, {lost} lost",
  "Of {all} duels, I won {won} and lost {lost}", "Came out of {all} duels with {won} won and {lost} lost",
  "Fought {all} friendly duels and won {won}", "Tried my hand in {all} duels and won {won} of them" }
-- What a day full of one emote is called. Only the game's own emote verbs.
JW.EMOTE_DOING = {
  wave = "waving", bow = "bowing", dance = "dancing", laugh = "laughing", cheer = "cheering", thank = "thanking people",
  salute = "saluting", smile = "smiling", greet = "greeting", hug = "hugging", cry = "weeping", sigh = "sighing",
  flex = "flexing", roar = "roaring", kiss = "kissing", applaud = "applause", clap = "clapping", nod = "nodding",
  yawn = "yawning", pray = "praying", chuckle = "chuckling", giggle = "giggling", grin = "grinning", shrug = "shrugging",
  cower = "cowering", taunt = "taunting", curtsey = "curtseying", wink = "winking", sing = "singing", whistle = "whistling",
  violin = "playing the tiny violin", chicken = "clucking", train = "playing at being a train", cackle = "cackling",
  bonk = "bonking", hail = "hailing people", welcome = "welcoming people", tickle = "tickling", poke = "poking",
}

---------------------------------------------------------------------------
-- Company and fortune.
---------------------------------------------------------------------------
JW.familiar = { "Some of the faces were ones I'd seen before: {n} of them", "{n} of those I travelled with I'd met before",
  "There were {n} familiar faces among the others", "Fell in again with {n} I'd travelled with before",
  "{n} of the company were people I'd met on the road before", "I knew {n} of my companions from earlier outings" }
JW.familiar_one = { "Among the company was a face I'd travelled with before", "There was a familiar face in the company",
  "One face in the company I knew from an earlier outing", "Saw a face I knew among the people I travelled with",
  "Travelled again with someone I'd met on the road before", "Ran into someone I'd travelled with before" }
JW.healed = { "Someone else saw to my wounds when I needed it", "Was patched up by another traveller",
  "Was healed by someone along the way", "Someone looked after me when I was hurt",
  "Was tended to by someone else along the way", "Another traveller saw to my hurts" }
JW.healed_many = { "{n} people saw to my wounds over the day", "Was patched up by {n} different people",
  "{n} people healed me at one point or another", "Others looked after me {times}",
  "{n} people saw to my hurts along the way", "Was tended to by {n} people before the day was out" }
JW.blessed = { "Someone gave me a blessing on the road", "Got a blessing from another traveller",
  "Somebody spared a blessing for me", "Was blessed by someone in passing", "Someone thought to bless me",
  "Another traveller lent me a blessing" }
JW.roll_lost = { "Lost the roll for {item}", "{item} went to someone else on the roll", "Didn't win the roll for {item}",
  "The dice went against me for {item}", "Rolled for {item} and lost", "Missed out on {item} by the roll" }
JW.roll_won = { "Won the roll for {item}", "The dice gave me {item}", "Rolled for {item} and won",
  "Took {item} on the roll", "{item} came to me on the roll", "Had the luck of the roll for {item}" }
JW.standing = { "I'm {standing} with {faction} now", "Rose to {standing} with {faction}", "Stood {standing} with {faction} by the end",
  "Earned my way to {standing} with {faction}", "Became {standing} with {faction}", "Reached {standing} with {faction}" }
JW.guild_join = { "Joined {guild}", "Took my place in {guild}", "Was taken into {guild}", "Signed on with {guild}",
  "Became one of {guild}", "Was welcomed into {guild}" }
JW.guild_left = { "Left {guild}", "Parted ways with {guild}", "Am no longer one of {guild}", "Walked away from {guild}",
  "Gave up my place in {guild}", "Said goodbye to {guild}" }
JW.guild_rank = { "Was made {rank} in {guild}", "Rose to {rank} in {guild}", "Am {rank} in {guild} now",
  "Got the rank of {rank} in {guild}", "Was raised to {rank} in {guild}", "Earned {rank} in {guild}" }
JW.pet_hungry = { "{pet} went hungry for a while", "{pet} was short of food and let me know it", "{pet} was hungry and sulking",
  "Let {pet} go hungry longer than I should have", "{pet} was off its food, or I was off feeding it", "{pet} grew hungry and cross" }
JW.pet_content = { "{pet} was content again by the end of it", "{pet} came round to a good mood", "{pet} was happy again",
  "{pet} settled back into good spirits", "{pet} cheered up", "{pet} was pleased with me again" }
JW.pet_died = { "{pet} fell in a fight", "Lost {pet} in a fight for a while", "{pet} went down in a fight",
  "{pet} took the worst of a fight", "{pet} was brought down", "{pet} fell, and I felt it" }
JW.pet_died_many = { "{pet} fell {times}", "{pet} went down {times}", "{pet} was brought down {times}",
  "Lost {pet} {times} in fights", "{pet} took the worst of it {times}", "{pet} fell in fights {times}" }
JW.abandon_one = { "Gave up on \"{q}\"", "Let \"{q}\" go", "Dropped \"{q}\"", "Put \"{q}\" aside for good",
  "Walked away from \"{q}\"", "Set \"{q}\" down for good" }
JW.abandon_many = { "Gave up on {n} jobs, \"{q}\" among them", "Dropped {n} jobs, \"{q}\" one of them",
  "Let {n} jobs go, \"{q}\" with them", "Walked away from {n} jobs, \"{q}\" included", "Put {n} jobs aside, \"{q}\" among them",
  "Gave up {n} jobs, starting with \"{q}\"" }

---------------------------------------------------------------------------
-- Looking ahead, and the length of the day.
---------------------------------------------------------------------------
JW.ahead_level = { "I'm not far from growing stronger again", "Another step up isn't far off", "I can feel the next step up coming",
  "I'm close to the next rung", "Not much more and I'll be stronger still", "The next step up is near" }
JW.ahead_rep = { "I'm within reach of {standing} with {faction}", "I'm nearly {standing} with {faction}",
  "Not far now from {standing} with {faction}", "A few more good turns and I'll be {standing} with {faction}",
  "{standing} with {faction} isn't far off now", "I'm close to {standing} with {faction}" }
JW.long_day = { "I was on the road for {span} without much rest", "It was a long one: {span} of it", "{span} on my feet, all told",
  "It went on for {span}", "I kept at it for {span}", "{span} from start to finish" }

---------------------------------------------------------------------------
-- The close: how the day sat with me, when one feeling held all day, then a last thought
-- in my own voice (by temperament, by race) and by how the day went (good, bad or calm).
---------------------------------------------------------------------------
JW.dominant = {
  good = { "It was a good day nearly all the way through", "The good mood held from start to finish",
    "I was in good spirits the whole day", "Nothing much dented my mood", "It stayed a good day to the end",
    "The good feeling lasted all day" },
  bad = { "It sat on me the whole day", "I couldn't shake it, start to finish", "The mood never lifted",
    "It hung over all of it", "The whole day felt that way", "I carried it with me all day" },
  weary = { "I was tired from the first hour to the last", "Tired all day, and it showed", "Every hour of it felt long" },
  merry = { "I was in good humour all day", "The cheer lasted from start to finish" },
  proud = { "I've been pleased with myself all day" },
  frustrated = { "Nothing went right for long", "It was one irritation after another" },
  lonely = { "It was a lonely sort of day all the way through", "I missed company the whole day" },
  sociable = { "There was company all day, and I was glad of it" },
  wonder = { "I spent the whole day looking about me" },
  homesick = { "Home was on my mind all day" },
  bored = { "The whole day dragged" },
  grateful = { "I've been thankful all day" },
  shaken = { "I didn't stop shaking for most of it" },
  satisfied = { "It was a solid day's work, and it felt like it" },
  exhausted = { "I was spent long before the end" },
  cheerful = { "I was cheerful start to finish" },
  bitter = { "It soured the whole day" },
  angry = { "I stayed angry most of the day" },
}
JW.reflect = {
  good = {
    default = { "A day I'd happily have again", "Days like this make up for the others", "I'll sleep well on this one",
      "If tomorrow's half as good, I'll take it", "Not a bad day at all", "Good days don't need explaining" },
    Human = { "Honest work, and something to show for it", "A good day, plain and simple; there's no better kind",
      "Back home they'd call this a fair day's work" },
    Dwarf = { "A grand day, and I'll drink to it", "That's a day worth a song, if a short one",
      "Good work, done properly, and that's the only kind worth doing" },
    Gnome = { "Results! Excellent results", "The figures came out well today", "A day that went more or less to plan, which is rare and delightful" },
    NightElf = { "One good day among very many, and I'll still remember it", "Elune smiled on the road today",
      "A day well spent, by any count of years" },
    Orc = { "A strong day. Good", "Today I was what I should be", "Strength and honour, and a full day of both" },
    Troll = { "Dat was a good one, mon", "Da spirits be smiling today", "Good day. Tomorrow maybe even better" },
    Tauren = { "The Earth Mother was kind today", "A good day, gently earned", "Today walked with me rather than against me" },
    Scourge = { "Almost pleasant. Don't tell anyone", "A good day, by the standards of the dead, which are low",
      "Nothing went wrong, which is suspicious, but I'll allow it" },
    Goblin = { "Profitable, in more ways than one", "A day in the black", "Good returns on the day" },
  },
  bad = {
    default = { "Tomorrow can only be better", "Not every day goes well; this one didn't", "I'll leave this one behind me",
      "Better days are coming, or they'd better be", "I've had easier", "Some days you just get through" },
    Human = { "We've seen worse and come through it", "Tomorrow, I start again", "Chin up. It's what we do" },
    Dwarf = { "Bah. Tomorrow, then", "A rotten day, and I'll say so to anyone", "There's no grudge like a grudge against a bad day" },
    Gnome = { "Back to the drawing board", "A setback, and I've noted every part of it", "The experiment failed. I'll redesign it" },
    NightElf = { "This too will pass, as everything does", "I've lived long enough to know a bad day ends",
      "The moon will rise again tonight, whatever today was" },
    Orc = { "A hard day. I am harder", "Tomorrow I take back what today took", "Pain is a teacher; I listened" },
    Troll = { "Bad day, mon. Bad day", "Da spirits not be with me today", "Tomorrow I try again, and I laugh at today" },
    Tauren = { "Even the plains have storms", "The ground was hard today; I'll walk it again", "Patience. The wind turns" },
    Scourge = { "And they say the dead don't suffer", "Another day I won't be missing", "Unpleasant, but I've been dead; I can endure a bad day" },
    Goblin = { "A loss on the day; I'll make it up", "Write it off", "Not a profitable day by any measure" },
  },
  calm = {
    default = { "An ordinary day, and none the worse for that", "Nothing much to say about it, and that's fine",
      "A steady day, which has its own value", "Quiet days count too", "Another day of the road", "So it goes" },
    Human = { "A quiet day's work. There are worse things", "Steady as a plough horse" },
    Dwarf = { "Nothing to sing about, nothing to grumble about", "A day like a good wall: solid and dull" },
    Gnome = { "No surprises, which is its own sort of surprise", "A day with no unexpected variables" },
    NightElf = { "One more day in a long count of them", "The seasons turn slowly; so did today" },
    Orc = { "A plain day. Tomorrow may bring a fight" },
    Troll = { "Easy day. Ain't nothing wrong with dat" },
    Tauren = { "Calm, like the plains on a still afternoon" },
    Scourge = { "Unremarkable, which suits me", "Another day not living. It passed" },
    Goblin = { "Break-even day" },
  },
}
JW.reflect_trait = {
  brave = { "Tomorrow I'll go further", "I'm not done yet, not by a long way" },
  cautious = { "Better safe than sorry, still", "I'll plan tomorrow more carefully" },
  kind = { "I hope the people I met had a good day too", "I hope I was of some use to someone" },
  cruel = { "Those who crossed me today will remember it" },
  witty = { "If nothing else, I kept myself amused", "I'll make a better story of it later" },
  stern = { "Enough. There's work tomorrow" },
  pious = { "Light keep me through the night", "I'll give thanks before I sleep" },
  skeptical = { "We'll see what tomorrow really brings" },
  greedy = { "I'll count my coin before I sleep" },
  generous = { "Whatever I have, I'll share tomorrow" },
  curious = { "I wonder what tomorrow will turn up" },
  charming = { "I'll have plenty to tell people" },
  reserved = { "Enough written. Some things stay with me" },
}
moreAll(JW.signoff, {
  PRIEST = { "Rest now; the hurt will still need tending tomorrow", "Light guide whoever needs it tonight" },
  PALADIN = { "My oath held another day", "The Light keeps the watch tonight" },
  WARRIOR = { "Rest, and back at it tomorrow", "Sharpen, rest, and back at it" },
  ROGUE = { "Nobody followed me, I made sure of it", "Back to the shadows for the night" },
  MAGE = { "The books can wait until morning, barely", "Tomorrow, more to learn" },
  WARLOCK = { "The shadows are quiet tonight. Mostly", "I keep my bargains, and my secrets" },
  HUNTER = { "The trail goes cold overnight; I'll find it again", "Rest, and the wilds again at first light" },
  DRUID = { "The wild sleeps, and so will I", "Tomorrow the green again" },
  SHAMAN = { "The elements were patient with me today", "I'll listen again tomorrow" },
  DEATHKNIGHT = { "The night doesn't trouble me as it once did", "No rest, just the dark until morning" },
})

---------------------------------------------------------------------------
-- The week behind: written on the first day of a new week, from the days kept.
---------------------------------------------------------------------------
JW.week = {
  open = { "Looking back on the week: most of it in {zones}", "The week just gone took me mostly through {zones}",
    "This past week I was mostly in {zones}", "A week, looking back, spent mostly in {zones}",
    "Most of the week went by in {zones}", "The week behind me was mostly {zones}" },
  open_one = { "Looking back on the week: I hardly left {zones}", "The week just gone was {zones}, start to finish",
    "This past week I kept to {zones}", "I spent the whole week in {zones}", "The week behind me was all {zones}",
    "A week, looking back, in {zones} and not much else" },
  new = { "New ground: {list}", "I saw {list} for the first time", "{list} were new to me", "First sight of {list}",
    "The week took me somewhere new: {list}", "I set foot in {list} for the first time" },
  new_one = { "New ground: {list}", "I saw {list} for the first time", "{list} was new to me", "First sight of {list}",
    "The week took me somewhere new: {list}", "I set foot in {list} for the first time" },
  deeds = { "All told: {list}", "Taken together: {list}", "It came to {list}", "What it added up to: {list}",
    "Counted up: {list}", "The tally of it: {list}" },
  -- How the days went, from their moods. {good} {bad}: how many days of each.
  good = { "Most days ended well", "It was a good week, on the whole", "The good days outnumbered the bad",
    "Looking back, I'd call it a good week", "More good days than not", "I'll remember it as a good week" },
  bad = { "It was a hard week", "More hard days than good ones", "Not a week I'd choose again",
    "The hard days outweighed the rest", "It was a week to get through", "I'm glad that week's done" },
  mixed = { "Some good days, some hard ones", "Up and down, as weeks go", "{good} good days and {bad} hard ones",
    "A mixed week: the good and the hard about even", "It had its good days and its bad", "Half good, half hard" },
  calm = { "A steady week, without much to shake it", "An even sort of week", "Nothing to shout about, nothing to regret",
    "Quiet, mostly", "A level week, on the whole", "An ordinary week, which is no bad thing" },
  feel = { "Mostly I was {feel}", "I was {feel}, more often than not", "{feel}, for most of it", "Through most of it, {feel}",
    "On most days, {feel}", "More often than not I ended the day {feel}" },
}
-- Noun phrases for the tally: the week's deeds, counted. {n} {list} {times} {item} {mount} {standing} {faction}
JW.week_bits = {
  quests = { "{n} jobs seen through", "{n} jobs done", "{n} jobs put behind me" },
  quest_one = { "one job seen through", "a single job done" },
  bosses = { "{list} brought down", "an end to {list}", "{list} beaten" },
  levels = { "{times} stronger", "{n} steps up in strength", "strength gained {times}" },
  level_one = { "a step up in strength", "stronger by a step" },
  deaths = { "{n} deaths", "{n} times dead" },
  death_one = { "one death", "a single death" },
  loot = { "{item} found", "{item} come by" },
  fish = { "{n} fish landed", "{n} fish caught" },
  made = { "{n} things made", "{n} pieces of work made" },
  books = { "{n} books read", "{n} books read through" },
  book_one = { "one book read", "a book read" },
  mount = { "a new mount in the {mount}", "the {mount} to ride" },
  standing = { "{standing} with {faction}", "{standing} standing with {faction}" },
  bg = { "{n} battles fought", "{n} battles" },
  bg_one = { "a battle fought", "one battle" },
  duels = { "{n} duels", "{n} duels fought" },
  duel_one = { "a duel", "one duel" },
}
JW.week_close = {
  default = { "On to the next", "Now, the week ahead", "That's the week, then", "Onward", "Another one done", "So, the next week" },
  Human = { "A week's work. On to the next" },
  Dwarf = { "That's a week done, and done properly" },
  Gnome = { "Week logged. Next!" },
  NightElf = { "One week. There will be many more" },
  Orc = { "A week of the road. More to come" },
  Troll = { "Dat's da week, mon" },
  Tauren = { "The week walked on; so do I" },
  Scourge = { "A week. Time means less to me than it did" },
  Goblin = { "Week closed. Books balanced, more or less" },
}
JW.week_title = { "The week behind me", "Looking back on the week", "The week, looking back", "A week in short",
  "The week that was", "On the week just gone" }
