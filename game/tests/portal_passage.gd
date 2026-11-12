extends SceneTree
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.start_game()
	await scene.level_loaded
	scene.player.set_physics_process(false)
	scene.player.position = scene.map.exit
	await create_timer(0.6).timeout
	assert(scene.level == 1 and scene.gate_entry_time == 0, "Locked gate must not transport")
	scene.remaining = 1
	scene._enemy_defeated()
	scene.player.position.x -= 100
	await create_timer(0.9).timeout
	scene.player.position = scene.map.exit
	await create_timer(0.2).timeout
	assert(scene.gate_entry_time > 0 and scene.gate_entry_time < 0.45)
	scene.player.position.x -= 100
	await process_frame
	await process_frame
	assert(scene.gate_entry_time == 0, "Leaving must cancel passage charge")
	scene.player.position = scene.map.exit
	await scene.level_loaded
	assert(scene.level == 2 and scene.gate_entry_time == 0)
	root.get_node("Audio").shutdown()
	print("PASS: locked gate, cancellation, and walking through open portal to level 2")
	quit()
