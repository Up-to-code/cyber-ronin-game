extends Node2D
## Long-lived ground mark left by a fire barrel. It cools from embers to soot,
## then fades out without touching collision or actor queries.
var age: float = 0.0
var lifetime: float = 8.0
var direction: float = 1.0

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	z_index = 0
	add_to_group("fire_barrel_scorch")

func _process(delta: float) -> void:
	age += delta
	if age >= lifetime:
		queue_free()
	else:
		queue_redraw()

func _draw() -> void:
	var fade: float = clampf((lifetime - age) / 2.0, 0.0, 1.0)
	var soot := Color(0.10, 0.08, 0.08, 0.58 * fade)
	for i in range(5):
		var width: float = (44.0 - i * 7.0) * (1.0 if direction >= 0.0 else 1.0)
		draw_rect(Rect2(Vector2(-width * 0.5 + i * 1.5, -3 - i * 2), Vector2(width, 4)), soot)
	for i in range(4):
		var x: float = (float(i) - 1.5) * 14.0
		draw_rect(Rect2(Vector2(x, -7 - (i % 2) * 3), Vector2(6, 3)), Color(0.16, 0.12, 0.11, 0.42 * fade))
	var ember_fade: float = clampf(1.0 - age / 1.6, 0.0, 1.0)
	if ember_fade <= 0.0:
		return
	for i in range(3):
		var pulse: float = 0.5 + 0.5 * sin(age * 12.0 + i * 2.1)
		var at := Vector2((float(i) - 1.0) * 12.0, -4.0 - float(i % 2) * 2.0).snapped(Vector2(2, 2))
		draw_rect(Rect2(at, Vector2(2, 2)), Color(1.0, 0.40, 0.10, ember_fade * pulse))
