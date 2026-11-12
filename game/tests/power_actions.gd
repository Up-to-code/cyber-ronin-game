extends SceneTree
var player: CharacterBody2D
var guard: CharacterBody2D
var world: Node2D
var fx: Node2D
var events: Array[String] = []
func _initialize() -> void: call_deferred("_run")
func _ticks(count: int) -> void:
	for i in range(count):
		await physics_frame
		await process_frame
func _tap(action: String) -> void:
	Input.action_press(action)
	await _ticks(1)
	Input.action_release(action)
	await _ticks(1)
func _check(ok: bool, message: String) -> bool:
	if not ok:
		push_error(message)
		quit(1)
	return ok
func _run() -> void:
	world = Node2D.new()
	root.add_child(world)
	var floor_body := StaticBody2D.new()
	var collider := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(2000,80)
	collider.shape = rectangle
	floor_body.position = Vector2(800,650)
	floor_body.add_child(collider)
	world.add_child(floor_body)
	fx = load("res://systems/pixel_fx.gd").new()
	world.add_child(fx)
	player = load("res://actors/player_2d.gd").new()
	player.position = Vector2(300,610)
	world.add_child(player)
	guard = load("res://actors/enemy_2d.gd").new()
	guard.position = Vector2(370,610)
	guard.health = 1000
	world.add_child(guard)
	guard.set_physics_process(false)
	player.fx_requested.connect(func(kind: String, at: Vector2, facing: float):
		events.append(kind)
		if kind not in ["dodge", "dash_trail"]: fx.spawn(kind, at, facing))
	await _ticks(10)
	await _tap("kick")
	await _ticks(30)
	if not _check(guard.health == 980 and player.power == 100 and player.health == 100, "Kick must hit once for 20 without spending health or power"):
		return
	await _tap("power_attack")
	await _ticks(10)
	if not _check(player.power == 50 and player.health == 100 and guard.health == 890, "Power must spend exactly 50 energy and hit once for 90"):
		return
	await _ticks(23)
	player.power = 0
	var before: int = guard.health
	await _tap("power_attack")
	await _ticks(12)
	if not _check(guard.health == before and player.attack_time == 0 and events.count("power_empty") == 1, "Empty power must not create a phantom attack or spend HP"):
		return
	player.power = 100
	Input.action_press("attack")
	await _ticks(62)
	if not _check(player.charging and player.charge_time >= 0.30, "Held sword must visibly charge after the normal strike"):
		return
	Input.action_release("attack")
	await _ticks(10)
	if not _check(player.power == 70 and events.count("charged") == 1 and not player.charging, "Releasing charged sword must spend 30 power and strike once"):
		return
	await _ticks(25)
	Input.action_press("attack")
	await _ticks(40)
	player.invulnerable = 0
	player.take_damage(10)
	Input.action_release("attack")
	await _ticks(20)
	if not _check(not player.charging and events.count("charged") == 1 and player.health == 90, "Hurt must cancel charge without a stale release"):
		return
	player.hurt_left = 0
	player.position = Vector2(300,420)
	player.velocity = Vector2.ZERO
	await _ticks(2)
	before = guard.health
	Input.action_press("move_down")
	await _tap("attack")
	Input.action_release("move_down")
	await _ticks(35)
	if not _check(player.is_on_floor() and not player.plunging and guard.health == before - 55 and events.count("aerial_land") == 1, "Explicit DOWN + aerial sword must descend, land, and apply one ground impact"):
		return
	fx.spawn("slash", Vector2.ZERO, 1)
	fx.spawn("slash_reverse", Vector2.ZERO, 1)
	var light: float = 0
	var heavy: float = 0
	for effect in fx.get_children():
		if effect is AnimatedSprite2D:
			if effect.get_meta("event", "") == "slash": light = effect.scale.x
			if effect.get_meta("event", "") == "slash_reverse": heavy = effect.scale.x
	if not _check(heavy >= light * 1.8, "Double attack VFX must be materially larger than the light slash"):
		return
	await _ticks(90)
	if not _check(player.power > 70 and fx.get_child_count() == 0, "Power regenerates after delay and VFX expire"):
		return
	print("PASS: independent health/power, kick, power costs/empty rejection, held charge/release/hurt cancellation, aerial impact, larger double attack and FX cleanup")
	world.queue_free()
	await _ticks(2)
	quit()
