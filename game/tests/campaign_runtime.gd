extends SceneTree

# Integration checks use the real campaign scene, colliders and controller.
# Representative jumps begin from injected, settled approach positions. Movement
# after that setup is produced only by sprint/direction/jump input. This is not
# a full player playthrough and does not establish combat pacing or fun.
var scene: Node
var loaded_count: int = 0
var last_loaded: int = 0
var failed: bool = false

func _initialize() -> void:
	call_deferred("_run")

func _on_level_loaded(index: int) -> void:
	loaded_count += 1
	last_loaded = index

func _ticks(count: int) -> void:
	for i in range(count):
		await physics_frame
		await process_frame

func _check(condition: bool, message: String) -> bool:
	if not condition:
		failed = true
		push_error("FAIL: " + message)
		_release_input()
		quit(1)
		return false
	return true

func _release_input() -> void:
	for action in ["move_left", "move_right", "jump", "sprint", "attack", "dodge", "interact"]:
		Input.action_release(action)

func _inject_approach(at: Vector2) -> void:
	_release_input()
	var player: CharacterBody2D = scene.player
	player.set_physics_process(true)
	player.position = at
	player.velocity = Vector2.ZERO
	player.invulnerable = 999
	player.attack_time = 0
	player.dodge_time = 0
	player.hurt_left = 0
	player.jump_buffer_left = 0
	player.coyote_left = 0
	player.reset_motion_presentation()
	await _ticks(10)

func _check_camera(data: Dictionary) -> bool:
	var player: CharacterBody2D = scene.player
	player.set_physics_process(false)
	var half_width: float = scene.get_viewport_rect().size.x/(2.0*scene.camera.zoom.x)
	player.position.x = data.width - 30
	await _ticks(120)
	if not _check(absf(scene.camera.position.x - maxf(half_width, data.width - half_width)) < 0.2, "level %d right camera bound must use map width" % data.id):
		return false
	player.position.x = 30
	await _ticks(120)
	if not _check(absf(scene.camera.position.x - half_width) < 0.2, "level %d left camera bound" % data.id):
		return false
	player.set_physics_process(true)
	return true

func _first_route() -> bool:
	var player: CharacterBody2D = scene.player
	await _inject_approach(Vector2(840,548))
	Input.action_press("sprint")
	Input.action_press("move_right")
	await _ticks(10)
	Input.action_press("jump")
	await _ticks(25)
	Input.action_release("jump")
	var landed: bool = false
	for i in range(50):
		await _ticks(1)
		if player.is_on_floor() and player.position.x > 930 and player.position.x < 1200:
			landed = true
			break
	Input.action_release("move_right")
	if not _check(landed, "level 1 first jump must reach actual moving bridge"):
		return false
	await _ticks(8)
	Input.action_press("move_right")
	for i in range(15):
		await _ticks(1)
		if player.position.x > scene.moving_platform.position.x + 35:
			break
	Input.action_press("jump")
	await _ticks(25)
	Input.action_release("jump")
	var crossed: bool = false
	for i in range(55):
		await _ticks(1)
		if player.is_on_floor() and player.position.x > 1200:
			crossed = true
			break
	_release_input()
	return _check(crossed, "level 1 second jump must reach actual right causeway")

func _representative_rising_gap(data: Dictionary) -> bool:
	var primary: Array[Dictionary] = []
	for platform in data.platforms:
		if not platform.get("optional", false):
			primary.append(platform)
	var source: Dictionary = {}
	var target: Dictionary = {}
	for i in range(primary.size() - 1):
		if primary[i + 1].center.y < primary[i].center.y:
			source = primary[i]
			target = primary[i + 1]
			break
	if not _check(not source.is_empty(), "level %d needs a representative rising route" % data.id):
		return false
	var right_edge: float = source.center.x + source.width / 2
	var target_left: float = target.center.x - target.width / 2
	await _inject_approach(Vector2(right_edge - 70, source.center.y - 2))
	var player: CharacterBody2D = scene.player
	if not _check(player.is_on_floor(), "level %d injected approach must settle on source platform" % data.id):
		return false
	Input.action_press("sprint")
	Input.action_press("move_right")
	await _ticks(12)
	var launch_x: float = player.position.x
	Input.action_press("jump")
	await _ticks(25)
	Input.action_release("jump")
	var reached: bool = false
	for i in range(50):
		await _ticks(1)
		if player.is_on_floor() and player.position.x > target_left + 5 and absf(player.position.y - target.center.y) < 1:
			reached = true
			break
		if player.position.y > source.center.y + 180:
			break
	_release_input()
	if not _check(reached, "level %d rising gap unreachable: launch %.1f, target %.1f y%.1f, result %s" % [data.id,launch_x,target_left,target.center.y,player.position]):
		return false
	print("PASS: level %d real sprint jump %.0f -> %.0f onto y%.0f (injected approach setup)" % [data.id,launch_x,player.position.x,target.center.y])
	return true

func _run() -> void:
	# Prevent a failed threaded load or assertion from leaving CI running forever.
	create_timer(40, true).timeout.connect(func():
		if not failed:
			push_error("FAIL: campaign integration timed out")
			quit(1))
	scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.level_loaded.connect(_on_level_loaded)
	for index in range(1,7):
		var old_root: Node = scene.level_root
		var before: int = loaded_count
		if index == 1:
			scene.start_game()
		else:
			scene._choose_level(index)
		if not _check(scene.transitioning and paused and scene.hud.screens.back() == "loading", "level %d must enter loading state" % index):
			return
		await scene.level_loaded
		if not _check(loaded_count == before + 1 and last_loaded == index, "level %d must emit one completion signal" % index):
			return
		if not _check(not paused and not scene.transitioning and scene.started, "level %d must resume after loading" % index):
			return
		if not _check(not is_instance_valid(old_root), "level %d must free previous terrain/collision root" % index):
			return
		var data: Dictionary = scene.map
		if not _check(scene.player.map_width == data.width and scene.level == index, "level %d must set controller map bounds" % index):
			return
		await _ticks(20)
		if not _check(scene.player.is_on_floor() and absf(scene.player.position.y - data.spawn.y) < 1, "level %d player spawn must ground" % index):
			return
		var guards: Array[Node] = get_nodes_in_group("enemies")
		if not _check(guards.size() == data.enemies.size() and scene.remaining == guards.size(), "level %d must spawn its own encounter" % index):
			return
		for guard in guards:
			if not _check(guard.is_on_floor() or guard.enemy_kind == "wraith", "level %d walking enemies must ground; only wraiths may hover" % index):
				return
			guard.set_physics_process(false)
		if not await _check_camera(data):
			return
		if index == 1:
			if not await _first_route():
				return
		else:
			if not await _representative_rising_gap(data):
				return
		print("PASS: level %d load, player/guard grounding, encounter count and camera bounds" % index)
	print("PASS: all six campaign runtime loads and representative physical routes")
	_release_input()
	scene.queue_free()
	await process_frame
	await process_frame
	quit()
