extends SceneTree
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	for index in range(1,11):
		scene._choose_level(index)
		await scene.level_loaded
		assert(scene.level==index and scene.remaining==scene.map.enemies.size())
		var bosses := 0
		for enemy in get_nodes_in_group("enemies"):
			if enemy.is_boss:
				bosses+=1
				assert(enemy.health==340)
			enemy.set_physics_process(false)
		assert(bosses==(1 if index%10==0 else 0))
		for i in range(12): await physics_frame
		assert(scene.player.is_on_floor(),"Spawn must settle on route floor")
		scene.player.invulnerable=0
		scene.camera_trauma=0
		scene.player.take_damage(10,1)
		assert(scene.camera_trauma>0 and scene.camera_trauma<=0.55)
	print("PASS: ten runtime routes, grounded spawns, boss at 10, bounded player-hit shake")
	root.get_node("Audio").shutdown()
	quit()
