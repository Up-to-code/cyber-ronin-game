extends RefCounted
# Owns camera follow, trauma shake and route framing for one run.
# The scene feeds it the player and viewport; it never reads scene internals.
const RouteCamera = preload("res://systems/route_camera.gd")

var trauma := 0.0
var initialized := false
var time := 0.0

func reset() -> void:
	initialized = false
	trauma = 0.0

func add_trauma(amount: float, ceiling: float = 0.65) -> void:
	trauma = minf(ceiling, trauma + amount)

func update(delta: float, camera: Camera2D, map: Dictionary, player: CharacterBody2D, viewport_size: Vector2, paused: bool) -> void:
	time += delta
	var shot_zoom: float = (0.56 if map.get("shaft", false) else 0.69) + trauma * 0.025
	camera.zoom = camera.zoom.lerp(Vector2.ONE * shot_zoom, 1.0 - exp(-delta * 5.0))
	var half_width: float = viewport_size.x / (2.0 * camera.zoom.x)
	var framing: Vector2 = RouteCamera.focus(map, player.position, player.velocity)
	var target := Vector2(
		clampf(framing.x, half_width, maxf(half_width, map.width - half_width)),
		clampf(framing.y, 180, map.get("height", 950.0) - 300))
	if not initialized:
		camera.position = target
		initialized = true
	elif not paused:
		camera.position.x = lerpf(camera.position.x, target.x, 1.0 - exp(-delta * 8.0))
		camera.position.y = lerpf(camera.position.y, target.y, 1.0 - exp(-delta * 12.0))
	trauma = maxf(0, trauma - delta * 1.8)
	camera.offset = Vector2(sin(time * 43), cos(time * 51)) * trauma * trauma * 12
