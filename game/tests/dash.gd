extends SceneTree
var player: CharacterBody2D
var trails: int = 0
var bursts: int = 0
func _initialize() -> void:
	call_deferred("_run")
func _ticks(count: int) -> void:
	for i in range(count):
		await physics_frame
		await process_frame
func _check(value: bool, message: String) -> bool:
	if not value:
		push_error(message)
		quit(1)
	return value
func _box(world: Node, at: Vector2, size: Vector2) -> void:
	var body := StaticBody2D.new()
	body.position = at
	var collider := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collider.shape = shape
	body.add_child(collider)
	world.add_child(body)
func _press_dash() -> void:
	Input.action_press("dodge")
	await _ticks(1)
	Input.action_release("dodge")
func _run() -> void:
	var world := Node2D.new()
	root.add_child(world)
	_box(world, Vector2(1500,620), Vector2(3000,20))
	_box(world, Vector2(700,420), Vector2(20,400))
	player = load("res://actors/player_2d.gd").new()
	player.position = Vector2(200,610)
	player.fx_requested.connect(func(kind: String, _at: Vector2, _direction: float):
		if kind == "dodge": bursts += 1
		if kind == "dash_trail": trails += 1)
	world.add_child(player)
	await _ticks(10)
	var start: float = player.position.x
	await _press_dash()
	Input.action_press("move_left")
	await _ticks(7)
	Input.action_release("move_left")
	if not _check(player.position.x > start + 85 and player.dash_direction == 1 and not player.sprite.is_playing(), "Dash must burst in locked direction with a held lean pose"):
		return
	player.take_damage(20)
	if not _check(player.health == 100 and bursts == 1 and trails >= 2 and trails <= 4, "Dash must own a short invulnerability window and bounded trail events"):
		return
	await _ticks(18)
	await _press_dash()
	if not _check(bursts == 1, "Cooldown must prevent immediate repeated dash"):
		return
	player.dodge_cooldown = 0
	player.position = Vector2(650,610)
	player.velocity = Vector2.ZERO
	player.facing = 1
	await _press_dash()
	await _ticks(10)
	if not _check(player.position.x <= 671 and player.dodge_time <= 0, "Dash must stop at wall rather than tunnel"):
		return
	player.position = Vector2(300,450)
	player.velocity = Vector2(0,250)
	player.dodge_cooldown = 0
	await _ticks(2)
	await _press_dash()
	var height: float = player.position.y
	await _ticks(5)
	if not _check(absf(player.position.y - height) < 0.5, "Air dash must hold its horizontal line during burst"):
		return
	await _ticks(12)
	if not _check(player.velocity.y > 0 and player.dodge_time == 0, "Gravity must resume when dash ends"):
		return
	print("PASS: locked dash burst/pose, bounded trails, invulnerability/cooldown, wall collision, air line and gravity recovery")
	world.queue_free()
	await process_frame
	await process_frame
	quit()
