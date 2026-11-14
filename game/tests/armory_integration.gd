extends SceneTree
func _initialize():call_deferred("run")
func run():
 create_timer(20,true,false,true).timeout.connect(func():push_error("Armory test timeout");quit(1))
 var scene=load("res://scenes/main.tscn").instantiate();root.add_child(scene);await process_frame
 scene.hud.settings_path="user://armory-test.cfg"
 scene.skill_inventory.load_state({});scene.coins=1000;scene.banked_coins=1000
 scene._choose_level(4);await scene.level_loaded
 var key=InputEventKey.new();key.keycode=KEY_B;key.physical_keycode=KEY_B;key.pressed=true;Input.parse_input_event(key);await process_frame
 assert(paused and scene.inventory_screen.visible)
 scene._purchase_skill("sword");assert(scene.coins==820 and scene.player.sword_damage_multiplier==1.15)
 scene._purchase_skill("vitality");assert(scene.coins==600 and scene.player.max_health==120)
 scene._purchase_skill("tide");assert(scene.coins==440 and scene.skill_inventory.charges.tide==3)
 scene._purchase_skill("tide");assert(scene.coins==440)
 var saved=ConfigFile.new();assert(saved.load(scene.hud.settings_path)==OK)
 assert(saved.get_value("progress","coins")==440 and saved.get_value("skills","state").charges.tide==3)
 var back=InputEventKey.new();back.keycode=KEY_ESCAPE;back.pressed=true;Input.parse_input_event(back);await process_frame
 assert(not paused and not scene.inventory_screen.visible)
 assert(scene.player.use_inventory_skill("tide"));assert(scene.skill_inventory.charges.tide==2)
 saved.load(scene.hud.settings_path);assert(saved.get_value("skills","state").charges.tide==2)
 scene.retry_game();await scene.level_loaded
 assert(scene.coins==440 and scene.player.health==120 and scene.skill_inventory.charges.tide==2)
 for enemy in get_nodes_in_group("enemies"):enemy.take_damage(99999)
 assert(not scene._objectives_met())
 scene._refresh_guide()
 assert("Sun Core" in scene.objective_guide.instruction.text)
 assert("TAKE SUN CORE" in scene.objective_guide.target_line.text)
 for device in get_nodes_in_group("realm_devices"):
  if device.kind=="laser_seal":device.break_with_relic()
 assert(scene._objectives_met())
 await create_timer(1).timeout
 assert(scene.gate_open)
 DirAccess.remove_absolute(ProjectSettings.globalize_path(scene.hud.settings_path))
 root.get_node("Audio").shutdown();print("PASS armory pause, purchase/wallet atomic save, upgrade application, charge persistence and level4 guide-to-open-gate");quit()
