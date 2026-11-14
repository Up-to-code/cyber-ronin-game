extends SceneTree
func _initialize():call_deferred("run")
func run():
 # Authored route placement changes independently of supported signature rules.
 var modes := ["echo","tether","glass","garden"]
 for map in preload("res://data/campaign.gd").levels():
  for guard in map.enemies:
   if guard.has("signature"): assert(guard.signature in modes)
 var p=load("res://actors/player_2d.gd").new();root.add_child(p);p.set_physics_process(false);p.position=Vector2(200,500)
 var enemy=load("res://actors/enemy_2d.gd").new();root.add_child(enemy);enemy.set_physics_process(false);enemy.position=Vector2(300,500);enemy.target=p
 for mode in ["echo","tether","glass","garden"]:
  enemy.configure_signature(mode)
  var rule=enemy.get_children().filter(func(n):return n.get_script()==load("res://systems/signature_encounter.gd")).back()
  rule.set_physics_process(false);rule.clock=0
  if mode=="echo":
   p.attack_time=.3;rule._physics_process(.01);assert(rule.marks.size()==1)
   p.position.x+=150;p.invulnerable=0;rule._physics_process(.9);assert(p.health==100,"Moving escapes the delayed copy")
   p.position.x-=150;p.attack_time=0
  if mode=="tether":
   rule._physics_process(.01);assert(rule.tether_left>0)
   p.dodge_time=.1;rule._physics_process(.01);assert(rule.tether_left==0,"Dash cuts tether")
   p.dodge_time=0
  if mode=="glass":
   enemy.health=100;enemy.recovery=0
   enemy.receive_hit(20,"sword",1,enemy.position);assert(enemy.health==100)
   enemy.receive_hit(20,"kick",1,enemy.position);assert(enemy.health==80 and enemy.recovery>0)
   enemy.receive_hit(20,"sword",1,enemy.position);assert(enemy.health==60)
  if mode=="garden":
   rule.marks.append({"at":p.position,"left":0.7,"life":7.0,"armed":false})
   rule.clock=99;rule._physics_process(.01);assert(rule.marks[0].armed)
   p.position.y-=90;p.invulnerable=0;rule._physics_process(.8);assert(p.health==100,"Jumping clears ground bloom")
  rule.free()
 enemy.free();p.free();root.get_node("Audio").shutdown()
 print("PASS four supported signature fixtures, echo escape, tether dash counter, glass guard break, mine jump counter")
 quit()
