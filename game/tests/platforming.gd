extends SceneTree
const Player = preload("res://actors/player_2d.gd")
const Enemy = preload("res://actors/enemy_2d.gd")
const MovingPlatform = preload("res://systems/moving_platform.gd")
var world: Node2D
var player: CharacterBody2D
var floor_body: StaticBody2D
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
func _collider(body: PhysicsBody2D, size: Vector2) -> void:
	var shape := RectangleShape2D.new()
	shape.size = size
	var collision := CollisionShape2D.new()
	collision.shape = shape
	body.add_child(collision)
func _settle() -> void:
	Input.action_release("jump")
	Input.action_release("move_right")
	Input.action_release("sprint")
	player.position = Vector2(200, 605)
	player.velocity = Vector2.ZERO
	player.coyote_left = 0.0
	player.jump_buffer_left = 0.0
	await _ticks(12)
func _height(hold_ticks: int) -> float:
	await _settle()
	var floor_y: float = player.position.y
	var minimum_y: float = floor_y
	Input.action_press("jump")
	await _ticks(1)
	for i in range(48):
		if i == hold_ticks:
			Input.action_release("jump")
		await _ticks(1)
		minimum_y = minf(minimum_y, player.position.y)
	Input.action_release("jump")
	return floor_y - minimum_y
func _run() -> void:
	world = Node2D.new()
	root.add_child(world)
	floor_body = StaticBody2D.new()
	floor_body.position = Vector2(400, 620)
	_collider(floor_body, Vector2(800, 20))
	world.add_child(floor_body)
	player = Player.new()
	player.position = Vector2(200, 610)
	world.add_child(player)
	await _settle()
	if not _check(player.is_on_floor(), "player feet must meet collision top"):
		return
	var short_height: float = await _height(1)
	var tall_height: float = await _height(25)
	if not _check(tall_height > short_height + 45.0 and tall_height > 95.0, "holding jump must produce a taller arc (%s vs %s)" % [tall_height, short_height]):
		return
	await _settle()
	floor_body.collision_layer = 0
	await _ticks(2)
	if not _check(not player.is_on_floor() and player.coyote_left > 0.0, "coyote time must survive leaving a ledge"):
		return
	Input.action_press("jump")
	await _ticks(1)
	Input.action_release("jump")
	if not _check(player.velocity.y < -500.0, "jump within coyote window must launch"):
		return
	floor_body.collision_layer = 1
	await _settle()
	player.position = Vector2(200, 585)
	player.velocity = Vector2(0, 400)
	await _ticks(2)
	player.coyote_left = 0.0
	Input.action_press("jump")
	var bounced: bool = false
	for i in range(10):
		await _ticks(1)
		if player.velocity.y < -500.0:
			bounced = true
			break
	Input.action_release("jump")
	if not _check(bounced, "buffered jump before landing must launch on contact"):
		return
	await _settle()
	Input.action_press("sprint")
	Input.action_press("move_right")
	await _ticks(1)
	var initial_speed: float = player.velocity.x
	await _ticks(8)
	var running_speed: float = player.velocity.x
	Input.action_release("move_right")
	Input.action_release("sprint")
	await _ticks(8)
	if not _check(initial_speed > 0.0 and initial_speed < running_speed and absf(player.velocity.x) < 1.0, "movement must accelerate and stop with grounded friction"):
		return
	floor_body.collision_layer = 0
	var platform: AnimatableBody2D = MovingPlatform.new()
	platform.position = Vector2(200, 610)
	platform.travel = Vector2(180, 0)
	platform.duration = 3.0
	_collider(platform, Vector2(180, 20))
	world.add_child(platform)
	player.position = Vector2(200, 594)
	player.velocity = Vector2.ZERO
	await _ticks(12)
	if not _check(player.is_on_floor(), "player must land on moving platform"):
		return
	var relative_x: float = player.position.x - platform.position.x
	var platform_start: float = platform.position.x
	await _ticks(28)
	if not _check(platform.position.x > platform_start + 25.0 and absf(player.position.x - platform.position.x - relative_x) < 6.0, "moving platform must carry standing player"):
		return
	platform.reset_motion()
	if not _check(is_zero_approx(platform.elapsed), "moving platform reset must restore its phase clock"):
		return
	var ledge := StaticBody2D.new()
	ledge.position = Vector2(1100, 620)
	_collider(ledge, Vector2(200, 20))
	world.add_child(ledge)
	player.set_physics_process(false)
	player.position = Vector2(1300, 610)
	var enemy: CharacterBody2D = Enemy.new()
	enemy.position = Vector2(1170, 605)
	enemy.target = player
	world.add_child(enemy)
	await _ticks(65)
	if not _check(enemy.is_on_floor() and enemy.position.x < 1180.0, "pursuing enemy must stop before an unsupported ledge"):
		return
	print("PASS: feet contact, variable jump, coyote time, jump buffer, acceleration/friction, moving-platform carry/reset, enemy ledge safety")
	world.queue_free()
	await process_frame
	await process_frame
	await _integration()

func _integration() -> void:
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.start_game()
	await scene.level_loaded
	await _ticks(20)
	for guard in get_nodes_in_group("enemies"):
		if not _check(guard.is_on_floor() and absf(guard.position.y - 550.0) < 1.0, "integrated enemy must stand on textured platform collision"):
			return
		guard.set_physics_process(false)
	player = scene.player
	player.position = Vector2(840, 548)
	player.velocity = Vector2.ZERO
	await _ticks(10)
	Input.action_press("sprint")
	Input.action_press("move_right")
	await _ticks(10)
	Input.action_press("jump")
	await _ticks(25)
	Input.action_release("jump")
	var landed_on_lift: bool = false
	for i in range(50):
		await _ticks(1)
		if player.is_on_floor() and player.position.x > 930.0 and player.position.x < 1200.0:
			landed_on_lift = true
			break
	Input.action_release("move_right")
	Input.action_release("sprint")
	if not _check(landed_on_lift, "first actual gap jump must reach moving platform"):
		return
	await _ticks(8)
	Input.action_press("sprint")
	Input.action_press("move_right")
	for i in range(15):
		await _ticks(1)
		if player.position.x > scene.moving_platform.position.x + 35.0:
			break
	Input.action_press("jump")
	await _ticks(25)
	Input.action_release("jump")
	var crossed: bool = false
	for i in range(55):
		await _ticks(1)
		if player.is_on_floor() and player.position.x > 1200.0:
			crossed = true
			break
	Input.action_release("move_right")
	Input.action_release("sprint")
	if not _check(crossed, "second actual gap jump must reach right-hand ground"):
		return
	# Lock the opponent's AI so this checks contact timing, not a competing strike.
	var guard: Node = get_nodes_in_group("enemies")[0]
	guard.position = player.position + Vector2(80, 0)
	player.facing = 1.0
	Input.action_press("attack")
	await _ticks(4)
	Input.action_release("attack")
	if not _check(guard.health == 70, "attack must not damage before contact frame"):
		return
	await _ticks(5)
	if not _check(guard.health == 35, "attack must damage on the active contact window"):
		return
	await _ticks(20)
	if not _check(guard.health == 35, "one swing must not damage the same guard twice"):
		return
	player.invulnerable = 0.0
	player.take_damage(100)
	await create_timer(1.9).timeout
	if not _check(paused and scene.hud.screens.back() == "death", "death must pause gameplay behind retry menu"):
		return
	scene.retry_game()
	await scene.level_loaded
	if not _check(not paused and player.health == 100 and is_zero_approx(player.hurt_left) and is_zero_approx(player.attack_time), "retry must restore health and clear transient movement states"):
		return
	await _ticks(8)
	if not _check(player.is_on_floor() and absf(player.position.y - 550.0) < 1.0, "retry must restore player feet to actual platform"):
		return
	print("PASS: integrated enemy grounding, two-jump gap traversal, attack timing/single hit, death/retry reset")
	scene.queue_free()
	await process_frame
	await process_frame
	quit()
