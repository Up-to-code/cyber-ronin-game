extends SceneTree
var failed:=false
var preview: Control
var screen: Control
func _initialize() -> void:call_deferred("run")
func check(value: bool,message: String) -> void:
 if not value:failed=true;push_error(message)
func step() -> void:
 preview._process(1.0/60)
 await process_frame
func capture(name: String) -> void:
 if DisplayServer.get_name()=="headless":return
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/tmp/armory-motion-"+name+".png")
func run() -> void:
 var model=load("res://systems/skill_inventory.gd").new()
 screen=load("res://ui/character_inventory.gd").new()
 screen.mode="skills";screen.setup(model,1250);root.add_child(screen)
 await process_frame;await process_frame
 preview=screen.preview;preview.set_process(false);preview.auto_replay=false
 var start_state: Dictionary=model.export_state().duplicate(true)
 screen.select_skill("dash")
 var previous: Vector2=preview.rig.position
 var max_step:=0.0
 for frame in range(110):
  await step()
  max_step=maxf(max_step,preview.rig.position.distance_to(previous))
  previous=preview.rig.position
  if frame==7:await capture("dash-burst")
  if frame==24:await capture("dash-brake")
  if frame==58:
   check(preview.rig.current_state=="walk" and preview.rig.current_facing<0,"Dash must return using authored walk cels")
   await capture("dash-return")
 check(max_step<7,"Dash must not snap back to its origin")
 check(preview.rig.position.distance_to(Vector2(142,173))<.01,"Dash must settle at home")
 screen.select_skill("sword")
 var contacts: int=preview.contact_count
 var clips: Dictionary={}
 var captured:=false
 for frame in range(230):
  await step()
  clips[preview.rig.current_clip]=true
  if not captured and preview.contact_count>contacts:
   await capture("sword-contact");captured=true
 check(preview.contact_count-contacts==4,"Sword demonstration must complete the real four-cut combo")
 for clip in ["sword1","sword2","sword3","sword4"]:check(clips.has(clip),"Missing actual gameplay clip: "+clip)
 check(Engine.time_scale==1.0,"Preview hit-stop must never change global game time")
 screen.select_skill("tide");await step()
 screen.select_skill("heal")
 check(not preview.target.visible,"Healing must not imply a hit against the training dummy")
 for frame in range(25):await step()
 check(model.export_state()==start_state and screen.wallet==1250,"Motion and VFX must remain free and isolated")
 screen.select_skill("tide");preview.auto_replay=true;preview.set_motion(false)
 var before: int=preview.replay_count
 for frame in range(240):await step()
 check(preview.replay_count>before,"Enabled loop must repeat complete demonstrations")
 screen.hide();await process_frame
 check(not preview.stage.enabled,"Hidden training scenery must stop moving")
 screen.queue_free();await process_frame
 root.get_node("Audio").shutdown()
 print("Armory motion: ","FAIL" if failed else "PASS"," — continuous dash, four cuts, contact feedback, safe cancellation, local hit-stop, free looping")
 quit(1 if failed else 0)
