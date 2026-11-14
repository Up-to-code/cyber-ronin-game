extends Node2D
## Layered pixel blast for a fire barrel: hot core, radial tongues, ember spray,
## a single expanding contour and rolling smoke. No bitmap assets are required.
var age: float = 0.0
var lifetime: float = 0.95
var radius: float = 148.0
var direction: float = 1.0

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	z_index = 12
	add_to_group("fire_barrel_vfx")

func _process(delta: float) -> void:
	age += delta
	if age >= lifetime:
		queue_free()
	else:
		queue_redraw()

func _draw() -> void:
	_draw_smoke()
	_draw_core()
	_draw_tongues()
	_draw_ring()
	_draw_embers()
	if age < 0.06:
		var flash: float = 1.0 - age / 0.06
		draw_rect(Rect2(-40, -40, 80, 80), Color(1.0, 0.97, 0.82, flash * 0.55))

func _draw_core() -> void:
	var fade: float = clampf(1.0 - age / 0.44, 0.0, 1.0)
	if fade <= 0.0:
		return
	var bloom: float = 0.45 + clampf(age / 0.14, 0.0, 1.0) * 0.55
	_pixel_disc(Vector2.ZERO, 46.0 * bloom, Color(0.30, 0.05, 0.03, fade * 0.85))
	_pixel_disc(Vector2.ZERO, 36.0 * bloom, Color(0.72, 0.16, 0.06, fade * 0.9))
	_pixel_disc(Vector2.ZERO, 26.0 * bloom, Color(1.0, 0.38, 0.08, fade))
	_pixel_disc(Vector2.ZERO, 15.0 * bloom, Color(1.0, 0.72, 0.22, fade))
	_pixel_disc(Vector2.ZERO, 7.0 * bloom, Color(1.0, 0.96, 0.70, fade))

func _draw_tongues() -> void:
	var fade: float = clampf(1.0 - age / 0.40, 0.0, 1.0)
	if fade <= 0.0:
		return
	var reach: float = 30.0 + clampf(age / 0.18, 0.0, 1.0) * 54.0
	for i in range(9):
		var angle: float = TAU * float(i) / 9.0 + 0.24
		var flicker: float = 0.68 + 0.32 * sin(age * 22.0 + i * 1.9)
		var extent: float = reach * flicker
		var tip := (Vector2(cos(angle), sin(angle) * 0.74) * extent).snapped(Vector2(2, 2))
		var size: float = 8.0 + 5.0 * flicker
		draw_rect(Rect2(tip - Vector2(size, size) * 0.5, Vector2(size, size)), Color(0.95, 0.30, 0.06, fade * 0.8))
		draw_rect(Rect2(tip - Vector2(size, size) * 0.25, Vector2(size, size) * 0.5), Color(1.0, 0.75, 0.24, fade * 0.9))

func _draw_ring() -> void:
	var progress: float = age / 0.36
	if progress >= 1.0:
		return
	var extent: float = snappedf(20.0 + radius * 0.55 * (1.0 - pow(1.0 - progress, 3)), 2.0)
	var color := Color(1.0, 0.62, 0.20, (1.0 - progress) * 0.75)
	for i in range(18):
		var angle: float = TAU * float(i) / 18.0
		var at := (Vector2(cos(angle), sin(angle) * 0.62) * extent).snapped(Vector2(2, 2))
		draw_rect(Rect2(at - Vector2(2, 2), Vector2(4, 4)), color)

func _draw_embers() -> void:
	var fade: float = clampf(1.0 - age / lifetime, 0.0, 1.0)
	for i in range(18):
		var angle: float = TAU * float(i) / 18.0 + 0.17
		var speed: float = 110.0 + float(i % 5) * 38.0
		var motion := Vector2(cos(angle) * speed + direction * 18.0, sin(angle) * speed * 0.72 - 90.0) * age
		motion.y += 320.0 * age * age
		var size: float = 3.0 if i % 4 == 0 else 2.0
		draw_rect(Rect2(motion.snapped(Vector2(2, 2)), Vector2(size, size)), Color(1.0, 0.48 + 0.10 * (i % 3), 0.12, fade))

func _draw_smoke() -> void:
	for i in range(9):
		var delay: float = 0.03 + float(i) * 0.035
		var progress: float = (age - delay) / (lifetime - delay)
		if progress < 0.0 or progress > 1.0:
			continue
		var rise: float = 24.0 + progress * (78.0 + i * 3.0)
		var drift: float = (float(i) - 4.0) * 9.0 + sin(progress * 3.0 + i) * 14.0
		var size: float = snappedf(8.0 + progress * 20.0, 2.0)
		var color := Color(0.20, 0.17, 0.17, (1.0 - progress) * 0.34)
		var at := Vector2(drift, -rise).snapped(Vector2(2, 2))
		draw_rect(Rect2(at - Vector2(size, size) * 0.5, Vector2(size, size)), color)
		draw_rect(Rect2(at - Vector2(size, size) * 0.5 + Vector2(size * 0.35, -size * 0.45), Vector2(size * 0.72, size * 0.72)), Color(0.25, 0.21, 0.20, (1.0 - progress) * 0.24))

func _pixel_disc(center: Vector2, disc_radius: float, color: Color) -> void:
	var extent: int = int(maxf(2.0, disc_radius))
	var step: int = 4
	for y in range(-extent, extent + 1, step):
		var span: float = sqrt(maxf(0.0, disc_radius * disc_radius - float(y * y)))
		var left: float = snappedf(center.x - span, 2.0)
		var top: float = snappedf(center.y + y, 2.0)
		draw_rect(Rect2(left, top, snappedf(span * 2.0, 2.0), step), color)
