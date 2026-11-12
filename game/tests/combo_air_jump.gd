extends SceneTree
var player: CharacterBody2D
var fx: Node2D
var events: Array[String] = []
func _initialize() -> void:
	call_deferred("_run")
func _ticks(count: int) -> void:
	for i in range(count):
		await physics_frame
		await process_frame
func _press(action: String) -> void:
	Input.action_press(action)
	await _ticks(1)
	Input.action_release(action)
	await _ticks(1)
func _check(condition: bool, message: String) -> bool:
	if not condition:
		push_error(message)
		quit(1)
	return condition
func _run() -> void:
	var world := Node2D.new()
	root.add_child(world)
	var floor_body := StaticBody2D.new()
	var collider := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(2000, 80)
	collider.shape = shape
	floor_body.position = Vector2(800,650)
	floor_body.add_child(collider)
	world.add_child(floor_body)
	fx = load("res://systems/pixel_fx.gd").new()
	world.add_child(fx)
	player = load("res://actors/player_2d.gd").new()
	player.position = Vector2(300,610)
	world.add_child(player)
	player.fx_requested.connect(func(kind: String, at: Vector2, direction: float):
		events.append(kind)
		if kind not in ["dodge", "dash_trail"]: fx.spawn(kind, at, direction))
	await _ticks(10)
	await _press("jump")
	await _ticks(5)
	await _press("jump")
	if not _check(player.air_jumps_left == 0 and player.velocity.y < -150 and events.count("air_jump") == 1, "Second tap must produce one upward air jump and its own VFX"):
		return
	await _ticks(5)
	var previous: float = player.velocity.y
	await _press("jump")
	if not _check(player.velocity.y > previous and events.count("air_jump") == 1, "Third tap must not create an unlimited jump"):
		return
	await _ticks(85)
	if not _check(player.is_on_floor() and player.air_jumps_left == 1, "Landing must recharge the air jump"):
		return
	var guard: CharacterBody2D = load("res://actors/enemy_2d.gd").new()
	guard.position = player.position + Vector2(85, 0)
	guard.health = 500
	world.add_child(guard)
	guard.set_physics_process(false)
	await _press("attack")
	await _ticks(3)
	await _press("attack")
	await _ticks(25)
	if not _check(player.combo_step == 2 and player.rig.current_clip == "sword2", "Early repeated attack tap must queue the second authored clip"):
		return
	await _press("attack")
	for frame in range(40):
		if player.combo_step == 3: break
		await _ticks(1)
	await _ticks(16)
	if not _check(player.combo_step == 3 and player.rig.current_clip == "sword3" and events.count("finisher") == 1, "Third strike must use the finisher clip and VFX"):
		return
	await _ticks(60)
	if not _check(guard.health == 385, "Each combo strike must damage once: 35 + 35 + 45"):
		return
	var slashes: int = events.count("slash")
	Input.action_press("attack")
	await _ticks(65)
	Input.action_release("attack")
	if not _check(events.count("slash") == slashes + 1 and player.combo_step == 1, "Holding attack must not auto-repeat; an expired combo must restart"):
		return
	await _press("move_right")
	await _ticks(3)
	await _press("move_right")
	if not _check(player.dodge_time > 0 and events.count("dodge") == 1, "Double-tapping direction must trigger dash"):
		return
	await _ticks(45)
	player.facing = 1
	player._start_attack()
	await _press("move_left")
	await _ticks(3)
	await _press("move_left")
	if not _check(player.dash_direction == -1 and player.attack_time == 0, "Directional double tap must cancel attack and dash toward the tapped side"):
		return
	await _ticks(45)
	if not _check(fx.get_child_count() == 0, "Transient VFX must clean up after a burst"):
		return
	print("PASS: bounded double jump/recharge, tap-buffered authored 3-hit combo, no held autoattack, directional double tap, VFX cleanup")
	world.queue_free()
	await _ticks(2)
	quit()
