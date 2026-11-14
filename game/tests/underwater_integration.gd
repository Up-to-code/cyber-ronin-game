extends SceneTree
func _initialize():call_deferred("run")
func tick():await physics_frame;await process_frame
func release():
 for action in ["move_left","move_right","move_up","move_down","jump"]:Input.action_release(action)
func run():
 create_timer(90,true,false,true).timeout.connect(func():push_error("Underwater integration timeout");quit(1))
 var scene=load("res://scenes/main.tscn").instantiate();root.add_child(scene);await process_frame
 scene._choose_level(8);await scene.level_loaded
 var p=scene.player;p.invulnerable=999
 for enemy in get_nodes_in_group("enemies"):enemy.queue_free()
 # Walk off dry entry; no teleport between swim itinerary points.
 Input.action_press("move_right")
 for i in range(150):
  await tick()
  if p.submerged:break
 release();assert(p.submerged,"Walking off pier enters water")
 var waypoints=scene.map.swim_waypoints.duplicate()
 waypoints.append([3020,315])
 for index in range(waypoints.size()):
  var goal=Vector2(waypoints[index][0],waypoints[index][1])
  var arrived=false
  for i in range(900):
   var offset:Vector2=goal-p.position
   release()
   if offset.length()<36:arrived=true;break
   if absf(offset.x)>14:Input.action_press("move_right" if offset.x>0 else "move_left")
   if absf(offset.y)>14:Input.action_press("move_down" if offset.y>0 else "move_up")
   await tick()
  assert(arrived,"Continuous swim waypoint%d failed at%s target%s"%[index,p.position,goal])
  print("PASS swim waypoint",index," ",p.position)
 release()
 for i in range(90):await tick()
 assert(scene.seals_left==0,"Collect all3 chamber pearls")
 assert(not p.submerged and p.is_on_floor(),"Return to dry platform with normal grounding")
 assert(scene._objectives_met(),"Escape requires pearls and surfacing, not killing all wildlife")
 scene.retry_game();await scene.level_loaded
 assert(not p.submerged and scene.seals_left==3)
 p.position=Vector2(700,600);await tick();await tick()
 assert(p.submerged)
 var count=get_nodes_in_group("combat_projectiles").size()
 scene._spawn_projectile("fire",p.position,Vector2.RIGHT,p)
 assert(get_nodes_in_group("combat_projectiles").size()==count,"Fire extinguished in volume")
 scene._spawn_projectile("water",p.position,Vector2.RIGHT,p)
 assert(get_nodes_in_group("combat_projectiles").size()==count+1)
 scene._choose_level(1);await scene.level_loaded
 assert(not p.submerged and p.swim_current==Vector2.ZERO)
 root.get_node("Audio").shutdown();print("PASS underwater entry,3 pearls,whirlpool navigation,dry escape,retry,fire quench,water pulse,land reset");quit()
