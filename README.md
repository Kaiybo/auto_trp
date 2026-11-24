# Auto TRP

A companion to [RPG Dialogue](https://github.com/Kaiybo/rpg-dialogue) for World of Warcraft: Forever. It keeps your **Total RP 3** profile in step with your character's story: what they feel, where they are, what they believe, who they know and what they've been through.

It reads three addons if you have them (all optional, and it never changes them):

- **RPG Dialogue**: your origin, alignment and traits, opinions you've voiced, standing in towns, the people you've met, the stories you've followed, your diary.
- **Social Diary**: the players you've marked as friends (and the relationship you wrote down for them), your recent groups.
- **Chronicle** (AzerothForge Adventure Chronicle): your goals, bosses brought down, dungeons, rare beasts, professions, deaths, and its equipment and stat snapshots for your appearance. Your private Chronicle notes are never read.

## What it writes

**It reacts as things happen.** Over two dozen game events (changing zone or subzone, resting, leaving combat, a buff or sickness landing, mounting, shapeshifting, your pet, joining a group, the mailbox, bank or crafting table, loot, money, your emotes, a death, a level, a boss, a conversation in RPG Dialogue, new gear, reputation) trigger an update within a couple of seconds. **Currently** and the glances are rewritten whenever they change (at most every 15 seconds), the story within half a minute of something that matters, and anything held back during combat is written the moment it ends.

| Total RP 3 field | From |
|---|---|
| **Currently** | Your mood, what you're doing and where, with the zone's atmosphere, your pet and the hour: *"Bone-tired and a little uneasy, beneath the dead trees of Duskwood, with Fang at heel, under the stars."* It notices the mailbox, the bank, the auction house, crafting, fishing and eating. `/atrp intent` adds your plans. |
| **At first glance**, all five | **1 Mood**: what a stranger notices. **2 Lately**: the freshest news (a death, a victory, a story moving, a new land), else who you were last seen with. **3 Company**: your group, your Social Diary friends, where you're known, or travelling alone. **4 Ambition**: your Chronicle goal, an unfinished story, or what your class strives for. **5 Marks**: wounds, drink, madness, taint, battered or remarkable gear, old scars, else what you wear and carry. |
| **Personality traits** | Plain words: **Good/Evil**, **Lawful/Chaotic**, **Honest/Deceitful** from your RPG Dialogue alignment, and Kind/Cruel, Brave/Cautious, Generous/Greedy, Religious/Skeptical, Outgoing/Reserved, Playful/Serious from your choices. |
| **About: Personality** | Temperament, a plain *"By most accounts: good and lawful"*, the opinions you've said out loud, and conversation starters for other players: *"Ask them about the gold of Elwynn's mines, what's down in the Deadmines..."* |
| **About: History** | Your origin in your own words, how long you've been on the road, the lands and dungeons you've seen, your usual inn (and the one you gave up), friends and rivals, where you're liked or distrusted, who you ride with, your guild, faction reputations and PvP rank, deeds, crafts, the creatures you've thinned out, books you've read, close calls, how the last few days have felt, and a line from your diary. |
| **About: Physical** | Your race's look (a dwarf's braided beard, a Forsaken's stitched grey flesh, a tauren's beaded horns...), your class's marks (a paladin's holy symbol, a shaman's totems, a warlock's whiff of brimstone...), your build, what you wear and carry, the finest thing on you, and your scars. |
| **Title** | Your rank by experience, specific to your race, class and faction: a Forsaken rogue rises from Newly Risen to Deathstalker, a dwarf hunter from Novice to Mountaineer, a tauren warrior from Young Brave to Plainsrunner, a troll shaman to Loa-Speaker and Witch Doctor, a night elf priest to Acolyte of Elune, an orc warrior from Grunt to Warlord. |
| **Full title** | Alignment and standing (*Lightsworn, Friend of Goldshire*), else what you are and where from. |
| **Relationship status** | Married or Taken, if you've named a wife, husband, betrothed or sweetheart in Social Diary. |
| **OOC note** | Off by default: a line saying the profile updates itself. |
| **Nickname, Motto, Residence, Birthplace** | An epithet you've earned (*the Far-Walker*, *Grave-Cheater*, *the Bookish*), a motto that fits your temperament, your inn, your homeland. |

Each one has a switch in the settings.

## Race and class

Your race and class shape almost everything: the rank ladder, how each mood shows on you (a tauren's ears pinned back, a Forsaken's creaking joints, a mage's sparks at the fingertips), what you get up to on the road (a hunter tracking, a shaman listening to the spirits, a warlock gathering reagents best not named), your background when RPG Dialogue has no origin for you, your ambitions and your motto.

## How your character feels

Dozens of signals feed it, and each feeling remembers why (`/atrp mood` shows the reasons):

- **Death**: shaken right after, then **downcast** for hours; die again soon and you're **frustrated**. Resurrection sickness leaves you **drained**. Watching a party member fall brings sorrow and anger.
- **Blessings and ailments**: three or more buffs and you're **in fine fettle**; a world buff makes you **glorious**; Well Fed, **well-fed**. Disease, poison or a curse leaves you **ailing**; low health out of a fight, **wounded**.
- **Fortune**: a rare or epic drop **thrills**, a windfall makes you **flush**, an empty purse **worried**, full bags **overloaded**, broken gear frustrating. Almost at the next level: **eager**.
- **Deeds**: a level **elates**, a boss is a **triumph**, a run of fights makes you **battle-hungry**, a run of finished jobs **accomplished**, a close call **rattled**.
- **Places**: **at ease** in an inn or sanctuary, **on guard** in a dungeon or enemy land, **uneasy** in Duskwood or the Plaguelands at night, **wide-eyed** somewhere new, **glad to be home**, **festive** at Winter Veil, Hallow's End, Midsummer, Brewfest and the rest.
- **Company**: in good company in a group, happier with Social Diary friends, **solitary** after a long time alone.
- **Your story** (RPG Dialogue): a dark choice leaves you **conflicted**, a good one **righteous**; goodwill earned makes you **proud**, lost **ashamed**; a story beat **intrigues**; a letter brings **news**; drink makes you **merry**; madness **haunts**. A Chronicle goal reached **elates**.
- **Your emotes**: /cry, /dance, /pray, /flirt, /rage, /cower, /wave and more move your mood.
- **Temperament** bends all of it: brave characters shake less, kind ones grieve more, greedy ones love a windfall, the devout take prayer to heart.

`/atrp feel <mood>` sets it yourself for an hour.

**The mood badge**: a small icon on screen shows your current mood. Hover for the reasons and what your profile says, click for the preview, right-click to pause, drag to move (`/atrp badge` hides it). When your mood turns you get a quiet line in your own chat (never sent to anyone).

**The mood journal** keeps each day's main feeling and place for two weeks. History sums up the last few days (*"These past days: downcast in Duskwood today and wide-eyed in Westfall yesterday."*), and `/atrp days` lists the week.

## Your words stay yours

- Auto TRP writes to **one profile**. On first login it offers to make a copy of your current profile called *"Name (Auto TRP)"* and only ever writes there. Switch to another profile and it stops.
- It never writes to Total RP 3's default profile (Total RP 3 doesn't allow it).
- **It never writes over your own words.** If a field already has text it didn't write, or you edit something it wrote, that field becomes yours and it stops touching it. `/atrp claim <field>` hands one back.
- Nothing is written in combat. *Currently* and the glances update at most every 90 seconds; the rest every five minutes or after something that matters.
- **Backup**: before its first write to a profile, Auto TRP keeps a copy of everything it might touch. `/atrp restore` puts the profile back exactly and hands every field back to you.
- Profile text is public, so it never gives your exact position, never reads Chronicle notes, and only names other players you've marked as friends in Social Diary (switch that off in settings).
- Optional: pause *Currently* and the glances while you're out of character.

## Install

Copy the `AutoTRP` folder into `World of Warcraft/<your Forever folder>/Interface/AddOns/` and restart the game. Needs **Total RP 3**.

## Commands

| | |
|---|---|
| `/atrp` | settings |
| `/atrp preview` | see what your profile would say, and which fields are Auto TRP's and which are yours |
| `/atrp update` | write it now |
| `/atrp setup` | make a profile for Auto TRP |
| `/atrp use` | let Auto TRP write to the profile you're using now (your existing text stays) |
| `/atrp claim <field\|all>` | hand a field back to Auto TRP |
| `/atrp release <field\|all>` | take a field back |
| `/atrp mood` | how your character feels, and why |
| `/atrp feel <mood>` | choose a mood for the next hour (`/atrp feel` lists them, `/atrp feel clear` lets it go) |
| `/atrp intent <text>` | add what you're up to to Currently for two hours (*"Looking for passage to Theramore."*) |
| `/atrp days` | the mood journal: the last week of feelings and places |
| `/atrp slot <glance> <1-5\|0>` | move a glance (mood, lately, company, ambition, marks) to another slot, or drop it |
| `/atrp restore` | put your profile back as it was before Auto TRP |
| `/atrp badge` | show or hide the mood badge |
| `/atrp on` / `off` | resume or pause |

Fields: `currently`, `title`, `fulltitle`, `nickname`, `motto`, `residence`, `birthplace`, `traits`, `bearing`, `history`, `physical`, `glance_mood`, `glance_lately`, `glance_company`, `glance_ambition`, `glance_marks`, `relationship`, `ooc`.

## For developers

- `lua5.1 tests/run.lua` runs an offline test against a mock of the game, Total RP 3 and sample data from all three addons, and prints the profile it writes.
- `python3 tools/gen_rpgd_names.py /path/to/rpg-dialogue` regenerates `AutoTRP/Data/RPGDNames.lua` (town and story names; RPG Dialogue keeps those inside its private namespace, and its saved data only holds ids).
- All wording lives in `AutoTRP/Data/Words.lua`.
- Writing follows Total RP 3's own pattern (`Core/Player.lua`): set the field, bump the section's version, fire `REGISTER_DATA_UPDATED` so other players fetch the new profile.

MIT licensed. World of Warcraft is a trademark of Blizzard Entertainment; this is a fan-made addon.
