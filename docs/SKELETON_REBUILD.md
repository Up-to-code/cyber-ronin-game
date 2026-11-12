# Skeleton and world rebuild

The visible player and enemies now use `game/rig/rig_visual.gd`: a real Skeleton2D hierarchy, 17 bones, textured pixel polygon pieces, analytic two-link limb IK, named hand/foot/chest/weapon sockets, connected body poses and body-center impact roll. Legacy whole-body sprite clips are hidden and retained as compatibility metadata; they no longer render the character or drive footstep timing. Footstep audio follows rig contact events.

This is a reusable skeleton/cutout renderer, not a soft weighted skin or anatomical ragdoll. All actors retain a capsule collision body. It is appropriate for this pixel-art prototype and supports replacing named art parts without redrawing every motion clip. A random whole-body image cannot automatically become a working anatomical mesh: export the parts atlas and its rectangles/pivots using the documented contract.

## Shared mechanics

`game/systems/world_rules.gd` reads `game/data/physics.json`. World +Y points down; the default scale is 180 pixels/metre and gravity is 1765.8 pixels/second² (9.81m/s²). Jump launch is `−sqrt(2gh)` for the configured height; falling integrates `v += g·dt`. Jump-release cuts and the extra airborne jump are explicit game-control rules. Gravity always pulls downward. Moving-platform carry uses Godot's CharacterBody2D/AnimatableBody2D collision support.

An impact applies `Δv = J / m`, converted from metres to world pixels. Rotation uses the contact lever arm about the torso center: `Δω = (r × J) / I`, with the simplified upright-rod inertia `I = m·L²/12`. Spin limits keep the character readable. A kick moves the actual enemy body upward/sideways; the skeleton bends and rotates around its hip as gravity brings the body down. At floor contact, rotation settles and limbs return to stance. Central impacts produce no torque; opposite contact lever arms reverse spin. This is a controlled gameplay approximation, not a human biomechanics simulation.

Root physics and visual IK are separate. Body position owns collision; bones own skin motion and effect sockets. Airborne launch, recoil, kick wind-up/extension/recovery, feet contact, turn/movement blend and clothing overlap share one rig. Character profiles supply lengths, widths, atlas regions, pivots and tint. Player collision height follows profile proportions. Use `--character=res://data/characters/your_profile.json` or set the player's exported `character_profile`; restart after replacing the global physics JSON. [Rig contract](rig_runtime.md) · [Workshop usage](CHARACTER_WORKSHOP.md).

## Combat and world

- Ground guards use sword pursuit, telegraph, contact and recovery.
- Ember enemies kick a three-projectile fire fan after a wind-up.
- Wraiths use a distinct flame-mask/cloth profile with hidden legs and intentional hover control. Hover is an explicit supernatural movement mode; ground enemies only leave the floor when jumping, falling or launched.
- Ranged (I / the RANGED button) spends 25 power and launches a 40-damage sword wave. Swept ray collision stops it at terrain or the first target; it expires after its range. Jumping lets the player aim the horizontal wave at higher enemies.
- UP on the left directional cross jumps; tap again for double jump. DOWN crouches and lowers the collider. The right cluster has a wider central Sword control surrounded by Kick, Power and Ranged. A separate right-hand Jump and RUN are removed. Spawn points were moved clear of the left pad.
- Air jump has a broader independent ring/dust burst at the feet, while hand and kick effects use the rig's actual sockets. Dash echoes snapshot the visible bone meshes rather than the hidden sprite sheet.
- Platforms use black non-tiled foundations with a separate generated earth/moss surface and sparse roots. Static ground extends below the view with matching collision depth; only optional ledges and moving bridges remain suspended. The tall repeated brick texture is removed. Existing red sky/cloud/castle/bamboo parallax continues moving independently of the foreground.

## Audio sources

Normal swing cloth, kick cloth, footstep variations, confirmed body impacts and ordinary landing use Kenney RPG Audio / Impact Sounds samples. Cloth/contact variants alternate; heavier supernatural charge/release layers remain original synthesis. Foot contact and actual strike/hit events own playback. No contact sound is fired merely because an attack misses. The limiter remains active, and charge audio cancels on release, damage, dash or pause.

Original source pages: [RPG Audio (CC0)](https://kenney.nl/assets/rpg-audio), [Impact Sounds (CC0)](https://kenney.nl/assets/impact-sounds). The creator's direct ZIP links returned HTTP403 in this environment; selected files and matching pack licenses were retrieved from the public [asset mirror](https://github.com/GeorgeQLe/assets-sfx-combat). Runtime selections are in game/audio/foley; pack licenses are in game/licenses, with source copies in assets/audio/kenney. Composer music and its required credit remain unchanged.

## Validation and limits

Godot import, all script parsers and native smoke pass. Structural resource inventory reports no missing files; the shared skill QA regex falsely truncates the valid `.gdshader` suffix and reports `dash_echo.gd`, so the exact-path checker and actual engine load are used to resolve that scanner finding. No dummy resource was added.

`rig_geometry`: real bone/mesh hierarchy, fixed link lengths/reach, stance contact, kick extension, body-center roll and profile swaps. `body_physics`: configured jump height, mass-scaled impulse, torque symmetry, kick launch/tumble/landing, crouch collider, ranged power cost, fire fan, hover and swept projectile hits. Existing platforming, moving carry, campaign routes, dash and touch/menu checks were rerun. Native audio output is non-silent and remains below clipping; this does not establish human preference or physical-phone speaker quality.

`docs/qa/skeleton-body-rebuild.mp4` is scripted gameplay for review: the first guard has raised health to show successive reactions, player damage is disabled, and later scenes begin from injected approach positions to show fire and floating enemies. Controls are hidden in the final monster shot so the silhouette can be inspected. This is not a complete campaign playthrough or physical-device ergonomics test. Rams quick_review via=rules was requested after UI/workshop edits; exhausted workspace credits prevented that review.

New bones and named weapon sockets provide the attachment point for later tools. Replacing the weapon art is supported through profile parts; new weapon rules, attack ranges and an equipment inventory would be additional gameplay work.
