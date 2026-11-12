extends SceneTree
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	create_timer(35,true,false,true).timeout.connect(func():quit(1))
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	if not scene.transitioning: scene._choose_level(1)
	await scene.level_loaded
	scene.main_menu()
	for i in range(600):
		match i:
			90: scene.hud._push("settings")
			160: scene.hud._push("touch_settings")
			240:
				scene.start_game()
				await scene.level_loaded
				scene.player.invulnerable = 999
			300: Input.action_press("move_right")
			350: Input.action_release("move_right")
			390: Input.action_press("jump")
			415: Input.action_release("jump")
			480:
				scene.pause_game()
				scene.hud._push("audio_settings")
		if i in [30,120,200,375,530]: root.get_texture().get_image().save_png("/tmp/menu-clean-%d.png"%i)
		await physics_frame
		await process_frame
	root.get_node("Audio").shutdown()
	await create_timer(0.15).timeout
	quit()
