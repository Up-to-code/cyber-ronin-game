# Motion/art review outcome and repair order

11 November 2026. The user rejects the current animation and art. This turn is an independent diagnosis and skill installation, not another product rewrite. No game code or art was changed. The original captured build remains the baseline.

## What failed

The earlier work validated joint positions, constant link lengths, gravity, events and resource loading. Those checks never validated authored body performance, character identity, pose-specific drawings or a convincing match between visual contact and damage. Calling that a completed motion rebuild was premature.

Two independent review agents examined the rendered recording as timestamped extracted frames, source and art. Neither had continuous normal-speed audiovisual playback; real-time severity and heard mix quality remain unverified. The user's rejection is clear evidence that the result has not met visual acceptance. The reports separate source-confirmed defects, frame observations and production recommendations.

- [Independent motion audit: eight findings plus workshop/runtime comparison](independent-motion-audit.md).
- [Independent art audit: six findings, original-character comparisons and production choices](independent-art-audit.md).

## Highest-priority gaps

| Area | Verified gap | Required change / acceptance |
|---|---|---|
| Preview authority | The browser diagram uses different clocks, target curves, pole directions and reach handling from the Godot rig. It exports proportions, not animation. | Preserve it as a proportions editor. Use the actual runtime rig/controller for performance preview, or share authored pose/timing data and prove parity at fixed phases. Correct dots cannot approve animation. |
| Ground contact | The stance curve cancels root travel at full run only; amplitude blending produces foot drift at patrol/approach speeds. | Separate contact ownership from style amplitude. Compare sole and ground in the same coordinate space at each real speed, acceleration, brake and reversal. |
| Attack causality | A 90ms damage clock is independent of the chosen kick/sword contact configuration and root-distance hit rectangles. | Author the visible contact pose/sweep around the intended active clock, then align hit volume, reaction, sound and FX to that demonstrated contact. Do not simply delay damage to maximum extension by rule. |
| Whole-body performance | Kick is a symmetric endpoint pulse; three combo hits share one visible sword path. | Draw/block separate chamber, contact, recoil and recovery poses with pelvis, torso, support leg and hands carrying distinct responsibilities. First/reverse/finisher must differ without VFX. |
| Jump/landing | Airborne states reuse the same targets; landing/takeoff timers affect the hidden old sprite. | Route those phases into the visible body: push-off, ascent, apex, descent reach, compression and settle. Keep immediate input response. |
| Art representation | Generated parts changed the slim armored source into a different wrapped-cloth character; single-view quads cannot invent new surfaces, grip perspectives or overlap. | Choose a canonical appearance; test one full-body sword action and one kick. Use authored/replacement drawings where perspective changes. Retain bones/IK for contacts, sockets and suitable secondary motion. |
| Rendering/processing | Per-part tight crop and square normalization followed by different aspect ratios alter shapes; rigid rotation changes pixel clusters. | Preserve intended proportions/volume and native pixel scale. Inspect silhouette, joint contours, boots and katana at target size against both neutral and gameplay backgrounds. |
| Reactions/turns | Whole-rig rotation plus an upright capsule is not articulated recoil/landing; facing is an instant reflection. | Author constrained recoil/settle and turn transitions, checking first contact/extents. Approve any intentional instant mirroring convention explicitly; do not sell equations as biomechanics. |

The source kit itself is painted rather than pixel art, as its creator and bundled documentation state. Pixelizing it and generating replacement pieces were adaptations that need separate approval, not a faithful unchanged import. Restoring source animation is a useful comparison candidate, not an automatic decision to abandon the requested pixel direction.

## Research that changes the approach

1. [Wayne Gilbert / Animation Mentor: body mechanics](https://www.animationmentor.com/blog/animation-tips-tricks-what-makes-or-breaks-a-good-body-mechanics-shot/): plan how forces and body sections lead/follow; observe motion reference. Application here: define support/load/contact/recovery before coding more endpoint curves.
2. [Pedro Medeiros: consistency and rotation](https://saint11.art/blog/consistency/): pixel-grid/render-scale decisions and rotation have tradeoffs. Application: inspect the actual native-scale skin, not only continuous bone curves or enlarged atlas pieces.
3. [Pedro Medeiros: 3D reference for pixel art](https://saint11.art/blog/3d-ref/): rough 3D can supply perspective reference followed by drawing. Application: geometry can guide an action; it does not eliminate drawing the changed view.
4. [Godot cutout animation](https://docs.godotengine.org/en/stable/tutorials/animation/cutout_animation.html): combines cutout and cel/replacement parts. Application: retain reusable structure while allowing pose-specific hand/boot/body artwork. The tutorial carries an engine-version warning; verify exact APIs locally.
5. [Godot skeletons](https://docs.godotengine.org/en/stable/tutorials/animation/2d_skeletons.html): weighted deformation is separate from rigid bone-parented parts. Application: identify the actual renderer honestly; adding a Skeleton2D node does not by itself produce a deforming mesh or good acting.

## Installed skills

- **game-graphics**: installed from [fenre/skills/game-graphics](https://github.com/fenre/skills/tree/84bdc1dc884290ad78f4607e0e8f2068695377e7/game-graphics), pinned commit `84bdc1dc884290ad78f4607e0e8f2068695377e7`. Local `/Users/ahmedmansour/.codex/skills/game-graphics/SKILL.md`. Useful for silhouette-first, pose-first pixel production and animation references. Community heuristics and example frame counts remain fallible; primary references and project-specific review override generic prescriptions. Installed with the bundled skill-installer and validated.
- **character-motion-review**: authored and installed locally at `/Users/ahmedmansour/.codex/skills/character-motion-review/SKILL.md` using skill-creator, with no executable scripts. It captures the relevant contact/timing/skin/preview checks and evidence boundaries from this failure. Validated with the bundled validator.

Both will be discoverable on the next turn. Neither is a professional animator or a quality guarantee.

Rejected candidate: `thedivergentai/GD-Agentic-Skills/godot-2d-animation` recommends `AnimatedSprite2D.advance(0)`, which the installed API and [official class methods](https://docs.godotengine.org/en/stable/classes/class_animatedsprite2d.html) do not provide. Other inspected candidates prescribed universal mass-to-frame mappings, motion on every body part or UI easing rules for character action. Those were not adopted. No npm installer, remote skill script or product code from candidates was executed.

## Next implementation gate

1. Keep the current build and mechanics as comparison evidence. Do not expand enemies, VFX or UI during this proof.
2. Make a small reference board for one intended samurai identity and chosen side-view sword/kick actions. Preserve the source character's proportions unless a new appearance is deliberately chosen.
3. Produce a compact pose/silhouette sheet and effects-free native-scale performance for run → brake → sword contact → recovery, plus one grounded kick. Include visible skeleton, skinned body and ground markers in separate views.
4. Fix stance ownership and contact timing in that small sequence; establish meaningful visual acceptance before retargeting all characters and adding effects back.
5. Inspect normal-speed playback and sound separately. Frame sheets and assertions support diagnosis but cannot pass that perceptual review.

The motion is **not fixed** by this audit or by installing skills. Audio quality, full encounter balance and physical-phone comfort are still outside the inspected evidence; they must not inherit a blanket PASS from these reports.
