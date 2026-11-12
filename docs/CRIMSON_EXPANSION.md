# Crimson animation and scenery expansion

Built with the image-generation and 2D asset skills, with separate character, magic and scenery agents. Source images and exact prompts are retained in the corresponding `assets/crimson-*` folders; engine exports live in `game/art/crimson-*`.

## Implemented

- Generated nine-frame crimson/ivory spirit projectile for X/G, keeping damage, speed, lifetime and fire interception unchanged.
- Generated crimson wraith hover and casting animation, preserving combat contact timing.
- Generated crimson scenery across all six existing maps, with lantern flicker and bamboo sway.
- Walking into an unlocked gate for 0.45 seconds transports the player to the next map. Leaving the aperture cancels the charge. The vortex accelerates and expands slightly while charging. The interaction button remains supported.

## Scope

The six-area concept board is art direction, not six new playable maps. Guardian statues are decorative props, not new boss AI. Wraith hurt/death artwork remains from the prior set. Tests and staged screenshots verify mechanics and rendering, not a complete human playthrough.

## Verification

Passed portal_passage, campaign_data, all six campaign_runtime maps, crimson_wraith, fire_interception, and native magic/scenery/combined render checks. `docs/qa/crimson-combined.png` is a staged combined render.
