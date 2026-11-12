extends SceneTree
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	if not scene.transitioning: scene._choose_level(2)
	await scene.level_loaded
	scene.hud.touch_enabled = true
	scene.hud.touch.show()
	for enemy in get_nodes_in_group("enemies"):
		enemy.set_physics_process(false)
	var guard: Node = get_nodes_in_group("enemies")[0]
	guard.position = scene.player.position + Vector2(80, 0)
	guard.health = 1000
	for i in range(235):
		match i:
			5: Input.action_press("kick")
			6: Input.action_release("kick")
			20,23,33,90,175: Input.action_press("attack")
			21,24,34,130,176: Input.action_release("attack")
			60: Input.action_press("power_attack")
			61: Input.action_release("power_attack")
			155,166: Input.action_press("jump")
			160,171: Input.action_release("jump")
		if i in [8,34,64,128,181]:
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("/tmp/power-%d.png" % i)
		await process_frame
	root.get_node("Audio").shutdown()
	await create_timer(0.15).timeout
	quit()
