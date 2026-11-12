extends SceneTree
func _initialize() -> void: call_deferred("_run")
func _tick() -> void:
	await physics_frame
	await process_frame
func _run() -> void:
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.start_game()
	await scene.level_loaded
	var player: Node = scene.player
	player.invulnerable = 999
	for i in range(10): await _tick()
	var poses: Dictionary = {}
	Input.action_press("jump")
	for i in range(60):
		await _tick()
		var state: String = player.rig.current_state
		if not poses.has(state): poses[state] = {}
		poses[state][player.rig.current_frame] = true
	Input.action_release("jump")
	for state in ["takeoff", "jump", "apex", "fall", "land"]:
		if not poses.has(state) or poses[state].size() < 2:
			push_error("Aerial phase must show sequential drawings: " + state + str(poses))
			quit(1); return
	if not player.is_on_floor():
		push_error("Full jump must return to ground"); quit(1); return
	# A landed plunge must recover through the landing pose, never reappear as the dive.
	for i in range(10):
		if not player.is_on_floor(): break
		await _tick()
	Input.action_press("jump")
	await _tick()
	Input.action_release("jump")
	for i in range(12):
		if not player.is_on_floor(): break
		await _tick()
	Input.action_press("move_down")
	await _tick()
	Input.action_press("attack")
	await _tick()
	Input.action_release("attack")
	var saw_air_plunge: bool = player.plunging and player.rig.current_clip == "plunge"
	var post_land_dive: bool = false
	for i in range(90):
		await _tick()
		if player.is_on_floor() and not player.plunging and player.attack_time > 0 and player.rig.current_clip == "plunge":
			post_land_dive = true
		if player.is_on_floor() and player.attack_time <= 0:
			break
	Input.action_release("move_down")
	if not saw_air_plunge or post_land_dive:
		push_error("Plunge must dive, then land without snapping back to the dive pose")
		quit(1); return
	print("PASS: held jump displays multiple takeoff, rise, apex, fall and landing drawings and returns to ground")
	root.get_node("Audio").shutdown()
	scene.queue_free()
	await _tick()
	quit()
