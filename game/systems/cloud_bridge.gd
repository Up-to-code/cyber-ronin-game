extends StaticBody2D
var width:=140.0
func _ready() -> void:
 var col:=CollisionShape2D.new()
 var shape:=RectangleShape2D.new();shape.size=Vector2(width,14)
 col.shape=shape;col.position.y=7;col.one_way_collision=true;col.one_way_collision_margin=8
 add_child(col)
 texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
func _draw() -> void:
 # The flat ivory deck matches the collision plane; stepped wisps hang below.
 draw_rect(Rect2(-width/2,0,width,9),Color("e7efe0"))
 draw_rect(Rect2(-width/2+5,9,width-10,8),Color("a4cad2"))
 for i in range(int(width/16)):
  var x: float=-width/2+i*16
  draw_rect(Rect2(x+3,17,13,4+(i%3)*3),Color("688aaf"))
  draw_rect(Rect2(x+3,2,7,2),Color("ffffff"))
