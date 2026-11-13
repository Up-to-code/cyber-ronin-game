extends SceneTree
func _initialize():call_deferred("run")
func run():
 create_timer(180,true,false,true).timeout.connect(func():push_error("Gate audit timeout");quit(1))
 var scene=load("res://scenes/main.tscn").instantiate();root.add_child(scene);await process_frame
 scene.hud.settings_path="user://gate-audit-test.cfg"
 for number in range(1,101):
  scene._choose_level(number);await scene.level_loaded
  scene.player.invulnerable=999
  for wave in range(2):
   for enemy in get_nodes_in_group("enemies"):
    if enemy.health>0:enemy.take_damage(99999)
  for pickup in get_nodes_in_group("world_pickups"):
   if pickup.kind=="seal" and not pickup.taken:
    pickup.taken=true;pickup.collected.emit("seal",1,pickup.position);pickup.queue_free()
  for device in get_nodes_in_group("realm_devices"):
   if device.kind=="laser_seal":device.break_with_relic()
   elif device.kind=="cloud_anchor":scene.player.grant_relic("cloud");device.activate()
   elif device.kind=="portal" and scene.required_devices.has(device.device_id):device.activate()
  if number==11:scene.sequence_machine.phase="done";scene.sequence_machine.completed.emit()
  scene.player.position=scene.map.exit+Vector2(-100,0);scene.player.set_submerged(false)
  scene._check_gate()
  assert(scene._objectives_met(),"All authored requirements complete on%d"%number)
  await create_timer(.9,false).timeout
  assert(scene.gate_open,"Real gate animation must complete on%d"%number)
  print("PASS gate",number)
 DirAccess.remove_absolute(ProjectSettings.globalize_path(scene.hud.settings_path))
 root.get_node("Audio").shutdown();print("PASS100 native gate lifecycles after enemy/brood,pickup,device and cockpit completion");quit()
