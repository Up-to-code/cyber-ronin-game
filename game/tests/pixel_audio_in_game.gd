extends SceneTree
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.start_game()
	await scene.level_loaded
	scene.pause_game()
	scene.hud._push("settings")
	scene.hud._push("audio_settings")
	await create_timer(0.3,true).timeout
	var slider: HSlider = scene.hud.menu_box.get_child(2).get_node("VolumeSlider")
	slider.value = 0.65
	slider.grab_focus()
	await process_frame
	var before: float = slider.value
	var key := InputEventKey.new()
	key.keycode = KEY_RIGHT
	key.pressed = true
	root.push_input(key,true)
	await process_frame
	key.pressed = false
	root.push_input(key,true)
	await process_frame
	assert(slider.value>before,"Native slider keyboard input adjusts real volume")
	assert(is_equal_approx(scene.hud.master_volume,slider.value),"Presentation and real mixer preference agree")
	if DisplayServer.get_name() != "headless":
		await create_timer(0.2,true).timeout
		root.get_texture().get_image().save_png("/tmp/pixel-audio-in-game.png")
	print("PASS: integrated native slider input and displayed volume")
	root.get_node("Audio").shutdown()
	quit()
