extends SceneTree
## Fire barrels: deterministic placement, non-blocking hazard bodies, melee and
## projectile ignition, blast damage, chain reactions and bounded VFX.
func _initialize() -> void:
	call_deferred("_run")
	call_deferred("_watchdog")

func _watchdog() -> void:
	await create_timer(25.0, true).timeout
	push_error("Fire barrel test timed out before completion")
	quit(1)

func _ticks(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame

func _run() -> void:
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.start_game()
	await scene.level_loaded
	await _ticks(10)

	var barrels: Array = get_nodes_in_group("fire_barrels")
	assert(barrels.size() >= 2, "Surface routes place fire barrels")
	for barrel in barrels:
		assert(barrel is StaticBody2D, "Fire barrel owns a hit target")
		assert(barrel.collision_layer == 4 and barrel.collision_mask == 0, "Barrel is hittable but never blocks movement")
		assert(not barrel.is_in_group("scenery"), "Fire hazard is not decorative scenery")
		assert(not barrel.find_children("*", "CollisionShape2D", true, false).is_empty(), "Barrel exposes a hit shape")

	for enemy in get_nodes_in_group("enemies"):
		enemy.target = null
		enemy.set_physics_process(false)
		enemy.collision_layer = 0

	var player: CharacterBody2D = scene.player
	var melee_barrel = barrels[0]
	var fused: Array = [0]
	var blasted: Array = [0]
	melee_barrel.fused.connect(func(_at: Vector2): fused[0] += 1)
	melee_barrel.detonated.connect(func(_at: Vector2, _direction: float): blasted[0] += 1)
	player.position = melee_barrel.position + Vector2(-78, 0)
	player.velocity = Vector2.ZERO
	player.facing = 1
	player.health = 100
	player.invulnerable = 0
	await _ticks(6)
	player._start_attack()
	await _ticks(34)
	assert(fused[0] == 1 and blasted[0] == 1, "Melee contact lights and detonates a barrel once")
	assert(not is_instance_valid(melee_barrel) or melee_barrel.exploded, "Spent barrel is removed from play")
	assert(get_nodes_in_group("fire_barrel_vfx").size() >= 1, "Detonation spawns the fire blast VFX")
	assert(get_nodes_in_group("fire_barrel_scorch").size() >= 1, "Detonation leaves a scorch mark")

	var shot_barrel = barrels[1]
	var shot: Node = load("res://systems/combat_projectile.gd").new()
	shot.kind = "blade"
	shot.position = shot_barrel.position + Vector2(-150, -40)
	shot.direction = Vector2.RIGHT
	shot.from_player = true
	shot.owner_body = player
	scene.level_root.add_child(shot)
	await _ticks(30)
	assert(not is_instance_valid(shot_barrel) or shot_barrel.exploded, "Player projectile ignites a barrel")

	# Isolated pair proves blast damage and a chained second blast.
	var victim: CharacterBody2D = get_nodes_in_group("enemies")[0]
	victim.position = Vector2(3900, 560)
	victim.health = 500
	var first = load("res://systems/fire_barrel.gd").new()
	first.position = Vector2(3900, 600)
	first.detonated.connect(scene._fire_barrel_detonated)
	scene.level_root.add_child(first)
	var second = load("res://systems/fire_barrel.gd").new()
	second.position = Vector2(3970, 600)
	second.detonated.connect(scene._fire_barrel_detonated)
	scene.level_root.add_child(second)
	await _ticks(3)
	var chained_blasts: Array[int] = [0]
	first.detonated.connect(func(_at: Vector2, _dir: float): chained_blasts[0] += 1)
	second.detonated.connect(func(_at: Vector2, _dir: float): chained_blasts[0] += 1)
	first.receive_hit(1, "sword", 1, first.position)
	await _ticks(30)
	assert(not is_instance_valid(first) and not is_instance_valid(second), "Blast consumes both chained barrels")
	assert(victim.health < 500, "Blast damages nearby enemies")
	assert(chained_blasts[0] == 2 and get_nodes_in_group("fire_barrel_vfx").size() >= 2, "Each barrel draws exactly one blast layer")

	await create_timer(8.5).timeout
	assert(get_nodes_in_group("fire_barrel_vfx").is_empty(), "Blast effects expire")
	assert(get_nodes_in_group("fire_barrel_scorch").is_empty(), "Scorch effects expire")

	root.get_node("Audio").shutdown()
	scene.queue_free()
	await _ticks(2)
	print("PASS: fire barrels place, ignite from melee and projectiles, chain, damage actors and leave bounded VFX")
	quit()
