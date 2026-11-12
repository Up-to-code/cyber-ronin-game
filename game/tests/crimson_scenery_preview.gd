extends SceneTree
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.start_game()
	await scene.level_loaded
	for old in get_nodes_in_group("scenery"): old.queue_free()
	for i in range(6):
		var prop = load("res://systems/scenery_prop.gd").new()
		prop.variant = i
		prop.position = Vector2(150+i*130,550)
		prop.scale = Vector2(1.5,1.5)
		scene.level_root.add_child(prop)
		assert(prop.z_index < 0 and prop.get_meta("decorative"))
	await create_timer(0.4).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://../docs/qa/crimson-scenery.png")
	root.get_node("Audio").shutdown()
	print("PASS: six scenery variants render behind actors")
	quit()
