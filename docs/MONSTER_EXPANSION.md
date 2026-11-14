# Lantern Revenant and Obsidian Oni

Generated pixel artwork is in `game/art/monster-expansion/monsters.png`; source is alongside it. Built-in image generation produced the artwork; Pillow only sliced and resized its 4x4 grid using nearest-neighbor sampling. Two profiles use four locomotion cels, anticipation/strike poses, and distinct hurt/death poses. These are sparse authored poses, not 60 unique drawings per second.

Lantern Revenant inherits floating navigation, with 110 base health plus level bonus, 14 projectile damage, a 0.65-second windup and three aimed fire projectiles. Obsidian Oni inherits heavy ground navigation, with 180 base health plus bonus, mass145, 28 melee damage, a 0.8-second windup, a ground-impact effect and two outward fire projectiles. Shared fire interception still applies. Existing VFX are combined with the generated attack arcs; no new VFX atlas is claimed.

The campaign now contains45 enemies. Several existing encounters use these new variants; one additional revenant joins a broad rooftop combat deck. Bosses remain on5 and10. Native profile, attack count, effect event and health tests pass, along with campaign data and ten-level runtime checks. Full encounter balance and animation quality still need playtesting.
