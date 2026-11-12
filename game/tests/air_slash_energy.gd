extends SceneTree
func _initialize() -> void: call_deferred("run")
func ticks(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame
func tap(action: String) -> void:
	Input.action_press(action)
	await ticks(1)
	Input.action_release(action)
func run() -> void:
	create_timer(15,true,false,true).timeout.connect(func():quit(1))
	var world := Node2D.new()
	root.add_child(world)
	var floor_body := StaticBody2D.new()
	var collider := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(2000,80)
	collider.shape = shape
	floor_body.add_child(collider)
	floor_body.position = Vector2(800,650)
	world.add_child(floor_body)
	var player: CharacterBody2D = load("res://actors/player_2d.gd").new()
	player.position = Vector2(300,610)
	world.add_child(player)
	player.invulnerable = 999
	player.projectile_requested.connect(func(kind: String,at: Vector2,dir: Vector2,source: Node):
		var shot = load("res://systems/combat_projectile.gd").new()
		shot.kind=kind;shot.position=at;shot.direction=dir;shot.owner_body=source
		world.add_child(shot))
	await ticks(8)
	await tap("jump")
	await ticks(3)
	var before_y: float = player.position.y
	await tap("attack")
	await ticks(2)
	assert(not player.plunging and player.attack_kind == "sword", "J in air must not force plunge")
	assert(player.position.y < before_y and player.velocity.y < 0, "J preserves upward momentum")
	await ticks(80)
	for distance in [55,350]:
		var enemy: CharacterBody2D = load("res://actors/enemy_2d.gd").new()
		enemy.position = player.position + Vector2(distance,0)
		enemy.health = 500
		world.add_child(enemy)
		enemy.set_physics_process(false)
		player.power = 100
		await tap("energy_attack")
		await ticks(50)
		assert(enemy.health == 435, "Energy slash must damage exactly once at short and long range")
		assert(player.power == 65, "Energy slash spends exactly 35 power")
		enemy.queue_free()
		await ticks(2)
	player.power=0
	await tap("energy_attack")
	assert(player.attack_time == 0,"Energy without power must not fire")
	print("PASS: upward air slash, X close/far single-hit energy attack, cost and empty rejection")
	root.get_node("Audio").shutdown()
	world.queue_free()
	await ticks(2)
	quit()
