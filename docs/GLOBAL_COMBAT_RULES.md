# Shared combat rules, combo motion and ground audio

## Playable changes

A second sword tap now queues one follow-up and can enter it after the first cut's active cels plus 50 ms of follow-through. It no longer waits for the entire first recovery. The actual rapid-input test starts cut two at about 0.25 s, compared with the first cut's full 0.47 s duration. Two cuts deal 35 + 42 damage; the third deals 55. Contact damage is still emitted once per cut, and the charged/air/plunge input paths remain separate.

Second/third/charged cuts use a new forward half-shell VFX around the body rather than enlarging a hand-centered sprite through the floor. The side and bottom contours gain a bright edge and brief glints, then fade over 240 ms. The local vertical radius is 52 px with a center 62 px above the feet, leaving 10 px clearance (at least 8 px after snapped geometry). Extra inner contour on strong cuts adds visual weight without additional damage events. This is pixel-snapped runtime geometry, not a newly generated sprite sheet.

Idle presentation adds a 2.8 s breathing cycle with 0.8% width/1.4% height changes, anchored at the drawn feet. Body physics and floor contact do not bob. Sockets include the visual scale. It is a small whole-cel breath, not a new articulated idle animation.

## Reusable response model

Implementation: `game/systems/world_rules.gd`, shared by enemies and player hurt reactions. Tunables: `game/data/physics.json` → `combat`. Each actor exposes `mass_kg` and `knockback_resistance`; built-in enemy presets also set resistance. A future large boss can supply its own mass and bracing without special-casing the hit function.

```gdscript
var response: Dictionary = WorldRules.combat_response(
    damage, attack_kind, incoming_direction, mass_kg, knockback_resistance)
# response.velocity: bounded initial recoil velocity in px/s
# response.impulse: corresponding bounded impulse, for angular reaction
# response.stun: recovery/stagger duration
# response.ground_stop_distance: ideal horizontal stopping-distance estimate
```

Two core rules:

1. Attack strength creates impulse: `J = J_kind × (damage / reference_damage)^0.85 / resistance`.
2. Mass converts impulse into recoil: `v = pixels_per_meter × J / mass`.

Then horizontal/lift speed limits prevent extreme launches. Ground/air drag slows recoil; the existing shared downward gravity handles falling. The ideal flat-ground distance is `vx² / (2 × ground_drag)`. Actual travel also depends on fixed time steps, airborne duration, walls, ledges and AI recovery. This estimate is not a promise to teleport a body that exact distance. Recoil is an authored reaction state initialized from this velocity, not a full rigid-body solver.

Damage affects impulse; **current health does not stand in for mass**. A heavy or braced enemy recoils less at the same damage. Resistance represents game-designed poise, not a physical universal constant. All hit profiles, reference damages, impulses, speed caps, drag, enemy resistance presets and combo follow-through can be edited in the JSON.

The physical basis is Newtonian momentum, not Einstein/general relativity: [NASA's second-law explanation](https://www.grc.nasa.gov/WWW/K-12/BGP/newton2.html) describes force as the rate of momentum change and the mass/velocity relation. The damage exponent, resistance, caps and stun are deliberate game-feel choices, not claims of physical realism.

## Ground sound from other creators

New sources: [Jump Landing Sound by MentalSanityOff](https://opengameart.org/content/jump-landing-sound) and [Impact by qubodup](https://opengameart.org/content/impact), both CC0 on their creator listings. A boot/body landing and stone texture are mixed differently for normal landing, heavy landing, plunge and wall contact. This replaces the previous tiny trimmed landing and generic soft-impact sound. Walking and takeoff remain from the existing palette; weapon swishes remain artisticdude, and combat/energy layers remain SpritePilot. The game now deliberately mixes sources by role.

Provenance/credit: `game/licenses/ground-resources-cc0.txt`. Originals retained in `assets/audio/ground-candidates`. Builder: `tools/build_ground_audio.py`.

Before/after sample: `docs/qa/ground-v3/ground-comparison.wav`, six 1.2-second slots: light old/new, heavy old/new, plunge old/new. This is available for listening; waveform/output checks do not establish that the new sounds are subjectively better.

## Validation

`combat_rules_combo.gd` tests the response law, mirrored direction, zero damage, large-boss resistance, actual physical travel, real rapid input, exact combined damage, breathing foot contact, arc ground clearance and expiry. Same 35-damage hit produced about 10.78 px travel at 70 kg, 1.77 px at 140 kg, and 0.30 px at 140 kg with 2× resistance in the isolated test. The values include discrete simulation; they illustrate ordering rather than a universal distance target.

Other passing checks: body_physics, authored_contact, motion_audio_sync, aerial_motion, audio_event_states, audio_palette, smoke, directional_recoil_scenery, attack_resource_roles. The body_physics projectile phase now removes its previously tested fire/wraith actors before checking the isolated guard; after recoil tuning the fire keeper could otherwise enter the ray and correctly intercept it.

Native `audio_combat` output/cancellation/variation check passed. `docs/qa/global-combat.mp4` is a 60 FPS native sample using real rapid taps against a guard and braced sentinel, plus air kick, landing, energy, charged and power. Enemy health/power and AI movement are staged for observation. It is not a full campaign playtest or a physical-phone listening test.
