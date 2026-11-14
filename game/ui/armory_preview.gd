extends Control
## A private, transparent world sharing the gameplay cel rig, attack spec and VFX renderer.
## No Player2D, enemy groups, input actions, wallet or consumable model live here.
const Rig = preload("res://animation/cel_actor_visual.gd")
const Fx = preload("res://systems/pixel_fx.gd")
var summary: Label
var viewport: SubViewport
var rig: Node2D
var fx: Node2D
var skill := "tide"
var age := 0.0
var action_age := 0.0
var emitted := false
var playing := false
var replay_count := 0
var combo := 1
var spec: Dictionary = {}
var _echo_left := 0.0
var _host: SubViewportContainer
func _ready() -> void:
 process_mode=Node.PROCESS_MODE_ALWAYS
 mouse_filter=Control.MOUSE_FILTER_IGNORE
 clip_contents=true
 _host=SubViewportContainer.new()
 _host.mouse_filter=Control.MOUSE_FILTER_IGNORE
 _host.stretch=true
 _host.stretch_shrink=3
 _host.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 add_child(_host)
 _host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 viewport=SubViewport.new()
 viewport.transparent_bg=true
 viewport.world_2d=World2D.new()
 viewport.handle_input_locally=false
 viewport.gui_disable_input=true
 viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
 _host.add_child(viewport)
 rig=Rig.new()
 viewport.add_child(rig)
 rig.position=Vector2(142,173)
 fx=Fx.new()
 viewport.add_child(fx)
 summary=Label.new()
 summary.mouse_filter=Control.MOUSE_FILTER_IGNORE
 summary.add_theme_font_override("font",preload("res://ui/armory_art.gd").font())
 summary.add_theme_font_size_override("font_size",30)
 summary.add_theme_color_override("font_color",Color("ffe4b5"))
 summary.add_theme_color_override("font_shadow_color",Color("080e1b"))
 summary.add_theme_constant_override("shadow_offset_y",2)
 summary.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 summary.position=Vector2(90,0)
 summary.size=Vector2(650,50)
 add_child(summary)
 visibility_changed.connect(_visibility)
 replay()
func _visibility() -> void:
 if viewport!=null:
  viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS if is_visible_in_tree() else SubViewport.UPDATE_DISABLED
func set_character_profile(profile: String) -> void:
 if rig!=null:
  rig.configure(profile)
  replay()
func play_skill(id: String) -> void:
 skill=id
 if is_node_ready():replay()
func replay() -> void:
 if not is_instance_valid(rig):return
 for effect in fx.get_children():
  fx.remove_child(effect)
  effect.queue_free()
 action_age=0
 combo=1
 emitted=false
 playing=skill not in ["locked","vitality","gear_blade","gear_armor","gear_bracers","gear_boots"]
 replay_count+=1
 _echo_left=0
 spec=rig.get_attack_spec("sword",combo)
 rig.update_pose(0,"idle",1,Vector2.ZERO,true)
func _process(delta: float) -> void:
 if not is_visible_in_tree() or not is_instance_valid(rig):return
 age+=delta
 rig.position=Vector2(142,173)
 var state: String="idle"
 var progress:=0.0
 if playing:
  action_age+=delta
  if skill=="sword":
   var duration:=float(spec.get("duration",.36))
   state="sword" if action_age<=duration else "idle"
   progress=clampf(action_age/duration,0,1)
   if not emitted and progress>=float(spec.get("contact_progress",.3)):
    fx.spawn("slash_reverse" if combo==2 else ("finisher" if combo>=3 else "slash"),rig.position+Vector2(38,-45),1)
    emitted=true
   if action_age>duration+.38:
    if combo<3:
     combo+=1;action_age=0;emitted=false;spec=rig.get_attack_spec("sword",combo)
    else:playing=false
  elif skill=="dash":
   if action_age<.16:
    state="dash"
    progress=action_age/.16
    rig.position.x=112+progress*60
    _echo_left-=delta
    if _echo_left<=0:
     fx.rig_trail(rig)
     _echo_left=.035
    if not emitted:
     fx.burst("dash_start",rig.position+Vector2(0,-32),1)
     emitted=true
   elif action_age>.8:playing=false
  elif skill in ["tide","heal"]:
   if not emitted and action_age>=.18:
    fx.spawn("shockwave_ring" if skill=="tide" else "heal",rig.position+Vector2(0,-40 if skill=="tide" else -45),1)
    emitted=true
   if action_age>1.0:playing=false
 rig.update_pose(delta,state,1,Vector2(600,0) if state=="dash" else Vector2.ZERO,true,progress,0,combo)
