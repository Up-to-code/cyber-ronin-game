extends SceneTree
func _initialize():call_deferred("run")
func run():
 var player=load("res://actors/player_2d.gd").new();player.position=Vector2(200,600);root.add_child(player);player.set_physics_process(false)
 for id in [4,5,6,10]:
  var enemy=load("res://actors/enemy_2d.gd").new();enemy.enemy_kind="guard";enemy.position=Vector2(100,600);enemy.target=player;root.add_child(enemy);enemy.set_physics_process(false);enemy.apply_monster_profile(id)
  var shots: Array[String]=[]
  enemy.projectile_requested.connect(func(kind: String,_at: Vector2,_direction: Vector2,_source: Node):shots.append(kind))
  enemy.windup=0;enemy.strike_duration=0.5;enemy.strike_left=0.3;enemy.strike_contact=0.4;enemy.strike_hit=false
  enemy._physics_process(0.01)
  if id==4:assert(shots.size()==5 and shots[0]=="fire")
  if id==5 or id==10:assert(shots==["laser"])
  if id==6:assert(shots==["fire","fire"])
  if id==10:
   shots.clear();enemy.strike_left=0.3;enemy.strike_hit=false;enemy._physics_process(0.01)
   assert(shots==["fire","fire"],"Warcaller alternates beam and quake")
  enemy.free()
 player.free()
 root.get_node("Audio").shutdown()
 print("PASS: roster fan five shots, laser, bilateral quake, alternating warcaller attacks")
 quit()
