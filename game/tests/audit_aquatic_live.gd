extends SceneTree
func _initialize():call_deferred("run")
func run():
 var victim=load("res://actors/player_2d.gd").new();root.add_child(victim);victim.set_physics_process(false)
 for role in ["jelly","eel","crab"]:
  var enemy=load("res://actors/enemy_2d.gd").new();enemy.swimming=true;enemy.swim_role=role;enemy.swim_bounds=Rect2(0,0,800,600);enemy.position=Vector2(180,240);root.add_child(enemy)
  enemy.apply_monster_profile(81 if role=="jelly" else (46 if role=="eel" else 35));enemy.target=victim
  var evidence={"starts":0,"contacts":0}
  enemy.contract.action_started.connect(func(_a,_b):evidence.starts+=1)
  enemy.contract.damage_contact.connect(func(_a,_b,_c):evidence.contacts+=1)
  for i in range(360):
   victim.position=Vector2(330,360);victim.health=10000;victim.invulnerable=0
   await physics_frame;await process_frame
  print(role," ",evidence," attacks=",enemy.attack_count)
  enemy.queue_free();await process_frame
 root.get_node("Audio").shutdown();quit()
