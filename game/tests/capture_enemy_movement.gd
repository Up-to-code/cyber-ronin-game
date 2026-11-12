extends SceneTree
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	var world := Node2D.new()
	root.add_child(world)
	var bg := ColorRect.new()
	bg.color = Color("25141e")
	bg.size = Vector2(1200,700)
	world.add_child(bg)
	var actors: Array[CelActorVisual] = []
	for i in range(3):
		var a := CelActorVisual.new()
		world.add_child(a)
		a.configure(["guard_pixel","fire_pixel","wraith_pixel"][i])
		a.position = Vector2(70+i*170,260)
		actors.append(a)
	for tick in range(180):
		for i in range(3):
			actors[i].update_pose(1.0/60,"walk" if i<2 else "float",1,Vector2(84,0),i<2)
			if i<2: actors[i].position.x += 84.0/60
		if tick in [20,60,100]: root.get_texture().get_image().save_png("/tmp/enemy-movement-native-%d.png"%tick)
		await physics_frame
		await process_frame
	root.get_node("Audio").shutdown()
	await create_timer(0.15).timeout
	quit()
