extends CharacterBody2D

signal health_changed(current: int, maximum: int)
signal power_changed(current: float, maximum: float)
signal charge_changed(fraction: float)
signal state_changed(value: String)
signal fx_requested(kind: String, at: Vector2, direction: float)
signal projectile_requested(kind: String, at: Vector2, direction: Vector2, source: Node)
const Rules = preload("res://systems/world_rules.gd")

@export var walk_speed: float = 180.0
@export var run_speed: float = 300.0
@export var map_width: float = 2520.0
@export var ground_acceleration: float = 2400.0
@export var air_acceleration: float = 1650.0
@export var ground_friction: float = 3200.0
@export var coyote_window: float = 0.12
@export var jump_buffer_window: float = 0.14
@export var character_profile: String = "ronin_cel"

var health: int = 100
var max_health: int = 100
var facing: float = 1.0
var attack_aim := Vector2.RIGHT
var attack_time: float = 0.0
var attack_hit: bool = false
var attack_motion_played: bool = false
var dodge_time: float = 0.0
var dodge_cooldown: float = 0.0
var invulnerable: float = 0.0
var sprite: AnimatedSprite2D
var coyote_left: float = 0.0
var jump_buffer_left: float = 0.0
var attack_buffer_left: float = 0.0
var kick_buffer_left: float = 0.0
var low_kick: bool = false
var hurt_left: float = 0.0
var landing_left: float = 0.0
var dead: bool = false
var death_elapsed: float = 0.0
var takeoff_left: float = 0.0
var air_jump_pose_left: float = 0.0
var footstep_distance: float = 0.0
var footstep_count: int = 0
var sprinting: bool = false
var footstep_cooldown: float = 0.0
var dash_buffer_left: float = 0
var dash_vertical_speed: float = 0
var dash_trail_left: float = 0
var dash_direction: float = 1
var air_jumps_left: int = 1
var combo_step: int = 0
var combo_window_left: float = 0
var attack_duration: float = 0.30
var move_tap_left: float = 0
var move_tap_direction: float = 0
var power: float = 100
var max_power: float = 100
var power_regen_delay: float = 0
var attack_kind: String = "sword"
var attack_hold: float = 0
var charge_time: float = 0
var charge_fx_left: float = 0
var charging: bool = false
var plunging: bool = false
var plunge_fx_left: float = 0
var rig: Node2D
var crouching: bool = false
var crouch_collider: CollisionShape2D
var standing_height: float = 116
var current_attack_spec: Dictionary = {}
var attack_contact_progress: float = 0.30
const DASH_DURATION: float = 0.16
const ATTACK_DURATION: float = 0.30
const ATTACK_CONTACT: float = 0.09
const ATTACK_DAMAGE: int = 35

func _ready() -> void:
	add_to_group("player")
	process_mode = Node.PROCESS_MODE_PAUSABLE
	collision_layer = 2
	collision_mask = 1
	platform_floor_layers = 1
	platform_on_leave = CharacterBody2D.PLATFORM_ON_LEAVE_ADD_UPWARD_VELOCITY
	floor_snap_length = 8.0
	var collider := CollisionShape2D.new()
	var shape := CapsuleShape2D.new()
	shape.radius = 20.0
	shape.height = 116.0
	collider.shape = shape
	collider.position.y = -58.0
	add_child(collider)
	crouch_collider = collider
	sprite = AnimatedSprite2D.new()
	sprite.sprite_frames = preload("res://art/last-ronin/last-ronin.tres").duplicate()
	var kick_sheet: Texture2D = load("res://art/pixel/ronin_kick.png")
	sprite.sprite_frames.add_animation("kick")
	sprite.sprite_frames.set_animation_loop("kick", false)
	sprite.sprite_frames.set_animation_speed("kick", 16)
	for i in range(4):
		var kick_frame := AtlasTexture.new()
		kick_frame.atlas = kick_sheet
		kick_frame.region = Rect2(i * 96, 0, 96, 96)
		sprite.sprite_frames.add_frame("kick", kick_frame)
	sprite.offset = Vector2(0, -39)
	sprite.scale = Vector2(2, 2)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(sprite)
	_play("idle")
	if ResourceLoader.exists("res://animation/cel_actor_visual.gd"):
		rig = load("res://animation/cel_actor_visual.gd").new()
		add_child(rig)
		for arg in OS.get_cmdline_user_args():
			if arg.begins_with("--character="): character_profile = arg.trim_prefix("--character=")
		set_character_profile(character_profile)
		rig.foot_contact.connect(_on_rig_step)
		sprite.hide()

func _physics_process(delta: float) -> void:
	var grounded: bool = is_on_floor()
	var previous_fall_speed: float = velocity.y
	invulnerable = maxf(0.0, invulnerable - delta)
	dodge_cooldown = maxf(0.0, dodge_cooldown - delta)
	dash_buffer_left = maxf(0.0, dash_buffer_left - delta)
	jump_buffer_left = maxf(0.0, jump_buffer_left - delta)
	attack_buffer_left = maxf(0.0, attack_buffer_left - delta)
	kick_buffer_left = maxf(0.0, kick_buffer_left - delta)
	landing_left = maxf(0.0, landing_left - delta)
	takeoff_left = maxf(0.0, takeoff_left - delta)
	air_jump_pose_left = maxf(0.0, air_jump_pose_left - delta)
	footstep_cooldown = maxf(0.0, footstep_cooldown - delta)
	power_regen_delay = maxf(0, power_regen_delay - delta)
	if health > 0 and power_regen_delay <= 0 and power < max_power and not charging:
		power = minf(max_power, power + 12 * delta)
		power_changed.emit(power, max_power)
	move_tap_left = maxf(0, move_tap_left - delta)
	if attack_time <= 0:
		combo_window_left = maxf(0, combo_window_left - delta)
	if grounded and velocity.y >= 0.0:
		coyote_left = coyote_window
		air_jumps_left = 1
	else:
		coyote_left = maxf(0.0, coyote_left - delta)
	if health <= 0:
		death_elapsed += delta
		velocity.x = move_toward(velocity.x, 0.0, ground_friction * delta)
		velocity.y = Rules.fall(velocity.y, delta)
		move_and_slide()
		_update_visual_scale(delta)
		_update_rig(delta)
		return
	dead = false
	if Input.is_action_just_pressed("jump"):
		jump_buffer_left = 0.2 if dodge_time > 0 else jump_buffer_window
	if Input.is_action_just_pressed("kick"):
		# One pending kick survives recovery or a short dash, without auto-repeat.
		kick_buffer_left = maxf(0.18, attack_time + 0.08)
	if Input.is_action_just_pressed("attack"):
		# One queued strike: rapid tapping never builds an unbounded attack backlog.
		attack_buffer_left = maxf(0.20, attack_time + 0.08)
	if Input.is_action_pressed("attack"):
		attack_hold += delta
	else:
		if charging:
			var another_action: bool = Input.is_action_just_pressed("energy_attack") or Input.is_action_just_pressed("kick") or Input.is_action_just_pressed("power_attack") or Input.is_action_just_pressed("ranged_attack") or Input.is_action_just_pressed("dodge")
			var ready: bool = charge_time >= 0.44 and not another_action
			_cancel_charge()
			if ready and hurt_left <= 0 and dodge_time <= 0:
				_start_special("charged")
		attack_hold = 0
	var direction: float = Input.get_axis("move_left", "move_right")
	crouching = grounded and ((Input.is_action_pressed("move_down") and attack_time <= 0) or (low_kick and attack_kind == "kick" and attack_time > 0))
	if grounded and not crouching and crouch_collider.shape.height < standing_height:
		var overhead := PhysicsRayQueryParameters2D.create(global_position + Vector2(0,-45), global_position + Vector2(0,-standing_height), 1)
		crouching = not get_world_2d().direct_space_state.intersect_ray(overhead).is_empty()
	var body_height: float = standing_height - 22 if crouching else standing_height
	crouch_collider.shape.height = body_height
	crouch_collider.position.y = -body_height * 0.5
	# Mobile uses one reliable movement speed; no separate RUN control is needed.
	sprinting = true
	var travel_speed: float = run_speed
	if crouching: travel_speed *= 0.4
	if direction != 0.0 and attack_time <= 0.0 and dodge_time <= 0.0 and hurt_left <= 0.0:
		facing = signf(direction)
	sprite.flip_h = facing < 0.0
	if not grounded and dodge_time <= 0:
		velocity.y = Rules.fall(velocity.y, delta)
	elif velocity.y > 0.0:
		velocity.y = 0.0
	if jump_buffer_left > 0.0 and hurt_left <= 0.0 and dodge_time <= 0:
		if coyote_left > 0:
			_jump()
		elif not grounded and air_jumps_left > 0:
			_jump(true)
	if Input.is_action_just_released("jump") and velocity.y < -160.0:
		velocity.y *= 0.48
	if Input.is_action_just_pressed("dodge"):
		dash_buffer_left = 0.10
	var tapped_dash_direction: float = 0
	for action in ["move_left", "move_right"]:
		if Input.is_action_just_pressed(action):
			var tapped: float = -1.0 if action == "move_left" else 1.0
			if move_tap_left > 0 and move_tap_direction == tapped:
				dash_buffer_left = 0.10
				tapped_dash_direction = tapped
				move_tap_left = 0
			else:
				move_tap_left = 0.23
				move_tap_direction = tapped
	if dash_buffer_left > 0 and dodge_cooldown <= 0.0 and hurt_left <= 0.0:
		_cancel_charge()
		plunging = false
		dash_buffer_left = 0
		attack_time = 0.0
		attack_buffer_left = 0.0
		combo_window_left = 0
		dodge_time = DASH_DURATION
		dodge_cooldown = 0.56
		dash_direction = tapped_dash_direction if tapped_dash_direction != 0 else facing
		facing = dash_direction
		sprite.flip_h = facing < 0
		dash_vertical_speed = velocity.y
		dash_trail_left = 0.035
		invulnerable = DASH_DURATION
		_audio("dodge")
		fx_requested.emit("dodge", global_position, facing)
		_dash_pose()
	if Input.is_action_just_pressed("energy_attack") and hurt_left <= 0 and dodge_time <= 0 and attack_time <= 0:
		_cancel_charge()
		_start_special("energy")
	elif Input.is_action_just_pressed("power_attack") and hurt_left <= 0 and dodge_time <= 0 and attack_time <= 0:
		_cancel_charge()
		_start_special("power")
	elif Input.is_action_just_pressed("ranged_attack") and hurt_left <= 0 and dodge_time <= 0 and attack_time <= 0:
		_cancel_charge()
		_start_special("ranged")
	elif kick_buffer_left > 0 and hurt_left <= 0 and dodge_time <= 0 and attack_time <= 0:
		_cancel_charge()
		_start_special("kick")
	if attack_hold > 0.32 and attack_time <= 0 and dodge_time <= 0 and hurt_left <= 0 and not plunging and power >= 30:
		if not charging:
			charging = true
			_audio("charge")
		charge_time = minf(0.45, charge_time + delta)
		charge_changed.emit(charge_time / 0.45)
		charge_fx_left -= delta
		if charge_fx_left <= 0:
			charge_fx_left = 0.12
			fx_requested.emit("charge", global_position + Vector2(facing * 28, -46), facing)
	# A second tap can leave recovery only after the active cel and follow-through.
	# No extra contact or phantom damage is created by the visual combo sweep.
	if attack_buffer_left > 0 and attack_time > 0 and attack_kind=="sword" and attack_hit and not plunging:
		var active_end: float=attack_duration*float(current_attack_spec.get("active_end_progress",attack_contact_progress))
		if attack_duration-attack_time >= Rules.combo_recovery_time(active_end): attack_time=0
	if attack_buffer_left > 0.0 and attack_time <= 0.0 and dodge_time <= 0.0 and hurt_left <= 0.0:
		_start_attack()
	if hurt_left > 0.0:
		hurt_left -= delta
		velocity.x = move_toward(velocity.x, 0.0, Rules.recoil_drag(grounded) * delta)
	elif dodge_time > 0.0:
		dodge_time = maxf(0.0, dodge_time - delta)
		var burst: float = 780.0 if dodge_time > 0.035 else 600.0
		velocity.x = dash_direction * burst
		velocity.y = 0
		_dash_pose()
		dash_trail_left -= delta
		if dash_trail_left <= 0:
			dash_trail_left += 0.035
			fx_requested.emit("dash_trail", global_position, dash_direction)
		if dodge_time <= 0:
			velocity.y = clampf(dash_vertical_speed, -300, 400)
	elif attack_time > 0.0:
		attack_time = maxf(0.0, attack_time - delta)
		# These authored ground cuts/kicks plant a support foot. Held movement
		# resumes after recovery; aerial actions retain a little steering.
		velocity.x = move_toward(velocity.x, 0.0 if grounded else direction * travel_speed * 0.32, ground_friction * delta)
		# Motion peaks at the authored strike, while contact still owns damage/VFX.
		var motion_cue: String = _attack_motion_cue()
		var audio: Node = get_node_or_null("/root/Audio")
		var lead: float = audio.motion_lead(motion_cue) if audio else 0.0
		var contact_time: float = attack_duration * attack_contact_progress
		if not attack_motion_played and not plunging and attack_duration - attack_time >= maxf(0.0, contact_time - lead):
			attack_motion_played = true
			_audio(motion_cue)
		if not attack_hit and 1.0 - attack_time / maxf(0.01, attack_duration) >= attack_contact_progress and not plunging:
			attack_hit = true
			var slash_kind: String = attack_kind if attack_kind != "sword" else ("finisher" if combo_step == 3 else ("slash_reverse" if combo_step == 2 else "slash"))
			# Resolve sockets from the displayed contact pose, not the previous tick.
			_update_rig(0)
			attack_aim = read_attack_aim()
			var attack_socket: Vector2 = global_position + Vector2(facing * 46, -42)
			if is_instance_valid(rig): attack_socket = global_position + rig.socket("foot" if attack_kind == "kick" else "hand")
			if absf(attack_aim.y) > 0.1:
				attack_socket = global_position + Vector2(0,-48) + attack_aim * 46
			fx_requested.emit(slash_kind, attack_socket, facing)
			var wall_contact: Dictionary = {}
			if attack_kind == "kick":
				var probe := PhysicsRayQueryParameters2D.create(Vector2(global_position.x, attack_socket.y), attack_socket + Vector2(facing * 12, 0), 1)
				wall_contact = get_world_2d().direct_space_state.intersect_ray(probe)
				if not wall_contact.is_empty():
					velocity.x = -facing * 90
					_audio("push")
					fx_requested.emit("impact", wall_contact.position, -facing)
					if is_instance_valid(rig): rig.apply_impact(Vector2(-facing,0),0.3)

			if attack_kind in ["ranged", "energy"]:
				projectile_requested.emit("energy" if attack_kind == "energy" else "blade", global_position + Vector2(0, -52) + attack_aim * 8, attack_aim, self)
			var reach: float = float(current_attack_spec.get("reach", {"kick":85.0, "power":210.0, "charged":180.0}.get(attack_kind,150 if combo_step>=2 else 118)))
			var damage: int = int(current_attack_spec.get("damage", {"kick":20,"power":90,"charged":60}.get(attack_kind,45 if combo_step==3 else ATTACK_DAMAGE)))
			for enemy in get_tree().get_nodes_in_group("enemies") if attack_kind not in ["ranged", "energy"] else []:
				var distance: Vector2 = enemy.global_position - global_position
				var vertical_contact: bool = absf(distance.y) < 80.0
				if attack_kind == "kick":
					# Test the foot against the target torso, not two feet origins.
					vertical_contact = attack_socket.y >= enemy.global_position.y - 128 and attack_socket.y <= enemy.global_position.y + 16
				var directional_contact: bool = absf(distance.x) < reach and vertical_contact and distance.x * facing > -10.0
				if absf(attack_aim.y) > 0.1 and attack_kind != "power":
					var target_delta: Vector2 = enemy.global_position + Vector2(0,-48) - (global_position + Vector2(0,-48))
					directional_contact = target_delta.dot(attack_aim) > -10 and target_delta.dot(attack_aim) < reach and absf(target_delta.cross(attack_aim)) < 65
				if directional_contact and wall_contact.is_empty():
					var kind: String = ("finisher" if combo_step==3 else ("double" if combo_step==2 else "sword")) if attack_kind=="sword" else attack_kind
					if enemy.has_method("receive_hit"):
						enemy.receive_hit(damage, kind, facing, attack_socket)
					else: enemy.take_damage(damage)
	else:
		var acceleration: float = ground_acceleration if grounded else air_acceleration
		var friction: float = ground_friction if grounded else 350.0
		velocity.x = move_toward(velocity.x, direction * travel_speed, acceleration * delta if direction != 0.0 else friction * delta)
		if charging:
			_play("block", 1.0)
		elif grounded:
			if absf(velocity.x) > 20.0:
				var gait: String = "run" if sprinting else "walk"
				_play(gait, 2.0 * clampf(absf(velocity.x) / travel_speed, 0.55, 1.1))
			elif landing_left > 0.0:
				_landing_pose()
			else:
				_play("idle")
		else:
			_air_pose()
	sprite.modulate = Color(1.25, 1.1, 0.95) if dodge_time > 0 else (Color(1.7, 1.35, 1.1, 0.7) if invulnerable > 0.0 else Color.WHITE)
	if plunging and hurt_left <= 0:
		velocity.y = 850
		velocity.x *= 0.8
		plunge_fx_left -= delta
		if plunge_fx_left <= 0:
			plunge_fx_left = 0.07
			fx_requested.emit("plunge_trail", global_position + Vector2(0, -38), facing)
		_air_pose()
	var landed_from_plunge: bool = plunging
	move_and_slide()
	if plunging and is_on_floor():
		plunging = false
		attack_time = 0.22
		attack_hit = true
		_audio("aerial_land")
		fx_requested.emit("aerial_land", global_position, facing)
		for enemy in get_tree().get_nodes_in_group("enemies"):
			if absf(enemy.global_position.x - global_position.x) < 145 and absf(enemy.global_position.y - global_position.y) < 75:
				enemy.receive_hit(55, "plunge", facing, global_position)
	if dodge_time > 0 and is_on_wall():
		dodge_time = 0
		velocity.y = clampf(dash_vertical_speed, -300, 400)
	if not grounded and is_on_floor():
		coyote_left = coyote_window
		air_jumps_left = 1
		if previous_fall_speed > 150.0:
			landing_left = 0.13
			if not landed_from_plunge: _audio("land_heavy" if previous_fall_speed >= 550 else "land_light")
			fx_requested.emit("land", global_position, facing)
		if jump_buffer_left > 0.0:
			_jump()
	if is_on_floor() and absf(velocity.x) > 30.0 and attack_time <= 0.0 and dodge_time <= 0.0 and hurt_left <= 0.0:
		footstep_distance += absf(velocity.x) * delta
	elif not is_on_floor():
		footstep_distance = 0.0
	_update_visual_scale(delta)
	_update_rig(delta)
	position.x = clampf(position.x, 24.0, maxf(24.0, map_width - 24.0))
	if position.y > 950.0:
		invulnerable = 0.0
		take_damage(max_health)

func _start_attack() -> void:
	_cancel_charge()
	attack_buffer_left = 0
	attack_kind = "sword"
	if not is_on_floor() and Input.is_action_pressed("move_down"):
		attack_kind = "plunge"
		plunging = true
		plunge_fx_left = 0
	combo_step = combo_step % 3 + 1 if combo_window_left > 0 else 1
	combo_window_left = 0.40
	attack_duration = 0.36 if combo_step == 3 else (0.28 if combo_step == 2 else ATTACK_DURATION)
	attack_time = attack_duration
	attack_hit = false
	attack_motion_played = false
	_apply_attack_spec("sword", combo_step)
	var clip: String = "attack" if combo_step == 1 else "attack%d" % combo_step
	var frames: SpriteFrames = sprite.sprite_frames
	var speed: float = frames.get_frame_count(clip) / (frames.get_animation_speed(clip) * attack_duration)
	sprite.stop()
	_play(clip, speed)

func _start_special(kind: String) -> bool:
	var cost: float = 50 if kind == "power" else (30 if kind == "charged" else (35 if kind == "energy" else (25 if kind == "ranged" else 0)))
	if power < cost:
		_audio("power_empty")
		fx_requested.emit("power_empty", global_position + Vector2(0, -45), facing)
		return false
	power -= cost
	if cost > 0:
		power_regen_delay = 1.0
		power_changed.emit(power, max_power)
	low_kick = kind == "kick" and crouching and is_on_floor()
	if kind == "kick": kick_buffer_left = 0
	attack_kind = kind
	attack_buffer_left = 0
	combo_step = 0
	combo_window_left = 0
	plunging = false
	attack_duration = 0.28 if kind == "kick" else 0.48
	attack_time = attack_duration
	attack_hit = false
	attack_motion_played = false
	_apply_attack_spec("ranged" if kind == "energy" else kind, 1)
	var clip: String = "kick" if kind == "kick" and sprite.sprite_frames.has_animation("kick") else ("attack3" if kind != "kick" else "attack2")
	var frames: SpriteFrames = sprite.sprite_frames
	sprite.stop()
	_play(clip, frames.get_frame_count(clip) / (frames.get_animation_speed(clip) * attack_duration))
	return true

func _apply_attack_spec(kind: String, variant: int) -> void:
	current_attack_spec = rig.get_attack_spec(kind, variant) if is_instance_valid(rig) and rig.has_method("get_attack_spec") else {}
	attack_contact_progress = float(current_attack_spec.get("contact_progress", ATTACK_CONTACT / attack_duration))
	attack_duration = float(current_attack_spec.get("duration", attack_duration))
	attack_time = attack_duration

func _cancel_charge() -> void:
	if charging:
		var audio := get_node_or_null("/root/Audio")
		if audio and audio.has_method("stop_cue"): audio.stop_cue("charge")
	charging = false
	charge_time = 0
	charge_fx_left = 0
	charge_changed.emit(0)

func cancel_pending_input() -> void:
	_cancel_charge()
	attack_hold = 0
	kick_buffer_left = 0
	attack_buffer_left = 0
	jump_buffer_left = 0
	dash_buffer_left = 0
	move_tap_left = 0

func _jump(air_jump: bool = false) -> void:
	if plunging:
		plunging = false
		attack_time = 0
	jump_buffer_left = 0.0
	coyote_left = 0.0
	if air_jump:
		air_jumps_left -= 1
		air_jump_pose_left = 0.30
	velocity.y = Rules.jump_velocity() * (0.9 if air_jump else 1.0)
	landing_left = 0.0
	takeoff_left = 0.09
	air_jump_pose_left = 0.30 if air_jump else 0.0
	footstep_distance = 0.0
	_audio("air_jump" if air_jump else "jump")
	fx_requested.emit("air_jump" if air_jump else "jump", global_position, facing)
	if attack_time <= 0.0 and dodge_time <= 0.0:
		_air_pose()

func reset_motion_presentation() -> void:
	cancel_pending_input()
	dead = false
	invulnerable = 0
	dodge_cooldown = 0
	death_elapsed = 0
	kick_buffer_left = 0
	low_kick = false
	crouching = false
	attack_time = 0
	attack_hit = false
	attack_motion_played = false
	dodge_time = 0
	hurt_left = 0
	if is_instance_valid(crouch_collider):
		crouch_collider.shape.height = standing_height
		crouch_collider.position.y = -standing_height * 0.5
	_cancel_charge()
	power = max_power
	power_regen_delay = 0
	power_changed.emit(power, max_power)
	attack_hold = 0
	plunging = false
	attack_kind = "sword"
	landing_left = 0.0
	takeoff_left = 0.0
	air_jump_pose_left = 0.0
	footstep_distance = 0.0
	footstep_count = 0
	footstep_cooldown = 0.0
	sprinting = false
	dash_buffer_left = 0
	dash_trail_left = 0
	dash_vertical_speed = 0
	air_jumps_left = 1
	combo_step = 0
	combo_window_left = 0
	move_tap_left = 0
	jump_buffer_left = 0
	attack_buffer_left = 0
	if is_instance_valid(sprite):
		sprite.scale = Vector2(2, 2)
		sprite.modulate = Color.WHITE
	if is_instance_valid(rig):
		rig.external_roll = 0
		rig.pose_scale = Vector2.ONE
		rig.modulate = Color.WHITE

func _update_rig(delta: float) -> void:
	if not is_instance_valid(rig): return
	var state: String = "idle"
	if health <= 0: state = "death"
	elif hurt_left > 0: state = "hurt"
	elif dodge_time > 0: state = "dash"
	elif plunging: state = "plunge"
	elif attack_kind == "plunge" and attack_time > 0: state = "land"
	elif attack_time > 0: state = "sword" if attack_kind == "sword" else ("ranged" if attack_kind == "energy" else attack_kind)
	elif charging: state = "charge"
	elif not is_on_floor() and air_jump_pose_left > 0: state = "air_jump"
	elif not is_on_floor(): state = "takeoff" if takeoff_left > 0 else ("jump" if velocity.y < -90 else ("apex" if velocity.y < 90 else "fall"))
	elif landing_left > 0: state = "land"
	elif crouching: state = "crouch"
	elif absf(velocity.x) > 20: state = "walk" if absf(velocity.x) < walk_speed else "run"
	var progress: float = 1.0 - attack_time / maxf(0.01, attack_duration) if attack_time > 0 else (1.0 - landing_left / 0.13 if state == "land" else (1.0 - takeoff_left / 0.09 if state == "takeoff" else 0))
	# Drive drawn aerial phases from the physical arc. Each phase has multiple
	# authored frames; a changed velocity after a short-hop or air-jump is reflected
	# immediately without running a second animation timer.
	if state == "death":
		progress = death_elapsed / death_duration()
	elif state == "air_jump":
		progress = 1.0-air_jump_pose_left/0.30
	elif state == "jump":
		progress = inverse_lerp(Rules.jump_velocity() + Rules.gravity() * 0.09, -90.0, velocity.y)
	elif state == "apex":
		progress = inverse_lerp(-90.0, 90.0, velocity.y)
	elif state == "fall":
		progress = inverse_lerp(90.0, 600.0, velocity.y)
	rig.update_pose(delta, state, facing, velocity, is_on_floor(), clampf(progress,0,1), hurt_left / 0.17, maxi(1,combo_step))
	# Show the grace window on the visible cel, not only the hidden legacy sprite.
	rig.modulate = Color(1,1,1,0.55 if int(invulnerable*14)%2 == 0 else 0.9) if invulnerable > 0 and health > 0 and dodge_time <= 0 else Color.WHITE
	if hurt_left > 0 and health > 0: rig.modulate = Color(1.0,0.38,0.38)

func set_character_profile(profile_id: String) -> void:
	character_profile = profile_id
	if not is_instance_valid(rig): return
	rig.configure(profile_id)
	var height: float = float(rig.profile.get("body_center_height", 58)) * 2
	standing_height = height
	var shape: CapsuleShape2D = crouch_collider.shape
	shape.height = maxf(height, shape.radius * 2)
	crouch_collider.position.y = -shape.height * 0.5

func _on_locomotion_frame() -> void:
	if sprite.animation not in ["walk", "run"] or not is_on_floor() or absf(velocity.x) < 30.0:
		return
	if attack_time > 0.0 or dodge_time > 0.0 or hurt_left > 0.0 or footstep_cooldown > 0.0:
		return
	var count: int = sprite.sprite_frames.get_frame_count(sprite.animation)
	if sprite.frame != 0 and sprite.frame != count / 2:
		return
	footstep_cooldown = 0.12
	footstep_distance = 0.0
	footstep_count += 1
	_audio("step")
	if sprite.animation == "run" and footstep_count % 3 == 0:
		fx_requested.emit("step", global_position, facing)

func _on_rig_step() -> void:
	if not is_on_floor() or attack_time > 0 or dodge_time > 0 or hurt_left > 0: return
	footstep_count += 1
	_audio("step")
	if footstep_count % 3 == 0: fx_requested.emit("step", global_position, facing)

func _update_visual_scale(delta: float) -> void:
	var target_scale := Vector2(2, 2)
	if health > 0 and hurt_left <= 0.0 and attack_time <= 0.0 and dodge_time <= 0.0:
		if takeoff_left > 0.0:
			target_scale = Vector2(1.94, 2.06)
		elif landing_left > 0.0:
			target_scale = Vector2(2.12, 1.86)
	# The AnimatedSprite2D origin is at its feet. Scaling this visual never moves collision.
	sprite.scale = sprite.scale.lerp(target_scale, 1.0 - exp(-26.0 * delta))
	# The cel rig is the visible character; carry the same takeoff/landing squash
	# onto it so the presentation is not limited to the hidden compatibility sprite.
	if is_instance_valid(rig):
		rig.pose_scale = sprite.scale / 2.0

func _dash_pose() -> void:
	if sprite.sprite_frames.has_animation("run"):
		sprite.animation = "run"
		sprite.pause()
		sprite.frame = sprite.sprite_frames.get_frame_count("run") / 3

func _landing_pose() -> void:
	if not sprite.sprite_frames.has_animation("jump"):
		_play("idle")
		return
	sprite.animation = "jump"
	sprite.pause()
	var count: int = sprite.sprite_frames.get_frame_count("jump")
	sprite.set_frame_and_progress(maxi(0, count - 2), 0.0)

func _air_pose() -> void:
	if not sprite.sprite_frames.has_animation("jump"):
		return
	sprite.animation = "jump"
	sprite.pause()
	var count: int = sprite.sprite_frames.get_frame_count("jump")
	# Use readable take-off / apex / falling poses, not a full looping jump clip.
	var fraction: float = 0.18 if velocity.y < -100.0 else (0.48 if velocity.y < 100.0 else 0.76)
	sprite.set_frame_and_progress(clampi(int((count - 1) * fraction), 0, count - 1), 0.0)

func _play(animation: String, speed: float = 1.0) -> void:
	if sprite.sprite_frames.has_animation(animation):
		sprite.speed_scale = speed
		if sprite.animation != animation or not sprite.is_playing():
			sprite.play(animation)

func _attack_motion_cue() -> String:
	if attack_kind == "kick": return "kick"
	if attack_kind in ["power", "ranged", "energy"]:
		return {"power":"power", "ranged":"ranged_swing", "energy":"energy_swing"}[attack_kind]
	if attack_kind == "charged": return "charged_swing"
	return "swing_finisher" if combo_step == 3 else ("swing_reverse" if combo_step == 2 else "swing")

func _audio(cue: String) -> void:
	var audio: Node = get_node_or_null("/root/Audio")
	if audio:
		audio.play(cue)

func death_duration() -> float:
	if is_instance_valid(rig) and rig.profile.get("clips", {}).has("death"):
		var milliseconds: float = 0
		for frame in rig.profile.clips.death.frames:
			milliseconds += float(frame.get("duration_ms",100))
		return maxf(0.2,milliseconds/1000.0)
	return 1.0

func take_damage(amount: int, hit_direction: float = 0.0) -> void:
	if health <= 0 or invulnerable > 0.0:
		return
	cancel_pending_input()
	low_kick = false
	plunging = false
	health = maxi(0, health - amount)
	attack_time = 0.0
	kick_buffer_left = 0
	attack_buffer_left = 0.0
	combo_window_left = 0
	dodge_time = 0.0
	invulnerable = 0.7
	hurt_left = 0.17
	landing_left = 0.0
	takeoff_left = 0.0
	air_jump_pose_left = 0.0
	footstep_distance = 0.0
	var push_direction: float = signf(hit_direction) if hit_direction != 0 else -facing
	var response: Dictionary = Rules.combat_response(amount,"enemy",push_direction,Rules.BODY_MASS_KG)
	velocity.x = response.velocity.x
	velocity.y = minf(velocity.y,0)+response.velocity.y
	if is_instance_valid(rig): rig.apply_impact(Vector2(push_direction, -0.2), 0.65)
	_audio("hurt")
	fx_requested.emit("finisher_hit" if amount >= 25 else "impact", global_position + Vector2(0,-38), push_direction)
	health_changed.emit(health, max_health)
	if health == 0:
		dead = true
		death_elapsed = 0
		var audio: Node = get_node_or_null("/root/Audio")
		if audio: audio.set_defeated(true)
		_play("death")
		state_changed.emit("Defeated")
	else:
		_play("hurt", 1.5)

func can_cut_fire(start: Vector2, end: Vector2) -> bool:
	if health <= 0 or hurt_left > 0 or attack_time <= 0: return false
	if attack_kind not in ["sword","charged","power"]: return false
	var phase: float = 1.0-attack_time/maxf(0.01,attack_duration)
	var finish: float = float(current_attack_spec.get("active_end_progress",attack_contact_progress))
	if phase < attack_contact_progress or phase > finish+0.10: return false
	var center := global_position + Vector2(0,-50) + attack_aim * 55
	return Geometry2D.get_closest_point_to_segment(center,start,end).distance_to(center)<65

func read_attack_aim() -> Vector2:
	var vertical := Input.get_axis("move_up", "move_down")
	var horizontal := Input.get_axis("move_left", "move_right")
	if absf(vertical) < 0.1: return Vector2(facing, 0)
	return Vector2(horizontal, vertical).normalized()
