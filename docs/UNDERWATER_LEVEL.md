# Level 8 — The Drowned Palace

Walk off the western pier, swim through the flooded castle, recover three pearls from separate chambers, steer through the whirlpool currents, and rise to the dry eastern gate. Killing every sea creature is optional. The gate requires all pearls and a return to air.

Controls: A/D steer horizontally; W/up or Space rises; S/down dives; J performs a reversible three-hit swimming sword chain; I fires an aimed water pulse for18 power. Directional input aims attacks vertically and diagonally. Sun/fire power actions do not activate underwater or consume the earned sun relic. Existing land controls resume when leaving water.

Swimming has acceleration, drag, mild buoyancy and bounded currents. The current maximum is140 versus175 player swim speed, so the whirlpools remain escapable. Entering/leaving water cancels stale attacks and resets posture. The swim presentation reuses authored airborne poses with torso pitch and paddle timing; it is not a newly painted swim animation set.

Aquatic encounters use floorless movement and water attacks: jellyfish radial pulses, committed eel charges, and crab claw sequences. Their art comes from existing distinct monster bodies. Water projectiles use swept collision. Fire spawned inside water is suppressed; fire crossing the boundary extinguishes.

New original generated background and props are retained in assets/environments/tidal-castle/source with prompts. The underwater background, coral, kelp, pearl shell and masonry are integrated into the native game. Bubbles and whirlpool strokes have fixed budgets. HUD objective wording changes to PEARLS.

Validation:
- Underwater data test validates chamber geometry and swept body clearance.
- Continuous native-physics route test walks off the pier, reaches every swim waypoint with currents enabled, collects all3 pearls, surfaces onto dry ground, and verifies retry/land reset. Enemies are removed only for this traversal isolation.
- Swimming controller and aquatic enemy regressions pass, as do existing moving-sword and100 monster contract tests.
- Water projectile test drives the actual ranged input, confirms damage to an aquatic actor, and checks incoming fire extinction.
- Native screenshots inspected in docs/qa/underwater-0.png through underwater-2.png.

The requested Rams rules review was attempted after the HUD text change. The tool schema has no via field; rules was supplied in context. Rams returned ran:false because workspace review credits are exhausted, so there were no findings to apply. The HUD label was checked in a native screenshot.
