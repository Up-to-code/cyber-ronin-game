extends Node2D
# Singular encounters: each rule has a different player counter.
var actor: CharacterBody2D
var mode := ""
var clock := 1.0
var marks: Array[Dictionary] = []
var previous_attack := false
var tether_left := 0.0
var tether_anchor := Vector2.ZERO
var font = preload("res://art/pixel/PixelifySans.ttf")
func _ready() -> void:
 set_as_top_level(true)
 global_position=Vector2.ZERO
 z_index=8
func _physics_process(delta: float) -> void:
 if not is_instance_valid(actor) or actor.health<=0:
  queue_free();return
 var p=actor.target
 if not is_instance_valid(p) or p.health<=0:return
 var near: bool=actor.global_position.distance_to(p.global_position)<480
 clock=maxf(0,clock-delta)
 if near and mode=="echo" and p.attack_time>0 and not previous_attack and clock<=0:
  marks.append({"at":p.global_position,"left":0.85,"life":1.05,"armed":true})
  clock=1.3
 if near and mode=="tether" and clock<=0:
  tether_anchor=p.global_position
  tether_left=2.4
  clock=5.0
 if near and mode=="garden" and clock<=0:
  for dx in [-100,0,100]:
   var from: Vector2=p.global_position+Vector2(dx,-8)
   var hit=get_world_2d().direct_space_state.intersect_ray(PhysicsRayQueryParameters2D.create(from,from+Vector2(0,230),1))
   if not hit.is_empty():marks.append({"at":hit.position,"left":0.7,"life":7.0,"armed":false})
  clock=8.0
 previous_attack=p.attack_time>0
 if tether_left>0:
  tether_left=maxf(0,tether_left-delta)
  if p.dodge_time>0 or (p.attack_time>0 and p.global_position.distance_to(tether_anchor)<95):
   tether_left=0
   actor.fx_requested.emit("charge",tether_anchor+Vector2(0,-30),1)
  elif p.global_position.distance_to(tether_anchor)>155:
   p.velocity.x=lerpf(p.velocity.x,signf(tether_anchor.x-p.global_position.x)*180,1.0-exp(-delta*45))
 for mark in marks:
  mark.life-=delta
  if not mark.armed and absf(p.global_position.x-mark.at.x)<55 and absf(p.global_position.y-mark.at.y)<45:mark.armed=true
  if mark.armed:
   var before: float=mark.left
   mark.left-=delta
   if before>0 and mark.left<=0:
    actor.fx_requested.emit("aerial_land",mark.at,1)
    if absf(p.global_position.x-mark.at.x)<65 and absf(p.global_position.y-mark.at.y)<(105 if mode=="echo" else 30):p.take_damage(18 if mode=="echo" else 14)
    mark.life=minf(mark.life,0.2)
 marks=marks.filter(func(mark):return mark.life>0)
 queue_redraw()
func _draw() -> void:
 if mode=="glass" and is_instance_valid(actor) and is_instance_valid(actor.target) and actor.global_position.distance_to(actor.target.global_position)<480:
  draw_string(font,actor.global_position+Vector2(-75,-160),"GUARD OPEN" if actor.recovery>0 else "BAIT STRIKE / KICK",HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("ffce67"))
 for mark in marks:
  var at: Vector2=mark.at
  var color:=Color("ffca58") if mark.armed else Color("a74b7f")
  draw_line(at+Vector2(-60,-3),at+Vector2(60,-3),color,3)
  draw_texture_rect(preload("res://art/crimson-gold/impact0.png"),Rect2(at+Vector2(-20,-39),Vector2(40,40)),false,color)
  if mark.armed:
   draw_arc(at+Vector2(0,-28),30,0,TAU*clampf(mark.left/(0.85 if mode=="echo" else 0.7),0,1),24,color,2)
   draw_string(font,at+Vector2(-65,-68),"LEAVE YOUR ECHO" if mode=="echo" else "JUMP THE BLOOM",HORIZONTAL_ALIGNMENT_LEFT,-1,13,color)
 if tether_left>0 and is_instance_valid(actor.target):
  draw_line(tether_anchor+Vector2(0,-25),actor.target.global_position+Vector2(0,-45),Color("ffce67"),2)
  draw_texture_rect(preload("res://art/crimson-gold/impact0.png"),Rect2(tether_anchor+Vector2(-18,-38),Vector2(36,36)),false)
  draw_string(font,tether_anchor+Vector2(-90,-75),"CUT THE KNOT / DASH FREE",HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("ffce67"))
