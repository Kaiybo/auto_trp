# Auto TRP

A companion to [RPG Dialogue](https://github.com/Kaiybo/rpg-dialogue) for World of Warcraft: Forever. It keeps your **Total RP 3** profile in step with your character's story: what they feel, where they are, what they believe, who they know and what they've been through.

It reads three addons if you have them (all optional, and it never changes them):

- **RPG Dialogue**: your origin, alignment and traits, opinions you've voiced, standing in towns, the people you've met, the stories you've followed, your diary.
- **Social Diary**: the players you've marked as friends (and the relationship you wrote down for them), your recent groups.
- **Chronicle** (AzerothForge Adventure Chronicle): your open goals, bosses brought down, professions and deaths. Your private Chronicle notes are never read.

## What it writes

| Total RP 3 field | From |
|---|---|
| **Currently** | Your mood, what you're doing and where: *"Bone-tired and a little uneasy, on the road around Raven Hill, Duskwood under the stars."* |
| **At first glance** (slots 1-3) | **Mood**: what a stranger would notice. **Lately**: the freshest thing that happened (a death, a victory, a story moving, a new land, or your Chronicle goal). **Company**: who you travel with, or where you're known. |
| **Personality traits** | Light/Shadow, Lawful/Free-Spirited, Honest/Silver-Tongued from your RPG Dialogue alignment, and bars like Kind/Cruel or Brave/Cautious from your choices. |
| **About: Personality** | A short read on your temperament and the opinions you've said out loud. |
| **About: History** | Your origin in your own words, the roads you've walked, friends and rivals, where you're liked or distrusted, deeds, close calls, and a line from your diary. |
| **Title / Full title** | Your alignment title (*Lightsworn*) and your best standing (*Friend of Goldshire*). |
| **Nickname, Motto, Residence, Birthplace** | An epithet you've earned (*the Far-Walker*), a motto that fits your temperament, your hearthstone, your homeland. |
| **About: Physical** | Off by default; your looks are yours. |

Each one has a switch in the settings.

## How your character feels

Auto TRP keeps a handful of emotions that events push up and time lets fade: **shaken** after a death, **rattled** after a close fight, **elated** at a new level, **triumphant** after a boss, **wide-eyed** in a new land, **glad to be home**, **talkative** after a run of conversations, **intrigued** when a story moves. Others follow the moment: **at ease** in an inn, **on guard** in a dungeon, **uneasy** in Duskwood at night, **road-weary** after hours away from rest, **merry** after a few drinks, **haunted** when RPG Dialogue's madness takes hold. Your RPG Dialogue temperament bends it (brave characters shake less, curious ones wonder more), and when nothing stands out it shows your temperament instead (*Warm*, *Composed*, *Wry*...).

`/atrp mood` shows how your character feels and why.

## Your words stay yours

- Auto TRP writes to **one profile**. On first login it offers to make a copy of your current profile called *"Name (Auto TRP)"* and only ever writes there. Switch to another profile and it stops.
- It never writes to Total RP 3's default profile (Total RP 3 doesn't allow it).
- **It never writes over your own words.** If a field already has text it didn't write, or you edit something it wrote, that field becomes yours and it stops touching it. `/atrp claim <field>` hands one back.
- Nothing is written in combat. *Currently* and the glances update at most every 90 seconds; the rest every five minutes or after something that matters.
- Profile text is public, so it never gives your exact position, never reads Chronicle notes, and only names other players you've marked as friends in Social Diary (switch that off in settings).

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
| `/atrp mood` | how your character feels |
| `/atrp on` / `off` | resume or pause |

Fields: `currently`, `title`, `fulltitle`, `nickname`, `motto`, `residence`, `birthplace`, `traits`, `bearing`, `history`, `physical`, `glance_mood`, `glance_lately`, `glance_company`.

## For developers

- `lua5.1 tests/run.lua` runs an offline test against a mock of the game, Total RP 3 and sample data from all three addons, and prints the profile it writes.
- `python3 tools/gen_rpgd_names.py /path/to/rpg-dialogue` regenerates `AutoTRP/Data/RPGDNames.lua` (town and story names; RPG Dialogue keeps those inside its private namespace, and its saved data only holds ids).
- All wording lives in `AutoTRP/Data/Words.lua`.
- Writing follows Total RP 3's own pattern (`Core/Player.lua`): set the field, bump the section's version, fire `REGISTER_DATA_UPDATED` so other players fetch the new profile.

MIT licensed. World of Warcraft is a trademark of Blizzard Entertainment; this is a fan-made addon.
