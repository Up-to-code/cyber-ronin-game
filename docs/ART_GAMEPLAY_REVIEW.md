# Game-art and movement review

## Changes implemented
Six generated airborne second-jump drawings now play over 0.30 seconds, interrupted immediately by attacks, hurt, dash or landing. Normal takeoff remains its own sequence. No artificial input delay added. Source: assets/ronin-v2/air-jump-source.png; game atlas: game/art/ronin-v2/air-jump.png. Generated with built-in imagegen using the new ronin reference: six ordered tuck/coil/extension/rise/apex/descent poses, same hat/scarf/weapon hand, transparent background. Local processing only splits, scales and packs cells.

Sword sequence durations changed from 0.47/0.38/0.48 to 0.36/0.32/0.40 seconds. Uneven frame durations separate anticipation, fast strike, contact hold and recovery. Damage, sockets, VFX and sound still follow the displayed contact frame. Other attack clips gain uneven frame timing without damage changes.

## Artist findings and remaining gaps
- Idle has eight drawings and continuous breathing; further squash will not substitute for articulated poses.
- Walk and run share eight drawings. Dedicated heel-contact walking art remains needed; the current pass does not invent frames by interpolation.
- Double jump previously reused ground anticipation; replaced here with airborne drawings.
- Attack timing was uniformly spaced and first cut slow; retimed here. Exact per-pose hand/weapon sockets still need authoring.
- Heavy magic actions share sword poses. Dedicated casting/body recoil drawings remain a gap.
- Blood reacts at hit events; it is not a substitute for a readable hurt silhouette. Current hurt/death sequence has limited poses.
- Background detail and large VFX can hide silhouettes. Keep ivory contact accents brief and darken scenery behind encounter zones in a later art pass.

## Physics and level findings
Gravity already exists at 1765.8 px/s²; jump height110 gives initial speed sqrt(2gh), about623 px/s and ideal equal-height flight0.706s. These are game units, not a reason to use relativistic gravity. Coyote time, jump buffering, variable jump handling and mass/resistance recoil already exist. Do not increase gravity indiscriminately to mask slow drawings.

Route1 starts with a broad flat platform and two guards, but its 280px gap relies on a moving lift. Teach the lift above safe ground before combining enemy pressure with traversal. Later routes add height changes, fire, ranged enemies and narrower footing; verify each landing has room for the player collider and recoil. Audit actual reach with moving platforms and double jump, not distance alone. The six routes have not received a full human play-through in this pass.

Loading already queues ResourceLoader.load_threaded_request, polls status, displays progress, retrieves only loaded resources, then builds the route. Large population batches could still hitch and should be profiled before splitting work across frames. No unnecessary loading rewrite made.

## Primary/reference reading
- Maddy Thorson, Celeste & TowerFall Physics: https://www.mattmakesgames.com/articles/celeste_and_towerfall_physics/index.html — actor/solid separation and moving-platform treatment.
- Maddy Thorson GDC level-design workshop: https://www.gdcvault.com/play/1024307/Level-Design-Workshop-Designing-Celeste — level-design reference; no claim of having watched the full talk.
- Godot background loading: https://docs.godotengine.org/en/stable/tutorials/io/background_loading.html — request/status/get lifecycle; get can block if called too early.
- Animation Mentor anticipation: https://www.animationmentor.com/blog/tag/anticipation/ — poses should communicate intent before action.
- The Level Design Book, pacing: https://book.leveldesignbook.com/process/preproduction/pacing — introduce, test, then vary challenges; alternate intensity and recovery space.
