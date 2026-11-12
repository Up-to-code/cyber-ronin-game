# Slim ronin art, story and reusable animation proof

The selected direction is a pixel-art redraw of the original slim ronin: pointed hat, narrow dark armor, torn cloak and a fine cyan sword. The source Cyber Ronin pack is painted artwork; the old pixel conversion and the new generated redraw are adaptations, not original pixel-art source claims.

## What is in the build

The hero now uses `CelActorVisual`, rendering whole-character drawings. Idle, the first sword strike and kick use the new redraw under `game/art/ronin-redraw`. Every sheet cell has a common 128×128 canvas, feet origin (64,112), and uniform 2× display scale. Drawings retain their full silhouettes instead of rotating separate rigid body chunks. Ground attacks brake to a planted support stance; aerial steering remains available.

Each new action has six pose records including rest and recovery holds, lasting 470 ms. Contact starts at 135 ms on frame 2. These are blocking/key-pose proofs. Generated in-betweens changed lighting and silhouette, so those candidates are saved but excluded from runtime. They are not presented as a completed 14-frame animation. Walk/run, combo strikes two/three, power and other actions still use normalized existing whole-character sprites. Those transitions need a coherent redraw pass before calling the art finished. Guard uses its original authored cel animations; fire and wraith retain experimental rigs. This library does not claim to be a weighted mesh or skeletal ragdoll.

`game/animation/profiles/ronin_cel.json` owns frame rectangles, holds, contact frame, duration, damage/reach and sockets. Contact annotations remain provisional. `CelAttackSpec` derives contact phase from the drawing durations; the player and guard consume it. The controller and visible action share one clock. Locomotion contacts use traveled distance, not an unrelated wall clock. Shared gravity/impulse rules remain in `game/systems/world_rules.gd`. The launch/death rotation is restrained to keep a whole-body cel readable.

Sword and kick damage, contact audio and VFX are triggered at the declared contact phase. Trails can snapshot the current whole drawing. Jump performance now separates takeoff, rising, apex, falling and landing source poses; physics controls the actual jump arc.

## Story

Kuro returns to a silent monastery. Captain Ren stole the shrine bell and bound the keepers into fire and wraith forms. Six short chapter cards follow the existing six maps, ending with recovery of the bell and release of the keepers. Cards pause gameplay, release held touches and restore input on Continue. They appear once per chapter per session. Automated gameplay runs skip automatic cards, with a dedicated test exercising the manual integration.

## Reusable production tools

- `tools/pack_ronin_redraw.py`: alpha cleanup, common-scale packing, support-foot registration and palette mapping. It does not synthesize poses. Raw generated candidates and prompts are retained under `assets/pixel/ronin-redraw`.
- `tools/build_character_library.py`: normalizes source atlases and creates compatibility profiles. Read its overwrite behavior before rerunning; profiles have subsequent authored edits.
- `game/animation/cel_actor_visual.gd`: replaceable atlas/profile interface, mirrored sockets, event markers, snapshots and per-clip registration. See ANIMATION_LIBRARY.md for a custom character.
- [Aseprite command line](https://www.aseprite.org/docs/cli/) can export PNG/JSON tags and slices for an artist-authored pipeline.
- [Godot Aseprite Wizard](https://github.com/viniciusgerevini/godot-aseprite-wizard), MIT, is an optional Godot importer for Aseprite animation assets. It was researched but not installed; the current library needs only PNG and JSON. Aseprite was not purchased.

## Verification and limits

Godot 4.7.2 headless checks cover the actual displayed contact frame, once-per-action sword/kick damage, planted support during strikes, story input ownership/resume, custom profiles, distance-driven gait events, independent HP/power, charge cancellation, double jump/combos, enemy launch/projectiles, mobile safe-area controls and all six map loads with representative physical routes. These tests establish behavior, not artistic approval or natural-looking motion.

`docs/qa/redraw-story-proof.mp4` is an 8.7-second native Godot capture with story, sword, kick, movement and jump. World combat effects are hidden in this capture to expose the body drawings; it is not a final VFX showcase. Frame screenshots were inspected; continuous motion and audio still need a human quality review. Real-device touch/performance testing remains pending.

Rams quick_review was requested for the new story UI with `via: rules`. It returned `ran:false` because the workspace's 15 review credits are exhausted. No Rams approval is claimed.
