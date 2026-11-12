extends Node2D
var age: float = 0
var direction: float = 1
func _process(delta: float) -> void:
	age+=delta
	if age>=0.20: queue_free()
	else: queue_redraw()
func _draw() -> void:
	var fade: float=1-age/0.20
	var points:=PackedVector2Array()
	for i in range(9):
		var angle: float=lerpf(-1.6,0.8,float(i)/8)+age*2.8
		points.append((Vector2(cos(angle)*direction,sin(angle))*30).snapped(Vector2(2,2)))
	draw_polyline(points,Color(0.75,0.13,0.21,fade*0.7),7,false)
	draw_polyline(points,Color(1,0.89,0.70,fade),3,false)
	for i in range(3):
		var at:=Vector2(-direction*(12+i*7),-5+i*8)
		draw_line(at,at+Vector2(-direction*12,0),Color(1,0.75,0.55,fade*0.6),2,false)
