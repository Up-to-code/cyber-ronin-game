extends SceneTree
func _initialize():
 create_timer(80).timeout.connect(func():quit(1))
 call_deferred("run")
func ticks(n:int):
 for i in range(n):await physics_frame;await process_frame
func jump_to(p,target:Vector2,width:float)->bool:
 await ticks(3)
 var side:float=signf(target.x-p.position.x)
 var action:String="move_right" if side>0 else "move_left"
 Input.action_press(action);Input.action_press("jump")
 for i in range(180):
  await ticks(1)
  if i==24:Input.action_release("jump")
  Input.action_release("move_down")
  if i>24 and i%5==0 and p.is_on_floor() and p.position.y<target.y-5:Input.action_press("move_down")
  if (target.x-p.position.x)*side<=p.velocity.x*p.velocity.x/6400:Input.action_release(action)
  if i>6 and p.is_on_floor() and absf(p.position.y-target.y)<4 and absf(p.position.x-target.x)<width/2-8:
   Input.action_release(action);Input.action_release("jump");Input.action_release("move_down");return true
 print("FAILED cloud target ",target," player ",p.position);Input.action_release(action);Input.action_release("jump");return false
func run():
 var scene=load("res://scenes/main.tscn").instantiate();root.add_child(scene);await process_frame
 for chapter in range(10):
  for slot in [4,5,7]:
   var number:int=chapter*10+slot
   scene._choose_level(number);await scene.level_loaded
   for enemy in get_nodes_in_group("enemies"):enemy.queue_free()
   var p=scene.player;p.invulnerable=999
   var devices=get_nodes_in_group("realm_devices")
   var first=devices[0];var second=devices[1]
   p.position=Vector2(first.position.x,first.position.y+(35 if slot!=5 else 0));p.velocity=Vector2.ZERO
   await ticks(8)
   if slot==4:
    assert(p.relic_charges.laser==1)
    p.facing=1;Input.action_press("energy_attack");await ticks(2);Input.action_release("energy_attack");await ticks(55)
    assert(second.solved,"Laser must hit seal from earned pickup position")
   elif slot==7:
    assert(p.relic_charges.cloud==1 and scene.seals_left==1)
    Input.action_press("move_right")
    for i in range(100):
     await ticks(1)
     if p.position.x>=second.position.x-20:break
    Input.action_release("move_right");await ticks(8)
    Input.action_press("interact");await ticks(2);Input.action_release("interact");await ticks(3)
    assert(second.solved and second.platforms.size()==2)
    assert(scene.seals_left==1,"Activating loom alone must not collect the required vow")
    for bridge in second.platforms:assert(await jump_to(p,bridge.position,bridge.width),"Earned cloud landings must be physically traversable")
    await ticks(4)
    assert(scene.seals_left==0,"Outer cloud traversal must collect required vow")
   else:
    Input.action_press("interact");await ticks(2);Input.action_release("interact");await ticks(8)
    assert(scene.active_realm=="underworld")
    var arrival:Dictionary=scene.map.platforms[-2]
    assert(p.is_on_floor() and absf(p.position.y-arrival.center.y)<4)
    # Walk to arrival edge then physically jump to the return engine.
    Input.action_press("move_right")
    for i in range(100):
     await ticks(1)
     if p.position.x>=arrival.center.x+arrival.width/2-40:break
    Input.action_release("move_right");await ticks(8)
    assert(await jump_to(p,second.position,220),"Pocket return platform must be reachable")
    Input.action_press("interact");await ticks(2);Input.action_release("interact");await ticks(8)
    assert(scene.active_realm=="surface")
   print("PASS physical device route ",number)
 root.get_node("Audio").shutdown();print("PASS 10 laser seals, 20 cloud jumps, 10 portal roundtrips with physical return traversal");quit()
