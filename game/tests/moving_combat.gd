extends SceneTree
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.start_game()
	await scene.level_loaded
	for e in get_nodes_in_group("enemies"): e.set_physics_process(false)
	for i in range(8): await physics_frame
	var p = scene.player
	var start: float = p.position.x
	Input.action_press("move_right")
	Input.action_press("energy_attack")
	for i in range(10): await physics_frame
	Input.action_release("energy_attack")
	assert(p.position.x > start+10 and p.attack_time > 0, "D+G must move during attack")
	assert(p.power < 100, "Magic must cost power")
	Input.action_release("move_right")
	Input.action_press("move_left")
	for i in range(15): await physics_frame
	assert(p.velocity.x < -50, "Can reverse during attack")
	Input.action_release("move_left")
	for i in range(40): await physics_frame
	var sword_start: float = p.position.x
	Input.action_press("move_right")
	Input.action_press("attack")
	for i in range(3): await physics_frame
	Input.action_release("attack")
	for i in range(10): await physics_frame
	assert(p.position.x > sword_start+15 and p.attack_time > 0, "D+J moves during sword attack")
	Input.action_release("move_right")
	var rules = load("res://systems/world_rules.gd")
	assert(rules.landing_damage(800)==0 and rules.landing_damage(900)==2 and rules.landing_damage(1200)==10)
	root.get_node("Audio").shutdown()
	print("PASS: D+G movement, reversal, power cost, capped fall damage")
	quit()
