extends Control
## Separate selection and keyboard focus cues, with one traveling golden glint.
var active:=false
var focused:=false
var age:=0.0
func _ready() -> void:mouse_filter=Control.MOUSE_FILTER_IGNORE
func _process(delta: float) -> void:
 if not is_visible_in_tree():return
 age+=delta
 queue_redraw()
func _draw() -> void:
 var color:=Color("ffe7b5") if focused else Color("e9b65e")
 var inset:=4.0
 var end:=size-Vector2.ONE*inset
 for corner in [Vector2(inset,inset),Vector2(end.x,inset),Vector2(inset,end.y),end]:
  var dir:=Vector2(1 if corner.x< size.x*.5 else -1,1 if corner.y<size.y*.5 else -1)
  draw_line(corner,corner+Vector2(25*dir.x,0),color,4,true)
  draw_line(corner,corner+Vector2(0,25*dir.y),color,4,true)
 if active:
  var phase:=fposmod(age*.12,1.0)
  var point:=Vector2(lerpf(inset,end.x,phase),inset)
  draw_circle(point,4,Color(1,.8,.4,.22))
  draw_circle(point,1.5,Color("fff2cb"))
