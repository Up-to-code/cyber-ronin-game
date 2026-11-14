extends Node2D
var age:=0.0
func _process(delta: float) -> void:
 age+=delta
 if age>.65:queue_free()
 queue_redraw()
func _draw() -> void:
 for i in range(4):
  var at:=Vector2(i*9-14+sin(age*5+i)*4,-age*(35+i*7)).round()
  var tint:=Color(.65,.88,1,(1-age/.65)*.65)
  draw_rect(Rect2(at,Vector2(4,4)),tint,false,1)
