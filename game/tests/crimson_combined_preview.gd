extends SceneTree
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.start_game()
	await scene.level_loaded
	for old in get_nodes_in_group("enemies"): old.queue_free()
	scene.player.position = Vector2(2010,550)
	scene.player.invulnerable = 100
	scene.remaining = 1
	scene._enemy_defeated()
	await create_timer(1.2).timeout
	var wraith = load("res://actors/enemy_2d.gd").new()
	wraith.enemy_kind = "wraith"
	wraith.position = Vector2(2200,500)
	wraith.target = scene.player
	scene.level_root.add_child(wraith)
	wraith.set_physics_process(false)
	wraith.rig.update_pose(0.0,"sword",-1,Vector2.ZERO,false,0.35)
	var magic = load("res://systems/combat_projectile.gd").new()
	magic.kind = "energy"
	magic.position = Vector2(2120,480)
	scene.level_root.add_child(magic)
	magic.set_physics_process(false)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://../docs/qa/crimson-combined.png")
	root.get_node("Audio").shutdown()
	print("PASS: combined generated scenery, wraith, magic and portal render")
	quit()
