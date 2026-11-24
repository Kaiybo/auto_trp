# Changelog

## 0.13.0 (2026-11-24): A Life, Not a Ledger

- About is written as the character's story instead of a list of what the addons know. History runs in five short paragraphs (roots, the road, the people, the deeds, how things stand now), and events come with what they did to the character: the place that changed them, what the road has made of them at their stage of life. All of it shaped by temperament.
- Statistics: deaths, lands explored, dungeons and creatures slain are plain counts in Total RP 3's Additional information, not sentences in History. A fresh death reads as being badly hurt in the Lately glance.
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
