extends SceneTree
func _initialize():call_deferred("run")
func run():
 var scene=load("res://scenes/main.tscn").instantiate();root.add_child(scene);await process_frame
 for number in [2,3,10,50,100]:
  scene._choose_level(number);await scene.level_loaded
  scene.player.invulnerable=999
  var enemies=get_nodes_in_group("enemies")
  if not enemies.is_empty():scene.player.position=enemies.back().position+Vector2(-90,0)
  scene.camera_initialized=false
  var times: Array[float]=[]
  var last=Time.get_ticks_usec()
  for i in range(240):
   if i%45==0:
    for enemy in enemies:
     if is_instance_valid(enemy) and enemy.health>0:enemy.contract.cast()
   if i%20==0:scene.fx.burst("blood",scene.player.position+Vector2(60,-40),1)
   await process_frame
   var now=Time.get_ticks_usec()
   if i>60:times.append((now-last)/1000.0)
   last=now
  times.sort()
  print("FRAME SAMPLE level%d median %.2fms p95 %.2fms drawcalls%d nodes%d"%[number,times[times.size()/2],times[int(times.size()*.95)],Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),Performance.get_monitor(Performance.OBJECT_NODE_COUNT)])
 root.get_node("Audio").shutdown();quit()
