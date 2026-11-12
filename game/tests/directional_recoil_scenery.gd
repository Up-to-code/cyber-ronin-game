extends SceneTree
func _initialize() -> void:call_deferred("_run")
func _ticks(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame
func _run() -> void:
	var scene: Node=load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.start_game()
	await scene.level_loaded
	await _ticks(8)
	assert(get_nodes_in_group("scenery").size()>0,"Route has decorative scenery")
	for prop in get_nodes_in_group("scenery"):
		assert(prop.get_meta("decorative",false) and prop.z_index<scene.player.z_index)
		assert(prop.find_children("*","CollisionObject2D").is_empty(),"Background props cannot block attacks or movement")
	var player: CharacterBody2D=scene.player
	for direction in [-1.0,1.0]:
		player.position=Vector2(380,550)
		player.health=100
		player.invulnerable=0
		player.velocity=Vector2.ZERO
		player.facing=1
		player.take_damage(10,direction)
		assert(player.velocity.x*direction>0,"Player push follows incoming hit rather than facing")
		var before: float=player.position.x
		await _ticks(5)
		assert((player.position.x-before)*direction>2,"Player visibly recoils away from either side")
	var enemy: CharacterBody2D=get_nodes_in_group("enemies")[0]
	enemy.target=null
	var reactions: Array[float]=[]
	enemy.fx_requested.connect(func(kind:String,_at:Vector2,direction:float):
		if kind in ["impact","finisher_hit"]:reactions.append(direction))
	for direction in [-1.0,1.0]:
		enemy.position=Vector2(670,550)
		enemy.velocity=Vector2.ZERO
		enemy.health=500
		enemy.facing=1
		enemy.receive_hit(20,"kick",direction,enemy.position+Vector2(-direction*30,-45))
		assert(enemy.velocity.x*direction>0 and reactions.back()==direction,"Enemy movement and contact VFX share incoming direction")
		var before: float=enemy.position.x
		await _ticks(5)
		assert((enemy.position.x-before)*direction>4,"Enemy recoils physically from both sides")
	scene.pause_game()
	scene.hud._click_feedback(Rect2(20,20,100,44))
	assert(scene.hud.root.get_node("ClickFeedback").mouse_filter==Control.MOUSE_FILTER_IGNORE)
	await create_timer(0.3,true,false,true).timeout
	assert(scene.hud.root.find_children("ClickFeedback","ColorRect").is_empty(),"Click feedback expires while paused")
	assert(scene.hud.menu_scroll.get_v_scroll_bar().custom_minimum_size.x==10)
	paused=false
	root.get_node("Audio").shutdown()
	scene.queue_free()
	await _ticks(2)
	print("PASS: decorative scenery, two-sided player/enemy recoil, aligned impacts and transient paused-menu click feedback")
	quit()
