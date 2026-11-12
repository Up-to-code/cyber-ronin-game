extends Node2D
# A forward half-shell around the body. The lower edge stops above the soles.
var direction: float=1
var strength: float=1
var age: float=0
const LIFETIME: float=0.24
const RADIUS_Y: float=52
func _ready() -> void:
	texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
func _process(delta: float) -> void:
	age+=delta
	if age>=LIFETIME:queue_free()
	else:queue_redraw()
func edge_point(angle: float, inset: float=0) -> Vector2:
	return Vector2(cos(angle)*(88*strength-inset)*direction,sin(angle)*(RADIUS_Y-inset*.35)).snapped(Vector2(2,2))
func _draw() -> void:
	var phase: float=clampf(age/LIFETIME,0,1)
	var envelope: float=minf(1,0.65+age*9)*(1-phase*phase)
	var finish: float=lerpf(0.25,PI/2,minf(1,age/0.06))
	var outer:=PackedVector2Array()
	var inner:=PackedVector2Array()
	for i in range(25):
		var angle: float=lerpf(-PI/2,finish,float(i)/24)
		outer.append(edge_point(angle))
		inner.append(edge_point(angle,11))
	for i in range(24):
		draw_colored_polygon(PackedVector2Array([outer[i],outer[i+1],inner[i+1],inner[i]]),Color(0.85,0.12,0.22,envelope*.85))
	draw_polyline(outer,Color(1,0.89,0.72,envelope),3,false)
	draw_polyline(inner,Color(1,0.36,0.32,envelope*.8),2,false)
	if strength>1:
		var echo:=PackedVector2Array()
		for i in range(25):echo.append(edge_point(lerpf(-PI/2,finish,float(i)/24),23))
		draw_polyline(echo,Color(1,0.7,0.55,envelope*.55),2,false)
	# Three small edge glints peak just after contact, never imply extra hits.
	if age>.025 and age<.13:
		for angle in [-0.65,0.15,1.0]:
			var point: Vector2=edge_point(angle)
			draw_rect(Rect2(point-Vector2(2,2),Vector2(4,4)),Color(1,0.96,0.82,envelope))
