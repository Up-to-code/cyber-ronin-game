extends SceneTree
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene._choose_level(5)
	await scene.level_loaded
	var found := false
	for enemy in get_nodes_in_group("enemies"):
		if enemy.impostor:
			found = true
			assert(enemy.health == 170 and enemy.projectile_damage == 18)
			var before: int = scene.coins
			enemy.take_damage(999)
			assert(scene.coins == before+5)
	assert(found)
	root.get_node("Audio").shutdown()
	print("PASS: level 5 impostor stats and defeat coin reward")
	quit()
