extends SceneTree
func _initialize():call_deferred("run")
func run():
 var scene=load("res://scenes/main.tscn").instantiate();root.add_child(scene);await process_frame
 scene._choose_level(5);await scene.level_loaded
 var health=scene.player.health
 var origin=scene.player.position
 scene._enter_realm("underworld")
 assert(scene.active_realm=="underworld")
 assert(scene.player.position.distance_to(origin)>500)
 assert(scene.player.health==health)
 assert(scene.snow_field.biome=="underground")
 scene._enter_realm("surface")
 assert(scene.active_realm=="surface")
 assert(scene.player.health==health)
 scene._choose_level(4);await scene.level_loaded
 assert(not scene.required_devices.is_empty())
 scene.remaining=0;scene.seals_left=0;scene.marked_left=0
 assert(not scene._objectives_met())
 for device in get_nodes_in_group("realm_devices"):
  if device.kind=="laser_seal":device.break_with_relic()
 assert(scene.required_devices.is_empty())
 assert(scene._objectives_met())
 scene.retry_game();await scene.level_loaded
 assert(not scene.required_devices.is_empty())
 root.get_node("Audio").shutdown();print("PASS portal round trip, state preservation, required relic seal and retry reset");quit()
