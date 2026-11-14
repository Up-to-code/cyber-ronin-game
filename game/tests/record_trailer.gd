extends SceneTree
## Deterministic input-driven footage from real game scenes, physics and audio.
var scene: Node
var cues: Array = []
func _initialize() -> void: call_deferred("run")
func ticks(count: int) -> void:
 for i in range(count):
  await physics_frame
  await process_frame
func release_inputs() -> void:
 for action in InputMap.get_actions():Input.action_release(action)
func run() -> void:
 scene=load("res://scenes/main.tscn").instantiate()
 root.add_child(scene)
 await process_frame
 if scene.transitioning:await scene.level_loaded
 scene.main_menu()
 var audio=root.get_node("Audio")
 audio.set_enabled(true)
 AudioServer.set_bus_volume_db(0,0)
 audio.cue_triggered.connect(func(cue):cues.append(cue))
 # First title and atlas; progress is local to this capture, never saved.
 scene.hud.max_unlocked=100
 await ticks(90)
 scene.hud._push("maps")
 await ticks(90)
 for number in [1,3,7,10]:
  release_inputs()
  scene._choose_level(number)
  await scene.level_loaded
  scene.player.invulnerable=999
  scene.hud.touch.hide()
  audio.set_enabled(true)
  var guard=load("res://actors/enemy_2d.gd").new()
  guard.enemy_kind="guard"
  guard.position=scene.player.position+Vector2(70,0)
  guard.target=scene.player
  guard.fx_requested.connect(scene._enemy_fx)
  scene.level_root.add_child(guard)
  guard.health=150
  guard.configure_health_display()
  guard.set_physics_process(false)
  scene.player.facing=1
  for frame in range(420):
   match frame:
    5:pass
    18:pass
    25,48,71,94:Input.action_press("attack")
    26,49,72,95:Input.action_release("attack")
    122:Input.action_press("kick")
    123:Input.action_release("kick")
    155:
     Input.action_press("move_right")
     Input.action_press("jump")
    170:Input.action_release("jump")
    180:Input.action_press("jump")
    190:Input.action_release("jump")
    220:Input.action_release("move_right")
    245:Input.action_press("energy_attack")
    246:Input.action_release("energy_attack")
    295:Input.action_press("ranged_attack")
    296:Input.action_release("ranged_attack")
    335:Input.action_press("jump")
    350:Input.action_release("jump")
    360:Input.action_press("attack")
    361:Input.action_release("attack")
   await ticks(1)
  root.get_texture().get_image().save_png("/tmp/redesign-trailer-map-%d.png"%number)
 release_inputs()
 scene.main_menu()
 await ticks(90)
 FileAccess.open("/tmp/redesign-trailer-cues.json",FileAccess.WRITE).store_string(JSON.stringify(cues))
 audio.shutdown()
 quit()
