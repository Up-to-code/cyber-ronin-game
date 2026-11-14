extends Control
## Deterministic motes and traveling perimeter beams, separate from all raster art.
var age := 0.0
func _draw() -> void:
 var bounds := Rect2(Vector2(9,9), size - Vector2(18,18))
 if bounds.size.x <= 0 or bounds.size.y <= 0: return
 var perimeter := 2.0 * (bounds.size.x + bounds.size.y)
 for beam in range(3):
  for trail in range(18):
   var distance := fposmod(age * 47.0 + beam * perimeter / 3.0 - trail * 2.0, perimeter)
   var point := _edge(bounds, distance)
   var alpha := (1.0 - float(trail)/18.0) * 0.8
   draw_circle(point, 3.0, Color(1.0,0.08,0.12,alpha * 0.13))
   draw_rect(Rect2(point,Vector2(2,2)),Color(1.0,0.25,0.28,alpha))
 for index in range(32):
  var x := fposmod(index * 89.3 + sin(age * 0.3 + index) * 9.0 + age * 2.0, size.x)
  var y := fposmod(index * 47.7 - age * (3.0 + index % 4), size.y)
  var glow := 0.25 + 0.3 * (sin(age * 1.4 + index) * 0.5 + 0.5)
  draw_rect(Rect2(Vector2(x,y),Vector2(1,2)),Color(1.0,0.63,0.3,glow))
func _edge(rect: Rect2, distance: float) -> Vector2:
 if distance < rect.size.x: return rect.position + Vector2(distance,0)
 distance -= rect.size.x
 if distance < rect.size.y: return Vector2(rect.end.x,rect.position.y+distance)
 distance -= rect.size.y
 if distance < rect.size.x: return rect.end - Vector2(distance,0)
 return Vector2(rect.position.x,rect.end.y-(distance-rect.size.x))
