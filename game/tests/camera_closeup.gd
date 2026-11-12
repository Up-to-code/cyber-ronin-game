extends SceneTree
func _initialize() -> void: call_deferred("_run")
func _ticks(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame
func _run() -> void:
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.start_game()
	await scene.level_loaded
	scene.player.invulnerable = 999
	await _ticks(30)
	assert(scene.camera.zoom.x >= 0.689 and scene.camera.zoom.x <= 0.72,"Cinematic zoom stays within the bounded contact push-in")
	var ground_y: float = scene.camera.position.y
	var previous: float = ground_y
	var highest: float = ground_y
	Input.action_press("jump")
	for frame in range(45):
		await _ticks(1)
		var current: float = scene.camera.position.y
		assert(absf(current-previous)<12.0,"Jump camera must ease without a vertical snap")
		highest = minf(highest,current)
		previous = current
	Input.action_release("jump")
	await _ticks(100)
	assert(highest < ground_y-1 and highest > ground_y-120,"Jump follow responds immediately within the configured jump height")
	assert(absf(scene.camera.position.y-ground_y)<2,"Camera settles back to the landing surface")
	root.get_node("Audio").shutdown()
	scene.queue_free()
	await _ticks(2)
	print("PASS: bounded cinematic zoom, bounded smooth jump follow, landing settle")
	quit()
