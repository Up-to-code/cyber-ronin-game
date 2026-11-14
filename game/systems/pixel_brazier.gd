extends Node2D
var phase := 0.0
var variant := 0
var age := 0.0
const FRAMES = [preload("res://art/living-marsh/fire0.png"),preload("res://art/living-marsh/fire1.png"),preload("res://art/living-marsh/fire2.png"),preload("res://art/living-marsh/fire3.png")]
func _ready() -> void:
 texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 z_index=-1
func _process(delta: float) -> void:
 age+=delta
 queue_redraw()
func _draw() -> void:
 var frame:=int((age+phase)*(7.0+variant))%4
 var width:=float([34,44,27][variant])
 var height:=float([48,38,58][variant])
 # Reuse the authored iron/wood holder under the new aligned flame loop.
 draw_texture_rect_region(preload("res://art/pixel/torch.png"),Rect2(-10,-28,20,28),Rect2(8,27,16,18))
 draw_texture_rect(FRAMES[frame],Rect2(-width/2,-height-24,width,height),false)
 for i in range(4):
  var rise:=fposmod(age*(18+i*3)+phase*30+i*13,70)
  var x:=sin(age*1.4+i+phase)*8+rise*.12
  draw_rect(Rect2(Vector2(x,-28-rise).floor(),Vector2(2,2)),Color(1,.45+.1*i,.12,(1-rise/70)*.65))
