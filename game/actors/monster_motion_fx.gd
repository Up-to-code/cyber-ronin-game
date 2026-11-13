extends Node2D
## Small world-space movement accents; never substitutes for body animation.
var actor: CharacterBody2D
var motes: Array[Dictionary]=[]
var distance:=0.0
var beat:=0.0
var last_grounded:=false
var serial:=0
var last_frame:=-1
func _ready() -> void:
 top_level=true;global_position=Vector2.ZERO;z_index=3
 texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
func _physics_process(delta: float) -> void:
 for i in range(motes.size()-1,-1,-1):
  var mote: Dictionary=motes[i];mote.age+=delta
  if mote.age>=mote.life:motes.remove_at(i);continue
  mote.at+=mote.velocity*delta
  mote.velocity.y+=(-32 if mote.kind=="bubble" else 55)*delta
 if not is_instance_valid(actor):queue_free();return
 if actor.health<=0:queue_redraw();return
 var visible_range: bool=not is_instance_valid(actor.target) or actor.global_position.distance_to(actor.target.global_position)<950
 var ground: bool=actor.is_on_floor()
 if visible_range:
  if actor.swimming or actor._is_hovering():
   beat+=delta
   if beat>.32:
    beat=0;_burst("bubble" if actor.swimming else "air",actor.global_position+Vector2(-actor.facing*actor.body_width*.3,-actor.body_height*.5),2)
  elif ground and absf(actor.velocity.x)>25:
   var motion=actor.motion_visual
   if is_instance_valid(motion) and motion.has_method("_choose_frame"):
    if motion.phase=="travel" and motion.frame_index!=last_frame and motion.frame_index in [0,2]:
     _burst("dust",actor.global_position+Vector2(-actor.facing*9,-2),3)
    last_frame=motion.frame_index
   else:
    distance+=absf(actor.velocity.x)*delta
    if distance>maxf(26,float(actor.motion_profile.get("stride",15))):
     distance=0;_burst("dust",actor.global_position+Vector2(-actor.facing*9,-2),3)
  else:last_frame=-1
  if ground and not last_grounded:_burst("dust",actor.global_position+Vector2(0,-2),5)
 last_grounded=ground
 queue_redraw()
func _burst(kind: String,at: Vector2,count: int) -> void:
 for i in range(count):
  if motes.size()>=14:break
  serial+=1
  var sign:float=-1 if serial%2 else 1
  motes.append({"kind":kind,"at":at,"velocity":Vector2(sign*(10+serial%19),-14-serial%15),"age":0.0,"life":.28+float(serial%4)*.06,"size":1+serial%3})
func _draw() -> void:
 for mote in motes:
  var alpha: float=(1-mote.age/mote.life)*.5
  var at: Vector2=mote.at.snapped(Vector2(2,2))
  var color:=Color(.64,.55,.44,alpha)
  if mote.kind=="air":
   draw_line(at,at+Vector2(-actor.facing*(5+mote.size*2),2),Color(.77,.85,.9,alpha),1)
  elif mote.kind=="bubble":
   draw_rect(Rect2(at,Vector2.ONE*(mote.size+1)),Color(.45,.85,1,alpha),false,1)
  else:draw_rect(Rect2(at,Vector2.ONE*mote.size),color)
