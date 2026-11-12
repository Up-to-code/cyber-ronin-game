# Scenery, directional reactions and menu polish

User clarified that barrels are decorative background scenery, not destructible hazards, and both player and enemies should recoil away from incoming hits. The four new screenshot references were unavailable and no matching local attachment copies were found; changes were reviewed against the current build.

A generated six-prop pixel atlas adds single/stacked barrels, crates, stone lanterns, a fox shrine and cloth banners. Props are sparse, muted and behind playable characters, anchored to platform surfaces. Lantern/banners have restrained presentation motion. They have no collision objects and are excluded from attack/enemy queries.

Physical directional recoil already existed. The enemy impact presentation still used the enemy's facing for VFX and a contact-point vector that could nearly cancel horizontal visual reaction. Enemy VFX, defeat flecks and body reaction now follow the actual incoming hit direction. Player reaction was verified in both directions independently of facing. Shared gravity, impulse rules and mass differences remain.

Menu action rows now reserve44logicalpixels height, preserving existing text padding and scrolling when needed. Button-down adds a140ms warm pixel accent that cannot intercept input and expires while paused. The VScrollBar has a dark track, crimson thumb and ivory pressed state, with default arrow glyphs removed. Mouse hover does not introduce a new highlight.

Regression coverage: directional_recoil_scenery exercises actual left/right motion for both sides, matching contact direction, decorative noncollision and paused click-effect expiry. mobile_ui, menu_clean_layout, body_physics and recovery_flow pass. Native capture uses one staged nearby guard to expose combat and scenery; it is not a human full-level playthrough. Subjective motion/audio preference and physical-phone behavior remain unverified. Rams rules review was requested but blocked by exhausted credits.
