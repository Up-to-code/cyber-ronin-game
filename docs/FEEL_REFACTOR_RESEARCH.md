# Motion, touch and feedback repair research

## Evidence and implementation criteria

The previous build used six kick pose records with long holds, static rise/apex/fall drawings, a sprawling touch cross, and campaign openings up to 280 world pixels. Passing damage tests did not establish smoothness, comfort or sound quality.

Primary references consulted:

- Maddy Thorson, [Celeste & Forgiveness](https://www.maddymakesgames.com/articles/celeste_and_forgiveness/): coyote time, buffered jumps, apex adjustment and lift momentum support forgiving movement. Apply the timing principles; do not copy a game's constants without testing this game's scale.
- Apple, [Game controls](https://developer.apple.com/design/human-interface-guidelines/game-controls): virtual controls should suit touch input and thumb placement. Compact groups and safe areas need actual device validation.
- [Game Accessibility Guidelines: target size and spacing](https://gameaccessibilityguidelines.com/ensure-interactive-elements-virtual-controls-are-large-and-well-spaced-particularly-on-small-or-touch-screens/): generous separated hit areas are preferable to tiny or tightly packed controls. Physical dimensions cannot be certified from desktop viewport pixels.
- Godot, [Animation](https://docs.godotengine.org/en/stable/tutorials/animation/): animation systems drive authored data; an AnimationTree does not create missing cel drawings.

## Platform route repair

Required-route gaps are now capped progressively from 80 to 110 world pixels across six maps. Extensions preserve original outer endpoints and platform heights. Moving lifts fit within those openings and retain vertical travel; no required route depends on waiting for a lift's horizontal phase. Optional ledges remain unchanged. This is a design choice for this game's touch controls, not a universal recommended gap.

Review each representative rise with the real controller, then record the integrated game. Numerical route tests establish reachability; physical phone play establishes comfort. More particles or passing skeletal equations cannot certify animation quality.

## Integrated repair

Jump animation now consumes its authored phase frames; walk is shown through acceleration/braking. Kick timing was shortened while preserving contact synchronization. More consistent intermediate kick drawings remain necessary. See `reviews/MOTION_PHASE_REPAIR.md`.

Combat controls use a compact lower-right two-row group with press feedback. See `MOBILE_THUMB_LAYOUT_RESEARCH.md`. Confirmed hits have separate effects and protected audio voices; music ducks briefly for impact. Native capture: `qa/feel-refactor.mp4`, 8.7 seconds. Frame screenshots were inspected; continuous subjective audio/motion quality and physical-device comfort remain unverified. Rams could not run because credits are exhausted.
