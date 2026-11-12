extends SceneTree
func _initialize() -> void: call_deferred("_run")
func _ticks(count: int) -> void:
	for i in range(count):
		await physics_frame
		await process_frame
func _run() -> void:
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.start_game()
	await scene.level_loaded
	scene.player.invulnerable = 999
	var guard: Node = get_nodes_in_group("enemies")[0]
	guard.set_physics_process(false)
	guard.health = 500
	guard.position = scene.player.position + Vector2(70,0)
	await _ticks(8)
	for kind in ["attack","kick"]:
		var before: int = guard.health
		var saw_contact: bool = false
		Input.action_press(kind)
		await _ticks(1)
		Input.action_release(kind)
		var previous: Vector2 = scene.player.position
		for i in range(40):
			await _ticks(1)
			if guard.health < before and not saw_contact:
				saw_contact = true
				var spec: Dictionary = scene.player.current_attack_spec
				if scene.player.rig.current_frame != int(spec.contact_frame):
					push_error("Damage must occur on the displayed contact drawing")
					quit(1);return
			if scene.player.attack_time > 0 and scene.player.is_on_floor():
				assert(absf(scene.player.position.x - previous.x) < 0.1,"Ground strike support must stay planted")
		assert(saw_contact,"Action must contact a reachable target")
		assert(guard.health == before - (35 if kind=="attack" else 20),"Each action must hit once")
	scene._show_story(1,false)
	await process_frame
	assert(paused and scene.story_card.is_open() and not scene.hud.touch.visible,"Story owns pause and input")
	scene.story_card._continue()
	await _ticks(2)
	assert(not paused and not scene.story_card.is_open() and not Input.is_action_pressed("jump"),"Story dismissal restores clean gameplay input")
	print("PASS: actual displayed contact frame, once-per-action damage, grounded support and story input handoff")
	root.get_node("Audio").shutdown()
	scene.queue_free()
	await _ticks(2)
	quit()
