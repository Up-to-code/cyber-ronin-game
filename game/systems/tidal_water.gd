extends Node2D
## Physical world-space water: finite bounds, bounded current force and pixel bubbles.
signal immersion_changed(underwater: bool)
var player: CharacterBody2D
var bounds := Rect2()
var currents: Array = []
var age := 0.0
var last_submerged := false
var bursts: Array[Dictionary] = []
func _ready() -> void:
 process_physics_priority=-100
 z_index=6
 texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 add_to_group("water_volumes")
func contains(at: Vector2) -> bool:return bounds.has_point(at)
func current_at(at: Vector2) -> Vector2:
 var force:=Vector2.ZERO
 for current in currents:
  var offset: Vector2=at-current.center
  var distance:=offset.length()
  var radius: float=current.radius
  if distance>=radius or distance<1:continue
  var strength: float=float(current.strength)*(1-distance/radius)
  var tangent:=Vector2(-offset.y,offset.x).normalized()*float(current.get("spin",1))
  force+=tangent*strength-offset.normalized()*strength*.35
 return force.limit_length(140)
func splash(at: Vector2, amount: int=10) -> void:
 for i in range(mini(amount,48-bursts.size())):
  bursts.append({"at":at,"velocity":Vector2(sin(i*2.4)*70,-45-float(i%4)*20),"life":.65})
func _physics_process(delta: float) -> void:
 age+=delta
 if is_instance_valid(player):
  var wet:=contains(player.global_position+Vector2(0,-45))
  player.set_submerged(wet)
  player.swim_current=current_at(player.global_position) if wet else Vector2.ZERO
  if wet!=last_submerged:
   splash(player.global_position+Vector2(0,-40),16)
   immersion_changed.emit(wet)
   last_submerged=wet
 for projectile in get_tree().get_nodes_in_group("combat_projectiles"):
  if "kind" in projectile and projectile.kind=="fire" and contains(projectile.global_position):
   splash(projectile.global_position,6);projectile.queue_free()
 for burst in bursts:
  burst.life-=delta;burst.at+=burst.velocity*delta
 bursts=bursts.filter(func(b):return b.life>0)
 queue_redraw()
func _draw() -> void:
 draw_rect(bounds,Color(.02,.35,.48,.10))
 # Sparse caustic facets and rising bubbles: fixed budgets independent of playtime.
 for i in range(76):
  var x: float=bounds.position.x+fposmod(i*137.7+sin(age*.5+i)*16,bounds.size.x)
  var y: float=bounds.position.y+fposmod(i*83.2-age*(10+i%5*5),bounds.size.y)
  var side: float=2+i%3
  draw_rect(Rect2(Vector2(x,y).floor(),Vector2(side,side+2)),Color(.65,.96,1,.22),false,1)
 for i in range(ceili(bounds.size.x/32)):
  var at:=Vector2(bounds.position.x+i*32,bounds.position.y+floor(sin(age*2+i*.8)*3))
  draw_rect(Rect2(at,Vector2(25,3)),Color(.64,.95,1,.65))
 for current in currents:
  for ring in range(5):
   var points:=PackedVector2Array()
   var radius: float=current.radius*(.18+ring*.16)
   for j in range(13):
    var angle: float=j*TAU/16+age*float(current.get("spin",1))*(.6+ring*.1)+ring*.7
    points.append((current.center+Vector2(cos(angle),sin(angle)*.65)*radius).floor())
   draw_polyline(points,Color(.35,.85,.96,.18+ring*.025),2,false)
 for burst in bursts:
  draw_rect(Rect2(burst.at.floor(),Vector2(4,4)),Color(.75,1,1,burst.life),false,1)
