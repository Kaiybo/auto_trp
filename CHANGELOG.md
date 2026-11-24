# Changelog

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
