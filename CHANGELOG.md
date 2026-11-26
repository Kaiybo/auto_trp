# Changelog

## 0.21.0 (2026-11-26): Home Ground

- **Where the days go.** Auto TRP now notes how long your character spends in each land (counted every half minute; not while you're away from the keyboard or on a flight, and a loading screen never counts as more than one tick).
- A new statistic, *Most time spent*: "Westfall, 14 hours". It has its own switch and appears after an hour in one place.
- History says it once one land clearly holds the most of your time (at least three hours, a quarter of all of it, and well ahead of the next): "Spends more of her days in Westfall than anywhere else."
- The *Lately* glance notices when another land takes over (for a couple of days): "Lately he's been seen more in Duskwood than in Westfall." The first land found is taken in quietly.
- A new statistic, *Flights taken*: every flight from a flight master, counted once, with its own switch. It sits after *Days on the road*.
- `/atrp places` lists the five lands you've spent the most time in, and since when.
- **Plainer chat lines.** "Updated Currently, About: History and two statistics (deaths and wealth)." instead of "Updated: About: History, Currently, Stats: deaths, Stats: wealth.", in the order the profile reads, with the glances and statistics gathered together. The same for the fields left alone because they're yours.
- *Lately* no longer leaves a death hanging: a day or two on, it says the character is back on their feet, which matches what Currently and the mood show.
- **A tidier preview.** The statistics read as one block, a line each, the way Total RP 3 lists them, with the ones that have nothing to count yet gathered into one line at the end instead of a dozen "(nothing yet)"s.
- **Reads as one piece.** The About pages no longer say the same thing twice or break one event into scraps:
  - Personality leaves out a belief the opening line already gave ("keeps to the Light", then "keeps faith in the Light").
  - History tells a master felled in a dungeon it has just named in the same sentence: "Has been down into the Deadmines and helped bring down Edwin VanCleef there.", not "Has seen the inside of the Deadmines. Helped bring down Edwin VanCleef."
  - Physical no longer names your finest piece a second time after listing what you wear, and the class look never echoes your build ("calm-faced", then "Calm-eyed"). Priests have two more ways to look.

## 0.20.0 (2026-11-25): In Good Order

- **Fixed: some characters' profiles stopped being written.** 0.14.0 lost the class rank ladders every race shares, so a character whose race and class have no ladder of their own (a human warlock, a dwarf rogue) hit an error on every update: *Currently* and the glances kept going, but the title, About, History, statistics, nickname and the rest were never written. The ladders are back (a human warlock rises from Initiate to Summoner and on), and a new test builds the whole profile for every race and class.
- **Fixed: reaching a new rank** (every ten levels) hit the same error and was never remembered, so History never said "Was made ...". It's remembered again, on the same race and faction ladder as the Title, and a rank saved by an earlier version is read again by its level.
- **Statistics read in order.** They used to land in Total RP 3's Additional information in no particular order (*Best standing* first, *Deaths* sixth, the nickname and motto wedged between them). Now they come after your other entries, in the order the settings list them, and a statistic that turns up later (your first rare beast) takes its place among the rest instead of going to the end. A profile written by an earlier version is tidied once; only Auto TRP's own entries move, yours stay where they are.
- **Switched off means taken down.** Turning off a statistic (or all of them) used to leave its last value on the profile, going stale. Now Auto TRP takes down what it wrote there, and puts it back if you switch it on again. A glance switched off is hidden the same way (Total RP 3 keeps its text). Anything you've edited yourself is still left alone.
- **`/atrp days` works again.** The mood journal command has been in the help and the README all along but was lost in 0.5.0; it lists the last week, a line a day.
- **Jobs and victories without Chronicle.** The *Lately* glance now hears about a quest just turned in from Auto TRP's own record, as 0.18.0 meant it to, and a master felled again shows as a fresh victory straight away rather than up to a minute later.
- **Names are never forgotten.** Auto TRP's quest record keeps its newest 1,500 quests; past that it now never forgets one that earned a name, which would have quietly taken the name away.
- A Chronicle goal that ends in its own "?" or "!" (or is cut short with "...") no longer gets an extra full stop in *Ambition*.
- Lighter: item information arriving (tooltips, the auction house, loot) no longer makes Auto TRP read your reputations, skills, gear and bags again, unless it was still waiting on one of your items' names.

## 0.19.0 (2026-11-25): Old Habits

- The most cast spell. Every spell and ability your character casts is counted (not swings or shots, the hearthstone, gathering, crafting, or items like potions, food and bandages).
- A new statistic, *Most cast spell*: "Flash Heal, 1,240 times". It has its own switch and appears once something has been cast ten times.
- Personality says it once it's a real habit (fifty casts): "Reaches for Flash Heal more than any other spell." A warrior's or rogue's is an *ability*. Without RPG Dialogue, Personality now has this line rather than nothing.
- `/atrp spells` lists the five you cast most, and since when they've been counted.

## 0.18.0 (2026-11-25): Deeds of Their Own

- Auto TRP keeps its own record of what your character sees through: every quest turned in (its title, where and when) and every dungeon or raid master brought down (where, the first time and how many times). Quest chains, masters and bounties now earn their names **without Chronicle**, and nothing is missed while Chronicle is switched off. With both, the earlier time stands and nothing counts twice.
- Chains finished before this version: where the game can list every quest a character has completed, the ones that earn a name are taken in once, quietly, a little after login.
- The record also feeds the statistics (*Named foes felled*, *Jobs done*), History's masters and jobs, the *Lately* glance and the stories in Personality, so they work without Chronicle too.
- More chains: *Stalvan Mistmantle* (the chain's last step, beside *The Legend of Stalvan*), *Morganth* (*Morganth's Bane*), the Stockade's *The Stockade Riots* (*Riot-Breaker*) and *Crime and Punishment* (*Dextren's Bane*), *Kolkar Leaders* (*Barak's Bane*), and the Horde's *Into The Scarlet Monastery* and *Gnomer-gooooone!*.
- The mood badge's tooltip shows the name you're known by and what for; the preview lists every other name earned.

## 0.17.0 (2026-11-25): Names Worth Keeping

- Far more ways to earn a name. Quest chains: from 4 to 35, both factions and every part of the world: *Pig-Sticker* (Princess), *Militia-Hand* (the People's Militia), *Grave-Settler* (Mor'Ladim), *Lamp-Lighter* (Morbent Fel), *Bangalash's Bane*, *Page-Gatherer* (the Green Hills of Stranglethorn), *Mankrik's Friend*, *Kolkar-Breaker*, *Prospector's Guide*, *Linken's Friend*, *Darrowshire's Friend*, *Taelan's Witness*, the dungeon chains (*Scarlet-Breaker*, *Fang-Breaker*, *Gear-Breaker*, *Idol-Quencher*, *Disc-Reader*...), the keys and attunements (*Key-Bearer*, *Spire-Climber*, *the Unmasker*, *Core-Walker*) and two class chains (*the Whirlwind*, *Verigan's Heir*), each with its own saying and icon.
- Every dungeon and raid master, 33 in all, has its own name, saying and icon, not just "...'s Bane" and a dragon's head: *Dream-Waker* for Mutanus ("Every nightmare ends."), *Riot-Breaker* for Bazil Thredd, *Vault-Breaker* for Archaedas, *Frost-Breaker* for Amnennar, up to Onyxia, Ragnaros, Nefarian, Hakkar, C'Thun and Kel'Thuzad. A master's name now comes with a motto as well.
- Bounties: titles in quotes (`Wanted: "Hogger"`, as the game writes some of them), shouted ("WANTED: Murkdeep!") or with a dash ("Wanted - Arnak Grimtotem") now earn their name; a poster after a crowd ("Wanted: Syndicate Personnel") no longer makes a "Personnel's Bane". Hogger, Gath'Ilzogg, Fangore, Murkdeep and Longshore come with a saying.
- The greatest deed counts: within a kind, the hardest master or the longest chain wins over a small errand done first; between equals the first one earned still sticks. The same name from a story and its chain counts once.
- Every earned name is kept. `/atrp names` lists them with what each was for; `/atrp name <number>` (or the name itself) wears another one, `/atrp name auto` goes back to the greatest. History mentions the other names that stuck ("Also answers to "VanCleef's Bane"."), and a new statistic, *Names earned*, lists them.
- A name earned just now is noticed: a quiet line in your own chat with the deed and its saying (and which name you still go by), pride, and the Lately glance ("Some have started calling her "Militia-Hand".") for a couple of days. Names you'd already earned, and deeds days old, are taken in quietly.
- History tells where the name came from in more ways than one ("...and some have called Aldric "Mine-Warden" since", "It's why Aldric answers to...", "They came away from it with a saying: ...").
- Fixes: the add-on list showed version 0.13.0 and `ns.VERSION` said 0.14.1.

## 0.16.0 (2026-11-25): Earned Names

- Nickname and motto are earned by something the character saw through, not by counts: a story finished in RPG Dialogue (each of its fifty stories gives its own nickname and saying, like *Mine-Warden* and "Gold isn't worth a life." for *The gold of Elwynn's mines*), then a quest chain finished in Chronicle (*Defias-Breaker*), then the hardest dungeon master brought down (*VanCleef's Bane*), then a bounty collected (*Hogger's Bane*). The first one earned of the highest kind sticks. Gone: *Grave-Cheater*, *the Bookish*, *the Far-Walker* and the rest, and the temperament and race mottos ("Stay away from da voodoo", "Lok'tar ogar!", including the ones 0.15.0 added). With nothing earned yet, the nickname and motto stay empty.
- History says where they came from: "Saw the gold of Elwynn's mines through to the end. That's how Aldric came to be called "Mine-Warden", and where they picked up the saying "Gold isn't worth a life."" The preview shows the deed beside both.
- The profile icon: the earned nickname's icon (a coin for the Mine-Warden, a dragon's head for a boss's bane), else the class crest. New switch: "Icon". It follows the same rules as every other field: your own icon is left alone.
- History reworked: the origin reads as a sentence ("Aldric, a human priest, started out as a farmhand from the Westbrook fields."), the road reads as one ("From Elwynn Forest their road has led through four lands, Duskwood the latest of them."), deeds come before people, friends and travelling companions share a sentence, crafts and wealth read as part of the story ("Between roads they're a journeyman herbalist.", "These days they're well off..."). The creature kill count leaves the prose (it's still a statistic).

## 0.15.0 (2026-11-25): Many More Words

- Far more writing to show up. Most moods now have five or more ways to put it in Currently and as many things a stranger notices (up to eight), and the calm temperaments four or five each. Every race and class has its own lines for many more moods (a dwarf planted like a boulder, a night elf utterly still with ears turned to every sound, a warrior who moves like someone who has held a line all day). Still faces, voices and postures only, never an invented action or prop.
- Currently: three to five ways of describing every zone, a second and third for every dungeon, raid and city district, more for each activity (mail, bank, fishing, crafting, gathering, portals...), each craft, travelling, riding, flying, swimming, stealth, inns, towns, battlegrounds, flights and being a ghost, and different words for night, dawn and dusk.
- The glances and About tell the same facts in different words from one character (or one event) to the next: Lately (fights, close calls, jobs, finds, story beats, conversations, new lands), Company, Ambition, Marks, and the History and Personality paragraphs (friends, rivals, dungeons, named foes, rare beasts, jobs, crafts, home, stories).
- More mottos (by temperament and race), ambitions, builds, race and class looks, festival moods and ways to sum up the week.
- Grammar: lines now agree with he or she as well as they ("she walks", "he carries"), and two moods at once read "In no hurry, hale and hearty" rather than a run of "and"s.
- A new test fills every line with each set of pronouns and fails on any tag left over, and checks every mood has at least three ways to say it.

## 0.14.1 (2026-11-25): Secret Values

- Fixed "attempt to perform boolean test on a secret boolean value" (World.lua, away-from-keyboard check) on clients that hide some game values. Every game API read and every event payload now treats a secret value as unknown, instead of patching one call at a time.

## 0.14.0 (2026-11-25): Nothing Made Up

- Nothing invented. Auto TRP still draws conclusions from what the game records, but no longer makes up actions, props or backstory:
  - Mood lines describe a face, a posture or a voice. Gone: sitting beneath a tree, reading scripture, conjured tea, polishing a helm, brushing out a pet, sparks at the fingertips, fiddling with a gadget, pounding the table.
  - Currently no longer picks a class activity at random ("tending the land around...") when you're just out in the open, and an inn is "resting at" or "staying at", not "warming up by the fire".
  - History drops the invented turning point ("Something changed in them after...") and the "what the road has made of them" lines. Without an RPG Dialogue origin it says your race, class and starting land, not a made-up childhood.
  - Personality drops "people still argue about whether they're a good sort", "doesn't always say why they changed" and "reads whenever there's light to read by". A changed opinion now says what it was ("Used to distrust the night elves, and has since changed their mind"); books read are listed plainly.
  - Plainer deeds and wealth: no "most weeks", "has gone hungry more than once", "and still thinks about it", "and is not done yet" or "treasures it above anything else".
  - The Ambition glance, with no goal or unfinished story, names the next rank on your road.
  - Lately, Company and Marks lose their invented tails ("still smelling of the place", "would welcome company", "it comes up in most conversations", "banners and all").
- Letters received and people met are gone from History and the Statistics (they meant little to anyone reading), and so is the "the Talker" nickname. Statistics an earlier version wrote for them are taken off the profile.
- Physical: race looks are only what the race shares; the finest piece of gear is named instead of "Eyes go first to their chest".
- `tests/banned_phrases.txt` now bans the invented lines too.

## 0.13.0 (2026-11-24): A Life, Not a Ledger

- About is written as the character's story instead of a list of what the addons know. History runs in five short paragraphs (roots, the road, the people, the deeds, how things stand now), and events come with what they did to the character: the place that changed them, what the road has made of them at their stage of life. All of it shaped by temperament.
- Statistics in Total RP 3's Additional information: deaths, lands explored, days on the road, dungeons, named foes, rare beasts, creatures slain, jobs done, wealth, crafts, best standing, people met, books read and letters received. A master switch and one per statistic. Most also get an in-character line in About (wealth by how well off you are for your level), but deaths stay out of the prose. A fresh death reads as being badly hurt in the Lately glance.
- Only what the game backs up: gear is named only when equipped, by its own name ("Wears Crown of the Lost"); mood lines that mention a weapon, helm, shield or pet need one and name it; class reagents only when in your bags; race looks only what the whole race shares (no beards, hair, skin colour, scars, invented holy symbols, quivers or prayer books). A test (`tests/unbacked_nouns.txt`) keeps it that way.
- A coin pouch when you carry coin, its weight by your wealth ("Their coin pouch clinks when they walk").
- Gear wear follows the game's durability in bands and names the worst piece; the Marks glance only calls gear battered when it really is.
- Not too famous: standing is local and modest ("is liked in Goldshire", never "a hero to"), the full title at most "Friend of...", reputations as "Has done good work for...", no fame in the arc lines or level-60 words, and rank titles without offices or patrons (Thane, Warlord, Magister, SI:7, Archbishop's Chosen, Elder of the Cenarion Circle are gone).
- Personality: temperament and conscience together, beliefs and the ones that changed, lies found out, books, and the stories they have (instead of "Ask them about").
- Physical in three paragraphs: the body, what they wear and carry, what life has left on them.
- Looks nicer: quotes in a pale cream, the finest item and prized finds in their quality colour (switch: "Colour quotes and item names").
- Plainer writing: `tests/banned_phrases.txt` bans stock phrasing and the old tics ("By most accounts:", "The eye goes to", "A reader, too:", "most lately", "it shows"...), and the test enforces it. Fewer semicolons and "a little"s throughout the mood words.
- Fixes: story titles that start with a name keep their capital ("Westfall, left to fend for itself"); opinion topics like the Cenarion Circle get their "the"; a home that isn't an inn reads "in Stormwind City"; numbers under a hundred are written out.

## 0.12.0 (2026-11-24): Turncoat's Letters

- From RPG Dialogue: Personality notes when you've changed your tune about something; History remembers lies you were caught in (and being found out stings); Physical mentions the bundle of letters you carry once a few have reached you.

## 0.11.0 (2026-11-24): Ore, Herb and Hide

- Gathering and tradecraft in Currently: mining, herb gathering, skinning, disenchanting, picking locks and pockets.
- Zone touches work in every game language (zones are recognised by map ID on non-English clients).
- The settings panel scrolls; Auto TRP is in the AddOns menu by the minimap (click for the preview, right-click to pause); key bindings for the preview, pause and write-now.
- History notices a hard few days or a good stretch from the mood journal.
- The quiet Lately line has your class's flavour ("Has been tending to travellers around Goldshire").

## 0.10.0 (2026-11-24): Steady Hands

- Lately: the fight you just had ("Fresh from a fight with a Defias Pillager", "Barely survived a fight with Hogger") and the job you just finished (from Chronicle).
- Fading feelings read "Still ..."; Currently trims itself to fit Total RP 3's tooltip.
- Company names your party by class ("a priest and two warriors"); a raid is a host. The badge's border shows a good or bad mood. `/atrp why`.
- "Open to walk-ups" can follow your mood (off by default). Switches for the people and place reactions.
- New characters find the world new; veterans are steadier; ambitions change at the start and the height of the road; a hunter grieves a fallen pet.
- Fixes from a second review: reputation ticks no longer pin you at "proud" (once per faction per half hour, never inside dungeons); crafted items aren't loot finds; an unhappy pet isn't a money worry; new standings are caught on either chat channel and don't stay "not long ago" forever; a new home is noticed from the hearthstone itself; the enemy-faction reaction works without Social Diary and ignores duels with your own side; bosses and players aren't "a Hogger"; Forsaken can feel well-fed; "Still ..." only when it really is fading; spells learned on newer clients count; spell events only for you; the update pass reuses the mood it already has and skips the story when only Currently is due; the five-second check watches a shared Social Diary and Chronicle's quests; duels match first names.

## 0.9.0 (2026-11-24): Honoured Names

- In the capitals, Currently describes the district: the Trade District and Old Town, the Great Forge and Tinker Town, the Drag and the Valley of Honor, Elder Rise, the Apothecarium and more.
- Reputation: rising with a faction makes you proud, falling ashamed; reaching Honored, Revered or Exalted is a big moment, remembered in History.
- Targeting a player of the enemy faction puts you on edge.
- Learning a new ability, crafting something, or making an inn your home all register.

## 0.8.0 (2026-11-24): Familiar Faces

- Inside a dungeon or raid, Currently describes it: the dripping tunnels of the Deadmines, the cursed halls of Shadowfang Keep, the burning streets of Stratholme, the fire of the Molten Core, and two dozen more.
- Targeting a player you marked as a friend in Social Diary lifts your mood ("ran into Mirelle"); a foe sets your jaw. Once per person every half hour.
- Every class now has its own way of showing most moods.

## 0.7.0 (2026-11-24): Temper and Blood

- Temperament by race and class: dwarves take to drink merrily, orcs' blood runs hot, tauren are slow to anger, the Forsaken brood but scare less; warriors relish a fight, priests and paladins feel devotion and grief more, warlocks are hard to haunt, rogues stay cool.
- The hour by race: night elves are at ease at night, tauren feel the dawn.
- Lately shows the conversation you just had in RPG Dialogue (warmly or coldly).
- The Marks glance falls back on your class's look alongside your kit.
- Many more racial mood tells.

## 0.6.0 (2026-11-24): Old Wounds, Holy Ground

- Places mean something to your race and class: a night elf grieves in Felwood, a dwarf bristles in Dark Iron land and wonders at Titan ruins, a gnome mourns lost Gnomeregan, a Forsaken remembers Lordaeron, an orc burns at the old internment camps, a troll is at home in Stranglethorn, a tauren on Mulgore's plains. Paladins and priests at holy sites, druids in Moonglade, shamans on Elder Rise, warlocks in fel-touched land, rogues in Booty Bay, warriors at the arena. Everyone eases among their own people and tenses in the enemy's capital.
- Your spells: bringing someone back from death (Resurrection, Redemption, Ancestral Spirit, Rebirth) feels righteous; a mage's portal and a warlock's summoning ritual show in Currently; racial abilities (Shadowmeld, Cannibalize, Berserking, Blood Fury, War Stomp, Stoneform, Escape Artist, Will of the Forsaken) colour your mood.
- Hunters: your pet's happiness shows in your mood and the Company glance.

## 0.5.0 (2026-11-24): Light Step

- Lighter: nothing is worked out during combat; the other addons' data is read only when it changes; one pass per update instead of two; health and aura events only for you and your party.
- Currently knows who you're talking to, what you're reading, duels, being away, sitting, sleeping, dancing and hearthing home. Mounts by name, class or race (ram, kodo, nightsaber, felsteed, charger...), flights by faction (gryphon, hippogryph, wind rider, bat). Winning or losing a duel moves your mood.
- Safer with Total RP 3: never writes into a section while its editor is open; an editor saving an older copy is simply rewritten; a switched-off glance with your words is left alone; text is cleaned the way Total RP 3 cleans it.
- `/atrp restore` puts back exactly the fields Auto TRP wrote (now including relationship status and the OOC note) and nothing else.
- `/atrp slot` keeps both glances when they swap; glance slots are per character; two characters sharing one profile agree on what Auto TRP wrote.
- Fixed: a one-second loop while paused out of character; the setup popup no longer touches a game global, and Escape isn't a permanent no; "partner" no longer sets you as taken.

## 0.4.0 (2026-11-24): Blood and Bone

- **Reactive**: two dozen game events update your profile within seconds. Currently and the glances are rewritten whenever they change (at most every 15 seconds), the story within half a minute of something that matters, and anything held back in combat right after it.
- **Race and class everywhere**: rank ladders by race, class and faction (Deathstalker, Mountaineer, Brave, Loa-Speaker, Acolyte of Elune, Grunt...); racial and class mood tells; racial looks and class marks in Physical; backgrounds, ambitions and mottos by race; class activities in Currently.
- Milestones: each new rank, where you were and how you felt, in History. Your epic finds become prized possessions, and a fresh one shows in Lately.
- Checks run on GitHub for every push; `tools/build_zip.py` makes an installable zip.

## 0.3.0 (2026-11-24): The Mood Journal

- A mood badge on screen: hover for why you feel the way you do, click for the preview, right-click to pause.
- A quiet chat line when your mood turns (your chat only).
- The mood journal: each day's main feeling and place. History sums up the last few days; `/atrp days` lists the week.
- Personality ends with conversation starters for other players.
- History adds your guild, faction reputations, PvP rank, how long you've been on the road, an inn you moved from, and the creatures you've thinned out.
- Relationship status from a partner named in Social Diary; an optional OOC note.
- Druid, shaman and priest forms show in Currently. Professions are read from the game when Chronicle isn't there.
- Icons on the About sections.
- `/atrp restore` puts your profile back exactly as it was before Auto TRP; `/atrp slot` moves glances between slots.

## 0.2.0 (2026-11-24): Many Moods

- Mood draws on far more: grief after recent deaths, frustration at a run of them, buffs and world buffs, sickness and wounds, loot, money, full bags, broken gear, fights and jobs in a row, enemy land, festivals, your group and friends, your emotes, and choices in RPG Dialogue that went with or against your nature. `/atrp mood` shows why.
- All five At first glance slots are filled: mood, lately, company, ambition and marks.
- Personality bars in plain words: Good/Evil, Lawful/Chaotic, Honest/Deceitful.
- Title is now a rank by experience per class (Initiate, Squire, Knight...); alignment moves into the full title.
- About: Physical is on, built from your gear, your build and Chronicle's equipment snapshot.
- Currently notices crafting, fishing, eating, the mailbox, bank and auction house, your pet and the zone's atmosphere.
- History adds dungeons, your inn, groups and enemies from Social Diary, rare beasts, crafts, books read and more.
- `/atrp feel <mood>` and `/atrp intent <text>`; an option to pause while out of character.

## 0.1.0 (2026-11-24): First Ink

- Keeps your Total RP 3 profile in step with your story: Currently, three At first glance slots, personality traits, About (Personality, History, optional Physical), title, full title, nickname, motto, residence and birthplace.
- Reads RPG Dialogue, Social Diary and Chronicle when they're installed.
- A mood that follows what happens to your character and where they are.
- Writes only to its own profile, never over your own words, never in combat.
