extends Node2D
## Native game scenery; presentation-only animation in the private preview world.
var age:=0.0
var enabled:=true
var sky:=preload("res://art/pixel/sky.png")
var castle:=preload("res://art/pixel/castle.png")
var floor_art:=preload("res://art/pixel/platform.png")
var torch:=preload("res://art/pixel/torch.png")
func _process(delta: float) -> void:
 if not enabled:return
 age+=delta
 queue_redraw()
func _draw() -> void:
 draw_rect(Rect2(0,0,278,189),Color("0d101f"))
 draw_texture_rect(sky,Rect2(-12,0,310,175),false,Color(.55,.58,.7))
 draw_texture_rect(castle,Rect2(-10+sin(age*.08)*1.5,19,310,170),false,Color(.72,.65,.78))
 draw_rect(Rect2(0,155,278,19),Color(.04,.025,.055,.55))
 draw_texture_rect(floor_art,Rect2(0,174,278,35),false)
 draw_circle(Vector2(142,174),20,Color(0,0,0,.25))
 for side in [24,253]:
  var frame:=int(age*10)%3
  draw_texture_rect_region(torch,Rect2(side-16,135,32,32),Rect2(0,frame*64,64,64),Color.WHITE)
  draw_circle(Vector2(side,142),12,Color(1,.35,.08,.025+.01*sin(age*5)))
 for index in range(9):
  var p:=Vector2(fposmod(index*39+sin(age*.4+index)*3,278),fposmod(index*23-age*(1+index%3),169))
  draw_rect(Rect2(p.floor(),Vector2.ONE),Color(.9,.58,.31,.25+.12*sin(age+index)))
