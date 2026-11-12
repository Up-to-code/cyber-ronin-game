extends SceneTree
func _initialize() -> void: call_deferred("_run")
func _ticks(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame
func _run() -> void:
	var world := Node2D.new()
	root.add_child(world)
	var floor_body := StaticBody2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(2000,80)
	var collider := CollisionShape2D.new()
	collider.shape = shape
	floor_body.add_child(collider)
	floor_body.position = Vector2(800,650)
	world.add_child(floor_body)
	var player: CharacterBody2D = load("res://actors/player_2d.gd").new()
	player.position = Vector2(300,610)
	world.add_child(player)
	await _ticks(10)
	player.facing = 1
	player.jump_buffer_left = 0.1
	player.kick_buffer_left = 0.2
	player.take_damage(15,1)
	assert(player.velocity.x > 0,"A hit from behind pushes away from attacker")
	assert(player.jump_buffer_left == 0 and player.kick_buffer_left == 0,"Hit discards buffered attacks/jumps")
	player.take_damage(15,-1)
	assert(player.health == 85,"Grace window rejects repeated damage")
	await _ticks(3)
	assert(player.rig.modulate.a < 1 or player.rig.modulate.g < 0.8,"Visible character communicates invulnerability")
	await _ticks(45)
	player.invulnerable = 0
	player.take_damage(100)
	await _ticks(2)
	var first: int = player.rig.current_frame
	await _ticks(30)
	assert(player.rig.current_clip == "death" and player.rig.current_frame > first,"Visible death drawings advance")
	player.health = 100
	player.low_kick = true
	player.kick_buffer_left = 0.3
	player.crouching = true
	player.reset_motion_presentation()
	assert(not player.dead and not player.crouching and not player.low_kick,"Retry clears death and crouch state")
	assert(player.kick_buffer_left == 0 and player.death_elapsed == 0,"Retry clears stale input and animation timers")
	await _ticks(3)
	assert(player.rig.current_clip != "death" and player.rig.modulate == Color.WHITE,"Retry restores living presentation")
	print("PASS: directional hit, grace period feedback, stale-input cancellation, visible death progression and retry reset")
	root.get_node("Audio").shutdown()
	world.queue_free()
	await _ticks(2)
	quit()
