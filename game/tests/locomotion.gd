extends SceneTree
const Player = preload("res://actors/player_2d.gd")
const Enemy = preload("res://actors/enemy_2d.gd")
var world: Node2D
var player: CharacterBody2D
var step_dust_count: int = 0
func _initialize() -> void:
	call_deferred("_run")
func _ticks(count: int) -> void:
	for i in range(count):
		await physics_frame
		await process_frame
func _check(condition: bool, message: String) -> bool:
	if not condition:
		push_error("FAIL: " + message)
		quit(1)
		return false
	return true
func _run() -> void:
	if not InputMap.has_action("sprint"):
		InputMap.add_action("sprint")
	world = Node2D.new()
	root.add_child(world)
	var floor_body := StaticBody2D.new()
	floor_body.position = Vector2(1500,620)
	var collider := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(3000,20)
	collider.shape = rectangle
	floor_body.add_child(collider)
	world.add_child(floor_body)
	player = Player.new()
	player.position = Vector2(200,610)
	player.map_width = 4000
	player.fx_requested.connect(func(kind: String, _at: Vector2, _direction: float):
		if kind == "step":
			step_dust_count += 1)
	world.add_child(player)
	await _ticks(10)
	Input.action_press("move_right")
	await _ticks(20)
	if not _check(absf(player.velocity.x - 300.0) < 1.0 and player.sprite.animation == "run" and player.sprite.is_playing(), "movement must use the run cycle at 300 without a RUN button"):
		return
	var walking_frame: int = player.sprite.frame
	await _ticks(8)
	if not _check(player.sprite.frame != walking_frame, "walking animation must advance rather than restart"):
		return
	Input.action_press("sprint")
	await _ticks(20)
	if not _check(absf(player.velocity.x - 300.0) < 1.0 and player.sprite.animation == "run", "legacy sprint input must not change the single movement speed"):
		return
	await _ticks(42)
	if not _check(step_dust_count > 0 and step_dust_count < 6, "run dust must be sparse and cadence-linked"):
		return
	Input.action_release("sprint")
	Input.action_release("move_right")
	await _ticks(10)
	Input.action_press("jump")
	await _ticks(2)
	if not _check(player.rig.pose_scale.y > 1.0, "takeoff stretch must reach the visible cel rig"):
		return
	if not _check(player.rig.feet_local().length() < 2.0, "a visible takeoff stretch must keep the drawn feet planted"):
		return
	await _ticks(6)
	var rise_frame: int = player.sprite.frame
	if not _check(player.sprite.animation == "jump" and not player.sprite.is_playing() and player.velocity.y < 0, "rising jump must hold its physical-phase pose"):
		return
	Input.action_release("jump")
	var saw_fall: bool = false
	for i in range(45):
		await _ticks(1)
		if player.velocity.y > 120 and not player.is_on_floor():
			saw_fall = player.sprite.frame != rise_frame
		if player.is_on_floor():
			break
	if not _check(saw_fall and player.is_on_floor(), "falling must use a different pose and return feet to ground"):
		return
	await _ticks(2)
	if not _check(player.sprite.scale.y < 2.0 and player.rig.pose_scale.y < 1.0 and player.is_on_floor(), "landing squash must reach the visible cel rig while collision stays grounded"):
		return
	if not _check(player.rig.feet_local().length() < 2.0, "the landing squash must keep the drawn feet planted instead of sliding the pose"):
		return
	await _ticks(24)
	if not _check(player.sprite.scale.distance_to(Vector2(2,2)) < 0.01 and player.rig.pose_scale.distance_to(Vector2.ONE) < 0.01 and player.sprite.animation == "idle", "landing presentation must settle to its exact base"):
		return
	# Airborne J keeps the normal sword; DOWN+J is the deliberate plunge.
	Input.action_press("jump")
	await _ticks(2)
	Input.action_release("jump")
	for i in range(12):
		if not player.is_on_floor():
			break
		await _ticks(1)
	if not _check(not player.is_on_floor(), "test setup: jump must leave the floor"):
		return
	Input.action_press("attack")
	await _ticks(2)
	Input.action_release("attack")
	if not _check(player.attack_kind == "sword" and not player.plunging, "airborne J must keep the normal sword, not force a plunge"):
		return
	for i in range(90):
		await _ticks(1)
		if player.is_on_floor():
			break
	Input.action_press("jump")
	await _ticks(2)
	Input.action_release("jump")
	for i in range(12):
		if not player.is_on_floor():
			break
		await _ticks(1)
	if not _check(not player.is_on_floor(), "test setup: second jump must leave the floor"):
		return
	Input.action_press("move_down")
	await _ticks(1)
	Input.action_press("attack")
	for i in range(12):
		await _ticks(1)
		if player.plunging:
			break
	Input.action_release("attack")
	if not _check(player.attack_kind == "plunge" and player.plunging, "DOWN+J in the air must explicitly request a plunge"):
		return
	for i in range(90):
		await _ticks(1)
		if player.is_on_floor():
			break
	Input.action_release("move_down")
	if not _check(player.is_on_floor(), "plunge must return the feet to ground"):
		return
	player.take_damage(1)
	if not _check(player.attack_time == 0 and player.sprite.animation == "hurt", "hurt must cancel the active attack and its animation"):
		return
	player.reset_motion_presentation()
	if not _check(player.sprite.scale == Vector2(2,2) and is_zero_approx(player.footstep_distance) and is_zero_approx(player.takeoff_left), "retry presentation reset must clear all gait and scale state"):
		return
	var enemy: CharacterBody2D = Enemy.new()
	enemy.position = Vector2(1100,500)
	enemy.target = player
	world.add_child(enemy)
	await _ticks(2)
	if not _check(enemy.sprite.animation == "jump" and not enemy.sprite.is_playing(), "an airborne guard must not keep running in place"):
		return
	await _ticks(25)
	if not _check(enemy.is_on_floor() and enemy.sprite.animation in ["walk","idle","run"], "guard must recover its ground gait on landing"):
		return
	player.position.x = 3998
	await _ticks(1)
	if not _check(player.position.x <= 3976.0, "character bounds must follow the supplied map width"):
		return
	print("PASS: single movement speed without RUN, cadence, rise/fall poses, landing recovery, attack/hurt ownership, map bounds, grounded enemy presentation")
	world.queue_free()
	await process_frame
	await process_frame
	quit()
