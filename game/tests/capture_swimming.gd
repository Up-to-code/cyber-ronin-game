extends SceneTree
func _initialize():call_deferred("run")
func run():
 root.size=Vector2i(1152,648)
 var world:=Node2D.new();root.add_child(world)
 var bg:=Polygon2D.new();bg.polygon=PackedVector2Array([Vector2.ZERO,Vector2(640,0),Vector2(640,360),Vector2(0,360)]);bg.color=Color("092b3a");world.add_child(bg)
 var p=load("res://actors/player_2d.gd").new();p.position=Vector2(320,245);world.add_child(p)
 var fx=load("res://systems/pixel_fx.gd").new();world.add_child(fx);p.fx_requested.connect(fx.spawn)
 p.set_submerged(true)
 Input.action_press("move_right")
 for i in range(18):await physics_frame;await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://../docs/qa/swim-pose-native.png")
 Input.action_release("move_right")
 root.get_node("Audio").shutdown();quit()
