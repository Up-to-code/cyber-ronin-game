extends SceneTree
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	if not scene.transitioning: scene._choose_level(1)
	await scene.level_loaded
	scene.hud.touch_enabled = true
	scene.hud.touch.show()
	for i in range(30): await process_frame
	root.get_texture().get_image().save_png("/tmp/responsive-controls.png")
	var controls: Control = scene.hud.touch
	var scale: float = root.get_screen_transform().get_scale().x
	print("Native viewport=%s screen scale=%s sword face=%s sword hit=%s" % [root.size,scale,controls.face_sizes[5].x*scale,controls.target_sizes[5].x*scale])
	root.get_node("Audio").shutdown()
	await create_timer(0.1).timeout
	quit()
