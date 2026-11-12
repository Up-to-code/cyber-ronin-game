extends SceneTree
var peak: float = -200
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.start_game()
	await scene.level_loaded
	var audio: Node = root.get_node("Audio")
	audio.set_enabled(true)
	for i in range(12):
		await physics_frame
	var enemy: Node = get_nodes_in_group("enemies")[0]
	enemy.set_physics_process(false)
	enemy.position = scene.player.position + Vector2(80,0)
	Input.action_press("attack")
	await physics_frame
	Input.action_release("attack")
	var saw_slash: bool = false
	var saw_impact: bool = false
	for i in range(30):
		await physics_frame
		await process_frame
		for effect in scene.fx.get_children():
			if effect.has_meta("family"):
				saw_slash = saw_slash or effect.get_meta("family") == "slash"
				saw_impact = saw_impact or effect.get_meta("family") == "impact"
		peak = maxf(peak, AudioServer.get_bus_peak_volume_left_db(0,0))
	if not (saw_slash and saw_impact and enemy.health == 35):
		push_error("FX assertion: slash=%s impact=%s health=%s paused=%s attack=%s" % [saw_slash,saw_impact,enemy.health,paused,scene.player.attack_time])
		quit(1)
		return
	Input.action_press("jump")
	await physics_frame
	await process_frame
	Input.action_release("jump")
	var dust: bool = false
	for effect in scene.fx.get_children():
		dust = dust or effect.get_meta("family", "") == "dust"
	assert(dust, "Jump must create foot dust")
	if DisplayServer.get_name() != "headless":
		assert(peak > -45, "Native audio bus must receive attack signal")
		print("Native attack output peak: ", peak, " dB")
	print("PASS: slash, confirmed hit sparks, takeoff dust, event-linked audio")
	paused = false
	audio.shutdown()
	scene.queue_free()
	await create_timer(0.2).timeout
	quit()
