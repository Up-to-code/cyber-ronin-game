extends SceneTree
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	create_timer(40,true,false,true).timeout.connect(func():quit(1))
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP,true)
	root.grab_focus()
	if not scene.transitioning:scene._choose_level(1)
	await scene.level_loaded
	scene.main_menu()
	for i in range(900):
		match i:
			90: scene.hud._push("settings")
			160: scene.hud._push("touch_settings")
			240:
				scene._choose_level(1)
				await scene.level_loaded
				assert(not paused,"Route entry must not force the chapter modal")
				scene.hud.touch_enabled = true
				scene.hud.touch.show()
				scene.player.invulnerable=999
				for enemy in get_nodes_in_group("enemies"):
					if enemy.enemy_kind=="guard":
						enemy.position=scene.player.position+Vector2(68,0)
						enemy.health=500
						break

			310:Input.action_press("kick")
			311:Input.action_release("kick")
			390:Input.action_press("jump")
			400:Input.action_press("attack")
			401:Input.action_release("attack")
			418:Input.action_release("jump")
			480:Input.action_press("energy_attack")
			481:Input.action_release("energy_attack")
			600:
				scene.pause_game()
				scene.hud._push("audio_settings")
			690:
				scene.hud.close_menu()
				paused=false
			750:scene.main_menu()
		if i in [30,120,200,290,325,410,495,640,800]:root.get_texture().get_image().save_png("/tmp/scenery-recoil-%d.png"%i)
		await physics_frame
		await process_frame
	root.get_node("Audio").shutdown()
	await create_timer(0.15).timeout
	quit()
