extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _finger(index: int, position: Vector2, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.position = position
	event.pressed = pressed
	root.push_input(event, true)
func _run() -> void:
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame
	scene.hud.touch_enabled = true
	scene.start_game()
	await scene.level_loaded
	await process_frame
	await process_frame
	var controls: Control = scene.hud.touch
	assert(controls.actions == ["move_left", "move_right", "jump", "move_down", "kick", "attack", "power_attack", "ranged_attack", "energy_attack"], "Directional cross and five combat actions must remain available")
	controls.apply_preferences(1.0, false, 1.0, true)
	await process_frame
	await process_frame
	var right: Vector2 = controls.buttons[1].get_global_transform_with_canvas().origin
	var attack: Vector2 = controls.buttons[5].get_global_transform_with_canvas().origin
	var power: Vector2 = controls.buttons[6].get_global_transform_with_canvas().origin
	_finger(0, right, true)
	_finger(1, attack, true)
	_finger(2, power, true)
	await process_frame
	assert(Input.is_action_pressed("move_right") and Input.is_action_pressed("attack") and Input.is_action_pressed("power_attack"), "Movement and two actions must accept independent fingers")
	scene.player.charging = true
	scene.player.charge_time = 0.45
	scene.pause_game()
	assert(not scene.player.charging and scene.player.attack_hold == 0, "Pause must cancel a stored charge before releasing touch input")
	for action in controls.actions:
		assert(not Input.is_action_pressed(action), "Pause must release every touch action")
	_finger(0, right, false)
	_finger(1, attack, false)
	_finger(2, power, false)
	scene.hud._push("settings")
	assert(scene.hud.screens.back() == "settings", "Settings must open above pause")
	scene.hud.handle_back()
	assert(scene.hud.screens.back() == "pause", "Back must return to pause")
	scene.resume_game()
	scene.hud.set_power(25, 100)
	scene.hud.set_charge(0.7)
	assert(scene.hud.power_bar.value == 25 and scene.hud.health_bar != scene.hud.power_bar, "Power and health must remain separate meters")
	assert(controls.power == 25 and controls.charge > 0.69, "Power dimming and held-charge meter must receive state")
	for slot in controls.slots:
		assert(slot.find_children("*", "Label").is_empty(), "Action controls must remain icon-only")
		assert(slot.has_meta("accessible_action_name") and slot.tooltip_text.is_empty(), "Icons retain action metadata without hover popups")
	for dimensions in [Vector2i(1280,720), Vector2i(1600,720), Vector2i(960,540), Vector2i(1920,1080), Vector2i(1024,768),Vector2i(2532,1170),Vector2i(2266,1488)]:
		root.size = dimensions
		for frame in range(4): await process_frame
		var safe_rect: Rect2 = scene.hud.safe.get_global_rect()
		for button in controls.buttons:
			var point: Vector2 = button.get_global_transform_with_canvas().origin
			assert(safe_rect.has_point(point), "Touch control must remain in safe content")
		for i in range(controls.buttons.size()):
			var visual_center: Vector2 = controls.get_global_transform_with_canvas() * controls.centers[i]
			var input_center: Vector2 = controls.buttons[i].get_global_transform_with_canvas().origin
			assert(visual_center.distance_to(input_center) < 0.5, "Drawn icon must align with its touch target after container layout")
		var output_scale: float = root.get_screen_transform().get_scale().x
		print("Layout %s: sword hit %.1f px, sword face %.1f px, skill hit %.1f px" % [dimensions, controls.target_sizes[5].x*output_scale, controls.face_sizes[5].x*output_scale, controls.target_sizes[4].x*output_scale])
		assert((controls.target_sizes[5].x-controls.face_sizes[5].x)*output_scale >= 12.0, "Visible artwork leaves touch padding")
		var points: Array[Vector2] = []
		for button in controls.buttons:
			points.append(button.get_global_transform_with_canvas().origin)
		assert(is_equal_approx(points[0].y,points[1].y) and is_equal_approx(points[2].x,points[3].x), "Direction pad must have aligned left/right and up/down axes")
		assert(points[2].y < points[0].y and points[3].y > points[0].y and points[0].x < points[2].x and points[1].x > points[2].x, "Jump belongs at the top of the left cross")
		assert(points[4].x < points[5].x and points[6].y < points[5].y  and points[7].y < points[5].y and points[8].x > points[5].x, "Powers sit above and beside the primary sword in a floating cluster")
		assert(controls.target_sizes[5].x > controls.target_sizes[4].x, "Main sword target must be wider than the skill squares")
		for i in range(points.size()):
			var bounds := Rect2(points[i]-controls.target_sizes[i]*0.5,controls.target_sizes[i])
			assert(safe_rect.encloses(bounds), "Entire target must be inside the safe area")
			for j in range(i+1,points.size()):
				assert(not bounds.intersects(Rect2(points[j]-controls.target_sizes[j]*0.5,controls.target_sizes[j])), "Touch targets must not overlap")
	# Both supported sizes and handed layouts must retain distinct safe targets.
	for mirrored in [false, true]:
		for scale_value in [0.8, 1.0, 1.15]:
			controls.apply_preferences(scale_value, mirrored, 0.6, false)
			await process_frame
			await process_frame
			var safe_rect: Rect2 = scene.hud.safe.get_global_rect()
			for i in range(controls.buttons.size()):
				var point: Vector2 = controls.buttons[i].get_global_transform_with_canvas().origin
				var bounds := Rect2(point-controls.target_sizes[i]*0.5, controls.target_sizes[i])
				assert(safe_rect.encloses(bounds), "Large and mirrored targets stay in safe area")
				for j in range(i+1,controls.buttons.size()):
					var other: Vector2 = controls.buttons[j].get_global_transform_with_canvas().origin
					assert(not bounds.intersects(Rect2(other-controls.target_sizes[j]*0.5, controls.target_sizes[j])), "Customized touch targets never overlap")
	scene.pause_game()
	scene.hud._push("settings")
	scene.hud._push("touch_settings")
	assert(scene.hud.menu_box.get_node("TouchOptions").get_child_count() == 6, "Customization exposes six controls including Back in the responsive grid")
	scene.hud.handle_back()
	scene.hud._push("privacy")
	assert(scene.hud.screens.back() == "privacy", "Privacy must be reachable from settings")
	assert(scene.hud._policy_url("privacy_policy_url").is_empty(), "Unconfigured policy must not invent an external URL")
	scene.hud.privacy.set_value("links", "privacy_policy_url", "javascript:alert(1)")
	assert(scene.hud._policy_url("privacy_policy_url").is_empty(), "Non-HTTPS policy URLs must be rejected")
	scene.hud.handle_back()
	assert(scene.hud.screens.back() == "settings", "Privacy back returns to settings")
	# Round-trip through the actual HUD save/load path in a disposable file.
	var saved_hud: CanvasLayer = load("res://ui/hud.gd").new()
	saved_hud.settings_path = "user://mobile_settings_test.cfg"
	root.add_child(saved_hud)
	saved_hud.control_scale = 1.15
	saved_hud.left_handed = true
	saved_hud.control_opacity = 0.6
	saved_hud.vibration_enabled = false
	saved_hud.master_volume = 0.5
	saved_hud._save_settings()
	assert(saved_hud.save_error == OK)
	saved_hud.queue_free()
	await process_frame
	var loaded_hud: CanvasLayer = load("res://ui/hud.gd").new()
	loaded_hud.settings_path = "user://mobile_settings_test.cfg"
	root.add_child(loaded_hud)
	assert(loaded_hud.left_handed and is_equal_approx(loaded_hud.control_scale, 1.15) and not loaded_hud.vibration_enabled)
	assert(is_equal_approx(loaded_hud.touch.modulate.a, 0.6) and is_equal_approx(loaded_hud.master_volume, 0.5))
	loaded_hud.queue_free()
	await process_frame
	AudioServer.set_bus_volume_db(0, linear_to_db(scene.hud.master_volume))
	DirAccess.remove_absolute("user://mobile_settings_test.cfg")
	var audio: Node = root.get_node("Audio")
	audio.set_enabled(false)
	assert(not audio.enabled, "Mute must disable audio")
	audio.set_enabled(true)
	assert(audio.enabled, "Unmute must enable audio")
	print("PASS: left directional cross, central sword with surrounding skills and energy slash, separate meters, independent touches/pause release, nonoverlapping safe-area targets, saved customization, privacy routes, menu back and mute")
	scene.queue_free()
	await process_frame
	await process_frame
	quit()
