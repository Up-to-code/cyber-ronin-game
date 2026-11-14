extends RefCounted
# Combat presentation policy: which effect plays, where it sits on the actor,
# how much camera trauma and damage-veil it earns, and how projectiles spawn.
# pixel_fx stays a leaf renderer; it never decides any of this.
const PixelBurst = preload("res://systems/pixel_burst.gd")
const CombatProjectile = preload("res://systems/combat_projectile.gd")
const TelegraphBeam = preload("res://systems/telegraph_beam.gd")

const AIMED_KINDS := ["slash", "slash_reverse", "finisher", "sweep", "charged", "kick", "ranged", "energy"]
const PLAYER_IMPACT := ["impact", "finisher_hit"]
const GROUND_KINDS := ["step", "land", "jump", "aerial_land"]
const EFFECT_BUDGET := 60
const PROJECTILE_BUDGET := 48

var fx: Node2D
var player: CharacterBody2D
var camera: RefCounted
var veil: Node
var water: Node2D
var root: Node2D

func bind(p_fx: Node2D, p_player: CharacterBody2D, p_camera: RefCounted, p_veil: Node, p_root: Node2D) -> void:
	fx = p_fx
	player = p_player
	camera = p_camera
	veil = p_veil
	root = p_root

func enemy(kind: String, at: Vector2, direction: float) -> void:
	if kind == "water":
		_splash(at, 8)
		return
	fx.spawn("enemy_slash" if kind == "slash" else kind, at, direction)
	if kind == "defeat" and player.global_position.distance_to(at) < 260:
		_splash_veil(0.55)
		camera.add_trauma(0.20, 0.7)
	if kind in PLAYER_IMPACT:
		camera.add_trauma(0.52 if kind == "finisher_hit" else 0.30)

func player_effect(kind: String, at: Vector2, direction: float) -> void:
	if kind.begins_with("swim") or kind == "water":
		_splash(at, 8)
		return
	if kind in PLAYER_IMPACT:
		camera.add_trauma(0.36)
		_splash_veil(1.0)
	at = _player_socket(kind, at)
	if kind == "kick":
		fx.spawn("kick_wind", at, direction)
	if kind in ["land", "aerial_land"]:
		camera.add_trauma(0.48 if kind == "aerial_land" else 0.32, 0.60)
	_spawn_snow(kind, at, direction)
	if kind in ["dodge", "dash_trail"]:
		_dash_trail(kind, at, direction)
		return
	var previous := fx.get_children()
	fx.spawn(kind, at, direction)
	if kind in AIMED_KINDS:
		_aim_new_effects(previous)
	if kind in PLAYER_IMPACT and player.velocity.length() > 80 and is_instance_valid(player.rig):
		fx.rig_trail(player.rig)

func projectile(kind: String, at: Vector2, direction: Vector2, source: Node) -> void:
	if kind == "fire" and is_instance_valid(water) and water.contains(at):
		water.splash(at, 6)
		return
	if root.get_tree().get_nodes_in_group("combat_projectiles").size() >= PROJECTILE_BUDGET:
		return
	if kind == "laser":
		_spawn_laser(at, direction, source)
		return
	var shot: Node = CombatProjectile.new()
	shot.kind = kind
	shot.position = at
	shot.direction = direction.normalized()
	shot.from_player = source == player
	shot.owner_body = source
	shot.speed = 760 if source == player else 360
	shot.damage = 40 if source == player else source.projectile_damage
	shot.life = 0.85 if source == player else 1.8
	shot.impact.connect(func(point: Vector2, family: String):
		water_impact(point) if family == "water" else fx.spawn("fire_impact" if family == "fire" else "wall_hit", point, direction.x))
	root.add_child(shot)

func water_impact(at: Vector2) -> void:
	_splash(at, 12)

func _player_socket(kind: String, at: Vector2) -> Vector2:
	if kind == "sweep":
		return player.global_position + Vector2(0, -36)
	if kind in ["slash_reverse", "finisher", "charged"]:
		return player.global_position + Vector2(0, -62)
	if kind == "power":
		return player.global_position + Vector2(0, -6)
	return at

func _spawn_snow(kind: String, at: Vector2, direction: float) -> void:
	if kind not in GROUND_KINDS or fx.get_child_count() >= EFFECT_BUDGET:
		return
	var snow := PixelBurst.new()
	snow.position = at
	snow.tint = Color("d7e5ed")
	snow.count = 5 if kind == "step" else 12
	snow.spread = 0.45 if kind == "step" else 0.85
	snow.lifetime = 0.35
	snow.direction = direction
	fx.add_child(snow)

func _dash_trail(kind: String, at: Vector2, direction: float) -> void:
	if is_instance_valid(player.rig):
		fx.rig_trail(player.rig)
	else:
		fx.trail(player.sprite, at, direction)
	if kind == "dodge":
		fx.burst("dash_start", at + Vector2(0, -32), direction)
		if player.is_on_floor():
			fx.spawn("step", at, direction)

func _aim_new_effects(previous: Array) -> void:
	var angle: float = Vector2(1, 0).angle_to(player.attack_aim)
	for effect in fx.get_children():
		if effect in previous: continue
		effect.rotation += angle
		effect.set_meta("follow_actor", player)
		effect.set_meta("follow_offset", effect.global_position - player.global_position)

func _spawn_laser(at: Vector2, direction: Vector2, source: Node) -> void:
	var beam: Node = TelegraphBeam.new()
	beam.position = at + (direction * 28 if source == player else Vector2.ZERO)
	beam.direction = direction
	beam.owner_body = source
	beam.from_player = source == player
	beam.damage = 60 if source == player else source.projectile_damage
	beam.impact.connect(func(point: Vector2, _family: String): fx.spawn("fire_impact", point, direction.x))
	root.add_child(beam)

func _splash(at: Vector2, amount: int) -> void:
	if is_instance_valid(water): water.splash(at, amount)

func _splash_veil(strength: float) -> void:
	if is_instance_valid(veil): veil.splash(strength)
