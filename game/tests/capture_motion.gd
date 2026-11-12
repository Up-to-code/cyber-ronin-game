extends SceneTree
# Scripted presentation sequence, not a complete playthrough. Guards are frozen
# to isolate walk/run/jump and damage contact in the courtyard.
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	if not scene.transitioning:
		scene._choose_level(2)
	await scene.level_loaded
	for guard in get_nodes_in_group("enemies"):
		guard.set_physics_process(false)
	get_nodes_in_group("enemies")[0].position = Vector2(650,550)
	for i in range(170):
		match i:
			6: Input.action_press("move_right")
			25: Input.action_press("sprint")
			34: Input.action_press("jump")
			45: Input.action_release("move_right"); Input.action_release("sprint")
			55: Input.action_release("jump")
			60: Input.action_press("attack")
			61: Input.action_release("attack")
			80: Input.action_press("attack")
			81: Input.action_release("attack")
			100: Input.action_press("move_right"); Input.action_press("sprint")
			112: Input.action_press("jump")
			136: Input.action_release("jump")
			140: Input.action_release("move_right"); Input.action_release("sprint")
		await process_frame
	root.get_node("Audio").shutdown()
	await create_timer(0.15).timeout
	quit()
