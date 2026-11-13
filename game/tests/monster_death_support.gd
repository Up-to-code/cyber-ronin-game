extends SceneTree
func _initialize():call_deferred("run")
func run():
 var floor=StaticBody2D.new();var collider=CollisionShape2D.new();var shape=RectangleShape2D.new();shape.size=Vector2(4000,60);collider.shape=shape;collider.position.y=30;floor.add_child(collider);root.add_child(floor)
 await physics_frame
 for id in range(1,26 if "--first25" in OS.get_cmdline_user_args() else 101):
  var enemy=load("res://actors/enemy_2d.gd").new();root.add_child(enemy);enemy.set_physics_process(false);enemy.apply_monster_profile(id)
  enemy.position=Vector2.ZERO;enemy.velocity=Vector2(0,100)
  enemy.move_and_slide()
  assert(enemy.is_on_floor(),"Fixture must establish actual floor contact")
  for face in [-1.0,1.0]:
   enemy.facing=face;enemy.health=100;enemy.motion_visual.dying=false;enemy.motion_visual.tick(0)
   enemy.health=0;enemy.knockback=face*80;enemy.motion_visual.begin_death()
   for age in [0.0,.12,.3,.48,.9,1.28]:
    enemy.death_elapsed=age;enemy._update_rig(.016)
    var motion=enemy.motion_visual
    var bounds: Rect2i=motion.sprite.texture.get_image().get_used_rect()
    var bottom: Vector2=motion.sprite.to_global(Vector2(bounds.end))
    assert(absf(bottom.y-enemy.global_position.y)<2.1,"Drawn corpse must rest on actual floor %d"%id)
    assert(not enemy.rig.sprite.visible,"Death must not restore idle cel")
   assert(enemy.motion_visual.modulate.a<.01,"Corpse fades before removal")
  enemy.free()
 root.get_node("Audio").shutdown()
 print("PASS: ",25 if "--first25" in OS.get_cmdline_user_args() else 100," monsters, both facings, six death phases: floor support, pose continuity, fade")
 quit()
