extends SceneTree
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.start_game()
	await scene.level_loaded
	await create_timer(0.3).timeout
	var bolt: Node2D = load("res://systems/combat_projectile.gd").new()
	bolt.kind = "energy"
	bolt.position = scene.player.position + Vector2(290,-75)
	scene.add_child(bolt)
	bolt.set_physics_process(false)
	assert(bolt.visual.sprite_frames.get_frame_count("default") == 9)
	assert(bolt.damage == 65 and bolt.speed == 1100 and bolt.life == 0.8)
	await create_timer(0.2).timeout
	assert(bolt.visual.frame > 0)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://../docs/qa/crimson-magic.png")
	root.get_node("Audio").shutdown()
	print("PASS: nine animated crimson cels; energy combat tuning preserved")
	quit()
