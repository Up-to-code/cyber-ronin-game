extends SceneTree
func _initialize():call_deferred("run")
func tick():await physics_frame;await process_frame
func run():
 create_timer(600,true,false,true).timeout.connect(func():push_error("Individual contract timeout");quit(1))
 var p=load("res://actors/player_2d.gd").new();root.add_child(p);p.set_physics_process(false)
 var paths:Dictionary={};var names:Dictionary={}
 for id in range(1,101):
  var enemy=load("res://actors/enemy_2d.gd").new();enemy.position=Vector2(500,600);enemy.target=p;enemy.is_boss=id%10==0;root.add_child(enemy);enemy.set_physics_process(false);enemy.apply_monster_profile(id)
  if enemy.is_boss:enemy.health=int(enemy.max_health*.4)
  p.position=Vector2(650,600);p.health=10000;p.invulnerable=0
  var contract=enemy.contract;var spec=contract.get_choreography();names[spec.move]=true
  assert(ResourceLoader.exists(spec.motif_texture))
  contract.cast();assert(not contract.marks.is_empty() and contract.marks.size()<=12)
  var first=contract.marks[0]
  p.position=first.at+Vector2(0,45)
  var earliest=INF
  for mark in contract.marks:
   paths[mark.event.path]=true
   earliest=minf(earliest,float(mark.event.at)+float(mark.event.tell))
   assert(mark.contact_at+mark.life<=contract.current_action_duration+.001)
  for i in range(maxi(0,floori(earliest*60)-2)):await tick()
  assert(p.health==10000,"No damage before tell for%d"%id)
  for i in range(ceili(contract.current_action_duration*60)+5):await tick()
  assert(p.health<10000,"Real contact must damage stationary endpoint victim for%d"%id)
  assert(not contract.action_active and contract.marks.is_empty())
  enemy.queue_free();await tick()
 assert(names.size()==100 and paths.size()==17)
 root.get_node("Audio").shutdown();await process_frame
 print("PASS100 individual moves/assets,17 delivery paths,pre-tell safety,actual damage,late boss events and cleanup");quit()
