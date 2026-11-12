# OpenCode Game Review — samurai build (2026-11-11)

Working copy: `~/.t3/scratch/2026-11-11-https-pavelekh-itch-io-cyber-cc091a15/game`
Engine: Godot 4.7.2 (`/Applications/Godot.app/Contents/MacOS/Godot`)
Role: implementation pass — verified defects were fixed, not just listed.

## Method and evidence limits

- Degraded evidence first: `docs/qa/lacquer-defeat.mp4` (1152x648, 60 fps, 13.43 s, AAC)
  was **frame-extracted**, not played back. No claim here comes from watching or
  hearing the video.
- Behaviour was then re-verified by running the real scene headlessly and by
  assertions added to `game/tests/`.
- Audio timing was measured from extracted waveform energy (20 ms windows), not by ear.
- `docs/LOCOMOTION.md`, `docs/DEFEAT_PRESENTATION.md` and older notes were treated as
  claims to check, not as proof.

## Verified defects and fixes

### 1. Landing/takeoff squash never reached the visible character

`player_2d.gd` squashed and stretched `AnimatedSprite2D` (`sprite`) on takeoff and
landing. Since the cel rig (`CelActorVisual`) became the drawn character, that sprite
is hidden, so the only visible motion of a landing was the pose swap — the compression
the code intended was invisible.

Fix: `CelActorVisual` gained a presentation-only `pose_scale` that multiplies the drawn
sprite scale and never touches collision, sockets or the physics body; the sprite offset
is recomputed from the same scale so the cel stretches and compresses **around the feet**
instead of sliding the pose off the ground. `feet_local()` exposes that anchored point so
the invariant is testable. `player_2d.gd` feeds it the same interpolated scale each frame
and resets it on `reset_motion_presentation()`.

- `animation/cel_actor_visual.gd`: `pose_scale` field, scale and foot anchor in the pose
  update, `feet_local()`, reset in `configure()`.
- `actors/player_2d.gd`: `rig.pose_scale = sprite.scale / 2.0` in `_update_visual_scale`,
  reset in `reset_motion_presentation`.
- User-visible: takeoff now stretches and landings (including plunge landings) compress
  the actual on-screen ronin instead of a hidden node, with the feet staying planted.
- Regression: `tests/locomotion.gd` asserts the rig stretches on takeoff, squashes on
  landing, and that the drawn feet stay within 2 px of the actor's feet through both.

### 2. Plunge landing snapped back to the dive pose

`_update_rig` selected `land` only while `landing_left > 0`, but the plunge's own
`attack_time` outlived that window. For roughly 0.1 s after touchdown the visible
character flipped back to the `plunge` clip and then to `crouch`, so a dive landing
visibly re-entered the dive.

Fix: a landed plunge now owns the `land` pose for the whole post-impact attack time
(`attack_kind == "plunge" and attack_time > 0`).

- User-visible: plunge → compressed landing → neutral crouch recover, with no pose
  jump back to the dive.
- Regression: `tests/aerial_motion.gd` asserts an airborne plunge displays `plunge`,
  and that no frame after touchdown shows the dive clip again.

### 3. Touch controls stayed on screen through the death beat

In the capture, the touch pad remains bright and pressable after the ronin is cut down,
until the result card finally covers the playfield. That invites taps on a dead actor
and muddies the defeat moment.

Fix: `hud.hide_touch_controls()` releases held touches and hides the pad; the level
calls it when the player reports `Defeated`. `close_menu()` still restores the pad from
`touch_enabled`, so retry and every later route behave as before.

- `ui/hud.gd`, `scenes/main_2d.gd`.
- User-visible: the pad disappears at the lethal hit, the death clip plays on a clean
  screen, the result card appears afterwards, and retry brings the pad back.
- Regression: new `tests/death_presentation.gd`.
- Rendered before/after at the same instant (health 0, death pose, result card not yet up):

  ![before](defeat-before.png) ![after](defeat-after.png)

  `defeat-before.png` is extracted from the shipped `docs/qa/lacquer-defeat.mp4` (8.6 s);
  `defeat-after.png` is frame 490 of a fresh non-headless run of
  `tests/capture_lacquer_defeat.gd` with the route story card skipped
  (`--path . --script res://tests/capture_lacquer_defeat.gd -- --skip-story`).
  `retry-after.png` shows the same run after retry, pad restored.

### 4. Stale locomotion regression re-engaged

`tests/locomotion.gd` still asserted the old rule "airborne sword must descend or
complete its ground impact" after air-`J` became a normal air slash and `DOWN+J` the
explicit plunge. The suite therefore failed before any product change, which hides real
failures.

Fix: the test now checks current intended behaviour — air `J` stays a sword, `DOWN+J`
requests the plunge — and also asserts the visible rig squash and its exact settle.

## Test-only fix

`tests/smoke.gd` placed a guard next to the player and pressed attack, expecting one
35-damage hit. During the 65-frame wait the guard walks into reach and starts its own
swing; when the guard is teleported onto the player that in-flight strike lands first,
cancels the sword (`take_damage` clears `attack_time`) and the assertion fails. This is
a test-setup race, not a gameplay defect: the guard's strike can only connect that way
because the test moves the target into an already-running swing.

Fix: the test clears that in-flight AI action (`windup`, `strike_left`, `cooldown`)
after the teleport so it measures player damage rather than the guard's cooldown. No
gameplay code changed for this.

## Explicitly not changed

- **Single walking speed.** The build has one movement speed with a run cadence; that is
  a deliberate design decision, not a defect.
- **Sword/kick audio timing.** Measured cue order (swing whoosh on the contact frame,
  impact layered with it) matches the visible sweep; no defensible desync was found.
  The long near-silence after the defeat cue is a deliberate defeat-music fade.
- **Mobile spacing.** `tests/mobile_ui.gd` already verifies non-overlap, safe-area
  containment, multi-touch independence and preference-driven layouts at several
  viewport sizes; nothing there was broken.
- **Art.** No art was replaced. The pixel/cel direction is preserved.

## Verification

All headless tests run from `game/`:

```
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/<name>.gd
```

- 26/26 headless tests pass: `aerial_motion`, `air_slash_energy`, `animation_library`,
  `audio_combat`, `audio_event_states`, `audio_palette`, `audio_roles`,
  `authored_contact`, `body_physics`, `campaign_data`, `campaign_runtime`,
  `combo_air_jump`, `dash`, `death_presentation`, `defeat_ui`, `effects`,
  `feedback_separation`, `jungle_terrain`, `kick_states`, `locomotion`, `mobile_ui`,
  `platforming`, `power_actions`, `recovery_flow`, `rig_geometry`, `smoke`.
- `tests/rig_render.gd` needs a real rendering context: it awaits
  `RenderingServer.frame_post_draw`, which the headless dummy driver never emits, so it
  hangs under `--headless`. Run without `--headless` it completes and rewrites
  `/tmp/rig-preview-30.png`, `-75.png`, `-105.png`; the three skins still render with
  separated joints and owned weapons.
- Temporary diagnostic scripts used during investigation were deleted.

## Unresolved / recommended next

- **Rams quick_review: blocked.** The workspace review credits are exhausted, so no UI
  review was run and none of the UI changes above carry review approval.
- `docs/qa/lacquer-defeat.mp4` predates these fixes. It should be recaptured to confirm
  the hidden pad and the landing compression in a real recording; the assertions above
  are the current evidence.
- `tests/smoke.gd` still depends on AI cooldown state in a live scene. A future cleanup
  could give the test a frozen guard, or split "player damage" into a focused combat
  test, so the suite stops being timing-sensitive.
- The defeat beat still ends in a long quiet stretch before the retry card. It reads as
  intentional mood, but if it is meant to be shorter, change it deliberately rather
  than as an audio bug.
- Full-level contact feel (plunge impact weight, landing compression read at gameplay
  zoom) is not proven by tests; it needs a human play pass.
