extends SceneTree
const FxDirector = preload("res://systems/run/fx_director.gd")

class FakeFx extends Node2D:
	var spawned: Array[String] = []
	var trails := 0
	func spawn(kind: String, _at: Vector2, _direction: float) -> void:
		spawned.append(kind)
		add_child(Node2D.new())
	func rig_trail(_rig: Node2D) -> void: trails += 1
	func trail(_sprite: AnimatedSprite2D, _at: Vector2, _direction: float) -> void: trails += 1
	func burst(_kind: String, _at: Vector2, _direction: float) -> void: pass

class FakeWater extends Node2D:
	var splashes := 0
	func splash(_at: Vector2, _amount: int) -> void: splashes += 1

class FakeVeil extends Node:
	var strength := 0.0
	func splash(value: float) -> void: strength = value

class FakeCamera extends RefCounted:
	var trauma := 0.0
	func add_trauma(amount: float, ceiling: float = 0.65) -> void:
		trauma = minf(ceiling, trauma + amount)

class FakePlayer extends CharacterBody2D:
	var attack_aim := Vector2.RIGHT
	var rig: Node2D
	var sprite: AnimatedSprite2D

func _initialize(): call_deferred("run")
func run():
	var fx := FakeFx.new()
	var water := FakeWater.new()
	var veil := FakeVeil.new()
	var camera := FakeCamera.new()
	var player := FakePlayer.new()
	var root_node := Node2D.new()
	var director = FxDirector.new()
	director.bind(fx, player, camera, veil, root_node)
	director.water = water

	director.enemy("water", Vector2.ZERO, 1)
	assert(water.splashes == 1 and fx.spawned.is_empty(), "water must route to splash")

	director.player_effect("impact", Vector2(10, 10), 1)
	assert(camera.trauma > 0 and veil.strength == 1.0, "impact must add trauma and veil")
	assert(fx.spawned.back() == "impact")

	camera.trauma = 0.0
	director.player_effect("slash", Vector2(10, 10), 1)
	assert(camera.trauma == 0.0, "slash must not add trauma")
	var slashes := fx.get_children()
	assert(slashes.size() > 0)
	assert(slashes.back().has_meta("follow_actor"), "aimed effects must follow the player")
	assert(slashes.back().get_meta("follow_actor") == player)
	assert(slashes.back().has_meta("follow_offset"))

	player.free()
	fx.free()
	water.free()
	veil.free()
	root_node.free()
	print("PASS fx director water routing, trauma/veil policy and aim follow")
	quit()
