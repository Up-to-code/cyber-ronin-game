extends SceneTree
func _initialize() -> void: call_deferred("_run")
func _settle() -> void:
	for i in range(5): await process_frame
func _run() -> void:
	var hud: CanvasLayer = load("res://ui/hud.gd").new()
	hud.settings_path = "user://menu-clean-test.cfg"
	root.add_child(hud)
	await _settle()
	for dimensions in [Vector2i(640,360),Vector2i(960,540),Vector2i(1600,720),Vector2i(1024,768)]:
		root.size = dimensions
		await _settle()
		hud.show_title()
		await _settle()
		assert(hud.safe.get_global_rect().encloses(hud.menu_scroll.get_global_rect()),"Start screen viewport stays in safe area")
		if hud.safe.size.x >= 566:
			assert(not hud.title_layout.vertical,"Wide start screen places actions to the side")
		for screen in ["settings","touch_settings","audio_settings","death"]:
			if screen == "death": hud.show_result(false)
			else:
				hud.screens.assign(["pause",screen])
				hud._render_menu()
			await _settle()
			assert(hud.safe.get_global_rect().encloses(hud.menu_scroll.get_global_rect()),"Menu viewport stays safe instead of overflowing")
			var buttons: Array = hud.menu_box.find_children("*","Button",true,false)
			for button in buttons:
				assert(button.size.y >= 38,"Menu rows keep readable heights, never compressed")
			for i in range(buttons.size()-1):
				assert(not buttons[i].get_global_rect().intersects(buttons[i+1].get_global_rect()),"Menu rows never overlap")
			if screen == "touch_settings":
				assert(hud.menu_box.size.y > hud.menu_scroll.size.y or hud.menu_box.size.y <= hud.safe.size.y,"Tall content can scroll instead of shrinking")
			for button in buttons:
				if button.has_meta("pixel_component"):
					var style: StyleBox = button.get_theme_stylebox("normal")
					assert(style is StyleBoxFlat and style.border_width_left == 0 and style.border_width_right == 0,"Switch rows have no ornamental outline")
	hud.max_unlocked = 3
	hud.show_title()
	await _settle()
	var requests: Array[String] = []
	hud.start_requested.connect(func():requests.append("new"))
	hud.level_selected.connect(func(index:int):requests.append("continue%d" % index))
	var actions: Control = hud.title_layout.get_node("StartActions")
	actions.get_child(0).pressed.emit()
	actions.get_node("StartNewGame").pressed.emit()
	assert(requests == ["continue3","new"],"Continue resumes the saved route; generated START begins a new game")
	root.content_scale_size = Vector2i(480,280)
	root.size = Vector2i(960,560)
	hud.show_title()
	await _settle()
	assert(hud.title_layout.vertical,"Narrow logical viewport uses vertical fallback")
	hud.screens.assign(["pause","touch_settings"])
	hud._render_menu()
	await _settle()
	assert(hud.safe.get_global_rect().encloses(hud.menu_scroll.get_global_rect()))
	hud.menu_box.get_node("TouchOptions").get_child(5).grab_focus()
	await _settle()
	assert(hud.menu_scroll.scroll_vertical > 0,"Keyboard focus scrolls tall content into view")
	root.content_scale_size = Vector2i(640,360)
	if DisplayServer.get_name() != "headless":
		root.size = Vector2i(1152,648)
		hud.show_title()
		await _settle()
		await create_timer(0.2).timeout
		root.get_texture().get_image().save_png("/tmp/menu-clean-title.png")
		hud._push("settings")
		await _settle()
		await create_timer(0.2).timeout
		root.get_texture().get_image().save_png("/tmp/menu-clean-settings.png")
		hud._push("touch_settings")
		await _settle()
		await create_timer(0.2).timeout
		root.get_texture().get_image().save_png("/tmp/menu-clean-touch.png")
		hud._back()
		hud._push("audio_settings")
		await _settle()
		await create_timer(0.2).timeout
		root.get_texture().get_image().save_png("/tmp/menu-clean-audio.png")
	print("PASS: safe scroll viewport, stable nonoverlapping menu rows, borderless switches, side start layout")
	hud.queue_free()
	root.get_node("Audio").shutdown()
	await create_timer(0.1).timeout
	quit()
