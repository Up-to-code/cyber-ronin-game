extends Node2D
# Pixel-snapped expanding contour. Contact and airborne push-off own different shapes.
var age: float = 0.0
var lifetime: float = 0.22
var radius: float = 28.0
var flatten: float = 1.0
var tint := Color("ffe4a2")
func _process(delta: float) -> void:
	age += delta
	if age >= lifetime: queue_free()
	else: queue_redraw()
func _draw() -> void:
	var progress: float = clampf(age / lifetime, 0, 1)
	var extent: float = radius * (1.0 - pow(1.0 - progress, 3))
	var color := Color(tint, (1.0-progress) * 0.8)
	for index in range(16):
		var a: float = TAU * index / 16.0
		var b: float = TAU * (index + 0.65) / 16.0
		var first := (Vector2(cos(a), sin(a) * flatten) * extent).snapped(Vector2(2,2))
		var last := (Vector2(cos(b), sin(b) * flatten) * extent).snapped(Vector2(2,2))
		draw_line(first, last, color, 2.0, false)
