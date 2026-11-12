extends SceneTree
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	var hud: CanvasLayer = load("res://ui/hud.gd").new()
	hud.settings_path = "user://pixel-components-test.cfg"
	root.add_child(hud)
	await process_frame
	assert(hud.root.theme.default_font is FontFile,"Menus keep the pixel font")
	hud._push("settings")
	var toggle: Button = hud.menu_box.get_child(2)
	assert(toggle.get_meta("pixel_component") == "toggle")
	var before: bool = hud.touch_enabled
	toggle.pressed.emit()
	await process_frame
	assert(hud.touch_enabled != before,"Image toggle changes actual preference")
	hud._push("audio_settings")
	var volume: HSlider = hud.menu_box.get_child(2).get_node("VolumeSlider")
	volume.value = 0.65
	await process_frame
	assert(is_equal_approx(hud.master_volume,0.65),"Slider applies continuous volume")
	assert(is_equal_approx(db_to_linear(AudioServer.get_bus_volume_db(0)),0.65),"Slider controls actual Master bus")
	var stored := ConfigFile.new()
	assert(stored.load(hud.settings_path) == OK)
	assert(is_equal_approx(stored.get_value("audio","volume"),0.65),"Slider value persists")
	for dimensions in [Vector2i(960,540),Vector2i(1024,768),Vector2i(1600,720)]:
		root.size = dimensions
		await process_frame
		await process_frame
		assert(hud.safe.get_global_rect().encloses(hud.menu_box.get_global_rect()),"Audio components fit safe bounds")
	if DisplayServer.get_name() != "headless":
		await create_timer(0.2).timeout
		root.get_texture().get_image().save_png("/tmp/pixel-audio-components.png")
		hud.handle_back()
		await create_timer(0.2).timeout
		root.get_texture().get_image().save_png("/tmp/pixel-settings-components.png")
		hud.show_result(false)
		await create_timer(0.3).timeout
		root.get_texture().get_image().save_png("/tmp/pixel-defeat-components.png")
	print("PASS: pixel theme, image toggles, functional persisted slider, navigation and safe bounds")
	DirAccess.remove_absolute(hud.settings_path)
	hud.queue_free()
	root.get_node("Audio").shutdown()
	await create_timer(0.1).timeout
	quit()
