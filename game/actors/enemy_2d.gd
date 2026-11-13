extends CharacterBody2D

signal brood_requested(specs: Array)
var body_height := 116.0
var body_width := 40.0
var body_collider: CollisionShape2D
var motion_visual: Node2D
var motion_profile: Dictionary = {}
var authored_action_was_active := false
var contract: Node2D
var swimming := false
var swim_bounds := Rect2()
var swim_role := "jelly"
var swim_charge := 0.0
var swim_charge_direction := Vector2.ZERO
signal defeated
signal fx_requested(kind: String, at: Vector2, direction: float)
signal projectile_requested(kind: String, at: Vector2, direction: Vector2, source: Node)
const Roster = preload("res://data/monster_roster.gd")
var monster_id := 0
var monster_name := ""
var doctrine := ""
var signature_mode := ""
var roster_spec: Dictionary = {}
var roster_tint := Color.WHITE
var tactic_clock := 0.0
var tactic_cooldown := 0.0
var role_badge: Sprite2D
var healed_total := 0
var enraged := false
const Rules = preload("res://systems/world_rules.gd")
@export var patrol_speed: float = 42.0
@export var approach_speed: float = 108.0
var target: CharacterBody2D
var max_health: int = 70
var health_display: Node2D
signal fragments_requested(actor: Node2D, direction: float)
var health: int = 70
var map_bottom: float = 950.0
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
var is_boss: bool = false
var boss_name: String = ""
var impostor: bool = false
var monster_variant: String = ""
var attack_skill := "native"
var attack_count := 0
var projectile_damage: int = 10
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
	if enemy_kind in ["lantern", "obsidian", "tengu"]:
		monster_variant = enemy_kind
		enemy_kind = "wraith" if monster_variant == "lantern" else ("lancer" if monster_variant == "tengu" else "sentinel")
	if enemy_kind == "impostor":
		impostor = true
		enemy_kind = "fire"
		health = 170
		mass_kg = 110
		projectile_damage = 18
		windup_duration = 0.7
		modulate = Color(1.1,0.62,0.86)
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
	if monster_variant == "tengu":
		health=95
		mass_kg=55
		approach_speed=140
		melee_reach=140
		melee_damage=20
		windup_duration=0.42
	elif monster_variant == "lantern":
		health = 110
		projectile_damage = 14
		windup_duration = 0.65
	elif monster_variant == "obsidian":
		health = 180
		mass_kg = 145
		melee_damage = 28
		windup_duration = 0.8
	knockback_resistance *= float(Rules.combat_parameters().get("enemy_resistance",{}).get(enemy_kind,1.0))
	collision_layer = 4
	collision_mask = 1
	platform_floor_layers = 1
	floor_snap_length = 8.0
	var collider := CollisionShape2D.new()
	body_collider = collider
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
		rig.configure((monster_variant if not monster_variant.is_empty() else enemy_kind) + "_pixel")
		rig.foot_contact.connect(_on_rig_step)
		sprite.hide()

	configure_health_display()

func apply_monster_profile(id: int) -> void:
	var spec := Roster.get_monster(id)
	if spec.is_empty(): return
	monster_id = id
	monster_name = spec.name
	roster_spec = spec
	doctrine = spec.behavior
	attack_skill = spec.skill
	# Boss health remains authored by the campaign's scaling contract.
	if not is_boss: health = roundi(health * float(spec.health_multiplier))
	approach_speed *= float(spec.speed_multiplier)
	patrol_speed *= float(spec.speed_multiplier)
	windup_duration *= float(spec.windup_multiplier)
	roster_tint = Color(spec.tint)
	set_meta("monster_name",monster_name)
	set_meta("monster_id",id)
	if not is_instance_valid(role_badge):
		role_badge = Sprite2D.new()
		role_badge.name = "CombatRole"
		role_badge.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		role_badge.position = Vector2(-38,-132)
		role_badge.z_index = 12
		add_child(role_badge)
	role_badge.texture = load("res://art/monster-roster/role%d.png" % ((id-1)%10))
	role_badge.visible = false
	if is_instance_valid(rig):
		rig.configure(spec.profile)
		rig.scale = Vector2.ONE * float(spec.scale)
		_fit_monster_body()
	if not is_instance_valid(contract):
		contract = preload("res://actors/monster_contract.gd").new()
		contract.actor = self
		add_child(contract)
	_setup_monster_motion()
	configure_health_display()

func configure_signature(mode: String) -> void:
	signature_mode = mode
	monster_variant = ""
	doctrine = ""
	attack_skill = "native"
	# Signature casts replace the generic ranged kit; body artwork stays authored.
	enemy_kind = "guard"
	var rule = preload("res://systems/signature_encounter.gd").new()
	rule.actor = self
	rule.mode = mode
	add_child(rule)
	if mode == "glass":
		windup_duration = 0.65
		approach_speed = 80

func configure_health_display() -> void:
	max_health = maxi(1,health)
	if not is_instance_valid(health_display):
		health_display=preload("res://ui/enemy_health.gd").new()
		add_child(health_display)
	health_display.position=Vector2(0,-body_height-18/maxf(scale.y,.01))
	health_display.z_index=12
	health_display.set_health(health,max_health,is_boss)

func _physics_process(delta: float) -> void:
	if swimming:
		_swim_physics(delta)
		return
	if is_instance_valid(role_badge):
		role_badge.visible = health > 0 and (windup > 0 or (is_instance_valid(target) and target.global_position.distance_to(global_position)<230))
	hover_time += delta
	tactic_clock += delta
	tactic_cooldown = maxf(0,tactic_cooldown-delta)
	var was_grounded: bool = is_on_floor()
	velocity.y = Rules.fall(velocity.y, delta)
	if _is_hovering() and hurt_left <= 0 and health > 0:
		var hover_y: float=maxf(body_height*absf(scale.y)+24,hover_origin.y-110+sin(hover_time*2.2)*22)
		velocity.y=clampf((hover_y-position.y)*4,-140,140)
	velocity.x = knockback if hurt_left > 0 or not is_on_floor() else 0.0
	knockback = move_toward(knockback, 0, Rules.recoil_drag(was_grounded) * delta)
	if _is_hovering() and hurt_left <= 0 and health > 0:
		velocity.x = (hover_origin.x + sin(hover_time * 0.65) * 55 - position.x) * 2
	hit_reaction = move_toward(hit_reaction, 0, delta * 2)
	footstep_cooldown = maxf(0.0, footstep_cooldown - delta)
	cooldown = maxf(0.0, cooldown - delta)
	if health <= 0:
		death_elapsed += delta
		move_and_slide()
		_update_rig(delta)
		return
	if position.y > map_bottom:
		take_damage(health)
		return
	var offset := Vector2.INF
	if is_instance_valid(target) and target.health > 0:
		offset = target.global_position - global_position
	if doctrine == "berserker" and not enraged and health <= max_health/2:
		enraged = true
		approach_speed *= 1.5
		windup_duration *= 0.65
		melee_damage = roundi(melee_damage*1.25)
		fx_requested.emit("charge",global_position+Vector2(0,-50),facing)
	if doctrine == "bloodmender" and tactic_clock >= 3 and health < max_health and healed_total < max_health/3 and hurt_left <= 0:
		tactic_clock = 0
		var heal := mini(8,mini(max_health-health,max_health/3-healed_total))
		health += heal
		healed_total += heal
		if is_instance_valid(health_display): health_display.set_health(health,max_health,is_boss)
		fx_requested.emit("charge",global_position+Vector2(0,-45),facing)
	var authored_active := _authored_action_active()
	if authored_action_was_active and not authored_active:
		windup=0;strike_left=0;recovery=0
	authored_action_was_active=authored_active
	var nearby: bool = offset.length() < (680 if enemy_kind != "guard" else 470) and absf(offset.y) < (230 if _is_hovering() else 110)
	if hurt_left > 0.0:
		hurt_left -= delta
		velocity.x = knockback
	elif authored_active:
		_sync_authored_action()
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
			if monster_variant=="tengu": fx_requested.emit("finisher",global_position+Vector2(facing*25,-50),facing)
			attack_count += 1
			if not is_instance_valid(target) or target.health <= 0:
				strike_left = 0
				return
			if is_instance_valid(contract) and signature_mode.is_empty():
				contract.cast()
			else:
				var laser_turn: bool = attack_skill == "laser" or (attack_skill == "cycle" and attack_count % 2 == 1)
				if laser_turn:
					var beam_aim: Vector2 = (target.global_position+Vector2(0,-50)-(global_position+Vector2(0,-55))).normalized()
					projectile_requested.emit("laser",global_position+Vector2(facing*36,-55),beam_aim,self)
					fx_requested.emit("charge",global_position+Vector2(facing*36,-55),facing)
				if not laser_turn and ((is_boss and enemy_kind == "sentinel") or monster_variant == "obsidian" or attack_skill in ["quake","cycle"]):
					fx_requested.emit("aerial_land",global_position,facing)
					for side in [-1.0,1.0]:
						projectile_requested.emit("fire",global_position+Vector2(side*40,-25),Vector2(side,0),self)
				if not laser_turn and (enemy_kind in ["fire", "wraith"] or attack_skill=="fan"):
					var aim: Vector2 = (target.global_position + Vector2(0, -50) - (global_position + Vector2(0, -55))).normalized()
					for angle in (roster_spec.get("volley_angles",[]) if doctrine == "bombardier" else ([-0.3,-0.15,0.0,0.15,0.3] if impostor else ([-0.24,0.0,0.24] if monster_variant == "lantern" or attack_skill=="fan" else ([-0.15, 0.0, 0.15] if enemy_kind == "fire" else [0.0])))):
						projectile_requested.emit("fire", global_position + Vector2(facing * 36, -55), aim.rotated(angle), self)
					fx_requested.emit("fire_cast", global_position + Vector2(facing * 35, -55), facing)
				elif not laser_turn:
					fx_requested.emit("slash", global_position + Vector2(facing * 35.0, -38.0), facing)
				if not laser_turn and enemy_kind in ["guard", "lancer", "sentinel"] and absf(offset.x) < melee_reach and absf(offset.y) < 65.0 and offset.x * facing > -8.0:
					target.take_damage(melee_damage, facing)
		if strike_left <= 0.0:
			recovery = float(roster_spec.get("recovery",0.55))
	elif recovery > 0.0:
		recovery -= delta
		if doctrine == "duelist" and is_on_floor() and _floor_ahead(-facing):
			velocity.x = -facing * approach_speed * 0.65
		_play("idle")
	elif nearby:
		if absf(offset.x) > 2.0:
			facing = signf(offset.x)
		var attack_reach: float = 380 if is_instance_valid(contract) else 400 if enemy_kind in ["fire", "wraith"] or attack_skill in ["laser","cycle","fan"] else melee_reach-15
		if absf(offset.x) < attack_reach and absf(offset.y) < (230 if _is_hovering() else 65) and cooldown <= 0.0 and (is_on_floor() or _is_hovering()):
			if signature_mode.is_empty() and is_instance_valid(contract) and contract.has_method("get_choreography"):
				attack_count+=1
				contract.cast()
				_sync_authored_action()
			else: windup = windup_duration
			cooldown = (2.2 if enemy_kind in ["fire", "wraith"] else (1.8 if enemy_kind == "sentinel" else 1.2))*float(roster_spec.get("cooldown_multiplier",1.0))
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
	if nearby and hurt_left <= 0 and strike_left <= 0 and windup <= 0 and recovery <= 0 and is_on_floor():
		var preferred := float(roster_spec.get("preferred_distance",0))
		if preferred > 0 and absf(offset.x) < preferred and _floor_ahead(-facing):
			velocity.x = -facing * approach_speed * 0.7
		if doctrine in ["ambusher","pursuer"] and absf(offset.x) > melee_reach and absf(offset.x) < 310 and _floor_ahead(facing):
			if doctrine == "pursuer": velocity.x = facing * approach_speed * 1.2
			elif tactic_cooldown <= 0:
				tactic_cooldown = 2.4
				tactic_clock = 0
				fx_requested.emit("charge",global_position+Vector2(0,-35),facing)
			elif tactic_clock > 0.25 and tactic_clock < 0.5: velocity.x = facing * approach_speed * 2.3
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
	if is_instance_valid(rig) and rig.has_meta("monster_cel_visual"):return
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
	if signature_mode == "glass" and recovery <= 0 and kind != "kick":
		fx_requested.emit("charge",global_position+Vector2(0,-50),facing)
		return
	if signature_mode == "glass" and kind == "kick": recovery = 0.9
	if doctrine == "bulwark" and direction*facing < 0 and kind not in ["kick","power","charged","plunge"]:
		amount = maxi(1,roundi(amount*0.55))
		fx_requested.emit("charge",global_position+Vector2(facing*20,-50),facing)
	health = maxi(0, health - amount)
	if is_instance_valid(health_display): health_display.set_health(health,max_health,is_boss)
	_audio("kick_hit" if kind == "kick" else ("impact_spirit" if enemy_kind=="wraith" else ("impact_armor" if enemy_kind in ["guard","lancer","sentinel"] else "impact")))
	if amount >= 45 and enemy_kind != "wraith": _audio("heavy_contact")
	fx_requested.emit("finisher_hit" if amount >= 45 else "impact", global_position + Vector2(0, -38), signf(direction))
	if is_instance_valid(contract) and contract.has_method("cancel_action"):contract.cancel_action()
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
		if is_instance_valid(motion_visual): motion_visual.begin_death()
		fragments_requested.emit(self,signf(direction))
		fx_requested.emit("defeat", global_position + Vector2(0, -38), signf(direction))
		remove_from_group("enemies")
		if is_boss and monster_id == 10 and not get_meta("brood_child", false):
			var brood: Array = []
			for i in range(6):
				brood.append({"monster_id":56,"position":global_position+Vector2((i-2.5)*28,-12),"brood_child":true,"health":22})
			brood_requested.emit(brood)
		defeated.emit()
		_play("death", 1.25)
		await get_tree().create_timer(1.3, false).timeout
		queue_free()

func _update_rig(delta: float) -> void:
	if not is_instance_valid(rig): return
	rig.modulate = roster_tint if health<=0 else (Color(1.12,.92,.82) if windup>0 else (Color(1.3,.7,.65) if hurt_left>0 and hit_reaction>.8 else roster_tint))
	if not is_on_floor() and absf(angular_velocity) > 0:
		tumble += angular_velocity * delta
	else:
		tumble = lerp_angle(tumble, 0, 1 - exp(-14 * delta))
		angular_velocity = move_toward(angular_velocity, 0, delta * 15)
	rig.external_roll = tumble
	var state: String = "death" if health <= 0 else ("hurt" if hurt_left > 0 else ("kick" if strike_left > 0 and enemy_kind == "fire" else ("sword" if strike_left > 0 else ("charged" if windup > 0 else ("run" if absf(velocity.x) > 20 else "idle")))))
	if (swimming or _is_hovering()) and hurt_left <= 0 and health > 0 and windup <= 0 and strike_left <= 0: state = "float"
	elif health > 0 and hurt_left <= 0 and windup <= 0 and strike_left <= 0 and not is_on_floor(): state = "jump" if velocity.y < 0 else "fall"
	var progress: float = death_elapsed / 1.3 if health <= 0 else (1.0 - strike_left / strike_duration if strike_left > 0 else 0)
	rig.update_pose(delta, state, facing, velocity, is_on_floor(), progress, hit_reaction)
	if is_instance_valid(motion_visual):
		motion_visual.tick(delta)


func _swim_physics(delta: float) -> void:
	# Water actors have their own acceleration/state path; land gravity and floor tests never run.
	hover_time += delta
	cooldown = maxf(0.0,cooldown-delta)
	recovery = maxf(0.0,recovery-delta)
	hit_reaction = move_toward(hit_reaction,0,delta*2)
	if health <= 0:
		death_elapsed += delta
		velocity = velocity.move_toward(Vector2(0,35),delta*180)
	elif hurt_left > 0:
		hurt_left = maxf(0,hurt_left-delta)
		velocity = velocity.move_toward(Vector2.ZERO,delta*280)
		angular_velocity = move_toward(angular_velocity,0,delta*9)
	elif _authored_action_active():
		_sync_authored_action()
	elif swim_charge > 0:
		swim_charge = maxf(0,swim_charge-delta)
		velocity = swim_charge_direction*300
	elif windup > 0:
		velocity = velocity.move_toward(Vector2.ZERO,delta*320)
		windup -= delta
		if windup <= 0:
			attack_count += 1
			if is_instance_valid(contract): contract.cast()
			if swim_role == "eel": swim_charge = .32
			recovery = .8
	else:
		var desired := (hover_origin+Vector2(sin(hover_time*.7)*95,sin(hover_time*1.2)*45)-global_position)*1.8
		if is_instance_valid(target) and target.health > 0 and global_position.distance_to(target.global_position)<620:
			var offset := target.global_position-global_position
			if absf(offset.x)>3: facing=signf(offset.x)
			var distance := offset.length()
			var preferred := 180.0 if swim_role == "jelly" else (230.0 if swim_role == "eel" else 105.0)
			desired=offset.normalized()*approach_speed*clampf((distance-preferred)/90,-.6,1)
			desired.y += sin(hover_time*2)*18
			if distance < preferred+65 and cooldown<=0 and recovery<=0:
				if is_instance_valid(contract) and contract.has_method("get_choreography"):
					contract.cast();_sync_authored_action()
				else: windup=.8 if swim_role=="eel" else .55
				cooldown=2.8 if swim_role=="jelly" else 2.3
				swim_charge_direction=offset.normalized()
		velocity=velocity.move_toward(desired.limit_length(approach_speed),delta*150)
	move_and_slide()
	if swim_bounds.has_area():
		var half_width := body_width*absf(scale.x)*.5+8
		var full_height := body_height*absf(scale.y)+8
		global_position.x=clampf(global_position.x,swim_bounds.position.x+half_width,swim_bounds.end.x-half_width)
		global_position.y=clampf(global_position.y,swim_bounds.position.y+full_height,swim_bounds.end.y-12)
	sprite.flip_h=facing<0
	_update_rig(delta)


func _fit_monster_body() -> void:
	var bounds: Array = rig.profile.get("body_bounds",[0,6,120,106])
	var cel_path: String="res://art/monster-cels/%03d.json"%monster_id
	if FileAccess.file_exists(cel_path):
		var cel: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(cel_path))
		var atlas: Texture2D=load(cel.texture)
		if atlas:
			var source: Image=atlas.get_image()
			var cell: int=int(cel.get("cell_size",128));var columns: int=int(cel.get("columns",4))
			var envelope:=Rect2i()
			for i in range(10):
				var used: Rect2i=source.get_region(Rect2i((i%columns)*cell,(i/columns)*cell,cell,cell)).get_used_rect()
				envelope=used if not envelope.has_area() else envelope.merge(used)
			if envelope.has_area():bounds=[envelope.position.x,envelope.position.y,envelope.size.x,envelope.size.y]
	var art_scale: float = float(rig.profile.get("scale",2))
	var world_height := 210.0 if is_boss else 120.0
	var width_cap := 360.0 if is_boss else 230.0
	var factor := minf(world_height/float(bounds[3]),width_cap/float(bounds[2]))
	rig.scale=Vector2(factor/(art_scale*maxf(scale.x,.01)),factor/(art_scale*maxf(scale.y,.01)))
	body_height=float(bounds[3])*factor/maxf(scale.y,.01)
	body_width=float(bounds[2])*factor/maxf(scale.x,.01)
	if is_instance_valid(body_collider):
		var shape := CapsuleShape2D.new()
		shape.radius=minf(body_width*.22,body_height*.28)
		shape.height=body_height*.9
		body_collider.shape=shape
		body_collider.position=Vector2(0,-shape.height*.5)
	if is_instance_valid(role_badge): role_badge.position.y=-body_height-18/maxf(scale.y,.01)

func _setup_monster_motion() -> void:
	if not is_instance_valid(rig):return
	var record: Dictionary=contract.get_choreography() if is_instance_valid(contract) and contract.has_method("get_choreography") else {}
	motion_profile=record.get("motion",{}).duplicate(true)
	if motion_profile.is_empty():
		var stance:="duelist"
		var title:=monster_name.to_lower()
		for word in ["wolf","spider","serpent","crane","moth","eel","jelly"]:
			if word in title:stance={"crane":"flyer"}.get(word,word);break
		motion_profile={"stance":stance,"windup":windup_duration,"commit":.32,"recovery":float(roster_spec.get("recovery",.55)),"stride":55+monster_id*.47,"reach":melee_reach,"lead":"left" if monster_id%2 else "right"}
	windup_duration=float(motion_profile.get("windup",windup_duration))
	if not is_instance_valid(motion_visual):
		motion_visual=preload("res://actors/monster_cel_motion.gd").new() if FileAccess.file_exists("res://art/monster-cels/%03d.json"%monster_id) else preload("res://actors/monster_motion.gd").new()
		rig.body_pivot.add_child(motion_visual)
	motion_visual.configure(self,motion_profile)
	if not has_node("MotionAccents"):
		var accents=preload("res://actors/monster_motion_fx.gd").new()
		accents.name="MotionAccents";accents.actor=self;add_child(accents)

func _authored_action_active() -> bool:
	return is_instance_valid(contract) and contract.has_method("get_choreography") and bool(contract.get("action_active"))

func _sync_authored_action() -> void:
	var time: float=float(contract.current_action_time)
	var anticipation: float=float(motion_profile.get("windup",.4))
	var commit: float=float(motion_profile.get("commit",.32))
	windup=maxf(0,anticipation-time)
	strike_duration=commit
	strike_left=maxf(0,anticipation+commit-time) if time>=anticipation and time<anticipation+commit else 0
	recovery=maxf(0,float(contract.current_action_duration)-time) if time>=anticipation+commit else 0
	var stance: String=str(motion_profile.get("stance","duelist"))
	velocity.x=0 # Anticipation has a planted support instead of sliding windup.
	if strike_left>0:
		var phase:=1-strike_left/maxf(.01,commit)
		var drive:=sin(phase*PI)
		var strength: float=200 if stance in ["wolf","beast","quadruped","pouncer"] else (120 if stance in ["flyer","bird","winged"] else 48)
		if swimming:
			velocity=swim_charge_direction*strength*drive
		elif is_on_floor() and _floor_ahead(facing):
			velocity.x=facing*strength*drive
			if stance in ["wolf","beast","quadruped","pouncer"] and phase<.18:velocity.y=-95
		elif _is_hovering() or stance in ["wolf","beast","quadruped","pouncer"]:
			velocity.x=facing*strength*drive
			if _is_hovering() and is_instance_valid(target):
				velocity.y=clampf(target.global_position.y-35-global_position.y,-160,160)*drive
	elif recovery>0 and stance in ["duelist","ronin","samurai"] and is_on_floor() and _floor_ahead(-facing):
		velocity.x=-facing*30

func attack_origin(offset: Vector2 = Vector2.ZERO) -> Vector2:
	var reach: float=motion_visual.lunge*10 if is_instance_valid(motion_visual) else 0
	return global_position+Vector2((offset.x+reach)*facing,offset.y)

func _is_hovering() -> bool:
	if is_instance_valid(motion_visual) and motion_visual.has_method("_choose_frame"):
		var locomotion: String=str(motion_visual.manifest.get("locomotion",""))
		if not locomotion.is_empty():return locomotion in ["fly","swim"]
	return enemy_kind=="wraith" or str(motion_profile.get("stance","")) in ["flyer","bird"]
