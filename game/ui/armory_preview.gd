extends Control
## Gameplay art, timing and VFX in a private presentation world, without gameplay authority.
const Rig=preload("res://animation/cel_actor_visual.gd")
const Fx=preload("res://systems/pixel_fx.gd")
const HOME:=Vector2(142,173)
var summary: Label
var viewport: SubViewport
var rig: Node2D
var fx: Node2D
var stage: Node2D
var target: Sprite2D
var skill:="tide"
var age:=0.0
var action_age:=0.0
var emitted:=false
var playing:=false
var replay_count:=0
var combo:=1
var spec: Dictionary={}
var auto_replay:=true
var motion_enabled:=true
var damage_multiplier:=1.0
var last_contact_age:=-1.0
var contact_count:=0
var _echo_left:=0.0
var _host: SubViewportContainer
var _rest:=0.0
var _hit_stop:=0.0
var _target_age:=5.0
var _world: Node2D
var _damage: Label
var _cast_sent:=false
func _ready() -> void:
 process_mode=Node.PROCESS_MODE_ALWAYS
 mouse_filter=Control.MOUSE_FILTER_IGNORE
 texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 clip_contents=true
 _host=SubViewportContainer.new()
 _host.mouse_filter=Control.MOUSE_FILTER_IGNORE
 _host.stretch=true
 _host.stretch_shrink=3
 _host.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 add_child(_host)
 _host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 viewport=SubViewport.new()
 viewport.transparent_bg=false
 viewport.world_2d=World2D.new()
 viewport.handle_input_locally=false
 viewport.gui_disable_input=true
 viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
 _host.add_child(viewport)
 _world=Node2D.new();viewport.add_child(_world)
 stage=preload("res://ui/armory_stage.gd").new();_world.add_child(stage)
 target=Sprite2D.new()
 var texture:=AtlasTexture.new()
 texture.atlas=preload("res://art/armory-grid/training-dummy.png")
 texture.region=Rect2(79,68,792,1539)
 target.texture=texture
 target.centered=false
 target.scale=Vector2(28.0/792,54.0/1539)
 target.offset=Vector2(-396,-1539)
 target.position=Vector2(194,174)
 target.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 _world.add_child(target)
 rig=Rig.new();_world.add_child(rig);rig.position=HOME
 fx=Fx.new();_world.add_child(fx)
 _damage=Label.new()
 _damage.add_theme_font_override("font",preload("res://art/pixel/PixelifySans.ttf"))
 _damage.add_theme_font_size_override("font_size",11)
 _damage.add_theme_color_override("font_color",Color("ffe2a8"))
 _world.add_child(_damage)
 summary=Label.new()
 summary.mouse_filter=Control.MOUSE_FILTER_IGNORE
 summary.add_theme_font_override("font",preload("res://ui/armory_art.gd").font())
 summary.add_theme_font_size_override("font_size",28)
 summary.add_theme_color_override("font_color",Color("ffe4b5"))
 summary.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 summary.position=Vector2(45,6);summary.size=Vector2(745,45)
 add_child(summary)
 var border:=Panel.new()
 border.mouse_filter=Control.MOUSE_FILTER_IGNORE
 border.add_theme_stylebox_override("panel",preload("res://ui/armory_art.gd").outline(Color("947c51"),2))
 add_child(border)
 border.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 visibility_changed.connect(_visibility)
 replay()
func _visibility() -> void:
 if viewport!=null:
  viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS if is_visible_in_tree() else SubViewport.UPDATE_DISABLED
  if stage!=null:stage.enabled=is_visible_in_tree() and motion_enabled
  if fx!=null:fx.process_mode=Node.PROCESS_MODE_INHERIT if is_visible_in_tree() and _hit_stop<=0 else Node.PROCESS_MODE_DISABLED
func set_character_profile(profile: String) -> void:
 if rig!=null:rig.configure(profile);replay()
func play_skill(id: String) -> void:
 skill=id
 if is_node_ready():replay()
func set_motion(value: bool) -> void:
 motion_enabled=value
 if stage!=null:stage.enabled=value
func replay() -> void:
 if not is_instance_valid(rig):return
 for effect in fx.get_children():fx.remove_child(effect);effect.queue_free()
 action_age=0;combo=1;emitted=false;_cast_sent=false
 playing=skill in ["sword","tide","heal","dash"]
 replay_count+=1;_echo_left=0;_rest=0;_hit_stop=0
 fx.process_mode=Node.PROCESS_MODE_INHERIT
 spec=rig.get_attack_spec("sword",combo)
 rig.position=HOME
 rig.update_pose(0,"idle",1,Vector2.ZERO,true)
 target.visible=skill in ["sword","tide"]
 _target_age=5
 _damage.text=""
 _world.position=Vector2.ZERO
func _contact(amount: int) -> void:
 contact_count+=1;last_contact_age=action_age;_target_age=0
 _damage.text=str(amount);_damage.position=Vector2(187,109)
 fx.spawn("wall_hit",Vector2(194,137),1)
 if motion_enabled:
  _hit_stop=.035
  fx.process_mode=Node.PROCESS_MODE_DISABLED
func _process(delta: float) -> void:
 if not is_visible_in_tree() or not is_instance_valid(rig):return
 age+=delta
 if _hit_stop>0:
  _hit_stop=maxf(0,_hit_stop-delta)
  if _hit_stop<=0:fx.process_mode=Node.PROCESS_MODE_INHERIT
  return
 _target_age+=delta
 target.rotation=sin(_target_age*23)*exp(-_target_age*9)*.05 if motion_enabled else 0.0
 target.modulate=Color(1.3,1.2,1.0) if _target_age<.08 else Color.WHITE
 _damage.modulate.a=clampf(1-_target_age/0.65,0,1)
 _damage.position.y=109-minf(_target_age,.65)*15
 var kick:=exp(-_target_age*20) if motion_enabled else 0.0
 _world.position=Vector2(sin(_target_age*75)*kick,0)
 var state: String="idle"
 var progress:=0.0
 var facing:=1.0
 var velocity:=Vector2.ZERO
 if playing:
  action_age+=delta
  if skill=="sword":
   var duration:=float(spec.get("duration",.36))
   state="sword" if action_age<=duration else "idle"
   progress=clampf(action_age/duration,0,1)
   # Resolve the displayed contact pose before reading its socket, as gameplay does.
   rig.update_pose(0,state,1,Vector2.ZERO,true,progress,0,combo)
   if not emitted and progress>=float(spec.get("contact_progress",.3)):
    var family: String=["slash","slash_reverse","finisher","sweep"][combo-1]
    fx.spawn(family,rig.position+rig.socket("hand"),1)
    emitted=true
    _contact(roundi(float(spec.get("damage",35))*damage_multiplier))
   if action_age>duration+.12:
    if combo<4:
     combo+=1;action_age=0;emitted=false;spec=rig.get_attack_spec("sword",combo)
    else:playing=false
  elif skill=="dash":
   if action_age<.16:
    state="dash";progress=action_age/.16
    rig.position=HOME+Vector2(progress*60,0)
    velocity=Vector2(375,0)
    rig.update_pose(0,state,1,velocity,true,progress)
    _echo_left-=delta
    if _echo_left<=0:fx.rig_trail(rig);_echo_left=.035
    if not emitted:fx.burst("dash_start",HOME+Vector2(0,-32),1);emitted=true
   elif action_age<.48:
    rig.position=HOME+Vector2(60,0)
    if not _cast_sent:fx.spawn("step",rig.position,1);_cast_sent=true
   elif action_age<1.48:
    state="walk";facing=-1;velocity=Vector2(-60,0)
    rig.position=HOME+Vector2(60*(1-(action_age-.48)),0)
   else:
    rig.position=HOME;playing=false
  elif skill in ["tide","heal"]:
   if not emitted and action_age>=.18:
    fx.spawn("shockwave_ring" if skill=="tide" else "heal",rig.position+Vector2(0,-40 if skill=="tide" else -45),1)
    emitted=true
    if skill=="tide":_contact(85)
   if action_age>1.0:playing=false
 else:
  rig.position=HOME
  _rest+=delta
  if auto_replay and skill in ["sword","dash","tide","heal"] and _rest>2.4:replay()
 rig.update_pose(delta,state,facing,velocity,true,progress,0,combo)
