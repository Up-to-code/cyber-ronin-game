extends SceneTree
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	create_timer(45,true,false,true).timeout.connect(func():quit(1))
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	if not scene.transitioning: scene._choose_level(3)
	await scene.level_loaded
	scene.hud.touch_enabled = true
	scene.hud.touch.show()
	scene.player.invulnerable = 999
	scene.player.position.x = 180
	var kinds_seen: Dictionary = {}
	var offset: float = 120
	for enemy in get_nodes_in_group("enemies"):
		if kinds_seen.has(enemy.enemy_kind): continue
		kinds_seen[enemy.enemy_kind] = true
		enemy.position = scene.player.position + Vector2(offset,-80 if enemy.enemy_kind=="wraith" else 0)
		if enemy.enemy_kind == "wraith": enemy.hover_origin = Vector2(enemy.position.x,scene.player.position.y)
		enemy.health = 500
		offset += 110
	for i in range(900):
		match i:
			40: Input.action_press("jump")
			50: Input.action_press("attack")
			51: Input.action_release("attack")
			60: Input.action_release("jump")
			160: Input.action_press("energy_attack")
			161: Input.action_release("energy_attack")
			240: Input.action_press("move_right")
			290: Input.action_release("move_right")
			350: Input.action_press("kick")
			351: Input.action_release("kick")
			470:
				scene.pause_game()
				scene.hud._push("settings")
			540: scene.hud._push("audio_settings")
			620:
				scene.hud.close_menu()
				paused = false
			700:
				scene.player.invulnerable = 0
				scene.player.take_damage(100,-1)
		if i in [30,90,180,400,500,580,790]: root.get_texture().get_image().save_png("/tmp/pixel-pass-%d.png"%i)
		await physics_frame
		await process_frame
	root.get_node("Audio").shutdown()
	await create_timer(0.15).timeout
	quit()
