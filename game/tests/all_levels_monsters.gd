extends SceneTree
func _initialize(): call_deferred("run")
func run():
	var scene=load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.start_game()
	await scene.level_loaded
	for level in range(1,101):
		scene._choose_level(level)
		await scene.level_loaded
		assert(is_instance_valid(scene.player), "level %d player" % level)
		# load each monster variant sanity
	for i in range(1,101):
		var m=load("res://actors/enemy_2d.gd").new()
		root.add_child(m)
		m.apply_monster_profile(i)
		assert(is_instance_valid(m.motion_visual), "monster %d renderer" % i)
		assert(m.motion_visual.frames.size() == 12, "monster %d pose coverage" % i)
		m.queue_free()
	print("PASS all 100 levels and 100 monsters smoke")
	root.get_node("Audio").shutdown()
	quit()