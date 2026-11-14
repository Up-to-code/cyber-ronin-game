class_name CelActorVisual
extends Node2D
## Whole-character drawings with controller-owned action time.
## Loops alone have a local time/distance clock; actions never run a second timer.
signal foot_contact
signal frame_event(event: String, at: Vector2)
const AttackSpec = preload("res://animation/attack_spec.gd")
var profile: Dictionary = {}
var profile_id: String = "ronin_cel"
var sprite: AnimatedSprite2D
var body_pivot: Node2D
var current_clip: String = ""
var current_frame: int = 0
var current_state: String = "idle"
var current_facing: float = 1
var external_roll: float = 0
## Presentation-only scale around the feet. Controllers may squash/stretch the
## drawn cel for takeoff/landing without touching collision or hit sockets.
var pose_scale := Vector2.ONE
var idle_breath_scale := Vector2.ONE
var debug_enabled: bool = false
var _clock: float = 0
var _breath_clock: float = 0
var _stop_age: float = 1.0
var _drive_age: float = 1.0
var _turn_age: float = 1.0
var _distance: float = 0
var _phase: float = 0
var _last_event_frame: int = -1
var _impact: float = 0
var _impact_direction := Vector2.ZERO
var _frames: Dictionary = {}
var _configured: bool = false
func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	body_pivot = Node2D.new()
	body_pivot.name = "BodyCenter"
	add_child(body_pivot)
	sprite = AnimatedSprite2D.new()
	sprite.name = "AuthoredCharacter"
	sprite.centered = false
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	body_pivot.add_child(sprite)
	configure(profile_id)
func configure(id_or_path: String = "ronin_cel") -> bool:
	if not is_instance_valid(sprite): return false
	var path: String = id_or_path if id_or_path.begins_with("res://") or id_or_path.begins_with("user://") else "res://animation/profiles/" + id_or_path + ".json"
	if not FileAccess.file_exists(path):
		push_error("Cel character profile missing: " + path)
		return false
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not parsed is Dictionary or not parsed.has("clips"):
		push_error("Invalid cel character profile: " + path)
		return false
	var next_profile: Dictionary = parsed
	if not next_profile.clips.has("idle"):
		push_error("Cel character requires an idle clip: " + path)
		return false
	var library := SpriteFrames.new()
	library.remove_animation("default")
	var next_frames: Dictionary = {}
	for clip_name in next_profile.clips:
		var clip: Dictionary = next_profile.clips[clip_name]
		var atlas_path: String = clip.get("atlas", next_profile.get("atlas", ""))
		if not ResourceLoader.exists(atlas_path):
			push_error("Cel atlas missing: " + atlas_path)
			return false
		var atlas: Texture2D = load(atlas_path)
		library.add_animation(clip_name)
		library.set_animation_loop(clip_name, bool(clip.get("loop", false)))
		var records: Array = clip.get("frames", [])
		if records.is_empty():
			push_error("Cel clip has no authored frames: " + str(clip_name))
			return false
		for record in records:
			var rect: Array = record.rect
			var texture := AtlasTexture.new()
			texture.atlas = atlas
			texture.region = Rect2(float(rect[0]),float(rect[1]),float(rect[2]),float(rect[3]))
			library.add_frame(clip_name, texture, maxf(1, float(record.get("duration_ms", 100))) / 100.0)
		next_frames[clip_name] = records
	profile = next_profile
	profile_id = id_or_path
	_frames = next_frames
	sprite.sprite_frames = library
	sprite.pause()
	_configured = true
	_clock = 0
	_distance = 0
	pose_scale = Vector2.ONE
	current_clip = ""
	update_pose(0, "idle", 1, Vector2.ZERO, true)
	return true
func get_attack_spec(kind: String, combo: int = 1) -> Dictionary:
	return AttackSpec.resolve(profile, kind, combo)
func update_pose(delta: float, state: String, facing: float, velocity: Vector2, grounded: bool, progress: float = 0, reaction: float = 0, variant: int = 1) -> void:
	if not _configured: return
	if state == "idle" and current_state in ["run","walk"]: _stop_age = 0.0
	if grounded and state in ["run","walk"]:
		if current_state == "idle": _drive_age = 0.0
		if signf(facing) != current_facing: _turn_age = 0.0
	_drive_age += maxf(delta,0)
	_turn_age += maxf(delta,0)
	_stop_age += maxf(delta,0)
	_breath_clock += maxf(delta,0)
	current_state = state
	current_facing = -1 if facing < 0 else 1
	var clip_name: String = _clip_for(state, variant)
	if not _frames.has(clip_name): clip_name = "idle"
	var clip: Dictionary = profile.clips[clip_name]
	var changed: bool = clip_name != current_clip
	if changed:
		current_clip = clip_name
		_clock = 0
		_last_event_frame = -1
	_clock += maxf(0, delta)
	var previous_phase: float = _phase
	var advance: float = 0
	if state in ["run", "walk"] and grounded:
		advance = absf(velocity.x) * maxf(0, delta) / maxf(1, float(clip.get("stride_world", 180)))
		_distance += advance
		_phase = fposmod(_distance, 1)
		_emit_contact_crossings(previous_phase if not changed else _phase - advance, advance, clip)
	elif bool(clip.get("loop", false)):
		_phase = fposmod(_clock * 1000.0 / _duration_ms(clip), 1)
	elif state == "hurt":
		_phase = clampf(1 - reaction, 0, 1)
	elif clip.has("hold_progress"):
		_phase = clampf(float(clip.hold_progress), 0, 1)
	else:
		_phase = clampf(progress, 0, 1)
	current_frame = frame_at_progress(clip_name, _phase)
	sprite.animation = clip_name
	sprite.pause()
	sprite.set_frame_and_progress(current_frame, 0)
	sprite.flip_h = current_facing < 0
	var record: Dictionary = _frames[clip_name][current_frame]
	var origin: Vector2 = _origin(record, clip)
	var rect: Array = record.rect
	var mirror_origin: Vector2 = Vector2(float(rect[2]) - origin.x, origin.y) if current_facing < 0 else origin
	var art_scale: float = float(clip.get("scale", profile.get("scale", 2)))
	idle_breath_scale=Vector2.ONE
	if state=="idle" and grounded:
		var breath: float=sin(_breath_clock*TAU/2.4)
		idle_breath_scale=Vector2(1+breath*0.012,1-breath*0.022+sin(_breath_clock*TAU/4.8)*0.006)
		# A small damped compression/rebound after movement, anchored at the feet.
		var settle: float = sin(_stop_age * 18.0) * exp(-_stop_age * 9.0) * 0.045
		idle_breath_scale *= Vector2(1.0+settle*0.5,1.0-settle)
	if grounded and state in ["run","walk"]:
		# Small planted compression on push-off and reversal, never delay input.
		var drive: float = sin(minf(_drive_age/0.20,1.0)*PI)*0.025
		var turn: float = sin(minf(_turn_age/0.16,1.0)*PI)*0.035
		var stride: float = sin(_phase*TAU*2)*0.009
		idle_breath_scale = Vector2(1+(drive+turn)*0.4,1-drive-turn+stride)
	var applied_scale: Vector2=pose_scale*idle_breath_scale
	sprite.scale = Vector2.ONE * art_scale * applied_scale
	var center: float = float(profile.get("body_center_height", 58))
	body_pivot.position = Vector2(0,-center)
	# Optional bounded visual reaction; collision and impulses belong to the actor.
	_impact = maxf(0, _impact - delta * 8)
	body_pivot.rotation = clampf(external_roll, -float(profile.get("max_visual_roll", 0.35)), float(profile.get("max_visual_roll", 0.35))) if not grounded else 0
	# Anchor the drawn feet, not the inherited sprite corner: pose_scale must
	# stretch the cel around the feet so a squash never lifts or slides them.
	sprite.position = -mirror_origin * art_scale * applied_scale + Vector2(0,center) + (_impact_direction * _impact * 2).snapped(Vector2.ONE)
	if current_frame != _last_event_frame:
		for event in record.get("events", []):
			if event != "foot_contact": frame_event.emit(event, socket("foot" if str(event).begins_with("foot") else "hand"))
		_last_event_frame = current_frame
	queue_redraw()
func frame_at_progress(clip_name: String, progress: float) -> int:
	if not _frames.has(clip_name): return 0
	var records: Array = _frames[clip_name]
	var position_ms: float = clampf(progress,0,1) * _duration_ms(profile.clips[clip_name])
	var accumulated: float = 0
	for i in range(records.size()):
		accumulated += maxf(1, float(records[i].get("duration_ms",100)))
		if position_ms < accumulated: return i
	return records.size() - 1
func _clip_for(state: String, variant: int) -> String:
	if state in ["air_sword","moving_sword","drive_sword","turn_sword"]:
		return str(get_attack_spec(state,variant).get("clip","sword1"))
	if state in ["sword","attack"]:
		return str(get_attack_spec("sword",variant).get("clip","sword%d" % clampi(variant,1,4)))
	if profile.get("attacks",{}).has(state): return str(get_attack_spec(state).get("clip",state))
	var mapping: Dictionary = profile.get("state_map", {})
	return str(mapping.get(state, state))
func _duration_ms(clip: Dictionary) -> float:
	var result: float = 0
	for record in clip.get("frames",[]): result += maxf(1,float(record.get("duration_ms",100)))
	return maxf(1,result)
func _origin(record: Dictionary, clip: Dictionary) -> Vector2:
	var origin: Array = record.get("feet_origin", clip.get("feet_origin", profile.get("feet_origin", [48,87])))
	return Vector2(float(origin[0]),float(origin[1]))
func _emit_contact_crossings(previous_phase: float, advance: float, clip: Dictionary) -> void:
	if advance <= 0: return
	var records: Array = clip.frames
	var total: float = _duration_ms(clip)
	var elapsed: float = 0
	var start: float = fposmod(previous_phase,1)
	for record in records:
		if "foot_contact" in record.get("events",[]):
			var threshold: float = elapsed / total
			var first: int = int(floor(start - threshold)) + 1
			var last: int = int(floor(start + advance - threshold + 0.000001))
			for _crossing in range(first,last + 1): foot_contact.emit()
		elapsed += maxf(1,float(record.get("duration_ms",100)))
func feet_local() -> Vector2:
	## Where the drawn feet actually land in rig-local space. A landing squash
	## must keep this pinned to the actor's feet instead of drifting the pose.
	if not _configured or not _frames.has(current_clip): return Vector2.ZERO
	var clip: Dictionary = profile.clips[current_clip]
	var record: Dictionary = _frames[current_clip][current_frame]
	var origin: Vector2 = _origin(record, clip)
	var rect: Array = record.rect
	var mirror_origin: Vector2 = Vector2(float(rect[2]) - origin.x, origin.y) if current_facing < 0 else origin
	return body_pivot.transform * (sprite.position + mirror_origin * sprite.scale)
func socket(id: String) -> Vector2:
	if not _configured or not _frames.has(current_clip): return Vector2.ZERO
	var clip: Dictionary = profile.clips[current_clip]
	var record: Dictionary = _frames[current_clip][current_frame]
	var alias: String = {"hand_r":"hand","foot_r":"foot","hip":"pelvis"}.get(id,id)
	var value: Array = profile.get("sockets",{}).get(alias,[48,58])
	value = clip.get("sockets",{}).get(alias,value)
	value = record.get("sockets",{}).get(alias,value)
	var origin: Vector2 = _origin(record,clip)
	var art_scale: float = float(clip.get("scale",profile.get("scale",2)))
	var local := (Vector2(float(value[0]),float(value[1])) - origin) * art_scale * pose_scale * idle_breath_scale
	local.x *= current_facing
	var center: float = float(profile.get("body_center_height",58))
	return body_pivot.transform * (local + Vector2(0,center))
func apply_impact(direction: Vector2, strength: float) -> void:
	_impact_direction = direction.normalized()
	_impact = clampf(strength,0,1)
func set_debug(value: bool) -> void:
	debug_enabled = value
	queue_redraw()
func create_snapshot() -> Node2D:
	var monster_visual = get_meta("monster_cel_visual") if has_meta("monster_cel_visual") else null
	if is_instance_valid(monster_visual): return monster_visual.create_snapshot()
	var copy := Node2D.new()
	if not _configured: return copy
	var image := Sprite2D.new()
	image.texture = sprite.sprite_frames.get_frame_texture(current_clip,current_frame)
	image.centered = false
	image.flip_h = sprite.flip_h
	image.transform = body_pivot.transform * sprite.transform
	image.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	copy.add_child(image)
	return copy
func _draw() -> void:
	# Sparse looping ash keeps the ready stance alive without spawning nodes.
	if current_state == "idle":
		for i in range(5):
			var phase: float = fposmod(_clock * 0.28 + i * 0.2, 1.0)
			var point := Vector2(sin(phase * TAU + i) * 22, -12 - phase * 72).snapped(Vector2(2,2))
			draw_rect(Rect2(point,Vector2(2,2)),Color(0.9,0.35,0.27,sin(phase*PI)*0.38))
	if not debug_enabled: return
	draw_line(Vector2(-25,0),Vector2(25,0),Color(0.5,1,0.6),1)
	for id in ["hand","foot","weapon_tip","chest"]:
		draw_circle(socket(id),2,Color(1,0.7,0.3))
