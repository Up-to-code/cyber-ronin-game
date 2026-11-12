extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	assert(paused and not scene.started, "Game must open on title screen")
	scene.start_game()
	await scene.level_loaded
	assert(not paused, "Start must unpause gameplay")
	for i in range(10):
		await physics_frame
	assert(scene.remaining == 2, "First encounter needs two guards")
	assert(scene.player.is_on_floor(), "Player must stand on floor")
	var before: float = scene.player.position.x
	Input.action_press("move_right")
	for i in range(12):
		await physics_frame
	Input.action_release("move_right")
	assert(scene.player.position.x > before + 20, "Movement must advance player")
	Input.action_press("jump")
	await physics_frame
	await physics_frame
	Input.action_release("jump")
	assert(scene.player.velocity.y < 0, "Jump must lift player")
	for i in range(65):
		await physics_frame
	var enemy: Node = get_nodes_in_group("enemies")[0]
	enemy.position = scene.player.position + Vector2(80, 0)
	# The waiting frames let the guard walk in and start its own swing, and a
	# strike already in flight hits the teleported player first, cancelling the
	# sword. Clear only that in-flight AI action so this assertion measures the
	# player's damage instead of racing the guard's cooldown.
	enemy.windup = 0.0
	enemy.strike_left = 0.0
	enemy.cooldown = 1.2
	Input.action_press("attack")
	await physics_frame
	await physics_frame
	Input.action_release("attack")
	for i in range(30):
		await physics_frame
	assert(enemy.health == 35, "Attack should deal 35 damage once")
	enemy.take_damage(35)
	get_nodes_in_group("enemies")[0].take_damage(70)
	assert(scene.remaining == 0, "Clearing guards must unlock exit")
	scene.player.position.x = 2350
	Input.action_press("interact")
	await process_frame
	await process_frame
	Input.action_release("interact")
	await scene.level_loaded
	assert(scene.level == 2 and scene.remaining == 3, "Exit must start harder second encounter")
	scene.player.invulnerable = 0
	scene.player.take_damage(100)
	assert(scene.player.health == 0, "Lethal damage must defeat player")
	await create_timer(1.9).timeout
	assert(paused and scene.hud.screens.back() == "death", "Death must show retry menu")
	scene.retry_game()
	await scene.level_loaded
	assert(not paused and scene.player.health == 100, "Retry must restore health and input")
	scene.pause_game()
	assert(paused and scene.hud.screens.back() == "pause", "Pause must show menu")
	scene.resume_game()
	assert(not paused, "Resume must restore gameplay")
	assert(root.get_node("Audio").streams.size() >= 7, "Sound effects must load")
	print("PASS: movement, jump, attack, guard clear, exit transition, death")
	scene.queue_free()
	await process_frame
	await process_frame
	quit()
