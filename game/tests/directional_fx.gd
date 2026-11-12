extends SceneTree
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.start_game()
	await scene.level_loaded
	var p = scene.player
	p.set_physics_process(false)
	Input.action_press("move_up")
	assert(p.read_attack_aim().is_equal_approx(Vector2.UP))
	Input.action_press("move_right")
	assert(p.read_attack_aim().is_equal_approx(Vector2(1,-1).normalized()))
	Input.action_release("move_right")
	Input.action_release("move_up")
	p.attack_aim = Vector2.UP
	scene._player_fx("slash",p.position+Vector2(0,-94),1)
	var effect = scene.fx.get_children().back()
	assert(is_equal_approx(effect.rotation,-PI/2))
	var before: Vector2 = effect.global_position
	p.position += Vector2(30,-20)
	scene.fx._process(0)
	assert(effect.global_position.is_equal_approx(before+Vector2(30,-20)))
	root.get_node("Audio").shutdown()
	print("PASS: vertical/diagonal aim and slash follows actor movement")
	quit()
