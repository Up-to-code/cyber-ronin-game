extends SceneTree
func _initialize() -> void:call_deferred("_run")
func _run() -> void:
	var scene: Node=load("res://scenes/main.tscn").instantiate();root.add_child(scene)
	await process_frame
	scene.start_game();await scene.level_loaded
	var player: Node=scene.player
	player.invulnerable=999
	for i in range(15):await physics_frame
	player._jump(false)
	for i in range(8):await physics_frame
	player._jump(true)
	var frames: Dictionary={}
	for i in range(20):
		await physics_frame
		await process_frame
		if player.rig.current_clip=="air_jump":frames[player.rig.current_frame]=true
	assert(frames.size()>=5,"Second impulse must show distinct airborne drawings")
	root.get_node("Audio").shutdown()
	print("PASS: second jump traverses dedicated airborne animation")
	quit()
