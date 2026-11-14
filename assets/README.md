# Asset catalog

Source artwork is grouped by purpose. Runtime-ready sprites, animations, and effects live in [`game/art/`](../game/art/); runtime sounds live in [`game/audio/`](../game/audio/). Keep those runtime paths stable.

| Folder | Contents |
| --- | --- |
| [characters/](characters/) | Hero artwork, animation poses, and rig parts. |
| [enemies/](enemies/) | Enemy rosters, movement poses, attacks, and spearmen. |
| [vfx/](vfx/) | Magic and visual effect source artwork. |
| [environments/](environments/) | World scenery, terrain, castles, and environment concepts. |
| [levels/](levels/) | Level layouts and shaft/descent artwork. |
| [art/](art/) | Pixel artwork passes, UI kits, buttons, icons, and redraw sources. |
| [audio/](audio/) | Source sound effects and candidate recordings. |
| [concept-art/](concept-art/) | Exploratory concept artwork. |
| [archive/](archive/) | Retained artwork from completed or superseded passes. |
| [realm-relics/](realm-relics/) | Realm relic source artwork. |
| [source/](source/) | Original imported packs; some files are local or restricted. |

## Collections

### characters

- [cyber_ronin/](characters/cyber_ronin/)
- [rig/](characters/rig/)
- [ronin-v2/](characters/ronin-v2/)

### enemies

- [crimson-wraith/](enemies/crimson-wraith/)
- [monster-migration/](enemies/monster-migration/)
- [monster-motion/](enemies/monster-motion/)
- [monster-roster/](enemies/monster-roster/)
- [spearmen/](enemies/spearmen/)

### vfx

- [crimson-magic/](vfx/crimson-magic/)

### environments

- [concepts/](environments/concepts/)
- [crimson-gate/](environments/crimson-gate/)
- [living-marsh/](environments/living-marsh/)
- [tidal-castle/](environments/tidal-castle/)
- [world-migration/](environments/world-migration/)

### levels

- [crimson-levels/](levels/crimson-levels/)
- [crimson-shaft/](levels/crimson-shaft/)
- [descending-levels/](levels/descending-levels/)

### art

- [pixel/](art/pixel/)

### audio

- [attack-candidates/](audio/attack-candidates/)
- [ground-candidates/](audio/ground-candidates/)
- [hove/](audio/hove/)
- [kenney/](audio/kenney/)
- [tk-samurai/](audio/tk-samurai/)
- [vd-swords/](audio/vd-swords/)

### concept-art

- [concept-pass/](concept-art/concept-pass/)

### archive

- [armory-review/](archive/armory-review/)
- [crimson-gold/](archive/crimson-gold/)
- [pixel-redesign/](archive/pixel-redesign/)

### realm-relics

- [source/](realm-relics/source/)

## Adding assets

- Put new source artwork in the matching category, grouped by character, effect, or art pass.
- Keep related poses, animation frames, prompts, manifests, and licenses together.
- Export game-ready resources to `game/art/` or `game/audio/` and update their runtime references.
- Preserve original licenses and attribution. Ignored local source packs remain local.
- Update scripts and documentation whenever a source collection moves.
