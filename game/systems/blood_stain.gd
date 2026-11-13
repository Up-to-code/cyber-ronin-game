extends Node2D
## A small surface stain at a verified floor contact, bounded and self-cleaning.
var direction := 1.0
var age := 0.0
func _process(delta: float) -> void:
	age+=delta
	if age>1.6:queue_free()
	else:queue_redraw()
func _draw() -> void:
	var opacity:=clampf((1.6-age)/0.5,0,0.8)
	for i in range(13):
		var x:=float((i*17)%51-20)*direction
		var width:=6 if i%3==0 else 3
		draw_rect(Rect2(Vector2(x,0).snapped(Vector2(2,2)),Vector2(width,2+i%3)),Color("86152b",opacity))
