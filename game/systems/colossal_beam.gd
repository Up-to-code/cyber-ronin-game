extends Node2D
var owner_body: CharacterBody2D
var direction:=Vector2.RIGHT
var age:=0.0
var fired:=false
var cast_epoch: int = -1
var endpoint:=Vector2.ZERO
const LENGTH:=920.0
func _ready() -> void:
 cast_epoch=owner_body.relic_epoch
 process_mode=Node.PROCESS_MODE_PAUSABLE
 add_to_group("combat_projectiles")
 z_index=10
 direction=direction.normalized()
 endpoint=direction*LENGTH
func _physics_process(delta: float) -> void:
 age+=delta
 if not is_instance_valid(owner_body) or owner_body.health<=0 or owner_body.relic_epoch!=cast_epoch:
  queue_free();return
 if age>=0.22 and not fired:
  fired=true
  _fire()
 if age>0.65:queue_free()
 queue_redraw()
func _fire() -> void:
 var exclusions: Array[RID]=[owner_body.get_rid()]
 var start:=global_position
 var end:=global_position+direction*LENGTH
 for i in range(12):
  var hit:=get_world_2d().direct_space_state.intersect_ray(PhysicsRayQueryParameters2D.create(start,end,1|4,exclusions))
  if hit.is_empty():endpoint=end-global_position;break
  endpoint=hit.position-global_position
  var body=hit.collider
  if body.has_method("break_with_relic"):
   body.break_with_relic()
  elif body.has_method("receive_hit"):
   body.receive_hit(240,"power",direction.x,hit.position)
  else:break
  exclusions.append(body.get_rid())
  start=hit.position+direction*2
 owner_body.fx_requested.emit("power",global_position,owner_body.facing)
func _draw() -> void:
 draw_set_transform(Vector2.ZERO,direction.angle())
 var length:=maxf(1,endpoint.length())
 if not fired:
  for x in range(0,int(length),24):draw_rect(Rect2(x,-2,13,4),Color(1,.8,.3,0.7))
  draw_arc(Vector2.ZERO,18+age*60,0,TAU,16,Color("ffdf83"),3)
 else:
  var alpha:=clampf((.65-age)/.25,0,1)
  var pulse:=1+sin(age*80)*.06
  draw_rect(Rect2(0,-29*pulse,length,58*pulse),Color(1,.12,.18,.45*alpha))
  draw_rect(Rect2(0,-17,length,34),Color(1,.61,.18,alpha))
  draw_rect(Rect2(0,-6,length,12),Color(1,.96,.72,alpha))
  for i in range(9):
   var x:=fposmod(age*800+i*111,length)
   draw_rect(Rect2(x,-26+(i%3)*23,14,3),Color(1,.9,.45,alpha))
