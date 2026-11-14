# Crimson-scarf ronin replacement

Built-in imagegen created a 64-pose whole-character sheet: eight rows for ready idle, run, forward cut, reverse cut, kick, jump, heavy cut, damage/death. Prompt locked a screen-right slim adult ronin, charcoal armour, crimson scarf, straw hat, pale katana, consistent weapon hand, 8 × 8 cells, transparent background, no painted VFX. Source preserved under assets/characters/ronin-v2/generated-sheet.png.

Deterministic processing only: equal-cell splitting, alpha threshold, one shared 80px cell scale, foot-baseline alignment, packing into 128px cells. No generated intermediate poses from transformations. Active art: game/art/ronin-v2/actions.png. All player clips use the new sheet. Secondary states reuse related poses. Old artwork remains archived for rollback but is not referenced by the active character profile.

Idle now has eight drawn poses with breathing/scarf motion. Walk/run use eight poses instead of the old source's 21 entries; this pass prioritizes consistent new art, not a claim of 60 distinct drawings per second. Simulation remains 60Hz. Contact frames are mapped to new strike extensions. Default sockets remain approximate and need per-pose authoring for finer weapon-tip precision.
