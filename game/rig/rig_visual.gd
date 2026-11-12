extends Node2D
class_name RigVisual
signal foot_contact

# Body simulation belongs to CharacterBody2D. This component owns only the reusable
# joint solver, skin meshes and sockets. Coordinates: feet=(0,0), +Y is down.
var profile: Dictionary = {}
var profile_id: String = "ronin"
var skeleton: Skeleton2D
var pivot: Node2D
var bones: Dictionary = {}
var meshes: Dictionary = {}
var joints: Dictionary = {}
var external_roll: float = 0.0
var debug_enabled: bool = false
var phase: float = 0.0
var motion_blend: float = 0.0
var impact_angle: float = 0.0
var impact_speed: float = 0.0
var current_facing: float = 1.0
var current_state: String = "idle"
var _configured: bool = false
var _last_pose: Dictionary = {}
var _transition_from: Dictionary = {}
var _transition_left: float = 0.0
const TRANSITION_DURATION: float = 0.09
const LIMBS: Array[String] = ["rear_arm", "front_arm", "rear_leg", "front_leg"]

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_build_bones()
	configure(profile_id)
	update_pose(1, "idle", 1, Vector2.ZERO, true)

func _build_bones() -> void:
	pivot = Node2D.new()
	pivot.name = "BodyCenter"
	pivot.position = Vector2(0, -58)
	add_child(pivot)
	skeleton = Skeleton2D.new()
	skeleton.name = "Skeleton2D"
	skeleton.position = Vector2(0, 58)
	pivot.add_child(skeleton)
	_add_bone("pelvis", skeleton)
	_add_bone("torso", bones.pelvis)
	_add_bone("head", bones.torso)
	_add_bone("coat", bones.pelvis)
	for limb in LIMBS:
		var parent: Bone2D = bones.torso if limb.ends_with("arm") else bones.pelvis
		_add_bone(limb, parent)
		_add_bone(limb + "_lower", bones[limb])
		_add_bone(limb + "_end", bones[limb + "_lower"])
	_add_bone("weapon", bones.front_arm_end)
	for key in bones:
		var bone: Bone2D = bones[key]
		bone.rest = bone.transform

func _add_bone(id: String, parent: Node2D) -> void:
	var bone := Bone2D.new()
	bone.name = id
	bone.set_autocalculate_length_and_angle(false)
	bone.set_length(12)
	parent.add_child(bone)
	bones[id] = bone

func configure(id: String = "ronin") -> void:
	profile_id = id
	if not is_instance_valid(skeleton): return
	var base_path: String = "res://data/characters/ronin.json"
	profile = _read_profile(base_path)
	var path: String = id if id.begins_with("res://") or id.begins_with("user://") else "res://data/characters/" + id + ".json"
	if path != base_path:
		var custom: Dictionary = _read_profile(path)
		for key in custom:
			if custom[key] is Dictionary and profile.get(key) is Dictionary:
				profile[key].merge(custom[key], true)
			else: profile[key] = custom[key]
	for mesh in meshes.values():
		mesh.get_parent().remove_child(mesh)
		mesh.queue_free()
	meshes.clear()
	var atlas: Texture2D = load(profile.get("atlas", "res://rig/parts.png"))
	var parts: Dictionary = profile.get("parts", {})
	_make_part("coat", "coat", parts, atlas, -4)
	_make_part("rear_leg", "thigh", parts, atlas, -2)
	_make_part("rear_leg_lower", "shin", parts, atlas, -2)
	_make_part("rear_leg_end", "boot", parts, atlas, -2)
	_make_part("rear_arm", "upper_arm", parts, atlas, -1)
	_make_part("rear_arm_lower", "forearm", parts, atlas, -1)
	_make_part("rear_arm_end", "hand", parts, atlas, -1)
	_make_part("pelvis", "pelvis", parts, atlas, 0)
	_make_part("front_leg", "thigh", parts, atlas, 1)
	_make_part("front_leg_lower", "shin", parts, atlas, 1)
	_make_part("front_leg_end", "boot", parts, atlas, 1)
	_make_part("torso", "torso", parts, atlas, 3)
	_make_part("head", "wraith_head" if profile.get("head_part", "head") == "wraith_head" else "head", parts, atlas, 7)
	_make_part("front_arm", "upper_arm", parts, atlas, 5)
	_make_part("front_arm_lower", "forearm", parts, atlas, 5)
	_make_part("front_arm_end", "hand", parts, atlas, 6)
	_make_part("weapon", "weapon", parts, atlas, 8)
	var tint: Array = profile.get("tint", [1,1,1,1])
	skeleton.modulate = Color(float(tint[0]), float(tint[1]), float(tint[2]), float(tint[3]))
	_configured = true
	for limb in LIMBS:
		var first_key: String = "upper_arm" if limb.ends_with("arm") else "thigh"
		var second_key: String = "forearm" if limb.ends_with("arm") else "shin"
		bones[limb].set_length(float(profile.lengths[first_key]))
		bones[limb + "_lower"].set_length(float(profile.lengths[second_key]))
	phase = 0
	motion_blend = 0
	_last_pose.clear()
	_transition_from.clear()
	_transition_left = 0
	update_pose(0, "idle", current_facing, Vector2.ZERO, true)
	for bone in bones.values(): bone.rest = bone.transform

func _read_profile(path: String) -> Dictionary:
	if not FileAccess.file_exists(path): return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed if parsed is Dictionary else {}

func _make_part(bone_id: String, part_id: String, parts: Dictionary, atlas: Texture2D, layer: int) -> void:
	if not parts.has(part_id): return
	var part: Dictionary = parts[part_id]
	var rect: Array = part.rect
	var dimensions: Array = part.size
	var anchor: Array = part.pivot
	var w: float = float(dimensions[0])
	var h: float = float(dimensions[1])
	var lengths: Dictionary = profile.get("lengths", {})
	var widths: Dictionary = profile.get("widths", {})
	if widths.has(part_id): w = float(widths[part_id])
	if part_id in ["thigh", "shin", "upper_arm", "forearm"]:
		h = float(lengths.get(part_id, h - 4)) + 4
	var mesh := Polygon2D.new()
	mesh.name = part_id + "_mesh"
	mesh.texture = atlas
	mesh.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mesh.antialiased = false
	var offset := Vector2(-w * float(anchor[0]), -h * float(anchor[1]))
	mesh.polygon = PackedVector2Array([offset, offset + Vector2(w,0), offset + Vector2(w,h), offset + Vector2(0,h)])
	var uv_rect := Rect2(float(rect[0]), float(rect[1]), float(rect[2]), float(rect[3]))
	mesh.uv = PackedVector2Array([uv_rect.position, uv_rect.position + Vector2(uv_rect.size.x,0), uv_rect.end, uv_rect.position + Vector2(0,uv_rect.size.y)])
	mesh.z_index = layer
	bones[bone_id].add_child(mesh)
	meshes[bone_id] = mesh

static func solve_two_bone(origin: Vector2, target: Vector2, first_length: float, second_length: float, bend: float = 1.0) -> Array[Vector2]:
	var delta: Vector2 = target - origin
	var distance: float = clampf(delta.length(), absf(first_length - second_length) + 0.01, first_length + second_length - 0.01)
	var forward: Vector2 = delta.normalized() if delta.length_squared() > 0.0001 else Vector2.DOWN
	var along: float = (first_length * first_length - second_length * second_length + distance * distance) / (2 * distance)
	var perpendicular: Vector2 = Vector2(-forward.y, forward.x) * signf(bend)
	var elbow: Vector2 = origin + forward * along + perpendicular * sqrt(maxf(0, first_length * first_length - along * along))
	return [elbow, origin + forward * distance]

func update_pose(delta: float, state: String, facing: float, velocity: Vector2, grounded: bool, action_progress: float = 0, reaction: float = 0) -> void:
	if not _configured: return
	if state != current_state and not _last_pose.is_empty():
		_transition_from = _last_pose.duplicate()
		_transition_left = TRANSITION_DURATION
	current_state = state
	var facing_sign: float = -1 if facing < 0 else 1
	if facing_sign != current_facing:
		impact_speed += 0.7 * facing_sign
	current_facing = facing_sign
	pivot.scale.x = facing_sign
	var dt: float = minf(delta, 0.05)
	impact_speed += (-48 * impact_angle - 12 * impact_speed) * dt
	impact_angle += impact_speed * dt
	pivot.rotation = external_roll
	motion_blend = lerpf(motion_blend, clampf(absf(velocity.x) / 300.0, 0, 1), 1 - exp(-14 * dt))
	var previous_phase: float = phase
	phase = fposmod(phase + absf(velocity.x) * dt / 90.90909, 1)
	if grounded and absf(velocity.x) > 20 and state in ["run", "walk"]:
		if phase < previous_phase or (previous_phase < 0.5 and phase >= 0.5):
			foot_contact.emit()
	var lengths: Dictionary = profile.lengths
	var thigh: float = float(lengths.thigh)
	var shin: float = float(lengths.shin)
	var torso_length: float = float(lengths.torso)
	var hip_height: float = thigh + shin - 1
	var hip := Vector2(0, -hip_height + sin(phase * TAU * 2) * 1.4 * motion_blend)
	var lean: float = motion_blend * 0.14 + impact_angle + reaction * 0.20
	var front_foot := Vector2(8, -8)
	var rear_foot := Vector2(-8, -8)
	if grounded:
		front_foot = _gait_foot(phase, true).lerp(front_foot, 1 - motion_blend)
		rear_foot = _gait_foot(fposmod(phase + 0.5, 1), false).lerp(rear_foot, 1 - motion_blend)
	else:
		front_foot = hip + Vector2(19, 39)
		rear_foot = hip + Vector2(-17, 43)
		lean -= 0.12
	var hand_front: Vector2 = hip + Vector2(13, -3)
	var hand_rear: Vector2 = hip + Vector2(-11, -4)
	var weapon_angle: float = -0.25
	var pulse: float = sin(clampf(action_progress, 0, 1) * PI)
	if profile.get("id", "") == "wraith":
		for key in ["rear_leg", "rear_leg_lower", "rear_leg_end", "front_leg", "front_leg_lower", "front_leg_end"]:
			if meshes.has(key): meshes[key].visible = false
		if meshes.has("weapon"): meshes.weapon.visible = false
		hand_front = hip + Vector2(31,-12)
		hand_rear = hip + Vector2(-29,-9)
		lean += sin(phase * TAU) * 0.07
	match state:
		"crouch":
			hip.y += 20
			lean += 0.28
			front_foot = Vector2(18,-8)
			rear_foot = Vector2(-18,-8)
		"dash":
			hip.y += 11
			lean += 0.55
			hand_front = hip + Vector2(-18,-14)
			hand_rear = hip + Vector2(-28,-9)
			front_foot = hip + Vector2(28,34)
			rear_foot = hip + Vector2(-30,30)
		"kick", "fire_kick":
			lean = -0.28 * pulse + impact_angle
			hip.x -= 7 * pulse
			front_foot = hip + Vector2(48 * pulse + 8, (1-pulse) * 32 - 4)
			rear_foot = Vector2(-10,-8)
			hand_front = hip + Vector2(-19, -12)
			hand_rear = hip + Vector2(-22,-21)
			weapon_angle = 0.5
		"sword", "attack", "charged", "power":
			var swing: float = smoothstep(0.05, 0.6, action_progress)
			lean += 0.25 * pulse
			hand_front = hip + Vector2(lerpf(-17,39,swing), lerpf(-46,-9,swing))
			hand_rear = hand_front + Vector2(-9,5)
			weapon_angle = lerpf(2.65,-0.8,swing)
		"charge":
			hand_front = hip + Vector2(9,-40)
			hand_rear = hand_front + Vector2(-8,7)
			weapon_angle = 2.7
		"plunge":
			hand_front = hip + Vector2(14,7)
			hand_rear = hip + Vector2(4,2)
			weapon_angle = -0.15
		"hurt", "launched":
			lean += -0.32
			hand_front = hip + Vector2(26,-14)
			hand_rear = hip + Vector2(-26,-17)
		"death":
			lean -= 0.45
	if state == "run" or state == "walk":
		hand_front += Vector2(-sin(phase * TAU) * 11, -absf(sin(phase * TAU)) * 5)
		hand_rear += Vector2(sin(phase * TAU) * 11, -absf(sin(phase * TAU)) * 5)
	if _transition_left > 0 and not _transition_from.is_empty():
		_transition_left = maxf(0, _transition_left - delta)
		var blend: float = smoothstep(0, 1, 1 - _transition_left / TRANSITION_DURATION)
		hip = Vector2(_transition_from.get("hip", hip)).lerp(hip, blend)
		hand_front = Vector2(_transition_from.get("hand_front", hand_front)).lerp(hand_front, blend)
		hand_rear = Vector2(_transition_from.get("hand_rear", hand_rear)).lerp(hand_rear, blend)
		lean = lerp_angle(float(_transition_from.get("lean", lean)), lean, blend)
		weapon_angle = lerp_angle(float(_transition_from.get("weapon_angle", weapon_angle)), weapon_angle, blend)
		# Blend action targets before solving limbs. Ordinary run stance stays owned
		# by its contact curve; smoothing every gait frame would make the feet slide.
		if state not in ["run", "walk"]:
			front_foot = Vector2(_transition_from.get("front_foot", front_foot)).lerp(front_foot, blend)
			rear_foot = Vector2(_transition_from.get("rear_foot", rear_foot)).lerp(rear_foot, blend)
			if grounded and state not in ["dash", "kick", "fire_kick"]:
				front_foot.y = -8
				rear_foot.y = -8
			elif grounded and state in ["kick", "fire_kick"]:
				rear_foot.y = -8
	_place_joint("pelvis", hip, 0)
	_place_joint("torso", hip, lean)
	var shoulder: Vector2 = hip + Vector2(0,-torso_length).rotated(lean)
	_place_joint("head", shoulder + Vector2(0,-2), lean * 0.3)
	_place_joint("coat", hip + Vector2(-2,-4), -lean * 0.35 + sin(phase * TAU - 0.5) * motion_blend * 0.12)
	_pose_limb("rear_leg", hip + Vector2(-5,0), rear_foot, thigh, shin, -1)
	_pose_limb("front_leg", hip + Vector2(5,0), front_foot, thigh, shin, -1)
	_pose_limb("rear_arm", shoulder + Vector2(-7,5), hand_rear, float(lengths.upper_arm), float(lengths.forearm), 1)
	_pose_limb("front_arm", shoulder + Vector2(7,5), hand_front, float(lengths.upper_arm), float(lengths.forearm), 1)
	_place_joint("weapon", joints.front_arm_end, weapon_angle)
	joints.chest = hip.lerp(shoulder, 0.65)
	joints.hand = joints.front_arm_end
	joints.foot = joints.front_leg_end + Vector2(10,8)
	joints.weapon_tip = joints.hand + Vector2(0,53).rotated(weapon_angle)
	_last_pose = {"hip":hip,"front_foot":front_foot,"rear_foot":rear_foot,"hand_front":hand_front,"hand_rear":hand_rear,"lean":lean,"weapon_angle":weapon_angle,"grounded":grounded}
	queue_redraw()

func _gait_foot(cycle: float, _front: bool) -> Vector2:
	if cycle < 0.55:
		return Vector2(lerpf(25,-25,cycle / 0.55), -8)
	var swing: float = (cycle - 0.55) / 0.45
	return Vector2(lerpf(-25,25,smoothstep(0,1,swing)), -8 - sin(swing * PI) * 18)

func _pose_limb(id: String, origin: Vector2, endpoint: Vector2, first: float, second: float, bend: float) -> void:
	var solved: Array[Vector2] = solve_two_bone(origin, endpoint, first, second, bend)
	_place_joint(id, origin, (solved[0] - origin).angle() - PI/2)
	_place_joint(id + "_lower", solved[0], (solved[1] - solved[0]).angle() - PI/2)
	_place_joint(id + "_end", solved[1], 0)

func _place_joint(id: String, at: Vector2, angle: float) -> void:
	var bone: Bone2D = bones[id]
	var parent: Node2D = bone.get_parent()
	var parent_in_skeleton: Transform2D = skeleton.global_transform.affine_inverse() * parent.global_transform
	bone.position = parent_in_skeleton.affine_inverse() * at
	bone.rotation = angle - parent_in_skeleton.get_rotation()
	joints[id] = at

func socket(id: String) -> Vector2:
	if not is_instance_valid(skeleton): return Vector2.ZERO
	var key: String = {"hand_r":"hand", "foot_r":"foot", "hip":"pelvis"}.get(id, id)
	var at: Vector2 = joints.get(key, Vector2(0,-58))
	return to_local(skeleton.to_global(at))

func apply_impact(direction: Vector2, strength: float) -> void:
	impact_speed += clampf(strength / 160.0, 0.3, 3.0) * signf(direction.x if absf(direction.x) > 0.1 else 1) * current_facing

func set_debug(enabled: bool) -> void:
	debug_enabled = enabled
	queue_redraw()

func _draw() -> void:
	if not debug_enabled or not _configured: return
	for limb in LIMBS:
		for pair in [[limb,limb+"_lower"],[limb+"_lower",limb+"_end"]]:
			draw_line(socket(pair[0]), socket(pair[1]), Color(0.2,1,0.85,0.85), 1)
	for id in joints:
		draw_circle(socket(id), 2, Color(1,0.75,0.3))
