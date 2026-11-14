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
 var subjects=range(1,101)
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--focus-monster="):subjects=[int(arg.trim_prefix("--focus-monster="))]
 for id in subjects:
  var spec=preload("res://data/monster_roster.gd").get_monster(id)
  var enemy=load("res://actors/enemy_2d.gd").new();enemy.enemy_kind=spec.kind;enemy.position=Vector2(520,500);enemy.target=p;enemy.is_boss=id%10==0;scene.level_root.add_child(enemy);enemy.apply_monster_profile(id)
  var record=enemy.contract.get_choreography();label.text="%03d · %s\n%s"%[id,spec.name,record.move]
  enemy.set_physics_process(false)
  enemy.velocity=Vector2(0,20);enemy.move_and_slide()
  enemy.health_display.hide()
  var sheet:=Image.create(1200,780,false,Image.FORMAT_RGBA8)
  for index in range(12):
   enemy.health=100;enemy.hurt_left=0;enemy.windup=0;enemy.strike_left=0;enemy.recovery=0;enemy.velocity=Vector2(90,0)
   enemy.motion_visual.gait=(float(index)+.5)/4
   if index==4:enemy.windup_duration=1;enemy.windup=.5
   if index in [5,6]:enemy.strike_duration=1;enemy.strike_left=.8 if index==5 else .1
   if index==7:enemy.recovery=.2
   if index in [8,9]:enemy.hurt_left=.2;enemy.hit_reaction=.8 if index==8 else .1
   if index in [10,11]:enemy.health=0;enemy.death_elapsed=0 if index==10 else .6
   enemy._update_rig(0)
   await process_frame;await RenderingServer.frame_post_draw
   var at: Vector2=root.get_final_transform()*enemy.get_global_transform_with_canvas().origin
   var crop:=root.get_texture().get_image().get_region(Rect2i(int(at.x)-300,int(at.y)-400,600,420)) if enemy.is_boss else root.get_texture().get_image().get_region(Rect2i(int(at.x)-150,int(at.y)-240,300,260))
   if enemy.is_boss:
    crop.resize(300,210,Image.INTERPOLATE_NEAREST)
    var padded:=Image.create(300,260,false,Image.FORMAT_RGBA8)
    padded.blit_rect(crop,Rect2i(0,0,300,210),Vector2i(0,50));crop=padded
   sheet.blit_rect(crop,Rect2i(0,0,300,260),Vector2i((index%4)*300,(index/4)*260))
  sheet.save_jpg("res://../docs/qa/drawn-monster-%03d.jpg"%id,.82)
  enemy.queue_free();await process_frame
 label.queue_free();root.get_node("Audio").shutdown();await create_timer(.15).timeout;quit()
