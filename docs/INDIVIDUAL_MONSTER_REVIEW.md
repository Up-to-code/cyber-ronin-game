# Individual monster action review

User rejects the shared elemental effects and static body presentation. This pass treats each monster identity as an authored action, with anticipation, emission/travel, contact and recovery. Shared renderer infrastructure is acceptable; a name/color-only variant is not evidence of an individual action.

Review findings before changes:
- Exit gate height264 exceeded level2's202px gap to the upper landing, producing overlapping architecture and the appearance of standing on the gate roof.
- Legacy body animation reached strike contact before starting a second delayed contract telegraph. This separated the visible strike from damage timing.
- Five elemental impact sprites and20 geometry families did not provide enough identity-specific visual vocabulary.
- Existing100 body illustrations were single-pose cutouts with shared timing. Motion changes cannot honestly be described as100 new hand-drawn animation sets.

Gate repair: data now specifies166.4x176 world-pixel exit frames, bottom anchored at the deck. All100 frames have floor support and clear other platforms. Five final aprons were extended away from their approach side;42 continuous transitions across the affected routes pass. Native level2 screenshot reviewed at docs/qa/exit-clearance-fixed.png.

Action acceptance: individually authored identity records and motif art; body and collision consume the same action timeline; no contact before its tell; interruption cancels pending strikes; anatomy-specific motion preserves normalized size and planted feet; effect/audio budgets remain bounded. Native render evidence must be distinguished from full human playthrough and heard sound-quality approval.

Implemented:100 named choreography records,100 distinct generated motif textures (hash checked),17 delivery paths including swept projectile collision and arrival-only area strikes. Each action has an ordered release/afterbeat and bosses add phase events. Body motion and contract damage now use one clock; strikes cancel on hit interruption.32 morphology classes cover all records;96 distinct sampled deformation trajectories were observed. The wolf has three newly generated attack-pose cels. Other monsters use constrained anatomy-specific deformation of their existing illustrations, not new hand-drawn frame sets.

Validation:100 real-AI initiations/contact timing/interruption checks,100 actual-damage/pre-tell/late-boss-event/cleanup checks,100 motif assets,100 exit clearances,42 continuous transitions on the five changed exit aprons. Native representative phase captures inspected and a staged replay recorded. The replay isolates attacks on a flat stage; it is not a complete level playthrough. Normal-speed visual appeal and heard sound quality are not certified by frame extraction.

Native uncapped fixed60Hz stress sample (AppleM4/OpenGL): five stages, median6.67–8.55ms,95thpercentile10.18–11.05ms. Shared renderer and sound synthesis remain; this is a substantial identity/action pass, not100 independent animation engines. Existing elemental-only gallery was superseded by the individual motif gallery.

Delivery: local macOS package now includes only the host architecture, reducing the runtime from335MB to roughlyhalf that. This resolved the signing failure encountered with low free disk space; the rebuilt app passes codesign verification. Redundant raw AVI intermediates were removed after their MP4 exports were retained. The reviewed replay covers representative identities; late final-boss phase PNGs were captured separately after recording storage filled. No claim of100 full bespoke cel animation sets is made.

## Death continuity and ground contact repair

The previous death path hid the procedural visual and restored its unchanged standing cel. It now retains the pose/texture at interruption, falls in the impulse direction, supports the rotated opaque silhouette on the floor, and fades during the final 0.4 seconds. It also initializes the transform when death occurs before the first motion tick. Grounded lower contours cannot deform below the support plane, and airborne land creatures no longer play travel deformation. Swimming bodies retain free water motion.

Validation: `monster_death_support.gd` checks 100 identities, two facings and six death phases against actual floor contact; `monster_attack_clock.gd` passes. Native staged frame captures for IDs 1, 2, 8 and 10 are under `docs/qa/death-*.png`; IDs 1, 8 and 10 were visually inspected. These are a rigid retained-pose fall, not newly drawn anatomical death frames. Single-pose locomotion remains an art-production limitation. No claim of a complete animation replacement or normal-speed/audio review is made.
