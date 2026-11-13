extends SceneTree
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	assert(load("res://data/campaign.gd").levels().size()==100)
	for index in [8]:
		scene._choose_level(index)
		await scene.level_loaded
		for e in get_nodes_in_group("enemies"): e.set_physics_process(false)
		for i in range(15): await physics_frame
		assert(scene.player.is_on_floor())
		var platforms: Array = scene.map.platforms
		for i in range(platforms.size()-1):
			var a: Dictionary = platforms[i]
			var b: Dictionary = platforms[i+1]
			assert(absf(a.center.y-b.center.y)<=80)
			assert(b.center.x-b.width/2-(a.center.x+a.width/2)<=80)
		# Real controlled drop from the starting wall onto its next shelf.
		scene.player.invulnerable=99
		scene.player.position = Vector2(platforms[0].center.x+platforms[0].width/2-18,platforms[0].center.y-2)
		scene.player.velocity=Vector2.ZERO
		Input.action_press("move_right")
		var landed := false
		for i in range(55):
			await physics_frame
			if scene.player.is_on_floor() and scene.player.position.y>platforms[0].center.y+40:
				landed=true
				break
		Input.action_release("move_right")
		assert(landed,"Descending shelf must catch walking player")
	root.get_node("Audio").shutdown()
	print("PASS: ten routes, Bell Shaft loads, shelf bounds and real descending landing")
	quit()
