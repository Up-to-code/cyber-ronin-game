extends SceneTree
func _initialize():call_deferred("run")
func run():
 var floor=StaticBody2D.new();var col=CollisionShape2D.new();var rect=RectangleShape2D.new();rect.size=Vector2(3000,60);col.shape=rect;col.position.y=30;floor.add_child(col);root.add_child(floor);await physics_frame
 var count:=0
 for id in range(1,26 if "--first25" in OS.get_cmdline_user_args() else 101):
  if not FileAccess.file_exists("res://art/monster-cels/%03d.json"%id):
   assert("--available-only" in OS.get_cmdline_user_args(),"Missing creature motion %d"%id);continue
  var enemy=load("res://actors/enemy_2d.gd").new();root.add_child(enemy);enemy.set_physics_process(false);enemy.apply_monster_profile(id)
  enemy.velocity=Vector2(0,20);enemy.move_and_slide()
  assert(enemy.is_on_floor())
  var motion=enemy.motion_visual
  assert(motion.get_script().resource_path.ends_with("monster_cel_motion.gd"))
  assert(motion.frames.size()==12)
  var collider_size:float=enemy.body_collider.shape.height
  for face in [-1.0,1.0]:
   enemy.facing=face;enemy.velocity=Vector2(face*90,0);enemy.health=100;enemy.hurt_left=0;enemy.windup=0;enemy.strike_left=0;enemy.recovery=0
   var seen:Dictionary={}
   for t in [.125,.375,.625,.875]:
    motion.gait=t;motion.tick(0);seen[motion.frame_index]=true
    assert(motion.sprite.flip_h==(face<0));assert(not enemy.rig.sprite.visible)
    assert(enemy.body_collider.shape.height==collider_size)
   assert(seen.size()==4,"Distinct locomotion frames must reach renderer")
   enemy.windup_duration=1;enemy.windup=.5;motion.tick(0);assert(motion.frame_index==motion.manifest.clips.attack[0])
   enemy.windup=0;enemy.strike_duration=1;enemy.strike_left=.8;motion.tick(0);assert(motion.frame_index==motion.manifest.clips.attack[1])
   enemy.strike_left=.1;motion.tick(0);assert(motion.frame_index==motion.manifest.clips.attack[2])
   enemy.strike_left=0;enemy.recovery=.2;motion.tick(0);assert(motion.frame_index==motion.manifest.clips.attack[3])
   enemy.recovery=0;enemy.hurt_left=.2;enemy.hit_reaction=.8;motion.tick(0);assert(motion.frame_index==8)
   enemy.hit_reaction=.1;motion.tick(0);assert(motion.frame_index==9)
   var snapshot=enemy.rig.create_snapshot();assert(snapshot.get_child(0).texture==motion.sprite.texture);snapshot.free()
  enemy.health=0;enemy.death_elapsed=0;motion.tick(0);assert(motion.frame_index==10)
  enemy.death_elapsed=.6;motion.tick(0);assert(motion.frame_index==11 and not enemy.rig.sprite.visible)
  enemy.death_elapsed=1.28;motion.tick(0);assert(motion.modulate.a==0)
  enemy.free();count+=1
 root.get_node("Audio").shutdown();print("PASS actual drawn animation state/facing/snapshot/death paths for ",count," currently installed creatures");quit()
