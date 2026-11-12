extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	if not scene.transitioning:
		scene._choose_level(2)
	await scene.level_loaded
	var enemies: Array[Node] = get_nodes_in_group("enemies")
	for enemy in enemies:
		enemy.set_physics_process(false)
	var guard: Node = enemies[0]
	guard.position = scene.player.position + Vector2(85, 0)
	guard.health = 100
	for i in range(125):
		match i:
			5,8,16: Input.action_press("attack")
			6,9,17: Input.action_release("attack")
			45,56: Input.action_press("jump")
			50,61: Input.action_release("jump")
			88,94: Input.action_press("move_right")
			90,96: Input.action_release("move_right")
		if i in [27,58]:
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("/tmp/combo-%d.png" % i)
		await process_frame
	root.get_node("Audio").shutdown()
	await create_timer(0.15).timeout
	quit()
