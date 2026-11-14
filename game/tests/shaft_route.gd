extends SceneTree
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene._choose_level(7)
	await scene.level_loaded
	for enemy in get_nodes_in_group("enemies"): enemy.set_physics_process(false)
	var p = scene.player
	p.invulnerable = 100
	# Transition landings are covered by authored_routes.gd using route data.
	p.position=Vector2(1500,1510)
	p.velocity=Vector2.ZERO
	for i in range(60): await physics_frame
	assert(p.health>0 and scene.camera.position.y>1000 and p.map_bottom==1900)
	root.get_node("Audio").shutdown()
	print("PASS: deep shaft camera follow and lower exit survival")
	quit()
