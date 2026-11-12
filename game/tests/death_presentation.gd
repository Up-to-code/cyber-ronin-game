extends SceneTree
# Regression: the death beat must remove touch affordances immediately, show the
# result card after the visible death clip, and restore controls only on retry.
func _initialize() -> void: call_deferred("_run")
func _t(n: int = 1) -> void:
	for i in range(n):
		await physics_frame
		await process_frame
func _run() -> void:
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.hud.touch_enabled = true
	scene.start_game()
	await scene.level_loaded
	for enemy in get_nodes_in_group("enemies"):
		enemy.set_physics_process(false)
	await _t(4)
	var controls: Control = scene.hud.touch
	if not controls.visible:
		push_error("FAIL: touch controls must be visible during play")
		quit(1); return
	scene.player.invulnerable = 0
	scene.player.take_damage(100, 1)
	await _t(2)
	if controls.visible:
		push_error("FAIL: touch controls must leave the screen as soon as the ronin is defeated")
		quit(1); return
	if scene.player.rig.current_clip != "death":
		push_error("FAIL: visible death clip must own the defeat beat")
		quit(1); return
	var waited: int = 0
	while (scene.hud.screens.is_empty() or scene.hud.screens.back() != "death") and waited < 200:
		await _t(1)
		waited += 1
	if scene.hud.screens.is_empty() or scene.hud.screens.back() != "death" or not paused:
		push_error("FAIL: defeat card must appear after the death clip and pause gameplay")
		quit(1); return
	scene.retry_game()
	await scene.level_loaded
	await _t(4)
	if not controls.visible or not scene.player.is_on_floor() or scene.player.health != 100:
		push_error("FAIL: retry must restore touch controls and a living grounded ronin")
		quit(1); return
	if scene.player.plunging or scene.player.attack_time > 0 or scene.player.death_elapsed > 0:
		push_error("FAIL: retry must clear stale action and death state")
		quit(1); return
	print("PASS: defeat hides touch controls at the lethal hit, card waits for the death clip, retry restores play")
	root.get_node("Audio").shutdown()
	scene.queue_free()
	await _t(2)
	quit()
