extends SceneTree
func _initialize() -> void:call_deferred("_run")
func _run() -> void:
	var scene: Node=load("res://scenes/main.tscn").instantiate();root.add_child(scene)
	await process_frame
	scene.start_game();await scene.level_loaded
	scene.remaining=1
	scene._enemy_defeated()
	assert(not scene.gate_open and scene.shrine.frame==0)
	await create_timer(1.0).timeout
	assert(scene.gate_open and scene.shrine.frame==3)
	root.get_node("Audio").shutdown()
	print("PASS: gate animates closed to open before enabling exit")
	quit()
