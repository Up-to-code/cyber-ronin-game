extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _snapshot(path: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(path)
func _run() -> void:
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await scene.level_loaded
	scene.main_menu()
	await process_frame
	await _snapshot("/tmp/castle-menu.png")
	scene.hud._push("maps")
	await process_frame
	await _snapshot("/tmp/castle-maps.png")
	scene._choose_level(4)
	await process_frame
	await _snapshot("/tmp/castle-loading.png")
	await scene.level_loaded
	for i in range(15):
		await process_frame
	await _snapshot("/tmp/castle-roof-final.png")
	scene._choose_level(3)
	await scene.level_loaded
	for i in range(15):
		await process_frame
	await _snapshot("/tmp/castle-bamboo.png")
	for enemy in get_nodes_in_group("enemies"):
		enemy.take_damage(1000)
	scene.player.position = scene.map.exit - Vector2(60,0)
	for i in range(15):
		await process_frame
	await _snapshot("/tmp/castle-gate-final.png")
	await scene.quit_game()
