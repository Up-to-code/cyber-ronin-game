extends SceneTree
class DamageTarget extends StaticBody2D:
	signal fx_requested(kind: String, at: Vector2, direction: float)
	var health: int = 100
	func receive_hit(amount: int, _kind: String, direction: float, point: Vector2) -> void:
		health -= amount
		fx_requested.emit("impact",point,direction)
var projectile_impacts: int = 0
func _initialize() -> void: call_deferred("_run")
func _ticks(count: int) -> void:
	for i in range(count):
		await physics_frame
		await process_frame
func _shape(body: StaticBody2D) -> void:
	var collider := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(40,80)
	collider.shape = shape
	body.add_child(collider)
func _shot(world: Node2D) -> Node2D:
	var projectile: Node2D = load("res://systems/combat_projectile.gd").new()
	projectile.position = Vector2.ZERO
	projectile.impact.connect(func(_at: Vector2,_kind: String): projectile_impacts += 1)
	world.add_child(projectile)
	return projectile
func _run() -> void:
	var world := Node2D.new()
	root.add_child(world)
	var target := DamageTarget.new()
	target.collision_layer = 4
	target.position = Vector2(120,0)
	_shape(target)
	world.add_child(target)
	var fx: Node2D = load("res://systems/pixel_fx.gd").new()
	world.add_child(fx)
	target.fx_requested.connect(fx.spawn)
	await _ticks(2)
	var projectile: Node2D = _shot(world)
	await _ticks(12)
	assert(target.health==60 and not is_instance_valid(projectile),"Projectile damages once and expires")
	assert(projectile_impacts==0,"Actor owns hit feedback, so projectile cannot emit a duplicate")
	var rings: int = 0
	for effect in fx.get_children():
		if effect.get_meta("family", "") == "contact_ring": rings += 1
	assert(rings==1,"One projectile contact must render exactly one damage ring")
	target.queue_free()
	await _ticks(2)
	var wall := StaticBody2D.new()
	wall.collision_layer = 1
	wall.position = Vector2(120,0)
	_shape(wall)
	world.add_child(wall)
	await _ticks(2)
	projectile = _shot(world)
	await _ticks(12)
	assert(projectile_impacts==1 and not is_instance_valid(projectile),"Scenery still receives one projectile-owned impact")
	world.queue_free()
	await _ticks(2)
	root.get_node("Audio").shutdown()
	print("PASS: exactly one actor contact response and preserved scenery impact")
	quit()
