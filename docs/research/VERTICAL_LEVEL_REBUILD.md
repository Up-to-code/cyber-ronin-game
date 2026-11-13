# Vertical route rebuild — November12,2026

## References actually consulted

- [The Messenger, official screenshots](https://themessengergame.com/): inspected the Bamboo Creek and Glacial Peak screenshots. The observed surfaces occupy several heights, with structural supports, clear landing silhouettes and contrasting background depth. Our application: layered terraces, hanging balconies and supported arches. This is visual analysis, not a claim that those images prove pacing or fun.
- [Blasphemous, official publisher description](https://www.team17.com/games/blasphemous): explicitly describes a non-linear world, shortcuts and hubs. Our application is narrower: optional upper reward branches and lower recovery routes within the existing stage progression; no interconnected Metroidvania world is claimed.
- [Sébastien Bénard, The Level Design of Dead Cells](https://deepnight.net/tutorial/the-level-design-of-dead-cells-a-hybrid-approach/): authored rooms have specific purposes and placement constraints; enemy density and type respond to room space. Our application: separate traversal ledges from wide encounter terraces, with named branch connections tested physically.
- [SEGA, SHINOBI: Art of Vengeance](https://asia.sega.com/shinobi-art-of-vengeance/en/): official stage/platforming/hidden-secret reference. Art style is hand-drawn, so it is a structure/action reference rather than a pixel-art style target. No full gameplay video was watched for this pass.

## Applied changes

Reauthored the ten route families feeding100 levels. Most main paths now have eight transitions, multiple rises and drops, three combat terraces, upper reward branches, and a separate recovery ledge where an initial upward gap benefits from it. Descending openings use their next main landing as the safe catch. Boss arenas have three one-way balconies80/160 pixels above the ground. The primary route remains playable with one jump; double jump remains recovery/expressive movement.

New generated pixel assets: stone arches with open space beneath, rooted rock ledges, hanging balconies, carved buttresses, and a dark irregular masonry wall texture. Platform collision top stays aligned with its art surface; hanging platforms can be jumped through from below. Shaft walls are recessed decorative backing, not newly added collision barriers. Existing sky and distant skyline art remain.

Added the Ash Tengu: generated walk, anticipation, sickle strike, hurt and death artwork, faster approach, lower mass, a short melee windup and crimson slash feedback. The campaign now contains540 enemy placements across100 levels, including the ten existing boss milestones. This does not mean540 distinct monster species.

The beam's three-target piercing and warning mechanics remain. Its visible endpoint now stays at the last hit rather than continuing as an empty screen-wide bar. The body is a tapered broken pixel ribbon with drifting embers and a generated flame tip; the muzzle begins farther forward. Walls still stop collision and the visual beam.

## Verification and limits

- All100 maps: support/bounds/connectivity and next-primary-landing visibility checks. Camera targets and framing also pass for upper branches and recovery ledges.
- 780 primary transitions plus310 optional branch/recovery transitions tested with the actual controller and collisions, injected takeoff positions, isolated from enemies, at fixed60Hz.
- All100 runtime loads, boss milestones, mission counts and upgrade state.
- Beam warning, damage, piercing, wall blocking and evasion tests.
- Generated monster profiles and attack events; native rendered terraces, shafts and boss arenas inspected.

This is still a template-derived campaign. It is not100 individually authored worlds, and a traversal pass is not full combat balance approval. Existing enemies and bosses still share some artwork. There are no newly implemented climbable ladders, wall jumps or moving stair mechanisms in this pass.

## Rebuild order

`python3 scripts/author_vertical_routes.py`
`python3 scripts/build_campaign.py`

The first script authors base route families; the second applies chapter variations and encounter/reward rules. Both are deterministic and safe to rerun without accumulating enemies.
