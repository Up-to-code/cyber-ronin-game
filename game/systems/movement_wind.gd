extends Node2D
## Short, pixel-stepped air strokes. No collision and no damage implied.
var kind := "run_wind"
var direction := 1.0
var age := 0.0
var lifetime := 0.24
func _process(delta: float) -> void:
	age += delta
	if age >= lifetime: queue_free()
	else: queue_redraw()
func _draw() -> void:
	var t := age/lifetime
	var vertical := kind == "fall_wind"
	var powerful := kind == "kick_wind"
	for i in range(5 if powerful else 3):
		var length := (42.0 if powerful else 26.0)*(1.0-t)+i*4
		var offset := Vector2((-14-t*48-i*9)*direction, (i-1)*9.0)
		if powerful: offset.x += 32*direction
		if vertical: offset = Vector2((i-1)*13.0,-20-t*40-i*7)
		var tint := Color("f6dfbd" if powerful else "b9c8c5",(1.0-t)*0.55)
		var extent := Vector2(2,length) if vertical else Vector2(length,2)
		if not vertical and direction>0: offset.x -= length
		draw_rect(Rect2(offset.snapped(Vector2(2,2)),extent.snapped(Vector2(2,2))),tint)
		if i%2==0:
			draw_rect(Rect2((offset+Vector2(-6*direction,-4)).snapped(Vector2(2,2)),Vector2(2,2)),tint)
