extends SceneTree
func _initialize() -> void: call_deferred("_run")
func _ticks(count: int) -> void:
	for i in range(count):
		await physics_frame
		await process_frame
func _run() -> void:
	var world := Node2D.new()
	root.add_child(world)
	var floor_body := StaticBody2D.new()
	var collider := CollisionShape2D.new()
	var floor_shape := RectangleShape2D.new()
	floor_shape.size = Vector2(2400,80)
	collider.shape = floor_shape
	floor_body.position = Vector2(1000,650)
	floor_body.add_child(collider)
	world.add_child(floor_body)
	var actors: Array[CharacterBody2D] = []
	for i in range(3):
		var actor: CharacterBody2D = load("res://actors/enemy_2d.gd").new()
		actor.enemy_kind = ["guard","fire","wraith"][i]
		actor.position = Vector2(300+i*500,610)
		world.add_child(actor)
		actors.append(actor)
	await _ticks(20)
	for actor in actors:
		assert(actor.rig is CelActorVisual, "All enemy types must use whole-character pixel cels")
		assert(not actor.sprite.visible, "Legacy source sprite must remain hidden")
		assert(actor.rig.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST)
		assert(actor.rig.profile.atlas == "res://art/pixel/enemies-redraw.png")
		actor.set_physics_process(false)
		actor.windup = 0
		actor.hurt_left = 0
		actor.strike_duration = 0.32
		actor.strike_left = 0.16
		actor._update_rig(0)
		assert(actor.rig.current_clip == "attack", "A floating monster's attack must not be overridden by idle hover")
		actor.strike_left = 0
		actor.hurt_left = 0.3
		actor.hit_reaction = 0.7
		actor._update_rig(0)
		assert(actor.rig.current_clip == "hurt", "Each monster owns its own drawn hurt silhouette")
	assert(actors[0].is_on_floor() and actors[1].is_on_floor(), "Ground enemy collision remains grounded")
	assert(not actors[2].is_on_floor() and actors[2].position.y < 570, "Wraith hovering remains physical motion above floor")
	print("PASS: all three pixel-cel enemy types, nearest filtering, own attack/hurt drawings and preserved ground/hover rules")
	root.get_node("Audio").shutdown()
	world.queue_free()
	await _ticks(2)
	quit()
