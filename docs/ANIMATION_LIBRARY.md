# Authored character animation library

`game/animation/cel_actor_visual.gd` renders complete character drawings with `AnimatedSprite2D`. It deliberately does not invent body poses by rotating cutout limbs. It is an art playback/metadata component, not a second combat controller or proof of animation quality.

`profiles/ronin_cel.json` is a **provisional compatibility profile** populated from the existing source-derived 96×96 pixel atlas plus the previous four-frame kick strip. It is not the newly approved pixel redraw. Its sockets/contact keys are examples requiring visual review. Parent integration can replace individual clip atlases while keeping other clips available during production.

## Runtime API

```gdscript
var visual = preload("res://animation/cel_actor_visual.gd").new()
add_child(visual)
visual.configure("ronin_cel") # res://animation/profiles/ronin_cel.json
var spec: Dictionary = visual.get_attack_spec("sword", 2)
# Controller owns elapsed time, damage acceptance and cancellation.
visual.update_pose(delta, "sword", facing, velocity, is_on_floor(),
    attack_elapsed / spec.duration, 0, 2)
# At this profile's contact phase, the selected frame is its contact_frame.
if not hit_applied and attack_elapsed / spec.duration >= spec.contact_progress:
    # Run a corresponding authored hit-volume query; do not trust these defaults as art approval.
    hit_applied = true
var blade_contact: Vector2 = global_position + visual.socket("weapon_tip")
```

`configure` also accepts a full `res://` or `user://` JSON path. It builds new metadata/resources before committing a profile. Failed loading retains the previous valid visual. `get_attack_spec(kind, combo=1)` returns an independent dictionary containing `clip`, `duration` in seconds, `contact_progress`, `active_end_progress`, damage/reach/cost and other user-defined fields. Sword combo values select genuinely distinct `sword1`, `sword2`, `sword3` drawings; special kinds may point to any named clip.

`update_pose(delta,state,facing,velocity,grounded,progress=0,reaction=0,variant=1)` selects action drawings solely from controller-provided normalized progress. Calling it with a different delta but the same progress cannot advance an attack. There is no `AnimatedSprite2D.advance()` call, async contact timer, or independent action clock. Idle loops advance with delta; locomotion advances by signed-independent distance magnitude divided by each clip's authored `stride_world`, and never scales the artwork's limb amplitude. Foot contacts fire when declared frame boundaries are crossed, including a skipped-frame/wrapped boundary. Stance quality still depends on appropriately authored drawings and calibrated stride distance.

States can include idle, run, walk, jump, fall, land, crouch, dash, charge, hurt, death, kick, charged, power, ranged, plunge and sword. `state_map` maps aliases. `hold_progress` explicitly holds a phase (e.g. the ascent/fall drawing); other nonloop clips use controller progress. Hurt can use `reaction` decreasing from1 to0. For a landing clip, the controller must pass its actual landing phase; merely naming a landing state does not create that state or delay input.

`socket("hand"|"foot"|"weapon_tip"|"chest"|"pelvis")` returns a position in actor-root coordinates using the selected frame's feet origin, facing and uniform art scale. `hand_r`, `foot_r`, `hip` are compatibility aliases. Frame socket values override matching clip values, which override matching profile values; unspecified sockets preserve the lower-level definitions. The sockets are metadata for authored drawings, not an anatomical solver. Use `set_debug(true)` to inspect socket/ground markers.

`foot_contact` has no arguments; `frame_event(event, at)` supports other authored frame events. The controller still owns cancellation. `apply_impact(direction,strength)` adds a small transient presentation offset. `external_roll` is a compatibility input, bounded by `max_visual_roll` (default0.35radians) while airborne and suppressed on the ground; it is not a ragdoll. `create_snapshot()` returns a static child visual in local actor coordinates, for a caller to place at the actor position and fade as an afterimage.

## Profile schema and mixed atlas sizes

```json
{
  "id": "ronin_new",
  "atlas": "res://art/pixel/old_movement_sheet.png",
  "scale": 2,
  "feet_origin": [48, 87],
  "body_center_height": 58,
  "sockets": {"hand": [63,62], "foot": [59,84]},
  "clips": {
    "idle": {"loop": true, "frames": [{"rect": [0,0,96,96], "duration_ms": 120}]},
    "sword1": {
      "atlas": "res://art/pixel/new_sword_128.png",
      "feet_origin": [64,112],
      "scale": 2,
      "loop": false,
      "frames": [
        {"rect": [0,0,128,128], "duration_ms": 65},
        {"rect": [128,0,128,128], "duration_ms": 40, "sockets": {"hand": [84,83], "weapon_tip": [112,76]}},
        {"rect": [256,0,128,128], "duration_ms": 85},
        {"rect": [384,0,128,128], "duration_ms": 130}
      ]
    }
  },
  "attacks": {"sword1": {"clip": "sword1", "contact_frame": 1, "active_end_frame": 2, "duration": 0.32, "damage": 35, "reach": 118, "cost": 0}}
}
```

Rectangles and origins are **source pixels**, socket values are source-frame coordinates; displayed sizes and stride are world units. Each complete drawing uses a fixed canvas and a shared feet/root anchor. A frame can override `feet_origin` only for deliberate root-motion registration; do not tight-crop/recenter every frame automatically. Clip-level atlases allow 128px sword/kick drawings to coexist with 96px movement during a bounded repair. All art uses one uniform nearest-filtered scale; dimensions do not stretch independently. Frame weights `duration_ms` determine normalized contact and playback phase even when the controller fits the action into a chosen overall duration.

The example rectangles and sockets demonstrate the contract; they are not an approved sword pose or a mandate to use four frames. Readability, identity, contact, volume and transitions must be checked at native size with the new artwork before expanding the move set.

## Verification

Run `Godot --headless --path game --script res://tests/animation_library.gd`. The test covers controller-clock determinism, contact-frame selection, three distinct sword clips, stable feet-origin registration, mirrored sockets, distance-driven gait events, custom JSON load, per-frame/clip socket overrides and uniform scale. These checks establish library behavior, not art acceptance, foot pinning quality in a particular drawing, or normal-speed perception.
