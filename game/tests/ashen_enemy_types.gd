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
	shape.size = Vector2(1800,80)
	var collider := CollisionShape2D.new()
	collider.shape=shape
	floor_body.position=Vector2(600,650)
	floor_body.add_child(collider)
	world.add_child(floor_body)
	var player: CharacterBody2D = load("res://actors/player_2d.gd").new()
	player.position=Vector2(500,610)
	world.add_child(player)
	await _ticks(5)
	player.set_physics_process(false)
	for kind in ["lancer","sentinel"]:
		player.health=100
		player.invulnerable=0
		var enemy: CharacterBody2D=load("res://actors/enemy_2d.gd").new()
		enemy.enemy_kind=kind
		enemy.position=Vector2(370 if kind=="lancer" else 420,610)
		enemy.target=player
		world.add_child(enemy)
		await _ticks(3)
		assert(enemy.rig.profile_id==kind+"_pixel")
		assert(enemy.melee_reach==155 if kind=="lancer" else enemy.mass_kg==115)
		for frame in range(150):
			await _ticks(1)
			if player.health<100:break
		assert(player.health==(82 if kind=="lancer" else 75),"Each new melee type lands its own telegraphed attack")
		enemy.queue_free()
		await _ticks(2)
	world.queue_free()
	root.get_node("Audio").shutdown()
	await _ticks(2)
	print("PASS: lancer reach and sentinel mass, pixel profiles and actual melee damage")
	quit()
