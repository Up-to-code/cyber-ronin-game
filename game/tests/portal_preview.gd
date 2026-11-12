extends SceneTree
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.start_game()
	await scene.level_loaded
	scene.player.position = scene.shrine.position + Vector2(-140,0)
	scene.remaining = 1
	scene._enemy_defeated()
	await create_timer(1.5).timeout
	var field = scene.shrine.get_node("GateField")
	assert(field.z_index < 0 and field.show_behind_parent)
	assert(field.age >= 0.8 and scene.gate_open)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://../docs/qa/portal-shadow.png")
	root.get_node("Audio").shutdown()
	print("PASS: shadow portal opens behind gate")
	quit()
