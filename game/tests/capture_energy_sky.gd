extends SceneTree
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	create_timer(24,true,false,true).timeout.connect(func():quit(1))
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	if not scene.transitioning: scene._choose_level(1)
	await scene.level_loaded
	scene.hud.touch_enabled = true
	scene.hud.touch.show()
	scene.player.invulnerable = 999
	var guard: Node = get_nodes_in_group("enemies")[0]
	guard.position = scene.player.position + Vector2(230,0)
	guard.health = 500
	for i in range(600):
		match i:
			30: Input.action_press("jump")
			40: Input.action_press("attack")
			41: Input.action_release("attack")
			48: Input.action_release("jump")
			100,230: Input.action_press("energy_attack")
			101,231: Input.action_release("energy_attack")
			155: Input.action_press("move_right")
			200: Input.action_release("move_right")
			300: Input.action_press("jump")
			310: Input.action_press("kick")
			311: Input.action_release("kick")
			320: Input.action_release("jump")
		if i in [50,115,240,400]: root.get_texture().get_image().save_png("/tmp/energy-sky-%d.png"%i)
		await physics_frame
		await process_frame
	root.get_node("Audio").shutdown()
	await create_timer(0.15).timeout
	quit()
