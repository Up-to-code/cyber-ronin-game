# Research-backed campaign redesign — 2026-11-12

## Sources actually consulted

- Itay Keren, Scroll Back, GDC2015 slides: https://media.gdcvault.com/gdc2015/presentations/Keren_Itay_ScrollBack.pdf — camera design balances attention, interaction and comfort; gives vocabulary for framing, windows and smoothing.
- Cornell CS4152, Level Design lecture: https://www.cs.cornell.edu/courses/cs4152/2019sp/lectures/14-LevelDesign.pdf — geography, player capabilities, challenge relationships and progression must be designed together; storyboard player actions.
- Unity, Level Design Basics: https://unity.com/blog/level-design-basics — visual guidance through landmarks, light, color and repeated environmental cues.
- Chris McEntee, Rayman Legends GDC session overview: https://www.gdcvault.com/play/1021191/Rayman-Legends-The-Design-Process — source for the value of iterative prototyping tools. Read the overview; did not watch the full talk.

- Maddy Thorson, Celeste & Forgiveness: https://www.mattmakesgames.com/articles/celeste_and_forgiveness/index.html — explains coyote time, jump buffering, apex adjustment and other small player-favoring timing allowances. Existing jump buffering/coyote behavior is retained; this redesign does not claim all Celeste techniques are implemented.
- Godot CharacterBody2D reference: https://docs.godotengine.org/en/4.5/classes/class_characterbody2d.html — movement and floor-snap API reference, version4.5; installed engine is4.7.2 so local runtime tests remain authoritative.

## Application to this game (our design decisions, not quoted rules)

The previous campaign layered several resizing/relocation passes over old geometry. Replaced that with explicit authored sections in game/data/routes.json. Every platform now has a beat describing its job. No automatic platform widening or enemy relocation runs after loading.

Each route begins with safe movement, introduces a traversal/encounter, offers recovery space, and combines skills later. Main upward steps are at most80 pixels against a110-pixel jump apex. Most gaps are50–70 pixels; landing platforms are320 pixels or wider. Combat decks are560–1100 pixels. First threats are separated from spawn; caster and heavy encounters use broad floors. Boss arenas retain dedicated space on routes5 and10.

1. Approach: movement, first rise, single guard, descent, spaced duels.
2. Courtyard: climb, isolated fire keeper, recovery drop, fire plus blade, gate climb.
3. Ramparts: bridge, lancer lesson, recovery, floating threat, mixed reach.
4. Rooftops: three-step ascent, roof duel, two-stage descent, ranged roof.
5. Sanctuary: sentinel lesson, short ascent, spirit landing, recovery, boss arena.
6. Keep: raised caster terrace, descent, heavy plus blade, spirit gate.
7. Cistern: alternating shelf descent with140-pixel drops and a final crossing.
8. Bell Shaft: stair descent, broad basin fight, stair ascent, upper spirit.
9. Aqueduct: rise, lancer pier, descent, fire crossing, recovery climb, impostor pier.
10. Throne: stairs, last guardians, quiet approach, broad final boss arena.

## Verification boundaries

Static route support and jump graph checks; landing visibility within the game's640×360 internal viewport; real controller transition checks starting from injected settled takeoff positions. These do not constitute a full combat playthrough or prove final pacing/fun. Existing generated art is reused; the reference concepts' full architecture remains unfinished. Next: physical-phone playtesting, supported shaft walls, and tuning enemy pressure from observed attempts.

## Observed results

- All 57 adjacent route transitions passed using the real controller and collision surfaces, with injected takeoff positions and braking based on air friction. Enemies were removed for this isolated traversal check.
- All ten maps load, spawn on ground, retain bosses on5/10, and pass player-hit camera-shake checks. Campaign integration also passes load/unload state, enemy grounding, camera bounds after zoom settling, and representative rising jumps.
- Static route graph/support and next-landing visibility checks pass for all ten maps.
- Deep shaft survival/camera tracking and Bell Shaft walking descent pass.
- Native rendered frames inspected on routes4,7,8,10 show the current and next landing together. Existing black foundation fills and incomplete shaft walls remain visible art limitations.

## How the mechanism constrains layout

Gravity is1765.8 world pixels/s²; the configured jump height is110px. `WorldRules.jump_velocity()` uses −sqrt(2gh), about−623px/s. The ideal ballistic time back to the same height is about0.706s, before controller adjustments. A platform rising80px leaves only30px of vertical margin, so we keep both the horizontal gap and approach short. Actual controller tests take precedence over this simplified estimate.

The player has120ms coyote time and140ms jump buffering. These forgive late takeoff and early landing input; they should not be required to complete the normal route. Double jump remains an optional recovery tool for these transitions. Horizontal braking matters: releasing movement in air does not instantly stop momentum. The traversal test predicts braking distance with v²/(2a), using the existing350px/s² air friction.

Broad combat decks separate learning an enemy's attack from precise edge jumping. A recovery deck gives time to reposition before combining ranged and melee threats. The route camera frames the player toward the next landing; this differs from pinning the player exactly in the screen center. Boss health rises on routes5 and10, while the arena provides room to read and evade the attack.
