# Swimming player controller

The world calls `player.set_submerged(bool)` using torso contact with a water volume before player physics, and assigns `player.swim_current` in world pixels/second. Current strength is capped at 140. Leaving water clears the current and provides a -220 px/s surface breach; retry returns to ordinary grounded/air physics.

A/D plus W/S or arrows swim in two dimensions. Space ascends. Swimming uses 175 px/s voluntary speed, acceleration 480, release drag 180 and gentle 18 px/s upward buoyancy. It has no gravity, jumping, plunge, crouch, drop-through, or land footsteps. Entering water cancels previous actions and restores platform collision exceptions.

J cycles three slower airborne sword contacts with directional aim and reversible facing. Ranged action spends 18 power for the `water` projectile event. Power/energy buttons do not cast fire or spend a sun relic. Parent owns water projectile visuals, collision and enemy response.

Presentation uses the current character's authored airborne cels, a paddle-phase cycle and torso-centered swim pitch, plus bounded four-bubble trails. It does not mutate shared character profiles. Swimming tint/pitch is removed when leaving. Dedicated painted swim cels remain a future art refinement; this implementation deliberately preserves the existing character identity.

Tests: swimming.gd covers ascent/descent, buoyancy, drag, visual pitch, current cap, fire restriction, water-shot costs, reversible J and surface/retry reset. moving_sword_facing.gd and earned_relics.gd still pass. Native staged rendering: docs/qa/swim-pose-native.png. Integrated underwater route escape and water-projectile collision remain parent's playtest responsibility.
