extends CharacterBody2D

signal inventory_consumed(id: String)
var skill_inventory: RefCounted
var sword_damage_multiplier: float = 1.0
var inventory_skill_cooldown: float = 0.0
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
var map_bottom: float = 950.0
@export var ground_acceleration: float = 2400.0
@export var air_acceleration: float = 1650.0
@export var ground_friction: float = 3200.0
@export var coyote_window: float = 0.12
@export var jump_buffer_window: float = 0.14
@export var character_profile: String = "ronin_cel"

var laser_unlocked := false
var submerged: bool = false
var swim_current: Vector2 = Vector2.ZERO
var swim_phase: float = 0
var swim_bubble_left: float = 0
var relic_epoch: int = 0
var relic_charges: Dictionary = {"laser":0,"cloud":0}
var motion_echo_left := 0.0
var wind_left := 0.0
var slide_left := 0.0
var slide_direction := 1.0
var slide_cooldown := 0.0
var fast_falling := false
var fast_fall_delay := 0.0
var dropped_platforms: Array[PhysicsBody2D] = []
var drop_left := 0.0
const SLIDE_DURATION := 0.36
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
var sword_motion := "sword"
var directional_hold := 0.0
var held_direction := 0.0
var reversal_window := 0.0
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
	inventory_skill_cooldown=maxf(0,inventory_skill_cooldown-delta)
	if submerged and health > 0:
		_swim_physics(delta)
		return
	motion_echo_left = maxf(0,motion_echo_left-delta)
	if health>0 and hurt_left<=0 and motion_echo_left<=0 and ((attack_time>0 and absf(velocity.x)>90) or (not is_on_floor() and velocity.length()>450)):
		motion_echo_left=0.10
		fx_requested.emit("dash_trail",global_position,facing)
	_restore_drop_collisions(delta)
	slide_cooldown = maxf(0, slide_cooldown-delta)
	wind_left = maxf(0, wind_left-delta)
	var grounded: bool = is_on_floor()
	if grounded: fast_falling = false
	var was_pending_fall := fast_fall_delay>0
	fast_fall_delay=maxf(0,fast_fall_delay-delta)
	if was_pending_fall and fast_fall_delay<=0 and fast_falling and not grounded and not plunging:
		velocity.y=maxf(velocity.y,420)
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
	if direction == 0 or signf(direction) != held_direction:
		directional_hold = 0
	else:
		directional_hold += delta
	held_direction = signf(direction)
	reversal_window = maxf(0,reversal_window-delta)
	if Input.is_action_just_pressed("move_down") and hurt_left <= 0 and attack_time <= 0 and dodge_time <= 0:
		if grounded and _drop_through_shelf():
			grounded = false
		elif grounded and absf(velocity.x) > 100 and slide_cooldown <= 0:
			slide_left = SLIDE_DURATION
			slide_cooldown = 0.6
			slide_direction = signf(velocity.x)
			_cancel_charge()
			fx_requested.emit("slide_wind", global_position+Vector2(0,-18),slide_direction)
		elif not grounded:
			fast_falling = true
			# Brief input grace lets DOWN then J resolve as a plunge, even just after takeoff.
			fast_fall_delay = 0.055
	if slide_left > 0 and (not grounded or attack_buffer_left > 0 or kick_buffer_left > 0 or jump_buffer_left > 0): slide_left = 0
	crouching = grounded and (slide_left > 0 or (Input.is_action_pressed("move_down") and attack_time <= 0) or (low_kick and attack_kind == "kick" and attack_time > 0))
	if grounded and not crouching and crouch_collider.shape.height < standing_height:
		var overhead := PhysicsRayQueryParameters2D.create(global_position + Vector2(0,-45), global_position + Vector2(0,-standing_height), 1)
		crouching = not get_world_2d().direct_space_state.intersect_ray(overhead).is_empty()
	var body_height: float = 48 if slide_left > 0 else (standing_height - 22 if crouching else standing_height)
	crouch_collider.shape.height = body_height
	crouch_collider.position.y = -body_height * 0.5
	# Mobile uses one reliable movement speed; no separate RUN control is needed.
	sprinting = true
	var travel_speed: float = run_speed
	if crouching: travel_speed *= 0.4
	if slide_left <= 0 and direction != 0.0 and dodge_time <= 0.0 and hurt_left <= 0.0:
		if facing != signf(direction) and is_on_floor() and (attack_time>0 or combo_window_left>0):
			reversal_window = 0.30
			fx_requested.emit("slide_wind",global_position+Vector2(0,-12),-facing)
		facing = signf(direction)
	sprite.flip_h = facing < 0.0
	if not grounded and dodge_time <= 0:
		velocity.y = Rules.fall(velocity.y, delta * (1.65 if fast_falling and fast_fall_delay<=0 else 1.0))
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
		if not use_relic_laser(): _start_special("energy")
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
	elif slide_left > 0:
		slide_left = maxf(0,slide_left-delta)
		facing = slide_direction
		velocity.x = slide_direction * lerpf(260,520,slide_left/SLIDE_DURATION)
	elif attack_time > 0.0:
		attack_time = maxf(0.0, attack_time - delta)
		# Movement input remains responsive during every attack, including G/X.
		velocity.x = move_toward(velocity.x, direction * travel_speed, (ground_acceleration if grounded else air_acceleration) * delta)
		if attack_kind == "sword" and sword_motion in ["moving_sword","drive_sword"]:
			var strike_progress := 1.0-attack_time/attack_duration
			var drive := sin(clampf(strike_progress/0.65,0,1)*PI)
			velocity.x += direction * (220.0 if sword_motion == "drive_sword" else 120.0) * drive * delta * 8.0
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
			var slash_kind: String = attack_kind if attack_kind != "sword" else ("sweep" if combo_step == 4 else ("finisher" if combo_step == 3 else ("slash_reverse" if combo_step == 2 else "slash")))
			if attack_kind == "sword" and sword_motion != "sword":
				slash_kind = str(current_attack_spec.get("vfx",slash_kind))
			# Resolve sockets from the displayed contact pose, not the previous tick.
			_update_rig(0)
			attack_aim = Vector2(facing,0) if attack_kind=="kick" and low_kick else read_attack_aim()
			var attack_socket: Vector2 = global_position + Vector2(facing * 46, -42)
			if is_instance_valid(rig): attack_socket = global_position + rig.socket("foot" if attack_kind == "kick" else "hand")
			if absf(attack_aim.y) > 0.1:
				attack_socket = global_position + Vector2(0,-48) + attack_aim * 46
			fx_requested.emit(slash_kind, attack_socket, facing)
			if absf(velocity.x) > 80:
				fx_requested.emit("dash_trail", global_position, facing)
			var wall_contact: Dictionary = {}
			if attack_kind == "kick":
				var probe := PhysicsRayQueryParameters2D.create(Vector2(global_position.x, attack_socket.y), attack_socket + Vector2(facing * 12, 0), 1)
				wall_contact = get_world_2d().direct_space_state.intersect_ray(probe)
				if not wall_contact.is_empty():
					velocity.x = -facing * 90
					_audio("push")
					fx_requested.emit("wall_hit", wall_contact.position, -facing)
					if is_instance_valid(rig): rig.apply_impact(Vector2(-facing,0),0.3)

			if attack_kind in ["ranged", "energy"]:
				projectile_requested.emit(("laser" if laser_unlocked else "energy") if attack_kind == "energy" else "blade", global_position + Vector2(0, -52) + attack_aim * 8, attack_aim, self)
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
					var kind: String = ("finisher" if combo_step>=3 else ("double" if combo_step==2 else "sword")) if attack_kind=="sword" else attack_kind
					if enemy.has_method("receive_hit"):
						enemy.receive_hit(roundi(damage*sword_damage_multiplier) if attack_kind in ["sword","charged"] else damage, kind, facing, attack_socket)
					else: enemy.take_damage(roundi(damage*sword_damage_multiplier) if attack_kind in ["sword","charged"] else damage)
			# Barrels are separate hazards, never part of the enemy roster.
			for barrel in get_tree().get_nodes_in_group("fire_barrels") if attack_kind not in ["ranged", "energy"] else []:
				var offset: Vector2 = barrel.global_position - global_position
				var in_plane: bool = absf(offset.y) < 80.0
				if attack_kind == "kick":
					in_plane = attack_socket.y >= barrel.global_position.y - 96 and attack_socket.y <= barrel.global_position.y + 16
				var touching: bool = absf(offset.x) < reach and in_plane and offset.x * facing > -10.0
				if absf(attack_aim.y) > 0.1 and attack_kind != "power":
					var aim_delta: Vector2 = barrel.global_position + Vector2(0, -30) - (global_position + Vector2(0, -48))
					touching = aim_delta.dot(attack_aim) > -10 and aim_delta.dot(attack_aim) < reach and absf(aim_delta.cross(attack_aim)) < 65
				if touching and wall_contact.is_empty():
					barrel.receive_hit(damage, attack_kind, facing, attack_socket)
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
	if health > 0 and hurt_left <= 0 and wind_left <= 0:
		if slide_left > 0 or (grounded and absf(velocity.x)>240 and attack_time<=0):
			wind_left = 0.12
			fx_requested.emit("slide_wind" if slide_left>0 else "run_wind", global_position+Vector2(-facing*20,-22 if slide_left>0 else -38),facing)
		elif fast_falling and not grounded:
			wind_left = 0.10
			fx_requested.emit("fall_wind",global_position+Vector2(0,-45),facing)
	_assist_platform_landing()
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
		for barrel in get_tree().get_nodes_in_group("fire_barrels"):
			if absf(barrel.global_position.x - global_position.x) < 145 and absf(barrel.global_position.y - global_position.y) < 75:
				barrel.receive_hit(55, "plunge", facing, global_position)
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
		if not landed_from_plunge:
			var fall_damage: int = Rules.landing_damage(previous_fall_speed)
			if fall_damage > 0: take_damage(fall_damage)
		if jump_buffer_left > 0.0:
			_jump()
	if is_on_floor() and absf(velocity.x) > 30.0 and attack_time <= 0.0 and dodge_time <= 0.0 and hurt_left <= 0.0:
		footstep_distance += absf(velocity.x) * delta
	elif not is_on_floor():
		footstep_distance = 0.0
	_update_visual_scale(delta)
	_update_rig(delta)
	position.x = clampf(position.x, 24.0, maxf(24.0, map_width - 24.0))
	if position.y > map_bottom:
		invulnerable = 0.0
		take_damage(max_health)

func _start_attack() -> void:
	_cancel_charge()
	attack_buffer_left = 0
	attack_kind = "sword"
	if not is_on_floor() and Input.is_action_pressed("move_down"):
		attack_kind = "plunge"
		plunging = true
		fast_falling = false
		fast_fall_delay = 0
		plunge_fx_left = 0
	combo_step = combo_step % 4 + 1 if combo_window_left > 0 else 1
	combo_window_left = 0.40
	attack_duration = 0.36 if combo_step == 3 else (0.28 if combo_step == 2 else ATTACK_DURATION)
	attack_time = attack_duration
	attack_hit = false
	attack_motion_played = false
	sword_motion = "sword"
	if not plunging:
		if not is_on_floor(): sword_motion = "air_sword"
		elif absf(Input.get_axis("move_left","move_right")) > 0: sword_motion = "drive_sword" if directional_hold >= 0.28 else "moving_sword"
	if not plunging and is_on_floor() and reversal_window>0 and Input.get_axis("move_left","move_right")!=0:
		sword_motion = "turn_sword"
		reversal_window = 0
	_apply_attack_spec(sword_motion, combo_step)
	var clip: String = "attack" if combo_step == 1 else "attack%d" % mini(combo_step,3)
	var frames: SpriteFrames = sprite.sprite_frames
	var speed: float = frames.get_frame_count(clip) / (frames.get_animation_speed(clip) * attack_duration)
	sprite.stop()
	_play(clip, speed)

func _start_special(kind: String) -> bool:
	var cost: float = 50 if kind == "power" else (30 if kind == "charged" else ((45 if laser_unlocked else 35) if kind == "energy" else (25 if kind == "ranged" else 0)))
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
	_apply_attack_spec("low_kick" if low_kick else ("ranged" if kind in ["energy", "relic"] else kind), 1)
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
	slide_left = 0
	fast_falling = false
	fast_fall_delay = 0
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
	set_submerged(false)
	velocity = Vector2.ZERO
	swim_current = Vector2.ZERO
	relic_epoch += 1
	relic_charges = {"laser":0,"cloud":0}
	reversal_window = 0
	directional_hold = 0
	held_direction = 0
	sword_motion = "sword"
	_restore_drop_collisions(0, true)
	slide_left = 0
	slide_cooldown = 0
	fast_falling = false
	fast_fall_delay = 0
	wind_left = 0
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
	elif slide_left > 0: state = "slide"
	elif fast_falling and fast_fall_delay<=0 and attack_time<=0 and not is_on_floor(): state = "fast_fall"
	elif attack_kind == "plunge" and attack_time > 0: state = "land"
	elif attack_time > 0: state = "low_kick" if attack_kind=="kick" and low_kick else (sword_motion if attack_kind == "sword" else ("ranged" if attack_kind in ["energy", "relic"] else attack_kind))
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
	if state == "slide":
		progress = 1.0-slide_left/SLIDE_DURATION
	elif state == "fast_fall":
		progress = clampf(velocity.y/1000.0,0,1)
	elif state == "death":
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
	return "swing_finisher" if combo_step >= 3 else ("swing_reverse" if combo_step == 2 else "swing")

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
	slide_left = 0
	fast_falling = false
	fast_fall_delay = 0
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

func _drop_through_shelf() -> bool:
	# Ignore only the supporting one-way bodies, never disable world collision.
	var supports: Array[PhysicsBody2D] = []
	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		var body := collision.get_collider() as PhysicsBody2D
		if body == null or collision.get_normal().y > -0.6: continue
		var one_way := false
		for child in body.get_children():
			if child is CollisionShape2D and child.one_way_collision: one_way = true
		if not one_way: return false
		if body not in supports: supports.append(body)
	if supports.is_empty(): return false
	for body in supports:
		add_collision_exception_with(body)
		dropped_platforms.append(body)
	drop_left = 0.20
	coyote_left = 0
	jump_buffer_left = 0
	position.y += 5
	velocity.y = 180
	fx_requested.emit("fall_wind",global_position+Vector2(0,-32),facing)
	return true

func _restore_drop_collisions(delta: float, force: bool = false) -> void:
	drop_left = maxf(0,drop_left-delta)
	for i in range(dropped_platforms.size()-1,-1,-1):
		var body := dropped_platforms[i]
		if not is_instance_valid(body):
			dropped_platforms.remove_at(i)
		elif force or (drop_left<=0 and (position.y-standing_height > body.global_position.y+12 or velocity.y<0)):
			remove_collision_exception_with(body)
			dropped_platforms.remove_at(i)

# A held jump catches a nearby one-way deck when the torso clears it but the
# feet narrowly miss. Never catch while dropping, attacking downward or rising.
func _assist_platform_landing() -> void:
	if is_on_floor() or velocity.y < 0 or velocity.y > 260 or not Input.is_action_pressed("jump") or drop_left > 0 or plunging or fast_falling:
		return
	var query := PhysicsRayQueryParameters2D.create(global_position+Vector2(0,-56),global_position,1)
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	if hit.is_empty() or not hit.collider is PhysicsBody2D or hit.collider in dropped_platforms: return
	var body: PhysicsBody2D = hit.collider
	var one_way := false
	for child in body.get_children():
		if child is CollisionShape2D and child.one_way_collision: one_way = true
	if not one_way: return
	# The landing capsule must fit above the deck; no vault through ceilings.
	var clearance := PhysicsRayQueryParameters2D.create(hit.position-Vector2(0,2),hit.position-Vector2(0,standing_height),1)
	clearance.exclude = [body.get_rid()]
	if not get_world_2d().direct_space_state.intersect_ray(clearance).is_empty(): return
	global_position.y = hit.position.y-1
	velocity.y = 30

func grant_relic(kind: String) -> void:
	if not relic_charges.has(kind):return
	relic_charges[kind]=1
	fx_requested.emit("sparkle",global_position+Vector2(0,-65),facing)
	state_changed.emit("Sun relic ready: X / G" if kind=="laser" else "Cloud seed ready: E at anchor")

func consume_relic(kind: String) -> bool:
	if int(relic_charges.get(kind,0))<=0:return false
	relic_charges[kind]-=1
	return true

func use_relic_laser() -> bool:
	if submerged: return false
	if not consume_relic("laser"):return false
	var beam=preload("res://systems/colossal_beam.gd").new()
	beam.owner_body=self
	beam.direction=read_attack_aim()
	beam.position=global_position+Vector2(0,-55)
	get_parent().add_child(beam)
	_start_special("relic")
	attack_hit = true # The beam owns contact; do not emit a second projectile.
	attack_motion_played = true
	_audio("energy_swing")
	state_changed.emit("Sun relic spent • return to pedestal to recharge")
	return true

func prepare_realm_transition() -> void:
	# Stop the outgoing action without resetting earned inventory or resources.
	relic_epoch += 1
	cancel_pending_input()
	_restore_drop_collisions(0, true)
	attack_time = 0
	attack_hit = false
	attack_motion_played = false
	combo_window_left = 0
	combo_step = 0
	plunging = false
	fast_falling = false
	fast_fall_delay = 0
	dodge_time = 0
	slide_left = 0
	velocity = Vector2.ZERO
	air_jump_pose_left = 0
	takeoff_left = 0
	landing_left = 0

func set_submerged(value: bool) -> void:
	if submerged == value: return
	prepare_realm_transition()
	submerged = value
	swim_phase = 0
	swim_bubble_left = 0
	crouching = false
	air_jumps_left = 1
	if is_instance_valid(rig):
		rig.external_roll = 0
		rig.pose_scale = Vector2.ONE
		rig.body_pivot.rotation = 0
	if not value:
		velocity.y = -220 # Surface breach clears the waterline without a jump charge.
		swim_current = Vector2.ZERO

func _swim_physics(delta: float) -> void:
	swim_phase += delta
	swim_bubble_left -= delta
	invulnerable = maxf(0,invulnerable-delta)
	hurt_left = maxf(0,hurt_left-delta)
	power_regen_delay = maxf(0,power_regen_delay-delta)
	attack_buffer_left = maxf(0,attack_buffer_left-delta)
	combo_window_left = maxf(0,combo_window_left-delta)
	if power_regen_delay <= 0 and power < max_power:
		power=minf(max_power,power+8*delta);power_changed.emit(power,max_power)
	var steer:=Vector2(Input.get_axis("move_left","move_right"),Input.get_axis("move_up","move_down"))
	if Input.is_action_pressed("jump"):steer.y=-1
	steer=steer.limit_length()
	if steer.x != 0:facing=signf(steer.x)
	sprite.flip_h=facing<0
	var desired:=steer*175+Vector2(0,-18)+swim_current.limit_length(140)
	velocity=velocity.move_toward(desired,(480 if steer.length()>0 else 180)*delta)
	if Input.is_action_just_pressed("attack"):
		attack_buffer_left=maxf(.22,attack_time+.08)
	if hurt_left<=0 and attack_time<=0:
		if attack_buffer_left>0:
			combo_step=combo_step%3+1 if combo_window_left>0 else 1
			attack_kind="sword";sword_motion="air_sword"
			_apply_attack_spec("air_sword",combo_step)
			attack_duration*=1.18;attack_time=attack_duration
			attack_hit=false;attack_buffer_left=0;combo_window_left=attack_duration+.4
			_audio("sword_swing")
		elif Input.is_action_just_pressed("ranged_attack"):
			if power>=18:
				power-=18;power_regen_delay=1;power_changed.emit(power,max_power)
				_start_special("water")
				_apply_attack_spec("ranged",1)
				attack_hit=true
				projectile_requested.emit("water",global_position+Vector2(0,-45),read_attack_aim(),self)
			else:_audio("power_empty")
		elif Input.is_action_just_pressed("energy_attack") or Input.is_action_just_pressed("power_attack"):
			state_changed.emit("Fire and sun relics cannot ignite underwater")
	if attack_time>0:
		attack_time=maxf(0,attack_time-delta)
		if attack_kind=="sword" and not attack_hit and 1-attack_time/attack_duration>=attack_contact_progress:
			attack_hit=true
			attack_aim=read_attack_aim()
			var origin:=global_position+Vector2(0,-45)
			fx_requested.emit("slash_reverse" if combo_step==2 else "slash",origin+attack_aim*38,facing)
			velocity+=attack_aim*35
			for enemy in get_tree().get_nodes_in_group("enemies"):
				var offset: Vector2=enemy.global_position+Vector2(0,-42)-origin
				if offset.length()<115 and offset.normalized().dot(attack_aim)>.3:
					enemy.receive_hit(roundi((24+combo_step*5)*sword_damage_multiplier),"sword",facing,origin+attack_aim*55)
	move_and_slide()
	position.x=clampf(position.x,24,maxf(24,map_width-24))
	if position.y>map_bottom:
		invulnerable=0;take_damage(max_health)
	if swim_bubble_left<=0:
		swim_bubble_left=.22
		fx_requested.emit("swim_bubbles",global_position+Vector2(-facing*30,-35),facing)
	_update_swim_visual(delta)

func _update_swim_visual(delta: float) -> void:
	if not is_instance_valid(rig): return
	var striking:=attack_time>0
	var pose: String="air_sword" if striking and attack_kind=="sword" else ("ranged" if striking else "jump")
	var progress: float=1-attack_time/maxf(.01,attack_duration) if striking else .5+.48*sin(swim_phase*7)
	rig.update_pose(delta,pose,facing,velocity,false,progress,0,maxi(1,combo_step))
	# Tilt around the torso pivot, with a slow opposing paddle stroke. This is
	# local to swimming; the authored profile and land animation remain intact.
	var pitch:=facing*(.85 if not striking else .3)+clampf(velocity.y/300,-.35,.35)*facing
	rig.body_pivot.rotation=pitch+sin(swim_phase*7)*.08
	rig.pose_scale=Vector2.ONE
	rig.modulate=Color(.7,.92,1,.65 if invulnerable>0 and int(invulnerable*14)%2==0 else 1)

func apply_skill_inventory(inventory: RefCounted, refill_health: bool = false) -> void:
	skill_inventory=inventory
	var previous_max:=max_health
	max_health=100+int(inventory.ranks.vitality)*20
	sword_damage_multiplier=1.0+float(inventory.ranks.sword)*.15
	health=max_health if refill_health else mini(max_health,health+maxi(0,max_health-previous_max))
	health_changed.emit(health,max_health)

func use_inventory_skill(id: String) -> bool:
	if skill_inventory==null or health<=0 or inventory_skill_cooldown>0:return false
	if id=="heal" and health>=max_health:return false
	if not skill_inventory.consume(id):return false
	inventory_skill_cooldown=.5
	if id=="heal":
		health=mini(max_health,health+55)
		health_changed.emit(health,max_health)
		fx_requested.emit("heal",global_position+Vector2(0,-45),facing)
	elif id=="tide":
		fx_requested.emit("shockwave_ring",global_position+Vector2(0,-40),facing)
		invulnerable=maxf(invulnerable,.5)
		for enemy in get_tree().get_nodes_in_group("enemies"):
			if enemy.global_position.distance_to(global_position)<240:
				enemy.receive_hit(85,"power",signf(enemy.global_position.x-global_position.x),enemy.global_position+Vector2(0,-45))
	inventory_consumed.emit(id)
	return true

func _unhandled_key_input(event: InputEvent) -> void:
	if get_tree().paused or health<=0:return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode==KEY_Q or event.keycode==KEY_Q:
			use_inventory_skill("tide");get_viewport().set_input_as_handled()
		elif event.physical_keycode==KEY_H or event.keycode==KEY_H:
			use_inventory_skill("heal");get_viewport().set_input_as_handled()
