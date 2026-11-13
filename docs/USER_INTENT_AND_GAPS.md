# Ashen Veil — user intent and implementation audit

Reviewed 2026-11-12 from the conversation, supplied references, current source, and targeted runtime checks. This is the working specification for subsequent changes. Review only: no gameplay edits in this pass.

## Intended game

A mobile-first Godot samurai action platformer. Everything should share a coherent pixel-art identity: slim straw-hat ronin, crimson sky and stone, black/dark foundations, warm lights, red supernatural effects, pixel fonts and menus. Generated art must become usable game assets; concept images alone do not complete a feature.

### Movement and animation

- A/D movement must continue during J sword and G/X magic, including reversing direction. A stationary attack and a moving attack need different readable body performance and VFX.
- Responsive jump, double jump, aerial sword and kick; ordinary airborne attacks must not force the player down. Intentional downward attack is separate.
- Idle breathing/readiness, walking, running, takeoff, rise, apex, fall, landing, combos, recoil and death should connect smoothly. Sixty-Hz simulation is not sixty unique drawings.
- Reusable character rules, anchors and animation data should support replacement art. Joint positions alone do not prove convincing motion; visible feet, weight, torso and weapon timing matter.

### Combat and feedback

- Separate health and power. Normal sword attacks are free; powerful ranged/laser/soul skills consume power.
- Stronger double/triple attacks need stronger but correctly placed arcs, blood, sound and recoil. No misplaced effect striking the floor during an ordinary slash.
- Shared recoil depends on attack strength and target mass/resistance; heavy monsters move less. Use gameplay impulse/gravity rules, not claims of Einstein-based mechanics.
- Sword/soul attacks can intercept enemy fire during appropriate attack phases.
- Damage feedback on player and enemies includes directional reactions, red blood particles and bounded camera shake.

### Audio

Use the explicitly selected Hove Sword Combat Sound Effects Pack Free Version for appropriate combat roles. Use its different recordings intelligently for swing, contact, armor, stronger combos and enemy attacks. Other licensed packs can fill distinct roles. Do not randomly stack unrelated sounds or treat file count as quality. Listening and synchronization matter; a passing event test cannot establish that audio sounds good.

### Levels, monsters and rewards

- Distinct routes that descend and ascend, with gaps, wall-attached ledges, stairs, moving platforms, broad combat landings, safe intermediate drops and doors.
- Latest sketch is a deep shaft with alternating shelves projecting from opposing walls. Scattered floating platforms or a horizontal staircase alone do not match it.
- Ground top and foundation need distinct art. Avoid stretched textures and repetitive tall patterns. Architecture must visibly support the shelves.
- Layered sky/clouds/buildings/scenery move with depth and camera; weather particles add life.
- Opening portals have layered animated pixel artwork behind the doorway and allow level transitions.
- Enemies should have different silhouettes, weapons, telegraphs, damage, VFX and behavior. Level 5 has a stronger indoor impostor encounter.
- Earn coins/points with readable reward feedback.
- Fall damage should reward controlled descents. The prior interpretation was a safe threshold then damage capped at 10% maximum health per landing; whether the user instead meant a 10%-health floor remains unresolved.

### Mobile UI

Responsive safe-area controls: movement left; primary sword on right with smaller nearby powers and kick, optional extra skills above. No separate Run button. Icons, comfortable spacing, consistent text padding, restrained hover/focus treatment, pixel switches/sliders, compact scrollbar, settings navigation, return to title, privacy links and saved preferences. Verify on real mobile/device runtime; desktop touch preview is not iOS certification.

## Verified implementation and gaps

| Area | Current evidence | Remaining gap |
|---|---|---|
| Moving attacks | player_2d.gd now steers during attack_time | _update_rig chooses the same sword/ranged clip regardless of speed; no dedicated moving-attack body clip |
| Directional VFX | Effects follow actor; aim sampled at contact | Body poses are not independently authored for all aim directions; rotating an effect does not fix body acting |
| Shaft | Level 7 has alternating shelves and deeper camera/death boundary | No enclosing wall architecture; one-way shelves still appear detached. Shelf art is stretched across variable widths |
| Levels | Eight definitions and menu entries exist | Recent layout checks are limited; no complete eight-level human playthrough or pacing approval |
| Impostor | 170 health, five-shot spread, stronger projectile | Converts to fire archetype; reused art/tint, no disguise/reveal mechanic, indoor setting not established |
| Wraith | New hover and cast cels | Older hurt/death art remains |
| Coins | +5 on enemy defeat, shown in objective text | No pickup, persistent wallet, spending, dedicated display, or clear run/reset policy |
| Fall damage | Speed threshold 850, formula capped at 10 points | Hard-coded for 100 health; intent ambiguity; interaction with hurt invulnerability needs review |
| Audio | Hove recordings mapped, existing layered system | Many attack types share two whooshes; subjective mix/roles need listening, not automatic approval |
| Art | Generated gate, vortex, magic, scenery and shelves integrated | Concepts show architecture not implemented in runtime; whole-game pixel density and silhouettes remain inconsistent |
| Mobile/settings | Existing responsive controls and saved settings | Native iOS usability not verified; Rams credits exhausted |
| Documentation | Many historic reports | README is stale (six routes and old animation/camera descriptions); old reports cannot establish current quality |

## Repair order

1. Verify held movement plus J/G, reversal, jump+attack and hit interruption; author a visible moving-attack performance with matching VFX.
2. Finish one complete shaft section: actual opposing walls, supported shelves, descent/escape route, readable landing hints, camera framing and fall-damage checks.
3. Complete enemy art across every state and give the impostor a distinct identity/encounter.
4. Listen to attack and damage mixes against contact frames; refine the approved pack by role.
5. Make rewards a deliberate small system and finish native mobile layout verification.
6. Expand levels after one complete section meets the reference and plays correctly.

## Acceptance discipline

Report separately: generated concept, imported asset, implemented mechanic, test result, rendered evidence, and human play/listening approval. A VFX-follow test does not prove movement is unlocked. A spawn test does not prove an effect is integrated into combat. Numeric route checks do not prove level design feels good. Do not dismiss a reported defect because a neighboring subsystem passed a test.
