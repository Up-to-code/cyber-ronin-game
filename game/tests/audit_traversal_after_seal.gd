extends SceneTree
func _initialize():call_deferred("run")
func ticks(n: int):
 for i in range(n):await physics_frame;await process_frame
func release():
 for a in ["move_left","move_right","jump","move_down"]:Input.action_release(a)
func run():
 var scene=load("res://scenes/main.tscn").instantiate();root.add_child(scene);await process_frame
 var total:=0
 var samples: Array[int]=[]
 for index in range(1,101):
  if index!=8:samples.append(index) # Flooded palace uses the separate swim integration test.
 for argument in OS.get_cmdline_user_args():
  if argument.begins_with("--levels="):
   samples.clear()
   for value in argument.trim_prefix("--levels=").split(","):samples.append(int(value))
 for number in samples:
  scene._choose_level(number);await scene.level_loaded
  for enemy in get_nodes_in_group("enemies"):enemy.queue_free()
  for device in get_nodes_in_group("realm_devices"):
   if device.kind=="laser_seal":device.break_with_relic()
  var p=scene.player;p.invulnerable=999
  var route: Array=scene.map.platforms.filter(func(s):return s.route)
  await ticks(8)
  for i in range(route.size()-1):
   var a: Dictionary=route[i];var b: Dictionary=route[i+1]
   var side: float=signf(b.center.x-a.center.x)
   var action: String="move_right" if side>0 else "move_left"
   var overlap: bool=absf(b.center.x-a.center.x)<(a.width+b.width)*0.5
   # Walk to the takeoff edge on wide platforms. No teleport between jumps.
   var launch: float=a.center.x+side*(a.width/2-32)
   if overlap:launch=clampf(b.center.x,a.center.x-a.width/2+35,a.center.x+a.width/2-35)
   for tick in range(200):
    if (launch-p.position.x)*side<=12:break
    if not Input.is_action_pressed(action):Input.action_press(action)
    await ticks(1)
   if not Input.is_action_pressed(action):Input.action_press(action)
   Input.action_press("jump")
   var target_x: float=b.center.x-side*(b.width/2-65)
   if overlap:target_x=b.center.x
   var landed:=false
   for tick in range(180):
    await ticks(1)
    if tick==24:Input.action_release("jump")
    Input.action_release("move_down")
    if tick>24 and tick%5==0 and p.is_on_floor() and p.position.y<b.center.y-5:Input.action_press("move_down")
    var stop: float=p.velocity.x*p.velocity.x/(2*3200)
    if (target_x-p.position.x)*side<=stop:Input.action_release(action)

    if tick>6 and p.is_on_floor() and absf(p.position.y-b.center.y)<4 and absf(p.position.x-b.center.x)<b.width/2-8:
     landed=true;break
   release()
   if not landed:
    push_error("Sequential level%d transition%d %s -> %s failed player%s"%[number,i,a.center,b.center,p.position]);quit(1);return
   total+=1
  print("PASS continuous route ",number," ",scene.map.traversal)
 root.get_node("Audio").shutdown();print("PASS ",total," continuous transitions across ",samples.size()," representative directed routes, no between-jump resets");quit()
