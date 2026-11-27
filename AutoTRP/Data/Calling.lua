-- Auto TRP: the words for a character's calling (Sources/Calling.lua), the signature work of
-- each class as the game records it: stances and forms, charges, pockets picked, beasts
-- tamed, portals opened, summonings, resurrections, totems, blessings. Only said when the
-- counts back it. Tags: {n} {times} {beast} {kinds} {demon} {track} {dest} {zone} {others}
-- {form} {hours} {strangers}, and the pronoun tags {they} {them} {their} {they've} {they're}
-- with {s}/{es} after {they}.
local _, ns = ...
local W = ns.Words

W.CALLING = {
  ---------------------------------------------------------------------------
  -- Personality: how they practise their calling. A disposition, as a sentence without its stop.
  ---------------------------------------------------------------------------
  HABIT = {
    -- Warrior
    stance_defensive = {
      "Spends more of {their} time braced in a defensive stance than swinging freely",
      "Fights from a defensive stance by habit, as if someone always needs covering",
      "Keeps to a guarded stance most days, and gives ground slowly",
      "Would rather hold a line than break one, and fights like it",
      "Settles into a defender's stance almost as soon as a fight starts",
    },
    stance_berserker = {
      "Fights wide open in a berserker's stance more often than not",
      "Spends long stretches in a berserker's stance, guard all but forgotten",
      "Prefers the berserker's stance, trading safety for fury",
      "Goes into a fight hot, and usually in a berserker's stance",
    },
    stance_battle = {
      "Keeps to the plain battle stance most days, the first one {they} ever learned",
      "Fights mostly from a battle stance, without much fuss about the others",
      "Has never strayed far from the battle stance {they} trained in",
      "Favours the old battle stance over anything fancier",
    },
    charges = {
      "Closes the distance first and thinks about it on the way",
      "Charges in far more often than {they} wait{s} for a fight to come",
      "Would rather cross the field at a run than let a foe pick the ground",
      "Has charged headlong into more fights than {they} could count",
      "Doesn't wait to be reached: {they} go{es} to the fight",
    },
    laststand = {
      "Digs in when a fight turns bad rather than running",
      "Holds on when a fight goes wrong, shield up and teeth set",
      "Knows how to stand fast when {their} blood is running low",
      "Is hardest to finish off when {they're} nearly finished",
      "Has come through a good many fights on a last stand alone",
    },
    -- Rogue
    pockets = {
      "Has picked more pockets than {they} would care to admit",
      "Has light fingers, and keeps them in practice",
      "Treats other people's pockets as part of the day's work",
      "Can't pass a stranger without wondering what {they} carry",
      "Keeps {their} fingers nimble on other people's belongings",
    },
    locks = {
      "Opens locks the way other people open doors",
      "Can't leave a locked box alone for long",
      "Treats a lock as a puzzle that ought to be solved",
      "Has sprung more locks than most locksmiths",
      "Brightens at the sight of anything locked",
    },
    vanish = {
      "Has slipped out of more than one fight that should have been the end",
      "Disappears when a fight turns, and lives to try again",
      "Is gone before the killing blow lands more often than not",
      "Would rather vanish and come back than die well",
      "Has a way of not being there when the end comes",
    },
    poisons = {
      "Keeps {their} blades poisoned as a matter of course",
      "Never goes out to a fight without poison on {their} blades",
      "Tends {their} poisons as carefully as other people tend a garden",
      "Coats a blade before a fight without having to think about it",
      "Treats poison as a tool of the trade, nothing more",
    },
    -- Hunter
    tamer = {
      "Has tamed {n} different beasts, and has a way with wild things",
      "Has won over {n} wild beasts so far, {kinds} among them",
      "Has a way with wild animals: {n} of them tamed so far",
      "Has brought {n} wild beasts to heel, {kinds} among them",
      "Can calm a wild beast where others would only fight it, and has done it {n} times",
    },
    loyal = {
      "Has tamed only the one beast, and kept it",
      "Keeps to the one companion {they} tamed, and no other",
      "Has never tamed another beast since the first",
      "Has had the same beast at {their} side since the day it was tamed",
    },
    feign = {
      "Has played dead to get out of more than one losing fight",
      "Isn't too proud to drop and play dead when a fight goes wrong",
      "Has lived through bad fights by lying very still",
      "Will fall down dead in a fight and get up again once it's safe",
      "Has fooled more than a few foes into thinking {they} had died",
    },
    traps = {
      "Lays a trap before most fights, and lets the foe come to it",
      "Likes to have a trap waiting where the foe will step",
      "Prepares the ground before a fight whenever {they} can",
      "Would rather a foe walk into a trap than meet it head on",
    },
    tracking = {
      "Is always tracking something, {track} most of all",
      "Watches the ground for signs of {track} wherever {they} go{es}",
      "Keeps an eye out for {track} by habit",
      "Seldom travels without tracking {track}",
    },
    -- Mage
    portals = {
      "Opens portals for others readily, {n} of them so far",
      "Has opened the way home for others more times than {they} could count",
      "Treats a portal as a kindness to pass round, and has opened {n}",
      "Has sent a good many travellers home through {their} portals",
      "Thinks nothing of opening a portal for a group, and has done it {times}",
    },
    feeds = {
      "Hands out conjured bread and water freely",
      "Keeps other people fed and watered from {their} own conjuring",
      "Gives away conjured food and drink to whoever's thirsty",
      "Has handed out more conjured water than some innkeepers pour",
      "Has handed {n} conjured meals and drinks to others so far",
    },
    conjures = {
      "Lives on conjured bread and water as often as not",
      "Conjures {their} own food and drink as a matter of course",
      "Hardly needs a vendor for food or drink, with conjuring to hand",
      "Would sooner conjure a meal than buy one",
    },
    polymorph = {
      "Turns a foe into a sheep as readily as {they} would fight it",
      "Has turned more foes into sheep than {they} could count",
      "Is fond of Polymorph, and uses it often",
      "Reaches for Polymorph whenever a fight has one foe too many in it",
      "Settles crowded fights by turning someone into livestock first",
    },
    blink = {
      "Blinks out of trouble whenever it gets close",
      "Keeps distance between {them} and a foe, blinking clear when it closes",
      "Never lets a foe stay close for long",
      "Is hard to pin down in a fight, and harder to catch",
    },
    -- Warlock
    summoner = {
      "Brings people across the world by ritual, and has done so {times}",
      "Is often the one who opens the summoning circle: {n} rituals so far",
      "Has called people to {their} side by ritual {times}",
      "Thinks nothing of drawing a summoning circle so others needn't walk",
      "Spends {their} soul shards bringing others over, and has done it {times}",
    },
    soulstone = {
      "Leaves a soulstone on someone else before a hard fight",
      "Has set a soulstone on someone else {times}, just in case",
      "Makes sure someone in the group can come back, and has seen to it {times}",
      "Hands out soulstones before risky fights",
    },
    demon = {
      "Calls on {demon} more than any other demon",
      "Prefers the company of {demon} to any other {they} can call",
      "Has called up {demon} more often than any other servant",
      "Most often fights with {demon} beside {them}",
      "Is seldom seen without {demon} close by",
    },
    healthstones = {
      "Makes healthstones for whoever will take one",
      "Keeps a healthstone made and ready, and often one for someone else",
      "Makes healthstones as a matter of course",
      "Is seldom short of a healthstone",
    },
    -- Priest
    rez_strangers = {
      "Has resurrected more strangers than most priests would bother to",
      "Raises the fallen whether {they} know{s} them or not",
      "Stops to raise strangers where they fell, {strangers} of them so far",
      "Has brought {strangers} strangers back from death and moved on",
      "Will raise anyone left lying on the road",
    },
    rez = {
      "Has brought {n} people back from death",
      "Is the one {their} companions count on when someone falls",
      "Raises the fallen, and has done it {times}",
      "Rarely leaves a fallen companion lying",
    },
    shields = {
      "Shields other people readily, often before the first blow lands",
      "Puts a ward of Light over others as a matter of habit",
      "Is quick to shield whoever stands nearest the danger",
      "Has warded others with Power Word: Shield {times}",
    },
    fortitude = {
      "Hands out Fortitude to anyone who passes",
      "Rarely lets a traveller pass unblessed",
      "Has spoken Fortitude over others {times}",
      "Blesses passers-by with Fortitude without being asked",
    },
    mindcontrol = {
      "Takes hold of other minds more readily than most priests care to",
      "Has bent {n} minds to {their} will",
      "Isn't shy of reaching into another's mind",
      "Uses Mind Control the way others use a sword",
    },
    -- Shaman
    totem_earth = {
      "Sets earth totems down before most fights, steady as the ground",
      "Leans on the earth spirits more than the others",
      "Plants an earth totem first, almost every time",
      "Trusts the earth to hold, and calls on it most",
    },
    totem_fire = {
      "Calls on the spirits of fire first, and most often",
      "Leans on fire totems, and fights hot",
      "Sets a fire totem burning before most fights",
      "Favours the fire spirits over the rest",
    },
    totem_water = {
      "Keeps water totems close, mending as {they} fight{s}",
      "Leans on the water spirits more than any other",
      "Plants a water totem first, as if healing were half of every fight",
      "Favours the healing waters over fire and stone",
    },
    totem_air = {
      "Listens to the air spirits more than the others",
      "Sets air totems down first, and fights with the wind at {their} back",
      "Favours the spirits of air over fire and stone",
      "Calls on the winds before anything else",
    },
    totem_balance = {
      "Calls on all four elements in turn, favouring none",
      "Keeps fire, earth, water and air in balance",
      "Plants totems of every element, and leans on none above the rest",
      "Gives each of the elements its due",
    },
    ghostwolf = {
      "Travels as a ghost wolf whenever the road is long",
      "Spends long stretches of the road on four spectral legs",
      "Takes the shape of the ghost wolf for travel more often than not",
      "Would rather lope than walk, and has spent {hours} as a ghost wolf",
    },
    reincarnation = {
      "Has come back from death by {their} own ankh {times}",
      "Has walked back from death more than once, on the strength of the spirits",
      "Has died and risen again by {their} own power {times}",
      "Doesn't stay dead easily: the spirits have sent {them} back {times}",
    },
    ancestral = {
      "Calls the spirits of the fallen back to their bodies, {n} so far",
      "Has called {n} of the fallen back with Ancestral Spirit",
      "Leaves no companion lying dead for long",
      "Has raised the fallen {times}",
    },
    -- Paladin
    blessings = {
      "Hands out blessings to whoever stands near",
      "Has laid {their} blessing on others {times}",
      "Rarely lets a companion go unblessed",
      "Is generous with the Light's blessings",
      "Blesses others freely, strangers as often as friends",
    },
    redemption = {
      "Has brought {n} of the fallen back with Redemption",
      "Won't leave a fallen companion lying, and has raised them {times}",
      "Raises the fallen as a matter of duty",
      "Has called {n} souls back to their bodies",
    },
    layonhands = {
      "Has given everything {they} had to save someone else, more than once",
      "Has laid hands on a dying companion {times} and pulled them back from the edge",
      "Spends {their} own strength on others when it matters most",
      "Has spent Lay on Hands on others {times}",
    },
    intervention = {
      "Has given {their} own life to spare a companion's, and come back from it",
      "Has laid down {their} life by Divine Intervention {times} so another might live",
      "Knows what it is to die so that someone else won't",
      "Has made the old sacrifice of Divine Intervention {times}",
    },
    -- Druid
    form_bear = {
      "Takes the bear's shape most often, and fights like one",
      "Wears the bear's shape more than any other",
      "Turns to the bear first when a fight comes",
      "Fights mostly as a great bear, slow to give ground",
    },
    form_cat = {
      "Prowls as a cat more than in any other shape",
      "Favours the cat's shape, quick and low to the ground",
      "Turns cat when a fight is coming, more often than not",
      "Spends long hours as a great cat",
    },
    form_travel = {
      "Takes to the road in travel form whenever it's long",
      "Spends a good share of {their} hours in travel form",
      "Would rather run on four legs than walk on two",
      "Is often seen loping between towns in travel form",
    },
    form_aquatic = {
      "Takes to the water in aquatic form whenever there's any",
      "Spends long hours swimming in aquatic form",
      "Is as much at home in the water as on land",
      "Swims in the shape of a sea creature more than most druids do",
    },
    form_moonkin = {
      "Fights mostly in the moonkin's shape",
      "Favours the moonkin's form above the others",
      "Spends much of {their} time as a moonkin",
      "Takes the moonkin's shape for nearly every fight",
    },
    rebirth = {
      "Has brought {n} of the fallen back mid-battle with Rebirth",
      "Has raised others in the middle of a fight {times}",
      "Keeps a Rebirth ready for whoever falls first",
      "Has pulled {n} companions back from death before the fight was over",
    },
    innervate = {
      "Hands {their} Innervate to whoever needs it more",
      "Has given Innervate to others {times}",
      "Shares the spirits' strength with tired healers",
      "Keeps an eye on others' strength, and lends {their} own",
    },
    thorns = {
      "Sets thorns on others before a fight, as a matter of course",
      "Rarely leaves a companion without a coat of thorns",
      "Has woven Thorns over others {times}",
      "Hands out Thorns to friends and strangers alike",
    },
    -- Death knight
    grip = {
      "Drags foes in rather than chasing them",
      "Hauls enemies across the field on a chain of dark power",
      "Has dragged foes to {them} {times}",
      "Would rather pull a foe close than go to it",
    },
    raisedead = {
      "Raises the dead to fight beside {them} as a matter of course",
      "Has raised {n} corpses to serve {them}",
      "Seldom fights without a ghoul at {their} side",
      "Makes use of the dead as freely as of the living",
    },
    -- Any shape or stance by name, when there are no words of its own.
    form = {
      "Fights in {form} most of the time",
      "Keeps to {form} more than any other",
      "Favours {form} over the others",
      "Is most often in {form}",
    },
  },

  ---------------------------------------------------------------------------
  -- History, the news: past-tense predicates after the name ("Aldric tamed a wolf in Westfall").
  ---------------------------------------------------------------------------
  EVENT = {
    tame = { "tamed {beast} in {zone}", "won over {beast} in {zone}", "brought {beast} to heel in {zone}",
      "took {beast} into {their} keeping in {zone}" },
    tame_nozone = { "tamed {beast}", "won over {beast}", "brought {beast} to heel", "took {beast} into {their} keeping" },
    portal = { "opened a portal to {dest}", "sent travellers through a portal to {dest}", "opened the way to {dest} for others",
      "conjured a portal to {dest}" },
    portals = { "opened {n} portals for others", "sent others home through {n} portals", "opened the way for others {times}",
      "conjured {n} portals for other travellers" },
    ritual = { "brought someone over by the ritual of summoning", "drew a summoning circle to bring someone across",
      "summoned someone to {their} side by ritual", "opened a summoning circle for someone far away" },
    rituals = { "brought others over by ritual {times}", "drew the summoning circle {times}",
      "summoned others to {their} side {times}", "opened a summoning circle {times}" },
    soulstone = { "set a soulstone on someone else", "left a soulstone with someone before a hard fight",
      "gave someone else a soulstone, just in case", "placed a soulstone on a companion" },
    raised = { "brought someone back from death", "raised one of the fallen", "called a fallen companion back",
      "brought one of the dead back to {their} feet" },
    raised_many = { "brought {n} people back from death", "raised {n} of the fallen", "called {n} fallen back to their bodies",
      "brought {n} of the dead back" },
    raised_strangers = { "raised {n} strangers where they fell", "brought {n} strangers back from death",
      "stopped to raise {n} strangers on the road", "called {n} strangers back from death" },
    intervention = { "gave {their} life by Divine Intervention to spare someone else's", "died by Divine Intervention so another would live",
      "laid down {their} life to shield a companion's", "made the sacrifice of Divine Intervention" },
    layonhands = { "spent Lay on Hands to save someone else", "laid hands on a dying companion and brought them back from the edge",
      "gave {their} strength to save another with Lay on Hands", "pulled a companion back from the edge with Lay on Hands" },
    reincarnation = { "came back from death by Reincarnation", "rose again on the strength of the spirits",
      "walked back from death by {their} own ankh", "was sent back from death by the spirits" },
    vanish = { "vanished out of a fight that was nearly the end", "slipped away from a fight just short of dying",
      "disappeared from a fight that had all but finished {them}", "vanished clear of a fight gone badly" },
    feign = { "played dead to get out of a fight going badly", "dropped and lay still to escape a losing fight",
      "fooled a foe into thinking {they} had died", "got out of a bad fight by playing dead" },
    shieldwall = { "dug in behind a shield wall when a fight nearly went wrong", "stood fast behind a shield wall on {their} last legs",
      "held a fight off behind a shield wall when it was nearly lost", "braced behind a shield wall with little left to give" },
    laststand = { "came through a fight on a last stand", "made a last stand when a fight nearly finished {them}",
      "held on through a last stand with almost nothing left", "turned a losing fight with a last stand" },
    blink = { "blinked clear of a fight that was nearly the end", "got out of a losing fight in a blink",
      "blinked away from a foe just in time to live", "blinked out of reach when a fight went wrong" },
    demon = { "called up {demon} for the first time", "first bound {demon} to {their} service",
      "summoned {demon} for the first time", "took {demon} into {their} service" },
    innervate = { "lent {their} Innervate to others {times}", "shared the spirits' strength with others {times}",
      "gave Innervate to tired companions {times}", "lent others {their} strength {times}" },
    rebirth = { "brought someone back mid-fight with Rebirth", "raised a companion in the middle of a fight",
      "called someone back with Rebirth before the fight was over", "pulled a fallen companion back to {their} feet mid-battle" },
  },

  ---------------------------------------------------------------------------
  -- History, the older record: present perfect after "{they've}" ("{they've} picked 212 pockets").
  ---------------------------------------------------------------------------
  OLDER = {
    charges = { "charged headlong into {n} fights", "charged into {n} fights", "crossed the field at a charge {times}" },
    shieldwall = { "stood fast behind a shield wall {times} when a fight nearly went wrong",
      "held on behind a shield wall {times} with little health left" },
    pockets = { "picked {n} pockets", "lifted what {they} could from {n} pockets", "had {their} hand in {n} pockets" },
    locks = { "sprung {n} locks", "picked {n} locks", "opened {n} locks that weren't meant for {them}" },
    vanish = { "vanished out of {n} fights that might have been the end", "slipped away from {n} fights at the last moment" },
    tames = { "tamed {n} beasts of {kindsN} different kinds", "won over {n} wild beasts, the latest {latest}" },
    feign = { "played dead {times} to get out of a losing fight", "lived through {n} bad fights by playing dead" },
    portals = { "opened {n} portals for others", "opened the way home for others {times}", "conjured {n} portals for others" },
    portals_others = { "opened {n} portals and taken {others} others through them", "sent {others} other travellers through {n} portals" },
    feeds = { "handed out {n} conjured meals and drinks", "given away {n} loaves and flasks of conjured food and water" },
    polymorph = { "turned {n} foes into sheep", "polymorphed {n} foes" },
    rituals = { "summoned others by ritual {times}", "drawn the summoning circle {times}" },
    soulstones = { "set soulstones on others {times}", "left a soulstone with someone else {times}" },
    healthstones = { "made {n} healthstones", "made {n} healthstones and handed {given} of them round" },
    raised = { "brought {n} people back from death", "raised {n} of the fallen" },
    raised_strangers = { "brought {n} people back from death, {strangers} of them strangers",
      "raised {n} of the fallen, {strangers} of them strangers" },
    shields = { "shielded others {times}", "warded others with Power Word: Shield {times}" },
    mindcontrol = { "bent {n} minds to {their} will", "taken hold of {n} other minds" },
    totems = { "planted {n} totems", "called on the elements through {n} totems" },
    reincarnation = { "come back from death by Reincarnation {times}", "risen again by {their} own ankh {times}" },
    blessings = { "blessed others {times}", "laid {their} blessing on others {times}" },
    intervention = { "given {their} life by Divine Intervention {times}", "died by Divine Intervention {times} so others would live" },
    rebirth = { "brought {n} of the fallen back with Rebirth", "raised others mid-fight {times}" },
    innervate = { "lent Innervate to others {times}", "shared {their} Innervate {times}" },
    form_hours = { "spent {hours} in {form}", "passed {hours} in {form}" },
    grip = { "dragged {n} foes to {them}", "hauled {n} foes across the field" },
  },

  ---------------------------------------------------------------------------
  -- Lately: a recent act of the calling. { title, icon, lines }
  ---------------------------------------------------------------------------
  LATELY = {
    tame = { "A New Companion", "Ability_Hunter_BeastTaming", {
      "Tamed {beast} in {zone}, and is still getting the measure of it.",
      "Won over {beast} in {zone}, and the two are still new to each other.",
      "Has added {beast} to {their} side, tamed in {zone}.",
      "Brought {beast} to heel in {zone} not a day ago.",
    } },
    portal = { "Opened the Way", "Spell_Arcane_PortalStormwind", {
      "Opened a portal to {dest} for others within the hour.",
      "Sent a few travellers home to {dest} through a portal just now.",
      "Conjured a portal to {dest} for others a short while ago.",
      "Has only just closed a portal to {dest}.",
    } },
    ritual = { "A Summoning", "Spell_Shadow_Twilight", {
      "Drew the circle to bring someone across just now.",
      "Brought someone over by ritual within the hour.",
      "Has only just stepped out of the summoning circle.",
      "Summoned someone to {their} side a short while ago.",
    } },
    raised = { "Raised the Fallen", "Spell_Holy_Resurrection", {
      "Brought {n} of the fallen back within the hour.",
      "Has just raised {n} of the dead to their feet again.",
      "Called {n} fallen back to their bodies a short while ago.",
      "Has been raising the fallen: {n} within the hour.",
    } },
    raised_one = { "Raised the Fallen", "Spell_Holy_Resurrection", {
      "Brought someone back from death within the hour.",
      "Raised one of the fallen just now.",
      "Called a fallen traveller back a short while ago.",
      "Has just brought someone back to their feet.",
    } },
    soulstone = { "A Soulstone Given", "Spell_Shadow_SoulGem", {
      "Set a soulstone on someone else within the hour.",
      "Left a soulstone with a companion just now, before a hard fight.",
      "Gave someone a soulstone a short while ago, just in case.",
      "Has just placed a soulstone on a companion.",
    } },
    sacrifice = { "A Sacrifice", "Spell_Nature_TimeStop", {
      "Gave {their} own life to spare a companion's, not a day ago.",
      "Gave up {their} life through Divine Intervention so another could live.",
      "Laid down {their} life for a companion's not long since.",
      "Made the sacrifice of Divine Intervention within the day.",
    } },
    layonhands = { "Laid on Hands", "Spell_Holy_LayOnHands", {
      "Spent everything on Lay on Hands to save someone, within the day.",
      "Pulled a companion back from the edge with Lay on Hands lately.",
      "Gave {their} strength to save another with Lay on Hands not a day ago.",
      "Laid hands on a dying companion and kept them in this world.",
    } },
    reincarnation = { "Reincarnated", "Spell_Nature_Reincarnation", {
      "Came back from death by Reincarnation within the last few hours.",
      "Rose again on the strength of the spirits earlier today.",
      "Walked back from death by {their} own ankh a few hours ago.",
      "Has only just been sent back from death by the spirits.",
    } },
    escape = { "A Narrow Escape", "Ability_Vanish", {
      "{escape} within the half hour, and is still shaky with it.",
      "{escape} just now.",
      "{escape} a short while ago, and is lucky to be standing.",
      "{escape} not half an hour since.",
    } },
    feeds = { "Bread and Water", "INV_Drink_18", {
      "Handed out {n} conjured meals and drinks just now.",
      "Has been passing round conjured food and drink: {n} lately.",
      "Gave away {n} conjured loaves and flasks within the half hour.",
      "Kept others fed and watered with {n} conjured rations just now.",
    } },
  },
  -- How each narrow escape reads at the start of a Lately line.
  ESCAPE = {
    vanish = "Vanished out of a fight that was nearly the end", feign = "Played dead to get out of a fight going badly",
    shieldwall = "Dug in behind a shield wall with little left to give", laststand = "Came through a fight on a last stand",
    blink = "Blinked clear of a fight that was nearly the end", bubble = "Got out of a bad fight behind a divine shield",
    barkskin = "Weathered a fight that nearly finished {them} in barkskin", fade = "Faded from a fight just short of dying",
    deathcoil = "Bought {their} life back with a death coil in a losing fight", icebound = "Held on through a losing fight in icebound fortitude",
  },

  ---------------------------------------------------------------------------
  -- Marks: what the work has just left on them. { title, icon, lines }
  ---------------------------------------------------------------------------
  MARK = {
    poison = { "Poison-Stained", "Ability_Poisons", {
      "Smells sharp, of poison freshly worked into a blade.",
      "Has the bitter smell of fresh poison about {them}.",
      "Carries the sharp tang of a poison newly applied.",
      "Wipes {their} hands more often than usual, the poison still fresh.",
    } },
    pockets = { "Light Fingers", "INV_Misc_Bag_11", {
      "Has the quick, restless hands of someone just back from other people's pockets.",
      "Keeps {their} hands busy and close, fresh from lifting what {they} could.",
      "Looks a touch too pleased, fresh from picking pockets.",
      "Has the careful stillness of a pickpocket between marks.",
    } },
    conjure = { "Freshly Conjured", "INV_Drink_18", {
      "Smells of fresh bread and cold water, both conjured from nothing.",
      "Has the chill of new-conjured water on {their} hands.",
      "Still has frost on {their} fingers from conjuring water.",
      "Has just conjured a meal or three, and smells of warm bread.",
    } },
    ritual = { "Brimstone", "Spell_Shadow_Twilight", {
      "Smells of brimstone after a summoning.",
      "Still has the reek of a summoning circle about {them}.",
      "Carries the sour smell of fel fire from a ritual just done.",
      "Has the hollow look of someone who has just spent a soul shard on a summoning.",
    } },
    raised = { "Drawn and Tired", "Spell_Holy_Resurrection", {
      "Pale and slow after bringing the fallen back.",
      "Looks spent, as anyone would after bringing the dead back.",
      "Is pale and worn from calling the fallen back.",
      "Has the hollow-eyed weariness of a long round of resurrections.",
    } },
    stand = { "Hard Pressed", "Ability_Warrior_ShieldWall", {
      "Is breathing hard, newly back from a stand that nearly went the other way.",
      "Still has the set jaw of someone who just held on by a thread.",
      "Looks battered and grim, fresh from a fight that almost finished {them}.",
      "Is still shaking off a fight that came closer than {they} would like.",
    } },
  },

  ---------------------------------------------------------------------------
  -- Statistics: what each count is called. { one, many }
  ---------------------------------------------------------------------------
  NOUN = {
    charge = { "charge", "charges" }, intercept = { "intercept", "intercepts" }, taunt = { "taunt", "taunts" },
    pockets = { "pocket picked", "pockets picked" }, locks = { "lock picked", "locks picked" }, poisons = { "poison applied", "poisons applied" },
    sap = { "sap", "saps" }, tames = { "beast tamed", "beasts tamed" }, traps = { "trap laid", "traps laid" },
    tracking = { "tracking", "trackings" },
    portals = { "portal", "portals" }, teleports = { "teleport", "teleports" }, polymorph = { "Polymorph", "Polymorphs" },
    conjured = { "conjuring", "conjurings" },
    rituals = { "summoning", "summonings" }, healthstones = { "healthstone", "healthstones" }, demons = { "demon called", "demons called" },
    mindcontrol = { "Mind Control", "Mind Controls" }, fade = { "Fade", "Fades" },
    totems = { "totem", "totems" }, intervention = { "Divine Intervention", "Divine Interventions" },
    layonhands = { "Lay on Hands", "Lays on Hands" }, grip = { "Death Grip", "Death Grips" }, raisedead = { "ghoul raised", "ghouls raised" },
    deathgate = { "Death Gate", "Death Gates" },
    -- Given to others
    rez = { "raised", "raised" }, redemption = { "raised", "raised" }, ancestral = { "raised", "raised" },
    rebirth = { "Rebirth", "Rebirths" }, raiseally = { "raised", "raised" },
    pws = { "shield", "shields" }, fort = { "Fortitude", "Fortitudes" }, blessing = { "blessing", "blessings" },
    thorns = { "Thorns", "Thorns" }, innervate = { "Innervate", "Innervates" }, soulstone = { "soulstone", "soulstones" },
    intellect = { "Arcane Intellect", "Arcane Intellects" }, mark = { "Mark of the Wild", "Marks of the Wild" },
    feeds = { "conjured meal", "conjured meals" }, stonesGiven = { "healthstone handed over", "healthstones handed over" },
    lohOthers = { "Lay on Hands", "Lays on Hands" }, portalOthers = { "traveller sent", "travellers sent" },
  },
}
