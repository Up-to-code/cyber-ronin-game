# Combat motion, blood effects, and campaign atlas

Implemented 2026-11-12, following the control-spacing, downward movement, combo, blood, enemy-health and world-map request.

## Play controls and behavior

- **J / sword:** four separately drawn cuts. Each additional press buffers one strike; holding still charges rather than infinitely repeating. Hits are 35, 42, 55, and 65 damage. Each strike has its own authored contact phase and a different sweep. Movement remains responsive during attacks.
- **S / DOWN while running on solid ground:** a fast, low knee slide, with an eight-frame drawn action and trailing air. Jump or attack cancels the slide. It does not grant invulnerability.
- **DOWN while standing on a one-way shelf:** drop through that supporting shelf. Collision with the rest of the world stays enabled; temporary exceptions restore afterward.
- **DOWN in the air:** fast-fall, with a 55 ms input grace so DOWN followed by J still starts a plunge. Fall-damage rules still apply.
- **DOWN + J airborne:** plunge, followed by the landing pose.
- **DOWN + L:** low kick with a distinct low pose. Fixed a pre-existing bug that aimed crouching kicks downward and missed the enemy ahead. Authored foot sockets now follow the extended kick instead of the planted ankle.

## Presentation and layout

- Repositioned touch controls into a tighter combat cluster, with additional space between directional targets. Retained invisible touch padding, separate targets, multitouch, handedness, scaling and opacity preferences.
- Replaced the large center chapter label with a small `004 / 100` corner counter. Entry objectives remain accessible in the map/chapter screen rather than appearing over combat.
- Added segmented pixel health meters to every enemy, including bosses, initialized after final health/scaling configuration. Delayed damage fill communicates recent hits.
- Distinct running, sliding, falling and kicking air strokes; actual hits own blood and impact effects.
- Stronger directional blood sprays, short-lived floor stains only at ray-verified floors, six fragments from the defeated actor's actual cel, and generated screen-edge blood decals. Misses do not create blood; scenery impacts now have their own non-blood response.
- Player damage adds camera shake. Nearby deaths add a smaller pulse and edge blood. Overlay ignores input and leaves the center clear. World effects retain the existing 64-node budget; screen blood is capped at 18 decals.

## Campaign atlas

Main menu → **MAPS** opens the illustrated atlas. It contains all 100 level nodes across ten regions, connected route paths, boss crowns every tenth node, and a highlighted unlock frontier. Arrows move between regions; the map also scrolls horizontally and vertically. Select a route, inspect its objective, then press **ENTER**. Locked routes can be inspected but cannot launch. **BACK** returns to the previous menu. Keyboard focus scrolls nodes into view.

This is a map/navigation redesign of the existing 100-level campaign, not 100 new levels or a replacement of its tested platform geometry.

## Generated production assets

Built-in image generation was used. Original generator outputs remain outside the repository; only runtime crops/resizes/atlas packing were added here. Nearest-neighbor resizing preserves the pixel presentation.

- `game/art/campaign-map/world.png`: ten illustrated region landmarks, cropped into the runtime atlas by region. Source: `exec-cee93582-9676-4d7d-820e-aeff9d81bebe.png`.
- `game/art/ronin-v2/sweep-slide.png`: sixteen new drawn cels (eight sweep, eight slide). The slide drawings also support the low-kick variation. Cells normalized to 128×128 with one scale and a consistent opaque foot baseline. Source: `exec-61bc4027-8d33-4c38-9fab-9fca17d4498e.png`.
- `game/art/combat-feedback/blood-edge.png`: four 64×64 pixel splatter variants for screen-edge feedback. Source: `exec-ca28169d-4d76-41e5-9a1b-20f8f1e1114a.png`.

Exact generation prompts are in `docs/COMBAT_MAP_ASSET_PROMPTS.md`. No frame-interpolated FPS claim is made: physics remains 60 Hz, while each drawn action uses its own timed cels.

## Verification

15 targeted regression suites passed: `combat_expansion`, `combat_rules_combo`, `moving_combat`, `kick_states`, `aerial_motion`, `motion_audio_sync`, `effect_budget`, `feedback_separation`, `fire_interception`, `projectile_feedback`, `mobile_ui`, `campaign_navigation`, `death_presentation`, `menu_clean_layout`, `beam_combat`.

Additional `blood_feedback` verifies four decal variants, input transparency, no wall-hit blood, damage-triggered blood/shake, the screen limit, and full cleanup. Touch layout tests cover seven window sizes and both handedness options; map tests cover four aspect/size combinations, every region, locked entry, level 100 entry and return to title.

Native Godot frames were inspected for the map, touch layout, enemy meters, fourth sword cut, slide, kick death and player damage. Captures are temporary QA files, not shipped project content. These are scripted interaction checks and visual samples, not a full human playthrough or an iOS device FPS benchmark.

Rams `quick_review` was attempted with `via: rules` as required by AGENTS.md. It returned `ran: false`: the workspace's 15 review credits are exhausted. No Rams approval is claimed.
