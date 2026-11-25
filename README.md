# Auto TRP

A companion to [RPG Dialogue](https://github.com/Kaiybo/rpg-dialogue) for World of Warcraft: Forever. It keeps your **Total RP 3** profile in step with your character's story: what they feel, where they are, what they believe, who they know and what they've been through.

It reads three addons if you have them (all optional, and it never changes them), and keeps its own record of the quests you turn in, the dungeon and raid masters you bring down and the lands you travel through, so earned names, the road and most statistics work with none of them:

- **RPG Dialogue**: your origin, alignment and traits, opinions you've voiced, standing in towns, the people you've met, the stories you've followed, your diary.
- **Social Diary**: the players you've marked as friends (and the relationship you wrote down for them), your recent groups.
- **Chronicle** (AzerothForge Adventure Chronicle): your goals, bosses brought down, dungeons, rare beasts, professions, deaths, and its equipment and stat snapshots for your appearance. Your private Chronicle notes are never read.

## What it writes

**It reacts as things happen.** Over two dozen game events (changing zone or subzone, resting, leaving combat, a buff or sickness landing, mounting, shapeshifting, your pet, joining a group, the mailbox, bank or crafting table, loot, money, your emotes, a death, a level, a boss, a conversation in RPG Dialogue, new gear, reputation) trigger an update within a couple of seconds. **Currently** and the glances are rewritten whenever they change (at most every 15 seconds), the story within half a minute of something that matters, and anything held back during combat is written the moment it ends.

**It stays light.** Nothing is worked out during combat. The other addons' data is read only when it changes (a glance at a few counters every five seconds), reputations, skills and gear only when the game says they changed, and a burst of events makes one update, not many.

| Total RP 3 field | From |
|---|---|
| **Currently** | Your mood, what you're doing and where, with the zone's atmosphere, your pet and the hour: *"Bone-tired and a little uneasy, beneath the dead trees of Duskwood, with Fang at heel, under the stars."* It notices the mailbox, the bank, the auction house, crafting, fishing and eating. `/atrp intent` adds your plans. |
| **At first glance**, all five | **1 Mood**: what a stranger notices. **2 Lately**: the freshest news (a death, a victory, a story moving, a new land), else who you were last seen with. **3 Company**: your group, your Social Diary friends, where you're known, or travelling alone. **4 Ambition**: your Chronicle goal, an unfinished story, or the next rank on your road. **5 Marks**: wounds, drink, madness, taint, battered or remarkable gear, old scars, else what you wear and carry. |
| **Personality traits** | Plain words: **Good/Evil**, **Lawful/Chaotic**, **Honest/Deceitful** from your RPG Dialogue alignment, and Kind/Cruel, Brave/Cautious, Generous/Greedy, Religious/Skeptical, Outgoing/Reserved, Playful/Serious from your choices. |
| **About: Personality** | The spell or ability you cast most, once it's a habit (*"Reaches for Flash Heal more than any other spell."*). Temperament and conscience (*"Aldric is kind and brave, and keeps to the Light."*), the opinions you've said out loud and the ones you've changed, lies you were caught in, the books you've read, and what you have stories about: *"Has stories about the gold of Elwynn's mines, what's down in the Deadmines..."* |
| **About: History** | Told as a life in five short paragraphs: where you came from (your RPG Dialogue origin in your own words, or your race, class and starting land); the road so far, where you spend your time (*"Spends most of her days in Duskwood."*) and where you live; what you've done, including the deed behind your nickname and motto (*"Saw the gold of Elwynn's mines through to the end. That's how Aldric came to be called "Mine-Warden", and where they picked up the saying "Gold isn't worth a life.""*); your people (friends, rivals, enemies), standing, guild and reputations; and how things stand now, with a line from your diary. Every sentence comes from something the game or the addons recorded. Deaths and kill counts stay out of the prose (see Statistics). |
| **About: Physical** | Three paragraphs: the body (what every one of your race shares, and your build from your stats), what you wear and carry (each item by its own name in its quality colour, and your class's reagents only if they're in your bags), and how you are right now (wounded, haunted, battered gear). |
| **Title** | Your rank by experience, specific to your race, class and faction: a Forsaken rogue rises from Newly Risen to Deathstalker, a dwarf hunter from Novice to Mountaineer, a tauren warrior from Young Brave to Plainsrunner, a troll shaman to Loa-Speaker and Witch Doctor, a night elf priest to Acolyte of Elune, an orc warrior from Grunt to Warlord. |
| **Full title** | Alignment and standing (*Lightsworn, Friend of Goldshire*), else what you are and where from. |
| **Statistics** | Plain counts in Total RP 3's *Additional information* (Characteristics tab): Deaths (*"39, the first to Hogger"*), Lands explored, Days on the road, Dungeons, Named foes felled, Rare beasts, Creatures slain, Jobs done, Wealth (*"Comfortable (312 gold, 40 silver)"*), Crafts, Best standing, Names earned, Most cast spell (*"Flash Heal, 1,240 times"*), Favourite haunt (*"Duskwood, 14 hours"*), Books read. They're listed in this order, after your own entries. One switch turns them all off, and each has its own; switched off, Auto TRP takes down what it wrote. Most have an in-character line in About as well (wealth: *"Comfortable, with enough coin put by not to worry about it."*); deaths don't. Your own custom entries are left alone. |
| **Relationship status** | Married or Taken, if you've named a wife, husband, betrothed or sweetheart in Social Diary. |
| **OOC note** | Off by default: a line saying the profile updates itself. |
| **Nickname, Motto, Icon** | Earned by something your character saw through, never by counts like deaths or books read. Four kinds, highest first: a story finished in RPG Dialogue (each of its fifty stories has its own: *The gold of Elwynn's mines* makes you *Mine-Warden*, with the motto *"Gold isn't worth a life."*), a quest chain finished (from Auto TRP's own record or Chronicle; over forty across both factions, from *Pig-Sticker* to *Taelan's Witness* and the raid attunements), a dungeon or raid master brought down (all thirty-three have their own name and saying: *Dream-Waker* for Mutanus, *Riot-Breaker* for Bazil Thredd, *Thaurissan's Bane*), a bounty collected (*Hogger's Bane*, *"Even a gnoll can be brought to heel."*). Within a kind the greatest deed counts (the hardest master, the longest chain); between equals the first one earned sticks. Every name earned is kept: `/atrp names` lists them, `/atrp name <n>` wears another. A new one is noticed: a line in your own chat, pride, and *"Some have started calling her "Militia-Hand"."* in Lately for a couple of days. The profile icon matches the nickname, else your class crest. History says where the name and the saying came from, and which other names stuck. Until something is earned, there's no nickname or motto. |
| **Residence, Birthplace** | Your inn, your homeland. |

Each one has a switch in the settings.

## Race and class

Your race and class shape almost everything: the rank ladder, how each mood shows on you (a tauren's ears pinned back, a Forsaken's creaking joints, a mage's sparks at the fingertips), what you get up to on the road (a hunter tracking, a shaman listening to the spirits, a warlock gathering reagents best not named), your background when RPG Dialogue has no origin for you, and your ambitions. Places mean something to your race and class (a night elf grieves in corrupted Felwood, a dwarf bristles in Dark Iron land, a Forsaken remembers the ruins of Lordaeron, a paladin finds peace at Light's Hope), and so do your spells and racial abilities (resurrecting a companion, opening a portal, Shadowmeld, Cannibalize, Blood Fury...). A hunter's pet's happiness shows too.

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

## Only what the game backs up

Auto TRP can draw conclusions from what the game records (a kind character from kind choices, a broad build from high strength, "gets by" from your coin against your level), but it never invents what your character did, holds or went through. Mood lines describe a face, a posture or a voice, not an action you weren't doing (no sitting under trees, reading scripture or polishing a helm), and there are no made-up backstories or "the road has made them..." lines.

The profile never describes something your character doesn't have. Gear is named only when it's equipped, and by its own name (*"Wears Crown of the Lost and Robe of the Moccasin"*), never "a hat" or "a holy symbol" from thin air. A mood line that mentions a weapon, helm, shield or pet is used only when you have one, and names the real one (*"Leaning on his Staff of Westfall more than usual"*). Your class's reagents (Soul Shards, totems, Arcane Powder, Sacred Candles...) are mentioned only when they're in your bags, and a coin pouch only when you carry coin (how full it is follows your wealth). How worn your gear looks follows its real durability and names the worst piece (*"Their Robe of the Moccasin shows hard use"*, *"...is broken outright and needs a smith"*). Looks are limited to what every one of your race shares, with nothing you can customise, like beards, hair or skin colour.

## Not too famous

A profile is public, so the character isn't made out to be widely known. Standing is local and modest (*"is liked in Goldshire"*, *"is trusted in Auberdine"*, never "a hero to"), the full title is at most *"Friend of Goldshire"*, reputations read *"Has done good work for Stormwind"*, and rank titles stay clear of offices and patrons (no Thane, Warlord, Magister, SI:7 Agent or Archbishop's Chosen). `tests/banned_phrases.txt` holds the line.

## Your words stay yours

- Auto TRP writes to **one profile**. On first login it offers to make a copy of your current profile called *"Name (Auto TRP)"* and only ever writes there. Switch to another profile and it stops.
- It never writes to Total RP 3's default profile (Total RP 3 doesn't allow it).
- **Switched off means taken down.** Turn off a statistic and Auto TRP removes what it wrote there; turn off a glance and it's hidden (Total RP 3 keeps the text). Other fields simply stop updating. Anything you've edited is left as it is.
- **It never writes over your own words.** If a field already has text it didn't write, or you edit something it wrote, that field becomes yours and it stops touching it. `/atrp claim <field>` hands one back.
- Nothing is written in combat. *Currently* and the glances update at most every 90 seconds; the rest every five minutes or after something that matters.
- **Backup**: before its first write to a profile, Auto TRP keeps a copy of everything it might touch. `/atrp restore` puts the profile back exactly and hands every field back to you.
- Profile text is public, so it never gives your exact position, never reads Chronicle notes, and only names other players you've marked as friends in Social Diary (switch that off in settings).
- Optional: pause *Currently* and the glances while you're out of character.

## Install

Copy the `AutoTRP` folder into `World of Warcraft/<your Forever folder>/Interface/AddOns/` and restart the game. Needs **Total RP 3**.

## Getting at it

- **Settings**: `/atrp`, or Options > AddOns > Auto TRP.
- **The AddOns menu** by the minimap: click Auto TRP for the preview, right-click to pause or resume.
- **Key bindings** (Key Bindings > AddOns > Auto TRP): show the preview, pause or resume, write my profile now.
- **The mood badge** on screen (see above).

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
| `/atrp mood` (or `/atrp why`) | how your character feels, and why |
| `/atrp feel <mood>` | choose a mood for the next hour (`/atrp feel` lists them, `/atrp feel clear` lets it go) |
| `/atrp intent <text>` | add what you're up to to Currently for two hours (*"Looking for passage to Theramore."*) |
| `/atrp days` | the mood journal: the last week of feelings and places |
| `/atrp spells` | the spells and abilities you cast most |
| `/atrp places` | the lands you've been to, and where your time goes |
| `/atrp names` | every name you've earned, what for, and which one you wear |
| `/atrp name <number\|auto>` | wear one of your earned names (`auto`: the greatest deed's) |
| `/atrp slot <glance> <1-5\|0>` | move a glance (mood, lately, company, ambition, marks) to another slot, or drop it |
| `/atrp restore` | put your profile back as it was before Auto TRP |
| `/atrp badge` | show or hide the mood badge |
| `/atrp on` / `off` | resume or pause |

Fields: `currently`, `title`, `fulltitle`, `nickname`, `motto`, `icon`, `residence`, `birthplace`, `traits`, `bearing`, `history`, `physical`, `glance_mood`, `glance_lately`, `glance_company`, `glance_ambition`, `glance_marks`, `relationship`, `ooc`, `stat_deaths`, `stat_lands`, `stat_road`, `stat_dungeons`, `stat_foes`, `stat_rares`, `stat_slain`, `stat_jobs`, `stat_wealth`, `stat_crafts`, `stat_standing`, `stat_names`, `stat_spell`, `stat_haunt`, `stat_books`.

## Language

Auto TRP writes in English. Zones are recognised by their map ID, so zone touches (atmosphere, eerie places, places that matter to your race and class, capitals, flights) work in any game language. City districts, a few subzone places and dungeon descriptions are matched by their English names and are skipped on other languages. Everything else works the same.

## For developers

- `lua5.1 tests/run.lua` runs an offline test against a mock of the game, Total RP 3 and sample data from all three addons, and prints the profile it writes.
- Releasing: bump `## Version` in `AutoTRP/AutoTRP.toc` and add a matching `## <version> (date): Title` section to `CHANGELOG.md` in your pull request. When it merges into `main`, the release workflow tests, builds `AutoTRP-<version>.zip` and publishes the release with that changelog section as its notes. A merge that doesn't change the version releases nothing.
- `TRP.ORDER` (TRP.lua) is the order fields are written in, so new entries land the same way every time; statistics keep the order of `Compose.STATS`, and `tidyStats` gathers Auto TRP's own into one ordered run.
- `AutoTRP/Sources/Travels.lua` is Auto TRP's own record of lands visited (first seen) and time spent in each, merged with RPG Dialogue's lands in `Compose.Lands`; `Compose.Haunt` is where the time goes.
- `AutoTRP/Sources/Deeds.lua` is Auto TRP's own record (quests turned in, masters felled), merged with Chronicle's in `Compose.Finished` and `Compose.Bosses`. Earned-name data (`W.EARNED_STORY`, `W.EARNED_QUEST`, `W.EARNED_BOSS`, `W.EARNED_BOUNTY`) is in `Words.lua`; quest titles and boss names are matched in English.
- `python3 tools/gen_rpgd_names.py /path/to/rpg-dialogue` regenerates `AutoTRP/Data/RPGDNames.lua` (town and story names; RPG Dialogue keeps those inside its private namespace, and its saved data only holds ids).
- All wording lives in `AutoTRP/Data/Words.lua`. Most of it is lists: one line is picked per character (and per hour, event or place), so adding a line adds variety. `W.SAY` holds the ways the glances and About phrase the facts they report. After `{they}`, write verb endings as `{s}`, `{es}` or `{ies}` (`{they} walk{s}`, `{they} carr{ies}`) so lines read right with he, she or they.
- `tests/unbacked_nouns.txt` lists things (hats, candles, beards, scars...) the look and mood word lists may not name outright. Gear goes through tags (`{head}`, `{mainhand}`, `{shield}`, `{pet}`...) that name the real item and drop the line when it isn't there (`U.Backed`).
- `tests/banned_phrases.txt` lists phrases Auto TRP must never write (stock AI phrasing and old tics), plus a few allowed only a handful of times. The offline test fails if the wording or a written profile uses one.
- About text uses Total RP 3's markup for colour (`{col:rrggbb}...{/col}`): quotes in a pale cream, items in their quality colour. The "Colour quotes and item names" setting turns it off.
- Writing follows Total RP 3's own pattern (`Core/Player.lua`): set the field, bump the section's version, fire `REGISTER_DATA_UPDATED` so other players fetch the new profile.

MIT licensed. World of Warcraft is a trademark of Blizzard Entertainment; this is a fan-made addon.
