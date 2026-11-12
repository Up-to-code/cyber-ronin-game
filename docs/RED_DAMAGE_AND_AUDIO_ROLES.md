# Red damage and separated sound roles

This pass preserves the recorded-material jump, footstep, kick and sword identity the user said was improving. It changes event ownership and presentation rather than replacing that palette wholesale.

## Confirmed feedback defect

A projectile hit called the target's damage handler, which emitted confirmed-contact VFX, and then emitted its own impact signal, which the main scene rendered again. A blade hitting an actor therefore produced duplicate contact overlays. `combat_projectile.gd` now lets damaged actors own the hit response; only scenery receives a projectile-owned impact. `projectile_feedback.gd` exercises real swept collision, checks one health change and one ring on an actor, and confirms walls still produce a projectile impact.

## Palette

Damage impact, finisher contact and defeat motes/sprites now use crimson and red-pink instead of the old ivory/orange contact palette. The contour and particles share that color role. Energy motion remains cyan so it can be read separately from taking/dealing damage. Takeoff, dust and snow do not become red merely because combat is nearby. Feedback remains transient and pixel-snapped; collision geometry is unchanged.

## Sound ownership

- Enemy footsteps use a new quieter `enemy_step` cue and `EnemyCombat` bus, so they no longer share the player's footstep rate-limit key.
- Ranged release and energy release have separate cue identities and existing blade/energy recordings instead of routing every power-family action into the same burst.
- Enemy attack releases and steps use the enemy bus, while player motion/contact remains on Combat and menu cues remain on Interface.
- Existing source recordings and licenses are unchanged. No new unlicensed media is introduced.

The parent integrates player ranged/energy cue hooks; the enemy visual agent integrates enemy footstep hooks. This file does not claim a new composed soundtrack or subjective sound approval. The role separation follows the event-based sound-set principle described in the previously collected Audiokinetic Adventure design reference: https://www.audiokinetic.com/download/documents/WwiseProjectAdventure_en.pdf .

## Verification

Passed `red_feedback_audio` headless and native: distinct release sources, separate concurrent player/enemy footstep routes, crimson damage palette, distinct cyan energy motion and complete cleanup. Passed `projectile_feedback`, `audio_roles`, and `feedback_separation`. The broader effects test encountered the concurrently generated enemy atlas before it existed; rerun after the final asset import is required rather than treating its success print as a clean pass.

Native audio route assertions establish which bus/cue plays, not whether a listener prefers the result. Phone speakers and actual human listening remain unverified.
