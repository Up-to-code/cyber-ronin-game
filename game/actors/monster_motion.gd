extends Node2D
## Restrained textured deformation, not replacement drawings. Feet stay on the
## authored floor; upper-body reach, paired legs, wings and tails have separate weights.
var actor: CharacterBody2D
var texture: Texture2D
var clock:=0.0
var phase:="idle"
var progress:=0.0
var signature: Dictionary={}
const STANCE_CLASSES={"duelist":"duelist","wolf":"wolf","caster":"caster","beetle":"spider","bird":"flyer","flyer":"flyer","golem":"heavy","serpent":"aquatic","spider":"spider","rabbit":"wolf","heavy":"heavy","fox":"wolf","crawler":"spider","archer":"archer","deer":"wolf","boar":"wolf","tortoise":"heavy","ape":"ape","scorpion":"spider","horse":"wolf","centaur":"centaur","frog":"wolf","whale":"aquatic","fish":"aquatic","jelly":"aquatic","crab":"crab","mantis":"mantis","wheel":"wheel","mimic":"mimic","tree":"tree","doll":"doll","hydra":"hydra"}
var original_stance:="duelist"
var stance:="duelist"
var lunge:=0.0
var gait:=0.0
var pixel_scale:=2.0
var dying:=false
var death_facing:=1.0
var death_direction:=1.0
var death_points: Dictionary={}
var death_texture: Texture2D
var death_floor_shift:=0.0
var death_angle:=0.0
var death_outline:=PackedVector2Array()
const WOLF_POSES=[preload("res://art/monster-motion/wolf0.png"),preload("res://art/monster-motion/wolf1.png"),preload("res://art/monster-motion/wolf2.png")]
func begin_death() -> void:
 if dying:return
 dying=true
 death_facing=actor.facing
 death_direction=signf(actor.knockback) if absf(actor.knockback)>1 else -actor.facing
 death_texture=active_texture()
 var source:=death_texture.get_image()
 var edge:=PackedVector2Array()
 for x in range(source.get_width()):
  for y in range(source.get_height()):
   if source.get_pixel(x,y).a>.1:
    edge.append(Vector2(x,y));break
  for y in range(source.get_height()-1,-1,-1):
   if source.get_pixel(x,y).a>.1:
    edge.append(Vector2(x,y+1));break
 death_outline=Geometry2D.convex_hull(edge)
 for point in death_outline:
  death_points[point]=point if death_texture!=texture else point_motion(point)
 for y in range(9):
  for x in range(9):
   var point:=Vector2(x*16,y*16)
   death_points[point]=point if death_texture!=texture else point_motion(point)
func active_texture() -> Texture2D:
 if actor.monster_id==2 and phase in ["windup","strike","recovery"]:
  return WOLF_POSES[0 if phase=="windup" else (1 if phase=="strike" else 2)]
 return texture
func corpse_point(point: Vector2) -> Vector2:
 var posed: Vector2=death_points.get(point,point)
 # Rotate the retained contact pose, never pop back into the idle illustration.
 return (posed-Vector2(64,76)).rotated(death_angle)+Vector2(64,76)-Vector2(0,death_floor_shift)
func update_death() -> void:
 begin_death()
 var t:=clampf(actor.death_elapsed/.48,0,1)
 var eased:=1-pow(1-t,3)
 death_angle=death_direction*death_facing*eased*1.35
 death_floor_shift=0
 if actor.is_on_floor():
  var lower: float=-INF
  for point in death_outline:
   lower=maxf(lower,corpse_point(point).y)
  death_floor_shift=lower-112
 modulate.a=1-clampf((actor.death_elapsed-.85)/.4,0,1)
 actor.rig.sprite.hide()
 actor.rig.body_pivot.rotation=0
 visible=true
 queue_redraw()
func configure(target: CharacterBody2D, data: Dictionary) -> void:
 actor=target;signature=data.duplicate(true)
 original_stance=str(data.get("stance","duelist"))
 stance=str(STANCE_CLASSES.get(original_stance,original_stance))
 texture=load(actor.rig.profile.atlas)
 texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
func tick(delta: float) -> void:
 var rig=actor.rig
 pixel_scale=float(rig.profile.get("scale",2))
 var origin: Array=rig.profile.get("feet_origin",[64,112])
 position=Vector2(-float(origin[0])*pixel_scale,-float(origin[1])*pixel_scale+float(rig.profile.get("body_center_height",58)))
 scale=Vector2.ONE*pixel_scale
 if actor.health<=0:
  update_death()
  return
 clock+=delta
 var speed: float=absf(actor.velocity.x)
 gait+=delta*speed/maxf(30,float(signature.get("stride",15))*5)*TAU
 phase="hurt" if actor.hurt_left>0 else ("windup" if actor.windup>0 else ("strike" if actor.strike_left>0 else ("recovery" if actor.recovery>0 else ("travel" if speed>12 and (actor.is_on_floor() or actor.swimming or actor._is_hovering()) else "idle"))))
 progress=1-actor.windup/maxf(.01,actor.windup_duration) if phase=="windup" else (1-actor.strike_left/maxf(.01,actor.strike_duration) if phase=="strike" else (1-actor.recovery/maxf(.01,float(signature.get("recovery",.55))) if phase=="recovery" else 0))
 progress=clampf(progress,0,1)
 lunge=-sin(progress*PI*.5)*.45 if phase=="windup" else (sin(progress*PI) if phase=="strike" else (-.2*(1-progress) if phase=="recovery" else 0))
 if phase=="hurt":lunge=-actor.hit_reaction*.4
 rig.sprite.visible=false
 rig.body_pivot.rotation=0
 visible=actor.health>0
 queue_redraw()
func point_motion(point: Vector2) -> Vector2:
 var x: float=(point.x-64)/64
 var foot_weight:=clampf((112-point.y)/38,0,1)
 var upper:=clampf((105-point.y)/70,0,1)
 var step: float=sin(gait+(PI if x<0 else 0)+(PI if signature.get("lead","right")=="left" else 0))
 var displacement:=Vector2.ZERO
 var amount: float=float(signature.get("reach",10))
 # Values in source pixels. Bound reach prevents single-cel rubber stretching.
 amount=clampf(amount*.06,3,9)
 if stance in ["wolf","beast","quadruped","pouncer"]:
  displacement.y+=sin(gait*2)*1.2*upper if phase=="travel" else 0
  displacement.y+=4.5*upper*(-lunge if phase=="windup" else -lunge*.5)
  displacement.x+=lunge*amount*upper
  if point.y>78 and phase=="travel":displacement+=Vector2(step*3, -maxf(0,step)*2)*foot_weight
 elif stance in ["flyer","bird","winged","moth"]:
  displacement.y+=sin(clock*7+absf(x)*2)*absf(x)*5
  displacement.x+=lunge*amount*upper
 elif stance in ["spider","arachnid","brood"]:
  displacement.x+=sin(gait+point.x*.13)*absf(x)*2*foot_weight if phase=="travel" else 0
  displacement.y-=maxf(0,sin(gait+point.x*.13))*absf(x)*2*foot_weight if phase=="travel" else 0
  displacement.y+=(-lunge)*3*upper
 elif stance in ["aquatic","eel","serpent","jelly","swimmer"] or actor.swimming:
  displacement.y+=sin(clock*4+point.x*.065)*3*absf(x)
  displacement.x+=sin(clock*3+point.y*.055)*1.5*upper+lunge*amount*upper
 elif stance=="tree":
  # Roots remain at rest; opposing branch tips prepare and release.
  displacement.x+=sin(clock*1.4+point.y*.06)*absf(x)*upper*1.5+lunge*amount*upper*absf(x)
 elif stance=="wheel":
  var wheel_weight:=clampf((point.y-55)/45,0,1)
  var radial:=point-Vector2(64,86)
  displacement+=(radial.rotated(sin(gait)*.09)-radial)*wheel_weight
  displacement.x+=lunge*amount*upper
 elif stance=="crab":
  displacement.x+=step*2*absf(x)*foot_weight
  displacement.y-=maxf(0,sin(gait+point.x*.17))*2*absf(x)*foot_weight
  displacement.x+=lunge*amount*absf(x)*upper
 elif stance=="mantis":
  displacement.x+=lunge*amount*upper*absf(x)
  displacement.y-=lunge*4*upper*absf(x)
  if phase=="travel":displacement.y-=maxf(0,step)*2*foot_weight*(1-upper)
 elif stance=="hydra":
  displacement.x+=sin(clock*3+point.x*.11)*upper*2+lunge*amount*upper
  displacement.y+=cos(clock*3+point.x*.11)*upper*absf(x)*2
 elif stance=="ape":
  displacement.x+=step*2*absf(x)*foot_weight if phase=="travel" else lunge*amount*upper
  displacement.y+=absf(lunge)*3*upper
 elif stance=="centaur":
  if phase=="travel":displacement+=Vector2(step*2,-maxf(0,step)*2)*foot_weight*(1-upper)
  displacement.x+=lunge*amount*upper
 elif stance=="heavy":
  displacement.x+=lunge*amount*upper*.6
  displacement.y+=absf(lunge)*3*upper
  if phase=="travel":displacement.y-=maxf(0,step)*(1-upper)*foot_weight
 elif stance in ["caster","archer","doll","mimic"]:
  displacement.x+=lunge*amount*upper*absf(x)
  displacement.y+=sin(clock*2+point.x*.06)*.8*upper
 else:
  # Support plane remains pinned while hips, shoulder and weapon retract/extend.
  displacement.x+=lunge*amount*upper
  if phase=="travel":
   displacement.x+=step*2.4*(1-upper)*foot_weight
   displacement.y-=maxf(0,step)*2*(1-upper)*foot_weight
  displacement.y+=absf(lunge)*1.5*upper
 if original_stance=="beetle":displacement.y+=(-lunge)*absf(x)*upper*3
 if original_stance=="archer":displacement.x-=lunge*amount*upper*clampf(-x,0,1)
 if original_stance=="jelly":displacement.y+=sin(clock*3+point.x*.04)*upper*2
 # Grounded lower contours must not sink under the support plane, including
 # serpents and wheels whose idle motion used to deform below their collider.
 if actor.is_on_floor() and not actor.swimming:
  displacement.y=minf(displacement.y,maxf(0,112-point.y))
 return point+displacement
func _draw() -> void:
 if not texture:return
 var face: float=death_facing if dying else actor.facing
 draw_set_transform(Vector2(128,0) if face<0 else Vector2.ZERO,0,Vector2(-1,1) if face<0 else Vector2.ONE)
 var drawing: Texture2D=death_texture if dying else active_texture()
 if not dying and drawing!=texture:
  draw_texture(drawing,Vector2.ZERO)
  return
 for y in range(8):
  for x in range(8):
   var a:=Vector2(x*16,y*16)
   var b:=a+Vector2(16,0);var c:=a+Vector2(16,16);var d:=a+Vector2(0,16)
   var vertices:=PackedVector2Array([corpse_point(a),corpse_point(b),corpse_point(c),corpse_point(d)]) if dying else PackedVector2Array([point_motion(a),point_motion(b),point_motion(c),point_motion(d)])
   draw_polygon(vertices,PackedColorArray([Color.WHITE]),PackedVector2Array([a/128,b/128,c/128,d/128]),drawing)
