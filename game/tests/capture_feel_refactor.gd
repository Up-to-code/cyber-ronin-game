extends SceneTree
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	create_timer(18,true,false,true).timeout.connect(func():quit(1))
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	if not scene.transitioning:scene._choose_level(1)
	await scene.level_loaded
	scene.hud.touch_enabled = true
	scene.hud.touch.show()
	scene._show_story(1,false)
	for i in range(45):
		if i==20:root.get_texture().get_image().save_png("/tmp/feel-story.png")
		await process_frame
	scene.story_card._continue()
	await process_frame
	await process_frame
	scene.player.invulnerable = 999
	var guard: Node = get_nodes_in_group("enemies")[0]
	guard.position=scene.player.position+Vector2(76,0)
	guard.health=500
	scene.fx.show()
	for i in range(200):
		match i:
			15,145:Input.action_press("attack")
			16,146:Input.action_release("attack")
			45:Input.action_press("kick")
			46:Input.action_release("kick")
			75:Input.action_press("move_right")
			90:Input.action_release("move_right")
			110:Input.action_press("jump")
			120:Input.action_release("jump")
		if i in [20,50,83]:root.get_texture().get_image().save_png("/tmp/feel-action-%d.png"%i)
		await process_frame
	root.get_node("Audio").shutdown()
	await create_timer(0.15).timeout
	quit()
