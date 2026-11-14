extends SceneTree
func _initialize():call_deferred("run")
func run():
 root.size=Vector2i(1152,648)
 var background:=ColorRect.new();background.color=Color("221622");background.size=Vector2(640,360);root.add_child(background)
 var records: Array=JSON.parse_string(FileAccess.get_file_as_string("res://data/monster_choreography.json"))
 for i in range(3):
  var actor=load("res://actors/enemy_2d.gd").new();actor.position=Vector2(130+i*190,235);root.add_child(actor);actor.set_physics_process(false);actor.apply_monster_profile(2);actor.facing=1
  actor.motion_visual.configure(actor,records[1].motion)
  actor.windup_duration=records[1].motion.windup;actor.strike_duration=records[1].motion.commit
  if i==0:actor.windup=actor.windup_duration*.4
  elif i==1:actor.strike_left=actor.strike_duration*.5
  else:actor.recovery=records[1].motion.recovery*.7
  actor._update_rig(.016)
 for i in range(4):await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://../docs/qa/wolf-attack-poses-native.png")
 root.get_node("Audio").shutdown();quit()
