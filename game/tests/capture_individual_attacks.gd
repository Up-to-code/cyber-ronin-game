extends SceneTree
func _initialize():call_deferred("run")
func run():
 var scene=load("res://scenes/main.tscn").instantiate();root.add_child(scene);await process_frame
 scene._choose_level(1);await scene.level_loaded
 scene.hud.gameplay.hide()
 scene.welcome_layer.hide();scene.set_process(false);scene.camera.position=Vector2(620,385);scene.camera.zoom=Vector2(.85,.85)
 scene._layout_background(scene.get_viewport_rect().size,Vector2.ZERO)
 for enemy in get_nodes_in_group("enemies"):enemy.queue_free()
 var floor=StaticBody2D.new();floor.position=Vector2(700,500);var col=CollisionShape2D.new();var shape=RectangleShape2D.new();shape.size=Vector2(1400,60);col.shape=shape;col.position.y=30;floor.add_child(col);floor.set_meta("deck_depth",48);floor.set_meta("construction","rock");scene._decorate_platform(floor,1400);scene.level_root.add_child(floor)
 var label=Label.new();label.add_theme_font_override("font",load("res://art/pixel/PixelifySans.ttf"));label.add_theme_font_size_override("font_size",14);label.position=Vector2(18,18);scene.hud.add_child(label)
 var p=scene.player;p.position=Vector2(700,500);p.set_physics_process(false);p.health=10000
 var subjects=[1,2,3,4,10,12,25,50,81,100]
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--focus-monster="):subjects=[int(arg.trim_prefix("--focus-monster="))]
 for id in subjects:
  var spec=preload("res://data/monster_roster.gd").get_monster(id)
  var enemy=load("res://actors/enemy_2d.gd").new();enemy.enemy_kind=spec.kind;enemy.position=Vector2(520,500);enemy.target=p;enemy.is_boss=id%10==0;scene.level_root.add_child(enemy);enemy.apply_monster_profile(id)
  var record=enemy.contract.get_choreography();label.text="%03d · %s\n%s"%[id,spec.name,record.move]
  enemy.fx_requested.connect(scene._enemy_fx)
  scene.camera_initialized=false
  var captured={}
  for i in range(210):
   p.position=Vector2(700,500);p.health=10000;p.invulnerable=0
   await physics_frame;await process_frame
   if enemy.contract.action_active:
    var phase=enemy.contract.current_action_phase
    if phase in ["tell","commit","recovery"] and not captured.has(phase):
     captured[phase]=true
     await RenderingServer.frame_post_draw
     root.get_texture().get_image().save_png("res://../docs/qa/individual-%03d-%s.png"%[id,phase])
  enemy.queue_free();await process_frame
 label.queue_free();root.get_node("Audio").shutdown();await create_timer(.15).timeout;quit()
