extends Node2D
## Locked aim, visible warning, then one collision sweep. Walls stop the beam.
signal impact(at: Vector2, kind: String)
var direction := Vector2.RIGHT
var owner_body: CollisionObject2D
var from_player := false
var damage := 22
var warning := 0.65
var length := 620.0
var age := 0.0
var fired := false
var endpoint := Vector2.ZERO
var flame: Texture2D = preload("res://art/crimson-magic/spirit-flight.png")
func _ready() -> void:
 process_mode=Node.PROCESS_MODE_PAUSABLE
 add_to_group("combat_projectiles")
 z_index=6
 direction=direction.normalized()
 if from_player: warning=0.09
 endpoint=direction*length
func _physics_process(delta: float) -> void:
 age+=delta
 if not is_instance_valid(owner_body) or owner_body.health<=0 or (not fired and owner_body.hurt_left>0):
  queue_free()
  return
 if not fired:
  var wall:=get_world_2d().direct_space_state.intersect_ray(PhysicsRayQueryParameters2D.create(global_position,global_position+direction*length,1))
  endpoint=wall.position-global_position if not wall.is_empty() else direction*length
 if age>=warning and not fired:
  fired=true
  _fire()
 if age>warning+0.18: queue_free()
 queue_redraw()
func _fire() -> void:
 var audio:=get_node_or_null("/root/Audio")
 if audio: audio.play("energy_swing" if from_player else "enemy_cast")
 var start:=global_position
 var finish:=start+direction*length
 var exclusions: Array[RID]=[owner_body.get_rid()]
 var struck_actor := false
 for i in range(3 if from_player else 1):
  var query:=PhysicsRayQueryParameters2D.create(start,finish,1|(4 if from_player else 2),exclusions)
  var hit:=get_world_2d().direct_space_state.intersect_ray(query)
  if hit.is_empty():
   if not struck_actor: endpoint=direction*length
   break
  endpoint=hit.position-global_position
  var body: Node=hit.collider
  if from_player and body.has_method("receive_hit"):
   struck_actor=true
   body.receive_hit(damage,"ranged",direction.x,hit.position)
   exclusions.append(body.get_rid())
   start=hit.position+direction*2
  elif not from_player and body.has_method("take_damage"):
   if not body.has_method("can_cut_fire") or not body.can_cut_fire(global_position,hit.position):
    body.take_damage(damage,direction.x)
   impact.emit(hit.position,"fire")
   break
  else:
   impact.emit(hit.position,"fire")
   break
func _draw() -> void:
 var distance:=endpoint.length()
 draw_set_transform(Vector2.ZERO,direction.angle())
 if not fired:
  for x in range(0,int(distance),18):
   draw_rect(Rect2(x,-1,10,2),Color(1,0.28,0.22,0.4+0.5*age/warning))
 else:
  var fade:=clampf(1-(age-warning)/0.18,0,1)
  # A tapered, broken flame ribbon; the bright core retains an exact aim line.
  for x in range(0,int(distance),8):
   var t: float=float(x)/maxf(1,distance)
   var taper: float=sin(PI*t)*fade
   var edge: float=2+roundf(taper*(4+2*sin(x*0.19-age*55)))
   draw_rect(Rect2(x,-edge,minf(8,distance-x),edge*2),Color(0.72,0.07,0.16,fade*0.65))
   draw_rect(Rect2(x,-2,minf(8,distance-x),4),Color(1,0.40,0.31,fade))
   if x%24!=0:draw_rect(Rect2(x,-1,minf(8,distance-x),2),Color(1,0.87,0.69,fade))
   if x%32==0:
    var drift:=roundf(sin(x*.13+age*30)*(7+12*(1-fade)))
    draw_rect(Rect2(x,drift,3,2),Color(0.95,0.23,0.25,fade))
  var cell: float=flame.get_width()/9.0
  var frame: int=clampi(int((age-warning)*45),0,8)
  draw_texture_rect_region(flame,Rect2(maxf(0,distance-70),-24,80,48),Rect2(frame*cell,0,cell,flame.get_height()),Color(1,1,1,fade))
