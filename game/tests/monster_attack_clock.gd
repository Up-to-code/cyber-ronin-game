extends SceneTree
func _initialize():call_deferred("run")
func ticks(n: int):
 for i in range(n):await physics_frame;await process_frame
func run():
 create_timer(15,true,false,true).timeout.connect(func():quit(1))
 var floor:=StaticBody2D.new();floor.position=Vector2(600,500)
 var col:=CollisionShape2D.new();var shape:=RectangleShape2D.new();shape.size=Vector2(2000,40);col.shape=shape;col.position.y=20;floor.add_child(col);root.add_child(floor)
 var player=load("res://actors/player_2d.gd").new();player.position=Vector2(600,500);root.add_child(player);player.set_physics_process(false);player.health=1000
 var enemy=load("res://actors/enemy_2d.gd").new();enemy.position=Vector2(400,500);enemy.target=player;root.add_child(enemy);enemy.apply_monster_profile(2);enemy.cooldown=0
 var contacts: Array=[]
 enemy.contract.damage_contact.connect(func(id,event,hit):contacts.append({"time":enemy.contract.current_action_time,"phase":enemy.contract.current_action_phase}))
 var frames:=0
 while not enemy.contract.action_active and frames<80:await ticks(1);frames+=1
 assert(enemy.contract.action_active,"Actual AI must initiate choreography")
 assert(enemy.windup>0 and enemy.strike_left==0,"Tell begins before contact")
 var moved:=false
 while contacts.is_empty() and frames<180:
  await ticks(1);frames+=1
  if absf(enemy.velocity.x)>20:moved=true
 assert(not contacts.is_empty())
 var row: Dictionary=enemy.contract.get_choreography()
 var expected: float=row.events[0].at+row.events[0].tell+row.events[0].travel
 assert(absf(float(contacts[0].time)-expected)<.05,"Damage uses single choreography time")
 assert(contacts[0].phase=="commit","First hit coincides with visible commit")
 assert(moved,"Commit must move the actual enemy body")
 enemy.receive_hit(1,"kick",-1,enemy.position)
 assert(not enemy.contract.action_active and enemy.contract.marks.is_empty(),"Hit interruption cancels pending attacks")
 root.get_node("Audio").shutdown()
 print("PASS: actual AI starts tell, single-clock contact during commit, physical lunge, interrupted timeline clears")
 quit()
