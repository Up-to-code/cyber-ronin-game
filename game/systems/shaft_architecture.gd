extends Node2D
## Recessed architectural backing; walkable shelf collisions remain separate.
var side := 1.0
var wall_height := 1120.0
func _ready() -> void:
 z_index=-3
 texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 for y in [40.0,560.0]:
  var pillar:=Sprite2D.new()
  pillar.texture=preload("res://art/vertical-world/buttress.png")
  pillar.centered=false
  pillar.flip_h=side<0
  pillar.scale=Vector2(1.25,2.1)
  pillar.position=Vector2(-120 if side<0 else 0,y)
  pillar.modulate=Color(0.65,0.56,0.62)
  add_child(pillar)
 queue_redraw()
func _draw() -> void:
 var x: float=-600 if side<0 else 0
 draw_texture_rect(preload("res://art/vertical-world/wall.png"),Rect2(x,0,600,wall_height),false,Color(0.8,0.75,0.85))
