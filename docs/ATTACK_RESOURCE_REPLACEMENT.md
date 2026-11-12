# Attack resource replacement

The previous pass corrected timing while retaining cloth-heavy attack audio and a single four-frame slash atlas. This pass replaces those resources and gives distinct events different visual and sound treatments. Walking, jumping, landing and music are unchanged.

## Source choices

- [artisticdude: Swishes Sound Pack](https://opengameart.org/content/swishes-sound-pack): CC0, 13 light/heavy swishes. Selected short air strokes for kick motion, medium cuts for sword/reverse, longer cuts for finisher/charge, and separate enemy blade/thrust takes. The creator listing and archive were retrieved directly; the web renderer could not open the listing.
- [SpritePilot combat effects](https://spritepilot.com/free-game-assets/combat) and [impact effects](https://spritepilot.com/free-game-assets/effects): CC0 animated pixel strips. Five original sheets were imported and palette-remapped with nearest filtering and binary alpha.
- [SpritePilot sound effects](https://spritepilot.com/free-game-assets/sound-effects): CC0 kick, punch, steel clash, laser and fireball sources used as separate layers/roles. A downloaded sword-swing alternative remains a candidate; it is not the player's shipped sword sound.

License/provenance: `game/licenses/attack-resources-cc0.txt`. Downloaded originals remain outside the exported game.

## Runtime mapping

| Event | Visual | Audio |
|---|---|---|
| Sword cut / reverse | 7-frame sword atlas, strike frame first, directional reversal | Different medium swishes and alternating first cut |
| Finisher / charged cut | Broader authored arc; critical star only on confirmed heavy hit | Heavy swish; charge has its own take |
| Kick miss | Small flattened air stroke at the foot | Short light swish |
| Kick contact | Separate contact star and crimson debris | Kick/body transient, alternated |
| Armor contact | Contact star and crimson debris | Body transient plus quieter high steel edge |
| Floating spirit contact | Same compact contact presentation | Distinct short energy response |
| Power release | Ground-anchored expanding shockwave | Heavy air plus quieter energy layer |
| Energy launch / flight | Separate bolt sheet plus existing tapered trail | Electronic release, separate from charged sword |
| Enemy blade / thrust / fire | Directional blade or existing fire presentation | Separate swish/thrust/flame sources |

The original four-frame slash sheet is no longer used for these attack events or player projectiles. Related sword attacks reuse one sword atlas deliberately; contacts, criticals, power and energy use different artwork. This is a reusable palette of event parts rather than a single effect stretched across every event.

Attack sounds still follow authored contact/launch clocks. Timing keys include full resource paths so two different files named `swing.wav` cannot share the wrong measured lead. Effects begin at the bright strike cel rather than delaying the main silhouette until after damage. These presentation changes do not change damage/reach/collision.

## Verification and limits

Eight headless suites pass: attack_resource_roles, motion_audio_sync, audio_event_states, audio_roles, feedback_separation, projectile_feedback, authored_contact, air_slash_energy. They verify distinct resources, direction, expiry, correct motion/contact separation, action clocks, one-hit damage and aerial behavior; they do not establish subjective sound/art quality.

Native audio_combat check also passed for all nine tested combat cues, cancellation and alternating takes; measured overall output peak −12.92 dB.

Native capture: `docs/qa/attack-resources.mp4`, with a staged enemy and extra health/power, shows aerial slash, kick miss, three sword cuts, kick contact, enemy response, energy, charged cut and power. This is a presentation sample, not a full-level playtest. The new source palette still needs listening on phone speakers/headphones. Source sparse character poses are not redrawn in this pass.

Rebuild: `.pixel-tools/bin/python tools/build_attack_resources.py`, then Godot editor import. Run it **after** the older audio builders because it appends path-specific timing metadata. Original asset artwork is retained and remapping is repeatable.
