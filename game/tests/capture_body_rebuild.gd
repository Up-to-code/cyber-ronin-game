extends SceneTree
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	create_timer(25, true, false, true).timeout.connect(func(): quit(1))
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	if not scene.transitioning: scene._choose_level(2)
	await scene.level_loaded
	scene.hud.touch_enabled = true
	scene.hud.touch.show()
	scene.player.invulnerable = 999
	var guards: Array[Node] = get_nodes_in_group("enemies")
	var guard: Node = guards[0]
	guard.position = scene.player.position + Vector2(72,0)
	guard.health = 500
	for i in range(205):
		match i:
			5: Input.action_press("kick")
			6: Input.action_release("kick")
			33: Input.action_press("power_attack")
			34: Input.action_release("power_attack")
			62: Input.action_press("move_right")
			77: Input.action_release("move_right")
			90: Input.action_press("jump")
			95: Input.action_release("jump")
			100: Input.action_press("jump")
			105: Input.action_release("jump")
			126: Input.action_press("ranged_attack")
			127: Input.action_release("ranged_attack")
			158: Input.action_press("attack")
			159: Input.action_release("attack")
		if i in [12,42,70,103,130]:
			root.get_texture().get_image().save_png("/tmp/body-rebuild-%d.png" % i)
		await process_frame
	scene._choose_level(3)
	await scene.level_loaded
	scene.player.invulnerable = 999
	scene.player.position = Vector2(780,490)
	for i in range(95):
		if i == 35: Input.action_press("ranged_attack")
		if i == 36: Input.action_release("ranged_attack")
		if i == 30:
			root.get_texture().get_image().save_png("/tmp/fire-caster.png")
		await process_frame
	scene.player.position = Vector2(2550,530)
	scene.player.velocity = Vector2.ZERO
	scene.hud.touch.hide()
	for i in range(100):
		if i == 35: Input.action_press("jump")
		if i == 45: Input.action_release("jump")
		if i == 42: Input.action_press("ranged_attack")
		if i == 43: Input.action_release("ranged_attack")
		if i == 20:
			root.get_texture().get_image().save_png("/tmp/floating-wraith.png")
		await process_frame
	root.get_node("Audio").shutdown()
	await create_timer(0.15).timeout
	quit()
