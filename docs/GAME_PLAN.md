# Crimson Monastery

Update: the user requested a full pixel-art direction. `PIXEL_REBUILD.md` and `../VISUAL_DESIGN.md` supersede the smooth-art and old controller notes below. Two encounters now run with textured ledges, moving-platform traversal, pixel UI, layered scrolling and combat effects. The six-level campaign remains a content plan.

## Direction

Godot 4 stable, 2D side-scrolling action platformer, landscape Android and iOS. Start with the Compatibility renderer and test on a modest Android device before adding lighting. Use a 1280×720 logical canvas with aspect expansion and safe-area-aware UI. Confirm the installed editor version before implementation.

Near-black walkable platforms, dark enemies, deep red sky, drifting mist, layered monastery silhouettes, and small ivory lantern lights. Give enemies a visible warm rim and clear weapon trails so their attacks remain readable on black platforms. Traversable edges must have a fine lighter top edge. Color alone must not signal damage or a locked exit.

Use smooth character sprites with bilinear filtering. Equipment icons from Cyber Sausage remain pixel art with nearest filtering inside menu slots. Avoid mixing chunky pixel scenery into the primary smooth combat scene. Existing Japanese pixel environment packs are alternatives for composition/reference or a deliberate future style change.

## Player loop and controls

Walk right, cross platforms, fight enemies, reach the exit shrine. Defeating the required encounters activates the exit platform; standing on it opens a clearly labelled transition prompt. Advance to the next scene after acceptance. Do not trigger transitions merely by passing through during combat.

Left thumb: movement. Right thumb: jump, attack, dodge; hold attack for a heavy strike if the selected animations support it. Keyboard development controls: A/D, Space, J, K. Support simultaneous movement and attack touches. Start with one light attack and dodge before expanding combos.

First playable contract: one monastery approach, one enemy, movement/jump/attack/dodge, damage and death, retry, locked/unlocked exit, and transition into a second test room. Win by clearing the encounter and using the exit. Lose at zero health. Restart at the level entrance with enemies reset. Validate touch input, attack timing, and readability before producing all scenes.

## Proposed campaign

These are design targets, not completed levels. Levels 1–5 remain approachable; level 6 is the hardest. Start with six short levels rather than an unbounded campaign.

| Level | Place | Encounter progression | Art required |
|---|---|---|---|
| 1 | Monastery approach | Isolated guards, generous recovery, learn movement and attack | Red sky, distant monastery, stone ground, torii, lantern |
| 2 | Outer courtyard | Two guards, learn dodge, checkpoint before final encounter | Courtyard walls, banners, steps, shrine exit |
| 3 | Bamboo path | Staggered melee and ranged pressure, safe practice gaps | Bamboo silhouettes, bridge, fog, stone ledges |
| 4 | Monastery rooftops | Mixed enemies, deliberate jumps, limited simultaneous attackers | Roof modules, chimneys, cables, distant roofs |
| 5 | Ruined sanctuary | Elite guard and reinforcements, final preparation | Broken statues, pillars, braziers, ruined altar |
| 6 | Crimson summit | Boss with readable phases and recovery windows | Summit arena, red sun, storm mist, final gate |

Tune difficulty with attack telegraphs, enemy combinations and placement first. Do not simply multiply enemy health. Boss selection and enemy roles remain provisional until the actual pack animation inventory is reviewed. No required grinding, inventory, crafting or live services in the first slice.

## HUD and progression

Top center: level name and campaign progress (for example 2 / 6). Immediately below: health bar plus numeric current/max health. Top right: pause. Temporary encounter objective: “Defeat guards: 1 / 3”; exit changes to “Shrine ready”. Boss health appears only during the boss encounter. Bottom controls stay outside the central combat view and respect phone cutouts. Aim for touch targets at least 48 logical pixels with generous separation; scale against actual device DPI in testing.

Pause, retry, settings, level completion, and campaign completion are the required screens. Provide separate music/SFX volume controls and reduced flash/shake options. Do not embed HUD text into generated background images.

## Moving background

Prepare separate full-width layers: red sky/sun (stationary), mountains (0.08 camera ratio), monastery silhouettes (0.20), bamboo/roof details (0.40), playable geometry (1.0). These are initial tuning values. Add low-cost drifting mist and sparse particles. Use Parallax2D if supported by the chosen Godot version; validate its repeat settings. A flattened concept PNG cannot supply independent layers. Production layers must be exported separately and checked for repeat seams, camera coverage, and overdraw.

## Implementation stages

1. Asset intake: retain ZIPs and original license files; inventory animations, frame sizes, pivots and sound candidates. Complete a visual and listening pass before treating a candidate as final.
2. Create the Godot project and one reusable player/enemy/health/exit implementation. Data-driven levels own enemy placements and objectives; the HUD subscribes to health/progress signals.
3. Complete and test the first playable contract with simple geometry.
4. Replace placeholders with layered environment art; connect combat sounds to actual animation events and confirmed hits.
5. Expand campaign scenes from the level manifest. Reuse collision/platform modules; give each level distinct encounter pacing.
6. Mobile profiling and export: measure frame time, texture memory and touch input; reduce atlas size/overdraw as needed. Configure signing/export templates only for a selected device target.

Acceptance: stable target 60 FPS on an agreed reference phone, no unreadable enemies, no HUD overlap, no missed multi-touch actions, no exit before encounter completion, retry works, progress survives relaunch. These are future acceptance checks, not test results.
