# Crimson level scenery pass

Generated with the built-in image tool; full prompts are beside sources in `assets/crimson-levels/`.

## Implemented

Six generated compact props replace the old scenery atlas across the existing six maps: barrels, guardian statue, stone lantern, rubble, broken altar, bamboo urn. The existing spacing and placement hook remains unchanged. Props are decorative, behind actors, and add no collision. The lantern gently changes brightness; the bamboo urn has a restrained sway around its ground anchor. All six extracted cells are 64×64 with the base aligned at y=62.

`tools/build_crimson_scenery.py` performs only magenta cleanup, crop, nearest-neighbor reduction, and atlas packing. Raw images remain intact.

## Concepts only

`assets/crimson-levels/concepts.png` illustrates six distinct areas: causeway, courtyard, bamboo rampart, rooftop ascent, shrine garden, bell arena. These are visual references, not six new implemented maps. The large stairs, bell structure, background banners and new architecture shown on this board still require separate assets and gameplay work.

## Verification

- Godot import completed.
- `campaign_data.gd` passed stable spawns, exits, enemies, route graph and final captain checks.
- `crimson_scenery_preview.gd` rendered all six variants without runtime errors and checked decorative/background placement.
- Inspected `docs/qa/crimson-scenery.png`. This is a staged screenshot, not a complete playthrough.
