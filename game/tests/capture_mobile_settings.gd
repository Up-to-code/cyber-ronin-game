extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _snapshot(path: String) -> void:
	for i in range(4):
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(path)
func _run() -> void:
	create_timer(20,true,false,true).timeout.connect(func():quit(1))
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	if not scene.transitioning:
		scene._choose_level(1)
	await scene.level_loaded
	for i in range(10):
		await process_frame
	if scene.story_card.is_open():
		scene.story_card._continue()
	scene.hud.touch_enabled = true
	scene.hud.touch.apply_preferences(1.0, false, 1.0, true)
	scene.hud.touch.show()
	scene.player.invulnerable = 999
	await _snapshot("/tmp/mobile-central-sword.png")
	scene.pause_game()
	scene.hud._push("settings")
	await _snapshot("/tmp/mobile-settings.png")
	scene.hud._push("touch_settings")
	await _snapshot("/tmp/mobile-customization.png")
	scene.hud._back()
	scene.hud._push("privacy")
	await _snapshot("/tmp/mobile-privacy.png")
	root.get_node("Audio").shutdown()
	quit()
