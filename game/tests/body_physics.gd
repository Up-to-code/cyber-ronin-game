extends SceneTree
const Rules = preload("res://systems/world_rules.gd")
var world: Node2D
func _initialize() -> void: call_deferred("_run")
func _ticks(count: int) -> void:
	for i in range(count):
		await physics_frame
		await process_frame
func _check(ok: bool, message: String) -> bool:
	if not ok:
		push_error(message)
		quit(1)
	return ok
func _enemy(at: Vector2, kind: String = "guard") -> CharacterBody2D:
	var enemy: CharacterBody2D = load("res://actors/enemy_2d.gd").new()
	enemy.position = at
	enemy.enemy_kind = kind
	world.add_child(enemy)
	return enemy
func _run() -> void:
	world = Node2D.new()
	root.add_child(world)
	var floor_body := StaticBody2D.new()
	floor_body.position = Vector2(1000,650)
	var collider := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(2200,80)
	collider.shape = shape
	floor_body.add_child(collider)
	world.add_child(floor_body)
	var enemy: CharacterBody2D = _enemy(Vector2(500,610))
	await _ticks(10)
	if not _check(enemy.is_on_floor() and enemy.rig is CelActorVisual, "Guard must stand on its feet with the authored cel visual"):
		return
	var launch_at: Vector2 = enemy.position
	enemy.receive_hit(20,"kick",1,enemy.position+Vector2(0,-45))
	var launch: float = enemy.velocity.y
	await _ticks(8)
	if not _check(enemy.position.y < launch_at.y - 25 and enemy.position.x > launch_at.x + 25 and absf(enemy.tumble) > 0.1 and enemy.velocity.y > launch, "Kick launch: position=%s roll=%s vy=%s initial=%s" % [enemy.position,enemy.tumble,enemy.velocity.y,launch]):
		return
	await _ticks(85)
	if not _check(enemy.is_on_floor() and absf(enemy.position.y - 610) < 1 and absf(enemy.tumble) < 0.08, "Hit body must land without sinking and settle its rotation"):
		return
	var impulse := Vector2(120,-150)
	if not _check(Rules.impulse_velocity(impulse,140).is_equal_approx(Rules.impulse_velocity(impulse,70)*0.5), "Doubling body mass must halve velocity change for the same impulse"):
		return
	var jump: float = Rules.jump_velocity()
	if not _check(is_zero_approx(Rules.angular_impulse(Vector2.ZERO,impulse,70)) and signf(Rules.angular_impulse(Vector2(0,20),Vector2(120,0),70)) == -signf(Rules.angular_impulse(Vector2(0,-20),Vector2(120,0),70)), "Central impulse must not spin; opposite contact lever arms must reverse angular response"):
		return
	if not _check(absf(jump * jump / (2 * Rules.gravity()) - 110) < 0.1, "Shared jump launch must solve the configured height"):
		return
	var player: CharacterBody2D = load("res://actors/player_2d.gd").new()
	player.position = Vector2(250,610)
	world.add_child(player)
	player.invulnerable = 999
	await _ticks(5)
	Input.action_press("move_down")
	await _ticks(2)
	if not _check(player.crouching and player.crouch_collider.shape.height < player.standing_height, "DOWN must crouch both the rig and the collision body"):
		return
	Input.action_release("move_down")
	await _ticks(2)
	var ranged_requests: Array = []
	player.projectile_requested.connect(func(kind:String,_at:Vector2,_direction:Vector2,_source:Node):ranged_requests.append(kind))
	Input.action_press("ranged_attack")
	await _ticks(1)
	Input.action_release("ranged_attack")
	await _ticks(12)
	if not _check(player.power == 75 and ranged_requests == ["blade"], "Ranged input must spend 25 power and request exactly one blade wave"):
		return
	var fire: CharacterBody2D = _enemy(Vector2(570,610),"fire")
	fire.target = player
	var shots: Array[Vector2] = []
	fire.projectile_requested.connect(func(_kind:String,_at:Vector2,direction:Vector2,_source:Node):shots.append(direction))
	await _ticks(75)
	if not _check(shots.size() == 3 and not shots[0].is_equal_approx(shots[1]), "Fire-kicking enemy must telegraph then fire a three-bolt fan"):
		return
	var wraith: CharacterBody2D = _enemy(Vector2(1050,610),"wraith")
	wraith.target = player
	await _ticks(90)
	if not _check(not wraith.is_on_floor() and wraith.position.y < 535 and wraith.rig.profile_id == "wraith_pixel", "Wraith must hover intentionally above ground with a distinct profile"):
		return
	player.invulnerable = 0
	var shot: Node2D = load("res://systems/combat_projectile.gd").new()
	shot.kind = "fire"
	shot.position = player.position + Vector2(160,-55)
	shot.direction = Vector2.LEFT
	shot.from_player = false
	shot.owner_body = fire
	shot.damage = 10
	world.add_child(shot)
	await _ticks(30)
	if not _check(player.health == 90 and not is_instance_valid(shot), "Swept fire projectile must hit the player once then disappear"):
		return
	# Isolate the projectile lane after the separate fire/wraith checks.
	# Recoil tuning can leave the fire keeper between the shooter and guard;
	# the swept projectile correctly hits that nearer body.
	fire.queue_free()
	wraith.queue_free()
	await _ticks(2)
	var health_before: int = enemy.health
	var blade: Node2D = load("res://systems/combat_projectile.gd").new()
	blade.position = enemy.position + Vector2(-150,-55)
	blade.direction = Vector2.RIGHT
	blade.owner_body = player
	world.add_child(blade)
	await _ticks(30)
	if not _check(enemy.health == health_before - 40 and not is_instance_valid(blade), "Player blade wave must hit a distant enemy once and disappear"):
		return
	print("PASS: shared gravity/jump/impulse mass, grounded cel actor, kick launch/tumble/landing, fire fan, floating wraith and swept projectile damage")
	world.queue_free()
	await _ticks(2)
	quit()
