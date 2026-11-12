extends Node2D
# Small deterministic, pixel-snapped motes. Presentation never moves a physics body.
var age: float = 0
var lifetime: float = 0.28
var count: int = 8
var tint := Color("a4dad3")
var direction: float = 1
var spread: float = 1
var blood: bool = false
func _process(delta: float) -> void:
	age += delta
	if age >= lifetime:
		queue_free()
	else:
		queue_redraw()
func _draw() -> void:
	var fade: float = clampf((lifetime-age)/0.20,0,1) if blood else 1.0-age/lifetime
	for i in range(count):
		var angle: float = TAU * float(i) / count + 0.23
		var speed: float = (65.0 + (i % 3) * 27.0) * spread
		var motion := Vector2(cos(angle) * direction, sin(angle) * 0.65) * speed * age
		if blood:
			motion = Vector2(direction * (40 + absf(cos(angle))*speed) * (1.0-exp(-age*2.5))/2.5, (-35 + sin(angle)*speed*0.7) * age)
		motion.y += (360.0 if blood else 90.0) * age * age
		var side: float = (6 if i % 5 == 0 else 3) if blood else (4 if i % 3 == 0 else 2)
		if blood and age < lifetime * 0.65:
			var velocity := Vector2(direction * speed * exp(-age*2.5), -35 + sin(angle)*speed*0.7 + 720*age)
			for segment in range(1,4):
				var trail := motion - velocity * 0.012 * segment
				draw_rect(Rect2(trail.snapped(Vector2(2,2)),Vector2(2,2)),Color("861d36",fade*(0.7-segment*0.15)))
		draw_rect(Rect2(motion.snapped(Vector2(2, 2)), Vector2(side, side)), Color(tint, fade))
