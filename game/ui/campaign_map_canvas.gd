extends Control
var points: Array[Vector2] = []
var unlocked := 1
func _draw() -> void:
	for i in range(1,points.size()):
		if i%10==0: continue
		var tint := Color("e65464") if i<unlocked else Color("48202c")
		draw_line(points[i-1],points[i],Color("120e17"),6,false)
		draw_line(points[i-1],points[i],tint,2,false)
