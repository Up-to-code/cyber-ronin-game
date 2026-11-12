extends CharacterBody2D

signal defeated
signal fx_requested(kind: String, at: Vector2, direction: float)
signal projectile_requested(kind: String, at: Vector2, direction: Vector2, source: Node)
const Rules = preload("res://systems/world_rules.gd")
@export var patrol_speed: float = 42.0
@export var approach_speed: float = 108.0
var target: CharacterBody2D
var health: int = 70
var cooldown: float = 0.35
var windup: float = 0.0
var recovery: float = 0.0
var facing: float = -1.0
var sprite: AnimatedSprite2D
var strike_left: float = 0.0
var strike_duration: float = 0.22
var strike_contact: float = 0.45
var strike_hit: bool = false
var strike_motion_played: bool = false
var hurt_left: float = 0.0
var knockback: float = 0.0
var patrol_left: float = 2.0
var footstep_distance: float = 0.0
var footstep_cooldown: float = 0.0
@export var enemy_kind: String = "guard"
@export var mass_kg: float = 70
@export var knockback_resistance: float = 1.0
var rig: Node2D
var hover_origin := Vector2.ZERO
var hover_time: float = 0
var tumble: float = 0
var angular_velocity: float = 0
var hit_reaction: float = 0
var death_elapsed: float = 0
var melee_reach: float = 90
var melee_damage: int = 15
var windup_duration: float = 0.32

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	add_to_group("enemies")
	if enemy_kind == "lancer":
		health = 85
		melee_reach = 155
		melee_damage = 18
		approach_speed = 118
		windup_duration = 0.42
	elif enemy_kind == "sentinel":
		health = 130
		mass_kg = 115
		melee_reach = 105
		melee_damage = 25
		approach_speed = 66
		patrol_speed = 28
		windup_duration = 0.60
	knockback_resistance *= float(Rules.combat_parameters().get("enemy_resistance",{}).get(enemy_kind,1.0))
	collision_layer = 4
	collision_mask = 1
	platform_floor_layers = 1
	floor_snap_length = 8.0
	var collider := CollisionShape2D.new()
	var shape := CapsuleShape2D.new()
	shape.radius = 20.0
	shape.height = 116.0
	collider.shape = shape
	collider.position.y = -58.0
	add_child(collider)
	sprite = AnimatedSprite2D.new()
	sprite.sprite_frames = preload("res://art/tracer/tracer.tres")
	sprite.offset = Vector2(0, -40)
	sprite.scale = Vector2(2, 2)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(sprite)
	_play("idle")
	sprite.flip_h = true
	hover_origin = position
	if ResourceLoader.exists("res://animation/cel_actor_visual.gd"):
		rig = load("res://animation/cel_actor_visual.gd").new()
		add_child(rig)
		rig.configure(enemy_kind + "_pixel")
		rig.foot_contact.connect(_on_rig_step)
		sprite.hide()

func _physics_process(delta: float) -> void:
	hover_time += delta
	var was_grounded: bool = is_on_floor()
	velocity.y = Rules.fall(velocity.y, delta)
	if enemy_kind == "wraith" and hurt_left <= 0 and health > 0:
		velocity.y = clampf((hover_origin.y - 110 + sin(hover_time * 2.2) * 22 - position.y) * 4, -140, 140)
	velocity.x = knockback if hurt_left > 0 or not is_on_floor() else 0.0
	knockback = move_toward(knockback, 0, Rules.recoil_drag(was_grounded) * delta)
	if enemy_kind == "wraith" and hurt_left <= 0 and health > 0:
		velocity.x = (hover_origin.x + sin(hover_time * 0.65) * 55 - position.x) * 2
	hit_reaction = move_toward(hit_reaction, 0, delta * 2)
	footstep_cooldown = maxf(0.0, footstep_cooldown - delta)
	cooldown = maxf(0.0, cooldown - delta)
	if health <= 0:
		death_elapsed += delta
		move_and_slide()
		_update_rig(delta)
		return
	if position.y > 950.0:
		take_damage(health)
		return
	var offset := Vector2.INF
	if is_instance_valid(target) and target.health > 0:
		offset = target.global_position - global_position
	var nearby: bool = offset.length() < (680 if enemy_kind != "guard" else 470) and absf(offset.y) < (230 if enemy_kind == "wraith" else 110)
	if hurt_left > 0.0:
		hurt_left -= delta
		velocity.x = knockback
	elif windup > 0.0:
		windup -= delta
		if windup <= 0.0:
			strike_duration = 0.22
			strike_contact = 0.45
			if is_instance_valid(rig) and rig.has_method("get_attack_spec"):
				var spec: Dictionary = rig.get_attack_spec("sword",1)
				strike_duration = float(spec.get("duration",0.32))
				strike_contact = float(spec.get("contact_progress",0.31))
			strike_left = strike_duration
			strike_hit = false
			strike_motion_played = false
			_play("attack", 1.8)
	elif strike_left > 0.0:
		strike_left -= delta
		var cue: String = "enemy_cast" if enemy_kind in ["fire", "wraith"] else ("enemy_heavy" if enemy_kind == "sentinel" else ("enemy_thrust" if enemy_kind == "lancer" else "enemy_swing"))
		var audio: Node = get_node_or_null("/root/Audio")
		var lead: float = audio.motion_lead(cue) if audio else 0.0
		if not strike_motion_played and strike_duration - strike_left >= maxf(0.0, strike_duration * strike_contact - lead):
			strike_motion_played = true
			_audio(cue)
		if not strike_hit and 1 - strike_left / strike_duration >= strike_contact:
			strike_hit = true
			if enemy_kind in ["fire", "wraith"]:
				var aim: Vector2 = (target.global_position + Vector2(0, -50) - (global_position + Vector2(0, -55))).normalized()
				for angle in [-0.15, 0.0, 0.15] if enemy_kind == "fire" else [0.0]:
					projectile_requested.emit("fire", global_position + Vector2(facing * 36, -55), aim.rotated(angle), self)
				fx_requested.emit("fire_cast", global_position + Vector2(facing * 35, -55), facing)
			else:
				fx_requested.emit("slash", global_position + Vector2(facing * 35.0, -38.0), facing)
			if enemy_kind in ["guard", "lancer", "sentinel"] and absf(offset.x) < melee_reach and absf(offset.y) < 65.0 and offset.x * facing > -8.0:
				target.take_damage(melee_damage, facing)
		if strike_left <= 0.0:
			recovery = 0.55
	elif recovery > 0.0:
		recovery -= delta
		_play("idle")
	elif nearby:
		if absf(offset.x) > 2.0:
			facing = signf(offset.x)
		var attack_reach: float = 400 if enemy_kind in ["fire", "wraith"] else melee_reach-15
		if absf(offset.x) < attack_reach and absf(offset.y) < (230 if enemy_kind == "wraith" else 65) and cooldown <= 0.0 and (is_on_floor() or enemy_kind == "wraith"):
			windup = windup_duration
			cooldown = 2.2 if enemy_kind in ["fire", "wraith"] else (1.8 if enemy_kind == "sentinel" else 1.2)
			_play("idle")
		elif absf(offset.x) > 70.0 and is_on_floor() and _floor_ahead(facing):
			velocity.x = facing * approach_speed
			_play("run")
		else:
			_play("idle")
	else:
		patrol_left -= delta
		if patrol_left <= 0.0:
			patrol_left = 2.0
			facing *= -1.0
		if is_on_floor():
			if _floor_ahead(facing):
				velocity.x = facing * patrol_speed
				_play("walk", 0.7)
			else:
				facing *= -1.0
				_play("idle")
	sprite.flip_h = facing < 0.0
	sprite.modulate = Color(2.0, 1.35, 0.8) if windup > 0.0 else (Color(2.3, 1.7, 1.3) if hurt_left > 0.0 else Color.WHITE)
	move_and_slide()
	if not was_grounded and is_on_floor() and absf(angular_velocity) > 0.1:
		angular_velocity = 0
		tumble = wrapf(tumble, -PI, PI)
		fx_requested.emit("land", global_position, facing)
	_update_rig(delta)
	if not is_on_floor() and hurt_left <= 0.0 and windup <= 0.0 and strike_left <= 0.0:
		_air_pose()
	elif is_on_floor() and absf(velocity.x) > 20.0 and hurt_left <= 0.0:
		footstep_distance += absf(velocity.x) * delta

func _on_locomotion_frame() -> void:
	if sprite.animation not in ["walk", "run"] or not is_on_floor() or absf(velocity.x) < 20.0:
		return
	if hurt_left > 0.0 or windup > 0.0 or strike_left > 0.0 or footstep_cooldown > 0.0:
		return
	var count: int = sprite.sprite_frames.get_frame_count(sprite.animation)
	if sprite.frame != 0 and sprite.frame != count / 2:
		return
	footstep_cooldown = 0.15
	footstep_distance = 0.0
	if is_instance_valid(target) and target.global_position.distance_to(global_position) < 360.0:
		_audio("enemy_step")

func _on_rig_step() -> void:
	if is_on_floor() and is_instance_valid(target) and target.position.distance_to(position) < 360 and hurt_left <= 0 and strike_left <= 0:
		_audio("enemy_step")

func _air_pose() -> void:
	if sprite.sprite_frames.has_animation("jump"):
		sprite.animation = "jump"
		sprite.pause()
		var count: int = sprite.sprite_frames.get_frame_count("jump")
		sprite.set_frame_and_progress(clampi(int((count - 1) * 0.76), 0, count - 1), 0.0)

func _floor_ahead(direction: float) -> bool:
	var from: Vector2 = global_position + Vector2(direction * 28.0, -16.0)
	var query := PhysicsRayQueryParameters2D.create(from, from + Vector2(0, 44), 1, [get_rid()])
	return not get_world_2d().direct_space_state.intersect_ray(query).is_empty()

func _play(animation: String, speed: float = 1.0) -> void:
	if sprite.sprite_frames.has_animation(animation):
		sprite.speed_scale = speed
		if sprite.animation != animation or not sprite.is_playing():
			sprite.play(animation)

func _audio(cue: String) -> void:
	var audio: Node = get_node_or_null("/root/Audio")
	if audio:
		audio.play(cue)

func take_damage(amount: int, cue: String = "impact") -> void:
	receive_hit(amount, "kick" if cue == "kick_hit" else ("finisher" if amount >= 45 else "sword"), -facing, global_position + Vector2(0,-45))

func receive_hit(amount: int, kind: String, direction: float, point: Vector2) -> void:
	if health <= 0:
		return
	health = maxi(0, health - amount)
	_audio("kick_hit" if kind == "kick" else ("impact_spirit" if enemy_kind=="wraith" else ("impact_armor" if enemy_kind in ["guard","lancer","sentinel"] else "impact")))
	if amount >= 45 and enemy_kind != "wraith": _audio("heavy_contact")
	fx_requested.emit("finisher_hit" if amount >= 45 else "impact", global_position + Vector2(0, -38), signf(direction))
	windup = 0.0
	strike_left = 0.0
	var response: Dictionary = Rules.combat_response(amount,kind,direction,mass_kg,knockback_resistance)
	hurt_left = float(response.stun)
	var momentum: Vector2 = response.impulse
	var impulse: Vector2 = response.velocity
	velocity.y = minf(velocity.y, 0) + impulse.y
	knockback = impulse.x
	velocity.x = knockback
	hit_reaction = 1
	var spin_limit: float = 8.5 if kind in ["power", "charged", "finisher"] else (6.0 if kind == "kick" else 2.5)
	angular_velocity = clampf(Rules.angular_impulse(point - (global_position + Vector2(0,-58)), momentum, mass_kg), -spin_limit, spin_limit)
	if is_instance_valid(rig):
		rig.apply_impact(Vector2(signf(direction), -0.25), 1.0 if amount >= 45 else 0.6)
	_play("hurt", 1.5)
	if health == 0:
		fx_requested.emit("defeat", global_position + Vector2(0, -38), signf(direction))
		remove_from_group("enemies")
		defeated.emit()
		_play("death", 1.25)
		await get_tree().create_timer(1.3, false).timeout
		queue_free()

func _update_rig(delta: float) -> void:
	if not is_instance_valid(rig): return
	rig.modulate = Color(1.45,0.65,0.58) if windup > 0 else (Color(1.5,0.42,0.42) if hurt_left > 0 else Color.WHITE)
	if not is_on_floor() and absf(angular_velocity) > 0:
		tumble += angular_velocity * delta
	else:
		tumble = lerp_angle(tumble, 0, 1 - exp(-14 * delta))
		angular_velocity = move_toward(angular_velocity, 0, delta * 15)
	rig.external_roll = tumble
	var state: String = "death" if health <= 0 else ("hurt" if hurt_left > 0 else ("kick" if strike_left > 0 and enemy_kind == "fire" else ("sword" if strike_left > 0 else ("charged" if windup > 0 else ("run" if absf(velocity.x) > 20 else "idle")))))
	if enemy_kind == "wraith" and hurt_left <= 0 and health > 0 and windup <= 0 and strike_left <= 0: state = "float"
	elif health > 0 and hurt_left <= 0 and windup <= 0 and strike_left <= 0 and not is_on_floor(): state = "jump" if velocity.y < 0 else "fall"
	var progress: float = death_elapsed / 1.3 if health <= 0 else (1.0 - strike_left / strike_duration if strike_left > 0 else 0)
	rig.update_pose(delta, state, facing, velocity, is_on_floor(), progress, hit_reaction)
