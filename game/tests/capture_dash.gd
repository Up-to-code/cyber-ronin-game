extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	if not scene.transitioning:
		scene._choose_level(2)
	await scene.level_loaded
	for enemy in get_nodes_in_group("enemies"):
		enemy.set_physics_process(false)
	get_nodes_in_group("enemies")[0].position = Vector2(650,550)
	for i in range(110):
		match i:
			6,28: Input.action_press("dodge")
			7,29: Input.action_release("dodge")
			25: Input.action_press("move_right"); Input.action_press("sprint")
			40: Input.action_release("move_right"); Input.action_release("sprint")
			45: Input.action_press("jump")
			51: Input.action_press("dodge")
			52: Input.action_release("dodge")
			67: Input.action_release("jump")
			82: Input.action_press("attack")
			83: Input.action_release("attack")
		if i == 10:
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("/tmp/dash-echo-frame.png")
		await process_frame
	root.get_node("Audio").shutdown()
	await create_timer(0.15).timeout
	quit()
