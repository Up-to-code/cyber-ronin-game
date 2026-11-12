# Reusable pixel body rig

`game/rig/rig_visual.gd` is a reusable **segmented textured polygon / bone rig**, rather than a whole-body frame sheet. It creates one actual Godot `Skeleton2D`, 17 inspectable `Bone2D` nodes and 17 nearest-filtered textured `Polygon2D` pieces. The limb polygons follow their parent bones rigidly; this version does not use soft weighted skin deformation or a full physical ragdoll. Characters retain a single authoritative collision body controlled by the game. Air roll and spring recoil change the visible body, never secretly rotate its collider.

The origin is the feet on the walking surface. Default standing height is approximately 116 world pixels. The central hip is `(0,-56)`, with spine/shoulder/head chain and two upper/lower/end chains each for arms and legs. Local art faces right; facing mirrors the complete visual around its center. Named sockets return coordinates local to the rig's feet root, including the external roll: `hand`, `hand_r`, `foot`, `foot_r`, `chest`, `weapon_tip`, `pelvis`, and individual joint IDs. An equipped weapon remains attached to the front hand. Wraith profiles hide the leg and sword meshes and use a separately generated flame-mask head and visible cloth tail.

## Runtime API

```gdscript
var rig = preload("res://rig/rig_visual.gd").new()
add_child(rig)
rig.configure("ronin") # or guard, ember_fire, wraith, res://custom.json, user://custom.json
rig.update_pose(delta, "kick", facing, velocity, is_on_floor(), action_fraction, reaction)
rig.apply_impact(hit_direction, impulse_strength)
rig.external_roll = air_rotation_radians
var kick_contact = rig.global_position + rig.socket("foot")
rig.set_debug(true)
```

`foot_contact` emits twice per moving cycle, as each stance phase begins. It is independent of the old sprite-frame event. Supported state vocabulary includes idle, walk, run, crouch, dash, jump/fall, kick/fire_kick, sword/attack, charge, charged, power, plunge, hurt/launched and death. Unrecognized states retain neutral/air posture. `action_fraction` is 0–1. The body controller owns action timing and contact/damage; the rig visualizes that state.

## Mathematics and contacts

Each limb uses analytic two-link inverse kinematics. For lengths `a,b` and clamped target distance `d`, the projected elbow distance is `(a²-b²+d²)/(2d)` and its perpendicular distance is `sqrt(a²-x²)`. A fixed bend sign avoids arbitrary knee flips; unreachable targets clamp below full extension instead of stretching. The contact phase moves a planted ankle horizontally opposite travel, with fixed ankle Y=-8 and boot bottom Y=0. Swing phase follows a smooth return arc. Hip bob, torso lean, counter-swing arms and trailing coat are separate body responsibilities. Kick moves the front foot target across an arc while the rear foot remains grounded and torso/arms counterbalance. The root body remains responsible for gravity and ground contact.

Impact bend uses a damped angular spring; `external_roll` rotates the entire rig around `(0,-58)` so a launched enemy flips around its body center, not its feet. This is authored visual feedback layered onto ballistic body motion, not an anatomical biomechanical simulation.

State changes use a 0.09-second smoothstep blend of hip, hand, foot and angle targets before IK is solved. This preserves link lengths rather than stretching/interpolating solved joints. Run/walk foot targets continue using the unsmoothed stance contact curve, and grounded support feet keep ankle Y=-8. Facing uses an immediate full-width mirror with a short torso spring response rather than collapsing the body through zero width.

## Replace a character

Copy `game/data/characters/ronin.json`. Profiles override lengths, widths, tint, atlas path and optional part records. `configure` merges missing values from the default profile. Every part has an atlas rectangle in texture pixels, a displayed size in world pixels and a normalized pivot. Parts are head, torso, pelvis, coat, upper_arm, forearm, hand, weapon, thigh, shin, boot and wraith_head. Arms/legs reuse the same texture role for front/rear bones, with a defined z order. Keep overlap at joints. Changing the image alone cannot infer anatomical joints: supply the same 12-part contract or update the atlas rects/pivots. Movement, kick, gravity, hit effects and sockets can then remain shared.

Raw generated source and hand-written prompt are in `assets/rig/ronin-parts.*`. `tools/rig_process_parts.py` only alpha-cleans, tight-crops, resizes, palette-reduces and packs generated parts; it does not draw the artwork. Runtime `parts.png` is 384×288 RGBA, twelve 96×96 atlas cells. The base reference is the existing ronin art direction; additional fire and ghost appearances are configured skins, not new animation sheets.

## Validation

`tests/rig_geometry.gd` passed real bone/mesh counts, constant link length, unreachable target clamping, planted stance ankle, actual kick foot extension, center-based roll and fire/wraith profile swaps. `tests/rig_render.gd` rendered all three skins through run, kick and sword; frames `/tmp/rig-preview-30.png`, `-75.png`, `-105.png` were visually inspected for visible separated joints, body connections, weapon ownership, planted rear foot and a distinct floating silhouette. This isolated preview does not prove full-level contact or physical-phone feel.

Godot API references: [Bone2D](https://docs.godotengine.org/en/stable/classes/class_bone2d.html), [Polygon2D](https://docs.godotengine.org/en/stable/classes/class_polygon2d.html), [2D skeletons](https://docs.godotengine.org/en/stable/tutorials/animation/2d_skeletons.html). The chosen implementation uses their documented bone hierarchy and textured polygons, without claiming a weighted mesh when using rigid attachments.
