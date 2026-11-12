extends SceneTree
func _initialize() -> void:call_deferred("_run")
func _run() -> void:
	var scene: Node=load("res://scenes/main.tscn").instantiate();root.add_child(scene)
	await process_frame
	scene.start_game();await scene.level_loaded
	scene.player.invulnerable=999
	for enemy in get_nodes_in_group("enemies"):enemy.set_physics_process(false)
	for i in range(420):
		await physics_frame
		await process_frame
		if i==240:root.get_texture().get_image().save_png("/tmp/idle-flourish.png")
	root.get_node("Audio").shutdown();quit()
