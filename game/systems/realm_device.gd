extends StaticBody2D
signal completed(id: String)
signal realm_requested(destination: String)
signal relic_granted(kind: String)
var player: CharacterBody2D
var record: Dictionary={}
var device_id:=""
var kind:=""
var solved:=false
var age:=0.0
var cooldown:=0.0
var platforms: Array[Node]=[]
var font=preload("res://art/pixel/PixelifySans.ttf")
var collider: CollisionShape2D
func setup(target: CharacterBody2D, data: Dictionary) -> void:
 player=target;record=data;device_id=str(data.get("id","device"));kind=str(data.type)
 var p=data.get("position",Vector2.ZERO)
 position=p if p is Vector2 else Vector2(p[0],p[1])
func _ready() -> void:
 process_mode=Node.PROCESS_MODE_PAUSABLE
 collision_layer=0;collision_mask=0
 texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 add_to_group("realm_devices")
 z_index=4
 if kind=="laser_seal":
  collision_layer=1
  collider=CollisionShape2D.new();var shape:=RectangleShape2D.new();shape.size=Vector2(48,144);collider.shape=shape;collider.position=Vector2(0,-72);add_child(collider)
func _physics_process(delta: float) -> void:
 age+=delta;cooldown=maxf(0,cooldown-delta)
 if not is_instance_valid(player) or player.health<=0:return
 var near:=absf(player.global_position.x-global_position.x)<70 and absf(player.global_position.y-global_position.y)<90
 if kind in ["relic_laser","relic_cloud"] and near and cooldown<=0:
  var ability: String="laser" if kind=="relic_laser" else "cloud"
  if player.relic_charges.get(ability,0)==0:
   player.grant_relic(ability);cooldown=3.0;relic_granted.emit(ability)
   if not solved:solved=true;completed.emit(device_id)
 if near and Input.is_action_just_pressed("interact"):
  activate()
 if kind=="fire_vent" and _vent_active() and cooldown<=0:
  var height: float=float(record.get("height",125))
  var width: float=float(record.get("width",80))
  if absf(player.global_position.x-global_position.x)<width/2 and player.global_position.y<=global_position.y+12 and player.global_position.y>global_position.y-height:
   player.take_damage(16);cooldown=.7
 queue_redraw()
func activate() -> bool:
 if solved and kind not in ["portal","relic_laser","relic_cloud"]:return false
 if kind=="cloud_anchor":
  if record.get("landings",[]).is_empty():return false
  if not player.consume_relic("cloud"):return false
  for landing in record.get("landings",[]):
   var body:=preload("res://systems/cloud_bridge.gd").new()
   body.position=Vector2(landing[0],landing[1]);body.width=float(landing[2])
   get_parent().add_child(body);platforms.append(body)
  solved=true;completed.emit(device_id);player.fx_requested.emit("air_jump",global_position,1)
  return true
 if kind=="portal" and cooldown<=0:
  cooldown=1;solved=true;completed.emit(device_id);realm_requested.emit(str(record.get("destination","surface")));return true
 return false
func break_with_relic() -> void:
 if kind!="laser_seal" or solved:return
 solved=true;collision_layer=0
 if is_instance_valid(collider):collider.set_deferred("disabled",true)
 player.fx_requested.emit("explosion",global_position+Vector2(0,-70),1)
 completed.emit(device_id);queue_redraw()
func _vent_active() -> bool:
 var period: float=maxf(2,float(record.get("period",3.6)))
 return fposmod(age+float(record.get("phase",0)),period)>period-1.0
func _draw() -> void:
 var texture: Texture2D
 var size:=Vector2(70,95)
 var text:=""
 match kind:
  "relic_laser":texture=preload("res://art/realm-relics/sun.png");text="SUN RELIC • X / G" if cooldown<=0 else "RECHARGING"
  "relic_cloud":texture=preload("res://art/realm-relics/cloud.png");text="CLOUD SEED"
  "laser_seal":
   if solved:return
   texture=preload("res://art/realm-relics/seal.png");size=Vector2(64,144);text="SUN BEAM SEAL"
  "cloud_anchor":texture=preload("res://art/realm-relics/cloud.png");size=Vector2(45,55);text="BRIDGE GROWN" if solved else "E • GROW CLOUD BRIDGE"
  "portal":texture=preload("res://art/realm-relics/portal.png");size=Vector2(105,150);text="E • ENTER REALM"
  "fire_vent":
   var height: float=float(record.get("height",125))
   var width: float=float(record.get("width",80))
   draw_rect(Rect2(-width/2,-8,width,8),Color("6e3340"))
   var period: float=maxf(2,float(record.get("period",3.6)))
   var phase:=fposmod(age+float(record.get("phase",0)),period)
   if _vent_active():
    var frames=[preload("res://art/living-marsh/fire0.png"),preload("res://art/living-marsh/fire1.png"),preload("res://art/living-marsh/fire2.png"),preload("res://art/living-marsh/fire3.png")]
    draw_texture_rect(frames[int(age*10)%4],Rect2(-width/2,-height,width,height),false)
   elif phase>period-1.7:draw_line(Vector2(-width/2,-15),Vector2(width/2,-15),Color("ffcf69"),3)
   return
 if texture:draw_texture_rect(texture,Rect2(-size.x/2,-size.y,size.x,size.y),false,Color(1,1,1,.65 if kind=="cloud_anchor" and solved else 1))
 if is_instance_valid(player) and player.global_position.distance_to(global_position)<210:
  draw_string(font,Vector2(-110,-size.y-12),text,HORIZONTAL_ALIGNMENT_CENTER,220,13,Color("ffe0a2"))
