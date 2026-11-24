# Auto TRP

A companion to [RPG Dialogue](https://github.com/Kaiybo/rpg-dialogue) for World of Warcraft: Forever. It keeps your **Total RP 3** profile in step with your character's story: what they feel, where they are, what they believe, who they know and what they've been through.

It reads three addons if you have them (all optional, and it never changes them):

- **RPG Dialogue**: your origin, alignment and traits, opinions you've voiced, standing in towns, the people you've met, the stories you've followed, your diary.
- **Social Diary**: the players you've marked as friends (and the relationship you wrote down for them), your recent groups.
- **Chronicle** (AzerothForge Adventure Chronicle): your goals, bosses brought down, dungeons, rare beasts, professions, deaths, and its equipment and stat snapshots for your appearance. Your private Chronicle notes are never read.

## What it writes

Everything updates on its own while you play: **Currently** and the glances at most every 90 seconds (sooner after something happens), the rest every five minutes or right after a level, a death or a boss.

| Total RP 3 field | From |
|---|---|
| **Currently** | Your mood, what you're doing and where, with the zone's atmosphere, your pet and the hour: *"Bone-tired and a little uneasy, beneath the dead trees of Duskwood, with Fang at heel, under the stars."* It notices the mailbox, the bank, the auction house, crafting, fishing and eating. `/atrp intent` adds your plans. |
| **At first glance**, all five | **1 Mood**: what a stranger notices. **2 Lately**: the freshest news (a death, a victory, a story moving, a new land), else who you were last seen with. **3 Company**: your group, your Social Diary friends, where you're known, or travelling alone. **4 Ambition**: your Chronicle goal, an unfinished story, or what your class strives for. **5 Marks**: wounds, drink, madness, taint, battered or remarkable gear, old scars, else what you wear and carry. |
| **Personality traits** | Plain words: **Good/Evil**, **Lawful/Chaotic**, **Honest/Deceitful** from your RPG Dialogue alignment, and Kind/Cruel, Brave/Cautious, Generous/Greedy, Religious/Skeptical, Outgoing/Reserved, Playful/Serious from your choices. |
| **About: Personality** | Temperament, a plain *"By most accounts: good and lawful"*, and the opinions you've said out loud. |
| **About: History** | Your origin in your own words, the lands and dungeons you've seen, your usual inn, friends and rivals, where you're liked or distrusted, who you ride with, deeds, crafts, books you've read, close calls, and a line from your diary. |
| **About: Physical** | Your build (from your strongest attribute), what you wear and carry, the finest thing on you (live, or from Chronicle's equipment snapshot), and your scars. |
| **Title** | Your rank by experience, per class: a priest goes Acolyte, Initiate, Deacon, Priest, Confessor... a warrior Recruit, Militiaman, Soldier... |
| **Full title** | Alignment and standing (*Lightsworn, Friend of Goldshire*), else what you are and where from. |
| **Nickname, Motto, Residence, Birthplace** | An epithet you've earned (*the Far-Walker*, *Grave-Cheater*, *the Bookish*), a motto that fits your temperament, your inn, your homeland. |

Each one has a switch in the settings.

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

## Your words stay yours

- Auto TRP writes to **one profile**. On first login it offers to make a copy of your current profile called *"Name (Auto TRP)"* and only ever writes there. Switch to another profile and it stops.
- It never writes to Total RP 3's default profile (Total RP 3 doesn't allow it).
- **It never writes over your own words.** If a field already has text it didn't write, or you edit something it wrote, that field becomes yours and it stops touching it. `/atrp claim <field>` hands one back.
- Nothing is written in combat. *Currently* and the glances update at most every 90 seconds; the rest every five minutes or after something that matters.
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
| `/atrp on` / `off` | resume or pause |

Fields: `currently`, `title`, `fulltitle`, `nickname`, `motto`, `residence`, `birthplace`, `traits`, `bearing`, `history`, `physical`, `glance_mood`, `glance_lately`, `glance_company`, `glance_ambition`, `glance_marks`.

## For developers

- `lua5.1 tests/run.lua` runs an offline test against a mock of the game, Total RP 3 and sample data from all three addons, and prints the profile it writes.
- `python3 tools/gen_rpgd_names.py /path/to/rpg-dialogue` regenerates `AutoTRP/Data/RPGDNames.lua` (town and story names; RPG Dialogue keeps those inside its private namespace, and its saved data only holds ids).
- All wording lives in `AutoTRP/Data/Words.lua`.
- Writing follows Total RP 3's own pattern (`Core/Player.lua`): set the field, bump the section's version, fire `REGISTER_DATA_UPDATED` so other players fetch the new profile.

MIT licensed. World of Warcraft is a trademark of Blizzard Entertainment; this is a fan-made addon.
