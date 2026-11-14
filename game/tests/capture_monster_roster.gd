extends SceneTree
func _initialize():call_deferred("run")
func run():
 var world:=Node2D.new()
 root.add_child(world)
 world.scale=Vector2(0.55,0.55)
 var background:=ColorRect.new()
 background.color=Color("160c16");background.size=Vector2(1152,648);world.add_child(background)
 var roster=load("res://data/monster_roster.gd")
 for i in range(10):
  var spec=roster.get_monster(i*11+1)
  var enemy=load("res://actors/enemy_2d.gd").new()
  enemy.enemy_kind=spec.kind
  enemy.position=Vector2(115+(i%5)*224,270+(i/5)*280)
  world.add_child(enemy)
  enemy.set_physics_process(false)
  enemy.apply_monster_profile(spec.id)
  enemy._update_rig(0)
  enemy.role_badge.visible=true
  var label:=Label.new()
  label.text="%03d  %s\n%s" % [spec.id,spec.name.rsplit(" ",true,1)[0],spec.behavior.to_upper()]
  label.add_theme_font_override("font",load("res://art/pixel/PixelifySans.ttf"))
  label.add_theme_font_size_override("font_size",14)
  label.position=enemy.position+Vector2(-102,12)
  world.add_child(label)
 for i in range(10):await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://../docs/qa/monster-roster-gallery.png")
 root.get_node("Audio").shutdown()
 quit()
