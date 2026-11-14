> Current architecture, routes and enemy placements are documented in [Vertical Level Rebuild](research/VERTICAL_LEVEL_REBUILD.md). The notes below describe the preceding campaign expansion.

# Ashen Veil: 100-level campaign

## Implemented

100 deterministic level records, grouped into ten chapters. These reuse and vary ten tested traversal templates; they are not 100 independently painted environments. The build script applies modest horizontal scaling, vertical offsets, chapter encounter variations and explicit mission/reward placement. The JSON is the runtime source of truth. Edit `game/data/route_templates.json` or `scripts/build_campaign.py`, then run the script to rebuild.

468 enemies are distributed across these levels, with only the current level loaded. Ten major bosses appear exclusively on10,20,…,100. Each has a name, visible HP, larger scale, increasing health (340→970), and a configured archetype/skill. Existing character art is reused for bosses; this is not ten new boss sprite sheets. Regular enemy health increases by chapter with a bounded within-chapter increase. Narrow landing shelves remain clear of added reinforcements.

Missions:
- Purge: clear the patrols.
- Seals: collect three visible talismans and clear patrols.
- Hunt: kill the marked captain; other patrols are optional.
- Boss: defeat the major guardian; arena guards are optional.

The gate stays locked until the actual mission conditions are met. Retry resets the encounter and unbanked rewards.

## Rewards and skills

Generated pixel-art coins, healing flasks and seals are physical pickups. Coins award once on contact, not automatically on a kill. Every defeated enemy drops coins; every third remaining enemy and marked targets also drop healing. Drops are placed on the nearest supported surface. Full-health players leave healing available; healing clamps to maximum health. Coins bank to the existing settings save only when passing a completed gate. There is no shop in this pass.

Levels20 onward upgrade the existing X/G or mobile energy action to a piercing beam, costing45 power instead of35. It hits up to three enemies once and stops at walls. Enemy lasers show a locked dotted aim line for0.65s, can be avoided by leaving that line, and cancel if the owner dies or is interrupted before firing. Bosses from30 onward alternate beam and ground-wave patterns; other archetypes retain their fan, fire or melee skills. Existing active sword/fire interception is preserved.

Moving attacks and fast airborne movement emit short character echoes at most ten times per second. No movement lock is introduced. Projectile animation frames are shared; projectiles are capped at48, FX spawning reserves space within its existing64-child budget. Physics remains60Hz. No physical-phone FPS guarantee or new unique animation-frame count is implied.

## Verification

- All100 routes: support, bounds, distinct geometry, conservative connectivity and next-landing visibility.
- 570 real controller jump/landing transitions with injected settled starts, enemies removed, and a fixed60Hz simulation without wall-clock synchronization. This is traversal verification, not a full combat playthrough.
- All100 runtime loads: grounded spawns, correct pickups/mission counts, exactly ten bosses, rising boss health, player laser unlock and HUD progress.
- Physical coin/seal/health collection, one-time rewards, health cap, save checkpoint, hunt and seal gates.
- Beam warning, once-only damage, three-target piercing, wall blocking, enemy warning and evasion.
- Movement attack, sword/fire interception, existing monster attack events, portal passage and mobile control tests.
- Native rendered chapter10 menu, levels20/100 and beam contact inspected. Chapter menu uses ten routes per page with scrolling and previous/next navigation.

Rams quick_review was requested with via=rules. It did not run because the workspace's15 review credits are exhausted. No Rams approval is claimed.

## Next improvements, in order

1. Play chapters1–2 and record deaths, healing usage and missed jumps; adjust pressure from those observations.
2. Replace reused boss art with distinct silhouettes and additional anticipation/recovery cels.
3. Finish supported shaft walls and richer lower-platform architecture.
4. Profile combat on an actual phone before changing particle and projectile budgets.
5. Add coin purchases only after reward income and difficulty have been measured.
